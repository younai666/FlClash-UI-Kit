// Derived from chen08209/FlClash, lib/views/dashboard/widgets/connections_table.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../datetime.dart';
import '../localizations.dart';
import '../records/connection_models.dart';
import '../records/dns_queries_view.dart';
import '../records/requests_view.dart';
import '../records/tracker_info_table.dart';
import '../widgets/active_polling.dart';
import '../widgets/record_table.dart';
import 'card.dart';
import 'current_outbound.dart';
import 'layout.dart';
import 'style.dart';

/// Enough to fill the tallest card several times over; the full feed is a
/// tap away.
const _maxFeedRows = 100;
const _midTableWidth = 620.0;
const _wideTableWidth = 880.0;
const _cellInset = 8.0;
const _tableGap = 12.0;
const _headerHeight = 32.0;
const _minRows = 3;

double _tabHeightOf(DashboardDensity density) => density.isCompact ? 32 : 36;

double _rowHeightOf(DashboardDensity density) => density.isCompact ? 32 : 34;

/// Keeps the pill tabs concentric with the card's corners.
double _tabInsetOf(DashboardDensity density) =>
    dashboardCardRadius(density) - _tabHeightOf(density) / 2;

double connectionsTableTop(DashboardDensity density, double scale) =>
    _tabInsetOf(density) + _tabHeightOf(density) * scale + _tableGap;

/// The grid gives the tables a row once they can show their head and a few
/// connections; shorter, it shows the summary cards.
double connectionsTableMinHeight(DashboardDensity density, double scale) =>
    connectionsTableTop(density, scale) +
    (_headerHeight + _rowHeightOf(density) * _minRows) * scale;

enum DashboardFeed {
  connections,
  requests,
  dns;

  String labelOf(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return switch (this) {
      connections => appLocalizations.liveConnections,
      requests => appLocalizations.recentRequests,
      dns => 'DNS',
    };
  }
}

void openDashboardFeed(
  BuildContext context,
  DashboardFeed feed, {
  List<TrackerInfo> requests = const [],
  ValueListenable<List<TrackerInfo>>? requestsListenable,
  Future<List<TrackerInfo>> Function()? connectionsReader,
  Future<void> Function(TrackerInfo connection)? onCloseConnection,
  Future<void> Function()? onCloseAllConnections,
  List<DnsQuery> dnsQueries = const [],
  ValueListenable<List<DnsQuery>>? dnsQueriesListenable,
  Future<void> Function()? onClearDnsCache,
}) {
  showSnapSheet(
    context,
    initialScrollOffset: feed == DashboardFeed.connections
        ? 0
        : double.maxFinite,
    builder: (_, controller) => NestedPagedSheet(
      builder: (_) => switch (feed) {
        DashboardFeed.connections => RequestsView(
          scrollController: controller,
          initialFeed: RequestFeed.live,
          requests: requests,
          requestsListenable: requestsListenable,
          connectionsReader: connectionsReader,
          onCloseConnection: onCloseConnection,
          onCloseAllConnections: onCloseAllConnections,
        ),
        DashboardFeed.requests => RequestsView(
          scrollController: controller,
          initialFeed: RequestFeed.recent,
          requests: requests,
          requestsListenable: requestsListenable,
          connectionsReader: connectionsReader,
          onCloseConnection: onCloseConnection,
          onCloseAllConnections: onCloseAllConnections,
        ),
        DashboardFeed.dns => DnsQueriesView(
          scrollController: controller,
          dnsQueries: dnsQueries,
          dnsQueriesListenable: dnsQueriesListenable,
          onClearDnsCache: onClearDnsCache,
        ),
      },
    ),
  );
}

/// Polls the live connections while the dashboard is shown: the whole list
/// while its table is open, only the count otherwise.
mixin ConnectionsPolling<T extends StatefulWidget>
    on
        State<T>,
        WidgetsBindingObserver,
        ActivePollingMixin<T>,
        RouteMotionHoldMixin<T> {
  final connectionCount = ValueNotifier(0);
  List<TrackerInfo> connections = const [];
  var tcpCount = 0;
  var udpCount = 0;

  bool get pollsConnections;
  bool get isCoreConnected;
  Future<List<TrackerInfo>> Function()? get connectionsReader;
  Future<int> Function()? get connectionCountReader;
  List<TrackerInfo> get seededConnections => const [];
  int get seededConnectionCount => seededConnections.length;

  void syncSeededConnections() {
    if (connectionsReader == null && connectionCountReader == null) {
      if (!isCoreConnected) {
        connectionCount.value = 0;
        connections = const [];
        tcpCount = 0;
        udpCount = 0;
        return;
      }
      final next = [...seededConnections]
        ..sort((a, b) => b.start.compareTo(a.start));
      final tcp = next
          .where((item) => item.metadata.network.toLowerCase() == 'tcp')
          .length;
      connections = next;
      tcpCount = tcp;
      udpCount = next.length - tcp;
      connectionCount.value = next.isNotEmpty
          ? next.length
          : seededConnectionCount;
    }
  }

  @override
  Duration get pollInterval => Duration(seconds: pollsConnections ? 1 : 2);

  @override
  void dispose() {
    connectionCount.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    if (connectionsReader == null && connectionCountReader == null) {
      return;
    }
    if (!isCoreConnected) {
      connectionCount.value = 0;
      if (connections.isNotEmpty && isCurrent()) {
        updateWhenRouteSettled(
          () => setState(() {
            connections = const [];
            tcpCount = 0;
            udpCount = 0;
          }),
        );
      }
      return;
    }
    try {
      if (pollsConnections && connectionsReader != null) {
        final next = [...await connectionsReader!()];
        if (!isCurrent()) return;
        next.sort((a, b) => b.start.compareTo(a.start));
        final tcp = next
            .where((item) => item.metadata.network.toLowerCase() == 'tcp')
            .length;
        connectionCount.value = next.length;
        updateWhenRouteSettled(
          () => setState(() {
            connections = next;
            tcpCount = tcp;
            udpCount = next.length - tcp;
          }),
        );
      } else if (connectionCountReader != null) {
        final count = await connectionCountReader!();
        if (!isCurrent()) return;
        connectionCount.value = count;
      } else if (connectionsReader != null) {
        final next = await connectionsReader!();
        if (!isCurrent()) return;
        connectionCount.value = next.length;
      }
    } catch (error) {
      debugPrint('dashboard connections error: $error');
    }
  }
}

/// Follows a counter the Core moves per event, at the cadence the feed's own
/// list repaints at.
class ThrottledCount extends StatefulWidget {
  const ThrottledCount({
    super.key,
    required this.listenable,
    required this.builder,
  });

  final ValueListenable<int> listenable;
  final Widget Function(BuildContext context, int count) builder;

  @override
  State<ThrottledCount> createState() => _ThrottledCountState();
}

class _ThrottledCountState extends State<ThrottledCount> {
  late var _count = widget.listenable.value;
  late var _latest = _count;
  Timer? _repaint;
  var _active = true;

  void _onChanged() {
    _latest = widget.listenable.value;
    if (!_active) {
      return;
    }
    _repaint ??= Timer(renderThrottleDuration, _showLatest);
  }

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(ThrottledCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChanged);
      widget.listenable.addListener(_onChanged);
      _latest = widget.listenable.value;
      if (_active) {
        _count = _latest;
      }
    }
  }

  void _showLatest() {
    _repaint = null;
    setState(() => _count = _latest);
  }

  // A card can stay deactivated across timer ticks; a repaint there throws.
  @override
  void deactivate() {
    _active = false;
    _repaint?.cancel();
    _repaint = null;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _active = true;
    _count = _latest;
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    _repaint?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _count);
}

class ConnectionsTableCard extends StatefulWidget {
  const ConnectionsTableCard({
    super.key,
    this.connected = true,
    this.connections = const [],
    this.connectionsReader,
    this.connectionCountReader,
    this.requests = const [],
    this.requestsListenable,
    this.requestCountListenable,
    this.dnsQueries = const [],
    this.dnsQueriesListenable,
    this.dnsQueryCountListenable,
    this.initialColumnWidthsOf,
    this.onColumnWidthsChanged,
  });

  final bool connected;
  final List<TrackerInfo> connections;
  final Future<List<TrackerInfo>> Function()? connectionsReader;
  final Future<int> Function()? connectionCountReader;
  final List<TrackerInfo> requests;
  final ValueListenable<List<TrackerInfo>>? requestsListenable;
  final ValueListenable<int>? requestCountListenable;
  final List<DnsQuery> dnsQueries;
  final ValueListenable<List<DnsQuery>>? dnsQueriesListenable;
  final ValueListenable<int>? dnsQueryCountListenable;
  final Map<String, double> Function(String tableId)? initialColumnWidthsOf;
  final void Function(String tableId, Map<String, double> widths)?
  onColumnWidthsChanged;

  @override
  State<ConnectionsTableCard> createState() => _ConnectionsTableCardState();
}

class _ConnectionsTableCardState extends State<ConnectionsTableCard>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<ConnectionsTableCard>,
        RouteMotionHoldMixin<ConnectionsTableCard>,
        ConnectionsPolling<ConnectionsTableCard> {
  var _feed = DashboardFeed.connections;
  List<TrackerInfo> _requests = const [];
  List<DnsQuery> _queries = const [];
  Timer? _snapshot;

  @override
  bool get pollsConnections => _feed == DashboardFeed.connections;

  @override
  bool get isCoreConnected => widget.connected;

  @override
  Future<List<TrackerInfo>> Function()? get connectionsReader =>
      widget.connectionsReader;

  @override
  Future<int> Function()? get connectionCountReader =>
      widget.connectionCountReader;

  @override
  List<TrackerInfo> get seededConnections => widget.connections;

  List<TrackerInfo> get _sourceRequests =>
      widget.requestsListenable?.value ?? widget.requests;

  List<DnsQuery> get _sourceQueries =>
      widget.dnsQueriesListenable?.value ?? widget.dnsQueries;

  void _onRequestsChanged() => _scheduleSnapshot(DashboardFeed.requests);

  void _onQueriesChanged() => _scheduleSnapshot(DashboardFeed.dns);

  @override
  void initState() {
    super.initState();
    syncSeededConnections();
    _takeSnapshot();
    widget.requestsListenable?.addListener(_onRequestsChanged);
    widget.dnsQueriesListenable?.addListener(_onQueriesChanged);
  }

  @override
  void didUpdateWidget(ConnectionsTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestsListenable != widget.requestsListenable) {
      oldWidget.requestsListenable?.removeListener(_onRequestsChanged);
      widget.requestsListenable?.addListener(_onRequestsChanged);
    }
    if (oldWidget.dnsQueriesListenable != widget.dnsQueriesListenable) {
      oldWidget.dnsQueriesListenable?.removeListener(_onQueriesChanged);
      widget.dnsQueriesListenable?.addListener(_onQueriesChanged);
    }
    if (oldWidget.connected != widget.connected ||
        !identical(oldWidget.connections, widget.connections)) {
      syncSeededConnections();
    }
    if (!identical(oldWidget.requests, widget.requests) ||
        !identical(oldWidget.dnsQueries, widget.dnsQueries)) {
      _takeSnapshot();
    }
  }

  @override
  void dispose() {
    widget.requestsListenable?.removeListener(_onRequestsChanged);
    widget.dnsQueriesListenable?.removeListener(_onQueriesChanged);
    _snapshot?.cancel();
    super.dispose();
  }

  void _scheduleSnapshot(DashboardFeed feed) {
    if (feed != _feed) return;
    _snapshot ??= Timer(renderThrottleDuration, () {
      _snapshot = null;
      if (mounted) updateWhenRouteSettled(() => setState(_takeSnapshot));
    });
  }

  void _takeSnapshot() {
    switch (_feed) {
      case DashboardFeed.requests:
        _requests = _sourceRequests.reversed.toList();
      case DashboardFeed.dns:
        _queries = _sourceQueries.reversed.toList();
      case DashboardFeed.connections:
        break;
    }
  }

  void _select(DashboardFeed feed) {
    if (feed == _feed) return;
    setState(() {
      _feed = feed;
      if (feed != DashboardFeed.connections && connectionsReader != null) {
        connections = const [];
      } else if (feed == DashboardFeed.connections) {
        syncSeededConnections();
      }
      _takeSnapshot();
    });
    if (feed == DashboardFeed.connections) {
      stopPolling();
      startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final scale = DashboardDensityScope.scaleOf(context);
    final rowHeight = _rowHeightOf(density) * scale;
    final appLocalizations = KitLocalizations.of(context);
    final headerHeight = _tabHeightOf(density) * scale;
    final tabInset = _tabInsetOf(density);
    final cellStart = dashboardCardPadding(density).left - _cellInset;
    Widget segment(DashboardFeed feed, Widget count) =>
        DashboardConnectedButton(
          selected: _feed == feed,
          first: feed == DashboardFeed.values.first,
          last: feed == DashboardFeed.values.last,
          outer: headerHeight / 2,
          inner: 8,
          background: DashboardColors.of(context).tone,
          semanticLabel: feed.labelOf(context),
          onTap: () => _select(feed),
          builder: (foreground) => _FeedSegment(
            label: feed.labelOf(context),
            count: count,
            height: headerHeight,
            foreground: foreground,
          ),
        );
    return DashboardCard(
      semanticLabel: appLocalizations.liveConnections,
      padding: EdgeInsets.fromLTRB(cellStart, tabInset, cellStart, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: headerHeight,
            padding: EdgeInsets.symmetric(horizontal: tabInset - cellStart),
            child: LayoutBuilder(
              builder: (context, constraints) => DashboardCappedRow(
                share: 0.45,
                start: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: DashboardConnectedGroup(
                    children: [
                      segment(
                        DashboardFeed.connections,
                        ValueListenableBuilder(
                          valueListenable: connectionCount,
                          builder: (context, count, _) => _TabCount(count),
                        ),
                      ),
                      segment(
                        DashboardFeed.requests,
                        widget.requestCountListenable != null
                            ? ThrottledCount(
                                listenable: widget.requestCountListenable!,
                                builder: (_, count) => _TabCount(count),
                              )
                            : _TabCount(_sourceRequests.length),
                      ),
                      segment(
                        DashboardFeed.dns,
                        widget.dnsQueryCountListenable != null
                            ? ThrottledCount(
                                listenable: widget.dnsQueryCountListenable!,
                                builder: (_, count) => _TabCount(count),
                              )
                            : _TabCount(_sourceQueries.length),
                      ),
                    ],
                  ),
                ),
                end: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (_feed == DashboardFeed.connections &&
                        connections.isNotEmpty &&
                        constraints.maxWidth >= _midTableWidth) ...[
                      DashboardChip(
                        label: 'TCP $tcpCount',
                        tone: DashboardChipTone.idle,
                      ),
                      DashboardChip(
                        label: 'UDP $udpCount',
                        tone: DashboardChipTone.idle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: _tableGap),
          Expanded(
            child: switch (_feed) {
              DashboardFeed.connections => _Table<TrackerInfo>(
                key: const ValueKey(DashboardFeed.connections),
                tableId: 'dashboard.connections',
                initialColumnWidths:
                    widget.initialColumnWidthsOf?.call(
                      'dashboard.connections',
                    ) ??
                    const {},
                onColumnWidthsChanged: (widths) => widget.onColumnWidthsChanged
                    ?.call('dashboard.connections', widths),
                items: connections,
                rowHeight: rowHeight,
                columnsOf: (width) => _connectionColumns(context, width),
              ),
              DashboardFeed.requests => _Table<TrackerInfo>(
                key: const ValueKey(DashboardFeed.requests),
                tableId: 'dashboard.requests',
                initialColumnWidths:
                    widget.initialColumnWidthsOf?.call('dashboard.requests') ??
                    const {},
                onColumnWidthsChanged: (widths) => widget.onColumnWidthsChanged
                    ?.call('dashboard.requests', widths),
                items: _requests,
                rowHeight: rowHeight,
                columnsOf: (_) => _requestColumns(context),
              ),
              DashboardFeed.dns => _Table<DnsQuery>(
                key: const ValueKey(DashboardFeed.dns),
                tableId: 'dashboard.dns',
                initialColumnWidths:
                    widget.initialColumnWidthsOf?.call('dashboard.dns') ??
                    const {},
                onColumnWidthsChanged: (widths) => widget.onColumnWidthsChanged
                    ?.call('dashboard.dns', widths),
                items: _queries,
                rowHeight: rowHeight,
                columnsOf: (_) => _dnsColumns(context),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _TabCount extends StatelessWidget {
  const _TabCount(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      dashboardCount(count),
      maxLines: 1,
      style: AppTextStyle.subheadline
          .of(context, emphasized: true)
          .toTabular
          .copyWith(color: DefaultTextStyle.of(context).style.color),
    );
  }
}

class _FeedSegment extends StatelessWidget {
  const _FeedSegment({
    required this.label,
    required this.count,
    required this.height,
    required this.foreground,
  });

  final String label;
  final Widget count;
  final double height;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: count,
            ),
            Text(
              label,
              maxLines: 1,
              style: AppTextStyle.footnote
                  .of(context, emphasized: true)
                  .copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _Table<T> extends StatefulWidget {
  const _Table({
    super.key,
    required this.tableId,
    required this.initialColumnWidths,
    required this.onColumnWidthsChanged,
    required this.items,
    required this.rowHeight,
    required this.columnsOf,
  });

  final String tableId;
  final Map<String, double> initialColumnWidths;
  final ValueChanged<Map<String, double>> onColumnWidthsChanged;
  final List<T> items;
  final double rowHeight;
  final List<RecordColumn<T>> Function(double width) columnsOf;

  @override
  State<_Table<T>> createState() => _TableState<T>();
}

class _TableState<T> extends State<_Table<T>>
    with TableColumnWidthsMixin<_Table<T>> {
  final _sorter = RecordSorter<T>();
  RecordSort? _sort;

  @override
  String get tableId => widget.tableId;

  @override
  Map<String, double> get initialColumnWidths => widget.initialColumnWidths;

  @override
  void onColumnWidthsChanged(Map<String, double> widths) =>
      widget.onColumnWidthsChanged(widths);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final rowHeight = widget.rowHeight;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = widget.columnsOf(constraints.maxWidth);
        final layouts = [for (final column in columns) column.layout];
        final widths = tableColumnWidths(
          layouts,
          constraints.maxWidth,
          columnWidths,
        );
        final sorted = _sorter.sort(widget.items, columns, _sort);
        final items = sorted.length > _maxFeedRows
            ? sorted.sublist(0, _maxFeedRows)
            : sorted;
        final headerStyle = AppTextStyle.caption1
            .of(context, emphasized: true)
            .copyWith(color: colorScheme.onSurfaceVariant);
        final headerHeight =
            _headerHeight * DashboardDensityScope.scaleOf(context);
        final overflows =
            items.length * rowHeight + 2 > constraints.maxHeight - headerHeight;
        final shape = AppShape.all(DashboardCorner.tableHeader);
        final fill = ShapeDecoration(
          color: DashboardColors.of(context).tone,
          shape: shape,
        );
        final body = PrismListView(
          padding: const EdgeInsets.only(top: 2),
          itemExtent: rowHeight,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final cells = DefaultTextStyle.merge(
              style: AppTextStyle.footnote.of(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: TableCells(
                columns: layouts,
                widths: widths,
                height: rowHeight,
                inset: _cellInset,
                cells: [
                  for (final column in columns) column.cell(context, item),
                ],
              ),
            );
            return index.isOdd
                ? DecoratedBox(decoration: fill, child: cells)
                : cells;
          },
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: fill,
              child: Surface.transparent(
                shape: shape,
                clipBehavior: Clip.antiAlias,
                child: TableColumnResizer(
                  columns: layouts,
                  widths: widths,
                  onResize: (boundary, delta) =>
                      resizeColumn(layouts, widths, boundary, delta),
                  onResizeEnd: saveColumnWidths,
                  onReset: resetColumnWidths,
                  child: TableCells(
                    columns: layouts,
                    widths: widths,
                    height: headerHeight,
                    inset: 0,
                    cells: [
                      for (final column in columns)
                        RecordHeaderCell(
                          label: column.layout.label,
                          end: column.layout.end,
                          style: headerStyle,
                          inset: _cellInset,
                          descending: _sort?.columnId == column.id
                              ? _sort?.descending
                              : null,
                          onTap: column.sortKey == null
                              ? null
                              : () => setState(
                                  () => _sort = nextRecordSort(_sort, column),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          KitLocalizations.of(context).noData,
                          style: DashboardText.label(context),
                        ),
                      ),
                    )
                  : overflows
                  ? DashboardFadeOut(child: body)
                  : body,
            ),
          ],
        );
      },
    );
  }
}

TextStyle _muted(BuildContext context) =>
    TextStyle(color: context.colorScheme.onSurfaceVariant);

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _muted(context));
  }
}

class _Number extends StatelessWidget {
  const _Number(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: muted ? context.colorScheme.onSurfaceVariant : null,
      ),
    );
  }
}

class _Source extends StatelessWidget {
  const _Source(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.characters.firstOrNull ?? '?';
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: ShapeDecoration(
            color: DashboardColors.of(context).tone2,
            shape: AppShape.all(7),
          ),
          child: Center(
            child: Text(
              letter,
              style: AppTextStyle.caption2
                  .of(context, emphasized: true)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        Flexible(
          child: Text(
            name.isEmpty ? '—' : name,
            style: AppTextStyle.footnote.of(context, emphasized: true),
          ),
        ),
      ],
    );
  }
}

class _Exit extends StatelessWidget {
  const _Exit(this.info);

  final TrackerInfo info;

  @override
  Widget build(BuildContext context) {
    final exit = info.chains.firstOrNull ?? '';
    return EmojiText(
      exit.isEmpty ? '—' : exit,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: isBuiltinOutbound(exit) ? _muted(context) : null,
    );
  }
}

String _timeOf(DateTime time) => time.showTime.trim();

String _ruleKey(TrackerInfo info) =>
    '${info.rule} ${info.rulePayload}'.toLowerCase();

String _exitKey(TrackerInfo info) =>
    (info.chains.firstOrNull ?? '').toLowerCase();

List<RecordColumn<TrackerInfo>> _connectionColumns(
  BuildContext context,
  double width,
) {
  final appLocalizations = KitLocalizations.of(context);
  final mid = width >= _midTableWidth;
  final wide = width >= _wideTableWidth;
  return [
    RecordColumn(
      TableColumn('source', appLocalizations.source, width: wide ? 160 : 140),
      cell: (_, info) => _Source(info.metadata.process),
      sortKey: (info) => info.metadata.process.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('target', appLocalizations.target, flex: wide ? 1.3 : 1),
      cell: (_, info) => TrackerTargetText(info),
      sortKey: (info) => info.title.toLowerCase(),
    ),
    if (mid)
      RecordColumn(
        TableColumn(
          'protocol',
          appLocalizations.protocol,
          width: wide ? 52 : 46,
        ),
        cell: (_, info) => _Muted(info.metadata.network.toUpperCase()),
        sortKey: (info) => info.metadata.network.toLowerCase(),
      ),
    if (wide)
      RecordColumn(
        TableColumn('rule', appLocalizations.rule, flex: 1),
        cell: (_, info) => TrackerRuleText(info),
        sortKey: _ruleKey,
      ),
    RecordColumn(
      TableColumn(
        'exit',
        appLocalizations.outboundExit,
        width: wide ? 120 : 100,
      ),
      cell: (_, info) => _Exit(info),
      sortKey: _exitKey,
    ),
    RecordColumn(
      TableColumn(
        'download',
        appLocalizations.download,
        width: wide ? 80 : 70,
        end: true,
      ),
      cell: (_, info) => _Number(dashboardTraffic(info.download)),
      sortKey: (info) => info.download,
      descendingFirst: true,
    ),
    RecordColumn(
      TableColumn(
        'upload',
        appLocalizations.upload,
        width: wide ? 80 : 70,
        end: true,
      ),
      cell: (_, info) => _Number(dashboardTraffic(info.upload)),
      sortKey: (info) => info.upload,
      descendingFirst: true,
    ),
    if (mid)
      RecordColumn(
        TableColumn(
          'duration',
          appLocalizations.duration,
          width: wide ? 72 : 64,
          end: true,
        ),
        cell: (_, info) => _Number(
          trackerDurationText(DateTime.now().difference(info.start)),
          muted: true,
        ),
        sortKey: (info) => -info.start.microsecondsSinceEpoch,
        descendingFirst: true,
      ),
  ];
}

List<RecordColumn<TrackerInfo>> _requestColumns(BuildContext context) {
  final appLocalizations = KitLocalizations.of(context);
  return [
    RecordColumn(
      TableColumn('time', appLocalizations.time, width: 76),
      cell: (_, info) => _Number(_timeOf(info.start), muted: true),
      sortKey: (info) => info.start,
      descendingFirst: true,
    ),
    RecordColumn(
      TableColumn('source', appLocalizations.source, width: 140),
      cell: (_, info) => _Source(info.metadata.process),
      sortKey: (info) => info.metadata.process.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('target', appLocalizations.target, flex: 1.2),
      cell: (_, info) => TrackerTargetText(info),
      sortKey: (info) => info.title.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('rule', appLocalizations.rule, flex: 1),
      cell: (_, info) => TrackerRuleText(info),
      sortKey: _ruleKey,
    ),
    RecordColumn(
      TableColumn('exit', appLocalizations.outboundExit, width: 100),
      cell: (_, info) => _Exit(info),
      sortKey: _exitKey,
    ),
    RecordColumn(
      TableColumn('traffic', appLocalizations.traffic, width: 64, end: true),
      cell: (_, info) => _Number(dashboardTraffic(info.upload + info.download)),
      sortKey: (info) => info.upload + info.download,
      descendingFirst: true,
    ),
  ];
}

List<RecordColumn<DnsQuery>> _dnsColumns(BuildContext context) {
  final appLocalizations = KitLocalizations.of(context);
  return [
    RecordColumn(
      TableColumn('time', appLocalizations.time, width: 76),
      cell: (_, query) => _Number(_timeOf(query.time), muted: true),
      sortKey: (query) => query.time,
      descendingFirst: true,
    ),
    RecordColumn(
      TableColumn('domain', appLocalizations.domain, flex: 1.3),
      cell: (context, query) => Text(
        query.domain,
        style: AppTextStyle.footnote.of(context, emphasized: true),
      ),
      sortKey: (query) => query.domain.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('type', appLocalizations.ipType, width: 60),
      cell: (_, query) => _Muted(query.type),
      sortKey: (query) => query.type,
    ),
    RecordColumn(
      TableColumn('initiator', appLocalizations.initiatorShort, width: 52),
      cell: (_, query) => _Muted(query.initiator?.labelOfStrings(appLocalizations) ?? '—'),
      sortKey: (query) => query.initiator?.labelOfStrings(appLocalizations) ?? '',
    ),
    RecordColumn(
      TableColumn('result', appLocalizations.result, flex: 1),
      cell: (_, query) => _DnsResult(query),
      sortKey: (query) => query.summary.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('elapsed', appLocalizations.elapsed, width: 72, end: true),
      cell: (_, query) => _Number('${query.delay} ms', muted: true),
      sortKey: (query) => query.delay,
      descendingFirst: true,
    ),
  ];
}

class _DnsResult extends StatelessWidget {
  const _DnsResult(this.query);

  final DnsQuery query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (query.error.isNotEmpty) {
      return Text(query.error, style: TextStyle(color: colorScheme.error));
    }
    if (query.hasFailureRcode) {
      return Text(
        query.rcode,
        style: AppTextStyle.footnote
            .of(context, emphasized: true)
            .copyWith(color: DashboardColors.of(context).warn),
      );
    }
    final answer = query.answers.firstOrNull ?? '—';
    return Row(
      children: [
        if (query.cached)
          Container(
            height: 18,
            margin: const EdgeInsetsDirectional.only(end: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: ShapeDecoration(
              color: DashboardColors.of(context).tone,
              shape: AppShape.full,
            ),
            child: Center(
              child: Text(
                KitLocalizations.of(context).cache,
                style: AppTextStyle.caption2
                    .of(context, emphasized: true)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        Flexible(
          child: Text(
            answer,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
