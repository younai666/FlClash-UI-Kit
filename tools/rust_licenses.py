"""Preserve full notices for the actual locked native editor dependency graph."""
import argparse
import json
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--metadata', type=Path, default=ROOT / '.local/cargo-metadata.json')
    args = parser.parse_args()
    metadata = json.loads(args.metadata.read_text(encoding='utf-8-sig'))
    lock = tomllib.loads((ROOT / 'packages/editor/vendor/rust_api/rust/Cargo.lock').read_text(encoding='utf-8'))
    expected = {(p['name'], p['version']) for p in lock['package'] if p.get('source')}
    actual = {(p['name'], p['version']) for p in metadata['packages'] if p.get('source')}
    if expected != actual:
        raise SystemExit('Metadata must cover the complete current Cargo.lock; regenerate without --no-deps.')
    inventory = []
    for package in sorted(metadata['packages'], key=lambda p: (p['name'], p['version'])):
        if not package.get('source'):
            continue
        path = Path(package['manifest_path']).parent
        candidates = [p for p in path.iterdir() if p.is_file() and p.name.upper().startswith(('LICENSE', 'COPYING', 'NOTICE', 'COPYRIGHT', 'UNLICENSE'))]
        if package.get('license_file'):
            file = path / package['license_file']
            if file.is_file() and file not in candidates:
                candidates.append(file)
        external = []
        # These published crate archives omit their workspace-root license.
        # Their own .cargo_vcs_info.json provides these exact source commits.
        if package['name'] in {'flutter_rust_bridge', 'flutter_rust_bridge_macros'}:
            candidates.append(ROOT / 'licenses/upstream/flutter-rust-bridge-MIT.txt')
            external.append('https://github.com/fzyzcjy/flutter_rust_bridge/blob/8631db91a90c699439c9ce2a1fb4164ae8661da9/LICENSE')
        if package['name'] == 'dart-sys':
            candidates += sorted((ROOT / 'licenses/upstream').glob('dart-sys-LICENSE*'))
            candidates.append(path / 'dart-sdk/LICENSE')
            external.append('https://github.com/dart-sys/dart-sys/tree/c9329430a5a8e3828cf59600babe7896326c7c44')
        if not candidates:
            raise SystemExit(f'Missing full Rust license: {package["name"]}')
        target = ROOT / 'licenses/rust' / package['name'] / package['version']
        target.mkdir(parents=True, exist_ok=True)
        copied = []
        for file in candidates:
            name = 'Dart-SDK-LICENSE' if file == path / 'dart-sdk/LICENSE' else file.name
            (target / name).write_bytes(file.read_bytes())
            copied.append((target / name).relative_to(ROOT).as_posix())
        vcs = path / '.cargo_vcs_info.json'
        inventory.append({'name': package['name'], 'version': package['version'],
            'license_expression': package.get('license'), 'license_file': package.get('license_file'),
            'repository': package.get('repository'), 'source': package['source'],
            'vcs': json.loads(vcs.read_text(encoding='utf-8')) if vcs.exists() else None,
            'external_license_sources': external, 'notices': copied})
    output = ROOT / 'licenses/rust/index.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(inventory, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(inventory)} Rust dependency notice records exactly match Cargo.lock.')


if __name__ == '__main__':
    main()
