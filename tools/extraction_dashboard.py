"""Reviewed dashboard status buttons, feed tables, stats, proxy groups, and layout."""


def register_dashboard(register, base):
    register('lib/common/app_update.dart', 'dashboard/app_update.dart', [], excerpt=(
        'sealed class UpdateDownload {',
        '@visibleForTesting',
        '',
        '保留自更新下载状态密封类供仪表盘卡片与顶栏按钮复用；平台安装包校验与进程参数仍在源树',
    ))

    register('lib/views/dashboard/widgets/update_status.dart', 'dashboard/update_status.dart', [
        ('''import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'package:prism_ui/prism_ui.dart';''', '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../dialogs.dart';
import '../format.dart';
import '../localizations.dart';
import 'app_update.dart';
import 'card.dart';
import 'style.dart';'''),
        ('''String _readyTip(AppLocalizations appLocalizations) => system.isWindows
    ? '${appLocalizations.updateReadyTip}\\n${appLocalizations.updateRestartTip}'
    : appLocalizations.updateReadyTip;''', '''String _readyTip(KitLocalizations appLocalizations, {required bool isWindows}) =>
    isWindows
        ? '${appLocalizations.updateReadyTip}\\n${appLocalizations.updateRestartTip}'
        : appLocalizations.updateReadyTip;'''),
        ('''class UpdateStatusSlot extends ConsumerStatefulWidget {
  const UpdateStatusSlot({super.key, required this.gap});

  final double gap;

  @override
  ConsumerState<UpdateStatusSlot> createState() => _UpdateStatusSlotState();
}

class _UpdateStatusSlotState extends ConsumerState<UpdateStatusSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  UpdateDownload? _download;

  @override
  void initState() {
    super.initState();
    _download = ref.read(updateDownloadStateProvider);
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration,
      value: _download == null ? 0 : 1,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    ref.listenManual(updateDownloadStateProvider, (_, next) => _follow(next));
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }''', '''class UpdateStatusSlot extends StatefulWidget {
  const UpdateStatusSlot({
    super.key,
    required this.gap,
    this.download,
    this.downloadListenable,
    this.onInstall,
    this.onDiscard,
    this.onCancel,
    this.isWindows,
  });

  final double gap;
  final UpdateDownload? download;
  final ValueListenable<UpdateDownload?>? downloadListenable;
  final Future<void> Function()? onInstall;
  final Future<void> Function()? onDiscard;
  final VoidCallback? onCancel;
  final bool? isWindows;

  @override
  State<UpdateStatusSlot> createState() => _UpdateStatusSlotState();
}

class _UpdateStatusSlotState extends State<UpdateStatusSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  UpdateDownload? _download;

  UpdateDownload? get _currentDownload =>
      widget.downloadListenable?.value ?? widget.download;

  void _handleListenable() {
    unawaited(_follow(_currentDownload));
  }

  @override
  void initState() {
    super.initState();
    _download = _currentDownload;
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration,
      value: _download == null ? 0 : 1,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    widget.downloadListenable?.addListener(_handleListenable);
  }

  @override
  void didUpdateWidget(UpdateStatusSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downloadListenable != widget.downloadListenable) {
      oldWidget.downloadListenable?.removeListener(_handleListenable);
      widget.downloadListenable?.addListener(_handleListenable);
      unawaited(_follow(_currentDownload));
    } else if (widget.downloadListenable == null &&
        oldWidget.download != widget.download) {
      unawaited(_follow(widget.download));
    }
  }

  @override
  void dispose() {
    widget.downloadListenable?.removeListener(_handleListenable);
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }'''),
        ('          child: RepaintBoundary(child: _UpdateStatusCard(download)),', '''          child: RepaintBoundary(
            child: UpdateStatusCard(
              download: download,
              onInstall: widget.onInstall,
              onDiscard: widget.onDiscard,
              onCancel: widget.onCancel,
              isWindows: widget.isWindows,
            ),
          ),'''),
        ('''class _UpdateStatusCard extends ConsumerWidget {
  const _UpdateStatusCard(this.download);

  final UpdateDownload download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final ready = download is UpdateReady;
    return DashboardCard(
      onTap: ready ? () => unawaited(action.installUpdate()) : null,''', '''class UpdateStatusCard extends StatelessWidget {
  const UpdateStatusCard({
    super.key,
    required this.download,
    this.onInstall,
    this.onDiscard,
    this.onCancel,
    this.isWindows,
  });

  final UpdateDownload download;
  final Future<void> Function()? onInstall;
  final Future<void> Function()? onDiscard;
  final VoidCallback? onCancel;
  final bool? isWindows;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final ready = download is UpdateReady;
    final windows = isWindows ?? (defaultTargetPlatform == TargetPlatform.windows);
    return DashboardCard(
      onTap: ready && onInstall != null ? () => unawaited(onInstall!()) : null,'''),
        ('''                  onPressed: ready
                      ? () => unawaited(action.discardUpdate())
                      : action.cancelUpdateDownload,''', '''                  onPressed: ready
                      ? (onDiscard == null ? null : () => unawaited(onDiscard!()))
                      : onCancel,'''),
        ('              _readyTip(appLocalizations),', '              _readyTip(appLocalizations, isWindows: windows),'),
        ('''class UpdateStatusButton extends ConsumerWidget {
  const UpdateStatusButton({super.key});

  Future<void> _handlePressed(UpdateDownload download, WidgetRef ref) async {
    final appLocalizations = currentAppLocalizations;
    final action = ref.read(commonActionProvider.notifier);
    final res = await dialogs.showMessage(
      title: download is UpdateReady
          ? appLocalizations.updateReady
          : appLocalizations.downloadingUpdate,
      message: TextSpan(
        text: download is UpdateReady
            ? _readyTip(appLocalizations)
            : appLocalizations.stopUpdateDownloadTip,
      ),
      confirmText: download is UpdateReady ? appLocalizations.update : null,
      destructive: download is UpdateDownloading,
    );
    if (res != true) return;
    switch (download) {
      case UpdateReady():
        await action.installUpdate();
      case UpdateDownloading():
        action.cancelUpdateDownload();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final download = ref.watch(updateDownloadStateProvider);
    final appLocalizations = context.appLocalizations;''', '''class UpdateStatusButton extends StatelessWidget {
  const UpdateStatusButton({
    super.key,
    this.download,
    this.downloadListenable,
    this.onInstall,
    this.onCancel,
    this.isWindows,
  });

  final UpdateDownload? download;
  final ValueListenable<UpdateDownload?>? downloadListenable;
  final Future<void> Function()? onInstall;
  final VoidCallback? onCancel;
  final bool? isWindows;

  Future<void> _handlePressed(
    BuildContext context,
    UpdateDownload download,
  ) async {
    final appLocalizations = KitLocalizations.of(context);
    final windows = isWindows ?? (defaultTargetPlatform == TargetPlatform.windows);
    final res = await showKitMessage(
      context,
      title: download is UpdateReady
          ? appLocalizations.updateReady
          : appLocalizations.downloadingUpdate,
      message: TextSpan(
        text: download is UpdateReady
            ? _readyTip(appLocalizations, isWindows: windows)
            : appLocalizations.stopUpdateDownloadTip,
      ),
      confirmText: download is UpdateReady ? appLocalizations.update : null,
      destructive: download is UpdateDownloading,
    );
    if (res != true) return;
    switch (download) {
      case UpdateReady():
        await onInstall?.call();
      case UpdateDownloading():
        onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listenable = downloadListenable;
    if (listenable != null) {
      return ValueListenableBuilder<UpdateDownload?>(
        valueListenable: listenable,
        builder: (context, value, _) => _buildButton(context, value),
      );
    }
    return _buildButton(context, download);
  }

  Widget _buildButton(BuildContext context, UpdateDownload? download) {
    final appLocalizations = KitLocalizations.of(context);'''),
        ('onPressed: () => unawaited(_handlePressed(download, ref)),', 'onPressed: () => unawaited(_handlePressed(context, download)),'),
        ('globalState.measure.textHeight(\n                    AppTextStyle.subheadline,\n                  )', 'MeasureScope.of(context).textHeight(\n                    AppTextStyle.subheadline,\n                  )'),
    ])

    register('test/views/dashboard/update_status_test.dart', '@test/views/dashboard/update_status_test.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/update_status.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import 'package:prism_ui/prism_ui.dart';
import '../../helpers/host_scaffold.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/host_scaffold.dart';
import '../../helpers/test_app.dart';'''),
        ('''  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: HostScaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 380,
                child: DashboardDensityScope(
                  density: DashboardDensity.mobile,
                  scale: 1,
                  child: UpdateStatusSlot(gap: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }''', '''  late ValueNotifier<UpdateDownload?> download;

  setUp(() {
    download = ValueNotifier<UpdateDownload?>(null);
  });

  tearDown(() => download.dispose());

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 380,
              child: DashboardDensityScope(
                density: DashboardDensity.mobile,
                scale: 1,
                child: UpdateStatusSlot(
                  gap: 12,
                  downloadListenable: download,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }'''),
        ('    final download = container.read(updateDownloadStateProvider.notifier);\n', ''),
    ])

    register('lib/views/dashboard/widgets/core_status_button.dart', 'dashboard/core_status_button.dart', [
        ('''import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';''', '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../data.dart';
import '../dialogs.dart';
import '../localizations.dart';'''),
        ('''class CoreStatusButton extends ConsumerStatefulWidget {
  const CoreStatusButton({super.key});

  @override
  ConsumerState<CoreStatusButton> createState() => _CoreStatusButtonState();
}

class _CoreStatusButtonState extends ConsumerState<CoreStatusButton> {
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _holdTimer;
  CoreStatus _status = CoreStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _status = ref.read(coreStatusProvider);
    ref.listenManual(coreStatusProvider, (_, next) {
      _onStatusChanged(next);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }''', '''class CoreStatusButton extends StatefulWidget {
  const CoreStatusButton({
    super.key,
    this.status = CoreStatus.disconnected,
    this.statusListenable,
    this.onRestart,
  });

  final CoreStatus status;
  final ValueListenable<CoreStatus>? statusListenable;
  final Future<void> Function()? onRestart;

  @override
  State<CoreStatusButton> createState() => _CoreStatusButtonState();
}

class _CoreStatusButtonState extends State<CoreStatusButton> {
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _holdTimer;
  CoreStatus _status = CoreStatus.disconnected;

  CoreStatus get _currentStatus =>
      widget.statusListenable?.value ?? widget.status;

  void _handleListenable() {
    _onStatusChanged(_currentStatus);
  }

  @override
  void initState() {
    super.initState();
    _status = _currentStatus;
    widget.statusListenable?.addListener(_handleListenable);
  }

  @override
  void didUpdateWidget(CoreStatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusListenable != widget.statusListenable) {
      oldWidget.statusListenable?.removeListener(_handleListenable);
      widget.statusListenable?.addListener(_handleListenable);
      _onStatusChanged(_currentStatus);
    } else if (widget.statusListenable == null &&
        oldWidget.status != widget.status) {
      _onStatusChanged(widget.status);
    }
  }

  @override
  void dispose() {
    widget.statusListenable?.removeListener(_handleListenable);
    _holdTimer?.cancel();
    super.dispose();
  }'''),
        ('''  Future<void> _handleConnection() async {
    if (_holdTimer != null) {
      return;
    }
    final coreStatus = ref.read(coreStatusProvider);
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final tip = coreStatus == CoreStatus.connected
        ? context.appLocalizations.forceRestartCoreTip
        : context.appLocalizations.restartCoreTip;
    final res = await dialogs.showMessage(message: TextSpan(text: tip));
    if (res != true || !mounted) {
      return;
    }
    try {
      await ref.read(coreActionProvider.notifier).restartCore();
    } catch (error) {
      dialogs.showBanner(error.toString(), level: BannerLevel.error);
    }
  }''', '''  Future<void> _handleConnection() async {
    if (_holdTimer != null || widget.onRestart == null) {
      return;
    }
    final coreStatus = _currentStatus;
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final appLocalizations = KitLocalizations.of(context);
    final tip = coreStatus == CoreStatus.connected
        ? appLocalizations.forceRestartCoreTip
        : appLocalizations.restartCoreTip;
    final res = await showKitMessage(context, message: TextSpan(text: tip));
    if (res != true || !mounted) {
      return;
    }
    try {
      await widget.onRestart!();
    } catch (error) {
      if (mounted) {
        BannerHost.maybeOf(
          context,
        )?.show(error.toString(), level: BannerLevel.error);
      }
    }
  }'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('globalState.measure.textHeight(\n                    AppTextStyle.subheadline,\n                  )', 'MeasureScope.of(context).textHeight(\n                    AppTextStyle.subheadline,\n                  )'),
    ])

    register('test/widgets/core_status_button_test.dart', '@test/widgets/core_status_button_test.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/widgets/core_status_button.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';'''),
        ('''      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => HostScaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );''', '''      final status = ValueNotifier<CoreStatus>(CoreStatus.connected);
      addTearDown(status.dispose);

      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Center(child: CoreStatusButton(statusListenable: status)),
          ),
        ),
      );'''),
        ('''    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    Future<void> pumpAt(Size size) async {
      container.read(viewSizeProvider.notifier).value = size;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => HostScaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }''', '''    final status = ValueNotifier<CoreStatus>(CoreStatus.disconnected);
    addTearDown(status.dispose);
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;

    Future<void> pumpAt(Size size) async {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: Center(child: CoreStatusButton(statusListenable: status)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }'''),
        ('''    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => HostScaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );''', '''    final status = ValueNotifier<CoreStatus>(CoreStatus.connected);
    addTearDown(status.dispose);

    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(child: CoreStatusButton(statusListenable: status)),
        ),
      ),
    );'''),
        ('''    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => HostScaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );''', '''    final status = ValueNotifier<CoreStatus>(CoreStatus.disconnected);
    addTearDown(status.dispose);

    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(child: CoreStatusButton(statusListenable: status)),
        ),
      ),
    );'''),
        ('container.read(coreStatusProvider.notifier).value', 'status.value'),
    ])

    register('lib/views/dashboard/widgets/connections_table.dart', 'dashboard/connections_table.dart', [
        ('''import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/views/dns_queries.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'current_outbound.dart';''', '''import 'dart:async';

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
import 'style.dart';'''),
        ('''enum DashboardFeed {
  connections,
  requests,
  dns;

  String get label => switch (this) {
    connections => currentAppLocalizations.liveConnections,
    requests => currentAppLocalizations.recentRequests,
    dns => PageLabel.dns.label,
  };
}

void openDashboardFeed(BuildContext context, DashboardFeed feed) {
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
        ),
        DashboardFeed.requests => RequestsView(
          scrollController: controller,
          initialFeed: RequestFeed.recent,
        ),
        DashboardFeed.dns => DnsQueriesView(scrollController: controller),
      },
    ),
  );
}''', '''enum DashboardFeed {
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
}'''),
        ('''mixin ConnectionsPolling<T extends ConsumerStatefulWidget>
    on
        ConsumerState<T>,
        WidgetsBindingObserver,
        ActivePollingMixin<T>,
        RouteMotionHoldMixin<T> {
  final connectionCount = ValueNotifier(0);
  List<TrackerInfo> connections = const [];
  var tcpCount = 0;
  var udpCount = 0;

  bool get pollsConnections;

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => Duration(seconds: pollsConnections ? 1 : 2);

  @override
  void dispose() {
    connectionCount.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
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
      if (pollsConnections) {
        final next = [...await _core.getConnections()];
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
      } else {
        final count = await _core.getConnectionCount();
        if (!isCurrent()) return;
        connectionCount.value = count;
      }
    } catch (error) {
      commonPrint.log(
        'dashboard connections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}''', '''mixin ConnectionsPolling<T extends StatefulWidget>
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
}'''),
        ('''class ThrottledCount extends ConsumerStatefulWidget {
  const ThrottledCount({
    super.key,
    required this.provider,
    required this.builder,
  });

  final ProviderListenable<int> provider;
  final Widget Function(BuildContext context, int count) builder;

  @override
  ConsumerState<ThrottledCount> createState() => _ThrottledCountState();
}

class _ThrottledCountState extends ConsumerState<ThrottledCount> {
  late var _count = ref.read(widget.provider);
  late var _latest = _count;
  Timer? _repaint;
  var _active = true;

  @override
  void initState() {
    super.initState();
    ref.listenManual(widget.provider, (_, next) {
      _latest = next;
      if (!_active) {
        return;
      }
      _repaint ??= Timer(renderThrottleDuration, _showLatest);
    });
  }''', '''class ThrottledCount extends StatefulWidget {
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
  }'''),
        ('''  @override
  void dispose() {
    _repaint?.cancel();
    super.dispose();
  }''', '''  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    _repaint?.cancel();
    super.dispose();
  }'''),
        ('''class ConnectionsTableCard extends ConsumerStatefulWidget {
  const ConnectionsTableCard({super.key});

  @override
  ConsumerState<ConnectionsTableCard> createState() =>
      _ConnectionsTableCardState();
}

class _ConnectionsTableCardState extends ConsumerState<ConnectionsTableCard>
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
  void initState() {
    super.initState();
    _takeSnapshot();
    ref.listenManual(
      requestsProvider.select((state) => state.revision),
      (_, _) => _scheduleSnapshot(DashboardFeed.requests),
    );
    ref.listenManual(
      dnsQueriesProvider.select((state) => state.revision),
      (_, _) => _scheduleSnapshot(DashboardFeed.dns),
    );
  }

  @override
  void dispose() {
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
        _requests = ref.read(requestsProvider).list.reversed.toList();
      case DashboardFeed.dns:
        _queries = ref.read(dnsQueriesProvider).list.reversed.toList();
      case DashboardFeed.connections:
        break;
    }
  }

  void _select(DashboardFeed feed) {
    if (feed == _feed) return;
    setState(() {
      _feed = feed;
      if (feed != DashboardFeed.connections) {
        connections = const [];
      }
      _takeSnapshot();
    });
    if (feed == DashboardFeed.connections) {
      stopPolling();
      startPolling();
    }
  }''', '''class ConnectionsTableCard extends StatefulWidget {
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
  }'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('          semanticLabel: feed.label,\n          onTap: () => _select(feed),\n          builder: (foreground) => _FeedSegment(\n            label: feed.label,', '          semanticLabel: feed.labelOf(context),\n          onTap: () => _select(feed),\n          builder: (foreground) => _FeedSegment(\n            label: feed.labelOf(context),'),
        ('''                      segment(
                        DashboardFeed.requests,
                        ThrottledCount(
                          provider: requestCountProvider,
                          builder: (_, count) => _TabCount(count),
                        ),
                      ),
                      segment(
                        DashboardFeed.dns,
                        ThrottledCount(
                          provider: dnsQueryCountProvider,
                          builder: (_, count) => _TabCount(count),
                        ),
                      ),''', '''                      segment(
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
                      ),'''),
        ('''              DashboardFeed.connections => _Table<TrackerInfo>(
                key: const ValueKey(DashboardFeed.connections),
                tableId: 'dashboard.connections',
                items: connections,
                rowHeight: rowHeight,
                columnsOf: (width) => _connectionColumns(context, width),
              ),
              DashboardFeed.requests => _Table<TrackerInfo>(
                key: const ValueKey(DashboardFeed.requests),
                tableId: 'dashboard.requests',
                items: _requests,
                rowHeight: rowHeight,
                columnsOf: (_) => _requestColumns(context),
              ),
              DashboardFeed.dns => _Table<DnsQuery>(
                key: const ValueKey(DashboardFeed.dns),
                tableId: 'dashboard.dns',
                items: _queries,
                rowHeight: rowHeight,
                columnsOf: (_) => _dnsColumns(context),
              ),''', '''              DashboardFeed.connections => _Table<TrackerInfo>(
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
              ),'''),
        ('''class _Table<T> extends ConsumerStatefulWidget {
  const _Table({
    super.key,
    required this.tableId,
    required this.items,
    required this.rowHeight,
    required this.columnsOf,
  });

  final String tableId;
  final List<T> items;
  final double rowHeight;
  final List<RecordColumn<T>> Function(double width) columnsOf;

  @override
  ConsumerState<_Table<T>> createState() => _TableState<T>();
}

class _TableState<T> extends ConsumerState<_Table<T>>
    with TableColumnWidthsMixin<_Table<T>> {
  final _sorter = RecordSorter<T>();
  RecordSort? _sort;

  @override
  String get tableId => widget.tableId;''', '''class _Table<T> extends StatefulWidget {
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
      widget.onColumnWidthsChanged(widths);'''),
        ('cell: (_, query) => _Muted(query.initiator?.label ?? \'—\'),', 'cell: (_, query) => _Muted(query.initiator?.labelOfStrings(appLocalizations) ?? \'—\'),'),
        ('sortKey: (query) => query.initiator?.label ?? \'\',', 'sortKey: (query) => query.initiator?.labelOfStrings(appLocalizations) ?? \'\','),
    ])

    register('lib/views/dashboard/widgets/connection_stats.dart', 'dashboard/connection_stats.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'connections_table.dart';''', '''import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../localizations.dart';
import '../widgets/active_polling.dart';
import 'card.dart';
import 'connections_table.dart';
import 'layout.dart';
import 'style.dart';'''),
        ('''class ConnectionStatsCard extends ConsumerStatefulWidget {
  const ConnectionStatsCard({super.key});

  @override
  ConsumerState<ConnectionStatsCard> createState() =>
      _ConnectionStatsCardState();
}

class _ConnectionStatsCardState extends ConsumerState<ConnectionStatsCard>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<ConnectionStatsCard>,
        RouteMotionHoldMixin<ConnectionStatsCard>,
        ConnectionsPolling<ConnectionStatsCard> {
  static const _inset = 8.0;

  @override
  bool get pollsConnections => false;

  @override
  Widget build(BuildContext context) {
    final shape = AppShape.all(
      dashboardCardRadius(DashboardDensityScope.of(context)) - _inset,
    );
    return DashboardCard(
      semanticLabel: context.appLocalizations.connectionStats,
      padding: const EdgeInsets.all(_inset),
      child: Row(
        children: [
          _Stat(
            feed: DashboardFeed.connections,
            shape: shape,
            count: ValueListenableBuilder(
              valueListenable: connectionCount,
              builder: (context, count, _) => _Count(count),
            ),
          ),
          _Stat(
            feed: DashboardFeed.requests,
            shape: shape,
            count: ThrottledCount(
              provider: requestCountProvider,
              builder: (_, count) => _Count(count),
            ),
          ),
          _Stat(
            feed: DashboardFeed.dns,
            shape: shape,
            count: ThrottledCount(
              provider: dnsQueryCountProvider,
              builder: (_, count) => _Count(count),
            ),
          ),
        ],
      ),
    );
  }
}''', '''class ConnectionStatsCard extends StatefulWidget {
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
}'''),
        ('''class _Stat extends StatelessWidget {
  const _Stat({required this.feed, required this.shape, required this.count});

  final DashboardFeed feed;
  final OutlinedBorder shape;
  final Widget count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressSurface(
        fill: Colors.transparent,
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 10),
        childFills: true,
        onPressed: () => openDashboardFeed(context, feed),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            count,
            Text(
              feed.label,''', '''class _Stat extends StatelessWidget {
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
              feed.labelOf(context),'''),
    ])

    proxy_groups_src = (base / 'lib/views/dashboard/widgets/proxy_groups.dart').read_text(encoding='utf-8')
    show_sheet_fn = proxy_groups_src[
        proxy_groups_src.index('/// The proxies page stays mounted'):
        proxy_groups_src.index('/// Drawn in the proportions')
    ]
    register('lib/views/dashboard/widgets/proxy_groups.dart', 'dashboard/proxy_groups.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/shapes/shapes.dart';

import 'card.dart';
import 'connections_table.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';
import 'package:prism_ui/shapes/shapes.dart';

import '../../icons.dart';
import '../localizations.dart';
import '../proxies/models.dart';
import '../widgets/target_icon.dart';
import 'card.dart';
import 'connections_table.dart';
import 'layout.dart';
import 'style.dart';'''),
        (show_sheet_fn, ''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class _SelectedName extends ConsumerWidget {
  const _SelectedName({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(selectedProxyNameProvider(group.name)) ?? '';
    return EmojiText(
      name.isEmpty ? '—' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DashboardText.label(context),
    );
  }
}

class _TimeoutChip extends ConsumerWidget {
  const _TimeoutChip({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var timedOut = 0;
    for (final group in groups) {
      final delay = ref.watch(
        delayProvider(proxyName: group.name, testUrl: group.testUrl),
      );
      if (delay != null && delay < 0) {
        timedOut++;
      }
    }
    if (timedOut == 0) {
      return const SizedBox.shrink();
    }
    return DashboardChip(
      label: KitLocalizations.of(context).groupTimeoutCount(timedOut),
      tone: DashboardChipTone.warn,
    );
  }
}''', '''class _SelectedName extends StatelessWidget {
  const _SelectedName({required this.group, this.selectedNameOf});

  final Group group;
  final String? Function(String groupName)? selectedNameOf;

  @override
  Widget build(BuildContext context) {
    final name = selectedNameOf?.call(group.name) ?? group.now ?? '';
    return EmojiText(
      name.isEmpty ? '—' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DashboardText.label(context),
    );
  }
}

class _TimeoutChip extends StatelessWidget {
  const _TimeoutChip({required this.groups, this.delayOf});

  final List<Group> groups;
  final int? Function(String proxyName, String? testUrl)? delayOf;

  @override
  Widget build(BuildContext context) {
    var timedOut = 0;
    for (final group in groups) {
      final delay = delayOf?.call(group.name, group.testUrl);
      if (delay != null && delay < 0) {
        timedOut++;
      }
    }
    if (timedOut == 0) {
      return const SizedBox.shrink();
    }
    return DashboardChip(
      label: KitLocalizations.of(context).groupTimeoutCount(timedOut),
      tone: DashboardChipTone.warn,
    );
  }
}'''),
        ('''class _GroupsEmpty extends ConsumerWidget {
  const _GroupsEmpty({this.fit = false});

  /// Scales down into whatever height the card has left.
  final bool fit;

  static const _maxWidth = 260.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final (title, subtitle) = _emptyTextsOf(
      context,
      connected: ref.watch(coreStatusProvider) == CoreStatus.connected,
    );''', '''class _GroupsEmpty extends StatelessWidget {
  const _GroupsEmpty({required this.connected, this.fit = false});

  final bool connected;

  /// Scales down into whatever height the card has left.
  final bool fit;

  static const _maxWidth = 260.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final (title, subtitle) = _emptyTextsOf(context, connected: connected);'''),
        ('''class ProxyGroupsCard extends ConsumerWidget {
  const ProxyGroupsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    if (!density.isDesktop) {
      return const ProxyGroupsSummaryCard();
    }
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);
    final groups = ref.watch(visibleGroupsStateProvider).value;''', '''class ProxyGroupsCard extends StatelessWidget {
  const ProxyGroupsCard({
    super.key,
    this.groups = const [],
    this.connected = true,
    this.selectedNameOf,
    this.delayOf,
    this.onOpenProxies,
  });

  final List<Group> groups;
  final bool connected;
  final String? Function(String groupName)? selectedNameOf;
  final int? Function(String proxyName, String? testUrl)? delayOf;
  final void Function(String? groupName)? onOpenProxies;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    if (!density.isDesktop) {
      return ProxyGroupsSummaryCard(
        groups: groups,
        connected: connected,
        selectedNameOf: selectedNameOf,
        delayOf: delayOf,
        onOpenProxies: onOpenProxies,
      );
    }
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);'''),
        ('''          final tiles = _GroupTiles(
            groups: groups,
            columns: _GroupTiles.columnsFor(
              constraints.maxWidth,
              scale: scale,
              gap: tileGap,
            ),
            height: tileHeight,
            gap: tileGap,
            iconSize: tileHeight - _blockInset * 2,
            bottom: padding.bottom,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GroupsHeader(groups: groups, count: true),
              if (groups.isEmpty)
                const Expanded(child: _GroupsEmpty(fit: true))''', '''          final tiles = _GroupTiles(
            groups: groups,
            selectedNameOf: selectedNameOf,
            onOpenProxies: onOpenProxies,
            columns: _GroupTiles.columnsFor(
              constraints.maxWidth,
              scale: scale,
              gap: tileGap,
            ),
            height: tileHeight,
            gap: tileGap,
            iconSize: tileHeight - _blockInset * 2,
            bottom: padding.bottom,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GroupsHeader(
                groups: groups,
                count: true,
                delayOf: delayOf,
                onOpenProxies: onOpenProxies,
              ),
              if (groups.isEmpty)
                Expanded(
                  child: _GroupsEmpty(connected: connected, fit: true),
                )'''),
        ('''class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({required this.groups, this.count = false});

  final List<Group> groups;
  final bool count;''', '''class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({
    required this.groups,
    this.count = false,
    this.delayOf,
    this.onOpenProxies,
  });

  final List<Group> groups;
  final bool count;
  final int? Function(String proxyName, String? testUrl)? delayOf;
  final void Function(String? groupName)? onOpenProxies;'''),
        ('        _TimeoutChip(groups: groups),', '        _TimeoutChip(groups: groups, delayOf: delayOf),'),
        ('''              onPressed: groups.isEmpty
                  ? null
                  : () => showProxiesSheet(context),''', '''              onPressed: groups.isEmpty || onOpenProxies == null
                  ? null
                  : () => onOpenProxies!(null),'''),
        ('''class _GroupTiles extends StatelessWidget {
  const _GroupTiles({
    required this.groups,
    required this.columns,
    required this.height,
    required this.gap,
    required this.iconSize,
    required this.bottom,
  });

  final List<Group> groups;
  final int columns;
  final double height;
  final double gap;
  final double iconSize;
  final double bottom;''', '''class _GroupTiles extends StatelessWidget {
  const _GroupTiles({
    required this.groups,
    this.selectedNameOf,
    this.onOpenProxies,
    required this.columns,
    required this.height,
    required this.gap,
    required this.iconSize,
    required this.bottom,
  });

  final List<Group> groups;
  final String? Function(String groupName)? selectedNameOf;
  final void Function(String? groupName)? onOpenProxies;
  final int columns;
  final double height;
  final double gap;
  final double iconSize;
  final double bottom;'''),
        ('''          itemBuilder: (context, index) => _GroupTile(
            group: groups[index],
            iconSize: iconSize,
            onTap: () =>
                showProxiesSheet(context, groupName: groups[index].name),
          ),''', '''          itemBuilder: (context, index) => _GroupTile(
            group: groups[index],
            selectedNameOf: selectedNameOf,
            iconSize: iconSize,
            onTap: onOpenProxies == null
                ? null
                : () => onOpenProxies!(groups[index].name),
          ),'''),
        ('''class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.iconSize,
    required this.onTap,
  });

  final Group group;
  final double iconSize;
  final VoidCallback onTap;''', '''class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    this.selectedNameOf,
    required this.iconSize,
    required this.onTap,
  });

  final Group group;
  final String? Function(String groupName)? selectedNameOf;
  final double iconSize;
  final VoidCallback? onTap;'''),
        ('                _SelectedName(group: group),', '                _SelectedName(group: group, selectedNameOf: selectedNameOf),'),
        ('''class ProxyGroupsSummaryCard extends ConsumerWidget {
  const ProxyGroupsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = KitLocalizations.of(context);
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final density = DashboardDensityScope.of(context);
    final figure = _GroupsFigure(
      groups: groups,
      metrics: _figureMetricsOf(density),
    );
    if (density.isDesktop) {
      return DashboardCard(
        semanticLabel: appLocalizations.proxyGroup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupsHeader(groups: groups),
            const Spacer(),
            if (groups.isEmpty) const _GroupsEmptySummary() else figure,
            const Spacer(),
          ],
        ),
      );
    }
    return DashboardCard(
      semanticLabel: appLocalizations.proxyGroup,
      onTap: groups.isEmpty ? null : () => showProxiesSheet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupsHeader(groups: groups),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _GroupsEmpty(),
            )
          else
            figure,
        ],
      ),
    );
  }
}

/// The empty state of the desktop summary, whose fixed height leaves no room
/// for the illustration.
class _GroupsEmptySummary extends ConsumerWidget {
  const _GroupsEmptySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (title, subtitle) = _emptyTextsOf(
      context,
      connected: ref.watch(coreStatusProvider) == CoreStatus.connected,
    );''', '''class ProxyGroupsSummaryCard extends StatelessWidget {
  const ProxyGroupsSummaryCard({
    super.key,
    this.groups = const [],
    this.connected = true,
    this.selectedNameOf,
    this.delayOf,
    this.onOpenProxies,
  });

  final List<Group> groups;
  final bool connected;
  final String? Function(String groupName)? selectedNameOf;
  final int? Function(String proxyName, String? testUrl)? delayOf;
  final void Function(String? groupName)? onOpenProxies;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final density = DashboardDensityScope.of(context);
    final figure = _GroupsFigure(
      groups: groups,
      metrics: _figureMetricsOf(density),
    );
    if (density.isDesktop) {
      return DashboardCard(
        semanticLabel: appLocalizations.proxyGroup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupsHeader(
              groups: groups,
              delayOf: delayOf,
              onOpenProxies: onOpenProxies,
            ),
            const Spacer(),
            if (groups.isEmpty)
              _GroupsEmptySummary(connected: connected)
            else
              figure,
            const Spacer(),
          ],
        ),
      );
    }
    return DashboardCard(
      semanticLabel: appLocalizations.proxyGroup,
      onTap: groups.isEmpty || onOpenProxies == null
          ? null
          : () => onOpenProxies!(null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupsHeader(
            groups: groups,
            delayOf: delayOf,
            onOpenProxies: onOpenProxies,
          ),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _GroupsEmpty(connected: connected),
            )
          else
            figure,
        ],
      ),
    );
  }
}

/// The empty state of the desktop summary, whose fixed height leaves no room
/// for the illustration.
class _GroupsEmptySummary extends StatelessWidget {
  const _GroupsEmptySummary({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _emptyTextsOf(context, connected: connected);'''),
    ])

    register('lib/views/dashboard/dashboard.dart', 'dashboard/dashboard_view.dart', [
        ('''import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'edit.dart';
import 'layout.dart';
import 'style.dart';
import 'widget_registry.dart';
import 'widgets/core_status_button.dart';
import 'widgets/widgets.dart';''', '''import 'dart:math' as math;

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
}'''),
        ('''class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key, this.platform});

  /// The host's platform when null.
  final SupportPlatform? platform;

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  var _editing = false;
  final _cardKeys = <DashboardWidget, GlobalKey>{};

  void _setEditing(bool editing) {
    setState(() => _editing = editing);
  }

  GlobalKey _cardKeyOf(DashboardWidget widget) =>
      _cardKeys.putIfAbsent(widget, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform ?? SupportPlatform.currentPlatform;
    final viewSize = ref.watch(viewSizeProvider);
    final sideWidth = ref.watch(sideWidthProvider);
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    final size = Size(viewSize.width - sideWidth, viewSize.height) / scale;
    final editable = !DashboardDensity.of(size).isDesktop;
    if (!editable) {
      _editing = false;
    }
    final editing = _editing;
    final gap = cardSpacingOf(context, ref.watch(viewModeProvider));
    final appLocalizations = context.appLocalizations;
    return Scaffold(
      backgroundColor: DashboardColors.of(context).page,
      title: editing
          ? appLocalizations.editDashboard
          : appLocalizations.dashboard,
      actions: [
        if (!editable) const UpdateStatusButton(),
        if (!editing && coreLib == null) const CoreStatusButton(),
      ],''', '''class DashboardView extends StatefulWidget {
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
      ],'''),
        ('''                ? _DesktopDashboard(
                    platform: platform,
                    columns: dashboardColumnsOf(room.width),
                    gap: gap,
                  )
                : _MobileDashboard(
                    platform: platform,
                    gap: gap,
                    editing: editing,
                    cardKeyOf: _cardKeyOf,
                    onDone: () => _setEditing(false),
                  ),''', '''                ? _DesktopDashboard(
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
                  ),'''),
        ('''class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.platform,
    required this.columns,
    required this.gap,
  });

  final SupportPlatform platform;
  final int columns;
  final double gap;''', '''class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.slots,
    required this.columns,
    required this.gap,
  });

  final DashboardDesktopSlots slots;
  final int columns;
  final double gap;'''),
        ('''        final switches =
            DashboardWidget.networkTakeover.platforms.contains(platform)
            ? const [
                (1, NetworkTakeoverTile(TakeoverSwitch.systemProxy)),
                (1, NetworkTakeoverTile(TakeoverSwitch.tun)),
              ]
            : const [(2, VpnTile())];
        final half = columns ~/ 2;
        final summaries = row([
          (half, const ConnectionStatsCard()),
          (half, const ProxyGroupsSummaryCard()),
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
                  const RepaintBoundary(child: CurrentOutboundCard()),
                ),
                sized(
                  topHeight,
                  row(const [
                    (1, SpeedCard(direction: TrafficDirection.upload)),
                    (1, SpeedCard(direction: TrafficDirection.download)),
                  ]),
                ),
                sized(
                  controlHeight,
                  const RepaintBoundary(child: OutboundModeBar()),
                ),
                sized(controlHeight, row(switches)),
                sized(
                  middleHeight,
                  row(const [(1, IntranetIpCard()), (1, ProfilesCard())]),
                ),
                sized(
                  middleHeight,
                  row(const [(1, ServiceStatusCard()), (1, MemoryInfo())]),
                ),
                sized(summaryHeight, summaries),
              ],
            ),
          );
        }
        final rows = [
          sized(
            topHeight,
            row(const [
              (2, CurrentOutboundCard()),
              (1, SpeedCard(direction: TrafficDirection.upload)),
              (1, SpeedCard(direction: TrafficDirection.download)),
            ]),
          ),
          sized(
            controlHeight,
            row([(2, const OutboundModeBar()), ...switches]),
          ),
          sized(
            middleHeight,
            row([
              (1, const IntranetIpCard()),
              (1, const ProfilesCard()),
              (
                1,
                ServiceStatusCard(
                  columns: column >= _servicePairColumnMin * scale ? 2 : 1,
                ),
              ),
              (1, const MemoryInfo()),
            ]),
          ),
        ];''', '''        final switches = slots.switches;
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
        ];'''),
        ('''                        children: const [
                          Expanded(
                            flex: 3,
                            child: RepaintBoundary(
                              child: ConnectionsTableCard(),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RepaintBoundary(child: ProxyGroupsCard()),
                          ),
                        ],''', '''                        children: [
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
                        ],'''),
        ('''class _MobileDashboard extends ConsumerWidget {
  const _MobileDashboard({
    required this.platform,
    required this.gap,
    required this.editing,
    required this.cardKeyOf,
    required this.onDone,
  });

  final SupportPlatform platform;
  final double gap;
  final bool editing;
  final GlobalKey Function(DashboardWidget widget) cardKeyOf;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      dashboardStateProvider.select((state) => state.dashboardWidgets),
    );
    final top = context.contentTopPadding;
    final bottom = 16 + context.bottomInset;
    return CustomScrollView(
      // A viewport per card lays them all out and holds the scroll end still.
      scrollCacheExtent: editing
          ? ScrollCacheExtent.viewport(DashboardWidget.values.length.toDouble())
          : null,
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final side = dashboardMobileSideOf(constraints.crossAxisExtent);
            final widgets = [
              for (final widget in saved)
                if (widget.platforms.contains(platform)) widget,
            ];
            if (editing) {
              return DashboardEditor(
                platform: platform,
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
                    UpdateStatusSlot(gap: gap),
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
}''', '''class _MobileDashboard extends StatelessWidget {
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
}'''),
    ])
