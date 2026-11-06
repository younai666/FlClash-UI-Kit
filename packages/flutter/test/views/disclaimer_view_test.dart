import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  Widget testHost({required Widget child, Locale locale = const Locale('zh')}) {
    return KitApp(
      locale: locale,
      home: child,
    );
  }

  group('DisclaimerView', () {
    testWidgets('renders all disclaimer terms in read-only mode', (tester) async {
      await tester.pumpWidget(testHost(child: const DisclaimerView()));
      await tester.pumpAndSettle();

      expect(find.text('免责声明'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      // Top intro card with gavel glyph
      expect(find.textContaining('在使用本软件前'), findsOneWidget);
      // Terms are listed with numbered badges
      expect(find.text('软件性质'), findsOneWidget);
      expect(find.text('使用说明'), findsOneWidget);
      expect(find.text('用户责任'), findsOneWidget);
      expect(find.text('第三方内容'), findsOneWidget);
      expect(find.text('无担保声明'), findsOneWidget);
      expect(find.text('责任限制'), findsOneWidget);
      expect(find.text('数据收集与隐私'), findsOneWidget);
      expect(find.text('开源协议'), findsOneWidget);
      expect(find.text('声明变更'), findsOneWidget);
      expect(find.text('与开源协议的关系'), findsOneWidget);
      // Numbers 1 through 10
      for (var i = 1; i <= 10; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('requireConsent shows consent action bar with exit and agree buttons', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testHost(child: const DisclaimerView(requireConsent: true)));
      await tester.pumpAndSettle();

      expect(find.text('退出'), findsOneWidget);
      expect(find.text('同意'), findsOneWidget);
    });

    testWidgets('agree button triggers restatement confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testHost(child: const DisclaimerView(requireConsent: true)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('同意'));
      await tester.pumpAndSettle();

      // Restatement dialog appears
      expect(find.text('复述声明'), findsOneWidget);
      expect(find.text('确认'), findsOneWidget);

      // Confirm button is initially disabled
      final confirmBtn = tester.widget<TextButton>(find.widgetWithText(TextButton, '确认'));
      expect(confirmBtn.onPressed, isNull);

      // Enter mismatched text -> error shown
      await tester.enterText(find.byType(TextField), '不匹配的文本');
      await tester.pump();
      expect(find.text('与声明内容不一致'), findsOneWidget);

      // Enter exact statement
      const statement = '本软件自身不提供任何代理服务器、节点、订阅、机场或网络接入服务，也不与任何此类服务的提供者存在合作、代理或担保关系。';
      await tester.enterText(find.byType(TextField), statement);
      await tester.pump();

      // Now confirm is enabled
      final enabledConfirm = tester.widget<TextButton>(find.widgetWithText(TextButton, '确认'));
      expect(enabledConfirm.onPressed, isNotNull);
    });
  });
}
