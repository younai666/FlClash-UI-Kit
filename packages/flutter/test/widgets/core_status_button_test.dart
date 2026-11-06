// Derived from chen08209/FlClash, test/widgets/core_status_button_test.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void main() {
  testWidgets(
    'holds connecting for the minimum duration after a fast restart',
    (tester) async {
      final status = ValueNotifier<CoreStatus>(CoreStatus.connected);
      addTearDown(status.dispose);

      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Center(child: CoreStatusButton(statusListenable: status)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      status.value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ActivityIndicator), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      status.value = CoreStatus.connected;
      await tester.pump();
      expect(find.byType(ActivityIndicator), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      await tester.pump(const Duration(milliseconds: 199));
      expect(find.byType(ActivityIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    },
  );

  testWidgets(
    'shows disconnected immediately when restart fails during the hold',
    (tester) async {
      final status = ValueNotifier<CoreStatus>(CoreStatus.connected);
      addTearDown(status.dispose);

      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Center(child: CoreStatusButton(statusListenable: status)),
          ),
        ),
      );
      await tester.pump();

      status.value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ActivityIndicator), findsOneWidget);

      status.value =
          CoreStatus.disconnected;
      await tester.pump();
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);
    },
  );

  testWidgets('labels the status on desktop and keeps it an icon on mobile', (
    tester,
  ) async {
    final status = ValueNotifier<CoreStatus>(CoreStatus.disconnected);
    addTearDown(status.dispose);
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;

    Future<void> pumpAt(Size size) async {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Center(child: CoreStatusButton(statusListenable: status)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pumpAt(const Size(1200, 800));
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    await pumpAt(const Size(400, 800));
    expect(find.text('Disconnected'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
    expect(find.byTooltip('Core status'), findsOneWidget);

    status.value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Connecting…'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsOneWidget);
  });

  testWidgets('does not clip a connecting state longer than the hold', (
    tester,
  ) async {
    final status = ValueNotifier<CoreStatus>(CoreStatus.connected);
    addTearDown(status.dispose);

    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(child: CoreStatusButton(statusListenable: status)),
        ),
      ),
    );
    await tester.pump();

    status.value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(ActivityIndicator), findsOneWidget);

    status.value = CoreStatus.connected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });

  testWidgets('holds connecting when restarting from disconnected', (
    tester,
  ) async {
    final status = ValueNotifier<CoreStatus>(CoreStatus.disconnected);
    addTearDown(status.dispose);

    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(child: CoreStatusButton(statusListenable: status)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    status.value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ActivityIndicator), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsNothing);

    status.value = CoreStatus.connected;
    await tester.pump();
    expect(find.byType(ActivityIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 199));
    expect(find.byType(ActivityIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });
}
