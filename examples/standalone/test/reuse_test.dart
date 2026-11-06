import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:workspace_example/main.dart';

void main() {
  Future<void> finishRoute(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets(
    'custom pages, retained edits, appearance and custom action recording',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WorkspaceApp());
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(HomePage));
      final shell = HomeShellScope.read(context);
      await tester.enterText(find.byType(TextField), 'Retained draft');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Retained draft',
      );
      await tester.tap(find.text('Add note (0)'));
      await tester.pumpAndSettle();
      expect(find.text('Add note (1)'), findsOneWidget);
      shell.openPage('presets');
      await finishRoute(tester);
      expect(find.text('Writing layout'), findsOneWidget);
      shell.openPage('notes');
      await finishRoute(tester);
      expect(find.text('Retained draft'), findsOneWidget);
      shell.openPage('tools');
      await finishRoute(tester);
      await tester.tap(find.text('Hotkey management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create note'));
      await tester.pumpAndSettle();
      await simulateKeyDownEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await simulateKeyDownEvent(
        LogicalKeyboardKey.keyN,
        physicalKey: PhysicalKeyboardKey.keyN,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.keyN,
        physicalKey: PhysicalKeyboardKey.keyN,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(HotKeyScope.read(context).actions.single.action, 'create-note');
      expect(
        HotKeyScope.read(context).actions.single.key,
        PhysicalKeyboardKey.keyN.usbHidUsage,
      );
      Navigator.of(tester.element(find.byType(HotKeyView))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      ThemeScope.read(context)
          .updateThemeProps((p) => p.copyWith(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();
      expect(
        tester.widget<KitApp>(find.byType(KitApp)).themeMode,
        ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
