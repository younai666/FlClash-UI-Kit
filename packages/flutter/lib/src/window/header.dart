// Derived from chen08209/FlClash, lib/manager/window_manager.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../../icons.dart';
import '../localizations.dart';
import 'layout.dart';

class WindowHeaderLayout extends StatelessWidget {
  const WindowHeaderLayout({
    super.key,
    required this.height,
    required this.header,
    required this.child,
  });

  final double height;
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay.wrap(
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: height),
              Expanded(flex: 1, child: child),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: header),
        ],
      ),
    );
  }
}

@immutable
class WindowCaptionState {
  const WindowCaptionState({
    this.isPinned = false,
    this.isMaximized = false,
    this.isFullScreen = false,
  });

  final bool isPinned;
  final bool isMaximized;
  final bool isFullScreen;

  WindowCaptionState copyWith({
    bool? isPinned,
    bool? isMaximized,
    bool? isFullScreen,
  }) {
    return WindowCaptionState(
      isPinned: isPinned ?? this.isPinned,
      isMaximized: isMaximized ?? this.isMaximized,
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WindowCaptionState &&
        other.isPinned == isPinned &&
        other.isMaximized == isMaximized &&
        other.isFullScreen == isFullScreen;
  }

  @override
  int get hashCode => Object.hash(isPinned, isMaximized, isFullScreen);
}

class WindowHeaderBar extends StatelessWidget {
  const WindowHeaderBar({
    super.key,
    required this.height,
    required this.onDragStart,
    required this.onDoubleTap,
    this.backdropOpacity,
    this.title,
    this.actions,
  });

  final double height;
  final VoidCallback onDragStart;
  final VoidCallback onDoubleTap;
  final double? backdropOpacity;
  final Widget? title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final backdropOpacity = this.backdropOpacity;
    return Surface(
      color: backdropOpacity != null ? Colors.transparent : colorScheme.surface,
      shape: Border(bottom: Divider.createBorderSide(context)),
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (_) {
                  onDragStart();
                },
                onDoubleTap: onDoubleTap,
                child: ColoredBox(
                  color: backdropOpacity != null
                      ? colorScheme.chromeSurface.withValues(
                          alpha: backdropOpacity,
                        )
                      : colorScheme.chromeSurface,
                ),
              ),
            ),
            if (title != null)
              Positioned.fill(
                child: IgnorePointer(child: Center(child: title)),
              ),
            if (actions != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: ButtonTheme(
                  // Caption buttons answer a pointer as the system's do.
                  data: ButtonThemeData(
                    icon: ButtonStyle(
                      tapTargetSize: TapTargetSize.shrinkWrap,
                      minimumSize: getCaptionButtonSize(height),
                      maximumSize: getCaptionButtonSize(height),
                      padding: EdgeInsets.zero,
                      shape: AppShape.none,
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onSurface,
                      ),
                      overlayColor: WidgetStateProperty.fromMap({
                        WidgetState.pressed:
                            colorScheme.onSurfaceVariant.opacity10,
                        WidgetState.hovered: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.08),
                        WidgetState.focused:
                            colorScheme.onSurfaceVariant.opacity10,
                      }),
                      pressLook: PressLook.none,
                    ),
                  ),
                  child: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WindowHeaderActions extends StatelessWidget {
  const WindowHeaderActions({
    super.key,
    required this.state,
    required this.onPin,
    required this.onMinimize,
    required this.onMaximize,
    required this.onClose,
  });

  final ValueListenable<WindowCaptionState> state;
  final VoidCallback onPin;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (_, state, _) {
        final (maximizeGlyph, maximizeTooltip) = switch (state) {
          WindowCaptionState(isFullScreen: true) => (
            CaptionGlyph.restore,
            appLocalizations.exitFullScreen,
          ),
          WindowCaptionState(isMaximized: true) => (
            CaptionGlyph.restore,
            appLocalizations.unmaximize,
          ),
          _ => (CaptionGlyph.maximize, appLocalizations.maximize),
        };
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: IconButton(
                tooltip: state.isPinned
                    ? appLocalizations.unpinWindow
                    : appLocalizations.pinWindow,
                style: const ButtonStyle(
                  shape: AppShape.circle,
                  minimumSize: Size.zero,
                  maximumSize: Size.infinite,
                  iconSize: pinIconSize,
                ),
                onPressed: onPin,
                icon: AnimatedGlyph(
                  glyph: AppGlyphs.pin,
                  filled: state.isPinned,
                ),
              ),
            ),
            IconButton(
              tooltip: appLocalizations.minimize,
              onPressed: onMinimize,
              icon: const CaptionIcon(CaptionGlyph.minimize),
            ),
            IconButton(
              tooltip: maximizeTooltip,
              onPressed: onMaximize,
              icon: CaptionIcon(maximizeGlyph),
            ),
            IconButton(
              tooltip: appLocalizations.close,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? context.colorScheme.error : null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  final active =
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed);
                  return active ? context.colorScheme.onError : null;
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.pressed)
                      ? context.colorScheme.onError.opacity12
                      : Colors.transparent;
                }),
              ),
              onPressed: onClose,
              icon: const CaptionIcon(CaptionGlyph.close),
            ),
          ],
        );
      },
    );
  }
}
