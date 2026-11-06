import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  test('shared-process memory is separated without double counting', () {
    const core = CoreMemoryStats(rss: 80, heapInuse: 40, heapIdle: 10, stackInuse: 5, runtimeOther: 5);
    final shared = MemorySnapshot.resolve(rss: 120, core: core, coreInProcess: true);
    expect(shared.app, 60);
    expect(shared.total, 120);
    final separate = MemorySnapshot.resolve(rss: 120, core: core, coreInProcess: false);
    expect(separate.total, 200);
    expect(separate.coreOther, 20);
  });
  test('scan geometry fits portrait and short landscape', () {
    for (final size in [const Size(390, 844), const Size(844, 390)]) {
      final layout = ScanLayout(size: size, padding: const EdgeInsets.fromLTRB(0, 24, 0, 20), hintHeight: 42);
      expect(layout.scanWindow.width, greaterThan(0));
      expect(layout.scanWindow.width, lessThanOrEqualTo(400));
      expect((Offset.zero & size).contains(layout.scanWindow.topLeft), isTrue);
      expect((Offset.zero & size).contains(layout.scanWindow.bottomRight), isTrue);
      expect(layout.scanWindow.overlaps(layout.torch), isFalse);
      expect(layout.scanWindow.overlaps(layout.hint), isFalse);
    }
  });
  test('paused scan repaint reacts to contrast and paints an empty window safely', () {
    ScanEffectPainter painter(Color contrast, {Rect window = const Rect.fromLTWH(20, 20, 180, 180)}) => ScanEffectPainter(
      animation: const AlwaysStoppedAnimation(.3), scanWindow: window,
      borderRadius: 16, color: const Color(0xFF0066FF), highlight: const Color(0xFFFFFFFF), contrast: contrast);
    final old = painter(const Color(0xFFFFFFFF));
    expect(painter(const Color(0xFF000000)).shouldRepaint(old), isTrue);
  });
  testWidgets('caption callbacks and restore tooltip follow explicit state', (tester) async {
    final caption = ValueNotifier(const WindowCaptionState());
    addTearDown(caption.dispose);
    var closes = 0;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: Center(child: WindowHeaderBar(
      height: 32, onDragStart: () {}, onDoubleTap: () {}, actions: WindowHeaderActions(state: caption,
      onPin: () => caption.value = caption.value.copyWith(isPinned: true), onMinimize: () {},
      onMaximize: () => caption.value = caption.value.copyWith(isMaximized: true), onClose: () => closes++)))));
    await tester.tap(find.byTooltip('Maximize'));
    await tester.pump();
    expect(find.byTooltip('Restore'), findsOneWidget);
    await tester.tap(find.byTooltip('Pin window'));
    await tester.pump();
    expect(find.byTooltip('Unpin window'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    expect(closes, 1);
  });
  testWidgets('failed memory reread after release reports error, never success', (tester) async {
    var fail = false;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: MemoryDetailSheet(
      initial: const MemorySnapshot(app: 1024),
      memoryReader: () async {
        if (fail) throw StateError('host read failed');
        return const MemorySnapshot(app: 1024);
      }, onRelease: () async => fail = true)));
    await tester.pump();
    await tester.tap(find.byTooltip('Release memory'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Unable to release memory'), findsOneWidget);
    expect(find.text('Memory released'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
