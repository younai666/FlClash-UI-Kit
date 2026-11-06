"""Copy notices from the actual resolved SDK/pub packages without downloading assets."""
import json
import re
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse
from urllib.request import url2pathname

ROOT = Path(__file__).resolve().parents[1]
CONSUMERS = ['showcase', 'packages/flutter', 'packages/editor', 'packages/platform']


def resolved_packages():
    grouped = {}
    for consumer in CONSUMERS:
        config_file = ROOT / consumer / '.dart_tool/package_config.json'
        config = json.loads(config_file.read_text(encoding='utf-8'))
        for package in config['packages']:
            uri = urljoin(config_file.as_uri(), package['rootUri'])
            path = Path(url2pathname(unquote(urlparse(uri).path)))
            grouped.setdefault((package['name'], path), []).append(consumer)
    return grouped


def main():
    output = ROOT / 'licenses/dependencies'
    output.mkdir(parents=True, exist_ok=True)
    inventory = []
    for (name, path), consumers in sorted(resolved_packages().items(), key=lambda item: (item[0][0], str(item[0][1]))):
        if name in {'flclash_ui_kit', 'flclash_ui_showcase', 'prism_ui', 'flclash_ui_editor', 'flclash_ui_platform', 'rust_api'}:
            continue
        spec = path / 'pubspec.yaml'
        text = spec.read_text(encoding='utf-8') if spec.exists() else ''
        version = re.search(r'^version:\s*[\'\"]?([^\s\'\"]+)', text, re.M)
        candidates = [p for p in path.iterdir() if p.is_file() and p.name.upper() in {'LICENSE', 'LICENSE.MD', 'LICENSE.TXT', 'COPYING', 'NOTICE', 'NOTICE.MD'}]
        if not candidates and name in {'flutter', 'flutter_localizations', 'flutter_test', 'sky_engine'}:
            for parent in path.parents:
                if (parent / 'LICENSE').is_file():
                    candidates = [parent / 'LICENSE']
                    break
        if not candidates and name == 'sky_engine':
            candidates = list(path.glob('LICENSE*'))
        if not candidates:
            raise SystemExit(f'Missing license for resolved package: {name}')
        package_version = version.group(1) if version else 'SDK'
        target = output / name / package_version
        target.mkdir(parents=True, exist_ok=True)
        for file in candidates:
            (target / file.name).write_bytes(file.read_bytes())
        source = f'https://pub.dev/packages/{name}/versions/{package_version}'
        if name in {'code_forge', 'window', 'tray', 'dynamic_color'}:
            source = f'https://github.com/chen08209/FlClash/tree/be84736605527034689c95bf27828ff27d912c5e/plugins/{name}'
        inventory.append({'name': name, 'version': package_version, 'used_by': consumers,
                          'source': 'Flutter SDK' if name in {'flutter', 'flutter_localizations', 'flutter_test', 'sky_engine'} else source,
                          'notices': [(target / p.name).relative_to(ROOT).as_posix() for p in candidates]})
    (output / 'index.json').write_text(json.dumps(inventory, indent=2) + '\n', encoding='utf-8')
    print(f'Copied {len(inventory)} package/version license records across {len(CONSUMERS)} consumers, including dev/SDK packages.')


if __name__ == '__main__':
    main()
