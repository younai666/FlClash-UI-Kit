// Derived from FlClash lib/manager/window_manager.dart, commit be84736605527034689c95bf27828ff27d912c5e. GPL-3.0.
// Modified 2026-11-05: standalone imports; preserve events arriving during initial queries.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart' show WindowCaptionState;
import 'package:window/window.dart';

/// Maximize and fullscreen are written only from window events: the window
/// manager can change both on its own, and on Linux a maximize request is
/// applied later, so reading the state back right after the call is stale.
class WindowCaptionController extends ValueNotifier<WindowCaptionState>
    with WindowListener {
  WindowCaptionController() : super(const WindowCaptionState()) {
    desktopWindow.addListener(this);
    unawaited(_syncFromWindow());
  }

  bool _disposed = false;
  bool _maxEvent = false;
  bool _fullScreenEvent = false;
  bool _pinChanged = false;

  Future<void> _syncFromWindow() async {
    final states = await Future.wait<bool>([
      desktopWindow.isAlwaysOnTop(),
      desktopWindow.isMaximized(),
      desktopWindow.isFullScreen(),
    ]);
    _set(
      WindowCaptionState(
        isPinned: _pinChanged ? value.isPinned : states[0],
        isMaximized: _maxEvent ? value.isMaximized : states[1],
        isFullScreen: _fullScreenEvent ? value.isFullScreen : states[2],
      ),
    );
  }

  void _set(WindowCaptionState state) {
    if (_disposed) return;
    value = state;
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    _maxEvent = true;
    _set(value.copyWith(isMaximized: true));
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _maxEvent = true;
    _set(value.copyWith(isMaximized: false));
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _fullScreenEvent = true;
    _set(value.copyWith(isFullScreen: true));
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _fullScreenEvent = true;
    _set(value.copyWith(isFullScreen: false));
  }

  Future<void> toggleMaximized() async {
    if (await desktopWindow.isFullScreen()) {
      await desktopWindow.setFullScreen(false);
    } else if (await desktopWindow.isMaximized()) {
      await desktopWindow.unmaximize();
    } else {
      await desktopWindow.maximize();
    }
  }

  Future<void> togglePin() async {
    final isPinned = await desktopWindow.isAlwaysOnTop();
    await desktopWindow.setAlwaysOnTop(!isPinned);
    final applied = await desktopWindow.isAlwaysOnTop();
    _pinChanged = true;
    _set(value.copyWith(isPinned: applied));
  }

  @override
  void dispose() {
    _disposed = true;
    desktopWindow.removeListener(this);
    super.dispose();
  }
}

