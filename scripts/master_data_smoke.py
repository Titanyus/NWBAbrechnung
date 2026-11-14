#!/usr/bin/env python3
"""Full synthetic master-data workflow; creates uniquely named test records."""
import argparse
from pathlib import Path
from uuid import uuid4
from playwright.sync_api import sync_playwright, expect

parser = argparse.ArgumentParser()
parser.add_argument('--env-file', default='.env')
parser.add_argument('--port', default='3000')
args = parser.parse_args()
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
base = 'http://127.0.0.1:' + args.port
prefix = 'SYN-' + uuid4().hex[:10]

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 1280, 'height': 950})
    errors = []
    page.on('pageerror', lambda error: errors.append(str(error)))
    page.goto(base + '/session/new')
    page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
    page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
    page.get_by_role('button', name='Anmelden', exact=True).click()
    page.get_by_role('link', name='Testanlage 01', exact=True).click()
    page.get_by_role('heading', name='Anlage: Testanlage 01', level=1, exact=True).wait_for()
    plant_url = page.url.removesuffix("/edit")
    page.get_by_role('link', name='Neue Trasse', exact=True).click()
    page.get_by_label('Bezeichnung', exact=True).fill(prefix + '-Trasse')
    page.get_by_role('button', name='Trasse speichern', exact=True).click()
    page.get_by_role('cell', name=prefix + '-Trasse', exact=True).wait_for()
    page.get_by_text('Weitere Anlageninformationen', exact=True).click()
    page.get_by_role('link', name='Anschlüsse', exact=True).click()
    page.get_by_role('link', name='Anschluss anlegen', exact=True).click()
    page.get_by_label('Anschlussnummer', exact=True).fill(prefix + '-Anschluss')
    page.get_by_label('Straße und Hausnummer', exact=True).fill('Synthetischer Testweg 2')
    page.get_by_label('PLZ', exact=True).fill('00000')
    page.get_by_label('Ort', exact=True).fill('Testort')
    page.get_by_label('Trasse', exact=True).select_option(label=prefix + '-Trasse')
    page.get_by_label('Inbetriebnahme', exact=True).fill('2026-01-01')
    page.get_by_role('button', name='Anschluss speichern', exact=True).click()
    page.get_by_role('heading', name='Anschluss ' + prefix + '-Anschluss', exact=True).wait_for()
    connection_url = page.url
    page.get_by_role('link', name='Kunden', exact=True).click()
    page.get_by_role('link', name='Kunden anlegen oder zuordnen', exact=True).click()
    page.get_by_label('Firmenname (bei Unternehmen)', exact=True).fill(prefix + '-Firma')
    page.get_by_label('Straße und Hausnummer', exact=True).fill('Synthetischer Firmenweg 1')
    page.get_by_label('PLZ', exact=True).fill('00000')
    page.get_by_label('Ort', exact=True).fill('Testort')
    page.get_by_label('Kundennummer (optional)', exact=True).fill(prefix)
    page.get_by_role('button', name='Kunde speichern', exact=True).click()
    page.get_by_role('heading', name=prefix + '-Firma', exact=True).wait_for()
    customer_url = page.url
    page.get_by_role('link', name='Kunde bearbeiten', exact=True).click()
    page.get_by_label('Telefon', exact=True).fill('0000-TEST')
    page.get_by_role('button', name='Kunde speichern', exact=True).click()
    page.get_by_role('heading', name=prefix + '-Firma', exact=True).wait_for()
    assert '0000-TEST' in page.locator('main').inner_text()
    page.get_by_role('link', name='Vertrag anlegen', exact=True).click()
    page.get_by_label('Kunde / Rechnungsempfänger', exact=True).select_option(label=prefix + '-Firma')
    page.get_by_label('Verbrauchsstelle / Anschluss', exact=True).select_option(label=prefix + '-Anschluss')
    page.get_by_label('Vertragsnummer', exact=True).fill(prefix + '-Vertrag')
    page.get_by_label('Vertragsbeginn (einschließlich)', exact=True).fill('2026-01-01')
    page.get_by_label('Vertragsstatus', exact=True).select_option('active')
    page.get_by_role('button', name='Vertrag speichern', exact=True).click()
    page.get_by_role('heading', name='Vertragsakte ' + prefix + '-Vertrag', exact=True).wait_for()
    contract_url = page.url
    page.goto(connection_url)
    page.get_by_role('link', name='Zähler einbauen', exact=True).click()
    page.get_by_label('Zählernummer', exact=True).fill(prefix + '-ALT')
    page.get_by_label('Einbaudatum', exact=True).fill('2026-01-01')
    page.get_by_label('Anfangszählerstand', exact=True).fill('0.125')
    page.get_by_role('button', name='Zähler speichern', exact=True).click()
    page.get_by_role('heading', name='Wärmezähler ' + prefix + '-ALT', exact=True).wait_for()
    old_meter_url = page.url
    page.get_by_role('link', name='Ablesung erfassen', exact=True).click()
    page.get_by_label('Ablesedatum', exact=True).fill('2026-06-01')
    page.get_by_label('Kumulativer Zählerstand', exact=True).fill('100.123456')
    page.get_by_role('button', name='Ablesung speichern', exact=True).click()
    page.get_by_role('heading', name='Wärmezähler ' + prefix + '-ALT', exact=True).wait_for()
    page.locator('.reading').filter(has_text='2026-06-01').get_by_role('link', name='Ablesung korrigieren').click()
    page.get_by_label('Kumulativer Zählerstand', exact=True).fill('101.123456')
    page.get_by_label('Kommentar / Begründung bei Korrektur oder Rückgang', exact=True).fill('Synthetischer Zahlendreher')
    page.get_by_role('button', name='Ablesung speichern', exact=True).click()
    page.get_by_role('heading', name='Wärmezähler ' + prefix + '-ALT', exact=True).wait_for()
    assert page.locator('.reading').filter(has_text='2026-06-01').count() == 2
    assert '100.123456' in page.locator('main').inner_text()
    page.get_by_role('link', name='Zähler wechseln', exact=True).click()
    page.get_by_label('Wechseldatum', exact=True).fill('2026-07-01')
    page.get_by_label('Schlusszählerstand des alten Zählers', exact=True).fill('150.25')
    page.get_by_label('Zählernummer des neuen Zählers', exact=True).fill(prefix + '-NEU')
    page.get_by_label('Anfangszählerstand des neuen Zählers', exact=True).fill('0')
    page.get_by_role('button', name='Zählerwechsel vollständig speichern', exact=True).click()
    page.get_by_role('heading', name='Wärmezähler ' + prefix + '-NEU', exact=True).wait_for()
    new_meter_url = page.url
    page.goto(contract_url)
    page.get_by_role('link', name='Vertragsdaten bearbeiten', exact=True).click()
    page.get_by_label('Vertragsende (einschließlich, optional)', exact=True).fill('2026-06-30')
    page.get_by_label('Vertragsstatus', exact=True).select_option('ended')
    page.get_by_role('button', name='Vertrag speichern', exact=True).click()
    page.get_by_role('heading', name='Vertragsakte ' + prefix + '-Vertrag', exact=True).wait_for()
    expect(page.locator('#contract_terms')).to_contain_text('30.06.2026')
    pages = [plant_url, customer_url, connection_url, contract_url, old_meter_url, new_meter_url, customer_url + '/edit', connection_url + '/edit', contract_url + '/edit', plant_url + '/customers/new', plant_url + '/connections/new', plant_url + '/route_sections/new', plant_url + '/heat_meters/new', new_meter_url + '/meter_readings/new']
    for width in (1280, 1440, 1920, 2560):
        page.set_viewport_size({'width': width, 'height': 950})
        for url in pages:
            page.goto(url)
            assert page.locator('h1').count() == 1
            assert page.evaluate('document.documentElement.scrollWidth <= window.innerWidth'), url
    page.goto(plant_url + '/customers')
    page.get_by_label('Kunde oder Kundennummer suchen', exact=True).fill(prefix)
    page.get_by_role('button', name='Suchen', exact=True).click()
    page.get_by_role('link', name=prefix + '-Firma', exact=True).wait_for()
    assert not errors, errors
    browser.close()
print('PASS: synthetic customer/route/connection/contract/meter creation, edits, reading correction, atomic replacement, search, desktop and no JS errors')
