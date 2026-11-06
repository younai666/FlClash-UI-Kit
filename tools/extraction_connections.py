"""Reviewed connection, request, DNS query, and log views and feed helpers."""


def register_connections(register, base):
    register('lib/features/connection/detail_tabs.dart', 'records/detail_tabs.dart', [
        ("import 'package:fl_clash/widgets/widgets.dart';", "import 'package:prism_ui/prism_ui.dart';"),
    ])

    register('lib/features/connection/tracker_speed_ranker.dart', 'records/tracker_speed_ranker.dart', [
        ("import 'package:fl_clash/models/models.dart';", "import 'connection_models.dart';"),
    ])

    register('test/features/tracker_speed_ranker_test.dart', '@test/features/tracker_speed_ranker_test.dart', [
        ('''import 'package:fl_clash/features/connection/tracker_speed_ranker.dart';
import 'package:fl_clash/models/models.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';'''),
    ])

    item_src = (base / 'lib/features/connection/tracker_info_item.dart').read_text(encoding='utf-8')
    mitm_section = item_src[
        item_src.index('/// Adds the host of a connection'):
        item_src.index('class TrackerInfoDetailView')
    ]
    register('lib/features/connection/tracker_info_item.dart', 'records/tracker_info_item.dart', [
        (mitm_section, ''),
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detail_tabs.dart';
import 'mitm_exchanges.dart';''', '''import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../datetime.dart';
import '../format.dart';
import '../localizations.dart';
import '../scaffold/scaffold.dart';
import '../widgets/record.dart';
import '../widgets/target_icon.dart';
import 'connection_models.dart';
import 'detail_tabs.dart';
import 'filter.dart';
import 'model.dart';
import 'types.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    dialogs.showBanner(currentAppLocalizations.copySuccess);
  }''', '''  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      BannerHost.maybeOf(context)?.show(appLocalizations.copySuccess);
    }
  }'''),
        ('''class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool isLive;
  final ValueChanged<TrackerInfo>? onClose;
  final String detailTitle;

  /// What the detail opens on, where a memoized row outlives its traffic.
  final ValueGetter<TrackerInfo>? latest;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.isLive = false,
    this.onClose,
    required this.detailTitle,
    this.latest,
  });

  @override
  Widget build(BuildContext context, ref) {
    final showIcon = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always && system.isAndroid,
      ),
    );
    return ContextMenuRegion(
      menuItems: trackerInfoMenuItems(context, trackerInfo, onClose: onClose),
      child: RecordListItem(
        onTap: () => showTrackerInfoDetail(
          context,
          latest?.call() ?? trackerInfo,
          detailTitle,
        ),
        header: _buildHeader(context),
        body: _TrackerInfoBody(trackerInfo: trackerInfo, showIcon: showIcon),
      ),
    );
  }''', '''class TrackerInfoItem extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final bool isLive;
  final ValueChanged<TrackerInfo>? onClose;
  final String detailTitle;

  /// What the detail opens on, where a memoized row outlives its traffic.
  final ValueGetter<TrackerInfo>? latest;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.isLive = false,
    this.onClose,
    required this.detailTitle,
    this.latest,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      menuItems: trackerInfoMenuItems(context, trackerInfo, onClose: onClose),
      child: RecordListItem(
        onTap: () => showTrackerInfoDetail(
          context,
          latest?.call() ?? trackerInfo,
          detailTitle,
        ),
        header: _buildHeader(context),
        body: _TrackerInfoBody(
          trackerInfo: trackerInfo,
          loadPackageIcon: loadPackageIcon,
          cachedPackageIconOf: cachedPackageIconOf,
        ),
      ),
    );
  }'''),
        ('''class _TrackerInfoBody extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final bool showIcon;

  const _TrackerInfoBody({required this.trackerInfo, required this.showIcon});''', '''class _TrackerInfoBody extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const _TrackerInfoBody({
    required this.trackerInfo,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });'''),
        ('''    final process = metadata.process;
    if (!showIcon || process.isEmpty) {
      return title;
    }
    return Row(
      spacing: 8,
      children: [
        GestureDetector(
          onTap: () => RecordFilterScope.add(
            context,
            RecordFilter(RecordFacetKind.app, process),
          ),
          child: PackageIcon(packageName: process, size: 24),
        ),
        Flexible(child: title),
      ],
    );''', '''    final process = metadata.process;
    final loadIcon = loadPackageIcon;
    if (loadIcon == null || process.isEmpty) {
      return title;
    }
    return Row(
      spacing: 8,
      children: [
        GestureDetector(
          onTap: () => RecordFilterScope.add(
            context,
            RecordFilter(RecordFacetKind.app, process),
          ),
          child: PackageIcon(
            packageName: process,
            size: 24,
            loadIcon: loadIcon,
            cachedIconOf: cachedPackageIconOf,
          ),
        ),
        Flexible(child: title),
      ],
    );'''),
        ('class TrackerInfoDetailView extends ConsumerWidget {', 'class TrackerInfoDetailView extends StatelessWidget {'),
        ('        if (mitmFeature) _MitmHostSection(metadata: metadata),\n', ''),
        ('''  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = KitLocalizations.of(context);
    final capturing =
        trackerInfo.metadata.mitm &&
        ref.watch(
          patchClashConfigProvider.select(
            (state) => state.mitm.enable && state.mitm.capture,
          ),
        );
    return DetailTabs(
      tabs: [
        (appLocalizations.overview, _buildOverview),
        if (capturing)
          (
            appLocalizations.httpRequests,
            (_) => MitmExchangesView(trackerInfo: trackerInfo),
          ),
      ],
    );
  }''', '''  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return DetailTabs(
      tabs: [
        (appLocalizations.overview, _buildOverview),
      ],
    );
  }'''),
    ])

    register('lib/features/connection/tracker_info_table.dart', 'records/tracker_info_table.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'tracker_info_item.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../datetime.dart';
import '../format.dart';
import '../localizations.dart';
import '../widgets/record.dart';
import '../widgets/record_table.dart';
import 'connection_models.dart';
import 'filter.dart';
import 'model.dart';
import 'tracker_info_item.dart';
import 'types.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/features/connection/tracker_info_list.dart', 'records/tracker_info_list.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_info_item.dart';
import 'tracker_info_table.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../datetime.dart';
import '../fixed.dart';
import '../format.dart';
import '../widgets/record.dart';
import '../widgets/record_feed_list.dart';
import '../widgets/record_table.dart';
import '../widgets/target_icon.dart';
import 'connection_models.dart';
import 'filter.dart';
import 'model.dart';
import 'tracker_info_item.dart';
import 'tracker_info_table.dart';
import 'types.dart';'''),
        ('''RecordFilterController<TrackerInfo> trackerInfoFilterController(
  WidgetRef ref,
  String pageId,
) {
  return RecordFilterController(
    facets: trackerInfoFacets,
    groupers: trackerInfoGroupers,
    grouping: savedRecordGrouping(ref, pageId),
    onGroupingChanged: (grouping) => saveRecordGrouping(ref, pageId, grouping),
  );
}''', '''RecordFilterController<TrackerInfo> trackerInfoFilterController({
  RecordGrouping? grouping,
  ValueChanged<RecordGrouping?>? onGroupingChanged,
}) {
  return RecordFilterController(
    facets: trackerInfoFacets,
    groupers: trackerInfoGroupers,
    grouping: grouping,
    onGroupingChanged: onGroupingChanged,
  );
}'''),
        ('''  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.onClose,
  });''', '''  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const TrackerInfoList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.onClose,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });'''),
        ('''          onClose: onClose,
          latest: latest,
        ),''', '''          onClose: onClose,
          latest: latest,
          loadPackageIcon: loadPackageIcon,
          cachedPackageIconOf: cachedPackageIconOf,
        ),'''),
        ('''  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoAnimatedList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.onClose,
  });''', '''  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const TrackerInfoAnimatedList({
    super.key,
    required this.trackerInfos,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.onClose,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });'''),
        ('''              striped: striped,
              onClose: onClose,
            ),''', '''              striped: striped,
              onClose: onClose,
              loadPackageIcon: loadPackageIcon,
              cachedPackageIconOf: cachedPackageIconOf,
            ),'''),
        ('''class TrackerInfoGroupedList extends ConsumerStatefulWidget {
  final List<RecordGroup<TrackerInfo>> groups;
  final RecordGrouping grouping;
  final bool isLive;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;

  const TrackerInfoGroupedList({
    super.key,
    required this.groups,
    required this.grouping,
    required this.isLive,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.onClose,
  });

  @override
  ConsumerState<TrackerInfoGroupedList> createState() =>
      _TrackerInfoGroupedListState();
}

class _TrackerInfoGroupedListState
    extends ConsumerState<TrackerInfoGroupedList> {''', '''class TrackerInfoGroupedList extends StatefulWidget {
  final List<RecordGroup<TrackerInfo>> groups;
  final RecordGrouping grouping;
  final bool isLive;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<TrackerInfo>? onClose;
  final Future<ImageProvider?> Function(String packageName)? loadPackageIcon;
  final ImageProvider? Function(String packageName)? cachedPackageIconOf;

  const TrackerInfoGroupedList({
    super.key,
    required this.groups,
    required this.grouping,
    required this.isLive,
    required this.detailTitle,
    this.table,
    this.controller,
    this.padding,
    this.onClose,
    this.loadPackageIcon,
    this.cachedPackageIconOf,
  });

  @override
  State<TrackerInfoGroupedList> createState() =>
      _TrackerInfoGroupedListState();
}

class _TrackerInfoGroupedListState extends State<TrackerInfoGroupedList> {'''),
        ('''    final showIcon =
        grouping == RecordGrouping.app &&
        ref.watch(
          patchClashConfigProvider.select(
            (state) =>
                state.findProcessMode == FindProcessMode.always &&
                system.isAndroid,
          ),
        );
    final showsTraffic = isLive || table != null;
    return RecordGroupedList<TrackerInfo>(
      groups: widget.groups,
      grouping: grouping,
      controller: widget.controller,
      padding: widget.padding,
      estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
      leadingOf: (group) => showIcon && group.key.isNotEmpty
          ? PackageIcon(packageName: group.key, size: 24)
          : null,''', '''    final loadIcon = grouping == RecordGrouping.app ? widget.loadPackageIcon : null;
    final showsTraffic = isLive || table != null;
    return RecordGroupedList<TrackerInfo>(
      groups: widget.groups,
      grouping: grouping,
      controller: widget.controller,
      padding: widget.padding,
      estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
      leadingOf: (group) => loadIcon != null && group.key.isNotEmpty
          ? PackageIcon(
              packageName: group.key,
              size: 24,
              loadIcon: loadIcon,
              cachedIconOf: widget.cachedPackageIconOf,
            )
          : null,'''),
        ('''              onClose: onClose,
              latest: () => _latest(trackerInfo),
            );''', '''              onClose: onClose,
              latest: () => _latest(trackerInfo),
              loadPackageIcon: widget.loadPackageIcon,
              cachedPackageIconOf: widget.cachedPackageIconOf,
            );'''),
        ('''Widget _buildTrackerInfoItem(
  TrackerInfo trackerInfo, {
  required bool isLive,
  required String detailTitle,
  required RecordTable<TrackerInfo>? table,
  required bool striped,
  ValueChanged<TrackerInfo>? onClose,
  ValueGetter<TrackerInfo>? latest,
}) {
  if (table != null) {
    return TrackerInfoTableRow(
      key: Key(trackerInfo.id),
      trackerInfo: trackerInfo,
      table: table,
      striped: striped,
      detailTitle: detailTitle,
      onClose: onClose,
    );
  }
  return TrackerInfoItem(
    key: Key(trackerInfo.id),
    trackerInfo: trackerInfo,
    isLive: isLive,
    onClose: onClose,
    detailTitle: detailTitle,
    latest: latest,
  );
}''', '''Widget _buildTrackerInfoItem(
  TrackerInfo trackerInfo, {
  required bool isLive,
  required String detailTitle,
  required RecordTable<TrackerInfo>? table,
  required bool striped,
  ValueChanged<TrackerInfo>? onClose,
  ValueGetter<TrackerInfo>? latest,
  Future<ImageProvider?> Function(String packageName)? loadPackageIcon,
  ImageProvider? Function(String packageName)? cachedPackageIconOf,
}) {
  if (table != null) {
    return TrackerInfoTableRow(
      key: Key(trackerInfo.id),
      trackerInfo: trackerInfo,
      table: table,
      striped: striped,
      detailTitle: detailTitle,
      onClose: onClose,
    );
  }
  return TrackerInfoItem(
    key: Key(trackerInfo.id),
    trackerInfo: trackerInfo,
    isLive: isLive,
    onClose: onClose,
    detailTitle: detailTitle,
    latest: latest,
    loadPackageIcon: loadPackageIcon,
    cachedPackageIconOf: cachedPackageIconOf,
  );
}'''),
    ])

    register('lib/views/connection/requests.dart', 'records/requests_view.dart', [
        ('''import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';''', '''import 'dart:async';

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

void _ignoreColumnWidths(Map<String, double> _) {}'''),
        ('''class RequestsView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final RequestFeed? initialFeed;
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const RequestsView({
    super.key,
    this.scrollController,
    this.initialFeed,
    @visibleForTesting this.connectionsReader,
  });

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView>
    with RouteMotionHoldMixin<RequestsView> {
  final _recent = TrackerInfoListController();
  final _live = TrackerInfoListController();
  final _liveFeed = GlobalKey<_LiveFeedState>();
  late final _filters = trackerInfoFilterController(ref, 'requests');
  late var _feed =
      widget.initialFeed ?? ref.read(appSettingProvider).requestFeed;

  @override
  void initState() {
    super.initState();
    if (_feed == RequestFeed.recent) {
      _showLatestRequests();
    }
    ref.listenManual(requestsProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      updateRequestsThrottler();
    });
  }

  @override
  void dispose() {
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
    _recent.resumeAutoScrollToEnd(ref.read(requestsProvider).list);
    _filters.offer(_recent.value.trackerInfos);
  }

  void updateRequestsThrottler() {
    throttler.call(FunctionTag.requests, () {
      if (!mounted || _feed != RequestFeed.recent) {
        return;
      }
      updateWhenRouteSettled(
        () => _setRequests(ref.read(requestsProvider).list),
      );
    }, duration: renderThrottleDuration);
  }''', '''class RequestsView extends StatefulWidget {
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
  }'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''    if (widget.initialFeed == null) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(requestFeed: feed));
    }''', '    widget.onFeedChanged?.call(feed);'),
        ('''    if (_feed != RequestFeed.live) {
      return const [];
    }''', '''    if (_feed != RequestFeed.live || widget.onCloseAllConnections == null) {
      return const [];
    }'''),
        ('''      RequestFeed.recent => _RecentFeed(
        listController: _recent,
        filters: _filters,
        scrollController: widget.scrollController,
        onResumeToEnd: _showLatestRequests,
      ),
      RequestFeed.live => _LiveFeed(
        key: _liveFeed,
        listController: _live,
        filters: _filters,
        scrollController: widget.scrollController,
        connectionsReader: widget.connectionsReader,
      ),''', '''      RequestFeed.recent => _RecentFeed(
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
      ),'''),
        ('''  final ScrollController? scrollController;
  final VoidCallback onResumeToEnd;

  const _RecentFeed({
    required this.listController,
    required this.filters,
    required this.scrollController,
    required this.onResumeToEnd,
  });''', '''  final ScrollController? scrollController;
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
  });'''),
        ('''          child: RecordTableFrame<TrackerInfo>(
            tableId: 'requests',
            items: requests,
            reverse: true,''', '''          child: RecordTableFrame<TrackerInfo>(
            tableId: 'requests',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: requests,
            reverse: true,'''),
        ('''                    table: table,
                    detailTitle: detailTitle,
                  ),''', '''                    table: table,
                    detailTitle: detailTitle,
                    loadPackageIcon: widget.loadPackageIcon,
                    cachedPackageIconOf: widget.cachedPackageIconOf,
                  ),'''),
        ('''                      table: table,
                      detailTitle: detailTitle,
                    ),''', '''                      table: table,
                      detailTitle: detailTitle,
                      loadPackageIcon: widget.loadPackageIcon,
                      cachedPackageIconOf: widget.cachedPackageIconOf,
                    ),'''),
        ('''class _LiveFeed extends ConsumerStatefulWidget {
  final TrackerInfoListController listController;
  final RecordFilterController<TrackerInfo> filters;
  final ScrollController? scrollController;
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const _LiveFeed({
    super.key,
    required this.listController,
    required this.filters,
    required this.scrollController,
    required this.connectionsReader,
  });

  @override
  ConsumerState<_LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends ConsumerState<_LiveFeed>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<_LiveFeed>,
        RouteMotionHoldMixin<_LiveFeed> {
  CoreController get _core => ref.read(coreHandlerProvider);''', '''class _LiveFeed extends StatefulWidget {
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
        RouteMotionHoldMixin<_LiveFeed> {'''),
        ('''  Future<void> closeAll() => _close(_core.closeConnections);''', '''  Future<void> closeAll() {
    final closeAllConnections = widget.onCloseAllConnections;
    if (closeAllConnections == null) return Future.value();
    return _close(closeAllConnections);
  }'''),
        ('''  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      if (connectionsReader != null) {
        return await connectionsReader();
      }
      return ref.read(coreStatusProvider) == CoreStatus.connected
          ? await _core.getConnections()
          : const [];
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }''', '''  Future<List<TrackerInfo>?> _readConnections() async {
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
  }'''),
        ('''  Future<void> _closeConnection(TrackerInfo trackerInfo) =>
      _close(() => _core.closeConnection(trackerInfo.id));

  Future<void> _close(Future<void> Function() close) async {
    await globalState.safeRun(close, title: 'close connections');
    if (mounted) {
      await _refreshConnections();
    }
  }''', '''  ValueChanged<TrackerInfo>? get _onClose => widget.onCloseConnection == null
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
  }'''),
        ('''          child: RecordTableFrame<TrackerInfo>(
            tableId: 'connections',
            items: connections,''', '''          child: RecordTableFrame<TrackerInfo>(
            tableId: 'connections',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: connections,'''),
        ('''                  detailTitle: detailTitle,
                  onClose: _closeConnection,
                );''', '''                  detailTitle: detailTitle,
                  onClose: _onClose,
                  loadPackageIcon: widget.loadPackageIcon,
                  cachedPackageIconOf: widget.cachedPackageIconOf,
                );'''),
        ('''                detailTitle: detailTitle,
                onClose: _closeConnection,
              );''', '''                detailTitle: detailTitle,
                onClose: _onClose,
                loadPackageIcon: widget.loadPackageIcon,
                cachedPackageIconOf: widget.cachedPackageIconOf,
              );'''),
    ])

    register('lib/views/dns_queries.dart', 'records/dns_queries_view.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';''', '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../datetime.dart';
import '../fixed.dart';
import '../localizations.dart';
import '../scaffold/scaffold.dart';
import '../ui/null_status_illustration.dart';
import '../widgets/record.dart';
import '../widgets/record_feed_list.dart';
import '../widgets/record_table.dart';
import 'connection_models.dart';
import 'filter.dart';
import 'model.dart';
import 'types.dart';

void _ignoreColumnWidths(Map<String, double> _) {}'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class DnsQueriesView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const DnsQueriesView({super.key, this.scrollController});

  @override
  ConsumerState<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends ConsumerState<DnsQueriesView>
    with RouteMotionHoldMixin<DnsQueriesView> {
  final _listController = DnsQueryListController();
  final _filters = RecordFilterController<DnsQuery>(facets: dnsQueryFacets);
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        sheetScrollController(context, initialScrollOffset: double.maxFinite);
    _setDnsQueries(ref.read(dnsQueriesProvider).list);
    ref.listenManual(dnsQueriesProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      _updateDnsQueriesThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _filters.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _setDnsQueries(List<DnsQuery> dnsQueries) {
    _listController.setDnsQueries(dnsQueries);
    _filters.offer(_listController.value.dnsQueries);
  }

  void _updateDnsQueriesThrottler() {
    throttler.call(FunctionTag.dnsQueries, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(
        () => _setDnsQueries(ref.read(dnsQueriesProvider).list),
      );
    }, duration: renderThrottleDuration);
  }

  Future<void> _clearDnsCache() async {
    final appLocalizations = KitLocalizations.of(context);
    var cleared = false;
    try {
      await ref.read(coreHandlerProvider).clearDnsCache();
      cleared = true;
    } catch (error) {
      commonPrint.log(
        'clearDnsCache error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!mounted) {
      return;
    }
    dialogs.showBanner(
      cleared
          ? appLocalizations.dnsCacheCleared
          : appLocalizations.clearDnsCacheFailed,
      level: cleared ? BannerLevel.success : BannerLevel.error,
    );
  }''', '''class DnsQueriesView extends StatefulWidget {
  final ScrollController? scrollController;
  final List<DnsQuery> dnsQueries;
  final ValueListenable<List<DnsQuery>>? dnsQueriesListenable;
  final Future<void> Function()? onClearDnsCache;
  final Map<String, double> initialColumnWidths;
  final ValueChanged<Map<String, double>>? onColumnWidthsChanged;

  const DnsQueriesView({
    super.key,
    this.scrollController,
    this.dnsQueries = const [],
    this.dnsQueriesListenable,
    this.onClearDnsCache,
    this.initialColumnWidths = const {},
    this.onColumnWidthsChanged,
  });

  @override
  State<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends State<DnsQueriesView>
    with RouteMotionHoldMixin<DnsQueriesView> {
  final _listController = DnsQueryListController();
  RecordFilterController<DnsQuery>? _filtersInstance;
  Locale? _facetsLocale;
  Timer? _throttleTimer;
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  List<DnsQuery> get _currentDnsQueries =>
      widget.dnsQueriesListenable?.value ?? widget.dnsQueries;

  RecordFilterController<DnsQuery> get _filters => _filtersInstance!;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        sheetScrollController(context, initialScrollOffset: double.maxFinite);
    _listController.setDnsQueries(_currentDnsQueries);
    widget.dnsQueriesListenable?.addListener(_updateDnsQueriesThrottler);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_filtersInstance == null || _facetsLocale != locale) {
      _facetsLocale = locale;
      _filtersInstance?.dispose();
      _filtersInstance = RecordFilterController<DnsQuery>(
        facets: dnsQueryFacetsOf(KitLocalizations.of(context)),
      )..offer(_listController.value.dnsQueries);
    }
  }

  @override
  void didUpdateWidget(DnsQueriesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dnsQueriesListenable != widget.dnsQueriesListenable) {
      oldWidget.dnsQueriesListenable?.removeListener(
        _updateDnsQueriesThrottler,
      );
      widget.dnsQueriesListenable?.addListener(_updateDnsQueriesThrottler);
    }
    if (widget.dnsQueriesListenable == null &&
        !identical(oldWidget.dnsQueries, widget.dnsQueries)) {
      _updateDnsQueriesThrottler();
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    widget.dnsQueriesListenable?.removeListener(_updateDnsQueriesThrottler);
    _listController.dispose();
    _filtersInstance?.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _setDnsQueries(List<DnsQuery> dnsQueries) {
    _listController.setDnsQueries(dnsQueries);
    _filters.offer(_listController.value.dnsQueries);
  }

  void _updateDnsQueriesThrottler() {
    _throttleTimer ??= Timer(renderThrottleDuration, () {
      _throttleTimer = null;
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(() => _setDnsQueries(_currentDnsQueries));
    });
  }

  Future<void> _clearDnsCache() async {
    final onClearDnsCache = widget.onClearDnsCache;
    if (onClearDnsCache == null) return;
    final appLocalizations = KitLocalizations.of(context);
    var cleared = false;
    try {
      await onClearDnsCache();
      cleared = true;
    } catch (error) {
      debugPrint('clearDnsCache error: $error');
    }
    if (!mounted) {
      return;
    }
    BannerHost.maybeOf(context)?.show(
      cleared
          ? appLocalizations.dnsCacheCleared
          : appLocalizations.clearDnsCacheFailed,
      level: cleared ? BannerLevel.success : BannerLevel.error,
    );
  }'''),
        ('title: PageLabel.dns.label,', "title: 'DNS',"),
        ('''          iconActions: [
            IconButtonData(
              glyph: AppGlyphs.broom,
              tooltip: appLocalizations.clearDnsCache,
              onPressed: _clearDnsCache,
            ),
          ],''', '''          iconActions: [
            if (widget.onClearDnsCache != null)
              IconButtonData(
                glyph: AppGlyphs.broom,
                tooltip: appLocalizations.clearDnsCache,
                onPressed: _clearDnsCache,
              ),
          ],'''),
        ('final dnsQueries = _filters.apply(state.list);', 'final dnsQueries = _filters.apply(state.listOf(appLocalizations));'),
        ('''          child: RecordTableFrame<DnsQuery>(
            tableId: 'dns',
            items: dnsQueries,''', '''          child: RecordTableFrame<DnsQuery>(
            tableId: 'dns',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: dnsQueries,'''),
        ('''                    _listController.resumeAutoScrollToEnd(
                      ref.read(dnsQueriesProvider).list,
                    );''', '''                    _listController.resumeAutoScrollToEnd(_currentDnsQueries);'''),
        ('RecordFilter(RecordFacetKind.initiator, initiator.label)', 'RecordFilter(RecordFacetKind.initiator, initiator.labelOfStrings(appLocalizations))'),
        ('sortKey: (query) => query.initiator?.label ?? \'\',', 'sortKey: (query) => query.initiator?.labelOfStrings(appLocalizations) ?? \'\','),
        ('for (final filter in dnsQuery.resultFilters)', 'for (final filter in dnsQuery.resultFiltersOf(KitLocalizations.of(context)))'),
        ('(appLocalizations.initiator, dnsQuery.initiator?.label ?? \'\'),', '(appLocalizations.initiator, dnsQuery.initiator?.labelOfStrings(appLocalizations) ?? \'\'),'),
        ('dialogs.showBanner(KitLocalizations.of(context).copySuccess);', 'BannerHost.maybeOf(context)?.show(KitLocalizations.of(context).copySuccess);'),
    ])

    register('lib/views/logs.dart', 'records/logs_view.dart', [
        ('''import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';''', '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../fixed.dart';
import '../localizations.dart';
import '../scaffold/scaffold.dart';
import '../ui/fonts.dart';
import '../ui/null_status_illustration.dart';
import '../widgets/record.dart';
import '../widgets/record_feed_list.dart';
import 'connection_models.dart';
import 'filter.dart';
import 'log_payload.dart';
import 'model.dart';
import 'types.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView>
    with RouteMotionHoldMixin<LogsView> {
  final _listController = LogListController();
  final _filters = RecordFilterController<Log>(facets: logFacets);
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(
      context,
      initialScrollOffset: double.maxFinite,
    );
    _setLogs(ref.read(logsProvider).list);
    ref.listenManual(logsProvider.select((state) => state.revision), (_, _) {
      updateLogsThrottler();
    });
  }

  List<IconButtonData> _buildActions() {
    return [
      IconButtonData(
        glyph: AppGlyphs.export,
        tooltip: KitLocalizations.of(context).exportLogs,
        onPressed: _handleExport,
      ),
    ];
  }

  @override
  void dispose() {
    _listController.dispose();
    _filters.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = KitLocalizations.of(context);
    final res = await globalState.safeRun<bool>(() async {
      return ref.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    unawaited(
      dialogs.showAlert(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.exportSuccess),
      ),
    );
  }

  void _setLogs(List<Log> logs) {
    _listController.setLogs(logs);
    _filters.offer(_listController.value.logs);
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(() => _setLogs(ref.read(logsProvider).list));
    }, duration: renderThrottleDuration);
  }''', '''class LogsView extends StatefulWidget {
  final ScrollController? scrollController;
  final List<Log> logs;
  final ValueListenable<List<Log>>? logsListenable;
  final Future<bool> Function()? onExport;

  const LogsView({
    super.key,
    this.scrollController,
    this.logs = const [],
    this.logsListenable,
    this.onExport,
  });

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView>
    with RouteMotionHoldMixin<LogsView> {
  final _listController = LogListController();
  final _filters = RecordFilterController<Log>(facets: logFacets);
  Timer? _throttleTimer;
  late final ScrollController _scrollController;
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => _listController.value.autoScrollToEnd,
  );

  List<Log> get _currentLogs => widget.logsListenable?.value ?? widget.logs;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        sheetScrollController(context, initialScrollOffset: double.maxFinite);
    _setLogs(_currentLogs);
    widget.logsListenable?.addListener(updateLogsThrottler);
  }

  @override
  void didUpdateWidget(LogsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logsListenable != widget.logsListenable) {
      oldWidget.logsListenable?.removeListener(updateLogsThrottler);
      widget.logsListenable?.addListener(updateLogsThrottler);
    }
    if (widget.logsListenable == null &&
        !identical(oldWidget.logs, widget.logs)) {
      updateLogsThrottler();
    }
  }

  List<IconButtonData> _buildActions() {
    if (widget.onExport == null) {
      return const [];
    }
    return [
      IconButtonData(
        glyph: AppGlyphs.export,
        tooltip: KitLocalizations.of(context).exportLogs,
        onPressed: _handleExport,
      ),
    ];
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    widget.logsListenable?.removeListener(updateLogsThrottler);
    _listController.dispose();
    _filters.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  Future<void> _handleExport() async {
    final onExport = widget.onExport;
    if (onExport == null) return;
    final appLocalizations = KitLocalizations.of(context);
    var exported = false;
    try {
      exported = await onExport();
    } catch (error) {
      if (mounted) {
        BannerHost.maybeOf(
          context,
        )?.show(error.toString(), level: BannerLevel.error);
      }
      return;
    }
    if (!exported || !mounted) return;
    unawaited(
      showFloatingDialog<void>(
        context: context,
        child: AlertDialog(
          title: appLocalizations.tip,
          child: Text(appLocalizations.exportSuccess),
        ),
      ),
    );
  }

  void _setLogs(List<Log> logs) {
    _listController.setLogs(logs);
    _filters.offer(_listController.value.logs);
  }

  void updateLogsThrottler() {
    _throttleTimer ??= Timer(renderThrottleDuration, () {
      _throttleTimer = null;
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(() => _setLogs(_currentLogs));
    });
  }'''),
        ('_listController.resumeAutoScrollToEnd(ref.read(logsProvider).list);', '_listController.resumeAutoScrollToEnd(_currentLogs);'),
    ])
