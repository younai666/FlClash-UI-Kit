import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart' hide Mode;
import 'package:flclash_ui_editor/flclash_ui_editor.dart';

void main() {
  setUpAll(initializeEditor);
  testWidgets('the public native editor edits, finds and releases its host controllers', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final code = CodeForgeController()..text = 'name: FlClash\nvalue: 42\n';
    final search = FindController(code);
    final undo = UndoRedoController();
    await tester.pumpWidget(KitApp(home: Scaffold(title: 'Editor', body: NativeCodeEditor(
      controller: code, findController: search, undoController: undo,
      readOnly: false, language: EditorLanguage.yaml, topInset: 0,
    ))));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.widget<CodeForge>(find.byType(CodeForge)).innerPadding!.top, 0);
    code.selection = const TextSelection.collapsed(offset: 0);
    code.insertAtCurrentCursor('# editable\n');
    await tester.pump();
    expect(code.text, startsWith('# editable\n'));
    expect(undo.canUndo, isTrue);
    undo.undo();
    await tester.pump();
    expect(code.text, startsWith('name: FlClash'));
    search.show(replace: true);
    search.findInputController.text = 'FlClash';
    await tester.pump(const Duration(milliseconds: 350));
    expect(search.matchCount, 1);
    expect(find.byType(FindPanel), findsOneWidget);
    expect(tester.widget<FindPanel>(find.byType(FindPanel)).topInset, 0);
    search.replaceInputController.text = 'Reusable';
    search.replaceAll();
    await tester.pump();
    expect(code.text, contains('name: Reusable'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    search.dispose();
    code.dispose();
    undo.dispose();
  });
}
