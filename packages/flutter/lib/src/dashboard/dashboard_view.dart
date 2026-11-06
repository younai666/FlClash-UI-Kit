// Derived from chen08209/FlClash, lib/views/dashboard/dashboard.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../localizations.dart';
import '../proxies/models.dart';
import '../scaffold/scaffold.dart';
import 'connections_table.dart';
import 'edit.dart';
import 'items.dart';
import 'layout.dart';
import 'style.dart';

class DashboardDesktopSlots {
  const DashboardDesktopSlots({
    required this.currentOutbound,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.outboundMode,
    required this.switches,
    required this.intranetIp,
    required this.profiles,
    required this.serviceStatusBuilder,
    required this.memoryInfo,
    required this.connectionsTable,
    required this.proxyGroups,
    required this.connectionStats,
    required this.proxyGroupsSummary,
  });

  final Widget currentOutbound;
  final Widget uploadSpeed;
  final Widget downloadSpeed;
  final Widget outboundMode;
  final List<(int span, Widget child)> switches;
  final Widget intranetIp;
  final Widget profiles;
  final Widget Function(int columns) serviceStatusBuilder;
  final Widget memoryInfo;
  final Widget connectionsTable;
  final Widget proxyGroups;
  final Widget connectionStats;
  final Widget proxyGroupsSummary;
}

// Narrower columns leave a pair of service cells too tight for a status, so
// the grid stacks them in one.
const _servicePairColumnMin = 290.0;

const _maxColumnWidth = 440.0;

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    required this.desktopSlots,
    required this.mobileWidgets,
    required this.availableMobileWidgets,
    required this.onMobileWidgetsChanged,
    this.updateStatusButton,
    this.coreStatusButton,
    this.mobileUpdateSlotBuilder,
    this.sideWidth = 0,
    this.gap,
  });

  final DashboardDesktopSlots desktopSlots;
  final List<DashboardItem> mobileWidgets;
  final List<DashboardItem> availableMobileWidgets;
  final ValueChanged<List<DashboardItem>> onMobileWidgetsChanged;
  final Widget? updateStatusButton;
  final Widget? coreStatusButton;
  final Widget Function(double gap)? mobileUpdateSlotBuilder;
  final double sideWidth;
  final double? gap;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  var _editing = false;
  final _cardKeys = <DashboardItem, GlobalKey>{};

  void _setEditing(bool editing) {
    setState(() => _editing = editing);
  }

  GlobalKey _cardKeyOf(DashboardItem item) =>
      _cardKeys.putIfAbsent(item, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final viewSize = ViewScope.sizeOf(context);
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    final size =
        Size(math.max(0, viewSize.width - widget.sideWidth), viewSize.height) /
        scale;
    final editable = !DashboardDensity.of(size).isDesktop;
    if (!editable) {
      _editing = false;
    }
    final editing = _editing;
    final gap =
        widget.gap ?? cardSpacingOf(context, getViewMode(viewSize.width));
    final appLocalizations = KitLocalizations.of(context);
    return Scaffold(
      backgroundColor: DashboardColors.of(context).page,
      title: editing
          ? appLocalizations.editDashboard
          : appLocalizations.dashboard,
      actions: [
        if (!editable && widget.updateStatusButton != null)
          widget.updateStatusButton!,
        if (!editing && widget.coreStatusButton != null)
          widget.coreStatusButton!,
      ],
      confirmationAction: editing
          ? IconButtonData(
              glyph: AppGlyphs.check,
              tooltip: appLocalizations.done,
              onPressed: () => _setEditing(false),
            )
          : null,
      iconActions: [
        if (editable && !editing)
          IconButtonData(
            glyph: AppGlyphs.edit,
            tooltip: appLocalizations.editDashboard,
            onPressed: () => _setEditing(true),
          ),
      ],
      // The providers learn a resize a frame late, too late for the cards.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final room = constraints.biggest / scale;
          final layout = DashboardDensity.of(room);
          return DashboardDensityScope(
            density: layout,
            scale: scale,
            child: layout.isDesktop
                ? _DesktopDashboard(
                    slots: widget.desktopSlots,
                    columns: dashboardColumnsOf(room.width),
                    gap: gap,
                  )
                : _MobileDashboard(
                    widgets: widget.mobileWidgets,
                    available: widget.availableMobileWidgets,
                    onChanged: widget.onMobileWidgetsChanged,
                    updateSlotBuilder: widget.mobileUpdateSlotBuilder,
                    gap: gap,
                    editing: editing,
                    cardKeyOf: _cardKeyOf,
                    onDone: () => _setEditing(false),
                  ),
          );
        },
      ),
    );
  }
}

/// Four columns fill the window, the tables taking what the rows above them
/// leave. A window too short for the tables, and every two column one, gets
/// the summary cards instead, so no list scrolls inside a page that scrolls.
class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.slots,
    required this.columns,
    required this.gap,
  });

  final DashboardDesktopSlots slots;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);
    final base = EdgeInsetsDirectional.fromSTEB(
      16,
      context.contentTopPadding,
      24,
      24 + MediaQuery.paddingOf(context).bottom,
    );
    final topHeight = (compact ? 176 : 208) * scale;
    final controlHeight = (compact ? 56 : 64) * scale;
    final middleHeight = (compact ? 152 : 176) * scale;
    final tablesHeight = connectionsTableMinHeight(density, scale);
    final summaryHeight = (compact ? 112 : 120) * scale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final room =
            constraints.maxWidth - base.horizontal - gap * (columns - 1);
        final column = math.min(room / columns, _maxColumnWidth * scale);
        final inset = (room - column * columns) / 2;
        final padding = base.copyWith(
          start: base.start + inset,
          end: base.end + inset,
        );
        double span(int columns) => column * columns + gap * (columns - 1);
        Widget row(List<(int, Widget)> cards) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (final (columns, card) in cards)
              SizedBox(
                width: span(columns),
                child: RepaintBoundary(child: card),
              ),
          ],
        );
        Widget sized(double height, Widget child) =>
            SizedBox(height: height, child: child);
        final switches = slots.switches;
        final half = columns ~/ 2;
        final summaries = row([
          (half, slots.connectionStats),
          (half, slots.proxyGroupsSummary),
        ]);
        if (columns == 2) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: Column(
              spacing: gap,
              children: [
                sized(
                  topHeight,
                  RepaintBoundary(child: slots.currentOutbound),
                ),
                sized(
                  topHeight,
                  row([
                    (1, slots.uploadSpeed),
                    (1, slots.downloadSpeed),
                  ]),
                ),
                sized(
                  controlHeight,
                  RepaintBoundary(child: slots.outboundMode),
                ),
                sized(controlHeight, row(switches)),
                sized(
                  middleHeight,
                  row([(1, slots.intranetIp), (1, slots.profiles)]),
                ),
                sized(
                  middleHeight,
                  row([
                    (
                      1,
                      slots.serviceStatusBuilder(
                        column >= _servicePairColumnMin * scale ? 2 : 1,
                      ),
                    ),
                    (1, slots.memoryInfo),
                  ]),
                ),
                sized(summaryHeight, summaries),
              ],
            ),
          );
        }
        final rows = [
          sized(
            topHeight,
            row([
              (2, slots.currentOutbound),
              (1, slots.uploadSpeed),
              (1, slots.downloadSpeed),
            ]),
          ),
          sized(
            controlHeight,
            row([(2, slots.outboundMode), ...switches]),
          ),
          sized(
            middleHeight,
            row([
              (1, slots.intranetIp),
              (1, slots.profiles),
              (
                1,
                slots.serviceStatusBuilder(
                  column >= _servicePairColumnMin * scale ? 2 : 1,
                ),
              ),
              (1, slots.memoryInfo),
            ]),
          ),
        ];
        final rowsHeight =
            padding.vertical +
            topHeight +
            controlHeight +
            middleHeight +
            gap * 3;
        final tablesFit = constraints.maxHeight >= rowsHeight + tablesHeight;
        final fills = constraints.maxHeight >= rowsHeight + summaryHeight;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: fills ? constraints.maxHeight : null,
            child: Padding(
              padding: padding,
              child: Column(
                spacing: gap,
                children: [
                  ...rows,
                  if (tablesFit)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: gap,
                        children: [
                          Expanded(
                            flex: 3,
                            child: RepaintBoundary(
                              child: slots.connectionsTable,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RepaintBoundary(child: slots.proxyGroups),
                          ),
                        ],
                      ),
                    )
                  else if (fills)
                    Expanded(child: summaries)
                  else
                    sized(summaryHeight, summaries),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({
    required this.widgets,
    required this.available,
    required this.onChanged,
    required this.updateSlotBuilder,
    required this.gap,
    required this.editing,
    required this.cardKeyOf,
    required this.onDone,
  });

  final List<DashboardItem> widgets;
  final List<DashboardItem> available;
  final ValueChanged<List<DashboardItem>> onChanged;
  final Widget Function(double gap)? updateSlotBuilder;
  final double gap;
  final bool editing;
  final GlobalKey Function(DashboardItem item) cardKeyOf;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final top = context.contentTopPadding;
    final bottom = 16 + context.bottomInset;
    final cacheCount = math.max(1, available.length).toDouble();
    return CustomScrollView(
      // A viewport per card lays them all out and holds the scroll end still.
      scrollCacheExtent: editing ? ScrollCacheExtent.viewport(cacheCount) : null,
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final side = dashboardMobileSideOf(constraints.crossAxisExtent);
            if (editing) {
              return DashboardEditor(
                available: available,
                onChanged: onChanged,
                widgets: widgets,
                cardKeyOf: cardKeyOf,
                padding: EdgeInsets.fromLTRB(side, top, side, bottom),
                gap: gap,
                onDone: onDone,
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(side, top, side, bottom),
              // A lazy list estimates the cards it has not laid out from the
              // ones it has; cards this uneven move the scroll end as it goes.
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (updateSlotBuilder != null) updateSlotBuilder!(gap),
                    Column(
                      spacing: gap,
                      children: [
                        for (final widget in widgets)
                          RepaintBoundary(
                            key: cardKeyOf(widget),
                            child: widget.card,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
