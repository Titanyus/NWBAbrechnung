#!/usr/bin/env python3
"""Verify isolated small/large synthetic installations in one browser context."""
import argparse
from pathlib import Path
from playwright.sync_api import sync_playwright

parser = argparse.ArgumentParser()
parser.add_argument('--large-env', required=True)
args = parser.parse_args()

def password(path):
    return dict(line.split('=', 1) for line in Path(path).read_text().splitlines() if '=' in line)['DEMO_PASSWORD']

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='/usr/bin/chromium', headless=True, args=['--no-sandbox'])
    context = browser.new_context()
    small = context.new_page()
    large = context.new_page()
    def login(page, port, email, secret):
        page.goto(f'http://127.0.0.1:{port}/session/new')
        page.get_by_label('E-Mail-Adresse').fill(email)
        page.get_by_label('Passwort', exact=True).fill(secret)
        page.get_by_role('button', name='Anmelden', exact=True).click()
        page.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    login(small, 3000, 'admin@example.test', password('.env'))
    assert small.locator('#plants-table tbody tr').count() == 3
    login(large, 3001, 'admin@example.test', password(args.large_env))
    assert large.locator('#plants-table tbody tr').count() == 50
    large.get_by_role('button', name='Abmelden', exact=True).click()
    login(large, 3001, 'verwaltung@example.test', password(args.large_env))
    assert large.locator('#plants-table tbody tr').count() == 25
    small.reload()
    small.get_by_role('heading', name='Ihre Nahwärmeanlagen').wait_for()
    assert small.locator('#plants-table tbody tr').count() == 3
    browser.close()
print('PASS: separate installations with 3/50 plants, 25 authorized large plants, independent cookies on the same host')
