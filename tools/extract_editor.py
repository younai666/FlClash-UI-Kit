"""Reproduce the optional editor's unchanged UI and editor-only Rust inputs.

Regenerate the FRB glue after applying this recipe; never copy the application's
IPC/global-hotkey/script bridge into a standalone editor.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'source/upstream/FlClash'
TARGET = ROOT / 'packages/editor'
COMMIT = 'be84736605527034689c95bf27828ff27d912c5e'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest = {}

    def save(source, target, content=None, note='Unmodified upstream file'):
        original = BASE / source
        payload = original.read_bytes() if content is None else content.encode('utf-8')
        destination = TARGET / target
        if args.check:
            if destination.read_bytes() != payload:
                raise SystemExit(f'Editor extraction drift: {destination}')
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(payload)
        key = 'FlClash/' + source
        record = {
            'source_commit': COMMIT, 'target': destination.relative_to(ROOT).as_posix(),
            'status': '已提取；原生构建/运行状态见 verification.md', 'modification': note,
        }
        if key in manifest:
            manifest[key].setdefault('additional_targets', []).append(record['target'])
        else:
            manifest[key] = record

    forge = BASE / 'plugins/code_forge'
    for file in [*forge.glob('lib/**/*.dart'), forge / 'pubspec.yaml', forge / 'LICENSE', forge / 'analysis_options.yaml']:
        save(file.relative_to(BASE).as_posix(), 'vendor/code_forge/' + file.relative_to(forge).as_posix())
    save('lint_options.yaml', 'lint_options.yaml')
    rust = BASE / 'plugins/rust_api'
    for name in ['lib/editor.dart', 'rust/src/api/editor.rs', 'rust/src/api/init.rs']:
        save('plugins/rust_api/' + name, 'vendor/rust_api/' + name)
    for file in (rust / 'rust/src/editor').glob('*.rs'):
        name = file.relative_to(rust).as_posix()
        content = None
        if file.name == 'mod.rs':
            content = file.read_text(encoding='utf-8').replace('plugins/code_forge/LICENSE', '../code_forge/LICENSE')
        save('plugins/rust_api/' + name, 'vendor/rust_api/' + name, content,
             'MIT notice path adjusted' if content else 'Unmodified upstream editor implementation')
    save('plugins/rust_api/pubspec.yaml', 'vendor/rust_api/pubspec.yaml', '''# Modified 2026-11-05: editor-only native asset package; GPL-3.0.
name: rust_api
description: FlClash editor-only Rust bridge. No IPC, scripts or global hotkeys.
version: 0.0.1
publish_to: none
environment:
  sdk: '>=3.13.2 <4.0.0'
  flutter: '>=3.47.2'
dependencies:
  flutter:
    sdk: flutter
  code_assets: ^1.2.1
  flutter_rust_bridge: 2.13.0
  flutter_rust_bridge_hooks: 2.13.0
''', 'Application services and unrelated dev dependencies removed')
    save('plugins/rust_api/rust/Cargo.toml', 'vendor/rust_api/rust/Cargo.toml', '''# Modified 2026-11-05: retain only the document backend; GPL-3.0 with retained MIT modules.
[package]
name = "rust_api"
version = "0.1.0"
edition = "2021"
license = "GPL-3.0-only"
[lib]
name = "rust_api"
crate-type = ["cdylib", "staticlib"]
[dependencies]
flutter_rust_bridge = "=2.13.0"
ropey = { version = "1.6.1", default-features = false, features = ["simd"] }
[lints.rust]
unexpected_cfgs = { level = "warn", check-cfg = ['cfg(frb_expand)'] }
''', 'Remove QuickJS, charset, IPC, global hotkeys and platform service dependencies')
    save('plugins/rust_api/rust/rust-toolchain.toml', 'vendor/rust_api/rust/rust-toolchain.toml', '''# Modified 2026-11-05: exact upstream compiler and target declarations; minimal profile.
[toolchain]
channel = "1.99.0"
profile = "minimal"
targets = ["aarch64-apple-darwin", "x86_64-apple-darwin", "aarch64-linux-android", "armv7-linux-androideabi", "x86_64-linux-android", "aarch64-pc-windows-msvc", "x86_64-pc-windows-msvc", "aarch64-unknown-linux-gnu", "x86_64-unknown-linux-gnu"]
''', 'Keep exact upstream compiler and targets required by Native Assets; minimal profile')
    save('plugins/rust_api/rust/src/lib.rs', 'vendor/rust_api/rust/src/lib.rs', '''// Modified 2026-11-05: editor-only modules, GPL-3.0.
pub mod api;
mod editor;
mod frb_generated;
''', 'Editor-only crate exports')
    save('plugins/rust_api/rust/src/api/mod.rs', 'vendor/rust_api/rust/src/api/mod.rs', '''// Modified 2026-11-05: no service entrypoints, GPL-3.0.
pub mod editor;
pub mod init;
''', 'Only document and utility initialization APIs')
    save('plugins/rust_api/hook/build.dart', 'vendor/rust_api/hook/build.dart', '''// Derived from FlClash; modified 2026-11-05: no QuickJS Android bindgen. GPL-3.0.
import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';
import 'dart:io';
void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.userDefines['build_assets'] == false) return;
    await FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'rust',
      extraCargoBuildArgs: ['--locked'],
      extraCargoEnvironmentVariables: {
        for (final key in ['CARGO_HOME', 'RUSTUP_HOME', 'RUSTUP_TOOLCHAIN'])
          if (Platform.environment[key] case final value?) key: value,
      },
    ).run(input: input, output: output);
  });
}
''', 'Original Native Assets integration without unrelated bindgen environment')
    save('plugins/rust_api/flutter_rust_bridge.yaml', 'vendor/rust_api/flutter_rust_bridge.yaml', '''rust_input: crate::api
rust_root: rust/
dart_output: lib/src/rust
''')
    save('LICENSE', 'vendor/rust_api/LICENSE')
    save('LICENSE', 'LICENSE')
    save('plugins/code_forge/LICENSE', 'vendor/rust_api/MIT-code-forge.txt')

    popup = (BASE / 'lib/features/editor/completion_popup.dart').read_text(encoding='utf-8')
    popup = popup.replace('package:fl_clash/ui/ui.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart')
    save('lib/features/editor/completion_popup.dart', 'lib/src/completion_popup.dart',
         '// Modified 2026-11-05: independent UI import; GPL-3.0.\n' + popup, 'UI import only')

    source = (BASE / 'lib/pages/editor.dart').read_text(encoding='utf-8')
    code = source[source.index('class _CodeEditor '):]
    completion = code[code.index('  late CodeForgeCompletionSource? _completionSource ='):code.index('  late final ScrollController _verticalController;')]
    update = code[code.index('    if (oldWidget.language !='):code.index('  @override\n  void dispose()')]
    replacements = [
        ('_CodeEditorState', '_NativeCodeEditorState'), ('_CodeEditor', 'NativeCodeEditor'),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('const NativeCodeEditor({', 'const NativeCodeEditor({\n    super.key,\n    this.fontSize = 14,\n    this.lineWrap = false,\n    this.topInset,\n    this.completionSource,'),
        ('required this.schema,', ''), ('  final EditorSchema schema;', '  final double fontSize;\n  final bool lineWrap;\n  /// Null retains upstream floating-bar clearance; use zero in an inline host.\n  final double? topInset;\n  final CodeForgeCompletionSource? completionSource;'),
        (completion, '  CodeForgeCompletionSource? get _completionSource => widget.completionSource;\n'),
        (update, '    if (oldWidget.language != widget.language) _colorScheme = null;\n  }\n\n'),
        ('BuildContext context, EditorFontSize fontSize', 'BuildContext context, double fontSize'),
        ('fontSize.value', 'fontSize'),
        ('ref.watch(appSettingProvider.select((state) => state.editorFontSize))', 'widget.fontSize'),
        ('final lineWrap = ref.watch(\n      appSettingProvider.select((state) => state.editorLineWrap),\n    );', 'final lineWrap = widget.lineWrap;'),
        ('dialogs.showBanner(', 'BannerHost.maybeOf(context)?.show('),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('system.isDesktop', '(defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux)'),
        ('Language', 'EditorLanguage'),
        ('_findActive ? _findRowGap : context.appBarInset', '_findActive ? _findRowGap : (widget.topInset ?? context.appBarInset)'),
        ('topInset: context.appBarInset,', 'topInset: widget.topInset ?? context.appBarInset,'),
        ('''          if (_showReplace)
            Row(
              spacing: 8,
              children: [
                Expanded(child: _buildReplaceInput(context)),
                replaceActions,
              ],
            ),''', '''          if (_showReplace) ...[
            _buildReplaceInput(context),
            Align(alignment: AlignmentDirectional.centerEnd, child: replaceActions),
          ],'''),
    ]
    for old, new in replacements:
        if old not in code: raise SystemExit(f'Editor adaptation no longer matches: {old}')
        code = code.replace(old, new)
    imports = '''// Extracted from FlClash lib/pages/editor.dart:661-1377,
// be84736605527034689c95bf27828ff27d912c5e; modified 2026-11-05.
// GPL-3.0: explicit font/wrap/language/completion inputs; original renderer,
// find panel, touch selection, context menu and caret anchoring retained.
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:code_forge/code_forge.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'completion_popup.dart';
enum EditorLanguage { yaml, javaScript, json, ini, xml, text }
'''
    save('lib/pages/editor.dart', 'lib/src/native_code_editor.dart', imports + code,
         'Partial: complete editor surface/find panel; app file workflow remains upstream')
    output = ROOT / 'docs/audit/editor-extractions.json'
    if args.check:
        if json.loads(output.read_text(encoding='utf-8')) != json.loads(json.dumps(manifest)):
            raise SystemExit('Editor extraction ledger drift')
    else:
        output.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(manifest)} editor source records {"checked" if args.check else "extracted"}.')


if __name__ == '__main__':
    main()
