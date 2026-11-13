#!/usr/bin/env python3
"""Desktop geometry, appearance and delayed-selection regression using synthetic data."""
import asyncio
import json
from pathlib import Path
from playwright.async_api import async_playwright

async def main():
    settings = dict(line.split('=', 1) for line in Path('.env').read_text().splitlines() if '=' in line and not line.startswith('#'))
    paths = json.loads(Path('/tmp/nwb-ui-fixture.json').read_text())
    results = []
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path='/usr/bin/chromium', args=['--no-sandbox'])
        page = await browser.new_page(viewport={'width': 1440, 'height': 900})
        await page.goto('http://127.0.0.1:3000/session/new')
        await page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
        await page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
        await page.get_by_role('button', name='Anmelden', exact=True).click()
        await page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
        await page.goto('http://127.0.0.1:3000' + paths['contracts'])
        await page.locator('[data-contract-item]').first.wait_for()
        # A delayed response must never replace the more recently selected record.
        links = page.locator('.contract-list-scroll a[data-contract-id]')
        old_url = await links.nth(1).get_attribute('href')
        latest_id = await links.nth(2).get_attribute('data-contract-id')
        delayed_requests = []
        async def delay(route):
            delayed_requests.append(route.request.url)
            response = await route.fetch()
            await asyncio.sleep(0.8)
            try:
                await route.fulfill(response=response)
            except Exception:
                pass  # Turbo may cancel the obsolete request.
        await page.route('**' + old_url, delay)
        await links.nth(1).click()
        await links.nth(2).click()
        await page.wait_for_function('(id) => document.querySelector("#contract_workspace")?.dataset.contractId === id', arg=latest_id)
        await asyncio.sleep(1)
        assert await page.locator('#contract_workspace').get_attribute('data-contract-id') == latest_id
        assert len(delayed_requests) == 1, 'Delayed request fixture was not exercised'
        await page.unroute('**' + old_url)
        results.append('Delayed earlier selection cannot overwrite latest contract')
        # 200% zoom equivalent at a Full-HD display: 960 x 540 CSS pixels.
        for width, height in [(1280,800),(1440,900),(1920,1080),(2560,1440),(960,540)]:
            await page.set_viewport_size({'width':width,'height':height})
            assert await page.evaluate('document.documentElement.scrollWidth <= innerWidth')
            for selector in ['.contract-list-scroll', '.contract-detail-scroll']:
                assert await page.locator(selector).evaluate('(el) => el.clientHeight > 100 && getComputedStyle(el).overflowY === "auto"')
            results.append(f'{width}x{height}: independent scrolling, no page overflow')
        await page.set_viewport_size({'width':1440,'height':900})
        await page.locator('#contract_customer dd').first.evaluate('(el) => el.textContent = "Synthetischer langer Firmenname mit Zusatz und mehreren Verwaltungsbereichen ".repeat(4)')
        assert await page.evaluate('document.documentElement.scrollWidth <= innerWidth')
        assert await page.get_by_role('link', name='Kundendaten bearbeiten').is_visible()
        results.append('Long synthetic customer name wraps without hiding actions or overflowing page')
        for preset in ['billenhausen','emerald','ocean','slate']:
            for mode in ['light','dark']:
                await page.evaluate('([preset,mode]) => localStorage.setItem("nwb.appearance.v1",JSON.stringify({preset,mode}))', [preset,mode])
                await page.reload()
                await page.wait_for_function('([preset,mode]) => document.documentElement.dataset.colorPreset === preset && document.documentElement.dataset.colorMode === mode', arg=[preset,mode])
                assert await page.evaluate('document.documentElement.scrollWidth <= innerWidth')
                assert await page.locator('#contract_workspace').is_visible()
                results.append(f'{preset}/{mode}: contract workspace visible without overflow')
        await page.evaluate('localStorage.removeItem("nwb.appearance.v1")')
        await page.reload()
        await page.get_by_role('link', name='Kundendaten bearbeiten').click()
        await page.locator('#contract_customer form').wait_for()
        await page.screenshot(path='docs/ui-contracts/screenshots/customer-editor-1440x900.png')
        await browser.close()
    Path('docs/ui-contracts/visual-checks.json').write_text(json.dumps(results, indent=2)+'\n')
    print(json.dumps(results, indent=2))

asyncio.run(main())
