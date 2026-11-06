// Derived from chen08209/FlClash, lib/views/logs.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';

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
import 'types.dart';

class LogListController extends ValueNotifier<LogsState> {
  LogListController() : super(const LogsState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setLogs(List<Log> logs) {
    if (identical(logs, value.logs)) {
      return;
    }
    value = value.copyWith(
      logs: value.autoScrollToEnd
          ? logs
          : retainTrimmedHead(value.logs, logs, pausedMaxLogsLength),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<Log> logs) {
    value = value.copyWith(autoScrollToEnd: true, logs: logs);
  }
}

class LogsView extends StatefulWidget {
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
  }

  @override
  Widget build(BuildContext context) {
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
          iconActions: _buildActions(),
          keywords: _filters.keywordsOf(pinned: pinned),
          menuItems: _filters.menuItems(context, pinned: pinned),
          searchState: AppBarSearchState(onSearch: _listController.search),
          title: KitLocalizations.of(context).logs,
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
        final logs = _filters.apply(state.list);
        return NullStatusSwitcher(
          isEmpty: logs.isEmpty,
          isSearching: state.isSearching || _filters.isFiltering,
          nullStatus: NullStatus(
            illustration: NullStatusIllustration.logs,
            label: appLocalizations.nullTip(appLocalizations.logs),
          ),
          child: _buildList(context, state, logs),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, LogsState state, List<Log> logs) {
    final padding = EdgeInsets.only(
      top: context.contentTopPadding,
      bottom: 16 + context.bottomInset,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: FloatingScrollbar(
        controller: _scrollController,
        hintBuilder: (fraction) {
          final index = (fraction * (logs.length - 1)).round();
          return logs[index].dateTime;
        },
        child: ScrollToEndBox(
          onCancelToEnd: () {
            _listController.setAutoScrollToEnd(false);
          },
          onResumeToEnd: () {
            _listController.resumeAutoScrollToEnd(_currentLogs);
            _filters.offer(_listController.value.logs);
          },
          controller: _scrollController,
          enable: state.autoScrollToEnd,
          child: RecordFeedList<Log>(
            physics: _physics,
            reverse: true,
            shrinkWrap: true,
            controller: _scrollController,
            padding: padding,
            items: logs,
            keyOf: ObjectKey.new,
            gap: recordListGap,
            estimatedItemExtent: recordListEstimatedExtent,
            itemBuilder: (log, _, _) => MemoBuilder(
              inputs: [log],
              builder: (_) => LogItem(log: log),
            ),
          ),
        ),
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;

  const LogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final tone = switch (log.logLevel) {
      LogLevel.warning => RecordTone.warning,
      LogLevel.error => RecordTone.error,
      LogLevel.info || LogLevel.debug || LogLevel.silent => RecordTone.neutral,
    };
    final payload = log.parsed;
    return RecordListItem(
      onTap: () {},
      header: RecordHeader(
        children: [
          RecordTimestamp(log.dateTime),
          RecordLabel(
            label: log.logLevel.name,
            tone: tone,
            onPressed: () => RecordFilterScope.add(
              context,
              RecordFilter(RecordFacetKind.level, log.logLevel.name),
            ),
          ),
        ],
      ),
      body: _LogBody(payload: payload, errorColor: tone.accentColor(context)),
    );
  }
}

class _LogBody extends StatelessWidget {
  final LogPayload payload;
  final Color? errorColor;

  const _LogBody({required this.payload, this.errorColor});

  String get _sourceText => [
    payload.tag,
    if (payload.route case final route?) ...[route.source, route.sourceDetail],
  ].where((text) => text.isNotEmpty).join('  ·  ');

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final route = payload.route;
    if (route == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(payload.message, style: styles.primary),
          if (payload.tag.isNotEmpty)
            Text(payload.tag, style: styles.secondary),
        ],
      );
    }
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(text: route.destination, style: styles.title),
          if (route.error.isNotEmpty)
            TextSpan(
              text: '\n${route.error}',
              style: styles.secondary.copyWith(color: errorColor),
            ),
          const TextSpan(text: '\n'),
          if (route.rule.isNotEmpty) ...[
            TextSpan(text: route.rule, style: styles.secondary),
            TextSpan(text: ' \u2192 ', style: styles.secondary.toJetBrainsMono),
          ],
          TextSpan(
            text: route.proxy,
            style: AppTextStyle.footnote
                .of(context, emphasized: true)
                .copyWith(color: context.colorScheme.primary),
          ),
          TextSpan(text: '\n$_sourceText', style: styles.secondary),
        ],
      ),
    );
  }
}
