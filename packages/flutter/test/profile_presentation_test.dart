import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  for (final density in [DashboardDensity.mobile, DashboardDensity.compact, DashboardDensity.standard]) {
    testWidgets('profile quota and actions retain the $density layout', (tester) async {
      var opens = 0, syncs = 0, switches = 0;
      await tester.pumpWidget(KitApp(locale: const Locale('en'), home: Center(child: DashboardDensityScope(
        density: density, scale: 1, child: SizedBox(width: 350, height: 240, child: ProfilesCard(
          profile: const DashboardProfile(label: 'Example', subscriptionInfo: SubscriptionInfo(download: 27, total: 100)),
          switchable: true, onOpen: () => opens++, onSync: () => syncs++, onSwitch: () => switches++))))));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('27%', findRichText: true), findsOneWidget);
      await tester.tap(find.byTooltip('Update'));
      await tester.tap(find.byTooltip('Switch profile'));
      if (density.isDesktop) {
        await tester.tap(find.byTooltip('Profile details'));
      } else {
        await tester.tap(find.text('Example'));
      }
      expect((opens, syncs, switches), (1, 1, 1));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('profile detail uses its own bar clearance and host slivers', (tester) async {
    var previews = 0;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: ProfileDetailSheet(
      profile: const DashboardProfile(label: 'Profile detail'), stats: (groups: 4, proxies: 32, rules: 1048, providers: 2),
      onPreview: () => previews++, providerSlivers: const [SliverToBoxAdapter(child: Text('Host resources'))])));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(ProfileStatsGrid)).dy,
      greaterThan(tester.getBottomLeft(find.text('Profile detail')).dy));
    await tester.tap(find.byTooltip('Runtime configuration'));
    expect(previews, 1);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('Host resources'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
