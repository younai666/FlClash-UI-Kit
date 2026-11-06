// Derived from chen08209/FlClash, lib/widgets/config_item.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';

import '../localizations.dart';
import '../ui/list_item.dart';
import 'cidr.dart';

typedef ConfigLabel = String Function(KitLocalizations appLocalizations);

typedef ConfigWriter<T> = ValueChanged<T>;

typedef ConfigValidator =
    String? Function(String? value, KitLocalizations appLocalizations);

String? validateCidr(String? value, KitLocalizations appLocalizations) {
  return isCidr(value ?? '') ? null : appLocalizations.invalidCidrContent;
}

/// The sniffer's address lists also take mihomo's geoip: and rule-set: items.
String? validateIpMatcher(String? value, KitLocalizations appLocalizations) {
  final lower = value?.toLowerCase() ?? '';
  if (lower.startsWith('geoip:') || lower.startsWith('rule-set:')) {
    return null;
  }
  return validateCidr(value, appLocalizations);
}

final _portRange = RegExp(r'^([0-9]{1,5})(?:-([0-9]{1,5}))?$');

final _domainLabel = RegExp(
  r'^[A-Za-z0-9_]([A-Za-z0-9_-]{0,61}[A-Za-z0-9_])?$',
);

final _port = RegExp(r'^[0-9]{1,5}$');

bool _isIpv6Address(String value) {
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

bool _isIpv6(String value) => _isIpv6Address(value);

bool _isHost(String value) => value.contains(':')
    ? _isIpv6(value)
    : value.length <= 253 && value.split('.').every(_domainLabel.hasMatch);

String? validateHost(String? value, KitLocalizations appLocalizations) {
  return _isHost(value ?? '') ? null : appLocalizations.invalidHostContent;
}

/// mihomo starts no DNS server, and only logs why, for an address this refuses.
String? validateListenAddress(
  String? value,
  KitLocalizations appLocalizations,
) {
  final text = value ?? '';
  final colon = text.lastIndexOf(':');
  final host = colon < 0 ? null : text.substring(0, colon);
  final port = colon < 0 ? '' : text.substring(colon + 1);
  final validHost = switch (host) {
    null => false,
    '' => true,
    final host when host.startsWith('[') && host.endsWith(']') => _isIpv6(
      host.substring(1, host.length - 1),
    ),
    final host => !host.contains(':') && _isHost(host),
  };
  final validPort =
      _port.hasMatch(port) && int.parse(port) > 0 && int.parse(port) <= 65535;
  return validHost && validPort ? null : appLocalizations.invalidListenContent;
}

String? validatePortRange(String? value, KitLocalizations appLocalizations) {
  final match = _portRange.firstMatch(value ?? '');
  if (match == null ||
      [?match[1], ?match[2]].any((port) => int.parse(port) > 65535)) {
    return appLocalizations.invalidPortRangeContent;
  }
  return null;
}

abstract class _ConfigItem<T> extends StatelessWidget {
  const _ConfigItem({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final T value;
  final ConfigLabel title;
  final ConfigLabel? subtitle;
  final ConfigWriter<T> onChanged;
  final Widget? leading;

  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    T value,
  );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return buildItem(context, appLocalizations, value);
  }

  Widget? buildSubtitle(KitLocalizations appLocalizations) {
    final subtitle = this.subtitle;
    return subtitle == null ? null : Text(subtitle(appLocalizations));
  }
}

class ConfigToggleItem extends _ConfigItem<bool> {
  const ConfigToggleItem({
    super.key,
    required super.value,
    required super.title,
    required super.onChanged,
    super.leading,
  });

  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    bool value,
  ) {
    return ListItem.toggle(
      leading: leading,
      title: Text(title(appLocalizations)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class ConfigOptionsItem<T> extends _ConfigItem<T> {
  const ConfigOptionsItem({
    super.key,
    required super.value,
    required super.title,
    required super.onChanged,
    required this.options,
    required this.textBuilder,
    super.subtitle,
    super.leading,
  });

  final List<T> options;
  final String Function(T value) textBuilder;

  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    T value,
  ) {
    return ListItem<T>.options(
      leading: leading,
      title: Text(title(appLocalizations)),
      subtitle: buildSubtitle(appLocalizations),
      options: options,
      value: value,
      textBuilder: textBuilder,
      onChanged: onChanged,
    );
  }
}

class ConfigTextItem extends _ConfigItem<String> {
  const ConfigTextItem({
    super.key,
    required super.value,
    required super.title,
    required super.onChanged,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.normalize,
    this.allowEmpty = false,
    super.leading,
  });

  final int? maxLength;
  final TextInputType? keyboardType;
  final ConfigValidator? validator;
  final String Function(String value)? normalize;
  final bool allowEmpty;

  String? _normalize(String? value) {
    if (value == null) {
      return null;
    }
    return normalize?.call(value) ?? value;
  }

  @override
  Widget buildItem(
    BuildContext context,
    KitLocalizations appLocalizations,
    String value,
  ) {
    final label = title(appLocalizations);
    final validator = this.validator;
    return ListItem.input(
      leading: leading,
      title: Text(label),
      subtitle: value.isEmpty ? null : Text(value),
      dialogTitle: label,
      value: value,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: (text) {
        final normalized = _normalize(text);
        if (normalized == null || normalized.isEmpty) {
          return allowEmpty ? null : appLocalizations.emptyTip(label);
        }
        return validator?.call(normalized, appLocalizations);
      },
      onChanged: (text) {
        final normalized = _normalize(text);
        if (normalized == null || normalized == value) {
          return;
        }
        onChanged(normalized);
      },
    );
  }
}
