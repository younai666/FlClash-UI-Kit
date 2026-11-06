import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_showcase/demos.dart';
import 'package:flclash_ui_showcase/section.dart';
import 'package:flclash_ui_showcase/main.dart';

void main() {
  testWidgets('mobile home keeps content below its bar and opens live controls', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('原生组件 · 可交互动效 · 可检索源码')).dy,
        greaterThan(tester.getBottomLeft(find.text('FlClash UI Kit')).dy));
    await tester.tap(find.text('基础控件'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pump();
    expect(find.text('已触发 1 次'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in const [Size(390, 844), Size(1280, 900)]) {
    testWidgets('all live demo pages render and scroll at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final demo in demos) {
        await tester.pumpWidget(
          KitApp(
            key: ValueKey(demo.id),
            liquidGlass: null,
            locale: const Locale('zh'),
            home: DemoPage(demo: demo),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(
          tester.takeException(),
          isNull,
          reason: '${demo.id} initial at $size',
        );
        if (find.byType(DemoList).evaluate().isNotEmpty) {
          final list = find
              .descendant(
                of: find.byType(DemoList),
                matching: find.byType(ListView),
              )
              .first;
          for (var i = 0; i < 14; i++) {
            await tester.drag(list, const Offset(0, -650));
            await tester.pump(const Duration(milliseconds: 350));
            expect(
              tester.takeException(),
              isNull,
              reason: '${demo.id} scroll $i at $size',
            );
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }
}
