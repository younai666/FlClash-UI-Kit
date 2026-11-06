"""Build a fresh consumer against a detached copy of the core package only.

No upstream tree, optional native package or repository-relative asset is copied.
The retained temporary project and per-command logs are evidence for inspection.
"""
import argparse
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--flutter', default=shutil.which('flutter'))
    parser.add_argument('--windows', action='store_true', help='also build Windows release')
    parser.add_argument('--native-runtime', action='store_true', help='also run the Windows profile interaction test')
    args = parser.parse_args()
    if not args.flutter:
        parser.error('Flutter must be on PATH or supplied with --flutter')
    temporary = Path(tempfile.mkdtemp(prefix='flclash-ui-kit-stage4-')).resolve()
    output = ROOT / '.local'
    output.mkdir(exist_ok=True)
    (output / 'stage4-consumer-path.txt').write_text(str(temporary), encoding='utf-8')
    detached = temporary / 'ui-packages/flutter'
    shutil.copytree(ROOT / 'packages/flutter', detached,
                    ignore=shutil.ignore_patterns('.dart_tool', 'build', '.packages', '.flutter-plugins-dependencies'))
    project = temporary / 'workspace'
    commands = []

    def run(name, arguments, cwd):
        log = output / f'stage4-consumer-{name}.log'
        with log.open('w', encoding='utf-8') as stream:
            result = subprocess.run([args.flutter, *arguments], cwd=cwd,
                                    stdout=stream, stderr=subprocess.STDOUT)
        commands.append({'name': name, 'arguments': arguments, 'exit_code': result.returncode,
                         'log': str(log.relative_to(ROOT))})
        print(f'{name}: exit {result.returncode}', flush=True)
        if result.returncode:
            raise SystemExit(f'Failed; see {log}')

    run('create', ['create', '--empty', '--project-name', 'workspace_example',
                  '--platforms', 'web,windows' if args.windows else 'web', str(project)], temporary)
    fixture = ROOT / 'examples/standalone'
    for name in ['lib', 'test', 'integration_test', 'test_driver']:
        shutil.copytree(fixture / name, project / name, dirs_exist_ok=True)
    spec = (fixture / 'pubspec.yaml').read_text(encoding='utf-8')
    (project / 'pubspec.yaml').write_text(spec.replace('../../packages/flutter', '../ui-packages/flutter'), encoding='utf-8')
    for name, arguments in [
        ('pub', ['pub', 'get']), ('analyze', ['analyze', '--no-pub']),
        ('tests', ['test', '--no-pub', '--reporter', 'expanded']),
        ('web', ['build', 'web', '--release', '--no-pub']),
    ]:
        run(name, arguments, project)
    if args.native_runtime:
        run('native-runtime', ['drive', '--profile', '-d', 'windows', '--driver', 'test_driver/reuse.dart',
                              '--target', 'integration_test/reuse_test.dart',
                              '--dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false'], project)
    if args.windows:
        run('windows', ['build', 'windows', '--release'], project)
    report = {'project': str(project), 'dependency': str(detached),
              'upstream_or_optional_packages_copied': False, 'commands': commands}
    (output / 'stage4-consumer-results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'Fresh consumer retained at {project}')


if __name__ == '__main__':
    main()
