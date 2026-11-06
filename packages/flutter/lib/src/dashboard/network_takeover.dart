// Derived from chen08209/FlClash, lib/views/dashboard/widgets/network_takeover.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'package:prism_ui/shapes/shapes.dart' show MaterialShapes;

typedef _RowMetrics = ({
  EdgeInsets padding,
  double titleStart,
  double radius,
  double icon,
  bool subtitle,
});

const _RowMetrics _cardRowMetrics = (
  padding: EdgeInsets.fromLTRB(10, 10, 12, 10),
  titleStart: 14,
  radius: 20,
  icon: 38,
  subtitle: true,
);

/// A tile's icon and switch sit as far in from its ends as from its edges, so
/// a full pill keeps both concentric with its corners. Without the icon, the
/// title lines up with the content of the cards above and below.
_RowMetrics _tileMetricsOf(DashboardDensity density) => density.isCompact
    ? (
        padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
        titleStart: dashboardCardPadding(density).left,
        radius: dashboardCardRadius(density),
        icon: 36,
        subtitle: false,
      )
    : (
        padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
        titleStart: dashboardCardPadding(density).left,
        radius: dashboardCardRadius(density),
        icon: 40,
        subtitle: true,
      );

enum TakeoverSwitch { systemProxy, tun }

class _TakeoverRow extends StatelessWidget {
  const _TakeoverRow({
    required this.kind,
    required this.value,
    required this.onChanged,
    required this.port,
    required this.metrics,
    required this.showIcon,
    this.color,
  });

  final TakeoverSwitch kind;
  final bool value;
  final ValueChanged<bool> onChanged;
  final int port;
  final _RowMetrics metrics;
  final bool showIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final systemProxy = kind == TakeoverSwitch.systemProxy;
    final title = _titleOf(context, kind);
    final on = systemProxy ? appLocalizations.portValue(port) : appLocalizations.enabled;
    final change = onChanged;
    return DashboardSwitchRow(
      glyph: systemProxy ? AppGlyphs.shuffle : AppGlyphs.vpn,
      title: title,
      subtitle: metrics.subtitle
          ? value
                ? on
                : appLocalizations.disabled
          : null,
      value: value,
      iconSize: metrics.icon,
      padding: showIcon
          ? metrics.padding
          : metrics.padding.copyWith(left: metrics.titleStart),
      radius: metrics.radius,
      color: color,
      showIcon: showIcon,
      onTap: () => change(!value),
      onChanged: change,
    );
  }
}

String _titleOf(BuildContext context, TakeoverSwitch kind) => switch (kind) {
  TakeoverSwitch.systemProxy => KitLocalizations.of(context).systemProxy,
  TakeoverSwitch.tun => KitLocalizations.of(context).tun,
};

/// Both switches in one card, for the card list of a narrow window.
class NetworkTakeoverCard extends StatelessWidget {
  const NetworkTakeoverCard({super.key, required this.systemProxy, required this.tun,
    required this.onSystemProxyChanged, required this.onTunChanged, this.port = 7890});
  final bool systemProxy;
  final bool tun;
  final int port;
  final ValueChanged<bool> onSystemProxyChanged;
  final ValueChanged<bool> onTunChanged;

  @override
  Widget build(BuildContext context) {
    const metrics = _cardRowMetrics;
    final appLocalizations = KitLocalizations.of(context);
    return DashboardCard(
      semanticLabel: appLocalizations.networkTakeover,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.shuffle,
            title: appLocalizations.networkTakeover,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final showIcon = DashboardSwitchRow.iconFits(
                context,
                width: constraints.maxWidth,
                iconSize: metrics.icon,
                padding: metrics.padding,
                titles: [
                  for (final kind in TakeoverSwitch.values)
                    _titleOf(context, kind),
                ],
              );
              return Column(
                spacing: 8,
                children: [
                  for (final kind in TakeoverSwitch.values)
                    _TakeoverRow(
                      kind: kind,
                      value: kind == TakeoverSwitch.systemProxy ? systemProxy : tun,
                      onChanged: kind == TakeoverSwitch.systemProxy ? onSystemProxyChanged : onTunChanged,
                      port: port,
                      metrics: metrics,
                      showIcon: showIcon,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One switch as a card of its own, in the desktop's control row.
class NetworkTakeoverTile extends StatelessWidget {
  const NetworkTakeoverTile(this.kind, {super.key, required this.value, required this.onChanged, this.port = 7890});

  final TakeoverSwitch kind;
  final bool value;
  final ValueChanged<bool> onChanged;
  final int port;

  @override
  Widget build(BuildContext context) {
    final metrics = _tileMetricsOf(DashboardDensityScope.of(context));
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) => _TakeoverRow(
          kind: kind,
          value: value,
          onChanged: onChanged,
          port: port,
          metrics: metrics,
          color: Colors.transparent,
          showIcon: DashboardSwitchRow.iconFits(
            context,
            width: constraints.maxWidth,
            iconSize: metrics.icon,
            padding: metrics.padding,
            titles: [
              for (final kind in TakeoverSwitch.values) _titleOf(context, kind),
            ],
          ),
        ),
      ),
    );
  }
}

/// The VPN switch in the grid's control row, in place of the takeover tiles.
class VpnTile extends StatelessWidget {
  const VpnTile({super.key, required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final metrics = _tileMetricsOf(DashboardDensityScope.of(context));

    return DashboardCard(
      padding: EdgeInsets.zero,
      child: DashboardSwitchRow(
        glyph: AppGlyphs.vpn,
        title: 'VPN',
        subtitle: metrics.subtitle
            ? enabled
                  ? appLocalizations.enabled
                  : appLocalizations.disabled
            : null,
        value: enabled,
        iconSize: metrics.icon,
        padding: metrics.padding,
        radius: metrics.radius,
        color: Colors.transparent,
        onTap: () => onChanged(!enabled),
        onChanged: onChanged,
      ),
    );
  }
}

class VpnCard extends StatelessWidget {
  const VpnCard({super.key, required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  static const _iconSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);

    final change = onChanged;
    return DashboardCard(
      semanticLabel: 'VPN',
      padding: dashboardCardPadding(
        DashboardDensityScope.of(context),
      ).copyWith(top: 16, bottom: 16),
      onTap: () => change(!enabled),
      child: Row(
        spacing: 14,
        children: [
          ShapeBadge(
            shape: enabled
                ? MaterialShapes.cookie6Sided
                : MaterialShapes.circle,
            color: enabled ? colorScheme.primary : colors.tone,
            size: _iconSize,
            child: GlyphIcon(
              AppGlyphs.vpn,
              size: 22,
              color: enabled
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VPN',
                  style: AppTextStyle.callout.of(context, emphasized: true),
                ),
                Text(
                  enabled
                      ? appLocalizations.enabled
                      : appLocalizations.disabled,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          DashboardSwitch(
            value: enabled,
            semanticLabel: 'VPN',
            onChanged: change,
          ),
        ],
      ),
    );
  }
}
