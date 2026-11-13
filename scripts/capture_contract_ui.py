#!/usr/bin/env python3
"""Capture the same synthetic contract views and measure actual desktop geometry."""
import argparse
import json
import statistics
from pathlib import Path
from playwright.sync_api import sync_playwright

parser = argparse.ArgumentParser()
parser.add_argument('phase', choices=['before', 'after'])
parser.add_argument('--fixtures', default='/tmp/nwb-ui-fixture.json')
parser.add_argument('--env-file', default='.env')
parser.add_argument('--base', default='http://127.0.0.1:3000')
args = parser.parse_args()
paths = json.loads(Path(args.fixtures).read_text())
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
out = Path('docs/ui-contracts/screenshots') / args.phase
out.mkdir(parents=True, exist_ok=True)
metrics = {}

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    for width, height in [(1280, 800), (1440, 900), (1920, 1080), (2560, 1440)]:
        context = browser.new_context(viewport={'width': width, 'height': height}, device_scale_factor=1, reduced_motion='reduce')
        page = context.new_page()
        page.goto(args.base + '/session/new')
        page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
        page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
        page.get_by_role('button', name='Anmelden', exact=True).click()
        page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
        for key in ['contracts', 'contract_detail']:
            response = page.goto(args.base + paths[key])
            assert response.status == 200, (key, response.status)
            page.wait_for_function('document.documentElement.dataset.colorPreset !== undefined')
            if args.phase == 'after':
                page.locator('.contract-list-scroll').wait_for()
            page.screenshot(path=str(out / f'{key}-{width}x{height}.png'))
            result = page.evaluate('''() => {
              const list = document.querySelector('.contract-list-scroll');
              const rows = [...document.querySelectorAll(list ? '.contract-list-scroll [data-contract-item]' : '.record-grid > article')];
              const viewport = list?.getBoundingClientRect() || {top:0,bottom:innerHeight};
              const rects = rows.map(row=>row.getBoundingClientRect());
              const controls = [...document.querySelectorAll('.contract-filters .field input,.contract-filters .field select')];
              return {loadedRows:rows.length,visibleRows:rects.filter(r=>r.top>=viewport.top && r.bottom<=viewport.bottom && r.height>0).length,
                rowHeights:rects.map(r=>r.height),firstRowTop:rects[0]?.top??null,
                documentHeight:document.documentElement.scrollHeight,documentWidth:document.documentElement.scrollWidth,
                viewport:{width:innerWidth,height:innerHeight},horizontalOverflow:document.documentElement.scrollWidth>innerWidth,
                contentWidth:document.querySelector('main').getBoundingClientRect().width,
                listHeight:list?.clientHeight??null,listScrollHeight:list?.scrollHeight??null,
                detailHeight:document.querySelector('.contract-detail-scroll')?.clientHeight??null,
                detailScrollHeight:document.querySelector('.contract-detail-scroll')?.scrollHeight??null,
                filterTopRows:[...new Set(controls.map(el=>Math.round(el.getBoundingClientRect().top)))]};
            }''')
            result['medianRowHeight'] = round(statistics.median(result.pop('rowHeights')), 2) if result['loadedRows'] else None
            metrics[f'{key}-{width}x{height}'] = result
        context.close()
    browser.close()
Path('docs/ui-contracts', f'{args.phase}-metrics.json').write_text(json.dumps(metrics, indent=2) + '\n')
print(json.dumps(metrics, indent=2))
