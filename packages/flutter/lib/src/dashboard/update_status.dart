// Derived from chen08209/FlClash, lib/views/dashboard/widgets/update_status.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../dialogs.dart';
import '../format.dart';
import '../localizations.dart';
import 'app_update.dart';
import 'card.dart';
import 'style.dart';

String _progressText(UpdateDownloading download) {
  final received = download.received.traffic.show;
  if (download.total <= 0) {
    return received;
  }
  return '$received / ${download.total.traffic.show}';
}

String _readyTip(KitLocalizations appLocalizations, {required bool isWindows}) =>
    isWindows
        ? '${appLocalizations.updateReadyTip}\n${appLocalizations.updateRestartTip}'
        : appLocalizations.updateReadyTip;

/// The phone dashboard's top card while an update downloads or waits. It keeps
/// the last download on screen as it leaves, and takes its own gap so the cards
/// below close up with it.
class UpdateStatusSlot extends StatefulWidget {
  const UpdateStatusSlot({
    super.key,
    required this.gap,
    this.download,
    this.downloadListenable,
    this.onInstall,
    this.onDiscard,
    this.onCancel,
    this.isWindows,
  });

  final double gap;
  final UpdateDownload? download;
  final ValueListenable<UpdateDownload?>? downloadListenable;
  final Future<void> Function()? onInstall;
  final Future<void> Function()? onDiscard;
  final VoidCallback? onCancel;
  final bool? isWindows;

  @override
  State<UpdateStatusSlot> createState() => _UpdateStatusSlotState();
}

class _UpdateStatusSlotState extends State<UpdateStatusSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  UpdateDownload? _download;

  UpdateDownload? get _currentDownload =>
      widget.downloadListenable?.value ?? widget.download;

  void _handleListenable() {
    unawaited(_follow(_currentDownload));
  }

  @override
  void initState() {
    super.initState();
    _download = _currentDownload;
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration,
      value: _download == null ? 0 : 1,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    widget.downloadListenable?.addListener(_handleListenable);
  }

  @override
  void didUpdateWidget(UpdateStatusSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downloadListenable != widget.downloadListenable) {
      oldWidget.downloadListenable?.removeListener(_handleListenable);
      widget.downloadListenable?.addListener(_handleListenable);
      unawaited(_follow(_currentDownload));
    } else if (widget.downloadListenable == null &&
        oldWidget.download != widget.download) {
      unawaited(_follow(widget.download));
    }
  }

  @override
  void dispose() {
    widget.downloadListenable?.removeListener(_handleListenable);
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _follow(UpdateDownload? next) async {
    if (next != null) {
      setState(() => _download = next);
      if (context.disableAnimations) {
        _controller.value = 1;
      } else {
        unawaited(_controller.forward());
      }
      return;
    }
    if (context.disableAnimations) {
      _controller.value = 0;
    } else {
      await _controller.reverse().orCancel.catchError((_) {});
    }
    if (mounted && _controller.isDismissed) {
      setState(() => _download = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final download = _download;
    if (download == null) {
      return const SizedBox.shrink();
    }
    // Not SizeTransition: its clip would cut the card's shadow at rest.
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => Align(
        alignment: Alignment.topCenter,
        heightFactor: _curve.value,
        child: child,
      ),
      child: FadeTransition(
        opacity: _curve,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.gap),
          child: RepaintBoundary(
            child: UpdateStatusCard(
              download: download,
              onInstall: widget.onInstall,
              onDiscard: widget.onDiscard,
              onCancel: widget.onCancel,
              isWindows: widget.isWindows,
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateStatusCard extends StatelessWidget {
  const UpdateStatusCard({
    super.key,
    required this.download,
    this.onInstall,
    this.onDiscard,
    this.onCancel,
    this.isWindows,
  });

  final UpdateDownload download;
  final Future<void> Function()? onInstall;
  final Future<void> Function()? onDiscard;
  final VoidCallback? onCancel;
  final bool? isWindows;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final ready = download is UpdateReady;
    final windows = isWindows ?? (defaultTargetPlatform == TargetPlatform.windows);
    return DashboardCard(
      onTap: ready && onInstall != null ? () => unawaited(onInstall!()) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          DashboardCardHeader(
            glyph: ready ? AppGlyphs.checkCircle : AppGlyphs.cloudDownload,
            title: ready
                ? appLocalizations.updateReady
                : appLocalizations.downloadingUpdate,
            leading: [DashboardChip(label: download.tag)],
            trailing: [
              Transform.translate(
                offset: const Offset(8, 0),
                child: DashboardIconButton(
                  glyph: AppGlyphs.close,
                  tooltip: appLocalizations.cancel,
                  onPressed: ready
                      ? (onDiscard == null ? null : () => unawaited(onDiscard!()))
                      : onCancel,
                ),
              ),
            ],
          ),
          switch (download) {
            final UpdateDownloading progress => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                LinearProgressIndicator(
                  minHeight: 4,
                  value: progress.total > 0
                      ? progress.received / progress.total
                      : null,
                ),
                Text(
                  _progressText(progress),
                  style: DashboardText.label(context),
                ),
              ],
            ),
            UpdateReady() => Text(
              _readyTip(appLocalizations, isWindows: windows),
              style: DashboardText.label(context),
            ),
          },
        ],
      ),
    );
  }
}

/// The desktop dashboard's bar button while an update downloads or waits.
class UpdateStatusButton extends StatelessWidget {
  const UpdateStatusButton({
    super.key,
    this.download,
    this.downloadListenable,
    this.onInstall,
    this.onCancel,
    this.isWindows,
  });

  final UpdateDownload? download;
  final ValueListenable<UpdateDownload?>? downloadListenable;
  final Future<void> Function()? onInstall;
  final VoidCallback? onCancel;
  final bool? isWindows;

  Future<void> _handlePressed(
    BuildContext context,
    UpdateDownload download,
  ) async {
    final appLocalizations = KitLocalizations.of(context);
    final windows = isWindows ?? (defaultTargetPlatform == TargetPlatform.windows);
    final res = await showKitMessage(
      context,
      title: download is UpdateReady
          ? appLocalizations.updateReady
          : appLocalizations.downloadingUpdate,
      message: TextSpan(
        text: download is UpdateReady
            ? _readyTip(appLocalizations, isWindows: windows)
            : appLocalizations.stopUpdateDownloadTip,
      ),
      confirmText: download is UpdateReady ? appLocalizations.update : null,
      destructive: download is UpdateDownloading,
    );
    if (res != true) return;
    switch (download) {
      case UpdateReady():
        await onInstall?.call();
      case UpdateDownloading():
        onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listenable = downloadListenable;
    if (listenable != null) {
      return ValueListenableBuilder<UpdateDownload?>(
        valueListenable: listenable,
        builder: (context, value, _) => _buildButton(context, value),
      );
    }
    return _buildButton(context, download);
  }

  Widget _buildButton(BuildContext context, UpdateDownload? download) {
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final ready = download is UpdateReady;
    final statusColor = ready ? colorScheme.successContainer : null;
    final pane = TonalButtonTheme.glassOf(context) && statusColor != null
        ? LiquidGlassStyle.tinted(colorScheme, statusColor)
        : null;
    final label = switch (download) {
      null => '',
      UpdateReady() => appLocalizations.updateReady,
      UpdateDownloading(:final received, :final total) =>
        total > 0 ? '${received * 100 ~/ total}%' : received.traffic.show,
    };
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: download == null
          ? const SizedBox.shrink()
          : Tooltip(
              key: ValueKey(ready),
              message: ready
                  ? appLocalizations.updateReady
                  : appLocalizations.downloadingUpdate,
              child: FilledButton.icon(
                onPressed: () => unawaited(_handlePressed(context, download)),
                style: ButtonStyle.from(
                  backgroundColor: pane == null
                      ? statusColor
                      : Colors.transparent,
                  foregroundColor: ready
                      ? colorScheme.onSuccessContainer
                      : null,
                  backgroundBuilder: pane == null
                      ? null
                      : LiquidGlass.buttonBackground((_) => pane),
                  pressLook: PressLook.none,
                ),
                icon: GlyphIcon(
                  ready ? AppGlyphs.checkCircle : AppGlyphs.cloudDownload,
                  fill: 1,
                  size: MeasureScope.of(context).textHeight(
                    AppTextStyle.subheadline,
                  ),
                ),
                label: Text(label),
              ),
            ),
    );
  }
}
