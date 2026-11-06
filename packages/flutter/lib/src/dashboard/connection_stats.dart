// Derived from chen08209/FlClash, lib/views/dashboard/widgets/connection_stats.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../localizations.dart';
import '../widgets/active_polling.dart';
import 'card.dart';
import 'connections_table.dart';
import 'layout.dart';
import 'style.dart';

/// The counts of the three feeds, each opening its list, for the phone and
/// for a desktop page too short for the table.
class ConnectionStatsCard extends StatefulWidget {
  const ConnectionStatsCard({
    super.key,
    this.connected = true,
    this.initialConnectionCount = 0,
    this.connectionCountListenable,
    this.connectionCountReader,
    this.requestCount = 0,
    this.requestCountListenable,
    this.dnsQueryCount = 0,
    this.dnsQueryCountListenable,
    this.onOpenFeed,
  });

  final bool connected;
  final int initialConnectionCount;
  final ValueListenable<int>? connectionCountListenable;
  final Future<int> Function()? connectionCountReader;
  final int requestCount;
  final ValueListenable<int>? requestCountListenable;
  final int dnsQueryCount;
  final ValueListenable<int>? dnsQueryCountListenable;
  final ValueChanged<DashboardFeed>? onOpenFeed;

  @override
  State<ConnectionStatsCard> createState() => _ConnectionStatsCardState();
}

class _ConnectionStatsCardState extends State<ConnectionStatsCard>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<ConnectionStatsCard>,
        RouteMotionHoldMixin<ConnectionStatsCard>,
        ConnectionsPolling<ConnectionStatsCard> {
  static const _inset = 8.0;

  @override
  bool get pollsConnections => false;

  @override
  bool get isCoreConnected => widget.connected;

  @override
  Future<List<Never>> Function()? get connectionsReader => null;

  @override
  Future<int> Function()? get connectionCountReader =>
      widget.connectionCountReader;

  @override
  int get seededConnectionCount => widget.initialConnectionCount;

  @override
  void initState() {
    super.initState();
    syncSeededConnections();
  }

  @override
  void didUpdateWidget(ConnectionStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connected != widget.connected ||
        oldWidget.initialConnectionCount != widget.initialConnectionCount) {
      syncSeededConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shape = AppShape.all(
      dashboardCardRadius(DashboardDensityScope.of(context)) - _inset,
    );
    void open(DashboardFeed feed) {
      if (widget.onOpenFeed != null) {
        widget.onOpenFeed!(feed);
      } else {
        openDashboardFeed(context, feed);
      }
    }

    return DashboardCard(
      semanticLabel: KitLocalizations.of(context).connectionStats,
      padding: const EdgeInsets.all(_inset),
      child: Row(
        children: [
          _Stat(
            feed: DashboardFeed.connections,
            shape: shape,
            onOpen: open,
            count: ValueListenableBuilder<int>(
              valueListenable:
                  widget.connectionCountListenable ?? connectionCount,
              builder: (context, count, _) => _Count(count),
            ),
          ),
          _Stat(
            feed: DashboardFeed.requests,
            shape: shape,
            onOpen: open,
            count: widget.requestCountListenable != null
                ? ThrottledCount(
                    listenable: widget.requestCountListenable!,
                    builder: (_, count) => _Count(count),
                  )
                : _Count(widget.requestCount),
          ),
          _Stat(
            feed: DashboardFeed.dns,
            shape: shape,
            onOpen: open,
            count: widget.dnsQueryCountListenable != null
                ? ThrottledCount(
                    listenable: widget.dnsQueryCountListenable!,
                    builder: (_, count) => _Count(count),
                  )
                : _Count(widget.dnsQueryCount),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      dashboardCount(count),
      maxLines: 1,
      style: DashboardText.figure(
        context,
        AppTextStyle.title2,
      ).copyWith(letterSpacing: 0),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.feed,
    required this.shape,
    required this.count,
    required this.onOpen,
  });

  final DashboardFeed feed;
  final OutlinedBorder shape;
  final Widget count;
  final ValueChanged<DashboardFeed> onOpen;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressSurface(
        fill: Colors.transparent,
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 10),
        childFills: true,
        onPressed: () => onOpen(feed),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            count,
            Text(
              feed.labelOf(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DashboardText.label(context),
            ),
          ],
        ),
      ),
    );
  }
}
