#!/usr/bin/env python3
"""Independent browser contrast and persistence regression checks."""
from pathlib import Path
from playwright.sync_api import sync_playwright

settings = dict(line.split('=', 1) for line in Path('.env').read_text().splitlines() if '=' in line)

def luminance(color):
    channels = [int((('#' + ''.join(c * 2 for c in color[1:])) if len(color) == 4 else color)[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels]
    return sum(c * w for c, w in zip(linear, (0.2126, 0.7152, 0.0722)))

def ratio(first, second):
    a, b = sorted((luminance(first), luminance(second)))
    return (b + 0.05) / (a + 0.05)

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 390, 'height': 900})
    page.goto('http://127.0.0.1:3000/session/new')
    page.get_by_label('E-Mail-Adresse').fill('admin@example.test')
    page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
    page.get_by_role('button', name='Anmelden', exact=True).click()
    page.get_by_role('link', name='Darstellung', exact=True).click()
    page.get_by_role('heading', name='Farben nach Ihrem Geschmack').wait_for()
    checks = 0
    for preset in ('billenhausen', 'emerald', 'ocean', 'slate'):
        page.get_by_label('Farbvorlage').select_option(preset)
        for mode in ('light', 'dark'):
            page.get_by_label('Darstellungsmodus').select_option(mode)
            for accent in (None, '#000000', '#ffffff', '#808080', '#ffff00'):
                if accent:
                    page.get_by_label('Eigene Akzentfarbe', exact=True).evaluate('(el, value) => { el.value = value; el.dispatchEvent(new Event("input", { bubbles: true })) }', accent)
                else:
                    page.get_by_label('Farbvorlage').select_option(preset)
                colors = page.evaluate('''() => {
                  const css = getComputedStyle(document.documentElement);
                  return Object.fromEntries(['accent','accent-text','link','page','surface'].map(key => [key, css.getPropertyValue('--' + key).trim()]));
                }''')
                assert ratio(colors['accent'], colors['accent-text']) >= 4.5, colors
                assert ratio(colors['link'], colors['page']) >= 4.5, colors
                assert ratio(colors['link'], colors['surface']) >= 4.5, colors
                assert page.evaluate('document.documentElement.scrollWidth <= innerWidth')
                checks += 1
    page.get_by_label('Farbvorlage').select_option('ocean')
    page.get_by_label('Darstellungsmodus').select_option('dark')
    page.reload()
    assert page.get_by_label('Farbvorlage').input_value() == 'ocean'
    assert page.get_by_label('Darstellungsmodus').input_value() == 'dark'
    page.get_by_role('link', name='Anlagen', exact=True).click()
    page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    assert page.locator('html').get_attribute('data-color-mode') == 'dark'
    page.get_by_role('link', name='Darstellung', exact=True).click()
    page.get_by_role('button', name='Auf NWB und Hell zurücksetzen').click()
    assert page.locator('html').get_attribute('data-color-mode') == 'light'
    assert page.get_by_label('Farbvorlage').input_value() == 'billenhausen'
    # Invalid local configuration cannot become CSS or an inherited preset.
    page.evaluate('localStorage.setItem("nwb.appearance.v1", JSON.stringify({preset:"__proto__",mode:"wrong",accent:"red;display:none"}))')
    page.reload()
    assert page.get_by_label('Farbvorlage').input_value() == 'billenhausen'
    assert page.locator('html').get_attribute('data-color-mode') == 'light'
    browser.close()
print(f'PASS: {checks} theme/contrast combinations, mobile layout, reload/navigation persistence, reset and invalid storage')
