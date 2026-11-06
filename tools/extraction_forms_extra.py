"""Reviewed form editors, config item validators, CIDR check, and IP quality UI."""


def register_forms_extra(register, base):
    ipv6_helper = '''bool _isIpv6Address(String value) {
  if (value.isEmpty || value.contains('%') || value.trim() != value) {
    return false;
  }
  try {
    Uri.parseIPv6Address(value);
    return true;
  } on FormatException {
    return false;
  }
}

'''
    cidr_helpers = '''const privateRouteAddress = [
  '0.0.0.0/8',
  '10.0.0.0/8',
  '127.0.0.0/8',
  '169.254.0.0/16',
  '172.16.0.0/12',
  '192.168.0.0/16',
  '224.0.0.0/4',
  '255.255.255.255/32',
  'fc00::/7',
  'fe80::/10',
  'ff00::/8',
];

Uint8List? _tryParseRawAddress(String value) {
  if (value.isEmpty || value.contains('%')) {
    return null;
  }
  try {
    return Uint8List.fromList(
      value.contains(':')
          ? Uri.parseIPv6Address(value)
          : Uri.parseIPv4Address(value),
    );
  } on FormatException {
    return null;
  }
}

String _formatIpv6Bytes(Uint8List bytes) {
  final groups = List<int>.generate(
    8,
    (index) => (bytes[index * 2] << 8) | bytes[index * 2 + 1],
  );
  var bestStart = -1;
  var bestLen = 0;
  var curStart = -1;
  var curLen = 0;
  for (var i = 0; i < groups.length; i++) {
    if (groups[i] == 0) {
      if (curStart < 0) curStart = i;
      curLen++;
      if (curLen >= 2 && curLen > bestLen) {
        bestStart = curStart;
        bestLen = curLen;
      }
    } else {
      curStart = -1;
      curLen = 0;
    }
  }
  if (bestStart < 0) {
    return [for (final g in groups) g.toRadixString(16)].join(':');
  }
  final left = [
    for (var i = 0; i < bestStart; i++) groups[i].toRadixString(16),
  ].join(':');
  final right = [
    for (var i = bestStart + bestLen; i < groups.length; i++)
      groups[i].toRadixString(16),
  ].join(':');
  return '$left::$right';
}
'''
    register('lib/common/cidr.dart', 'forms/cidr.dart', [
        ('''import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';''', '''import 'dart:math';

import 'package:flutter/foundation.dart';

''' + cidr_helpers),
        ('''  return Isolate.run(
    () => subtractCidrs(include, exclude, wholeWhenEmpty: wholeWhenEmpty),
  );''', '''  return compute(
    (args) => subtractCidrs(args.$1, args.$2, wholeWhenEmpty: args.$3),
    (include, exclude, wholeWhenEmpty),
  );'''),
        ('''    final parsed = InternetAddress.tryParse(address);
    if (parsed?.type != InternetAddressType.IPv6 || address.trim() != address) {
      return false;
    }''', '''    if (!_isIpv6Address(address)) {
      return false;
    }'''),
        ('bool isCidr(String value) {', ipv6_helper + 'bool isCidr(String value) {'),
        ('''  final address = InternetAddress.tryParse(cidr.substring(0, slash).trim());
  final prefix = int.tryParse(cidr.substring(slash + 1).trim());
  if (address == null || prefix == null) {
    return null;
  }
  final raw = address.rawAddress;''', '''  final raw = _tryParseRawAddress(cidr.substring(0, slash).trim());
  final prefix = int.tryParse(cidr.substring(slash + 1).trim());
  if (raw == null || prefix == null) {
    return null;
  }'''),
        ('  return InternetAddress.fromRawAddress(bytes).address;', '  return _formatIpv6Bytes(bytes);'),
    ])

    register('lib/widgets/config_item.dart', 'forms/config_item.dart', [
        ('''import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/ui/list_item.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

export 'package:riverpod/misc.dart' show ProviderListenable;''', '''import 'package:flutter/widgets.dart';

import '../localizations.dart';
import '../ui/list_item.dart';
import 'cidr.dart';'''),
        ('AppLocalizations', 'KitLocalizations'),
        ('typedef ConfigWriter<T> = void Function(WidgetRef ref, T value);',
         'typedef ConfigWriter<T> = ValueChanged<T>;'),
        ('''bool _isIpv6(String value) =>
    InternetAddress.tryParse(value)?.type == InternetAddressType.IPv6;''', ipv6_helper + 'bool _isIpv6(String value) => _isIpv6Address(value);'),
        ('abstract class _ConfigItem<T> extends ConsumerWidget {', 'abstract class _ConfigItem<T> extends StatelessWidget {'),
        ('    required this.selector,', '    required this.value,'),
        ('  final ProviderListenable<T> selector;', '  final T value;'),
        ('''  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    KitLocalizations appLocalizations,
    T value,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return buildItem(context, ref, appLocalizations, ref.watch(selector));
  }''', '''  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    T value,
  );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return buildItem(context, appLocalizations, value);
  }'''),
        ('    required super.selector,', '    required super.value,'),
        ('''  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    KitLocalizations appLocalizations,
    bool value,
  ) {''', '''  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    bool value,
  ) {'''),
        ('onChanged: (value) => onChanged(ref, value),', 'onChanged: onChanged,'),
        ('''  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    KitLocalizations appLocalizations,
    T value,
  ) {''', '''  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    T value,
  ) {'''),
        ('''  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    KitLocalizations appLocalizations,
    String value,
  ) {''', '''  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    String value,
  ) {'''),
        ('        onChanged(ref, normalized);', '        onChanged(normalized);'),
    ])

    register('test/widgets/config_item_test.dart', '@test/widgets/config_item_test.dart', [
        ("import 'package:fl_clash/l10n/l10n.dart';", "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
        ("import 'package:fl_clash/widgets/config_item.dart';", ''),
        ('  late AppLocalizations appLocalizations;\n\n  setUpAll(() async {\n    appLocalizations = await AppLocalizations.load(const Locale(\'en\'));\n  });',
         '  const appLocalizations = KitLocalizations(Locale(\'en\'));'),
    ])

    register('lib/common/log_payload.dart', 'records/log_payload.dart')

    register('lib/models/ip_quality.dart', 'ip_quality/model.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ip_quality.freezed.dart';
part 'generated/ip_quality.g.dart';

@freezed
abstract class IpQuality with _$IpQuality {
  const factory IpQuality({
    required String ip,
    required IpQualitySource source,
    required IpType type,
    String? organization,
    int? asn,
    @Default(false) bool isProxy,
    @Default(false) bool isVpn,
    @Default(false) bool isTor,
    @Default(false) bool isAbuser,
  }) = _IpQuality;

  factory IpQuality.fromJson(Map<String, Object?> json) =>
      _$IpQualityFromJson(json);
}''', '''import 'package:flutter/foundation.dart';

import '../data.dart';

@immutable
class IpQuality {
  final String ip;
  final IpQualitySource source;
  final IpType type;
  final String? organization;
  final int? asn;
  final bool isProxy;
  final bool isVpn;
  final bool isTor;
  final bool isAbuser;

  const IpQuality({
    required this.ip,
    required this.source,
    required this.type,
    this.organization,
    this.asn,
    this.isProxy = false,
    this.isVpn = false,
    this.isTor = false,
    this.isAbuser = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpQuality &&
          other.ip == ip &&
          other.source == source &&
          other.type == type &&
          other.organization == organization &&
          other.asn == asn &&
          other.isProxy == isProxy &&
          other.isVpn == isVpn &&
          other.isTor == isTor &&
          other.isAbuser == isAbuser;

  @override
  int get hashCode => Object.hash(
        ip,
        source,
        type,
        organization,
        asn,
        isProxy,
        isVpn,
        isTor,
        isAbuser,
      );
}'''),
    ])

    register('lib/features/ip_quality/labels.dart', 'ip_quality/labels.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/ui.dart';''', '''import 'package:prism_ui/prism_ui.dart';

import '../data.dart';
import '../localizations.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/features/ip_quality/ip_quality_text.dart', 'ip_quality/ip_quality_text.dart', [
        ('''import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../ui/fonts.dart';
import 'model.dart';'''),
        ('''class IpQualityText extends ConsumerWidget {
  const IpQualityText({super.key, required this.ip, this.style});

  final String ip;
  final TextStyle? style;''', '''class IpQualityText extends StatelessWidget {
  const IpQualityText({
    super.key,
    required this.ip,
    this.quality,
    this.hideIp = false,
    this.style,
  });

  final String ip;
  final IpQuality? quality;
  final bool hideIp;
  final TextStyle? style;'''),
        ('''  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(ipQualityProvider(ip)).value;
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );''', '''  @override
  Widget build(BuildContext context) {'''),
    ])

    register('lib/features/ip_quality/ip_quality_sheet.dart', 'ip_quality/ip_quality_sheet.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'ip_quality_text.dart';
import 'labels.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';'''),
        ('''Future<void> showIpQualitySheet(BuildContext context, {required String ip}) {
  return showSheet<void>(
    context: context,
    builder: (_) => _IpQualitySheet(ip: ip),
  );
}

class _IpQualitySheet extends ConsumerWidget {
  const _IpQualitySheet({required this.ip});

  final String ip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final isLoading = ref.watch(
      ipQualityProvider(ip).select((result) => result.isLoading),
    );
    return Scaffold(
      title: localizations.outboundIp,
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: localizations.ipQualityRetry,
            isLoading: isLoading,
            onPressed: () => ref.invalidate(ipQualityProvider(ip)),
          ),
        ),
      ],
      body: _IpQualityDetail(ip: ip),
    );
  }
}

class _HideIpItem extends ConsumerWidget {
  const _HideIpItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    void update(bool value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(hideIp: value));
    return DecorationListItem(
      title: Text(context.appLocalizations.hideIp),
      onPressed: () => update(!hideIp),
      trailing: Switch(value: hideIp, onChanged: update),
    );
  }
}

class _IpQualityDetail extends ConsumerWidget {
  const _IpQualityDetail({required this.ip});

  /// The optical edge of the xl-radius cards, as in the memory sheet.
  static const _tipInset = 5.0;

  final String ip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final result = ref.watch(ipQualityProvider(ip));
    final quality = result.value;
    final error = result.error;
    final failed = quality == null && !result.isLoading;''', '''Future<void> showIpQualitySheet(
  BuildContext context, {
  required String ip,
  IpQuality? quality,
  bool isLoading = false,
  Object? error,
  bool hideIp = false,
  ValueChanged<bool>? onHideIpChanged,
  VoidCallback? onRetry,
}) {
  return showSheet<void>(
    context: context,
    builder: (_) => IpQualitySheet(
      ip: ip,
      quality: quality,
      isLoading: isLoading,
      error: error,
      hideIp: hideIp,
      onHideIpChanged: onHideIpChanged,
      onRetry: onRetry,
    ),
  );
}

class IpQualitySheet extends StatelessWidget {
  const IpQualitySheet({
    super.key,
    required this.ip,
    this.quality,
    this.isLoading = false,
    this.error,
    this.hideIp = false,
    this.onHideIpChanged,
    this.onRetry,
  });

  final String ip;
  final IpQuality? quality;
  final bool isLoading;
  final Object? error;
  final bool hideIp;
  final ValueChanged<bool>? onHideIpChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    return Scaffold(
      title: localizations.outboundIp,
      actions: [
        if (onRetry != null || isLoading)
          AppBarActionButton(
            data: IconButtonData(
              glyph: AppGlyphs.refresh,
              tooltip: localizations.ipQualityRetry,
              isLoading: isLoading,
              onPressed: onRetry,
            ),
          ),
      ],
      body: _IpQualityDetail(
        ip: ip,
        quality: quality,
        isLoading: isLoading,
        error: error,
        hideIp: hideIp,
        onHideIpChanged: onHideIpChanged,
      ),
    );
  }
}

class _HideIpItem extends StatelessWidget {
  const _HideIpItem({required this.hideIp, required this.onChanged});

  final bool hideIp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      title: Text(KitLocalizations.of(context).hideIp),
      onPressed: () => onChanged(!hideIp),
      trailing: Switch(value: hideIp, onChanged: onChanged),
    );
  }
}

class _IpQualityDetail extends StatelessWidget {
  const _IpQualityDetail({
    required this.ip,
    required this.quality,
    required this.isLoading,
    required this.error,
    required this.hideIp,
    required this.onHideIpChanged,
  });

  /// The optical edge of the xl-radius cards, as in the memory sheet.
  static const _tipInset = 5.0;

  final String ip;
  final IpQuality? quality;
  final bool isLoading;
  final Object? error;
  final bool hideIp;
  final ValueChanged<bool>? onHideIpChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    final error = this.error;
    final failed = quality == null && !isLoading;'''),
        ('value: IpQualityText(ip: ip),', 'value: IpQualityText(ip: ip, quality: quality, hideIp: hideIp),'),
        ('''        generateSection(
          title: localizations.other,
          items: const [_HideIpItem()],
        ),''', '''        if (onHideIpChanged != null)
          generateSection(
            title: localizations.other,
            items: [_HideIpItem(hideIp: hideIp, onChanged: onHideIpChanged!)],
          ),'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/features/form/list_edit_view.dart', 'forms/list_edit_view.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'list_editor_page.dart';
import 'quick_edit.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';'''),
        ('''abstract class EditViewState<W extends ConsumerStatefulWidget, T>
    extends ConsumerState<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  final _selectionKey = uniqueId;''', '''abstract class EditViewState<W extends StatefulWidget, T> extends State<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  Set<String> _selected = {};'''),
        ('  Future<void> showQuickEdit(List<T> entries, ValueChanged<List<T>> onChanged);',
         '  bool get hasQuickEdit => false;\n\n  Future<void> showQuickEdit(List<T> entries, ValueChanged<List<T>> onChanged);'),
        ('''  void _handleSelected(T entry) {
    ref.read(itemsProvider(_selectionKey).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(idOf(entry));
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _entries.map(idOf).toSet();
    ref.read(itemsProvider(_selectionKey).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }''', '''  void _handleSelected(T entry) {
    setState(() {
      _selected = Set<String>.from(_selected)..addOrRemove(idOf(entry));
    });
  }

  void _handleSelectAll() {
    final ids = _entries.map(idOf).toSet();
    setState(() {
      _selected = _selected.containsAll(ids) ? {} : ids;
    });
  }'''),
        ('''    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.deleteMultipTip(title)),
      destructive: true,
      confirmText: context.appLocalizations.delete,
    );
    if (res != true || !mounted) {
      return;
    }
    final selected = ref.read(itemsProvider(_selectionKey));
    _entries = _entries
        .where((entry) => !selected.contains(idOf(entry)))
        .toList();
    ref.read(itemsProvider(_selectionKey).notifier).value = {};
    setState(() {});''', '''    final res = await showKitMessage(
      context,
      message: TextSpan(text: KitLocalizations.of(context).deleteMultipTip(title)),
      destructive: true,
      confirmText: KitLocalizations.of(context).delete,
    );
    if (res != true || !mounted) {
      return;
    }
    _entries = _entries
        .where((entry) => !_selected.contains(idOf(entry)))
        .toList();
    _selected = {};
    setState(() {});'''),
        ('final res = await dialogs.showSaveChanges();', 'final res = await showKitSaveChanges(context);'),
        ('''    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
      destructive: true,
      confirmText: context.appLocalizations.reset,
    );''', '''    final res = await showKitMessage(
      context,
      message: TextSpan(text: KitLocalizations.of(context).resetPageChangesTip),
      destructive: true,
      confirmText: KitLocalizations.of(context).reset,
    );'''),
        ('    final appLocalizations = context.appLocalizations;\n    final selected = ref.watch(itemsProvider(_selectionKey));',
         '    final appLocalizations = KitLocalizations.of(context);\n    final selected = _selected;'),
        ('              ref.read(itemsProvider(_selectionKey).notifier).value = {};',
         '              setState(() => _selected = {});'),
        ('              onQuickEdit: _handleQuickEdit,',
         '              onQuickEdit: hasQuickEdit ? _handleQuickEdit : null,'),
        ('''class ConfigListEditItem extends ConsumerWidget {
  const ConfigListEditItem({
    super.key,
    required this.selector,
    required this.title,
    required this.onChanged,
    this.itemMaxLength,
    this.itemValidator,
    this.description,
    this.subtitle,
    this.leading,
  });

  final ProviderListenable<List<String>> selector;
  final ConfigLabel title;
  final ConfigWriter<List<String>> onChanged;
  final int? itemMaxLength;
  final ConfigValidator? itemValidator;
  final ConfigLabel? description;
  final ConfigLabel? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final value = ref.watch(selector);''', '''class ConfigListEditItem extends StatelessWidget {
  const ConfigListEditItem({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
    this.itemMaxLength,
    this.itemValidator,
    this.description,
    this.subtitle,
    this.leading,
    this.onQuickEdit,
  });

  final List<String> value;
  final ConfigLabel title;
  final ValueChanged<List<String>> onChanged;
  final int? itemMaxLength;
  final ConfigValidator? itemValidator;
  final ConfigLabel? description;
  final ConfigLabel? subtitle;
  final Widget? leading;
  final Future<void> Function(List<String> items, ValueChanged<List<String>> onChanged)? onQuickEdit;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);'''),
        ('        titleBuilder: (item) => Text(item),\n      ),',
         '        titleBuilder: (item) => Text(item),\n        onQuickEdit: onQuickEdit,\n      ),'),
        ('          onChanged(ref, next);', '          onChanged(next);'),
        ('''class ListEditView extends ConsumerStatefulWidget {
  final String title;
  final String? description;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final int? itemMaxLength;
  final String? Function(String item)? itemValidator;

  const ListEditView({
    super.key,
    required this.title,
    this.description,
    required this.items,
    required this.titleBuilder,
    this.itemMaxLength,
    this.itemValidator,
  });

  @override
  ConsumerState<ListEditView> createState() => _ListEditViewState();
}''', '''class ListEditView extends StatefulWidget {
  final String title;
  final String? description;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final int? itemMaxLength;
  final String? Function(String item)? itemValidator;
  final Future<void> Function(
    List<String> items,
    ValueChanged<List<String>> onChanged,
  )? onQuickEdit;

  const ListEditView({
    super.key,
    required this.title,
    this.description,
    required this.items,
    required this.titleBuilder,
    this.itemMaxLength,
    this.itemValidator,
    this.onQuickEdit,
  });

  @override
  State<ListEditView> createState() => _ListEditViewState();
}'''),
        ('''  @override
  Future<void> showQuickEdit(
    List<String> entries,
    ValueChanged<List<String>> onChanged,
  ) {
    return showListQuickEdit(
      context,
      title: widget.title,
      items: entries,
      itemMaxLength: widget.itemMaxLength,
      itemValidator: widget.itemValidator,
      onChanged: onChanged,
    );
  }''', '''  @override
  bool get hasQuickEdit => widget.onQuickEdit != null;

  @override
  Future<void> showQuickEdit(
    List<String> entries,
    ValueChanged<List<String>> onChanged,
  ) {
    final runner = widget.onQuickEdit;
    if (runner == null) return Future.value();
    return runner(entries, onChanged);
  }'''),
        ('final appLocalizations = context.appLocalizations;', 'final appLocalizations = KitLocalizations.of(context);'),
        ('  return dialogs.showCommonDialog<String>(\n    child: EntryDialog<String>(',
         '  return showFloatingDialog<String>(\n    context: context,\n    child: EntryDialog<String>('),
    ])

    register('lib/features/form/map_edit_view.dart', 'forms/map_edit_view.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'form_page.dart';
import 'form_row.dart';
import 'list_edit_view.dart';
import 'quick_edit.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';'''),
        ('''class MapEditView extends ConsumerStatefulWidget {
  final String title;
  final String? description;
  final Map<String, String> entries;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final int? keyMaxLength;
  final int? valueMaxLength;

  const MapEditView({
    super.key,
    required this.title,
    this.description,
    required this.entries,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.keyMaxLength,
    this.valueMaxLength,
  });

  @override
  ConsumerState<MapEditView> createState() => _MapEditViewState();
}''', '''class MapEditView extends StatefulWidget {
  final String title;
  final String? description;
  final Map<String, String> entries;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final int? keyMaxLength;
  final int? valueMaxLength;
  final Future<void> Function(
    List<MapEntry<String, String>> entries,
    ValueChanged<List<MapEntry<String, String>>> onChanged,
  )? onQuickEdit;

  const MapEditView({
    super.key,
    required this.title,
    this.description,
    required this.entries,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.keyMaxLength,
    this.valueMaxLength,
    this.onQuickEdit,
  });

  @override
  State<MapEditView> createState() => _MapEditViewState();
}'''),
        ('''  @override
  Future<void> showQuickEdit(
    List<_Entry> entries,
    ValueChanged<List<_Entry>> onChanged,
  ) {
    return showMapQuickEdit(
      context,
      title: widget.title,
      entries: entries,
      keyMaxLength: widget.keyMaxLength,
      valueMaxLength: widget.valueMaxLength,
      onChanged: onChanged,
    );
  }''', '''  @override
  bool get hasQuickEdit => widget.onQuickEdit != null;

  @override
  Future<void> showQuickEdit(
    List<_Entry> entries,
    ValueChanged<List<_Entry>> onChanged,
  ) {
    final runner = widget.onQuickEdit;
    if (runner == null) return Future.value();
    return runner(entries, onChanged);
  }'''),
        ('AppLocalizations', 'KitLocalizations'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/features/form/named_url_form.dart', 'forms/named_url_form.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'batch_section.dart';
import 'form_page.dart';
import 'form_row.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';'''),
        ('AppLocalizations', 'KitLocalizations'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    cidr_test_src = (base / 'test/common/cidr_test.dart').read_text(encoding='utf-8')
    tun_test = cidr_test_src[
        cidr_test_src.index("  test('an include list wholly excluded"):
        cidr_test_src.index("  test('the task subtracts")
    ]
    register('test/common/cidr_test.dart', '@test/common/cidr_test.dart', [
        ("import 'package:fl_clash/common/cidr.dart';\nimport 'package:fl_clash/models/models.dart';",
         "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
        (tun_test, ''),
    ])

    register('test/common/log_payload_test.dart', '@test/common/log_payload_test.dart', [
        ("import 'package:fl_clash/common/common.dart';",
         "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
    ])

    register('test/features/named_url_form_test.dart', '@test/features/named_url_form_test.dart', [
        ('''import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/ui.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';'''),
        ('      overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],\n', ''),
        ("'URL cannot be empty'", "'URL is required'"),
        ("'1 to add, 0 skipped as existing'", "'Add 1 items; skip 0 existing'"),
        ("'2 to add, 1 skipped as existing'", "'Add 2 items; skip 1 existing'"),
    ])
