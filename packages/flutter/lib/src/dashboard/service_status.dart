// Derived from chen08209/FlClash, lib/views/dashboard/widgets/service_status.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

String _statusLabel(BuildContext context, ServiceProbeStatus status) {
  final localizations = KitLocalizations.of(context);
  return switch (status) {
    ServiceProbeStatus.available => localizations.serviceAvailable,
    ServiceProbeStatus.restricted => localizations.serviceRestricted,
    ServiceProbeStatus.unavailable => localizations.serviceUnavailable,
    ServiceProbeStatus.disallowedIsp => localizations.serviceDisallowedIsp,
    ServiceProbeStatus.blocked => localizations.serviceBlocked,
    ServiceProbeStatus.unsupportedRegion =>
      localizations.serviceUnsupportedRegion,
    ServiceProbeStatus.originalsOnly => localizations.serviceOriginalsOnly,
    ServiceProbeStatus.comingSoon => localizations.serviceComingSoon,
    ServiceProbeStatus.timeout => localizations.timeout,
    ServiceProbeStatus.failed => localizations.serviceFailed,
  };
}

Color _statusColor(BuildContext context, ServiceProbeStatus status) {
  final colorScheme = context.colorScheme;
  return switch (status) {
    ServiceProbeStatus.available => colorScheme.success,
    ServiceProbeStatus.restricted ||
    ServiceProbeStatus.disallowedIsp ||
    ServiceProbeStatus.blocked ||
    ServiceProbeStatus.unsupportedRegion ||
    ServiceProbeStatus.originalsOnly ||
    ServiceProbeStatus.comingSoon => colorScheme.warning,
    ServiceProbeStatus.unavailable ||
    ServiceProbeStatus.timeout ||
    ServiceProbeStatus.failed => colorScheme.error,
  };
}

(String, Color) _statusOf(
  BuildContext context,
  ServiceCheck? check,
  ProbePhase phase,
) {
  final localizations = KitLocalizations.of(context);
  final idle = context.colorScheme.onSurfaceVariant;
  if (phase == ProbePhase.probing) {
    return (localizations.loading, idle);
  }
  if (check != null) {
    return (
      _statusLabel(context, check.status),
      _statusColor(context, check.status),
    );
  }
  if (phase == ProbePhase.failed) {
    return (
      _statusLabel(context, ServiceProbeStatus.failed),
      context.colorScheme.error,
    );
  }
  return (localizations.servicePending, idle);
}

/// A service as the card shows it: a failure held through a start reads as
/// still checking, without the result it replaced.
class ServiceStatusItem {
  const ServiceStatusItem(this.target, {this.check, this.phase = ProbePhase.idle});

  final ServiceTarget target;
  final ProbePhase phase;
  final ServiceCheck? check;

  bool get loading => phase == ProbePhase.probing && check == null;

  bool get abnormal => switch (check) {
    final check? => check.status != ServiceProbeStatus.available,
    null => phase == ProbePhase.failed,
  };

  (String, Color) statusOf(BuildContext context) => switch (check) {
    ServiceCheck(status: ServiceProbeStatus.available, :final delay) => (
      delay != null
          ? '$delay ms'
          : _statusLabel(context, ServiceProbeStatus.available),
      context.colorScheme.onSurfaceVariant,
    ),
    final ServiceCheck check => (
      _statusLabel(context, check.status),
      _statusColor(context, check.status),
    ),
    null => _statusOf(context, null, phase),
  };

  Color? dotOf(BuildContext context) => switch (check) {
    final check? => _statusColor(context, check.status),
    null when phase == ProbePhase.failed => context.colorScheme.error,
    null => null,
  };
}

class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard({super.key, required this.services, this.columns = 2,
    this.loading = false, this.onRefresh, this.onDetails}) : assert(columns > 0);
  final List<ServiceStatusItem> services;
  final int columns;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final mobile = !density.isDesktop;
    final appLocalizations = KitLocalizations.of(context);
    // At most four: what the Core checks at once (serviceCheckConcurrency).
    final shownCount = (mobile ? 1 : 2) * columns;
    final stacked = columns == 1;
    final services = this.services.take(shownCount).toList();
    final problems = services.where((service) => service.abnormal).length;
    final verdict = problems > 0
        ? DashboardChip(
            label: appLocalizations.serviceAbnormalCount(problems),
            tone: DashboardChipTone.warn,
          )
        : services.every((service) => service.check != null)
        ? DashboardChip(
            label: appLocalizations.serviceAllAvailable,
            tone: DashboardChipTone.ok,
          )
        : null;
    final openSheet = onDetails;
    final scale = DashboardDensityScope.scaleOf(context);
    final grid = _ServiceGrid(
      services: services,
      columns: columns,
      fill: !mobile,
      cellHeight:
          (mobile
              ? 44
              : density.isCompact
              ? 40
              : 46) *
          scale,
      gap: density.isCompact ? 6 : 8,
    );
    return DashboardCard(
      semanticLabel: appLocalizations.serviceStatus,
      onTap: mobile ? openSheet : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.verified,
            title: appLocalizations.serviceStatus,
            chevron: mobile && onDetails != null,
            trailing: [
              if (!stacked) ?verdict,
              if (!mobile)
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!stacked && onRefresh != null)
                        _CheckAllButton(
                          loading: loading,
                          onPressed: onRefresh!,
                        ),
                      DashboardIconButton(
                        glyph: AppGlyphs.chevronForward,
                        tooltip: appLocalizations.serviceStatus,
                        onPressed: openSheet,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (mobile) const SizedBox(height: 12) else const Spacer(),
          grid,
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.services,
    required this.columns,
    required this.fill,
    required this.cellHeight,
    required this.gap,
  });

  final List<ServiceStatusItem> services;
  final int columns;

  /// Holds two rows on a fixed-height card, a single row growing into tiles.
  final bool fill;
  final double cellHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (fill && services.length <= columns) {
      return SizedBox(
        height: cellHeight * 2 + gap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (final service in services)
              Expanded(
                child: _ServiceCell(
                  service: service,
                  height: cellHeight,
                  tile: true,
                ),
              ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        for (var start = 0; start < services.length; start += columns)
          Row(
            spacing: gap,
            children: [
              for (final service in services.skip(start).take(columns))
                Expanded(
                  child: _ServiceCell(service: service, height: cellHeight),
                ),
            ],
          ),
      ],
    );
  }
}

class _ServiceCell extends StatelessWidget {
  const _ServiceCell({
    required this.service,
    required this.height,
    this.tile = false,
  });

  static const _inset = 7.0;

  // Lines the text up with the 12 a cell keeps clear at its end.
  static const _tileText = EdgeInsetsDirectional.fromSTEB(5, 0, 5, 3);

  final ServiceStatusItem service;
  final double height;

  final bool tile;

  @override
  Widget build(BuildContext context) {
    final (label, color) = service.statusOf(context);
    final status = AppTextStyle.caption1
        .of(context, emphasized: true)
        .toTabular
        .copyWith(color: color);
    final badge = ServiceBadge(
      target: service.target,
      size: height - _inset * 2,
      radius: DashboardCorner.tab - _inset,
      color: DashboardColors.of(context).card,
      ink: context.colorScheme.onSurfaceVariant,
      dot: service.dotOf(context),
    );
    final text = ExcludeSemantics(
      child: service.loading
          ? SkeletonText(width: 44, style: status)
          : Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: status,
            ),
    );
    return Semantics(
      label: service.target.label,
      value: label,
      liveRegion: true,
      child: Tooltip(
        message: '${service.target.label}\n$label',
        excludeFromSemantics: true,
        child: tile
            ? DashboardBlock(
                radius: DashboardCorner.tab,
                padding: const EdgeInsets.all(_inset),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badge,
                    Padding(padding: _tileText, child: text),
                  ],
                ),
              )
            : SizedBox(
                height: height,
                child: DashboardBlock(
                  radius: DashboardCorner.tab,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    _inset,
                    0,
                    12,
                    0,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      badge,
                      Expanded(child: text),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// painted in the surface colour, which differs between the card and the rows.
class ServiceBadge extends StatelessWidget {
  const ServiceBadge({super.key,
    required this.target,
    required this.size,
    this.radius,
    this.dot,
    this.enabled = true,
    this.color,
    this.ink,
  });

  static const _glyphShare = 0.56;

  final ServiceTarget target;
  final double size;
  final double? radius;
  final Color? dot;
  final bool enabled;
  final Color? color;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CustomPaint(
      size: Size.square(size),
      painter: _BadgePainter(
        color: color ?? context.raisedSurfaceLevel.colorOf(colorScheme),
        radius: radius ?? AppCorner.fit(size),
        dot: dot,
        dotRadius: max(size / 10, 4),
        ring: max(size / 16, 2),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: SvgPicture.asset(
            'assets/images/services/${target.icon}.svg',
            package: 'flclash_ui_kit',
            width: size * _glyphShare,
            height: size * _glyphShare,
            excludeFromSemantics: true,
            theme: SvgTheme(
              currentColor:
                  ink ??
                  (enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.opacity38),
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  const _BadgePainter({
    required this.color,
    required this.radius,
    required this.dot,
    required this.dotRadius,
    required this.ring,
  });

  final Color color;
  final double radius;
  final Color? dot;
  final double dotRadius;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final tile = RSuperellipse.fromRectAndRadius(
      bounds,
      Radius.circular(radius),
    );
    final dot = this.dot;
    if (dot == null) {
      canvas.drawRSuperellipse(tile, Paint()..color = color);
      return;
    }
    final center = size.bottomRight(Offset(-dotRadius, -dotRadius));
    final gap = Path()
      ..addOval(Rect.fromCircle(center: center, radius: dotRadius + ring));
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRSuperellipse(tile),
          gap,
        ),
        Paint()..color = color,
      )
      ..drawCircle(center, dotRadius, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_BadgePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.dot != dot ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.ring != ring;
}


class _CheckAllButton extends StatelessWidget {
  const _CheckAllButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox.square(
        dimension: 32,
        child: Center(child: ActivityIndicator(size: 18)),
      );
    }
    return DashboardIconButton(
      glyph: AppGlyphs.bolt,
      tooltip: KitLocalizations.of(context).serviceCheckAll,
      onPressed: onPressed,
    );
  }
}

