"""Check delivery references, source coverage, provenance and runtime shader assets."""
import json
import hashlib
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

import audit

ROOT = Path(__file__).resolve().parents[1]


def main():
    records = json.loads((ROOT / 'docs/audit/source-index.json').read_text(encoding='utf-8'))
    if records != audit.census():
        raise SystemExit('Source census drift; review and regenerate the audit.')
    failures = []
    files = [p for p in [ROOT / 'README.md', ROOT / 'README_EN.md', ROOT / 'SKILL.md', ROOT / 'NOTICE.md', ROOT / 'HANDOFF.md', *(ROOT / 'docs').rglob('*.md'), *(ROOT / 'packages').glob('*/README.md')] if p.is_file()]
    for file in files:
        for target in re.findall(r'\]\(([^)]+)\)', file.read_text(encoding='utf-8')):
            if target.startswith(('https://', 'http://', '#', 'mailto:')):
                continue
            target = unquote(target.strip('<>').split('#')[0])
            if not (file.parent / target).exists():
                failures.append(f'{file.relative_to(ROOT)} -> {target}')
    manifests = [json.loads((ROOT / 'docs/audit' / name).read_text(encoding='utf-8')) for name in
                 ['extractions.json', 'editor-extractions.json', 'platform-extractions.json', 'web-extractions.json']]
    indexed = {r['repo'] + '/' + r['path']: r for r in records}
    for manifest in manifests:
        for key, item in manifest.items():
            if key not in indexed or item['source_commit'] != indexed[key]['commit']:
                failures.append(f'Unindexed extraction or commit mismatch: {key}')
            for target in [item['target'], *item.get('additional_targets', [])]:
                if not (ROOT / target).is_file():
                    failures.append(f'Missing extraction: {key} -> {target}')
    for shader in ['liquid_glass.frag', 'ink_sparkle.frag']:
        if not (ROOT / 'packages/flutter/vendor/prism_ui/shaders' / shader).is_file():
            failures.append(f'Missing runtime shader: {shader}')
    licenses = [*json.loads((ROOT / 'licenses/dependencies/index.json').read_text(encoding='utf-8')),
                *json.loads((ROOT / 'licenses/rust/index.json').read_text(encoding='utf-8'))]
    for package in licenses:
        for notice in package['notices']:
            if not (ROOT / notice).is_file():
                failures.append(f'Missing dependency license: {notice}')
    binaries = [p for p in (ROOT / 'packages/flutter/lib').rglob('*') if p.suffix.lower() in {'.ttf', '.otf', '.ttc', '.jpg', '.png', '.ico'}]
    if binaries:
        failures += [f'Review unapproved runtime asset: {p}' for p in binaries]
    for font in json.loads((ROOT / 'docs/audit/font-evidence.json').read_text(encoding='utf-8'))['fonts']:
        if hashlib.sha256((ROOT / font['upstream_asset']).read_bytes()).hexdigest() != font['sha256']:
            failures.append(f'Font license evidence no longer matches bytes: {font["upstream_asset"]}')
        if font.get('runtime_target'):
            if (ROOT / font['upstream_asset']).read_bytes() != (ROOT / font['runtime_target']).read_bytes():
                failures.append(f'Modified licensed font: {font["runtime_target"]}')
    # Asset declarations are a real runtime boundary: check fonts, shaders and
    # explicit files, excluding generated/test caches and network URLs.
    for spec in (ROOT / 'packages').glob('*/pubspec.yaml'):
        text = spec.read_text(encoding='utf-8')
        for target in re.findall(r'^\s+-\s+(?:asset:\s*)?(assets/\S+)', text, re.M):
            if not (spec.parent / target).exists():
                failures.append(f'Broken runtime asset declaration: {spec} -> {target}')
    # The core's declared Web-safe boundary must survive native integrations.
    # Native font enumeration and editor/OS services belong to optional packages.
    for file in (ROOT / 'packages/flutter/lib').rglob('*.dart'):
        for uri in re.findall(r"^\s*(?:import|export)\s+['\"]([^'\"]+)['\"]", file.read_text(encoding='utf-8'), re.M):
            if uri in {'dart:io', 'dart:ffi', 'dart:isolate'} or uri.startswith(('package:fl_clash/', 'package:flutter_riverpod/')):
                failures.append(f'Core portability contract violated: {file.relative_to(ROOT)} -> {uri}')
    if failures:
        raise SystemExit('\n'.join(failures))
    for script in ['extract.py', 'extract_editor.py', 'extract_platform.py', 'extract_web.py', 'bundled_notices.py']:
        subprocess.run([sys.executable, str(ROOT / 'tools' / script), '--check'], check=True)
    print(f'Checked {len(records)} source entries, {sum(map(len, manifests))} extraction records, {len(files)} document routes and {len(licenses)} dependency license records.')


if __name__ == '__main__':
    main()
