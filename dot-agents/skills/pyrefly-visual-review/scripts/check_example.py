#!/usr/bin/env python3
"""Validate the preserved example; optional browser smoke, no Pyrefly execution."""
import argparse
from html.parser import HTMLParser
import json
from pathlib import Path
import sys

SKILL = Path(__file__).resolve().parents[1]
EXAMPLE = SKILL / 'examples' / 'pyrefly-5555'

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.remote_assets = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if tag in {'script', 'img', 'iframe', 'link'}:
            url = attrs.get('src', attrs.get('href', ''))
            if url.startswith(('http:', 'https:', '//')):
                self.remote_assets.append(url)

def check_static():
    text = (SKILL / 'SKILL.md').read_text()
    assert text.startswith('---\nname: pyrefly-visual-review\n')
    assert len(text.splitlines()) < 200
    data = json.loads((EXAMPLE / 'data.json').read_text())
    ids = [case['id'] for case in data['cases']]
    assert len(ids) == len(set(ids)) == 7
    assert data['sourceURL'].endswith('/pyrefly/lib/alt/callable.rs')
    assert '2a215a3bb5880f5f7e94a2d7cb65d12850247c2b' in data['sourceURL']
    for case in data['cases']:
        assert len(case['steps']) == 5
        assert case['traceFocus'] in case['tracePython']
        assert case['state']['consumed'] <= len(case['state']['prefix'])
    for rows in data['excerpts'].values():
        assert all(isinstance(row['n'], int) and row['n'] > 0 for row in rows)
    for field in ['prefix', 'suffix', 'middle', 'consumed', 'matched', 'rparams', 'extra_arg']:
        assert field in data['defs']
    for path in [SKILL / 'SKILL.md', *EXAMPLE.iterdir()]:
        if not path.is_file():
            continue
        value = path.read_text()
        for forbidden in ['internalmeta.com', 'internalfb.com', '/data/atlas/', '/Users/']:
            assert forbidden not in value, (path.name, forbidden)
    parser = Page()
    parser.feed((EXAMPLE / 'template.html').read_text())
    assert not parser.remote_assets
    assert {'rust-state', 'trace-python', 'scope-path', 'whole-file-link', 'function-link', 'excerpt-link'} <= parser.ids
    for mode in ['before', 'after']:
        outputs = json.loads((EXAMPLE / f'{mode}.json').read_text())
        assert all(error['path'] == 'cases.py' for error in outputs['errors'])
    assert 'MIT License' in (EXAMPLE / 'LICENSE.pyrefly').read_text()
    assert len(json.loads((SKILL / 'evals' / 'evals.json').read_text())['evals']) == 3
    print('PASS: metadata, 7 examples, 5-step traces, evidence, source spans, links, licenses, public-data checks.')

def check_browser():
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        raise SystemExit('Browser check needs the optional playwright package and its Chromium installation.')
    # Import the deterministic builder without relying on a checked-in generated file.
    sys.path.insert(0, str(EXAMPLE))
    import build
    build.build()
    html = (EXAMPLE / 'index.html').read_text()
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for theme in ['light', 'dark']:
            page = browser.new_page(viewport={'width':1500, 'height':1050})
            errors = []
            page.on('pageerror', lambda e: errors.append(str(e)))
            page.set_content(html)
            if theme == 'dark':
                page.locator('#theme-toggle').click()
            assert 'no_args(*xs)' in page.locator('#trace-python').inner_text()
            assert 'arg_pre: Star {' in page.locator('#rust-state').inner_text()
            before = page.locator('.line.old').first.evaluate('(el)=>getComputedStyle(el).backgroundColor')
            after = page.locator('.line.add').first.evaluate('(el)=>getComputedStyle(el).backgroundColor')
            assert before != after
            for case in ['zero', 'union', 'explicit', 'prefix', 'suffix', 'matched', 'overload']:
                page.locator(f'[data-case="{case}"]').click()
                for step in range(5):
                    page.locator(f'[data-phase="{step}"]').click()
                    assert page.locator('#trace-python .current').count() == 1
                for lens in ['gate', 'nest', 'create', 'loop', 'advance', 'sink', 'caller']:
                    page.locator(f'[data-lens="{lens}"]').click()
                    assert page.locator('.line').count() > 0
            page.locator('[data-case="zero"]').click()
            for tour in ['create', 'nest', 'sink', 'caller']:
                page.locator(f'[data-tour="{tour}"]').click()
                assert 'no_args(*xs)' in page.locator('#trace-python').inner_text()
            page.locator('[data-case="zero"]').click()
            symbol = page.locator('.sym[data-symbol="consumed"]').first
            symbol.hover()
            assert page.locator('#def-title').inner_text() == 'consumed'
            symbol.click()
            assert 'pinned' in page.locator('#def-title').inner_text()
            page.locator('#unpin').click()
            assert not errors, errors
            page.close()
        page = browser.new_page(viewport={'width':390, 'height':844})
        page.set_content(html)
        page.locator('#mobile-cases').select_option('union')
        assert page.evaluate('document.documentElement.scrollWidth') <= 390
        page.close()
        page = browser.new_page(java_script_enabled=False)
        page.set_content(html)
        assert 'no_args(*xs)' in page.locator('#trace-python').inner_text()
        assert 'arg_pre: Star {' in page.locator('#rust-state').inner_text()
        browser.close()
    print('PASS: browser cases, steps, lenses, context tour, hover/pin, themes, mobile, no-script content.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--browser', action='store_true')
    args = parser.parse_args()
    check_static()
    if args.browser:
        check_browser()
