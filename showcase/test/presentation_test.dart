import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_showcase/application.dart';

Widget host(Widget child) => KitApp(locale: const Locale('zh'), home: child);

void main() {
  setUp(() => WidgetController.hitTestWarningShouldBeFatal = true);
  testWidgets('list editor searches and confirms deletion without changing hidden items', (tester) async {
    await tester.pumpWidget(host(const ListEditorExample()));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'MA');
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    expect(find.byType(PrismReorderableListView), findsNothing);
    await tester.tap(find.text('Gamma'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final answer in ['保存', '放弃', '继续编辑']) {
    testWidgets('nested draft exit preserves $answer', (tester) async {
      await tester.pumpWidget(host(const Scaffold(title: 'Examples', body: ApplicationDemo())));
      await tester.tap(find.text('编辑未保存草稿'));
      await tester.pumpAndSettle();
      expect(find.byType(FormPage), findsOneWidget);
      expect(tester.getTopLeft(find.byType(FormRowTextField)).dy, greaterThan(tester.getBottomLeft(find.text('未保存草稿')).dy));
      await tester.enterText(find.descendant(of: find.byType(FormPage), matching: find.byType(TextField)), '修改后的标题');
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('是否保存更改？'), findsOneWidget);
      if (answer == '继续编辑') {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(TextButton, answer == '保存' ? '确认' : '取消')));
      }
      await tester.pumpAndSettle();
      expect(find.byType(FormPage), answer == '继续编辑' ? findsOneWidget : findsNothing);
      if (answer == '继续编辑') expect(find.text('修改后的标题'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('theme miniature switches the actual preview animation and destination', (tester) async {
    await tester.pumpWidget(host(const Scaffold(title: '主题预览', body: ThemePreviewDemo())));
    final screen = find.descendant(of: find.byType(ThemeLivePreview), matching: find.byType(MiniScreen));
    expect(tester.widget<MiniScreen>(screen).selected, 0);
    await tester.ensureVisible(screen);
    await tester.pumpAndSettle();
    final rect = tester.getRect(screen);
    await tester.tapAt(rect.bottomRight - const Offset(25, 25));
    await tester.pumpAndSettle();
    expect(tester.widget<MiniScreen>(screen).selected, 3);
    await tester.ensureVisible(find.text('淡入'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('淡入'));
    await tester.pumpAndSettle();
    expect(tester.widget<MiniScreen>(screen).tabAnimation, TabAnimation.fade);
    expect(tester.takeException(), isNull);
  });
}
