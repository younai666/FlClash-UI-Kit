import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_platform/flclash_ui_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('window');
  var pinned = false, maximized = false, fullscreen = false;
  final requests = <String>[];
  setUp(() {
    pinned = maximized = fullscreen = false;
    requests.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      requests.add(call.method);
      return switch (call.method) {
        'isAlwaysOnTop' => pinned,
        'isMaximized' => maximized,
        'isFullScreen' => fullscreen,
        'setAlwaysOnTop' => pinned = (call.arguments as Map)['value'] as bool,
        _ => null,
      };
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
  Future<void> event(String name) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage('window',
      const StandardMethodCodec().encodeMethodCall(MethodCall('onEvent', {'name': name})), (_) {});
  }
  test('caption maximization follows native events and removes its listener', () async {
    final caption = WindowCaptionController();
    await Future<void>.delayed(Duration.zero);
    await caption.toggleMaximized();
    expect(requests, contains('maximize'));
    expect(caption.value.isMaximized, isFalse, reason: 'requests can finish before a Linux window manager applies them');
    await event('maximize');
    expect(caption.value.isMaximized, isTrue);
    maximized = true;
    await caption.toggleMaximized();
    expect(requests.last, 'unmaximize');
    await event('unmaximize');
    expect(caption.value.isMaximized, isFalse);
    caption.dispose();
    expect(desktopWindow.listeners, isNot(contains(caption)));
  });
  test('fullscreen exit precedes maximizing and pin reflects the native answer', () async {
    fullscreen = true;
    final caption = WindowCaptionController();
    await Future<void>.delayed(Duration.zero);
    expect(caption.value.isFullScreen, isTrue);
    await caption.toggleMaximized();
    expect(requests.last, 'setFullScreen');
    await caption.togglePin();
    expect(caption.value.isPinned, isTrue);
    caption.dispose();
  });
  test('an initial query cannot overwrite a newer native window event', () async {
    final delayed = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'isAlwaysOnTop' => true,
        'isMaximized' => await delayed.future,
        'isFullScreen' => false,
        _ => null,
      };
    });
    final caption = WindowCaptionController();
    await event('maximize');
    await event('enter-full-screen');
    expect(caption.value.isMaximized, isTrue);
    delayed.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(caption.value.isMaximized, isTrue);
    expect(caption.value.isFullScreen, isTrue);
    expect(caption.value.isPinned, isTrue, reason: 'unrelated initial fields must still load');
    caption.dispose();
  });
}
