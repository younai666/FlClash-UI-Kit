"""Keep third-party notices inside independently copied runtime packages."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def block(path):
    return re.search(r'/\*(.*?)\*/', (ROOT / path).read_text(encoding='utf-8'), re.S).group(1).strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    sources = [
        ('prism_ui source notices', (ROOT / 'packages/flutter/vendor/prism_ui/NOTICE').read_text(encoding='utf-8')),
        ('material_new_shapes — Agbama Gifted', block('packages/flutter/vendor/prism_ui/lib/shapes/shapes.dart')),
        ('super_sliver_list — Matej Knopp, Superlist and contributors', block('packages/flutter/vendor/prism_ui/lib/sliver_list/super_sliver_list.dart')),
        ('navigator_resizable — Daichi Fujita', block('packages/flutter/vendor/prism_ui/lib/navigator_resizable.dart')),
        ('material_color_utilities — Copyright 2021 Google LLC', (ROOT / 'licenses/upstream/Apache-2.0.txt').read_text(encoding='utf-8')),
        ('ink_sparkle — Copyright 2013 The Flutter Authors; BSD-3-Clause', (ROOT / 'licenses/dependencies/flutter/SDK/LICENSE').read_text(encoding='utf-8')),
        ('Dart QR — Copyright 2014 the Dart QR project authors', block('packages/flutter/lib/src/ui/qr_matrix.dart')),
        ('JetBrains Mono 2.304 — Copyright 2020 The JetBrains Mono Project Authors', (ROOT / 'packages/flutter/assets/fonts/JetBrainsMono-OFL.txt').read_text(encoding='utf-8')),
        ('Service icon origin and trademark notice', (ROOT / 'packages/flutter/assets/images/services/LICENSE.md').read_text(encoding='utf-8')),
        ('Simple Icons 13.0.0 — CC0 1.0 Universal', (ROOT / 'licenses/upstream/simple-icons-CC0-1.0.md').read_text(encoding='utf-8')),
    ]
    text = 'FlClash UI Kit — retained third-party notices\n\n'
    text += '\n\n'.join(title + '\n' + '=' * 72 + '\n' + content.strip() for title, content in sources) + '\n'
    outputs = {ROOT / 'packages/flutter/assets/licenses/third-party.txt': text}
    rust = json.loads((ROOT / 'licenses/rust/index.json').read_text(encoding='utf-8'))
    sections = []
    for package in rust:
        title = f'{package["name"]} {package["version"]} — {package["license_expression"] or "see license file"}\n{package["repository"] or package["source"]}'
        texts = [(ROOT / file).read_text(encoding='utf-8') for file in package['notices']]
        sections.append(title + '\n' + '=' * 72 + '\n' + '\n\n'.join(texts))
    editor_notice = (ROOT / 'packages/editor/vendor/code_forge/LICENSE').read_text(encoding='utf-8')
    outputs[ROOT / 'packages/editor/assets/licenses/rust-dependencies.txt'] = (
        'CodeForge and native editor dependency notices\n\n' + editor_notice + '\n\n' + '\n\n'.join(sections) + '\n')
    for file, content in outputs.items():
        if args.check:
            if file.read_text(encoding='utf-8') != content:
                raise SystemExit(f'Bundled notice drift: {file.relative_to(ROOT)}')
        else:
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(content, encoding='utf-8')
    print(f'{len(outputs)} complete runtime notice assets {"checked" if args.check else "generated"}.')


if __name__ == '__main__':
    main()
