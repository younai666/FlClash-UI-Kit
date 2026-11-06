"""Vendor the upstream standalone native UI plugins without altering them."""
import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'source/upstream/FlClash'
COMMIT = 'be84736605527034689c95bf27828ff27d912c5e'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    files = subprocess.check_output(['git', '-C', str(BASE), 'ls-files', 'plugins/window', 'plugins/tray', 'plugins/dynamic_color'], text=True).splitlines()
    ledger = {}
    for source in files:
        target = ROOT / 'packages/platform/vendor' / source.removeprefix('plugins/')
        data = (BASE / source).read_bytes()
        if args.check:
            if target.read_bytes() != data:
                raise SystemExit(f'Native plugin source drift: {target}')
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        ledger['FlClash/' + source] = {'source_commit': COMMIT, 'target': target.relative_to(ROOT).as_posix(),
            'status': '原样独立插件；各平台验证状态见 verification.md', 'modifications': []}
    source = 'lib/manager/window_manager.dart'
    original = (BASE / source).read_text(encoding='utf-8')
    begin, end = original.index('/// Maximize and fullscreen'), original.index('class WindowHeader extends')
    data = (f'// Derived from FlClash {source}, commit {COMMIT}. GPL-3.0.\n'
            '// Modified 2026-11-05: standalone imports; preserve events arriving during initial queries.\n'
            "import 'dart:async';\nimport 'package:flutter/foundation.dart';\n"
            "import 'package:flclash_ui_kit/flclash_ui_kit.dart' show WindowCaptionState;\n"
            "import 'package:window/window.dart';\n\n" + original[begin:end])
    changes = [
        ('  bool _disposed = false;', '  bool _disposed = false;\n  bool _maxEvent = false;\n  bool _fullScreenEvent = false;\n  bool _pinChanged = false;'),
        ('isPinned: states[0],', 'isPinned: _pinChanged ? value.isPinned : states[0],'),
        ('isMaximized: states[1],', 'isMaximized: _maxEvent ? value.isMaximized : states[1],'),
        ('isFullScreen: states[2],', 'isFullScreen: _fullScreenEvent ? value.isFullScreen : states[2],'),
        ('    super.onWindowMaximize();', '    super.onWindowMaximize();\n    _maxEvent = true;'),
        ('    super.onWindowUnmaximize();', '    super.onWindowUnmaximize();\n    _maxEvent = true;'),
        ('    super.onWindowEnterFullScreen();', '    super.onWindowEnterFullScreen();\n    _fullScreenEvent = true;'),
        ('    super.onWindowLeaveFullScreen();', '    super.onWindowLeaveFullScreen();\n    _fullScreenEvent = true;'),
        ('    _set(value.copyWith(isPinned: await desktopWindow.isAlwaysOnTop()));', '    final applied = await desktopWindow.isAlwaysOnTop();\n    _pinChanged = true;\n    _set(value.copyWith(isPinned: applied));'),
    ]
    for old, new in changes:
        if old not in data:
            raise SystemExit(f'Review caption adaptation: {old}')
        data = data.replace(old, new)
    target = ROOT / 'packages/platform/lib/src/window_caption.dart'
    if args.check:
        if target.read_text(encoding='utf-8') != data:
            raise SystemExit('Window caption controller drift')
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(data, encoding='utf-8')
    ledger['FlClash/' + source] = {'source_commit': COMMIT,
        'target': target.relative_to(ROOT).as_posix(),
        'source_lines': [original.count('\n', 0, begin) + 1, original.count('\n', 0, end)],
        'status': '部分提取：WindowCaptionController；应用持久化、退出策略仍在上游',
        'modifications': ['explicit Flutter/kit/window imports', *[{'from': old, 'to': new} for old, new in changes]]}
    for source in ['lint_options.yaml', 'LICENSE']:
        target = ROOT / 'packages/platform' / source
        if args.check:
            if target.read_bytes() != (BASE / source).read_bytes():
                raise SystemExit(f'Platform support file drift: {source}')
        else:
            target.write_bytes((BASE / source).read_bytes())
        ledger['FlClash/' + source] = {'source_commit': COMMIT,
            'target': target.relative_to(ROOT).as_posix(), 'status': '原样保留分析配置或 GPL 许可证', 'modifications': []}
    file = ROOT / 'docs/audit/platform-extractions.json'
    if args.check:
        if json.loads(file.read_text(encoding='utf-8')) != ledger:
            raise SystemExit('Platform ledger drift')
    else:
        file.write_text(json.dumps(ledger, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(ledger)} native UI plugin files {"checked" if args.check else "extracted"}.')


if __name__ == '__main__':
    main()
