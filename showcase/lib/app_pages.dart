import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_platform/flclash_ui_platform.dart'
    show loadNativeFontFamilies;

/// The complete page composition. Every data source is local and host-owned;
/// file import, OS hotkey registration and proxy services are deliberately absent.
class ApplicationShowcase extends StatefulWidget {
  const ApplicationShowcase({super.key, required this.catalogBuilder});
  final Widget Function(void Function(BuildContext) onSettings) catalogBuilder;
  @override
  State<ApplicationShowcase> createState() => _ApplicationShowcaseState();
}

class _ApplicationShowcaseState extends State<ApplicationShowcase>
    with WidgetsBindingObserver {
  late final HomeShellController _shell;
  late final ThemeController _theme;
  late final ProfilesController _profiles;
  late final ProxiesController _proxies;
  final _keys = HotKeyController(
    actions: const [],
    sectionsBuilder: (_) => [
      ('示例操作（录制绑定；不注册系统热键）', ['open-workspace', 'new-note']),
    ],
    actionLabelBuilder: (_, action) => action == 'new-note' ? '新建笔记' : '打开工作区',
  );
  final _requests = ValueNotifier<List<TrackerInfo>>([]);
  final _queries = ValueNotifier<List<DnsQuery>>([]);
  final _logs = ValueNotifier<List<Log>>([]);
  final _history = FixedList<Traffic>(
    32,
    list: [
      for (var i = 0; i < 32; i++)
        Traffic(up: i * 93, down: (i * i * 439) % 90000),
    ],
  );
  final _columnWidths = <String, Map<String, double>>{};
  var _running = true, _systemProxy = false, _tun = true, _allowLan = false;
  var _mode = Mode.rule;
  bool _reduceMotion = false;
  double? _layoutWidth;
  List<DashboardItem>? _mobileCards;
  void _syncSidebar() {
    final props = _theme.themeProps;
    final dark =
        props.themeMode == ThemeMode.dark ||
        (props.themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    _shell.setBackdropOpacity(
      !_theme.supportsSidebarBlur || !props.sidebarBlur
          ? null
          : defaultTargetPlatform == TargetPlatform.macOS
          ? 0
          : dark
          ? 0.55
          : 0.72,
    );
  }

  @override
  void didChangePlatformBrightness() => _syncSidebar();

  @override
  void initState() {
    super.initState();
    _shell = HomeShellController(
      pageLabel: 'dashboard',
      fallbackPageLabel: 'dashboard',
      locale: const Locale('zh'),
    );
    _theme = ThemeController(
      fontFamiliesReader: loadNativeFontFamilies,
      onFloatingNavigationBarChanged: _shell.setFloatingNavigationBar,
      onTabAnimationChanged: _shell.setTabAnimation,
    );
    _theme.addListener(_syncSidebar);
    WidgetsBinding.instance.addObserver(this);
    _syncSidebar();
    _profiles = ProfilesController(
      profiles: [
        Profile.normal(label: '本地演示订阅', url: 'https://example.com/catalog'),
      ],
      onUpdateProfile: (profile) async =>
          (label: profile.realLabel, message: '示例未接入订阅下载，请由宿主提供更新实现。'),
    );
    final nodes = [
      for (final name in ['Tokyo', 'Singapore', 'Frankfurt'])
        Proxy(name: name, type: 'Demo'),
    ];
    _proxies = ProxiesController(
      groups: [
        Group(
          name: 'GLOBAL',
          type: GroupType.Selector,
          all: nodes,
          now: 'Tokyo',
        ),
        Group(
          name: 'Workspace',
          type: GroupType.Selector,
          all: nodes,
          now: 'Singapore',
        ),
      ],
      selectedMap: const {'GLOBAL': 'Tokyo', 'Workspace': 'Singapore'},
      onTestProxyDelay: (proxy, _) async {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        return 24 + proxy.name.length * 11; // Local, reproducible UI fixture.
      },
    );
    _appendRecord();
    final items = <NavigationItem>[
      NavigationItem(
        label: 'dashboard',
        titleBuilder: (context) => KitLocalizations.of(context).dashboard,
        glyph: AppGlyphs.dashboard,
        builder: _dashboard,
      ),
      NavigationItem(
        label: 'proxies',
        titleBuilder: (context) => KitLocalizations.of(context).proxies,
        glyph: AppGlyphs.proxies,
        builder: (_) => const ProxiesView(),
      ),
      NavigationItem(
        label: 'profiles',
        titleBuilder: (context) => KitLocalizations.of(context).profiles,
        glyph: AppGlyphs.profiles,
        builder: (_) => const ProfilesView(),
      ),
      NavigationItem(
        label: 'requests',
        titleBuilder: (context) => KitLocalizations.of(context).requests,
        glyph: AppGlyphs.requests,
        builder: (_) => RequestsView(
          requestsListenable: _requests,
          connectionsReader: () async => _requests.value,
        ),
        modes: const [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        label: 'dns',
        title: 'DNS',
        glyph: AppGlyphs.dns,
        builder: (_) => DnsQueriesView(dnsQueriesListenable: _queries),
        modes: const [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        label: 'logs',
        titleBuilder: (context) => KitLocalizations.of(context).logs,
        glyph: AppGlyphs.logs,
        builder: (_) => LogsView(logsListenable: _logs),
        modes: const [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        label: 'tools',
        titleBuilder: (context) => KitLocalizations.of(context).tools,
        glyph: AppGlyphs.tools,
        builder: _tools,
      ),
    ];
    _shell.setNavigationItems(items);
  }

  void _appendRecord() {
    final id = _requests.value.length + 1;
    final now = DateTime.now();
    _requests.value = [
      ..._requests.value,
      TrackerInfo(
        id: '$id',
        start: now,
        metadata: Metadata(
          host: 'example-$id.test',
          process: 'Demo browser',
          network: id.isOdd ? 'tcp' : 'udp',
          destinationPort: '443',
        ),
        download: id * 6144,
        upload: id * 1024,
        chains: const ['Tokyo', 'GLOBAL'],
        rule: 'Domain',
        rulePayload: 'test',
      ),
    ];
    _queries.value = [
      ..._queries.value,
      DnsQuery(
        domain: 'example-$id.test',
        type: 'A',
        time: now,
        delay: id * 7,
        answers: const ['192.0.2.10'],
        cached: id.isEven,
      ),
    ];
    _logs.value = [
      ..._logs.value,
      Log.app('Local fixture record $id appended'),
    ];
  }

  void _appearance(BuildContext context) =>
      showSheet<void>(context: context, builder: (_) => const ThemeView());
  void _openFeed(BuildContext context, DashboardFeed feed) =>
      _openPage(context, switch (feed) {
        DashboardFeed.dns => 'dns',
        DashboardFeed.connections || DashboardFeed.requests => 'requests',
      });
  void _openPage(BuildContext context, String label) {
    final item = _shell.navigationItems.firstWhere(
      (item) => item.label == label,
    );
    if (_shell.currentNavigationItemsOf(context).contains(item)) {
      _shell.openPage(label);
    } else {
      BaseNavigator.push<void>(context, item.builder(context));
    }
  }

  void _openProxies(String? name) {
    if (name != null) _proxies.updateCurrentGroupName(name);
    _shell.openPage('proxies');
  }

  Widget _dashboard(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_profiles, _proxies, _requests, _queries]),
    builder: (context, _) {
      final current = CurrentOutboundCard(
        running: _running,
        info: const OutboundInfo(ip: '192.0.2.10', countryCode: 'JP'),
        onToggle: () => setState(() => _running = !_running),
        onRefresh: () => setState(_appendRecord),
      );
      final mode = OutboundModeCard(
        mode: _mode,
        onChanged: (value) => setState(() => _mode = value),
      );
      final lan = IntranetIpCard(
        localIp: '198.18.0.1',
        allowLan: _allowLan,
        port: 7890,
        onAllowLanChanged: (value) => setState(() => _allowLan = value),
      );
      final profile = ProfilesCard(
        profile: _profiles.profiles.firstOrNull?.toDashboardProfile(),
        switchable: _profiles.profiles.length > 1,
        onOpen: () => _shell.openPage('profiles'),
        onSwitch: () => _shell.openPage('profiles'),
      );
      final memory = MemoryInfo(
        memoryReader: () async => const MemorySnapshot(
          app: 106 * 1024 * 1024,
          coreTotal: 60 * 1024 * 1024,
        ),
      );
      Widget services(int columns) => ServiceStatusCard(
        columns: columns,
        services: [
          for (final target in ServiceTarget.values.take(4))
            ServiceStatusItem(
              target,
              check: const ServiceCheck(
                ServiceProbeStatus.available,
                delay: 42,
              ),
            ),
        ],
      );
      final groups = ProxyGroupsCard(
        groups: _proxies.rawGroups,
        selectedNameOf: _proxies.selectedProxyNameOf,
        onOpenProxies: _openProxies,
      );
      final summary = ProxyGroupsSummaryCard(
        groups: _proxies.rawGroups,
        selectedNameOf: _proxies.selectedProxyNameOf,
        onOpenProxies: _openProxies,
      );
      final stats = ConnectionStatsCard(
        initialConnectionCount: _requests.value.length,
        requestCount: _requests.value.length,
        dnsQueryCount: _queries.value.length,
        onOpenFeed: (feed) => _openFeed(context, feed),
      );
      final all = <DashboardItem>[
        DashboardItem(
          id: 'status',
          title: '状态',
          glyph: AppGlyphs.dashboard,
          index: 0,
          card: current,
          removable: false,
        ),
        DashboardItem(
          id: 'traffic',
          title: '流量',
          glyph: AppGlyphs.arrowUp,
          index: 1,
          card: NetworkSpeedCard(traffics: _history),
        ),
        DashboardItem(
          id: 'mode',
          title: '模式',
          glyph: AppGlyphs.split,
          index: 2,
          card: mode,
        ),
        DashboardItem(
          id: 'lan',
          title: '内网',
          glyph: AppGlyphs.devices,
          index: 3,
          card: lan,
        ),
        DashboardItem(
          id: 'profiles',
          title: '配置',
          glyph: AppGlyphs.profiles,
          index: 4,
          card: profile,
        ),
        DashboardItem(
          id: 'memory',
          title: '内存',
          glyph: AppGlyphs.memory,
          index: 5,
          card: memory,
        ),
        DashboardItem(
          id: 'services',
          title: '服务',
          glyph: AppGlyphs.verified,
          index: 6,
          card: services(2),
        ),
        DashboardItem(
          id: 'stats',
          title: '记录',
          glyph: AppGlyphs.connections,
          index: 7,
          card: stats,
        ),
        DashboardItem(
          id: 'groups',
          title: '策略组',
          glyph: AppGlyphs.layers,
          index: 8,
          card: summary,
        ),
      ];
      final ids = _mobileCards?.map((item) => item.id).toSet();
      final shown = ids == null
          ? all
          : [
              for (final old in _mobileCards!)
                ...all.where((item) => item.id == old.id),
            ];
      return DashboardView(
        sideWidth: HomeShellScope.of(context).sideWidth,
        mobileWidgets: shown,
        availableMobileWidgets: all,
        onMobileWidgetsChanged: (items) => setState(() => _mobileCards = items),
        desktopSlots: DashboardDesktopSlots(
          currentOutbound: current,
          uploadSpeed: SpeedCard(
            direction: TrafficDirection.upload,
            traffics: _history,
          ),
          downloadSpeed: SpeedCard(
            direction: TrafficDirection.download,
            traffics: _history,
          ),
          outboundMode: OutboundModeBar(
            mode: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          switches: [
            (
              1,
              NetworkTakeoverTile(
                TakeoverSwitch.systemProxy,
                value: _systemProxy,
                onChanged: (value) => setState(() => _systemProxy = value),
              ),
            ),
            (
              1,
              NetworkTakeoverTile(
                TakeoverSwitch.tun,
                value: _tun,
                onChanged: (value) => setState(() => _tun = value),
              ),
            ),
          ],
          intranetIp: lan,
          profiles: profile,
          serviceStatusBuilder: services,
          memoryInfo: memory,
          connectionsTable: ConnectionsTableCard(
            connections: _requests.value,
            requestsListenable: _requests,
            dnsQueriesListenable: _queries,
            initialColumnWidthsOf: (id) => _columnWidths[id] ?? {},
            onColumnWidthsChanged: (id, widths) => _columnWidths[id] = widths,
          ),
          proxyGroups: groups,
          connectionStats: stats,
          proxyGroupsSummary: summary,
        ),
      );
    },
  );

  Widget _tools(BuildContext context) => ToolsView(
    settingsItems: [
      ListItem<double?>.options(
        title: const Text('预览宽度'),
        options: const [null, 390, 800, 1280],
        value: _layoutWidth,
        textBuilder: (value) => value == null ? '跟随窗口' : '${value.toInt()} px',
        onChanged: (value) => setState(() => _layoutWidth = value),
      ),
      ListItem.toggle(
        title: const Text('减少动态效果'),
        value: _reduceMotion,
        onChanged: (value) => setState(() => _reduceMotion = value),
      ),
    ],
    otherItems: [
      ListItem.open(
        leading: const GlyphIcon(AppGlyphs.layers),
        title: const Text('组件目录'),
        widget: widget.catalogBuilder(_appearance),
        forceFull: true,
      ),
      ListItem(
        leading: const GlyphIcon(AppGlyphs.add),
        title: const Text('追加本地演示记录'),
        onTap: _appendRecord,
      ),
      ListItem.open(
        leading: const GlyphIcon(AppGlyphs.info),
        title: const Text('关于示例'),
        widget: const AboutView(
          appName: 'FlClash UI Kit',
          version: '0.1.0',
          description: '完整页面使用本地演示数据。节点延迟、服务检查和内存均为展示样本，不连接代理核心或更改系统网络。原生文件导入和热键注册由宿主接入。',
          logo: GlyphIcon(AppGlyphs.layers, size: 68),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _theme.removeListener(_syncSidebar);
    _keys.dispose();
    _proxies.dispose();
    _profiles.dispose();
    _theme.dispose();
    _shell.dispose();
    _requests.dispose();
    _queries.dispose();
    _logs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_theme, _shell]),
    builder: (_, _) {
      final props = _theme.themeProps;
      return KitApp(
        locale: _shell.locale,
        themeMode: props.themeMode,
        seedColor: _theme.seedColorFor(Brightness.light),
        fontFamily: props.fontFamily,
        textScale: props.textScale.enable ? props.textScale.scale : null,
        liquidGlass: props.liquidGlass.toQuality,
        pureBlack: props.pureBlack,
        colorStyle: props.colorStyle,
        builder: (context, child) => LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              math.min(
                _layoutWidth ?? constraints.maxWidth,
                constraints.maxWidth,
              ),
              constraints.maxHeight,
            );
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox.fromSize(
                size: size,
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(size: size, disableAnimations: _reduceMotion),
                  child: ViewScope(
                    size: size,
                    isMobile: size.width <= 600,
                    child: HomeShellScope(
                      controller: _shell,
                      child: ThemeScope(
                        controller: _theme,
                        child: HotKeyScope(
                          controller: _keys,
                          child: ProfilesScope(
                            controller: _profiles,
                            child: ProxiesScope(
                              controller: _proxies,
                              child: child!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Page builders capture host fields changed with setState.
        home: HomePage(),
      );
    },
  );
}
