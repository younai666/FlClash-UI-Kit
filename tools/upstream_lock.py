"""Record complete Git trees and every recursive submodule revision."""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args], text=True, encoding='utf-8').strip()


def main():
    sources = []
    for relative, repo in [('FlClash', 'FlClash'), ('prism_ui', 'prism_ui'), ('FlClash/core/Clash.Meta', 'Clash.Meta'), ('FlClash/plugins/prism_ui', 'prism_ui')]:
        path = ROOT / 'source/upstream' / relative
        files = git(path, 'ls-files').splitlines()
        source = {'path': 'source/upstream/' + relative,
                  'repository': f'https://github.com/chen08209/{repo}',
                  'commit': git(path, 'rev-parse', 'HEAD'), 'tracked_entries': len(files),
                  'shallow': git(path, 'rev-parse', '--is-shallow-repository') == 'true',
                  'gitlinks': git(path, 'submodule', 'status', '--recursive').splitlines()}
        if repo == 'Clash.Meta':
            source['scope'] = 'Proxy backend, no HTML/CSS/JS/TS/Dart frontend; Meta.png and docs/logo.png are upstream brand reference only.'
            source['files'] = files
        if relative == 'FlClash/plugins/prism_ui':
            source['same_tree_as'] = 'source/upstream/prism_ui'
        sources.append(source)
    (ROOT / 'source/upstream-lock.json').write_text(json.dumps({'date': '2026-11-05', 'sources': sources}, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Locked {len(sources)} repositories/submodules, all complete history: {all(not s["shallow"] for s in sources)}')


if __name__ == '__main__':
    main()
