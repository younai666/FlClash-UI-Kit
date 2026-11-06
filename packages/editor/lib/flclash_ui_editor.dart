/// Optional native-only editor. Initialize Rust before constructing controllers.
library;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rust_api/src/rust/frb_generated.dart';
export 'package:code_forge/code_forge.dart';
export 'src/native_code_editor.dart';
export 'src/completion_popup.dart';

Future<void>? _initialization;
Future<void> initializeEditor() {
  if (_initialization == null) {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['flclash_ui_editor (CodeForge and Rust dependencies)'],
        await rootBundle.loadString('packages/flclash_ui_editor/assets/licenses/rust-dependencies.txt'));
    });
    _initialization = RustLib.init();
  }
  return _initialization!;
}
