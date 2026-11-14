#!/usr/bin/env python3
"""Verify one global content frame, page heading and component spacing across admin pages."""
import argparse
import json
from pathlib import Path
from playwright.sync_api import sync_playwright, expect

parser = argparse.ArgumentParser()
parser.add_argument('--env-file', default='.env')
parser.add_argument('--fixture', default='/tmp/nwb-ui-fixture.json')
parser.add_argument('--port', default='3000')
parser.add_argument('--output', default='docs/ui-spacing')
args = parser.parse_args()
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
paths = json.loads(Path(args.fixture).read_text())
base = 'http://127.0.0.1:' + args.port
output = Path(args.output)
(output / 'screenshots').mkdir(parents=True, exist_ok=True)
report = {}
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', args=['--no-sandbox'])
    page = browser.new_page()
    errors = []
    page.on('pageerror', lambda error: errors.append(str(error)))
    page.goto(base + '/session/new')
    page.get_by_label('E-Mail-Adresse', exact=True).fill('admin@example.test')
    page.get_by_label('Passwort', exact=True).fill(settings['DEMO_PASSWORD'])
    page.get_by_role('button', name='Anmelden', exact=True).click()
    page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    targets = {
        'contracts': paths['contracts'], 'plants': '/plants', 'new_plant': '/plants/new',
        'edit_plant': paths['plant'] + '/edit', 'plant_details': paths['plant'],
        'customer_list': paths['customers'], 'customer': paths['customer_detail'],
        'new_customer': paths['new_customer'], 'edit_customer': paths['customer_form'],
        'connections': paths['connections'], 'edit_connection': paths['connection_form'],
        'new_connection': paths['plant'] + '/connections/new', 'meters': paths['meters'],
        'meter': paths['readings'], 'new_meter': paths['meter_form'], 'edit_meter': paths['meter_edit'],
        'meter_replacement': paths['meter_replacement'], 'reading': paths['reading_form'],
        'edit_contract': paths['contract_form'], 'new_contract': paths['contracts'] + '/new',
        'new_route': paths['new_route'], 'appearance': '/appearance',
    }
    for width, height in [(1280, 800), (1440, 900), (1920, 1080), (2560, 1440)]:
        page.set_viewport_size({'width': width, 'height': height})
        reference = None
        for key, path in targets.items():
            response = page.goto(base + path)
            assert response.status == 200, (key, response.status)
            page.locator('main.contract-main .page-heading h1').wait_for()
            metrics = page.evaluate('''() => {
                const main = document.querySelector('main');
                const heading = main.querySelector('.page-heading');
                const h1 = heading.querySelector('h1');
                const m = main.getBoundingClientRect(), h = heading.getBoundingClientRect(), t = h1.getBoundingClientRect();
                const css = getComputedStyle(main);
                const grids = [...main.querySelectorAll('.field-grid,.address-fields')].filter(el => el.getClientRects().length);
                const boxes = [...main.querySelectorAll('.panel,.section,.workspace-panel,fieldset,.toolbar')].filter(el => el.getClientRects().length && parseFloat(getComputedStyle(el).borderTopWidth)>0);
                return { mainLeft:m.left, mainTop:m.top, padding:[css.paddingTop,css.paddingRight,css.paddingBottom,css.paddingLeft],
                    headingLeft:h.left, headingTop:h.top, titleLeft:t.left, titleTop:t.top,
                    headingGap:getComputedStyle(heading).marginBottom,
                    gridGaps:[...new Set(grids.map(el=>getComputedStyle(el).rowGap+' '+getComputedStyle(el).columnGap))],
                    boxInsets:[...new Set(boxes.map(el=>getComputedStyle(el).padding))],
                    horizontalOverflow:document.documentElement.scrollWidth>innerWidth };
            }''')
            assert metrics['padding'] == ['12px', '16px', '12px', '16px'], (key, metrics)
            assert metrics['headingGap'] == '8px', (key, metrics)
            assert not metrics['horizontalOverflow'], (key, metrics)
            assert all(gap == '12px 12px' for gap in metrics['gridGaps']), (key, metrics)
            assert all(inset == '16px' for inset in metrics['boxInsets']), (key, metrics)
            if reference is None:
                reference = metrics
            for coordinate in ['mainLeft', 'mainTop', 'headingLeft', 'headingTop', 'titleLeft', 'titleTop']:
                assert abs(metrics[coordinate] - reference[coordinate]) < 1, (key, coordinate, metrics, reference)
            report[f'{key}-{width}x{height}'] = metrics
            if key in ['contracts', 'plants', 'new_plant', 'edit_customer', 'appearance']:
                page.screenshot(path=str(output / 'screenshots' / f'{key}-{width}x{height}.png'))
    # A success notice must not shift the page title away from the reference inset.
    page.goto(base + paths['plant'] + '/edit')
    page.get_by_role('button', name='Anlage speichern', exact=True).click()
    page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    expect(page.get_by_role('status').filter(has_text='Anlage wurde gespeichert.')).to_be_visible()
    header_before_notice = page.locator('main .page-heading').evaluate('(el)=>el.getBoundingClientRect().top')
    assert header_before_notice == 68, header_before_notice
    assert not errors, errors
    browser.close()
(output / 'metrics.json').write_text(json.dumps(report, indent=2) + '\n')
print(f'PASS: {len(report)} page/viewport checks, shared title/content positions, card/grid spacing, no horizontal overflow, notice below title, no JS errors')
