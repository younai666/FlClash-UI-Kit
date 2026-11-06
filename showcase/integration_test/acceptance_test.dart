import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_showcase/main.dart';
import 'package:flclash_ui_platform/flclash_ui_platform.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native application routes, interactions and rendered frames', (
    tester,
  ) async {
    final boundaryKey = GlobalKey();
    if ([
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ].contains(defaultTargetPlatform)) {
      await desktopWindow.ensureInitialized();
      await desktopWindow.setSize(const Size(1280, 900));
    }
    final captures = <Map<String, String>>[];
    binding.reportData = {
      'platform': defaultTargetPlatform.name,
      'captures': captures,
      'completed': false,
      'captureMethod': 'Flutter engine RenderRepaintBoundary.toImage; excludes OS window frame',
      'inputMethod': 'WidgetTester pointers and host controller calls in a real native engine',
      'performanceMethod':
          'engine FrameTiming callback; no VM/DDS or GC sampling',
    };
    Future<void> advance() async {
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
    }

    Future<void> capture(String name) async {
      await advance();
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final frame = await boundary.toImage(
        pixelRatio: tester.view.devicePixelRatio,
      );
      final png = await frame.toByteData(format: ui.ImageByteFormat.png);
      captures.add({
        'name': name,
        'png': base64Encode(png!.buffer.asUint8List()),
      });
      frame.dispose();
    }

    await tester.pumpWidget(
      RepaintBoundary(key: boundaryKey, child: const ShowcaseApp()),
    );
    await advance();
    final context = tester.element(find.byType(HomePage));
    final shell = HomeShellScope.read(context);
    final theme = ThemeScope.read(context);
    theme.updateThemeProps(
      (p) => p.copyWith(themeMode: ThemeMode.dark, pureBlack: true),
    );
    await advance();
    expect(find.byType(DashboardView), findsOneWidget);
    if (find.byType(OutboundModeBar).evaluate().isNotEmpty) {
      await tester.tap(
        find.descendant(
          of: find.byType(OutboundModeBar),
          matching: find.text('全局'),
        ),
      );
      await advance();
      expect(
        tester.widget<OutboundModeBar>(find.byType(OutboundModeBar)).mode,
        Mode.global,
      );
    }
    await capture('dashboard');
    final fonts = await loadNativeFontFamilies();
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.android) {
      expect(fonts, isNotEmpty);
    }
    binding.reportData!['systemFontFamilyCount'] = fonts.length;
    await Future<void>.delayed(const Duration(seconds: 2));
    final frameTimings = <ui.FrameTiming>[];
    void collect(List<ui.FrameTiming> frames) => frameTimings.addAll(frames);
    binding.addTimingsCallback(collect);
    try {
      for (var i = 0; i < 2; i++) {
        for (final label in ['proxies', 'profiles', 'dashboard', 'tools']) {
          shell.openPage(label);
          await advance();
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    } finally {
      binding.removeTimingsCallback(collect);
    }
    expect(frameTimings, isNotEmpty);
    binding.reportData!['routeFrames'] = FrameTimingSummarizer(frameTimings)
        .summary;
    await tester.ensureVisible(find.text('主题'));
    await tester.tap(find.text('主题'));
    await advance();
    expect(find.byType(ThemeView), findsOneWidget);
    await capture('theme');
    Navigator.of(tester.element(find.byType(ThemeView))).pop();
    await advance();
    shell.openPage('profiles');
    await advance();
    await ProfilesScope.read(context).addCustomProfile('Runtime workspace');
    await advance();
    await tester.tap(find.text('Runtime workspace'));
    await advance();
    final profiles = ProfilesScope.read(context);
    expect(
      profiles.profiles
          .firstWhere((p) => p.id == profiles.currentProfileId)
          .label,
      'Runtime workspace',
    );
    await capture('profiles');
    expect(tester.takeException(), isNull);
    binding.reportData ??= {};
    binding.reportData!.addAll({
      'completed': true,
      'platform': defaultTargetPlatform.name,
      'logicalSize': {
        'width': tester.view.physicalSize.width / tester.view.devicePixelRatio,
        'height':
            tester.view.physicalSize.height / tester.view.devicePixelRatio,
      },
      'devicePixelRatio': tester.view.devicePixelRatio,
      'captureMethod': 'Flutter engine RenderRepaintBoundary.toImage; excludes OS window frame',
      'inputMethod': 'WidgetTester pointers and host controller calls in a real native engine',
      'captures': captures,
    });
    await tester.pumpWidget(const SizedBox.shrink());
    await advance();
  });
}
