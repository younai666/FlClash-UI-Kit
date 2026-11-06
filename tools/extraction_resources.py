"""Reviewed generic input and service-card presentation, without network probes."""


def register_resources(register, base):
    prefix = "import 'package:flutter/widgets.dart';\nimport 'package:flclash_ui_kit/flclash_ui_kit.dart';\n\n"
    register('test/widgets/target_icon_test.dart', '@test/widgets/target_icon_test.dart', [
        ("import 'package:fl_clash/ui/icons/icons.dart';", ''),
        ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
    ])
    register('test/helpers/glyph_finders.dart', '@test/helpers/glyph_finders.dart', [
        ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
    ])
    register('test/helpers/test_app.dart', '@test/helpers/test_app.dart', [], excerpt=(
        'class HostPageRoute', '/// A plain modal', prefix + '''class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child, this.homeBuilder, this.locale});
  final Widget Function(Widget child)? homeBuilder;
  final Locale? locale;
  final Widget child;
  @override
  Widget build(BuildContext context) => KitApp(liquidGlass: null, locale: locale ?? const Locale('en'), home: homeBuilder != null ? homeBuilder!(child) : child);
}
class HostApp extends StatelessWidget {
  const HostApp({super.key, required this.home});
  final Widget home;
  @override
  Widget build(BuildContext context) => TestApp(child: home);
}

''', '保留 HostPageRoute 真实转场；测试宿主改为独立 KitApp，其他 Riverpod app 配置未提取'))
    register('lib/common/cache.dart', 'ui/icon_cache.dart')
    register('test/common/input_entries_test.dart', '@test/common/input_entries_test.dart', [
        ("import 'package:fl_clash/common/input_entries.dart';", "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
    ])
    register('lib/widgets/icon.dart', 'widgets/target_icon.dart', [
        ('package:fl_clash/common/cache.dart', 'package:flclash_ui_kit/src/ui/icon_cache.dart'),
        ("import 'package:fl_clash/common/common.dart';", "import '../ui/icon_source.dart';"),
        ('const _maxCachedIconBytes', 'const maxConcurrentIconLoads = 8;\n\nconst _maxCachedIconBytes'),
        ("import 'package:fl_clash/plugins/app.dart';", ''),
        ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/icons.dart'),
        ('package:fl_clash/ui/ui.dart', 'package:prism_ui/prism_ui.dart'),
        ('src.getBase64', 'decodeIconData(src)'),
        ('widget.src.isSvg', 'isSvgSource(widget.src)'),
        ('src.isSvg', 'isSvgSource(src)'),
        ('@visibleForTesting\nset readRemoteIcon', '/// Set before loading icons to provide a host-owned cache or transport.\nset readRemoteIcon'),
        ("commonPrint.log('Failed to precache icon $src: $error');", "debugPrint('Failed to precache icon $src: $error');"),
        ("commonPrint.log('Failed to read icon $src: $error');", "debugPrint('Failed to read icon $src: $error');"),
        ('  final double size;\n\n  const PackageIcon', '  final double size;\n  final Future<ImageProvider?> Function(String packageName) loadIcon;\n  final ImageProvider? Function(String packageName)? cachedIconOf;\n\n  const PackageIcon'),
        ('required this.size});', 'required this.size, required this.loadIcon, this.cachedIconOf});'),
        ('app?.getCachedPackageIcon(widget.packageName)', 'widget.cachedIconOf?.call(widget.packageName)'),
        ('app?.getPackageIcon(widget.packageName)', 'widget.loadIcon(widget.packageName)'),
        ('if (oldWidget.packageName != widget.packageName) {', 'if (oldWidget.packageName != widget.packageName || oldWidget.loadIcon != widget.loadIcon || oldWidget.cachedIconOf != widget.cachedIconOf) {'),
    ])
    str_src = (base / 'lib/common/string.dart').read_text(encoding='utf-8')
    str_md5 = str_src[str_src.index('  String toMd5() {'):str_src.index('  String? get value {')]
    const_src = (base / 'lib/common/constant.dart').read_text(encoding='utf-8')
    share_schemes = const_src[const_src.index('const shareLinkSchemes = {'):const_src.index('const stringListEquality')]
    register('lib/common/string.dart', 'string.dart', [
        ("import 'package:crypto/crypto.dart';\nimport 'package:fl_clash/common/common.dart';\nimport 'package:fl_clash/enum/enum.dart';", "import 'input/limits.dart';"),
        ('extension StringExtension on String {', share_schemes + 'extension StringExtension on String {'),
        ('''    } catch (e) {
      commonPrint.log(
        'invalid base64 data ${e.toString()}',
        logLevel: LogLevel.debug,
      );
      return null;
    }''', '    } catch (_) {\n      return null;\n    }'),
        ('''    } catch (e) {
      commonPrint.log(e.toString());
      return false;
    }''', '    } catch (_) {\n      return false;\n    }'),
        (str_md5, ''),
    ])
    register('lib/common/input_limits.dart', 'input/limits.dart')
    register('lib/common/input_entries.dart', 'input/model.dart', [
        ("import 'package:fl_clash/enum/enum.dart';\n\nimport 'string.dart';", "import '../string.dart';"),
        ('final _ruleTypes = {for (final action in RuleAction.values) action.value};',
         "const _ruleTypes = {'DOMAIN', 'DOMAIN-SUFFIX', 'DOMAIN-KEYWORD', 'DOMAIN-REGEX', 'DOMAIN-WILDCARD', 'GEOSITE', 'IP-CIDR', 'IP-CIDR6', 'IP-SUFFIX', 'IP-ASN', 'GEOIP', 'SRC-GEOIP', 'SRC-IP-ASN', 'SRC-IP-CIDR', 'SRC-IP-SUFFIX', 'DST-PORT', 'SRC-PORT', 'IN-PORT', 'IN-TYPE', 'IN-USER', 'IN-NAME', 'REMATCH-NAME', 'PROCESS-PATH', 'PROCESS-PATH-REGEX', 'PROCESS-PATH-WILDCARD', 'PROCESS-NAME', 'PROCESS-NAME-REGEX', 'PROCESS-NAME-WILDCARD', 'UID', 'NETWORK', 'DSCP', 'RULE-SET', 'AND', 'OR', 'NOT', 'SUB-RULE', 'MATCH'};"),
    ])
    register('lib/widgets/input.dart', 'input/input.dart', [
        ("import 'package:fl_clash/common/common.dart';", "import 'model.dart';\nimport 'limits.dart';\nimport '../localizations.dart';\nimport 'field.dart';"),
        ("import 'package:fl_clash/l10n/l10n.dart';", ''),
        ("import 'package:fl_clash/models/common.dart';", ''),
        ('package:fl_clash/ui/ui.dart', 'package:prism_ui/prism_ui.dart'),
        ('AppLocalizations', 'KitLocalizations'), ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])
    register('lib/models/common.dart', 'input/field.dart', [
        ('abstract class Field with _$Field', 'class Field'),
        ('  const factory Field({\n    required String label,\n    required String value,\n    Validator? validator,\n  }) = _Field;',
         '  const Field({required this.label, required this.value, this.validator});\n  final String label;\n  final String value;\n  final FormFieldValidator<String>? validator;'),
    ], excerpt=('abstract class Field', 'class CloseWindowIntent', "import 'package:flutter/widgets.dart';\n\n", 'Field 输入描述；移除 Freezed 序列化，其他业务模型仍在源树'))
    register('lib/features/form/batch_section.dart', 'forms/batch_section.dart', [
        ("import 'package:fl_clash/common/common.dart';", ''),
        ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])
    register('lib/features/form/filter.dart', 'forms/filter_regex_text.dart', [
        ('AppTextStyle.footnote', 'AppTextStyle.footnote'),
    ], excerpt=('class FilterRegexText', None, prefix,
        'FilterRegexText 排版；mihomo 正则校验与持久化仍在源树'))

    register('lib/common/service_probe.dart', 'dashboard/service_types.dart', [], excerpt=(
        'enum ServiceTarget', 'class ServiceCheck', '', '服务名、状态枚举与排序；网络探测/路由解析仍在源树'))
    source = (base / 'lib/views/dashboard/widgets/service_status.dart').read_text(encoding='utf-8')
    imports = source[:source.index('String _statusLabel')]
    state = source[source.index('class ServiceStatusCard'):source.index('  @override\n  Widget build(BuildContext context) {\n    final density = DashboardDensityScope.of(context);')]
    shown = source[source.index('    final shown = ref'):source.index('    final problems =')]
    # The original badge is lower in the same file. Append through a checked
    # fragment in the existing transformation so one source keeps one ledger.
    badge = source[source.index('/// painted in the surface colour'):source.index('Future<void> showServiceStatusSheet')]
    # register() owns a mutable changes list, which is intentionally supplied as
    # an ordinary recipe: no handwritten duplicate of the paint code.
    # The separately located fragment is inserted before the final card helper.
    # The retained original comment documents the compositing rule.
    register_badge_source = badge.replace('_ServiceBadge', 'ServiceBadge')
    register_badge_source = register_badge_source.replace('const ServiceBadge({', 'const ServiceBadge({super.key,')
    register_badge_source = register_badge_source.replace("'assets/images/services/${target.icon}.svg',", "'assets/images/services/${target.icon}.svg',\n            package: 'flclash_ui_kit',")
    # A source excerpt can contain separated original ranges; the matrix says
    # partial and the full literal fragment is retained in the adaptation log.
    register('lib/views/dashboard/widgets/service_status.dart', 'dashboard/service_status.dart', [
        (imports, "import 'dart:math';\nimport 'package:flutter_svg/flutter_svg.dart';\n" + prefix),
        ('  _ServiceView(this.target, ProbeEntry<ServiceCheck> entry, this.phase)\n    : check = phase == entry.phase ? entry.value : null;',
         '  const _ServiceView(this.target, {this.check, this.phase = ProbePhase.idle});'),
        (state, '''class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard({super.key, required this.services, this.columns = 2,
    this.loading = false, this.onRefresh, this.onDetails}) : assert(columns > 0);
  final List<ServiceStatusItem> services;
  final int columns;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback? onDetails;

'''),
        (shown, '    final services = this.services.take(shownCount).toList();\n'),
        ('widget.columns', 'columns'),
        ('Future<void> openSheet() => showServiceStatusSheet(context);', 'final openSheet = onDetails;'),
        ('chevron: mobile,', 'chevron: mobile && onDetails != null,'),
        ('if (!stacked)\n                        _CheckAllButton(', 'if (!stacked && onRefresh != null)\n                        _CheckAllButton('),
        ('loading: shown.any(state.isLoading),', 'loading: loading,'),
        ('onPressed: () => _services.refresh(shown),', 'onPressed: onRefresh!,'),
        ('_ServiceView', 'ServiceStatusItem'),
        ('_ServiceBadge', 'ServiceBadge'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        # After public renaming/localization, anchor on the unchanged class name.
        ('class _CheckAllButton', register_badge_source + '\nclass _CheckAllButton'),
    ], excerpt=('import', 'mixin _NodeAddressWatch', '',
        'ServiceStatusCard/Grid/Cell/Badge 与画笔；数据回调解耦；详情/管理及网络仍在源树；Badge 来自同文件 533–642 行'))
    source = (base / 'lib/views/dashboard/widgets/network_takeover.dart').read_text(encoding='utf-8')
    provider_state = source[source.index('    final value = systemProxy'):source.index('    return DashboardSwitchRow')]
    vpn_setter = source[source.index('void _setVpn'):source.index('/// The VPN switch')]
    vpn_read = '''    final enabled = ref.watch(
      vpnSettingProvider.select((state) => state.enable),
    );'''
    register('lib/views/dashboard/widgets/network_takeover.dart', 'dashboard/network_takeover.dart', [
        (source[:source.index('typedef _RowMetrics')], prefix + "import 'package:prism_ui/shapes/shapes.dart' show MaterialShapes;\n\n"),
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
        ('    required this.kind,', '    required this.kind,\n    required this.value,\n    required this.onChanged,\n    required this.port,'),
        ('  final TakeoverSwitch kind;', '  final TakeoverSwitch kind;\n  final bool value;\n  final ValueChanged<bool> onChanged;\n  final int port;'),
        (provider_state, '    final on = systemProxy ? appLocalizations.portValue(port) : appLocalizations.enabled;\n    final change = onChanged;\n'),
        ('const NetworkTakeoverCard({super.key});', '''const NetworkTakeoverCard({super.key, required this.systemProxy, required this.tun,
    required this.onSystemProxyChanged, required this.onTunChanged, this.port = 7890});
  final bool systemProxy;
  final bool tun;
  final int port;
  final ValueChanged<bool> onSystemProxyChanged;
  final ValueChanged<bool> onTunChanged;'''),
        ('                      kind: kind,', '                      kind: kind,\n                      value: kind == TakeoverSwitch.systemProxy ? systemProxy : tun,\n                      onChanged: kind == TakeoverSwitch.systemProxy ? onSystemProxyChanged : onTunChanged,\n                      port: port,'),
        ('const NetworkTakeoverTile(this.kind, {super.key});', 'const NetworkTakeoverTile(this.kind, {super.key, required this.value, required this.onChanged, this.port = 7890});'),
        ('builder: (context, constraints) => _TakeoverRow(\n          kind: kind,', 'builder: (context, constraints) => _TakeoverRow(\n          kind: kind,\n          value: value,\n          onChanged: onChanged,\n          port: port,'),
        (vpn_setter, ''),
        ('const VpnTile({super.key});', 'const VpnTile({super.key, required this.enabled, required this.onChanged});\n  final bool enabled;\n  final ValueChanged<bool> onChanged;'),
        ('const VpnCard({super.key});', 'const VpnCard({super.key, required this.enabled, required this.onChanged});\n  final bool enabled;\n  final ValueChanged<bool> onChanged;'),
        (vpn_read, ''),
        ('() => _setVpn(ref, !enabled)', '() => onChanged(!enabled)'),
        ('(value) => _setVpn(ref, value)', 'onChanged'),
        ('void change(bool value) => _setVpn(ref, value);', 'final change = onChanged;'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])
