import json
from pathlib import Path

ROOT = Path(__file__).parent

def build():
    data = json.loads((ROOT / 'data.json').read_text())
    payload = 'const DATA = ' + json.dumps(data).replace('<', '\\u003c') + ';'
    html = (ROOT / 'template.html').read_text().replace('/*__DATA__*/', payload)
    (ROOT / 'index.html').write_text(html)
    print('Built index.html:', len(html), 'bytes')

if __name__ == '__main__':
    build()
