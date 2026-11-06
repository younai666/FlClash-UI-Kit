// Derived from chen08209/FlClash, lib/views/dashboard/widgets/core_status_button.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../data.dart';
import '../dialogs.dart';
import '../localizations.dart';

class CoreStatusButton extends StatefulWidget {
  const CoreStatusButton({
    super.key,
    this.status = CoreStatus.disconnected,
    this.statusListenable,
    this.onRestart,
  });

  final CoreStatus status;
  final ValueListenable<CoreStatus>? statusListenable;
  final Future<void> Function()? onRestart;

  @override
  State<CoreStatusButton> createState() => _CoreStatusButtonState();
}

class _CoreStatusButtonState extends State<CoreStatusButton> {
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _holdTimer;
  CoreStatus _status = CoreStatus.disconnected;

  CoreStatus get _currentStatus =>
      widget.statusListenable?.value ?? widget.status;

  void _handleListenable() {
    _onStatusChanged(_currentStatus);
  }

  @override
  void initState() {
    super.initState();
    _status = _currentStatus;
    widget.statusListenable?.addListener(_handleListenable);
  }

  @override
  void didUpdateWidget(CoreStatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusListenable != widget.statusListenable) {
      oldWidget.statusListenable?.removeListener(_handleListenable);
      widget.statusListenable?.addListener(_handleListenable);
      _onStatusChanged(_currentStatus);
    } else if (widget.statusListenable == null &&
        oldWidget.status != widget.status) {
      _onStatusChanged(widget.status);
    }
  }

  @override
  void dispose() {
    widget.statusListenable?.removeListener(_handleListenable);
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onStatusChanged(CoreStatus next) {
    setState(() {
      _status = next;
      switch (next) {
        case CoreStatus.connecting:
          _holdTimer ??= Timer(_holdDuration, () {
            if (mounted) {
              setState(() {
                _holdTimer = null;
              });
            }
          });
          break;
        case CoreStatus.disconnected:
          _holdTimer?.cancel();
          _holdTimer = null;
          break;
        case CoreStatus.connected:
          break;
      }
    });
  }

  Future<void> _handleConnection() async {
    if (_holdTimer != null || widget.onRestart == null) {
      return;
    }
    final coreStatus = _currentStatus;
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final appLocalizations = KitLocalizations.of(context);
    final tip = coreStatus == CoreStatus.connected
        ? appLocalizations.forceRestartCoreTip
        : appLocalizations.restartCoreTip;
    final res = await showKitMessage(context, message: TextSpan(text: tip));
    if (res != true || !mounted) {
      return;
    }
    try {
      await widget.onRestart!();
    } catch (error) {
      if (mounted) {
        BannerHost.maybeOf(
          context,
        )?.show(error.toString(), level: BannerLevel.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coreStatus = _holdTimer != null ? CoreStatus.connecting : _status;
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final statusColor = switch (coreStatus) {
      CoreStatus.connecting => null,
      CoreStatus.connected => colorScheme.successContainer,
      CoreStatus.disconnected => colorScheme.errorContainer,
    };
    final statusForeground = switch (coreStatus) {
      CoreStatus.connecting => null,
      CoreStatus.connected => colorScheme.onSuccessContainer,
      CoreStatus.disconnected => colorScheme.onErrorContainer,
    };
    final pane = TonalButtonTheme.glassOf(context) && statusColor != null
        ? LiquidGlassStyle.tinted(colorScheme, statusColor)
        : null;
    final iconOnly =
        coreStatus == CoreStatus.connected || ViewScope.isMobileOf(context);
    final icon = switch (coreStatus) {
      CoreStatus.connecting => ActivityIndicator(
        color: iconOnly ? null : colorScheme.onPrimary,
      ),
      CoreStatus.connected => const GlyphIcon(AppGlyphs.check, fill: 1),
      CoreStatus.disconnected => const GlyphIcon(AppGlyphs.refresh, fill: 1),
    };
    return Tooltip(
      message: appLocalizations.coreStatus,
      child: FadeScaleBox(
        alignment: Alignment.centerRight,
        child: iconOnly
            ? IconButton.filled(
                key: ValueKey(coreStatus),
                style: ButtonStyle.from(
                  backgroundColor: pane == null
                      ? statusColor
                      : Colors.transparent,
                  foregroundColor: statusForeground,
                  backgroundBuilder: pane == null
                      ? null
                      : LiquidGlass.buttonBackground((_) => pane),
                  pressLook: PressLook.none,
                ),
                onPressed: _handleConnection,
                icon: icon,
              )
            : FilledButton.icon(
                key: ValueKey(coreStatus),
                onPressed: _handleConnection,
                style: ButtonStyle.from(
                  backgroundColor: pane == null
                      ? statusColor
                      : Colors.transparent,
                  foregroundColor: statusForeground,
                  backgroundBuilder: pane == null
                      ? null
                      : LiquidGlass.buttonBackground((_) => pane),
                  pressLook: PressLook.none,
                ),
                icon: SizedBox.square(
                  dimension: MeasureScope.of(context).textHeight(
                    AppTextStyle.subheadline,
                  ),
                  child: icon,
                ),
                label: Text(switch (coreStatus) {
                  CoreStatus.connecting => appLocalizations.connecting,
                  CoreStatus.connected => appLocalizations.connected,
                  CoreStatus.disconnected => appLocalizations.disconnected,
                }),
              ),
      ),
    );
  }
}
