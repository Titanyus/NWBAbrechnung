#!/usr/bin/env python3
"""Synthetic desktop plant workflow and shared live-search regressions."""
import asyncio
import json
from pathlib import Path
from urllib.parse import urlparse, parse_qs
from playwright.async_api import async_playwright, expect

async def main():
    settings = dict(line.split('=',1) for line in Path('.env').read_text().splitlines() if '=' in line and not line.startswith('#'))
    paths = json.loads(Path('/tmp/nwb-ui-fixture.json').read_text())
    report = []
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path='/usr/bin/chromium', args=['--no-sandbox'])
        page = await browser.new_page(viewport={'width':1440,'height':900})
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        await page.goto('http://127.0.0.1:3000/session/new')
        await page.get_by_label('E-Mail-Adresse',exact=True).fill('admin@example.test')
        await page.get_by_label('Passwort',exact=True).fill(settings['DEMO_PASSWORD'])
        await page.get_by_role('button',name='Anmelden',exact=True).click()
        await page.locator('#plants-table').wait_for()
        for width,height in [(1280,800),(1440,900),(1920,1080),(2560,1440)]:
            await page.set_viewport_size({'width':width,'height':height})
            assert await page.evaluate('document.documentElement.scrollWidth <= innerWidth')
            colors = await page.evaluate('''() => {const root=getComputedStyle(document.documentElement);return [...document.querySelectorAll('.contract-topbar,.contract-sidebar')].map(el=>[getComputedStyle(el).backgroundColor,root.getPropertyValue('--header').trim()])}''')
            assert all(color[0]=='rgb(43, 66, 31)' for color in colors)
            await page.screenshot(path=f'docs/ui-plant-routes/screenshots/after/plants-{width}x{height}.png')
        report.append('Four desktop sizes: green NWB header/sidebar from existing theme, no page overflow')
        await page.set_viewport_size({'width':1440,'height':900})
        assert await page.locator('#plants-table input[type=radio]').count() == 0
        report.append('Direct edit per row; no marking or radio step')
        q=page.get_by_label('Anlage oder Adresse suchen',exact=True)
        await q.fill('Testanlage 01')
        await expect(page.locator('#plants-table tbody tr')).to_have_count(1)
        await expect(q).to_be_focused()
        assert await q.input_value()=='Testanlage 01'
        await page.get_by_role('link',name='Testanlage 01: Bearbeiten',exact=True).click()
        await page.get_by_label('Anlagenname',exact=True).fill('')
        await page.get_by_role('button',name='Anlage speichern',exact=True).click()
        assert await page.locator('input#plant_name').evaluate('(el)=>!el.validity.valid')
        await page.get_by_label('Anlagenname',exact=True).fill('Testanlage 01')
        await page.get_by_role('button',name='Anlage speichern',exact=True).click()
        await page.locator('#plants-table').wait_for()
        await page.get_by_role('button',name='Testanlage 01: Anlage auswählen',exact=True).click()
        await page.locator('#contract_browser').wait_for()
        report.append('Plant search updates live with focus retained; direct edit validation/save and shared switch open contracts')
        # Debounce one request for a burst of keystrokes.
        requests=[]
        page.on('request', lambda request: requests.append(request.url) if request.headers.get('turbo-frame')=='contract_browser' else None)
        q=page.get_by_label('Suche',exact=True)
        await q.press_sequentially('UX-150',delay=30)
        await expect(page.locator('.contract-item')).to_have_count(1)
        await expect(page.locator('.contract-item')).to_contain_text('UX-150')
        await expect(q).to_be_focused()
        assert len(requests)==1,requests
        await page.get_by_label('Sortierung',exact=True).focus()
        await page.get_by_label('Sortierung',exact=True).select_option('number')
        await expect(page.locator('#contract_sort')).to_be_focused()
        await expect(q).to_have_value('UX-150')
        await expect(page.locator('.contract-item')).to_contain_text('UX-150')
        report.append('300 ms text debounce: one request for typing burst, full-dataset result and focus retained')
        delayed=[]
        async def delay(route):
            if parse_qs(urlparse(route.request.url).query).get('q')==['UX-001']:
                delayed.append(True)
                response=await route.fetch()
                await asyncio.sleep(.9)
                try: await route.fulfill(response=response)
                except Exception: pass
            else: await route.continue_()
        await page.route('**/supply_contracts?**',delay)
        await q.fill('UX-001')
        await page.wait_for_timeout(400)
        await q.fill('UX-002')
        await expect(page.locator('.contract-item')).to_contain_text('UX-002')
        await page.wait_for_timeout(1000)
        await expect(page.locator('.contract-item')).to_contain_text('UX-002')
        assert delayed
        await page.unroute('**/supply_contracts?**')
        await page.get_by_label('Status',exact=True).select_option('ended')
        await expect(page.locator('.contract-item')).to_have_count(0)
        report.append('Delayed earlier query cannot overwrite latest input; dropdown applies without submit')
        await page.get_by_label('Status',exact=True).select_option('')
        await q.fill('')
        await expect(page.locator('.contract-item')).to_have_count(30)
        await page.locator('.filter-secondary summary').click()
        await q.fill('Abzubrechende Suche')
        await page.get_by_role('link',name='Alle Filter zurücksetzen',exact=True).click()
        await expect(page.locator('.contract-item')).to_have_count(30)
        await expect(q).to_have_value('')
        report.append('Explicit filter reset supersedes pending debounced input')
        for width,height in [(1280,800),(1440,900),(1920,1080),(2560,1440)]:
            await page.set_viewport_size({'width':width,'height':height})
            await page.screenshot(path=f'docs/ui-plant-routes/screenshots/after/contracts-{width}x{height}.png')
        await page.set_viewport_size({'width':1440,'height':900})
        for preset in ['billenhausen','emerald','ocean','slate']:
            for mode in ['light','dark']:
                await page.evaluate('([preset,mode]) => localStorage.setItem("nwb.appearance.v1",JSON.stringify({preset,mode}))', [preset,mode])
                await page.reload()
                await page.wait_for_function('([preset,mode]) => document.documentElement.dataset.colorPreset === preset && document.documentElement.dataset.colorMode === mode', arg=[preset,mode])
                assert await page.evaluate('''() => {
                    const header=getComputedStyle(document.documentElement).getPropertyValue('--header').trim();
                    const rgb=header.slice(1).match(/../g).map(n=>parseInt(n,16));
                    return [...document.querySelectorAll('.contract-topbar,.contract-sidebar')].every(el=>getComputedStyle(el).backgroundColor === `rgb(${rgb.join(', ')})`);
                }''')
        await page.evaluate('localStorage.removeItem("nwb.appearance.v1")')
        report.append('All eight theme/mode combinations reuse existing header color in both chrome areas')
        # Every existing search uses the same controller/data contract.
        for key,label,query,frame in [('customers','Kunde oder Kundennummer suchen','Beispielbetrieb 01','customer-results'),('connections','Anschlussnummer oder Adresse suchen','UX-150','connection-results')]:
            await page.goto('http://127.0.0.1:3000'+paths[key])
            await page.get_by_label(label,exact=True).fill(query)
            await expect(page.locator(f'#{frame} .record-grid article')).to_have_count(1)
            await expect(page.get_by_label(label,exact=True)).to_be_focused()
        await page.goto('http://127.0.0.1:3000'+paths['new_customer'])
        await page.locator('input#customer_first_name').fill('Ungespeicherte Eingabe')
        await page.get_by_label('Name eines bereits sichtbaren Kunden',exact=True).fill('nichtvorhanden')
        await expect(page.locator('#available-customers select')).to_have_count(0)
        await expect(page.locator('input#customer_first_name')).to_have_value('Ungespeicherte Eingabe')
        report.append('Customer, connection and customer-assignment searches update live; unrelated unsaved creation fields survive')
        await page.context.clear_cookies()
        await page.get_by_label('Name eines bereits sichtbaren Kunden',exact=True).fill('Sitzung beendet')
        await page.get_by_role('heading',name='Willkommen bei NWB',exact=True).wait_for()
        report.append('Expired login during a live query returns to the full login page')
        assert not errors, errors
        report.append('No JavaScript errors')
        await browser.close()
    Path('docs/ui-plant-routes/browser-checks.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

asyncio.run(main())
