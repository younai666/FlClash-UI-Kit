// Derived from chen08209/FlClash, lib/views/dashboard/widgets/profiles.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

typedef _Usage = ({int used, int total, double share});

_Usage? _usageOf(DashboardProfile? profile) {
  final info = profile?.subscriptionInfo;
  if (info == null || info.total <= 0) {
    return null;
  }
  final used = info.upload + info.download;
  return (
    used: used,
    total: info.total,
    share: (used / info.total).clamp(0.0, 1.0).toDouble(),
  );
}

DateTime? _expiryOf(DashboardProfile? profile) {
  final expire = profile?.subscriptionInfo?.expire ?? 0;
  return expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;
}

int _daysLeft(DateTime expiry) =>
    math.max(0, expiry.difference(DateTime.now()).inDays);

String _expiryText(BuildContext context, DateTime expiry) =>
    KitLocalizations.of(context).profileExpiresIn(expiry.show, _daysLeft(expiry));

const _nearlyUsedShare = 0.9;

String _percentOf(double share) => '${(share * 100).round()}%';

String _sourceOf(BuildContext context, DashboardProfileType type) => switch (type) {
  DashboardProfileType.url => KitLocalizations.of(context).remote,
  DashboardProfileType.file => KitLocalizations.of(context).local,
  DashboardProfileType.custom => KitLocalizations.of(context).custom,
};

class ProfilesCard extends StatelessWidget {
  const ProfilesCard({super.key, this.profile, this.switchable = false, this.isUpdating = false,
    this.stats, this.statsFailed = false, this.onOpen, this.onSwitch, this.onSync});
  final DashboardProfile? profile;
  final bool switchable;
  final bool isUpdating;
  final ProfileStats? stats;
  final bool statsFailed;
  final VoidCallback? onOpen;
  final VoidCallback? onSwitch;
  final VoidCallback? onSync;

  static const _soonDays = 7;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final mobile = !density.isDesktop;
    final compact = density.isCompact;
    final appLocalizations = KitLocalizations.of(context);
    final profile = this.profile;
    final switchable = this.switchable;
    final usage = _usageOf(profile);
    final expiry = _expiryOf(profile);
    final updatedAt = profile?.lastUpdateDate;
    final label = DashboardText.label(context);
    final figure = mobile
        ? AppTextStyle.title3
        : (compact ? AppTextStyle.callout : AppTextStyle.headline);
    final name = mobile || !compact
        ? AppTextStyle.headline
        : AppTextStyle.callout;
    final endText = switch ((profile, expiry)) {
      (_, final expiry?) => appLocalizations.profileDaysLeft(_daysLeft(expiry)),
      (final profile?, null) => _sourceOf(context, profile.type),
      _ => null,
    };
    final Widget? end = switch ((endText, expiry)) {
      (final text?, final expiry?) => Tooltip(
        message: _expiryText(context, expiry),
        child: Text(
          text,
          maxLines: 1,
          style: _daysLeft(expiry) <= _soonDays
              ? label.copyWith(color: DashboardColors.of(context).warn)
              : label,
        ),
      ),
      (final text?, null) => Text(text, maxLines: 1, style: label),
      _ => null,
    };
    final sync = profile != null && profile.type == DashboardProfileType.url
        ? _SyncButton(isUpdating: isUpdating, onPressed: onSync)
        : null;
    final nameRow = Row(
      children: [
        Flexible(
          child: EmojiText(
            profile?.label ?? appLocalizations.addProfile,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: name.of(context, emphasized: true),
          ),
        ),
        if (profile != null && switchable)
          SizedBox(
            height: name.leading,
            child: DashboardIconButton(
              glyph: AppGlyphs.swap,
              tooltip: appLocalizations.switchProfile,
              onPressed: onSwitch,
            ),
          ),
      ],
    );
    return DashboardCard(
      semanticLabel: appLocalizations.profile,
      onTap: mobile || profile == null
          ? onOpen
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.profiles,
            title: appLocalizations.profile,
            chevron: mobile && onOpen != null,
            trailing: [
              if (mobile)
                ?sync
              else
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?sync,
                      DashboardIconButton(
                        glyph: AppGlyphs.chevronForward,
                        tooltip: appLocalizations.details(
                          appLocalizations.profile,
                        ),
                        onPressed: onOpen,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: mobile ? 12 : 10),
          if (compact && end != null)
            DashboardCappedRow(spacing: _rowGap, start: nameRow, end: end)
          else
            nameRow,
          if (profile != null && !compact)
            LayoutBuilder(
              builder: (context, constraints) {
                final time = updatedAt?.getLastUpdateTimeDesc(context);
                final updated = time == null
                    ? null
                    : appLocalizations.profileUpdatedAt(time);
                final fits =
                    updated == null ||
                    _textWidth(context, updated, label) +
                            _rowGap +
                            _textWidth(context, endText ?? '', label) <=
                        constraints.maxWidth;
                return Row(
                  spacing: _rowGap,
                  children: [
                    Expanded(
                      child: Text(
                        (fits ? updated : time) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: label,
                      ),
                    ),
                    ?end,
                  ],
                );
              },
            ),
          if (profile != null) ...[
            if (mobile) const SizedBox(height: 14) else const Spacer(),
            if (usage != null)
              _UsageMeter(usage: usage, figure: figure, gap: mobile ? 8 : 6)
            else
              _ConfigStats(figure: figure, stats: stats, failed: statsFailed),
          ],
        ],
      ),
    );
  }
}

const _rowGap = 12.0;

double _textWidth(BuildContext context, String text, TextStyle style) =>
    MeasureScope.of(context).computeTextSize(Text(text, style: style)).width;

class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.isUpdating, this.onPressed});

  final bool isUpdating;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return const SizedBox.square(
        dimension: 32,
        child: Center(child: ActivityIndicator(size: 18)),
      );
    }
    return DashboardIconButton(
      glyph: AppGlyphs.sync,
      tooltip: KitLocalizations.of(context).update,
      onPressed: onPressed,
    );
  }
}

class _ConfigStats extends StatelessWidget {
  const _ConfigStats({required this.figure, required this.stats, required this.failed});
  final AppTextStyle figure;
  final ProfileStats? stats;
  final bool failed;
  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final figure = DashboardText.figure(
      context,
      this.figure,
    ).copyWith(letterSpacing: 0);
    final label = DashboardText.label(context);
    Widget item(int? value, String name) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value != null)
          Text(dashboardCount(value), maxLines: 1, style: figure)
        else if (failed)
          Text('—', maxLines: 1, style: figure)
        else
          SkeletonText(width: this.figure.size * 1.5, style: figure),
        Text(name, maxLines: 1, style: label),
      ],
    );
    return LayoutBuilder(
      // The minimum width lets spaceBetween spread the row inside FittedBox.
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              item(stats?.groups, appLocalizations.proxyGroup),
              item(stats?.proxies, appLocalizations.proxies),
              item(stats?.rules, appLocalizations.rules),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    required this.usage,
    required this.figure,
    required this.gap,
  });

  final _Usage usage;
  final AppTextStyle figure;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final percent = DashboardText.figure(
              context,
              figure,
            ).copyWith(letterSpacing: 0);
            final unit = DashboardText.unit(context, AppTextStyle.footnote);
            final used = ' ${KitLocalizations.of(context).usedShort}';
            final traffic =
                '${dashboardTraffic(usage.used)} / ${dashboardTraffic(usage.total)}';
            final trafficStyle = AppTextStyle.footnote
                .of(context)
                .toTabular
                .copyWith(color: context.colorScheme.onSurfaceVariant);
            final showUnit =
                _textWidth(context, _percentOf(usage.share), percent) +
                    _textWidth(context, used, unit) +
                    _rowGap +
                    _textWidth(context, traffic, trafficStyle) <=
                constraints.maxWidth;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: _rowGap,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _percentOf(usage.share), style: percent),
                      if (showUnit) TextSpan(text: used, style: unit),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    traffic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: trafficStyle,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: gap),
        SizedBox(
          height: 12,
          child: CustomPaint(
            painter: WavyProgressPainter(
              value: usage.share,
              active: usage.share >= _nearlyUsedShare
                  ? DashboardColors.of(context).warn
                  : context.colorScheme.primary,
              track: DashboardColors.of(context).tone2,
            ),
          ),
        ),
      ],
    );
  }
}

/// The M3 Expressive wavy linear indicator: a wave up to [value], a gap,
/// then a flat track ending in a stop dot.
class WavyProgressPainter extends CustomPainter {
  const WavyProgressPainter({
    required this.value,
    required this.active,
    required this.track,
  });

  static const _stroke = 4.0;
  static const _amplitude = 3.0;
  static const _wavelength = 12.0;
  static const _gap = 6.0;
  static const _stop = 4.0;

  final double value;
  final Color active;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    const start = _stroke / 2;
    final end = size.width - _stroke / 2;
    final split = start + (end - start) * value;
    final paint = Paint()
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (value > 0) {
      final wave = Path()..moveTo(start, mid);
      for (var x = start; x <= split; x += 1) {
        wave.lineTo(
          x,
          mid + _amplitude * math.sin((x - start) / _wavelength * 2 * math.pi),
        );
      }
      canvas.drawPath(wave, paint..color = active);
    }
    final trackStart = value > 0 ? split + _gap + _stroke : start;
    if (trackStart < end - _stop) {
      canvas.drawLine(
        Offset(trackStart, mid),
        Offset(end - _stop - _gap, mid),
        paint..color = track,
      );
    }
    if (value < 1) {
      canvas.drawCircle(
        Offset(end - _stop / 2, mid),
        _stop / 2,
        Paint()..color = active,
      );
    }
  }

  @override
  bool shouldRepaint(WavyProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.active != active ||
      oldDelegate.track != track;
}
