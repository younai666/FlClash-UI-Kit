// Derived from chen08209/FlClash, lib/views/connection/requests.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../datetime.dart';
import '../localizations.dart';
import '../scaffold/scaffold.dart';
import '../ui/null_status_illustration.dart';
import '../widgets/active_polling.dart';
import '../widgets/record_table.dart';
import 'connection_models.dart';
import 'filter.dart';
import 'tracker_info_list.dart';
import 'tracker_info_table.dart';
import 'tracker_speed_ranker.dart';
import 'types.dart';

void _ignoreColumnWidths(Map<String, double> _) {}

class RequestsView extends StatefulWidget {
  final ScrollController? scrollController;
  final RequestFeed? initialFeed;
  final ValueChanged<RequestFeed>? onFeedChanged;
  final List<TrackerInfo> requests;
  final ValueListenable<List<TrackerInfo>>? requestsListenable;
  final Future<List<TrackerInfo>> Function()? connectionsReader;
  final Future<void> Function(TrackerInfo connection)? onCloseConnection;
  final Future<void> Function()? onCloseAllConnections;
  final RecordGrouping? initialGrouping;
  final ValueChanged<RecordGrouping?>? onGroupingChanged;
  final Map<String, double> initialRequestsColumnWidths;
  final ValueChanged<Map<String, double>>? onRequestsColumnWidthsChanged;
  final Map<String, double> initialConnectionsColumnWidths;
  final ValueChanged<Map<String, double>>? onConnectionsColumnWidthsChanged;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const RequestsView({
    super.key,
    this.scrollController,
    this.initialFeed,
    this.onFeedChanged,
    this.requests = const [],
    this.requestsListenable,
    this.connectionsReader,
    this.onCloseConnection,
    this.onCloseAllConnections,
    this.initialGrouping,
    this.onGroupingChanged,
    this.initialRequestsColumnWidths = const {},
    this.onRequestsColumnWidthsChanged,
    this.initialConnectionsColumnWidths = const {},
    this.onConnectionsColumnWidthsChanged,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView>
    with RouteMotionHoldMixin<RequestsView> {
  final _recent = TrackerInfoListController();
  final _live = TrackerInfoListController();
  final _liveFeed = GlobalKey<_LiveFeedState>();
  late final _filters = trackerInfoFilterController(
    grouping: widget.initialGrouping,
    onGroupingChanged: widget.onGroupingChanged,
  );
  late var _feed = widget.initialFeed ?? RequestFeed.recent;
  Timer? _throttleTimer;

  List<TrackerInfo> get _currentRequests =>
      widget.requestsListenable?.value ?? widget.requests;

  @override
  void initState() {
    super.initState();
    if (_feed == RequestFeed.recent) {
      _showLatestRequests();
    }
    widget.requestsListenable?.addListener(updateRequestsThrottler);
  }

  @override
  void didUpdateWidget(RequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestsListenable != widget.requestsListenable) {
      oldWidget.requestsListenable?.removeListener(updateRequestsThrottler);
      widget.requestsListenable?.addListener(updateRequestsThrottler);
    }
    if (widget.requestsListenable == null &&
        !identical(oldWidget.requests, widget.requests)) {
      updateRequestsThrottler();
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    widget.requestsListenable?.removeListener(updateRequestsThrottler);
    _recent.dispose();
    _live.dispose();
    _filters.dispose();
    super.dispose();
  }

  void _setRequests(List<TrackerInfo> requests) {
    _recent.setTrackerInfos(requests);
    _filters.offer(_recent.value.trackerInfos);
  }

  void _showLatestRequests() {
    _recent.resumeAutoScrollToEnd(_currentRequests);
    _filters.offer(_recent.value.trackerInfos);
  }

  void updateRequestsThrottler() {
    _throttleTimer ??= Timer(renderThrottleDuration, () {
      _throttleTimer = null;
      if (!mounted || _feed != RequestFeed.recent) {
        return;
      }
      updateWhenRouteSettled(() => _setRequests(_currentRequests));
    });
  }

  void _search(String query) {
    _recent.search(query);
    _live.search(query);
  }

  void _selectFeed(RequestFeed feed) {
    if (feed == _feed) {
      return;
    }
    // Offered before the feed mounts: a build below this page can't notify it.
    if (feed == RequestFeed.recent) {
      _showLatestRequests();
    }
    setState(() => _feed = feed);
    widget.onFeedChanged?.call(feed);
  }

  List<IconButtonData> _buildActions() {
    if (_feed != RequestFeed.live || widget.onCloseAllConnections == null) {
      return const [];
    }
    return [
      IconButtonData(
        glyph: AppGlyphs.clearAll,
        tooltip: KitLocalizations.of(context).closeConnections,
        onPressed: () => _liveFeed.currentState?.closeAll(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final body = RecordFilterScope(
      onFilter: _filters.add,
      child: ListenableBuilder(
        listenable: _filters,
        builder: (_, _) => _buildBody(),
      ),
    );
    return ListenableBuilder(
      listenable: Listenable.merge([_filters, _filters.options]),
      child: body,
      builder: (context, body) {
        final pinned = !ViewScope.isMobileOf(context);
        return Scaffold(
          title: _labelOf(_feed),
          titleMenuItems: _buildFeedMenu(),
          searchState: AppBarSearchState(onSearch: _search),
          keywords: _filters.keywordsOf(pinned: pinned),
          iconActions: _buildActions(),
          menuItems: _filters.menuItems(context, pinned: pinned),
          body: body!,
        );
      },
    );
  }

  String _labelOf(RequestFeed feed) => switch (feed) {
    RequestFeed.recent => KitLocalizations.of(context).recentRequests,
    RequestFeed.live => KitLocalizations.of(context).running,
  };

  List<PopupMenuItem> _buildFeedMenu() {
    return [
      for (final feed in RequestFeed.values)
        PopupMenuItem(
          label: _labelOf(feed),
          checked: feed == _feed,
          onPressed: () => _selectFeed(feed),
        ),
    ];
  }

  Widget _buildBody() {
    return switch (_feed) {
      RequestFeed.recent => _RecentFeed(
        listController: _recent,
        filters: _filters,
        scrollController: widget.scrollController,
        onResumeToEnd: _showLatestRequests,
        initialColumnWidths: widget.initialRequestsColumnWidths,
        onColumnWidthsChanged: widget.onRequestsColumnWidthsChanged,
        loadPackageIcon: widget.loadPackageIcon,
        cachedPackageIconOf: widget.cachedPackageIconOf,
      ),
      RequestFeed.live => _LiveFeed(
        key: _liveFeed,
        listController: _live,
        filters: _filters,
        scrollController: widget.scrollController,
        connectionsReader: widget.connectionsReader,
        onCloseConnection: widget.onCloseConnection,
        onCloseAllConnections: widget.onCloseAllConnections,
        initialColumnWidths: widget.initialConnectionsColumnWidths,
        onColumnWidthsChanged: widget.onConnectionsColumnWidthsChanged,
        loadPackageIcon: widget.loadPackageIcon,
        cachedPackageIconOf: widget.cachedPackageIconOf,
      ),
    };
  }
}

class _RecentFeed extends StatefulWidget {
  final TrackerInfoListController listController;
  final RecordFilterController<TrackerInfo> filters;
  final ScrollController? scrollController;
  final VoidCallback onResumeToEnd;
  final Map<String, double> initialColumnWidths;
  final ValueChanged<Map<String, double>>? onColumnWidthsChanged;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const _RecentFeed({
    required this.listController,
    required this.filters,
    required this.scrollController,
    required this.onResumeToEnd,
    required this.initialColumnWidths,
    required this.onColumnWidthsChanged,
    required this.loadPackageIcon,
    required this.cachedPackageIconOf,
  });

  @override
  State<_RecentFeed> createState() => _RecentFeedState();
}

class _RecentFeedState extends State<_RecentFeed> {
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => widget.listController.value.autoScrollToEnd,
  );

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        sheetScrollController(context, initialScrollOffset: double.maxFinite);
    // A sheet's one controller may have been left where the live feed reads.
    if (widget.scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return ValueListenableBuilder<TrackerInfosState>(
      valueListenable: widget.listController,
      builder: (context, state, _) {
        final requests = widget.filters.apply(state.list);
        return NullStatusSwitcher(
          isEmpty: requests.isEmpty,
          isSearching: state.isSearching || widget.filters.isFiltering,
          nullStatus: NullStatus(
            label: appLocalizations.nullTip(appLocalizations.requests),
            illustration: NullStatusIllustration.requests,
          ),
          child: RecordTableFrame<TrackerInfo>(
            tableId: 'requests',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: requests,
            reverse: true,
            columnsOf: (width) =>
                trackerInfoColumns(context, width: width, isLive: false),
            builder: (context, table, requests) {
              final padding = EdgeInsets.only(
                top: context.contentTopPadding,
                bottom: 16 + context.bottomInset,
              );
              final detailTitle = appLocalizations.details(
                appLocalizations.request,
              );
              final groups = widget.filters.groupsOf(requests, reverse: true);
              if (groups != null) {
                return FloatingScrollbar(
                  controller: _scrollController,
                  hintBuilder: (fraction) {
                    final index = (fraction * (groups.length - 1)).round();
                    return groups[index].items.first.start.showFull;
                  },
                  child: TrackerInfoGroupedList(
                    groups: groups,
                    grouping: widget.filters.value.grouping!,
                    isLive: false,
                    controller: _scrollController,
                    padding: padding,
                    table: table,
                    detailTitle: detailTitle,
                    loadPackageIcon: widget.loadPackageIcon,
                    cachedPackageIconOf: widget.cachedPackageIconOf,
                  ),
                );
              }
              return Align(
                alignment: Alignment.topCenter,
                child: FloatingScrollbar(
                  controller: _scrollController,
                  hintBuilder: (fraction) {
                    final index = (fraction * (requests.length - 1)).round();
                    return requests[index].start.showFull;
                  },
                  child: ScrollToEndBox(
                    controller: _scrollController,
                    enable: state.autoScrollToEnd,
                    onCancelToEnd: () {
                      widget.listController.setAutoScrollToEnd(false);
                    },
                    onResumeToEnd: () {
                      widget.onResumeToEnd();
                    },
                    child: TrackerInfoList(
                      reverse: true,
                      shrinkWrap: true,
                      physics: _physics,
                      controller: _scrollController,
                      padding: padding,
                      trackerInfos: requests,
                      table: table,
                      detailTitle: detailTitle,
                      loadPackageIcon: widget.loadPackageIcon,
                      cachedPackageIconOf: widget.cachedPackageIconOf,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LiveFeed extends StatefulWidget {
  final TrackerInfoListController listController;
  final RecordFilterController<TrackerInfo> filters;
  final ScrollController? scrollController;
  final Future<List<TrackerInfo>> Function()? connectionsReader;
  final Future<void> Function(TrackerInfo connection)? onCloseConnection;
  final Future<void> Function()? onCloseAllConnections;
  final Map<String, double> initialColumnWidths;
  final ValueChanged<Map<String, double>>? onColumnWidthsChanged;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const _LiveFeed({
    super.key,
    required this.listController,
    required this.filters,
    required this.scrollController,
    required this.connectionsReader,
    required this.onCloseConnection,
    required this.onCloseAllConnections,
    required this.initialColumnWidths,
    required this.onColumnWidthsChanged,
    required this.loadPackageIcon,
    required this.cachedPackageIconOf,
  });

  @override
  State<_LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<_LiveFeed>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<_LiveFeed>,
        RouteMotionHoldMixin<_LiveFeed> {

  final _speedRanker = TrackerSpeedRanker();
  late final ScrollController _scrollController;
  var _loaded = false;
  // A sheet's one controller opens where the recent feed reads, its far end.
  late var _startsAtFarEnd = widget.scrollController != null;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ?? sheetScrollController(context);
  }

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  Future<void> closeAll() {
    final closeAllConnections = widget.onCloseAllConnections;
    if (closeAllConnections == null) return Future.value();
    return _close(closeAllConnections);
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final trackerInfos = await _readConnections();
    if (!isCurrent()) {
      return;
    }
    _showConnections(trackerInfos);
  }

  Future<void> _refreshConnections() async {
    final trackerInfos = await _readConnections();
    if (!mounted) {
      return;
    }
    _showConnections(trackerInfos);
  }

  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      if (connectionsReader != null) {
        return await connectionsReader();
      }
      return const [];
    } catch (error) {
      debugPrint('updateConnections error: $error');
      return null;
    }
  }

  void _showConnections(List<TrackerInfo>? trackerInfos) {
    final readAt = DateTime.now();
    if (!_loaded) {
      showFirstContent(() {
        setState(() => _loaded = true);
        // A failed read must not leave the controller's list from the last visit.
        _applyConnections(trackerInfos ?? const [], readAt);
      });
      return;
    }
    updateWhenRouteSettled(() => _applyConnections(trackerInfos, readAt));
  }

  void _applyConnections(List<TrackerInfo>? trackerInfos, DateTime readAt) {
    if (trackerInfos == null) {
      return;
    }
    widget.listController.setTrackerInfos(
      _speedRanker.rank(trackerInfos, readAt),
    );
    widget.filters.offer(widget.listController.value.trackerInfos);
    if (_startsAtFarEnd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _startsAtFarEnd && _scrollController.hasClients) {
          _startsAtFarEnd = false;
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  ValueChanged<TrackerInfo>? get _onClose => widget.onCloseConnection == null
      ? null
      : (trackerInfo) =>
            unawaited(_close(() => widget.onCloseConnection!(trackerInfo)));

  Future<void> _close(Future<void> Function() close) async {
    try {
      await close();
    } catch (error) {
      if (mounted) {
        BannerHost.maybeOf(
          context,
        )?.show(error.toString(), level: BannerLevel.error);
      }
    }
    if (mounted) {
      await _refreshConnections();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return ValueListenableBuilder<TrackerInfosState>(
      valueListenable: widget.listController,
      builder: (context, state, _) {
        final connections = widget.filters.apply(state.list);
        return NullStatusSwitcher(
          isLoading: !_loaded,
          loadingStatus: const Center(child: ActivityIndicator.page()),
          isEmpty: connections.isEmpty,
          isSearching: state.isSearching || widget.filters.isFiltering,
          nullStatus: NullStatus(
            label: appLocalizations.nullTip(appLocalizations.connections),
            illustration: NullStatusIllustration.connections,
          ),
          child: RecordTableFrame<TrackerInfo>(
            tableId: 'connections',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: connections,
            columnsOf: (width) =>
                trackerInfoColumns(context, width: width, isLive: true),
            builder: (context, table, connections) {
              final padding = EdgeInsets.only(
                top: context.contentTopPadding,
                bottom: 16 + context.bottomInset,
              );
              final detailTitle = appLocalizations.details(
                appLocalizations.connection,
              );
              final groups = widget.filters.groupsOf(connections);
              if (groups != null) {
                return TrackerInfoGroupedList(
                  groups: groups,
                  grouping: widget.filters.value.grouping!,
                  isLive: true,
                  controller: _scrollController,
                  padding: padding,
                  table: table,
                  detailTitle: detailTitle,
                  onClose: _onClose,
                  loadPackageIcon: widget.loadPackageIcon,
                  cachedPackageIconOf: widget.cachedPackageIconOf,
                );
              }
              return TrackerInfoAnimatedList(
                controller: _scrollController,
                padding: padding,
                trackerInfos: connections,
                table: table,
                detailTitle: detailTitle,
                onClose: _onClose,
                loadPackageIcon: widget.loadPackageIcon,
                cachedPackageIconOf: widget.cachedPackageIconOf,
              );
            },
          ),
        );
      },
    );
  }
}
