import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/reuse_test.dart' as reuse;

// WidgetTester.enterText needs the standard test text-input channel registered.
// This validates editable widgets in the native engine, not the Windows IME.
class _ReuseBinding extends IntegrationTestWidgetsFlutterBinding {
  @override
  bool get registerTestTextInput => true;
}

void main() {
  final binding = _ReuseBinding();
  reuse.main();
  tearDownAll(() {
    binding.reportData = {
      'scenario': 'custom pages, draft retention, custom shortcuts and theme',
      'coreOnly': true,
      'textInput': 'Flutter test text-input channel; OS IME not tested',
    };
  });
}
