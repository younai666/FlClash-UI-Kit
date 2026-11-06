// Derived from chen08209/FlClash, lib/features/connection/tracker_info_list.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
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
import 'types.dart';

class TrackerInfoListController extends ValueNotifier<TrackerInfosState> {
  TrackerInfoListController() : super(const TrackerInfosState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setTrackerInfos(List<TrackerInfo> trackerInfos) {
    if (identical(trackerInfos, value.trackerInfos)) {
      return;
    }
    value = value.copyWith(
      trackerInfos: value.autoScrollToEnd
          ? trackerInfos
          : retainTrimmedHead(
              value.trackerInfos,
              trackerInfos,
              pausedMaxRequestsLength,
              keyOf: (trackerInfo) => trackerInfo.id,
            ),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<TrackerInfo> trackerInfos) {
    value = value.copyWith(autoScrollToEnd: true, trackerInfos: trackerInfos);
  }
}

RecordFilterController<TrackerInfo> trackerInfoFilterController({
  RecordGrouping? grouping,
  ValueChanged<RecordGrouping?>? onGroupingChanged,
}) {
  return RecordFilterController(
    facets: trackerInfoFacets,
    groupers: trackerInfoGroupers,
    grouping: grouping,
    onGroupingChanged: onGroupingChanged,
  );
}

class TrackerInfoList extends StatelessWidget {
  final List<TrackerInfo> trackerInfos;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
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
  });

  @override
  Widget build(BuildContext context) {
    final table = this.table;
    return RecordFeedList<TrackerInfo>(
      reverse: reverse,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      padding: padding,
      items: trackerInfos,
      keyOf: (trackerInfo) => ValueKey(trackerInfo.id),
      gap: table == null ? recordListGap : 0,
      estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
      itemBuilder: (trackerInfo, striped, latest) => MemoBuilder(
        inputs: table == null
            ? [..._shownInList(trackerInfo), detailTitle]
            : [trackerInfo, table, striped],
        builder: (_) => _buildTrackerInfoItem(
          trackerInfo,
          isLive: false,
          detailTitle: detailTitle,
          table: table,
          striped: striped,
          onClose: onClose,
          latest: latest,
          loadPackageIcon: loadPackageIcon,
          cachedPackageIconOf: cachedPackageIconOf,
        ),
      ),
    );
  }
}

/// What a finished row shows: it leaves out the traffic a request still
/// reports, which would rebuild the rows on screen at every refresh.
List<Object?> _shownInList(TrackerInfo trackerInfo) => [
  trackerInfo.start,
  trackerInfo.metadata,
  trackerInfo.chains,
  trackerInfo.rule,
  trackerInfo.rulePayload,
];

/// Same rows as [TrackerInfoList], but diffed by connection id so closed
/// connections collapse out and surviving rows slide to their new slot.
class TrackerInfoAnimatedList extends StatelessWidget {
  final List<TrackerInfo> trackerInfos;
  final String detailTitle;
  final RecordTable<TrackerInfo>? table;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
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
  });

  @override
  Widget build(BuildContext context) {
    final table = this.table;
    final positions = table == null
        ? const <String, int>{}
        : {
            for (final (index, trackerInfo) in trackerInfos.indexed)
              trackerInfo.id: index,
          };
    return ArrivalCacheExtentBuilder(
      builder: (cacheExtent) => KeyedAnimatedList<TrackerInfo>(
        controller: controller,
        padding: padding,
        scrollCacheExtent: cacheExtent,
        items: trackerInfos,
        keyOf: (trackerInfo) => trackerInfo.id,
        estimatedItemExtent: table?.rowHeight ?? recordListEstimatedExtent,
        separator: table == null ? const SizedBox(height: recordListGap) : null,
        itemBuilder: (itemContext, trackerInfo) {
          final striped = positions[trackerInfo.id]?.isOdd ?? false;
          return MemoBuilder(
            key: Key(trackerInfo.id),
            // A live row reads its age off the clock, which moves on its own.
            inputs: [
              trackerInfo,
              ...table == null
                  ? [
                      detailTitle,
                      trackerInfo.start.getLastUpdateTimeDesc(
                        itemContext,
                        compact: true,
                      ),
                    ]
                  : [table, striped],
            ],
            builder: (_) => _buildTrackerInfoItem(
              trackerInfo,
              isLive: true,
              detailTitle: detailTitle,
              table: table,
              striped: striped,
              onClose: onClose,
              loadPackageIcon: loadPackageIcon,
              cachedPackageIconOf: cachedPackageIconOf,
            ),
          );
        },
      ),
    );
  }
}

class TrackerInfoGroupedList extends StatefulWidget {
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

class _TrackerInfoGroupedListState extends State<TrackerInfoGroupedList> {
  Map<String, TrackerInfo>? _byId;

  @override
  void didUpdateWidget(TrackerInfoGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.groups, widget.groups)) {
      _byId = null;
    }
  }

  TrackerInfo _latest(TrackerInfo trackerInfo) =>
      (_byId ??= {
        for (final group in widget.groups)
          for (final item in group.items) item.id: item,
      })[trackerInfo.id] ??
      trackerInfo;

  @override
  Widget build(BuildContext context) {
    final TrackerInfoGroupedList(
      :grouping,
      :isLive,
      :detailTitle,
      :table,
      :onClose,
    ) = widget;
    final loadIcon = grouping == RecordGrouping.app ? widget.loadPackageIcon : null;
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
          : null,
      trailingOf: isLive ? (group) => _buildSpeed(context, group.items) : null,
      itemBuilder: (_, trackerInfo, index) {
        final striped = index.isOdd;
        return MemoBuilder(
          key: Key(trackerInfo.id),
          inputs: [
            ...showsTraffic ? [trackerInfo] : _shownInList(trackerInfo),
            detailTitle,
            table,
            striped,
            if (isLive && table == null)
              trackerInfo.start.getLastUpdateTimeDesc(context, compact: true),
          ],
          builder: (_) {
            final row = _buildTrackerInfoItem(
              trackerInfo,
              isLive: isLive,
              detailTitle: detailTitle,
              table: table,
              striped: striped,
              onClose: onClose,
              latest: () => _latest(trackerInfo),
              loadPackageIcon: widget.loadPackageIcon,
              cachedPackageIconOf: widget.cachedPackageIconOf,
            );
            return table == null
                ? Padding(
                    padding: const EdgeInsets.only(top: recordListGap),
                    child: row,
                  )
                : row;
          },
        );
      },
    );
  }

  Widget _buildSpeed(BuildContext context, List<TrackerInfo> trackerInfos) {
    var upload = 0;
    var download = 0;
    for (final trackerInfo in trackerInfos) {
      upload += trackerInfo.uploadSpeed ?? 0;
      download += trackerInfo.downloadSpeed ?? 0;
    }
    final color = context.colorScheme.onSurfaceVariant;
    WidgetSpan arrow(Glyph glyph) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GlyphIcon(glyph, size: 12, color: color),
    );
    return Text.rich(
      TextSpan(
        children: [
          arrow(AppGlyphs.arrowUp),
          TextSpan(text: ' ${upload.traffic.show}/s   '),
          arrow(AppGlyphs.arrowDown),
          TextSpan(text: ' ${download.traffic.show}/s'),
        ],
      ),
    );
  }
}

Widget _buildTrackerInfoItem(
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
}
