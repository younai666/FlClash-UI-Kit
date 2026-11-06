import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_kit/shapes.dart' as shapes;

class DashboardDemo extends StatefulWidget {
  const DashboardDemo({super.key});
  @override
  State<DashboardDemo> createState() => _DashboardDemoState();
}

class _DashboardDemoState extends State<DashboardDemo> {
  bool _editing = false;
  late final _all = <DashboardItem>[
    const DashboardItem(
      id: 'metric',
      title: '状态与运行按钮',
      glyph: AppGlyphs.dashboard,
      index: 0,
      card: _StatusExample(),
      removable: false,
    ),
    const DashboardItem(
      id: 'chart',
      title: '流量曲线',
      glyph: AppGlyphs.arrowUp,
      index: 1,
      card: _TrafficExample(),
    ),
    const DashboardItem(
      id: 'switches',
      title: '内网地址与开关',
      glyph: AppGlyphs.toggle,
      index: 2,
      card: _LanExample(),
    ),
    const DashboardItem(
      id: 'modes',
      title: '连接按钮组',
      glyph: AppGlyphs.proxies,
      index: 3,
      card: _ModesCard(),
    ),
    const DashboardItem(id: 'layout-primitives', title: '布局辅助', glyph: AppGlyphs.dashboard, index: 4, card: _MetricCard()),
    const DashboardItem(id: 'switch-primitives', title: '开关与按压辅助', glyph: AppGlyphs.toggle, index: 5, card: _SwitchCard()),
    const DashboardItem(id: 'memory', title: '内存与详情', glyph: AppGlyphs.memory, index: 6, card: _MemoryExample()),
    const DashboardItem(id: 'services', title: '服务状态', glyph: AppGlyphs.verified, index: 7, card: _ServiceExample()),
    const DashboardItem(id: 'takeover', title: '网络开关展示', glyph: AppGlyphs.shuffle, index: 8, card: _TakeoverExample()),
    const DashboardItem(id: 'profile', title: '配置摘要与详情', glyph: AppGlyphs.profiles, index: 9, card: _ProfileExample()),
  ];
  late List<DashboardItem> _visible = [..._all];
  final _keys = <Object, GlobalKey>{};
  GlobalKey _keyOf(DashboardItem item) =>
      _keys.putIfAbsent(item.id, GlobalKey.new);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final density = DashboardDensity.of(constraints.biggest);
      return DashboardDensityScope(
        density: density,
        scale: MediaQuery.textScalerOf(context).scale(1),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                context.contentTopPadding + 12,
                20,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('使用已提取的 Dashboard 组件组合。本地示例数据；完整业务页面的剩余解耦见提取矩阵。'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () => setState(() => _editing = !_editing),
                        child: Text(_editing ? '完成编辑' : '编辑卡片'),
                      ),
                      Text('密度 ${density.name} · ${_visible.length} 张卡片'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _editing
                  ? CustomScrollView(
                      slivers: [
                        DashboardEditor(
                          available: _all,
                          widgets: _visible,
                          cardKeyOf: _keyOf,
                          padding: const EdgeInsets.all(20),
                          gap: 20,
                          onDone: () => setState(() => _editing = false),
                          onChanged: (items) =>
                              setState(() => _visible = [...items]),
                        ),
                      ],
                    )
                  : LayoutBuilder(
                      builder: (context, size) {
                        final count = size.maxWidth < 700 ? 1 : 2;
                        final width =
                            (size.maxWidth - 40 - (count - 1) * 20) / count;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (final item in _visible)
                                SizedBox(
                                  width: width,
                                  child: RepaintBoundary(
                                    key: _keyOf(item),
                                    child: item.card,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '真实调用：showcase/lib/dashboard.dart · src/dashboard/edit.dart',
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ProfileExample extends StatefulWidget {
  const _ProfileExample();
  @override
  State<_ProfileExample> createState() => _ProfileExampleState();
}
class _ProfileExampleState extends State<_ProfileExample> {
  var _quota = true;
  var _updating = false;
  DateTime _updated = DateTime.now().subtract(const Duration(hours: 2));
  static const _stats = (groups: 4, proxies: 32, rules: 1048, providers: 2);
  DashboardProfile get _profile => DashboardProfile(label: 'Example configuration', lastUpdateDate: _updated,
    subscriptionInfo: _quota ? const SubscriptionInfo(download: 140 * 1024 * 1024 * 1024,
      total: 512 * 1024 * 1024 * 1024, expire: 4102444800) : null);
  Future<void> _sync() async {
    if (_updating) return;
    setState(() => _updating = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() { _updating = false; _updated = DateTime.now(); });
  }
  void _open() => showSheet<void>(context: context, builder: (_) => ProfileDetailSheet(
    profile: _profile, stats: _stats, onSync: _sync,
    onPreview: () => showKitMessage(context, message: const TextSpan(text: '宿主在此打开配置预览；此例使用本地展示数据。')),
    providerSlivers: const [SliverToBoxAdapter(child: ListItem(title: Text('由宿主提供的扩展资源列表')))]));
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    SizedBox(height: DashboardDensityScope.of(context).isDesktop ? 216 : null, child: ProfilesCard(
      profile: _profile, stats: _stats, switchable: true, isUpdating: _updating,
      onOpen: _open, onSync: _sync, onSwitch: () => setState(() => _quota = !_quota))),
    TextButton(onPressed: () => setState(() => _quota = !_quota), child: const Text('切换配额与统计状态')),
  ]);
}

class _ServiceExample extends StatefulWidget {
  const _ServiceExample();
  @override
  State<_ServiceExample> createState() => _ServiceExampleState();
}
class _ServiceExampleState extends State<_ServiceExample> {
  var _checked = false;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    SizedBox(height: DashboardDensityScope.of(context).isDesktop ? 210 : null,
      child: ServiceStatusCard(services: [
        ServiceStatusItem(ServiceTarget.github, check: ServiceCheck(ServiceProbeStatus.available, delay: _checked ? 83 : 120)),
        const ServiceStatusItem(ServiceTarget.google, check: ServiceCheck(ServiceProbeStatus.restricted)),
        const ServiceStatusItem(ServiceTarget.youtube, phase: ProbePhase.probing),
        const ServiceStatusItem(ServiceTarget.bilibili, phase: ProbePhase.failed),
      ], onRefresh: () => setState(() => _checked = !_checked),
        onDetails: () => showKitMessage(context, message: const TextSpan(text: '示例数据由宿主提供；无真实服务网络请求。')))),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: [for (final target in ServiceTarget.values) Tooltip(
      message: target.label, child: ServiceBadge(target: target, size: 40, dot: context.colorScheme.success))]),
  ]);
}
class _TakeoverExample extends StatefulWidget {
  const _TakeoverExample();
  @override
  State<_TakeoverExample> createState() => _TakeoverExampleState();
}
class _TakeoverExampleState extends State<_TakeoverExample> {
  var _system = false;
  var _tun = true;
  var _vpn = false;
  @override
  Widget build(BuildContext context) => Column(children: [
    NetworkTakeoverCard(systemProxy: _system, tun: _tun,
      onSystemProxyChanged: (value) => setState(() => _system = value), onTunChanged: (value) => setState(() => _tun = value)),
    const SizedBox(height: 12),
    SizedBox(height: 68, child: NetworkTakeoverTile(TakeoverSwitch.systemProxy, value: _system,
      onChanged: (value) => setState(() => _system = value))),
    const SizedBox(height: 12),
    SizedBox(height: 68, child: NetworkTakeoverTile(TakeoverSwitch.tun, value: _tun,
      onChanged: (value) => setState(() => _tun = value))),
    const SizedBox(height: 12),
    VpnCard(enabled: _vpn, onChanged: (value) => setState(() => _vpn = value)),
    const SizedBox(height: 12),
    SizedBox(height: 68, child: VpnTile(enabled: _vpn, onChanged: (value) => setState(() => _vpn = value))),
    const Text('回调只改变本地展示状态；宿主自行接入网络/VPN 服务。'),
  ]);
}

class _MemoryExample extends StatefulWidget {
  const _MemoryExample();
  @override
  State<_MemoryExample> createState() => _MemoryExampleState();
}
class _MemoryExampleState extends State<_MemoryExample> {
  var _app = 106 * 1024 * 1024;
  Future<MemorySnapshot> _read() async => MemorySnapshot.resolve(
    rss: _app, core: const CoreMemoryStats(rss: 60 * 1024 * 1024,
      heapInuse: 30 * 1024 * 1024, heapIdle: 18 * 1024 * 1024,
      stackInuse: 2 * 1024 * 1024, runtimeOther: 4 * 1024 * 1024), coreInProcess: false);
  @override
  Widget build(BuildContext context) => SizedBox(
    height: DashboardDensityScope.of(context).isDesktop ? 216 : null,
    child: MemoryInfo(memoryReader: _read, onRelease: () async {
      _app = (_app - 8 * 1024 * 1024).clamp(64 * 1024 * 1024, 106 * 1024 * 1024);
    }));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard();
  @override
  Widget build(BuildContext context) => DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardCardHeader(
          glyph: AppGlyphs.dashboard,
          title: '组件组合',
          trailing: [
            DashboardChip(label: '可复用', tone: DashboardChipTone.ok, dot: true),
          ],
        ),
        const SizedBox(height: 20),
        DashboardCappedRow(
          start: DashboardFitText(
            '12,480',
            style: DashboardText.figure(context, AppTextStyle.largeTitle),
          ),
          end: ShapeBadge(
            shape: shapes.MaterialShapes.cookie6Sided,
            color: context.colorScheme.primaryContainer,
            size: 56,
            child: const GlyphIcon(AppGlyphs.sparkle),
          ),
        ),
        const SizedBox(height: 12),
        Text('原始连续圆角、阴影、排版与响应式密度', style: DashboardText.label(context)),
      ],
    ),
  );
}

class _SwitchCard extends StatefulWidget {
  const _SwitchCard();
  @override
  State<_SwitchCard> createState() => _SwitchCardState();
}

class _SwitchCardState extends State<_SwitchCard> {
  bool _on = true;
  @override
  Widget build(BuildContext context) => DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardCardHeader(title: '开关组合', glyph: AppGlyphs.toggle),
        const SizedBox(height: 18),
        DashboardSwitchRow(
          glyph: AppGlyphs.bolt,
          title: '自动模式',
          subtitle: '点击或拖动切换',
          value: _on,
          onChanged: (v) => setState(() => _on = v),
          onTap: () => setState(() => _on = !_on),
          iconSize: 40,
          padding: const EdgeInsets.all(16),
          radius: 20,
        ),
        const SizedBox(height: 16),
        Center(
          child: RunningToggle(
            size: 72,
            enabled: true,
            running: _on,
            suspended: false,
            onToggle: () => setState(() => _on = !_on),
          ),
        ),
      ],
    ),
  );
}

class _ModesCard extends StatefulWidget {
  const _ModesCard();
  @override
  State<_ModesCard> createState() => _ModesCardState();
}

class _ModesCardState extends State<_ModesCard> {
  Mode _selected = Mode.rule;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      OutboundModeCard(mode: _selected, onChanged: (v) => setState(() => _selected = v)),
      const SizedBox(height: 12),
      SizedBox(height: 64, child: OutboundModeBar(mode: _selected, onChanged: (v) => setState(() => _selected = v))),
    ],
  );
}

class _StatusExample extends StatefulWidget {
  const _StatusExample();
  @override
  State<_StatusExample> createState() => _StatusExampleState();
}

class _StatusExampleState extends State<_StatusExample> {
  bool _running = true;
  bool _hideIp = false;
  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 232, child: CurrentOutboundCard(
      running: _running, hideIp: _hideIp, runTime: 18 * 60 * 1000,
      info: const OutboundInfo(ip: '203.0.113.8', countryCode: 'JP'),
      quality: const OutboundQuality(typeLabel: '机房', levelLabel: '普通', organization: 'Example Network'),
      onToggle: () => setState(() => _running = !_running),
      onRefresh: () => setState(() => _hideIp = !_hideIp),
      onDetails: () => showFloatingDialog<void>(context: context, child: const AlertDialog(title: '宿主提供详情', child: Text('地址为演示保留地址；本例不执行网络探测。'))),
    )),
    TextButton(onPressed: () => setState(() => _hideIp = !_hideIp), child: const Text('隐藏 / 显示地址')),
  ]);
}

class _TrafficExample extends StatefulWidget {
  const _TrafficExample();
  @override
  State<_TrafficExample> createState() => _TrafficExampleState();
}

class _TrafficExampleState extends State<_TrafficExample> {
  var _history = FixedList<Traffic>(32, list: [for (var i = 0; i < 32; i++) Traffic(up: (i * 917) % 18000, down: (i * i * 439) % 90000)]);
  int _tick = 0;
  @override
  Widget build(BuildContext context) => Column(children: [
    NetworkSpeedCard(traffics: _history, total: const Traffic(up: 22 * 1024 * 1024, down: 179 * 1024 * 1024)),
    const SizedBox(height: 12),
    SizedBox(height: 190, child: Row(spacing: 12, children: [
      for (final direction in TrafficDirection.values) Expanded(child: SpeedCard(direction: direction, traffics: _history, total: 179 * 1024 * 1024)),
    ])),
    TextButton(onPressed: () => setState(() { _tick++; _history = _history.append(Traffic(up: (_tick * 1777) % 40000, down: (_tick * 8999) % 120000)); }), child: const Text('追加采样并移动曲线')),
  ]);
}

class _LanExample extends StatefulWidget {
  const _LanExample();
  @override
  State<_LanExample> createState() => _LanExampleState();
}

class _LanExampleState extends State<_LanExample> {
  bool _allow = false;
  @override
  Widget build(BuildContext context) => SizedBox(height: 232, child: IntranetIpCard(
    localIp: '192.0.2.1', allowLan: _allow, port: 7890,
    onAllowLanChanged: (v) => setState(() => _allow = v),
  ));
}
