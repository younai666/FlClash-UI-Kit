// Derived from chen08209/FlClash, lib/views/dns_queries.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

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

void _ignoreColumnWidths(Map<String, double> _) {}

class DnsQueryListController extends ValueNotifier<DnsQueriesState> {
  DnsQueryListController() : super(const DnsQueriesState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setDnsQueries(List<DnsQuery> dnsQueries) {
    if (identical(dnsQueries, value.dnsQueries)) {
      return;
    }
    value = value.copyWith(
      dnsQueries: value.autoScrollToEnd
          ? dnsQueries
          : retainTrimmedHead(
              value.dnsQueries,
              dnsQueries,
              pausedMaxDnsQueriesLength,
            ),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<DnsQuery> dnsQueries) {
    value = value.copyWith(autoScrollToEnd: true, dnsQueries: dnsQueries);
  }
}

class DnsQueriesView extends StatefulWidget {
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
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final body = RecordFilterScope(
      onFilter: _filters.add,
      child: _buildBody(context),
    );
    return ListenableBuilder(
      listenable: Listenable.merge([_filters, _filters.options]),
      child: body,
      builder: (context, body) {
        final pinned = !ViewScope.isMobileOf(context);
        return Scaffold(
          title: 'DNS',
          searchState: AppBarSearchState(onSearch: _listController.search),
          keywords: _filters.keywordsOf(pinned: pinned),
          menuItems: _filters.menuItems(context, pinned: pinned),
          iconActions: [
            if (widget.onClearDnsCache != null)
              IconButtonData(
                glyph: AppGlyphs.broom,
                tooltip: appLocalizations.clearDnsCache,
                onPressed: _clearDnsCache,
              ),
          ],
          body: body!,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_listController, _filters]),
      builder: (context, _) {
        final state = _listController.value;
        final dnsQueries = _filters.apply(state.listOf(appLocalizations));
        return NullStatusSwitcher(
          isEmpty: dnsQueries.isEmpty,
          isSearching: state.isSearching || _filters.isFiltering,
          nullStatus: NullStatus(
            label: appLocalizations.nullTip(appLocalizations.dnsQueries),
            illustration: NullStatusIllustration.dns,
          ),
          child: RecordTableFrame<DnsQuery>(
            tableId: 'dns',
            initialColumnWidths: widget.initialColumnWidths,
            onColumnWidthsChanged:
                widget.onColumnWidthsChanged ?? _ignoreColumnWidths,
            items: dnsQueries,
            reverse: true,
            columnsOf: (width) =>
                _dnsQueryColumns(context, wide: width >= recordWideTableWidth),
            builder: (context, table, dnsQueries) => Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (dnsQueries.length - 1)).round();
                  return dnsQueries[index].time.showFull;
                },
                child: ScrollToEndBox(
                  controller: _scrollController,
                  enable: state.autoScrollToEnd,
                  onCancelToEnd: () {
                    _listController.setAutoScrollToEnd(false);
                  },
                  onResumeToEnd: () {
                    _listController.resumeAutoScrollToEnd(_currentDnsQueries);
                    _filters.offer(_listController.value.dnsQueries);
                  },
                  child: RecordFeedList<DnsQuery>(
                    reverse: true,
                    shrinkWrap: true,
                    physics: _physics,
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: context.contentTopPadding,
                      bottom: 16 + context.bottomInset,
                    ),
                    items: dnsQueries,
                    keyOf: ObjectKey.new,
                    gap: table == null ? recordListGap : 0,
                    estimatedItemExtent:
                        table?.rowHeight ?? recordListEstimatedExtent,
                    itemBuilder: (dnsQuery, striped, _) => MemoBuilder(
                      inputs: [
                        dnsQuery,
                        if (table != null) ...[table, striped],
                      ],
                      builder: (_) => table == null
                          ? DnsQueryItem(dnsQuery: dnsQuery)
                          : _DnsQueryTableRow(
                              dnsQuery: dnsQuery,
                              table: table,
                              striped: striped,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showDnsQueryDetail(BuildContext context, DnsQuery dnsQuery) {
  showSheet<void>(
    context: context,
    builder: (_) {
      return Scaffold(
        body: DnsQueryDetailView(dnsQuery: dnsQuery),
        title: KitLocalizations.of(context).details('DNS'),
      );
    },
  );
}

List<RecordColumn<DnsQuery>> _dnsQueryColumns(
  BuildContext context, {
  required bool wide,
}) {
  final appLocalizations = KitLocalizations.of(context);
  return [
    RecordColumn(
      TableColumn('time', appLocalizations.time, width: 80),
      cell: (_, query) =>
          RecordCellText(query.time.showTime.trim(), muted: true),
      sortKey: (query) => query.time,
      descendingFirst: true,
    ),
    RecordColumn(
      TableColumn('domain', appLocalizations.domain, flex: 1.3),
      cell: (_, query) => RecordCellText(query.domain),
      sortKey: (query) => query.domain.toLowerCase(),
    ),
    RecordColumn(
      TableColumn('type', appLocalizations.ipType, width: 72),
      cell: (_, query) =>
          _DnsKeyword(RecordFilter(RecordFacetKind.type, query.type)),
      sortKey: (query) => query.type,
    ),
    RecordColumn(
      TableColumn('initiator', appLocalizations.initiatorShort, width: 72),
      cell: (_, query) => switch (query.initiator) {
        final initiator? => _DnsKeyword(
          RecordFilter(RecordFacetKind.initiator, initiator.labelOfStrings(appLocalizations)),
        ),
        null => const RecordCellText(''),
      },
      sortKey: (query) => query.initiator?.labelOfStrings(appLocalizations) ?? '',
    ),
    RecordColumn(
      TableColumn('result', appLocalizations.result, flex: 1),
      cell: (_, query) => _DnsResult(query),
      sortKey: (query) => query.summary.toLowerCase(),
    ),
    if (wide)
      RecordColumn(
        TableColumn('upstream', appLocalizations.source, flex: 0.8),
        cell: (_, query) => RecordCellText(query.upstream, muted: true),
        sortKey: (query) => query.upstream.toLowerCase(),
      ),
    RecordColumn(
      TableColumn('elapsed', appLocalizations.elapsed, width: 76, end: true),
      cell: (_, query) => RecordCellText('${query.delay} ms', muted: true),
      sortKey: (query) => query.delay,
      descendingFirst: true,
    ),
  ];
}

class _DnsKeyword extends StatelessWidget {
  final RecordFilter filter;
  final RecordTone tone;

  const _DnsKeyword(this.filter, {this.tone = RecordTone.neutral});

  @override
  Widget build(BuildContext context) {
    return RecordLabel(
      label: filter.value,
      tone: tone,
      onPressed: () => RecordFilterScope.add(context, filter),
    );
  }
}

class _DnsResult extends StatelessWidget {
  final DnsQuery dnsQuery;

  const _DnsResult(this.dnsQuery);

  @override
  Widget build(BuildContext context) {
    final summary = dnsQuery.summary;
    return Row(
      spacing: 6,
      children: [
        for (final filter in dnsQuery.resultFiltersOf(KitLocalizations.of(context)))
          if (filter.kind != RecordFacetKind.initiator)
            _DnsKeyword(
              filter,
              tone: filter.kind == RecordFacetKind.rcode
                  ? RecordTone.error
                  : RecordTone.neutral,
            ),
        if (summary.isNotEmpty)
          Flexible(
            child: Text(
              summary,
              style: TextStyle(
                color: dnsQuery.isFailed
                    ? context.colorScheme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _DnsQueryTableRow extends StatelessWidget {
  final DnsQuery dnsQuery;
  final RecordTable<DnsQuery> table;
  final bool striped;

  const _DnsQueryTableRow({
    required this.dnsQuery,
    required this.table,
    required this.striped,
  });

  @override
  Widget build(BuildContext context) {
    return RecordTableRow(
      table: table,
      striped: striped,
      onTap: () => _showDnsQueryDetail(context, dnsQuery),
      cells: table.cellsOf(context, dnsQuery),
    );
  }
}

class DnsQueryItem extends StatelessWidget {
  final DnsQuery dnsQuery;

  const DnsQueryItem({super.key, required this.dnsQuery});

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final tone = dnsQuery.isFailed ? RecordTone.error : RecordTone.neutral;
    final summary = dnsQuery.summary;
    return RecordListItem(
      onTap: () => _showDnsQueryDetail(context, dnsQuery),
      header: RecordHeader(
        trailing: Text('${dnsQuery.delay} ms'),
        children: [
          RecordTimestamp(dnsQuery.time.showFull),
          _DnsKeyword(RecordFilter(RecordFacetKind.type, dnsQuery.type)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(dnsQuery.domain, style: styles.title),
          if (summary.isNotEmpty)
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.secondary.copyWith(
                color: tone.accentColor(context),
              ),
            ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final filter in dnsQuery.resultFiltersOf(KitLocalizations.of(context)))
                _DnsKeyword(
                  filter,
                  tone: filter.kind == RecordFacetKind.rcode
                      ? RecordTone.error
                      : RecordTone.neutral,
                ),
              if (dnsQuery.upstream.isNotEmpty)
                Text(dnsQuery.upstream, style: styles.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class DnsQueryDetailView extends StatelessWidget {
  final DnsQuery dnsQuery;

  const DnsQueryDetailView({super.key, required this.dnsQuery});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final entries = [
      (appLocalizations.time, dnsQuery.time.showFull),
      (appLocalizations.domain, dnsQuery.domain),
      (appLocalizations.recordType, dnsQuery.type),
      (appLocalizations.initiator, dnsQuery.initiator?.labelOfStrings(appLocalizations) ?? ''),
      (appLocalizations.source, dnsQuery.upstream),
      (
        appLocalizations.cache,
        dnsQuery.cached ? appLocalizations.yes : appLocalizations.no,
      ),
      (appLocalizations.responseCode, dnsQuery.rcode),
      (appLocalizations.delay, '${dnsQuery.delay} ms'),
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
        bottom: 20 + context.bottomInset,
        top: context.sectionsTopPadding,
      ),
      children: [
        generateSection(
          title: appLocalizations.basicInfo,
          items: [
            for (final (title, value) in entries)
              if (value.isNotEmpty) DetailRow.text(title: title, value: value),
          ],
        ),
        if (dnsQuery.error.isNotEmpty)
          generateSection(
            title: appLocalizations.error,
            items: [_ErrorRow(error: dnsQuery.error)],
          ),
        if (dnsQuery.answers.isNotEmpty)
          generateSection(
            title: appLocalizations.answers,
            items: [
              for (final answer in dnsQuery.answers)
                DetailRow(title: answer, copyText: answer),
            ],
          ),
      ],
    );
  }
}

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  BannerHost.maybeOf(context)?.show(KitLocalizations.of(context).copySuccess);
}

class _ErrorRow extends StatelessWidget {
  final String error;

  const _ErrorRow({required this.error});

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      onPressed: () => _copy(context, error),
      minVerticalPadding: 14,
      title: Text(
        error,
        style: AppTextStyle.subheadline
            .of(context)
            .copyWith(color: context.colorScheme.error),
      ),
    );
  }
}
