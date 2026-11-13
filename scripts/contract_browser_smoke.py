#!/usr/bin/env python3
"""Behavioral check of the pilot with synthetic fixtures only."""
import argparse
from datetime import datetime, timedelta
from decimal import Decimal
import json
from pathlib import Path
import re
from urllib.parse import parse_qs, urlparse
from playwright.sync_api import sync_playwright, expect

parser = argparse.ArgumentParser()
parser.add_argument('--fixtures', default='/tmp/nwb-ui-fixture.json')
parser.add_argument('--env-file', default='.env')
parser.add_argument('--base', default='http://127.0.0.1:3000')
args = parser.parse_args()
paths = json.loads(Path(args.fixtures).read_text())
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
report = {'checks': [], 'page_batches': []}

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 1440, 'height': 900})
    errors = []
    page.on('pageerror', lambda error: errors.append(str(error)))

    def response_seen(response):
        if 'cursor' in parse_qs(urlparse(response.url).query) and response.status == 200:
            text = response.text()
            report['page_batches'].append(len(re.findall('data-contract-item=', text)))
    page.on('response', response_seen)
    page.goto(args.base + '/session/new')
    page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
    page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
    page.get_by_role('button', name='Anmelden', exact=True).click()
    page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    page.goto(args.base + paths['contracts'])
    page.locator('.contract-item').first.wait_for()
    page.wait_for_timeout(150)
    assert page.locator('.contract-item').count() == 30
    assert page.locator('.contract-sidebar nav a').all_text_contents() == ['Anlagen', 'Verträge']
    assert page.locator('nav[aria-label="Ergebnisseiten"]').count() == 0
    report['checks'].append('Initial DOM contains 30 contracts, no numbered pagination or customer main navigation')

    def search(value):
        old = page.locator('turbo-frame#contract_browser')
        page.get_by_label('Suche', exact=True).fill(value)
        with page.expect_response(lambda response: '/supply_contracts' in response.url and response.request.headers.get('turbo-frame') == 'contract_browser' and response.status == 200):
            page.get_by_role('button', name='Suchen', exact=True).click()
        expect(page.get_by_label('Suche', exact=True)).to_have_value(value)
        page.wait_for_timeout(100)

    search('Beispiel')
    assert page.locator('.contract-item').count() == 30
    total = int(re.search(r'\d+', page.locator('.contract-list-heading strong').inner_text()).group())
    assert total >= 150
    for _ in range(10):
        previous = page.locator('.contract-item').count()
        if previous >= total:
            break
        page.locator('.contract-list-scroll').evaluate('(el) => {el.scrollTop = el.scrollHeight}')
        page.wait_for_function('(count) => document.querySelectorAll(".contract-item").length > count', arg=previous)
        assert page.locator('.contract-item').count() - previous <= 30
    assert page.locator('.contract-item').count() == total
    ids = page.locator('.contract-item').evaluate_all('(items) => items.map(item => item.dataset.contractItem)')
    assert len(set(ids)) == total
    assert all(0 < size <= 30 for size in report['page_batches'])
    report['checks'].append('Explicit scrolling loads all synthetic results in bounded batches without duplicates')

    link = page.locator('.contract-item a').nth(42)
    link.scroll_into_view_if_needed()
    selected = link.get_attribute('data-contract-id')
    page.evaluate('window.__nwbListNode = document.querySelector(".contract-list-scroll")')
    before = page.locator('.contract-list-scroll').evaluate('(el) => el.scrollTop')
    assert before > 0
    link.click()
    expect(page.locator('#contract_workspace')).to_have_attribute('data-contract-id', selected)
    assert page.evaluate('window.__nwbListNode === document.querySelector(".contract-list-scroll")')
    assert abs(page.locator('.contract-list-scroll').evaluate('(el) => el.scrollTop') - before) < 2
    expect(page.get_by_label('Suche', exact=True)).to_have_value('Beispiel')
    assert parse_qs(urlparse(page.url).query)['q'] == ['Beispiel']
    report['checks'].append('Selection replaces the detail frame only, preserving DOM, scroll position, filter and URL state')

    page.get_by_role('link', name='Historie', exact=True).click()
    page.locator('#contract-history').wait_for()
    assert page.evaluate('window.__nwbListNode === document.querySelector(".contract-list-scroll")')
    page.get_by_role('link', name='Übersicht', exact=True).click()
    for section in ['contract_customer', 'contract_connection', 'contract_terms', 'contract_meter']:
        page.locator('#' + section).wait_for()
    report['checks'].append('Overview shows customer, connection, terms and meter together; History is a real optional detail')

    focused = page.locator('.contract-item a[data-contract-id="' + selected + '"]')
    focused.focus()
    focused.press('ArrowDown')
    next_id = page.evaluate('document.activeElement.dataset.contractId')
    assert next_id and next_id != selected
    page.keyboard.press('Enter')
    expect(page.locator('#contract_workspace')).to_have_attribute('data-contract-id', next_id)
    report['checks'].append('Arrow keys and Enter select contracts using native keyboard focus')

    search('UX-150')
    expect(page.locator('.contract-item')).to_have_count(1)
    expect(page.locator('.record-heading')).to_contain_text('UX-150')
    report['checks'].append('Search finds an uninitially loaded contract via the complete server dataset')

    search('UX-001')
    expect(page.locator('.record-heading')).to_contain_text('UX-001')
    page.evaluate('window.__nwbListNode = document.querySelector(".contract-list-scroll")')
    page.get_by_role('link', name='Kundendaten bearbeiten', exact=True).click()
    phone = '0000-UI-CONTEXT'
    page.get_by_label('Telefon', exact=True).fill(phone)
    page.get_by_role('button', name='Kunde speichern', exact=True).click()
    expect(page.locator('#contract_customer')).to_contain_text(phone)
    expect(page.locator('#contract_customer').get_by_role('button', name='Kunde speichern')).to_have_count(0)
    assert page.evaluate('window.__nwbListNode === document.querySelector(".contract-list-scroll")')
    expect(page.get_by_label('Suche', exact=True)).to_have_value('UX-001')
    report['checks'].append('Customer edit saves in place and returns to the same contract without a customer-menu detour')

    def dd(section, label):
        return page.locator('#' + section).locator('dt').filter(has_text=re.compile('^' + re.escape(label) + '$')).locator('xpath=following-sibling::dd').first.inner_text().strip()
    previous_date = datetime.strptime(dd('contract_meter', 'Ablesedatum'), '%d.%m.%Y').date()
    previous_value = Decimal(dd('contract_meter', 'Letzter Zählerstand').split()[0].replace('.', '').replace(',', '.'))
    next_value = previous_value + Decimal('100.123456')
    next_date = previous_date + timedelta(days=1)
    page.get_by_role('link', name='Neue Ablesung', exact=True).click()
    page.get_by_label('Ablesedatum', exact=True).fill(previous_date.isoformat())
    page.get_by_label('Kumulativer Zählerstand', exact=True).fill(str(next_value))
    page.get_by_role('button', name='Ablesung speichern', exact=True).click()
    expect(page.locator('#contract_meter [role="alert"]')).to_contain_text('bereits')
    expect(page.get_by_label('Kumulativer Zählerstand', exact=True)).to_have_value(str(next_value))
    page.get_by_label('Ablesedatum', exact=True).fill(next_date.isoformat())
    page.get_by_role('button', name='Ablesung speichern', exact=True).click()
    expect(page.locator('#contract_meter').get_by_role('link', name='Neue Ablesung', exact=True)).to_be_visible()
    assert dd('contract_meter', 'Ablesedatum') == next_date.strftime('%d.%m.%Y')
    displayed = Decimal(dd('contract_meter', 'Letzter Zählerstand').split()[0].replace('.', '').replace(',', '.'))
    assert displayed == next_value
    assert page.evaluate('window.__nwbListNode === document.querySelector(".contract-list-scroll")')
    report['checks'].append('Duplicate reading reports inline errors and retains inputs; valid reading refreshes exact current value in the same workspace')

    page.get_by_role('link', name='Zählerhistorie und Wechsel', exact=True).click()
    page.locator('#contract_detail #readings').wait_for()
    assert page.evaluate('window.__nwbListNode === document.querySelector(".contract-list-scroll")')
    page.get_by_role('link', name='Zur Vertragsakte', exact=True).click()
    expect(page.locator('#contract_meter').get_by_role('link', name='Neue Ablesung', exact=True)).to_be_visible()
    report['checks'].append('Complex meter details stay in the right pane and return without replacing the list')
    assert not errors, errors
    report['checks'].append('No JavaScript page errors')
    browser.close()
Path('docs/ui-contracts').mkdir(exist_ok=True)
Path('docs/ui-contracts/browser-checks.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
