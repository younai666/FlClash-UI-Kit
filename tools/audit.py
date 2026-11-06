"""Inventory pinned upstream trees, imports and source-level UI evidence.

This is a reproducible census, not a claim of manual or runtime verification.
"""
import argparse
import collections
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TREES = {
    'FlClash': ROOT / 'source/upstream/FlClash',
    'prism_ui': ROOT / 'source/upstream/prism_ui',
}
EVIDENCE = {
    'motion': r'AnimationController|SpringDescription|SpringSimulation|Duration\(|Curves\.|Cubic\(|Tween[<(]|TickerProvider|Simulation|animateTo|animateWith|requestAnimationFrame|@keyframes|animation[-:]|transition[-:]|setInterval\(',
    'rendering': r'CustomPainter|RenderBox|RenderProxyBox|RenderSliver|ImageFilter|FragmentProgram|FragmentShader|BackdropFilter|saveLayer|drawPath|drawRSuperellipse|addRSuperellipse|getContext\(|gl_Position|createRadialGradient|filter:|backdrop-filter',
    'interaction': r'GestureDetector|RawGestureDetector|Listener\(|MouseRegion|Shortcuts\(|LogicalKeyboardKey|FocusNode|FocusScope|FocusTraversal|DragGesture|onPan|onTap|onHover|onKeyEvent|HapticFeedback|addEventListener\(|onPointer|pointerdown|touchstart|keydown|WM_NCHITTEST|WM_NC|WM_MOUSE|GDK_BUTTON|mouseDown|mouseUp|scrollWheel|NSTrackingArea|onTouchEvent|onKeyDown|onBackInvoked|OnBackPressed|MotionEvent',
    'platform': r'TargetPlatform|Platform\.|kIsWeb|isMobile|isDesktop|viewInsets|MediaQuery|LayoutBuilder|WindowEffect|NSVisualEffect|DwmSetWindowAttribute',
    'lifecycle': r'initState\(|dispose\(|didUpdateWidget\(|didChangeDependencies\(|WidgetsBindingObserver|AppLifecycleState|RouteObserver|PageActivityScope|RouteMotionHold',
}
EVIDENCE['rendering'] += r'|DwmSetWindowAttribute|SetWindowCompositionAttribute|NSVisualEffectView|NSGlassEffectView|NSAppearance|gtk_widget|gtk_window|WindowInsetsController|SYSTEM_UI_FLAG|setStatusBarColor'
EVIDENCE['motion'] += r'|CAAnimation|CATransaction|animateWithDuration|animateWithSpring'
EVIDENCE['lifecycle'] += r'|viewDidLoad|viewDidAppear|windowDid|onCreate\(|onResume\(|onPause\(|onDestroy\(|onAttachedToEngine|onDetachedFromEngine|NSWindowDelegate'


def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args], text=True, encoding='utf-8').strip()


def category(repo, path):
    if path.startswith('lib/') and repo == 'prism_ui':
        return 'design-system'
    if path.startswith(('test/', 'integration_test/')) or '/test/' in path:
        return 'test'
    if path.startswith(('assets/', 'shaders/', 'arb/')):
        return 'asset'
    if path.startswith('assets_source/'):
        return 'asset-source'
    if path.startswith('site/'):
        return 'website'
    if path.startswith('example/'):
        return 'example'
    if path.startswith('lib/'):
        section = path.split('/')[1]
        return {
            'pages': 'page', 'views': 'page', 'features': 'feature',
            'ui': 'app-ui', 'widgets': 'app-widget', 'l10n': 'localization',
            'providers': 'state', 'manager': 'lifecycle', 'common': 'utility',
            'models': 'model', 'database': 'data', 'core': 'core',
        }.get(section, 'entrypoint')
    if path.startswith('plugins/code_forge/'):
        return 'editor'
    if path.startswith('plugins/rust_api/') and 'editor' in path:
        return 'native-editor'
    if path.startswith(('plugins/window/', 'plugins/tray/', 'plugins/dynamic_color/')):
        return 'native-ui'
    if path.startswith('plugins/'):
        return 'native-bridge'
    if path.startswith(('android/', 'windows/', 'macos/', 'linux/')):
        return 'platform-host'
    if path.startswith(('doc/', 'docs/', '.agents/', '.github/', '.claude/', '.codex/', '.gemini/')) or path.endswith('.md'):
        return 'documentation-config'
    if path.startswith('core/'):
        return 'core'
    return 'build-support'


def census():
    records = []
    for repo, base in TREES.items():
        commit = git(base, 'rev-parse', 'HEAD')
        for path in git(base, 'ls-files').splitlines():
            file = base / path
            rec = {'repo': repo, 'commit': commit, 'path': path, 'category': category(repo, path)}
            if file.is_dir():
                rec.update(kind='gitlink', target_commit=git(file, 'rev-parse', 'HEAD'), lines=0)
                records.append(rec)
                continue
            data = file.read_bytes()
            rec['bytes'] = len(data)
            try:
                content = data.decode('utf-8')
                if '\0' in content:
                    raise ValueError('binary')
            except (UnicodeError, ValueError):
                rec.update(kind='binary', lines=0)
                records.append(rec)
                continue
            lines = content.splitlines()
            rec.update(kind='text', lines=len(lines))
            rec['symbols'] = [{'name': m.group(2), 'kind': m.group(1), 'line': content.count('\n', 0, m.start()) + 1}
                              for m in re.finditer(r'^(?:(?:abstract|sealed|base|final|interface) )*(class|mixin|enum|extension|typedef)\s+(\w+)', content, re.M)]
            rec['imports'] = re.findall(r"^(?:import|export|part)\s+['\"]([^'\"]+)['\"]", content, re.M)
            if path.endswith(('.js', '.ts', '.html', '.css')):
                rec['imports'] += re.findall(r"(?:from\s+|import\s*|(?:src|href)=)[\"']([^\"']+)[\"']", content)
                rec['symbols'] += [{'name': m.group(1), 'kind': 'function', 'line': content.count('\n', 0, m.start()) + 1}
                                   for m in re.finditer(r'\bfunction\s+(\w+)\s*\(', content)]
            if path.endswith(('.cc', '.cpp', '.h', '.hpp', '.m', '.mm')):
                rec['imports'] += re.findall(r'^\s*#(?:include|import)\s*[<\"]([^>\"]+)[>\"]', content, re.M)
            if path.endswith(('.swift', '.kt', '.java')):
                rec['imports'] += re.findall(r'^\s*import\s+([\w.*]+)', content, re.M)
            rec['global_dependencies'] = sorted(set(re.findall(r'globalThis\.(FlClash\w+)', content)))
            rec['evidence'] = {key: [{'line': i + 1, 'code': line.strip()} for i, line in enumerate(lines) if re.search(pattern, line)]
                               for key, pattern in EVIDENCE.items()}
            rec['references'] = sorted(set(re.findall(r"['\"]((?:assets|shaders|packages)/[^'\"]+)['\"]", content)))
            rec['license_lines'] = [{'line': i + 1, 'text': line.strip()} for i, line in enumerate(lines)
                                    if re.search(r'Copyright|SPDX|Licensed under|MIT License|Apache License|BSD.*License', line, re.I)]
            records.append(rec)
    locations = {(r['repo'], r['path']): r for r in records}
    for r in records:
        r['resolved_imports'] = []
        r['callers'] = []
    for r in records:
        for ref in r.get('imports', []):
            if ref.startswith(('dart:', 'package:flutter', 'http:', 'https:', 'data:', '#')):
                continue
            if ref.startswith('package:'):
                package, _, tail = ref[8:].partition('/')
                repo, prefix = {
                    'fl_clash': ('FlClash', 'lib/'), 'prism_ui': ('prism_ui', 'lib/'),
                    'code_forge': ('FlClash', 'plugins/code_forge/lib/'),
                }.get(package, ('FlClash', f'plugins/{package}/lib/'))
                target = prefix + tail
            else:
                repo = r['repo']
                resolved = (TREES[repo] / r['path']).parent.joinpath(ref.split('#')[0]).resolve()
                if not resolved.is_relative_to(TREES[repo]):
                    continue
                target = resolved.relative_to(TREES[repo]).as_posix()
            if (repo, target) in locations:
                r['resolved_imports'].append(repo + '/' + target)
                locations[(repo, target)]['callers'].append(r['repo'] + '/' + r['path'])
    return records


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    records = census()
    output = ROOT / 'docs/audit/source-index.json'
    if args.write:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    if args.check:
        previous = json.loads(output.read_text(encoding='utf-8'))
        if previous != records:
            raise SystemExit('Upstream census changed: review the source changes, then regenerate with --write.')
    counts = collections.Counter((r['repo'], r['category']) for r in records)
    print(json.dumps({'files': len(records), 'categories': {'/'.join(k): v for k, v in counts.items()},
                      'unreadable_files': 0, 'unresolved_review': 'See extraction-matrix.md; census does not imply extraction.'}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
