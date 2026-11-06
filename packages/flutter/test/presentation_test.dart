import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  test('filter chips retain an absent selection and grouping stays host-owned', () {
    final changes = <RecordGrouping?>[];
    final controller = RecordFilterController<String>(
      facets: [RecordFacet(RecordFacetKind.network, (v) => [v], offered: true)],
      groupers: [RecordGrouper(RecordGrouping.host, (v) => v)],
      onGroupingChanged: changes.add,
    );
    addTearDown(controller.dispose);
    controller.offer(['tcp', 'udp']);
    controller.add(const RecordFilter(RecordFacetKind.network, 'tcp'));
    controller.offer(['udp']);
    expect(controller.options.value[RecordFacetKind.network], contains('tcp'));
    final tcp = controller.keywordsOf(pinned: true).value.singleWhere((v) => v.label == 'tcp');
    expect(tcp.selected, isTrue);
    tcp.onPressed!();
    expect(controller.isFiltering, isFalse);
    controller.setGrouping(RecordGrouping.host);
    expect(changes, [RecordGrouping.host]);
    expect(controller.groupsOf(['a', 'a', 'b'])!.first.items, ['a', 'a']);
  });

  testWidgets('unchanged host inputs retain the theme; pure black retains elevated sheets', (tester) async {
    late ThemeData theme;
    Widget home(String text) => Builder(builder: (context) { theme = Theme.of(context); return Text(text); });
    await tester.pumpWidget(KitApp(home: home('first')));
    final first = theme;
    final baseline = seededColorScheme(seedColor: const Color(0xFF007AFF), brightness: Brightness.light, style: ColorStyle.vivid);
    expect(theme.colorScheme.primary, baseline.primary);
    await tester.pumpWidget(KitApp(home: home('second')));
    expect(theme, same(first));
    await tester.pumpWidget(KitApp(themeMode: ThemeMode.dark, pureBlack: true, home: home('dark')));
    await tester.pumpAndSettle();
    expect(theme.colorScheme.surface, const Color(0xFF000000));
    expect(theme.elevatedColorScheme, isNotNull);
    expect(theme.elevatedColorScheme!.surface, isNot(theme.colorScheme.surface));
  });

  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('outbound status keeps masking, retry and control callbacks at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var toggles = 0;
      var retries = 0;
      Widget probe({bool hide = false, bool loading = false}) => KitApp(
        locale: const Locale('en'),
        home: Center(child: DashboardDensityScope(
          density: size.width < 600 ? DashboardDensity.mobile : DashboardDensity.standard,
          scale: 1,
          child: SizedBox(width: size.width < 600 ? 350 : 560, height: 248, child: CurrentOutboundCard(
            info: const OutboundInfo(ip: '203.0.113.8', countryCode: 'JP'),
            quality: const OutboundQuality(typeLabel: 'Hosting', levelLabel: 'Normal', organization: 'Example Network'),
            running: true, runTime: 150000, hideIp: hide, checking: loading,
            onToggle: () => toggles++, onRefresh: () => retries++,
          )),
        )),
      );
      await tester.pumpWidget(probe());
      await tester.tap(find.byType(RunningToggle));
      await tester.tap(find.byTooltip('Retry'));
      expect(toggles, 1);
      expect(retries, 1);
      expect(find.text('00:02:30'), findsOneWidget);
      await tester.pumpWidget(probe(hide: true, loading: true));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('203.0.113.8'), findsNothing);
      expect(find.text('*****'), findsOneWidget);
      await tester.tap(find.byTooltip('Retry'));
      expect(retries, 1, reason: 'a running probe cannot be retried');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
