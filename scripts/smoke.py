#!/usr/bin/env python3
"""Real HTTP readiness, CSRF, login, assets and logout; synthetic stacks only."""
import argparse
import http.cookiejar
from html.parser import HTMLParser
from pathlib import Path
import urllib.request
import urllib.error
import urllib.parse

parser = argparse.ArgumentParser()
parser.add_argument('--env-file', default='.env')
parser.add_argument('--port', default='3000')
args = parser.parse_args()
settings = dict(line.split('=', 1) for line in Path(args.env_file).read_text().splitlines() if '=' in line and not line.startswith('#'))
base = 'http://127.0.0.1:' + args.port
jar = http.cookiejar.CookieJar()
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

class Page(HTMLParser):
    def __init__(self, body):
        super().__init__()
        self.csrf = None
        self.assets = []
        self.feed(body)
    def handle_starttag(self, tag, attributes):
        attr = dict(attributes)
        if tag == 'meta' and attr.get('name') == 'csrf-token':
            self.csrf = attr['content']
        if tag == 'link' and attr.get('rel') == 'stylesheet':
            self.assets.append(attr['href'])

def get(path):
    return client.open(base + path, timeout=10)

def post(path, data):
    return client.open(base + path, urllib.parse.urlencode(data).encode(), timeout=10)

assert get('/up').status == 200
response = get('/plants')
assert response.url.endswith('/session/new')
body = response.read().decode()
page = Page(body)
assert page.csrf
assert page.assets
for asset in page.assets:
    assert get(asset).status == 200
try:
    post('/session', {'email_address': 'admin@example.test', 'password': settings['DEMO_PASSWORD']})
    raise AssertionError('CSRF-less login unexpectedly accepted')
except urllib.error.HTTPError as error:
    assert error.code == 422
page = Page(get('/session/new').read().decode())
response = post('/session', {'authenticity_token': page.csrf, 'email_address': 'admin@example.test', 'password': settings['DEMO_PASSWORD']})
body = response.read().decode()
assert 'Ihre Nahwärmeanlagen' in body
assert response.headers['Cache-Control'] == 'no-store'
assert 'Testanlage 01' in body
page = Page(body)
response = post('/session', {'_method': 'delete', 'authenticity_token': page.csrf})
assert response.url.endswith('/session/new')
assert get('/plants').url.endswith('/session/new')
print('PASS: Docker HTTP/DB readiness, CSRF rejection, login, local CSS, authenticated scope and logout')
