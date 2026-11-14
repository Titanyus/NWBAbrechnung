#!/usr/bin/env python3
"""Synthetic plant save return, cancellation, confirmed removal and occupied-plant guard."""
import argparse
import json
from pathlib import Path
from uuid import uuid4
from playwright.sync_api import sync_playwright, expect

parser=argparse.ArgumentParser()
parser.add_argument('--env-file',default='.env')
parser.add_argument('--base',default='http://127.0.0.1:3000')
parser.add_argument('--output',default='docs/ui-plant-removal')
args=parser.parse_args()
settings=dict(line.split('=',1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
base=args.base.rstrip('/')
name='SYN-Delete-'+uuid4().hex[:8]
out=Path(args.output,'screenshots');out.mkdir(parents=True,exist_ok=True)
report=[]
with sync_playwright() as p:
 b=p.chromium.launch(executable_path='/usr/bin/chromium',args=['--no-sandbox'])
 page=b.new_page(viewport={'width':1440,'height':900});errors=[];page.on('pageerror',lambda error:errors.append(str(error)))
 page.goto(base+'/session/new');page.get_by_label('E-Mail-Adresse',exact=True).fill('admin@example.test');page.get_by_label('Passwort',exact=True).fill(settings['DEMO_PASSWORD']);page.get_by_role('button',name='Anmelden',exact=True).click();page.locator('#plants-table').wait_for()
 page.get_by_role('link',name='Neue Anlage anlegen',exact=True).click()
 page.get_by_label('Anlagenname',exact=True).fill(name);page.get_by_label('Straße und Hausnummer',exact=True).fill('Löschtestweg 1');page.get_by_label('PLZ',exact=True).fill('01234');page.get_by_label('Ort',exact=True).fill('Testort');page.get_by_role('button',name='Anlage speichern',exact=True).click()
 page.locator('#plants-table').wait_for();assert page.url==base+'/plants';report.append('Saving a new plant returns to overview')
 page.get_by_role('link',name=name+': Bearbeiten',exact=True).click();page.locator('#plant-form').wait_for();edit_url=page.url
 page.get_by_label('Technische Hinweise (optional)',exact=True).fill('Speichertest')
 page.get_by_role('button',name='Anlage speichern',exact=True).click();page.locator('#plants-table').wait_for();assert page.url==base+'/plants';report.append('Saving changes also returns to overview')
 page.get_by_role('link',name=name+': Bearbeiten',exact=True).click();page.locator('#plant-form').wait_for()
 for width,height in [(1280,800),(1440,900),(1920,1080),(2560,1440)]:
  page.set_viewport_size({'width':width,'height':height});assert page.evaluate('document.documentElement.scrollWidth <= innerWidth');page.screenshot(path=str(out/f'plant-detail-{width}x{height}.png'))
 page.set_viewport_size({'width':1440,'height':900});page.get_by_role('link',name='Anlage löschen',exact=True).click();page.get_by_role('heading',name=name+' wirklich löschen?',exact=True).wait_for();page.screenshot(path=str(out/'confirmation-1440x900.png'))
 page.get_by_role('link',name='Abbrechen',exact=True).click();page.locator('#plant-form').wait_for();expect(page.get_by_label('Anlagenname',exact=True)).to_have_value(name);report.append('Delete opens explicit confirmation; cancel preserves plant')
 page.get_by_role('link',name='Anlage löschen',exact=True).click();page.get_by_role('button',name='Löschen bestätigen',exact=True).click();page.locator('#plants-table').wait_for()
 assert page.locator('#plants-table').get_by_role('link',name=name,exact=True).count()==0
 assert name not in page.locator('#selected_plant_id').inner_text()
 response=page.goto(edit_url);assert response.status==404
 report.append('Confirmed removal returns to overview, excludes plant from header/list and blocks its direct URL')
 page.goto(base+'/plants');page.get_by_role('link',name='Testanlage 01: Bearbeiten',exact=True).click();page.locator('#plant-form').wait_for();page.get_by_role('link',name='Anlage löschen',exact=True).click();page.locator('[role=alert]').filter(has_text='kann nicht gelöscht werden').wait_for();assert page.get_by_role('button',name='Löschen bestätigen',exact=True).count()==0;page.screenshot(path=str(out/'occupied-plant-1440x900.png'));report.append('Occupied plant shows explanation and offers no delete confirmation button')
 assert not errors,errors;report.append('Four desktop sizes without horizontal overflow; no JavaScript errors');b.close()
Path(args.output,'browser-checks.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
