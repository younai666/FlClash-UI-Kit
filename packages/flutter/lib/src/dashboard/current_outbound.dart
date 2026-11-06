// Derived from chen08209/FlClash, lib/views/dashboard/widgets/current_outbound.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:math' as math;
















import 'package:flutter/widgets.dart';

import 'package:prism_ui/shapes/shapes.dart';

import 'card.dart';
import 'layout.dart';
import 'style.dart';
import '../data.dart';
import '../datetime.dart';
import '../localizations.dart';
import '../../icons.dart';
import 'package:prism_ui/prism_ui.dart';

const _builtinOutbounds = {'DIRECT', 'REJECT', 'REJECT-DROP', 'PASS'};

bool isBuiltinOutbound(String name) => _builtinOutbounds.contains(name);

const _ipMask = '*****';

const _decorationGrowth = 0.12;

const _decorationTurn = 2 * math.pi / 12;

/// Original status-card presentation, without network probes or services.
class CurrentOutboundCard extends StatelessWidget {
  const CurrentOutboundCard({super.key, required this.onToggle, required this.onRefresh,
    this.info, this.quality, this.enabled = true, this.running = false,
    this.suspended = false, this.rootAccess = false, this.loading = false,
    this.failed = false, this.checking = false, this.hideIp = false,
    this.runTime, this.onDetails});
  final OutboundInfo? info;
  final OutboundQuality? quality;
  final bool enabled, running, suspended, rootAccess, loading, failed, checking, hideIp;
  final int? runTime;
  final VoidCallback onToggle, onRefresh;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final hasProfile = enabled;
    final isStart = running;
    final ipInfo = info;
    final metrics = _OutboundMetrics.of(density);
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final (chipLabel, chipTone) = suspended
        ? (appLocalizations.suspended, DashboardChipTone.warn)
        : isStart
        ? (appLocalizations.running, DashboardChipTone.ok)
        : (appLocalizations.notRunning, DashboardChipTone.idle);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: rootAccess ? 1 : 0),
      duration: context.motionDuration(commonDuration),
      builder: (context, root, child) => DashboardCard(
        padding: EdgeInsets.zero,
        semanticLabel: rootAccess
            ? '${appLocalizations.status} ${appLocalizations.root}'
            : appLocalizations.status,
        side: root == 0
            ? BorderSide.none
            : BorderSide(
                color: context.colorScheme.primary.withValues(alpha: root),
                width: 1.5,
              ),
        child: child!,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: AppShape.all(dashboardCardRadius(density)),
                textDirection: Directionality.of(context),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    end: metrics.decorationEnd,
                    top: metrics.decorationTop,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: isStart ? 1 : 0),
                      duration: context.motionDuration(_morphDuration),
                      curve: Curves.easeOutBack,
                      builder: (_, progress, _) => Transform.rotate(
                        angle: _decorationTurn * progress,
                        child: Transform.scale(
                          scale: 1 + _decorationGrowth * progress,
                          child: ShapeBadge(
                            shape: MaterialShapes.cookie12Sided,
                            color: Color.lerp(
                              colors.tone,
                              Color.alphaBlend(
                                colorScheme.primary.withValues(alpha: 0.1),
                                colors.card,
                              ),
                              progress.clamp(0, 1),
                            )!,
                            size: metrics.decorationSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: metrics.padding,
            child: Row(
              spacing: metrics.gap,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardCardHeader(
                        glyph: AppGlyphs.status,
                        title: appLocalizations.status,
                        leading: [
                          DashboardChip(
                            label: chipLabel,
                            tone: chipTone,
                            dot: isStart,
                          ),
                        ],
                      ),
                      SizedBox(height: metrics.ipTop),
                      _ExitRow(
                        info: ipInfo,
                        failed: failed,
                        loading: loading,
                        checking: checking,
                        hideIp: hideIp,
                        onDetails: onDetails,
                        onRefresh: onRefresh,
                        quality: quality,
                        active: isStart,
                        metrics: metrics,
                        large: !density.isDesktop,
                      ),
                      if (density.isDesktop)
                        const Spacer()
                      else
                        const SizedBox(height: 16),
                      _Cells(
                        quality: quality,
                        loading: loading,
                        active: isStart && !suspended,
                        runTime: runTime,
                        gap: metrics.cellGap,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: metrics.buttonSlot,
                  child: Center(
                    child: RunningToggle(
                      size: metrics.buttonSize,
                      enabled: hasProfile,
                      running: isStart,
                      suspended: suspended,
                      onToggle: onToggle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutboundMetrics {
  const _OutboundMetrics({
    required this.padding,
    required this.gap,
    required this.ipTop,
    required this.cellGap,
    required this.badgeSize,
    required this.ip,
    required this.buttonSize,
    required this.buttonSlot,
    required this.decorationSize,
    required this.decorationEnd,
    required this.decorationTop,
  });

  factory _OutboundMetrics.of(DashboardDensity density) => switch (density) {
    DashboardDensity.standard => _OutboundMetrics(
      padding: dashboardCardPadding(density),
      gap: 16,
      ipTop: 10,
      cellGap: 28,
      badgeSize: 48,
      ip: AppTextStyle.title1,
      buttonSize: 104,
      buttonSlot: 120,
      decorationSize: 290,
      decorationEnd: -64,
      decorationTop: -87,
    ),
    DashboardDensity.compact => _OutboundMetrics(
      padding: dashboardCardPadding(density),
      gap: 16,
      ipTop: 8,
      cellGap: 22,
      badgeSize: 40,
      ip: AppTextStyle.title2,
      buttonSize: 84,
      buttonSlot: 100,
      decorationSize: 250,
      decorationEnd: -64,
      decorationTop: -75,
    ),
    DashboardDensity.mobile => const _OutboundMetrics(
      padding: EdgeInsetsDirectional.fromSTEB(20, 18, 16, 18),
      gap: 10,
      ipTop: 12,
      cellGap: 24,
      badgeSize: 48,
      ip: AppTextStyle.title2,
      buttonSize: 88,
      buttonSlot: 88,
      decorationSize: 240,
      decorationEnd: -60,
      decorationTop: -66,
    ),
  };

  final EdgeInsetsGeometry padding;
  final double gap;
  final double ipTop;
  final double cellGap;
  final double badgeSize;
  final AppTextStyle ip;
  final double buttonSize;
  final double buttonSlot;
  final double decorationSize;
  final double decorationEnd;
  final double decorationTop;
}

class _ExitRow extends StatelessWidget {
  const _ExitRow({
    required this.info,
    required this.failed,
    required this.loading,
    required this.checking,
    required this.onRefresh,
    required this.hideIp,
    this.onDetails,
    required this.quality,
    required this.active,
    required this.metrics,
    required this.large,
  });

  final OutboundInfo? info;
  final bool hideIp;
  final VoidCallback? onDetails;
  final bool failed;
  final bool loading;
  final bool checking;
  final VoidCallback onRefresh;
  final OutboundQuality? quality;
  final bool active;
  final _OutboundMetrics metrics;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = DashboardText.figure(
      context,
      metrics.ip,
      color: active ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
    ).copyWith(letterSpacing: 0);
    final info = this.info;
    final appLocalizations = KitLocalizations.of(context);
    final Widget ip = info != null
        ? Tooltip(
            message: appLocalizations.details(appLocalizations.outboundIp),
            child: FocusRing(
              shape: AppShape.xs,
              standsOff: true,
              child: PressRegion(
                onTap: onDetails,
                shape: AppShape.xs,
                overlay: PressRegion.focusOverlay,
                child: _IpText(ip: info.ip, style: style, hideIp: hideIp),
              ),
            ),
          )
        : failed
        ? Text(
            appLocalizations.serviceFailed,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: colorScheme.error),
          )
        : SkeletonText(width: 140, style: style);
    return Row(
      spacing: 12,
      children: [
        _CountryBadge(
          countryCode: info?.countryCode,
          size: metrics.badgeSize,
          active: active,
          checking: checking,
          onRefresh: onRefresh,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    metrics.ip.leading * DashboardDensityScope.scaleOf(context),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ip,
                ),
              ),
              const SizedBox(height: 4),
              if (failed)
                SizedBox(
                  height: _chipHeight(large),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      appLocalizations.tapIconToRetry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DashboardText.label(context),
                    ),
                  ),
                )
              else
                _IpChips(quality: quality, loading: loading, large: large),
            ],
          ),
        ),
      ],
    );
  }
}

class _IpText extends StatelessWidget {
  const _IpText({required this.ip, required this.style, required this.hideIp});
  final bool hideIp;

  final String ip;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return DashboardFitText(hideIp ? _ipMask : ip, style: style);
  }
}

double _chipHeight(bool large) => large ? 28 : 24;

const _chipSkeletonWidths = [48.0, 72.0];

class _IpChips extends StatelessWidget {
  const _IpChips({
    required this.quality,
    required this.loading,
    required this.large,
  });

  final OutboundQuality? quality;
  final bool loading;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final quality = this.quality;
    final height = _chipHeight(large);
    // Chips that do not fit wrap onto a clipped second line; the details
    // sheet still lists them all.
    return SizedBox(
      height: height,
      child: ClipRect(
        child: Wrap(
          spacing: 6,
          runSpacing: height,
          children: switch (quality) {
            final quality? => [
              DashboardChip(label: quality.typeLabel, large: large),
              DashboardChip(
                label:
                    '${KitLocalizations.of(context).ipQualityShort} ${quality.levelLabel}',
                tone: switch (quality.level) {
                  OutboundQualityLevel.good => DashboardChipTone.ok,
                  OutboundQualityLevel.normal => DashboardChipTone.idle,
                  OutboundQualityLevel.risky => DashboardChipTone.warn,
                },
                large: large,
              ),
            ],
            null when loading => [
              for (final width in _chipSkeletonWidths)
                SkeletonPill(width: width, height: height),
            ],
            null => [
              DashboardChip(
                label: KitLocalizations.of(context).ipTypeUnknown,
                large: large,
              ),
            ],
          },
        ),
      ),
    );
  }
}

const _spinPeriod = Duration(milliseconds: 1500);

/// The exit's country on a clover that checks the exit again when tapped and
/// turns while it is being checked.
class _CountryBadge extends StatefulWidget {
  const _CountryBadge({
    required this.countryCode,
    required this.size,
    required this.active,
    required this.checking,
    required this.onRefresh,
  });

  final String? countryCode;
  final double size;
  final bool active;
  final bool checking;
  final VoidCallback onRefresh;

  @override
  State<_CountryBadge> createState() => _CountryBadgeState();
}

class _CountryBadgeState extends State<_CountryBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: _spinPeriod,
  );
  var _hovered = false;
  var _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _spin();
  }

  @override
  void didUpdateWidget(_CountryBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checking != widget.checking) {
      _spin();
    }
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  void _spin() {
    if (context.disableAnimations) {
      _turns.value = 0;
    } else if (widget.checking) {
      _turns.repeat();
    } else {
      // A clover looks the same every quarter turn, so it stops on the next.
      final rest = (_turns.value * 4).ceil() / 4;
      _turns.animateTo(rest, duration: _spinPeriod * (rest - _turns.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foreground = widget.active
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final enabled = !widget.checking;
    final size = widget.size;
    final code = widget.countryCode;
    final tooltip = KitLocalizations.of(context).retry;
    final color = Color.alphaBlend(
      foreground.withValues(alpha: enabled && _hovered ? 0.08 : 0),
      DashboardColors.of(context).tone2,
    );
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: PressRegion(
          onTap: enabled ? widget.onRefresh : null,
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          child: ElasticPress(
            enabled: enabled,
            child: AnimatedBuilder(
              animation: _turns,
              builder: (_, child) => ShapeBadge(
                shape: MaterialShapes.clover4Leaf,
                color: color,
                size: size,
                rotation: _turns.value * 2 * math.pi,
                ring: _focused ? focusRingSide(colorScheme) : null,
                child: child,
              ),
              child: code == null || code.isEmpty
                  ? GlyphIcon(
                      AppGlyphs.proxies,
                      size: size * 0.42,
                      color: foreground,
                    )
                  : Text(
                      code.toUpperCase(),
                      maxLines: 1,
                      style: AppTextStyle.footnote
                          .of(context, emphasized: true)
                          .copyWith(
                            color: foreground,
                            letterSpacing: 0.04 * AppTextStyle.footnote.size,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cells extends StatelessWidget {
  const _Cells({
    required this.quality,
    required this.loading,
    required this.active,
    required this.gap,
    this.runTime,
  });

  final OutboundQuality? quality;
  final bool loading;
  final bool active;
  final double gap;
  final int? runTime;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final organization = switch (quality) {
      OutboundQuality(organization: final name?) when name.isNotEmpty => name,
      OutboundQuality(asn: final asn?) => 'AS$asn',
      _ => null,
    };
    return Row(
      spacing: gap,
      children: [
        _Cell(
          label: appLocalizations.runTime,
          value: active ? _RunTimeValue(runTime) : const _Placeholder(),
        ),
        Flexible(
          child: _Cell(
            label: appLocalizations.ipOrganization,
            value: organization != null
                ? _CellText(organization)
                : loading
                ? SkeletonText(width: 96, style: _cellStyle(context))
                : const _Placeholder(),
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DashboardText.label(context),
        ),
        const SizedBox(height: 2),
        value,
      ],
    );
  }
}

TextStyle _cellStyle(BuildContext context) =>
    AppTextStyle.subheadline.of(context, emphasized: true).toTabular;

class _CellText extends StatelessWidget {
  const _CellText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _cellStyle(context),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Text('—', maxLines: 1, style: _cellStyle(context));
  }
}

class _RunTimeValue extends StatelessWidget {
  const _RunTimeValue(this.runTime);
  final int? runTime;

  @override
  Widget build(BuildContext context) {
    return _CellText(getTimeText(runTime));
  }
}

const _morphDuration = Duration(milliseconds: 450);
const _stateDuration = Duration(milliseconds: 150);

final _startMorph = Morph(MaterialShapes.circle, MaterialShapes.cookie9Sided);

Path _morphPath(double progress) => _startMorph.toPath(progress: progress);

double _morphTurn(double progress) => progress * 2 * math.pi / 9;

/// A circle with a play glyph while stopped that grows the cookie-9 of a
/// running tunnel, the way the M3 Expressive loader morphs between shapes.
class RunningToggle extends StatefulWidget {
  const RunningToggle({
    super.key,
    required this.size,
    required this.enabled,
    required this.running,
    required this.suspended,
    required this.onToggle,
  });

  final double size;
  final bool enabled;
  final bool running;
  final bool suspended;
  final VoidCallback onToggle;

  @override
  State<RunningToggle> createState() => _RunningToggleState();
}

class _RunningToggleState extends State<RunningToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _morphDuration,
    value: widget.running ? 1 : 0,
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );
  var _hovered = false;
  var _pressed = false;
  var _focused = false;

  /// The M3 state layer, painted inside the shape: the card's decoration
  /// covers the button, so ink on the card would never show.
  double get _overlay => !widget.enabled
      ? 0
      : _focused
      ? 0.1
      : _hovered
      ? 0.08
      : 0;

  @override
  void didUpdateWidget(RunningToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) {
      widget.running ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = KitLocalizations.of(context);
    final glass = LiquidGlassScope.of(context);
    final size = widget.size;
    final enabled = widget.enabled;
    final fill = enabled
        ? colorScheme.primary
        : DashboardColors.of(context).tone2;
    final ink = enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final tooltip = widget.suspended
        ? appLocalizations.suspended
        : widget.running
        ? appLocalizations.stop
        : appLocalizations.start;
    final stateDuration = context.motionDuration(_stateDuration);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: PressRegion(
          onTap: enabled ? _toggle : null,
          onHover: (value) => setState(() => _hovered = value),
          onPressedChanged: (value) => setState(() => _pressed = value),
          onFocusChange: (value) => setState(() => _focused = value),
          child: ElasticPress(
            enabled: enabled,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _overlay),
              duration: stateDuration,
              builder: (_, overlay, child) => AnimatedBuilder(
                animation: _progress,
                builder: (_, child) {
                  final progress = _progress.value;
                  final color = Color.alphaBlend(
                    ink.withValues(alpha: overlay),
                    fill,
                  );
                  return CustomPaint(
                    painter: _MorphPainter(
                      progress: progress,
                      color: glass ? null : color,
                      shadow: enabled
                          ? colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                      ring: _focused
                          ? focusRingSide(colorScheme, standsOff: true)
                          : null,
                    ),
                    child: glass
                        ? LiquidGlass(
                            style: LiquidGlassStyle.tinted(colorScheme, color),
                            clipper: _MorphClipper(progress),
                            pressed: _pressed,
                            child: child,
                          )
                        : child,
                  );
                },
                child: child,
              ),
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: widget.suspended
                      ? GlyphIcon(
                          AppGlyphs.wifiOff,
                          size: size * 0.34,
                          color: ink,
                          fill: 1,
                        )
                      : TweenAnimationBuilder<double>(
                          tween: Tween(end: widget.running ? 1 : 0),
                          duration: _morphDuration,
                          curve: Curves.easeOutBack,
                          builder: (_, progress, _) => GlyphIcon(
                            AppGlyphs.playPause(progress),
                            size: size * 0.34,
                            color: ink,
                            fill: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fills the morph, or with no [color] leaves its inside to glass and casts
/// [shadow] only outside it, as one under glass would show through.
class _MorphPainter extends CustomPainter {
  const _MorphPainter({
    required this.progress,
    required this.color,
    required this.shadow,
    required this.ring,
  });

  static const _shadowOffset = Offset(0, 6);
  static const _shadowBlur = 14.0;

  final double progress;
  final Color? color;
  final Color shadow;
  final BorderSide? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _morphPath(progress);
    final color = this.color;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_morphTurn(progress))
      ..scale(size.width, size.height)
      ..translate(-0.5, -0.5);
    if (shadow.a > 0) {
      canvas.save();
      if (color == null) {
        canvas.clipPath(
          Path()
            ..fillType = PathFillType.evenOdd
            ..addRect(const Rect.fromLTRB(-1, -1, 2, 2))
            ..addPath(path, Offset.zero),
        );
      }
      canvas
        ..translate(
          _shadowOffset.dx / size.width,
          _shadowOffset.dy / size.height,
        )
        ..drawPath(
          path,
          Paint()
            ..color = shadow
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              _shadowBlur / 2 / size.width,
            ),
        )
        ..restore();
    }
    if (color != null) {
      canvas.drawPath(path, Paint()..color = color);
    }
    if (ring case final ring?) {
      strokeUnitShape(canvas, path, size.width, ring);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.shadow != shadow ||
      oldDelegate.ring != ring;
}

class _MorphClipper extends CustomClipper<Path> {
  const _MorphClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final transform =
        Matrix4.translationValues(size.width / 2, size.height / 2, 0)
          ..rotateZ(_morphTurn(progress))
          ..scaleByDouble(size.width, size.height, 1, 1)
          ..translateByDouble(-0.5, -0.5, 0, 1);
    return _morphPath(progress).transform(transform.storage);
  }

  @override
  bool shouldReclip(_MorphClipper oldClipper) =>
      oldClipper.progress != progress;
}
