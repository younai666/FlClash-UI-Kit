import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_editor/flclash_ui_editor.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart' hide Mode;
import 'package:flclash_ui_showcase/editor_native.dart';

void main() {
  setUpAll(initializeEditor);
  testWidgets('keyboard gives the native editor space instead of its footer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      const KitApp(
        home: Scaffold(title: 'Editor', body: EditorDemo()),
      ),
    );
    // Let the already-initialized native Future notify this newly mounted host.
    await tester.runAsync(() async {});
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NativeCodeEditor), findsOneWidget);
    final footer = find.textContaining('真实调用：packages/editor');
    expect(footer, findsOneWidget);
    await tester.tap(find.text('查找 / 替换'));
    await tester.pump();
    expect(find.byType(FindPanel), findsOneWidget);
    final editorState = tester.state(find.byType(CodeForge));
    final search = tester.widget<FindPanel>(find.byType(FindPanel)).controller;
    expect(search.findInputFocusNode.hasFocus, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 350);
    await tester.pump();
    expect(footer, findsNothing);
    expect(find.text('查找 / 替换'), findsNothing);
    expect(tester.state(find.byType(CodeForge)), same(editorState));
    expect(search.findInputFocusNode.hasFocus, isTrue);
    expect(tester.getSize(find.byType(CodeForge)).height, greaterThan(80));
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pump();
    expect(footer, findsOneWidget);
    expect(tester.state(find.byType(CodeForge)), same(editorState));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
