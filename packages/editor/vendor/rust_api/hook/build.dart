// Derived from FlClash; modified 2026-11-05: no QuickJS Android bindgen. GPL-3.0.
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
