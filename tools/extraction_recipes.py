"""Presentation contracts found during the second source review.

These recipes preserve the upstream rendering and motion; service and provider
access becomes host-owned values/callbacks. Excerpts explicitly remain partial.
"""


def register_reviewed(register, base):
    ui = ('package:fl_clash/ui/ui.dart', 'package:prism_ui/prism_ui.dart')
    icons = ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/icons.dart')
    strings = ('context.appLocalizations', 'KitLocalizations.of(context)')
    register('lib/common/iterable.dart', 'iterable.dart')
    register('lib/common/fixed.dart', 'fixed.dart')
    register('lib/ui/fonts.dart', 'ui/fonts.dart', [
        ('jetBrainsMono(\'JetBrainsMono\')', "jetBrainsMono('packages/flclash_ui_kit/JetBrainsMono')"),
        ('/// The fonts FlClash bundles, declared in its `pubspec.yaml`.',
         '/// JetBrains Mono is packaged here under OFL-1.1. Twemoji is a host-supplied optional family; its upstream binary remains quarantined.'),
    ])
    register('lib/common/datetime.dart', 'datetime.dart', [
        ("import 'context.dart';", "import 'localizations.dart';"), strings,
        ('''  bool isBeforeSecure(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return true;
  }

''', ''),
    ])
    register('lib/widgets/chip_title.dart', 'widgets/chip_title.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../datetime.dart';\nimport '../localizations.dart';"), ui, strings,
    ])
    register('lib/widgets/last_update_time_text.dart', 'widgets/last_update_time_text.dart', [
        ('package:fl_clash/common/common.dart', 'package:flclash_ui_kit/src/datetime.dart'),
    ])
    register('lib/enum/enum.dart', 'records/types.dart', [], excerpt=(
        'enum RecordTone', 'enum TrafficUnit',
        "import 'package:flutter/widgets.dart';\nimport 'package:prism_ui/prism_ui.dart';\n\n",
        'RecordTone/RecordFacetKind/RecordGrouping 及颜色；其他业务枚举未提取',
    ))
    register('lib/models/record_filter.dart', 'records/model.dart', [
        ('package:fl_clash/enum/enum.dart', 'package:flclash_ui_kit/src/records/types.dart'),
    ])
    source = (base / 'lib/widgets/record_filter.dart').read_text(encoding='utf-8')
    persistence = source[source.index('RecordGrouping? savedRecordGrouping('):source.index('/// Lets a value tapped')]
    register('lib/widgets/record_filter.dart', 'records/filter.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';\nimport '../scaffold/scaffold.dart';\nimport 'labels.dart';"),
        ('package:fl_clash/enum/enum.dart', 'package:flclash_ui_kit/src/records/types.dart'),
        ('package:fl_clash/models/models.dart', 'package:flclash_ui_kit/src/records/model.dart'),
        ("import 'package:fl_clash/providers/config.dart';", ''),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ("import 'record.dart';", "import '../widgets/record.dart';"),
        icons, ui, strings, (persistence, ''),
        ('facet.kind.title', 'facet.kind.titleOf(context)'),
        ('grouper.grouping.label', 'grouper.grouping.labelOf(context)'),
        # A new callback must reach existing rows when a host rebinds the scope.
        ('bool updateShouldNotify(RecordFilterScope oldWidget) => false;',
         'bool updateShouldNotify(RecordFilterScope oldWidget) => onFilter != oldWidget.onFilter;'),
    ])
    register('lib/widgets/record.dart', 'widgets/record.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';\nimport '../ui/fonts.dart';"),
        ('package:fl_clash/enum/enum.dart', 'package:flclash_ui_kit/src/records/types.dart'), ui, strings,
        ('dialogs.showBanner(KitLocalizations.of(context).copySuccess);',
         'BannerHost.maybeOf(context)?.show(KitLocalizations.of(context).copySuccess);'),
    ])
    register('lib/widgets/subscription_info_view.dart', 'widgets/subscription_info_view.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../datetime.dart';\nimport '../format.dart';\nimport '../localizations.dart';"),
        ('package:fl_clash/models/models.dart', 'package:flclash_ui_kit/src/data.dart'), ui, strings,
    ])
    register('lib/features/form/custom_issue.dart', 'forms/error_banner.dart', [], excerpt=(
        '/// Opens a page of sections', None,
        "import 'package:flutter/widgets.dart';\nimport 'package:prism_ui/prism_ui.dart';\nimport '../../icons.dart';\n\n",
        '仅通用 ErrorBanner 和绘制；CustomIssue 业务校验仍在原树',
    ))
    register('lib/features/form/form_page.dart', 'forms/form_page.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';\nimport '../scaffold/scaffold.dart';"),
        ("import 'custom_issue.dart';", "import 'error_banner.dart';"), icons, ui, strings,
        ('body: ListView(', 'body: Builder(builder: (context) => ListView('),
        ('          ...children,\n        ],\n      ),', '          ...children,\n        ],\n      )),')
    ])
    source = (base / 'lib/features/form/nested_form_sheet.dart').read_text(encoding='utf-8')
    entry = source[source.index('/// A null [profileId]'):source.index('class NestedFormSheet<T>')]
    register('lib/features/form/nested_form_sheet.dart', 'forms/nested_form_sheet.dart', [
        ("import 'package:fl_clash/common/common.dart';", ''),
        ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ("import 'package:riverpod/misc.dart' show Override;", ''),
        (entry, '''/// Open an isolated form with a host-owned draft and exit confirmation.
Future<void> showNestedFormSheet<T>({
  required BuildContext context,
  required T Function() currentValue,
  required WidgetBuilder formBuilder,
  Widget Function(Widget child)? scopeBuilder,
}) => showFormSheet(
  context: context,
  props: nestedPagedSheetProps,
  builder: (_) {
    final sheet = NestedFormSheet<T>(currentValue: currentValue, formBuilder: formBuilder);
    return scopeBuilder?.call(sheet) ?? sheet;
  },
);

'''),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('T Function(WidgetRef ref) currentOf', 'T Function() currentValue'),
        ('required this.currentOf,', 'required this.currentValue,'),
        ('widget.currentOf(ref)', 'widget.currentValue()'), strings,
        ('dialogs.showMessage(\n          message:', 'showKitMessage(context,\n          message:'),
        ('dialogs.showSaveChanges()', 'showKitSaveChanges(context)'),
    ])
    register('lib/features/form/list_editor_page.dart', 'forms/list_editor_page.dart', [
        ("import 'package:fl_clash/common/common.dart';", ''),
        ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ("import 'package:fl_clash/ui/icons/icons.dart';", ''), strings,
        ('    WidgetRef ref,\n', ''), ('            ref,\n', ''),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('final List<T>? Function(WidgetRef ref) itemsOf;', 'final List<T>? items;'),
        ('required this.itemsOf,', 'required this.items,'),
        ('widget.itemsOf(ref)', 'widget.items'),
        ('dialogs.showMessage(', 'showKitMessage(context,'),
    ])
    register('lib/views/dashboard/widgets/traffic.dart', 'dashboard/traffic.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../fixed.dart';\nimport '../format.dart';\nimport '../iterable.dart';\nimport '../localizations.dart';"),
        ('package:fl_clash/models/models.dart', 'package:flclash_ui_kit/src/data.dart'),
        ("import 'package:fl_clash/providers/providers.dart';", ''),
        ("import 'package:fl_clash/widgets/widgets.dart';", "import 'package:prism_ui/prism_ui.dart';"),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ('package:fl_clash/views/dashboard/layout.dart', 'package:flclash_ui_kit/src/dashboard/layout.dart'),
        ('package:fl_clash/views/dashboard/style.dart', 'package:flclash_ui_kit/src/dashboard/style.dart'), icons, strings,
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
        ('const SpeedCard({super.key, required this.direction});',
         'const SpeedCard({super.key, required this.direction, required this.traffics, this.total = 0});\n\n  final FixedList<Traffic> traffics;\n  final num total;'),
        ('    final traffics = ref.watch(trafficsProvider);\n    final total = ref.watch(\n      totalTrafficProvider.select((state) => direction.of(state)),\n    );',
         '    final traffics = this.traffics;\n    final total = this.total;'),
        ('const NetworkSpeedCard({super.key});',
         'const NetworkSpeedCard({super.key, required this.traffics, this.total = const Traffic()});\n\n  final FixedList<Traffic> traffics;\n  final Traffic total;'),
        ('    final traffics = ref.watch(trafficsProvider);\n    final total = ref.watch(totalTrafficProvider);',
         '    final traffics = this.traffics;\n    final total = this.total;'),
    ])
    source = (base / 'lib/views/theme_preview.dart').read_text(encoding='utf-8')
    listener = source[source.index('  @override\n  void initState()'):source.index('  Future<void> _select(')]
    config = source[source.index('    final themeMode ='):source.index('    final corner =')]
    register('lib/views/theme_preview.dart', 'theme_preview.dart', [
        ("import 'package:fl_clash/enum/enum.dart';", ''),
        ("import 'package:fl_clash/providers/config.dart';", ''),
        ("import 'package:fl_clash/providers/state.dart';", ''),
        ("import 'package:fl_clash/widgets/widgets.dart';", ''),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ('class PreviewChoice<T>', 'enum TabAnimation { slide, fade }\n\nclass PreviewChoice<T>'),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('const ThemeLivePreview({super.key});', '''const ThemeLivePreview({super.key, this.colorScheme, this.floatingBar = true, this.liquidGlass = false, this.tabAnimation = TabAnimation.slide});
  final ColorScheme? colorScheme;
  final bool floatingBar;
  final bool liquidGlass;
  final TabAnimation tabAnimation;'''),
        (listener, '''  @override
  void didUpdateWidget(ThemeLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabAnimation != widget.tabAnimation) {
      _select((_selected + 1) % MiniScreen.destinationCount);
    }
  }

'''),
        ('final tabAnimation = ref.read(appSettingProvider).tabAnimation;', 'final tabAnimation = widget.tabAnimation;'),
        (config, '''    final colorScheme = widget.colorScheme ?? context.colorScheme;
    final floatingBar = widget.floatingBar;
    final tabAnimation = widget.tabAnimation;
    final liquidGlass = widget.liquidGlass;
'''),
    ])
    source = (base / 'lib/views/dashboard/widgets/outbound_mode.dart').read_text(encoding='utf-8')
    change_mode = source[source.index('void _changeMode('):source.index('class OutboundModeCard')]
    register('lib/views/dashboard/widgets/outbound_mode.dart', 'dashboard/outbound_mode.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';"),
        ('package:fl_clash/enum/enum.dart', 'package:flclash_ui_kit/src/dashboard/mode.dart'),
        ("import 'package:fl_clash/providers/providers.dart';", ''),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ('package:fl_clash/views/dashboard/layout.dart', 'package:flclash_ui_kit/src/dashboard/layout.dart'),
        ('package:fl_clash/views/dashboard/style.dart', 'package:flclash_ui_kit/src/dashboard/style.dart'),
        icons, ui, strings, (change_mode, ''),
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
        ('const OutboundModeCard({super.key});', 'const OutboundModeCard({super.key, required this.mode, required this.onChanged});\n  final Mode mode;\n  final ValueChanged<Mode> onChanged;'),
        ('const OutboundModeBar({super.key});', 'const OutboundModeBar({super.key, required this.mode, required this.onChanged});\n  final Mode mode;\n  final ValueChanged<Mode> onChanged;'),
        ('    final mode = ref.watch(\n      patchClashConfigProvider.select((state) => state.mode),\n    );', '    final mode = this.mode;'),
        ('_changeMode(ref, item)', 'item == mode ? null : onChanged(item)'),
        ('item.label', 'item.labelOf(context)'),
    ])
    source = (base / 'lib/views/dashboard/widgets/intranet_ip.dart').read_text(encoding='utf-8')
    values = source[source.index('    final localIp ='):source.index('    final figure =')]
    change_lan = source[source.index('    void change(bool value)'):source.index('    return DashboardCard(')]
    register('lib/views/dashboard/widgets/intranet_ip.dart', 'dashboard/intranet_ip.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';"),
        ("import 'package:fl_clash/providers/providers.dart';", ''),
        ("import 'package:fl_clash/widgets/widgets.dart';", "import 'package:prism_ui/prism_ui.dart';"),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ('package:fl_clash/views/dashboard/layout.dart', 'package:flclash_ui_kit/src/dashboard/layout.dart'),
        ('package:fl_clash/views/dashboard/style.dart', 'package:flclash_ui_kit/src/dashboard/style.dart'), icons, strings,
        ('dialogs.showBanner(', 'BannerHost.maybeOf(context)?.show('),
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
        ('const IntranetIpCard({super.key});', 'const IntranetIpCard({super.key, required this.localIp, required this.allowLan, required this.port, required this.onAllowLanChanged});\n  final String? localIp;\n  final bool allowLan;\n  final int port;\n  final ValueChanged<bool> onAllowLanChanged;'),
        (values, '    final localIp = this.localIp;\n'), (change_lan, '    void change(bool value) => onAllowLanChanged(value);\n'),
    ])
    source = (base / 'lib/views/dashboard/widgets/current_outbound.dart').read_text(encoding='utf-8')
    root = source[source.index('/// The address the proxied'):source.index('    final metrics =')]
    ip_watch = source[source.index('    final hideIp = ref.watch('):source.index('    return DashboardFitText(')]
    level_tone = source[source.index('tone: switch (quality.level)'):source.index('                large: large,', source.index('tone: switch (quality.level)'))]
    removals = [line for line in source.splitlines() if line.startswith("import 'package:fl_clash/")]
    current_changes = [(line, '') for line in removals]
    current_changes += [
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ("import 'card.dart';", "import 'card.dart';\nimport 'layout.dart';\nimport 'style.dart';\nimport '../data.dart';\nimport '../datetime.dart';\nimport '../localizations.dart';\nimport '../../icons.dart';"),
        (root, '''/// Original status-card presentation, without network probes or services.
class CurrentOutboundCard extends StatelessWidget {
  const CurrentOutboundCard({super.key, required this.onToggle, required this.onRefresh,
    this.info, this.quality, this.enabled = true, this.running = false,
    this.suspended = false, this.rootAccess = false, this.loading = false,
    this.failed = false, this.checking = false, this.hideIp = false,
    this.runTime, this.onDetails});
  final OutboundInfo? info;
  final OutboundQuality? quality;
  final bool enabled, running, suspended, rootAccess, loading, failed, checking, hideIp;
  final int? runTime;
  final VoidCallback onToggle, onRefresh;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final hasProfile = enabled;
    final isStart = running;
    final ipInfo = info;
'''), strings,
        ('checking: phase == ProbePhase.probing || qualityLoading,', 'checking: checking,\n                        hideIp: hideIp,\n                        onDetails: onDetails,'),
        ('onRefresh: () => _refresh(ipInfo?.ip),', 'onRefresh: onRefresh,'),
        ('                        active: isStart && !suspended,', '                        active: isStart && !suspended,\n                        runTime: runTime,'),
        ('                      suspended: suspended,', '                      suspended: suspended,\n                      onToggle: onToggle,'),
        ('required this.onRefresh,\n    required this.quality,', 'required this.onRefresh,\n    required this.hideIp,\n    this.onDetails,\n    required this.quality,'),
        ('final IpInfo? info;', 'final IpInfo? info;\n  final bool hideIp;\n  final VoidCallback? onDetails;'),
        ('onTap: () => showIpQualitySheet(context, ip: info.ip),', 'onTap: onDetails,'),
        ('_IpText(ip: info.ip, style: style)', '_IpText(ip: info.ip, style: style, hideIp: hideIp)'),
        ('const _IpText({required this.ip, required this.style});', 'const _IpText({required this.ip, required this.style, required this.hideIp});\n  final bool hideIp;'),
        (ip_watch, ''),
        ('quality.type.label(context)', 'quality.typeLabel'),
        ('quality.level.label(context)', 'quality.levelLabel'),
        (level_tone, '''tone: switch (quality.level) {
                  OutboundQualityLevel.good => DashboardChipTone.ok,
                  OutboundQualityLevel.normal => DashboardChipTone.idle,
                  OutboundQualityLevel.risky => DashboardChipTone.warn,
                },
'''),
        ('IpInfo', 'OutboundInfo'), ('IpQuality', 'OutboundQuality'),
        ('required this.gap,\n  });', 'required this.gap,\n    this.runTime,\n  });'),
        ('  final double gap;\n\n  @override', '  final double gap;\n  final int? runTime;\n\n  @override'),
        ('const _RunTimeValue() : const _Placeholder()', '_RunTimeValue(runTime) : const _Placeholder()'),
        ('const _RunTimeValue();', 'const _RunTimeValue(this.runTime);\n  final int? runTime;'),
        ('getTimeText(ref.watch(runTimeProvider))', 'getTimeText(runTime)'),
        ('_StartToggleState', '_RunningToggleState'), ('_StartToggle', 'RunningToggle'),
        ('const RunningToggle({', 'const RunningToggle({\n    super.key,'),
        ('required this.suspended,', 'required this.suspended,\n    required this.onToggle,'),
        ('final bool suspended;', 'final bool suspended;\n  final VoidCallback onToggle;'),
        ('ref.read(commonActionProvider.notifier).toggleRunning();', 'widget.onToggle();'),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
    ]
    register('lib/views/dashboard/widgets/current_outbound.dart', 'dashboard/current_outbound.dart', current_changes)
