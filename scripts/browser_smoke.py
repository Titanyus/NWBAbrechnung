#!/usr/bin/env python3
"""Optional desktop/mobile browser checks against a synthetic installation."""
from pathlib import Path
from playwright.sync_api import sync_playwright
settings = dict(line.split('=', 1) for line in Path('.env').read_text().splitlines() if '=' in line)
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    for width in (1280, 390):
        page = browser.new_page(viewport={'width': width, 'height': 900})
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        page.goto('http://127.0.0.1:3000/session/new')
        page.get_by_label('E-Mail-Adresse').fill('admin@example.test')
        page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
        page.get_by_role('button', name='Anmelden', exact=True).click()
        page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
        page.get_by_role('link', name='Testanlage 01', exact=True).click()
        page.get_by_role('heading', name='Stammdaten', exact=True).wait_for()
        assert page.evaluate('typeof window.Turbo') == 'object'
        assert page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')
        page.get_by_role('button', name='Abmelden', exact=True).click()
        page.get_by_role('heading', name='Willkommen bei NWB').wait_for()
        assert not errors, errors
        page.close()
    browser.close()
print('PASS: Chromium desktop/mobile, Hotwire loaded, plant selection, logout, no JS errors or horizontal overflow')
