import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_showcase/main.dart';

// Running status/traffic intentionally keep animating. Advance complete route
// transitions without waiting for all tickers in the app to become idle.
Future<void> advance(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 900)]) {
    testWidgets('complete application navigation and live state at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ShowcaseApp());
      await advance(tester);
      expect(find.byType(DashboardView), findsOneWidget);
      if (size.width > 600) {
        await tester.tap(
          find.descendant(
            of: find.byType(OutboundModeBar),
            matching: find.text('全局'),
          ),
        );
        await advance(tester);
        expect(
          tester.widget<OutboundModeBar>(find.byType(OutboundModeBar)).mode,
          Mode.global,
        );
      }
      final context = tester.element(find.byType(HomePage));
      final shell = HomeShellScope.read(context);
      final profiles = ProfilesScope.read(context);
      final mobile = size.width <= 600;
      final nav = find.byType(mobile ? NavigationDock : NavigationSidebar);
      await tester.tap(find.descendant(of: nav, matching: find.text('配置')));
      expect(shell.pageLabel, 'profiles');
      await advance(tester);
      expect(find.byType(ProfilesView), findsOneWidget);
      await profiles.addCustomProfile('New workspace');
      await advance(tester);
      await tester.tap(find.text('New workspace'));
      await advance(tester);
      expect(
        profiles.profiles
            .firstWhere((p) => p.id == profiles.currentProfileId)
            .label,
        'New workspace',
      );
      shell.openPage('proxies');
      await advance(tester);
      expect(find.byType(ProxiesView), findsOneWidget);
      for (final (id, label, type) in [
        ('requests', '请求', RequestsView),
        ('dns', 'DNS', DnsQueriesView),
        ('logs', '日志', LogsView),
      ]) {
        if (mobile) {
          shell.openPage('tools');
          await advance(tester);
          await tester.tap(find.text(label));
        } else {
          shell.openPage(id);
        }
        await advance(tester);
        expect(find.byType(type), findsOneWidget);
        expect(tester.takeException(), isNull, reason: id);
        if (mobile) {
          Navigator.of(context).pop();
          await advance(tester);
        }
      }
      shell.openPage('tools');
      await advance(tester);
      await tester.ensureVisible(find.text('追加本地演示记录'));
      await tester.tap(find.text('追加本地演示记录'));
      await advance(tester);
      if (mobile) {
        await tester.ensureVisible(find.text('请求'));
        await tester.tap(find.text('请求'));
      } else {
        shell.openPage('requests');
      }
      await advance(tester);
      expect(find.textContaining('example-2.test'), findsWidgets);
      if (mobile) {
        Navigator.of(context).pop();
        await advance(tester);
      }
      shell.openPage('tools');
      await advance(tester);
      await tester.ensureVisible(find.text('主题'));
      await tester.tap(find.text('主题'));
      await advance(tester);
      expect(find.byType(ThemeView), findsOneWidget);
      final theme = ThemeScope.read(context);
      theme.updateThemeProps(
        (p) => p.copyWith(
          themeMode: ThemeMode.dark,
          pureBlack: true,
          fontFamily: 'Segoe UI',
        ),
      );
      await advance(tester);
      expect(
        tester.widget<KitApp>(find.byType(KitApp)).themeMode,
        ThemeMode.dark,
      );
      expect(
        Theme.of(tester.element(find.byType(ThemeView))).fontFamily,
        'Segoe UI',
      );
      Navigator.of(tester.element(find.byType(ThemeView))).pop();
      await advance(tester);
      shell.setLocale(const Locale('en'));
      await advance(tester);
      expect(
        find.descendant(of: nav, matching: find.text('Tools')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await advance(tester);
    });
  }
}
