"""Extract the native Canvas effect discovered outside the Flutter directories."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'source/upstream/FlClash'
COMMIT = 'be84736605527034689c95bf27828ff27d912c5e'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    source = (BASE / 'site/assets/field.js').read_text(encoding='utf-8')
    source = '// Derived from FlClash site/assets/field.js, ' + COMMIT + '; GPL-3.0.\n// Modified 2026-11-05: dispose observers, listeners and RAF for reusable hosts.\n' + source
    changes = [
        ('    let frame = 0;', '    let frame = 0;\n    let disposed = false;\n    let resizeObserver;\n    let intersectionObserver;'),
        ('const run = onScreen && !document.hidden && !still();', 'const run = !disposed && onScreen && !document.hidden && !still();'),
        ('      new ResizeObserver(', '      resizeObserver = new ResizeObserver('),
        ('      new IntersectionObserver(', '      intersectionObserver = new IntersectionObserver('),
        ("      }).observe(canvas);\n    }\n    if ('IntersectionObserver'", "      });\n      resizeObserver.observe(canvas);\n    }\n    if ('IntersectionObserver'"),
        ("      }).observe(canvas);\n    }\n    document.addEventListener", "      });\n      intersectionObserver.observe(canvas);\n    }\n    document.addEventListener"),
        ("    addEventListener(\n      'pointermove',\n      (event) => {\n        if (event.pointerType === 'mouse' && frame) pointer = { x: event.clientX, y: event.clientY };\n      },\n      { passive: true },\n    );", "    const onPointerMove = (event) => {\n      if (event.pointerType === 'mouse' && frame) pointer = { x: event.clientX, y: event.clientY };\n    };\n    addEventListener('pointermove', onPointerMove, { passive: true });"),
        ("    addEventListener(\n      'scroll',\n      () => {", '    const onScroll = () => {'),
        ("      },\n      { passive: true },\n    );\n    sync();", "      };\n    addEventListener('scroll', onScroll, { passive: true });\n    sync();"),
        ('    return { refresh, surge };', '''    function dispose() {
      disposed = true;
      sync();
      resizeObserver?.disconnect();
      intersectionObserver?.disconnect();
      document.removeEventListener('visibilitychange', sync);
      removeEventListener('pointermove', onPointerMove);
      removeEventListener('scroll', onScroll);
      pointer = null;
    }
    return { refresh, surge, dispose };'''),
    ]
    for old, new in changes:
        if old not in source:
            raise SystemExit(f'Review field extraction: {old}')
        source = source.replace(old, new)
    css = (BASE / 'site/assets/style.css').read_text(encoding='utf-8')
    css = '/* Derived from FlClash site/assets/style.css, ' + COMMIT + '; GPL-3.0. Only original tokens retained. */\n' + css[:css.index('@supports (corner-shape: squircle)')]
    outputs = {'packages/web/field.js': ('site/assets/field.js', source, '完整 Canvas 效果；新增显式 dispose；保留原参数与绘制'),
               'packages/web/tokens.css': ('site/assets/style.css', css, '部分提取：原始明暗颜色、字体名与 spring CSS token；营销页布局未提取'),
               'packages/web/LICENSE': ('LICENSE', (BASE / 'LICENSE').read_text(encoding='utf-8'), '原样 GPL-3.0')}
    manifest = {}
    for target, (origin, content, status) in outputs.items():
        file = ROOT / target
        if args.check:
            if file.read_text(encoding='utf-8') != content:
                raise SystemExit(f'Web extraction drift: {target}')
        else:
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(content, encoding='utf-8')
        manifest['FlClash/' + origin] = {'target': target, 'source_commit': COMMIT,
            'status': status, 'modifications': changes if target.endswith('field.js') else ['select CSS token prefix' if target.endswith('.css') else 'none']}
    ledger = ROOT / 'docs/audit/web-extractions.json'
    if args.check:
        if json.loads(ledger.read_text(encoding='utf-8')) != json.loads(json.dumps(manifest)):
            raise SystemExit('Web extraction ledger drift')
    else:
        ledger.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(manifest)} web source records {"checked" if args.check else "extracted"}.')


if __name__ == '__main__':
    main()
