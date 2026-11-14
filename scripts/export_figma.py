#!/usr/bin/env python3
"""Export the rendered synthetic desktop UI and resolved tokens for the local Figma plugin."""
import argparse
import json
import shutil
import subprocess
from pathlib import Path
from playwright.sync_api import sync_playwright

parser = argparse.ArgumentParser()
parser.add_argument('--env-file', default='.env')
parser.add_argument('--fixtures', default='/tmp/nwb-ui-fixture.json')
parser.add_argument('--base', default='http://127.0.0.1:3000')
parser.add_argument('--output', default='/workspace/NWB-Figma-Export')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
out = Path(args.output)
(out / 'screenshots').mkdir(parents=True, exist_ok=True)
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
paths = json.loads(Path(args.fixtures).read_text())
capture = (root / 'design/figma/capture.js').read_text()
result = {'format': 'nwb-figma-import', 'version': 1, 'sourceCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(), 'screens': [], 'themes': {}, 'components': []}
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 1440, 'height': 900}, reduced_motion='reduce')
    page.goto(args.base + '/session/new')
    page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
    page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
    page.get_by_role('button', name='Anmelden', exact=True).click()
    page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    targets = {'Verträge – Übersicht': paths['contracts'], 'Verträge – Anlegen': paths['contracts'] + '/new', 'Anlagen – Übersicht': '/plants', 'Anlagen – Anlegen': '/plants/new', 'Anlagen – Bearbeiten': paths['plant'] + '/edit', 'Anlagen – Details': paths['plant'], 'Kunden – Bearbeiten': paths['customer_form'], 'Anschlüsse – Bearbeiten': paths['connection_form'], 'Zähler – Anlegen': paths['meter_form'], 'Ablesung – Erfassen': paths['reading_form'], 'Darstellung': '/appearance'}
    for preset in ['billenhausen', 'emerald', 'ocean', 'slate']:
        for mode in ['light', 'dark']:
            page.evaluate('(state)=>localStorage.setItem("nwb.appearance.v1",JSON.stringify(state))', {'preset': preset, 'mode': mode, 'accent': None})
            page.goto(args.base + paths['contracts'])
            page.wait_for_function('(preset) => document.documentElement.dataset.colorPreset === preset', arg=preset)
            result['themes'][preset + '/' + mode] = page.evaluate(capture)['tokens']
    page.evaluate('localStorage.removeItem("nwb.appearance.v1")')
    for width, height in [(1440, 900), (1920, 1080)]:
        page.set_viewport_size({'width': width, 'height': height})
        for index, (name, path) in enumerate(targets.items()):
            response = page.goto(args.base + path)
            assert response.status == 200, (name, response.status)
            page.locator('main .page-heading h1').wait_for()
            page.evaluate('document.fonts.ready')
            scene = page.evaluate(capture)
            scene['name'] = f'{name} / {width}×{height}'
            result['screens'].append(scene)
            page.screenshot(path=str(out / 'screenshots' / f'{index+1:02d}-{width}x{height}.png'))
    browser.close()
(out / 'nwb-ui.json').write_text(json.dumps(result, ensure_ascii=False))
for file in ['manifest.json', 'code.js', 'ui.html', 'README.md']:
    shutil.copyfile(root / 'design/figma' / file, out / file)
# W3C-style token exchange; semantic aliases are resolved from the actual browser theme.
tokens = {}
for theme, values in result['themes'].items():
    group = {}
    for name, value in values.items():
        if value.startswith('#') and len(value) == 7:
            group[name] = {'$type': 'color', '$value': {'colorSpace': 'srgb', 'components': [int(value[i:i+2], 16)/255 for i in (1, 3, 5)], 'alpha': 1}}
        elif value.endswith('px'):
            group[name] = {'$type': 'dimension', '$value': {'value': float(value[:-2]), 'unit': 'px'}}
        else:
            group[name] = {'$type': 'string', '$value': value}
    tokens[theme.replace('/', '-')] = group
(out / 'design.tokens.json').write_text(json.dumps(tokens, indent=2) + '\n')
shutil.make_archive(str(out), 'zip', out)
print(f'Exported {len(result["screens"])} screens and {len(result["themes"])} theme definitions to {out}.zip')
