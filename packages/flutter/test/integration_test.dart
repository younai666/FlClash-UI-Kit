import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  testWidgets(
    'KitApp supplies both localizations and view scopes to every route',
    (tester) async {
      await tester.pumpWidget(
        KitApp(
          liquidGlass: null,
          locale: const Locale('zh'),
          home: Builder(
            builder: (context) => Scaffold(
              title: '宿主',
              body: Center(
                child: FilledButton(
                  onPressed: () => BaseNavigator.push(
                    context,
                    Builder(
                      builder: (context) => Scaffold(
                        title: '详情',
                        body: Text(
                          '${KitLocalizations.of(context).cancel} ${ViewScope.isMobileOf(context)}',
                        ),
                      ),
                    ),
                  ),
                  child: const Text('打开'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.textContaining('取消'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search shortcut retains the query and system back closes the layer',
    (tester) async {
      String query = '';
      await tester.pumpWidget(
        KitApp(
          liquidGlass: null,
          home: Scaffold(
            title: 'Search',
            searchState: AppBarSearchState(onSearch: (value) => query = value),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'needle');
      await tester.pump();
      expect(query, 'needle');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard editor removes and restores cards through the host callback',
    (tester) async {
      const first = DashboardItem(
        id: 1,
        title: '固定项',
        glyph: AppGlyphs.dashboard,
        card: Text('固定卡片'),
        removable: false,
      );
      const second = DashboardItem(
        id: 2,
        title: '可移除项',
        glyph: AppGlyphs.star,
        card: Text('可移除卡片'),
        index: 1,
      );
      var shown = [first, second];
      final keys = {1: GlobalKey(), 2: GlobalKey()};
      await tester.pumpWidget(
        KitApp(
          liquidGlass: null,
          locale: const Locale('zh'),
          home: StatefulBuilder(
            builder: (context, update) => Scaffold(
              title: '编辑',
              body: CustomScrollView(
                slivers: [
                  DashboardEditor(
                    available: const [first, second],
                    widgets: shown,
                    cardKeyOf: (item) => keys[item.id]!,
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    gap: 20,
                    onDone: () {},
                    onChanged: (items) => update(() => shown = [...items]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == '移除 可移除项',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(shown, [first]);
      expect(find.text('可移除卡片'), findsNothing);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == '添加 可移除项',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(shown, [first, second]);
      expect(find.text('可移除卡片'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'RunningToggle delegates state ownership and rejects disabled taps',
    (tester) async {
      int toggles = 0;
      Widget app(bool enabled) => KitApp(
        liquidGlass: null,
        home: Surface(
          child: Center(
            child: RunningToggle(
              size: 72,
              enabled: enabled,
              running: true,
              suspended: false,
              onToggle: () => toggles++,
            ),
          ),
        ),
      );
      await tester.pumpWidget(app(true));
      await tester.tap(find.byType(RunningToggle));
      await tester.pump(const Duration(milliseconds: 500));
      expect(toggles, 1);
      await tester.pumpWidget(app(false));
      await tester.tap(find.byType(RunningToggle));
      expect(toggles, 1);
    },
  );
}
