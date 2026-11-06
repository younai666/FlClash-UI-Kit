// ignore_for_file: constant_identifier_names
// Presentation projections of FlClash lib/enum/enum.dart, lib/models/common.dart,
// lib/models/clash_config.dart, lib/models/config.dart, lib/models/state.dart,
// lib/common/layout.dart, lib/common/constant.dart, lib/common/app_localizations.dart,
// and lib/providers/state/custom.dart, commit be84736605527034689c95bf27828ff27d912c5e.
// Modified 2026-11-06: remove Freezed/JSON codegen and Riverpod; preserve value
// semantics, breakpoint formulas, and delay/selection state contracts. GPL-3.0.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import '../localizations.dart';
export '../window/layout.dart';

const delayTimedOutValue = -1;
const defaultTestUrl = 'https://www.gstatic.com/generate_204';
const maxMobileWidth = 600.0;
const maxLaptopWidth = 840.0;
const proxiesListStoreKey = PageStorageKey<String>('proxies_list');

/// Names the core registers before any proxy is parsed.
const reservedProxyNames = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'COMPATIBLE',
  'PASS',
  'PASS-RULE',
};

/// A group may take GLOBAL to stand in for the core's own selector, while a
/// proxy of that name is shadowed by the selector.
const reservedCustomProxyNames = {...reservedProxyNames, 'GLOBAL'};

typedef DelayMap = Map<String, Map<String, int?>>;

String delayFailureText(int delay, KitLocalizations appLocalizations) {
  return delay == delayTimedOutValue
      ? appLocalizations.timeout
      : appLocalizations.delayFailed;
}

enum GroupType {
  Selector('select'),
  URLTest('url-test'),
  Fallback('fallback'),
  LoadBalance('load-balance'),
  Relay('relay');

  final String value;

  const GroupType(this.value);

  static GroupType parse(String type) {
    return switch (type.toLowerCase()) {
      'url-test' || 'urltest' => URLTest,
      'select' || 'selector' => Selector,
      'fallback' => Fallback,
      'load-balance' || 'loadbalance' => LoadBalance,
      'relay' => Relay,
      String() => throw UnimplementedError(),
    };
  }

  static List<GroupType> get selectableValues =>
      values.where((item) => item != Relay).toList();
}

extension GroupTypeExtension on GroupType {
  static List<String> get valueList =>
      GroupType.values.map((e) => e.toString().split('.').last).toList();

  bool get isComputedSelected {
    return [GroupType.URLTest, GroupType.Fallback].contains(this);
  }

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }
}

enum DelayTestPhase { queued, running }

enum ViewMode { mobile, laptop, desktop }

enum ProxiesSortType { none, delay, name }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { loose, standard, compact }

enum ProxiesIconStyle { filled, plain, hidden }

extension ProxiesTypeL10n on ProxiesType {
  String labelOf(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return switch (this) {
      ProxiesType.tab => appLocalizations.tab,
      ProxiesType.list => appLocalizations.list,
    };
  }
}

extension ProxyCardTypeL10n on ProxyCardType {
  String labelOf(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return switch (this) {
      ProxyCardType.loose => appLocalizations.loose,
      ProxyCardType.standard => appLocalizations.standard,
      ProxyCardType.compact => appLocalizations.compact,
    };
  }
}

@immutable
class Proxy {
  final String name;
  final String type;
  final String? now;
  final String? providerName;

  const Proxy({
    required this.name,
    required this.type,
    this.now,
    this.providerName,
  });

  Proxy copyWith({
    String? name,
    String? type,
    String? now,
    String? providerName,
  }) {
    return Proxy(
      name: name ?? this.name,
      type: type ?? this.type,
      now: now ?? this.now,
      providerName: providerName ?? this.providerName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Proxy &&
          other.name == name &&
          other.type == type &&
          other.now == now &&
          other.providerName == providerName;

  @override
  int get hashCode => Object.hash(name, type, now, providerName);
}

extension ProxyExt on Proxy {
  List<String> get searchFields => [name, type];
}

@immutable
class Group {
  final GroupType type;
  final List<Proxy> all;
  final String? now;
  final bool? hidden;
  final String? testUrl;
  final String icon;
  final String name;

  const Group({
    required this.type,
    this.all = const [],
    this.now,
    this.hidden,
    this.testUrl,
    this.icon = '',
    required this.name,
  });

  Group copyWith({
    GroupType? type,
    List<Proxy>? all,
    String? now,
    bool? hidden,
    String? testUrl,
    String? icon,
    String? name,
  }) {
    return Group(
      type: type ?? this.type,
      all: all ?? this.all,
      now: now ?? this.now,
      hidden: hidden ?? this.hidden,
      testUrl: testUrl ?? this.testUrl,
      icon: icon ?? this.icon,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          other.type == type &&
          listEquals(other.all, all) &&
          other.now == now &&
          other.hidden == hidden &&
          other.testUrl == testUrl &&
          other.icon == icon &&
          other.name == name;

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(all),
        now,
        hidden,
        testUrl,
        icon,
        name,
      );
}

final _groupsByName = Expando<Map<String, Group>>();

extension GroupsExt on List<Group> {
  /// Indexed once per list, so a list must not change after its first lookup.
  Group? getGroup(String groupName) => (_groupsByName[this] ??= {
        for (final group in this) group.name: group,
      })[groupName];
}

extension GroupExt on Group {
  String get realNow => now ?? '';

  String getCurrentSelectedName(String proxyName) {
    if (type.isComputedSelected) {
      return realNow.isNotEmpty ? realNow : proxyName;
    }
    return proxyName.isNotEmpty && _isMember(proxyName) ? proxyName : realNow;
  }

  /// A saved pick outlives a subscription update that renames or drops it.
  bool _isMember(String proxyName) =>
      all.isEmpty || all.any((proxy) => proxy.name == proxyName);
}

@immutable
class SelectedProxyState {
  final String proxyName;
  final bool group;
  final String? testUrl;

  const SelectedProxyState({
    required this.proxyName,
    this.group = false,
    this.testUrl,
  });

  SelectedProxyState copyWith({
    String? proxyName,
    bool? group,
    String? testUrl,
  }) {
    return SelectedProxyState(
      proxyName: proxyName ?? this.proxyName,
      group: group ?? this.group,
      testUrl: testUrl ?? this.testUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedProxyState &&
          other.proxyName == proxyName &&
          other.group == group &&
          other.testUrl == testUrl;

  @override
  int get hashCode => Object.hash(proxyName, group, testUrl);
}

@immutable
class DelayState {
  final int delay;
  final bool group;

  const DelayState({required this.delay, required this.group});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelayState && other.delay == delay && other.group == group;

  @override
  int get hashCode => Object.hash(delay, group);
}

extension DelayStateExt on DelayState {
  int get priority {
    if (delay > 0) return 0;
    if (delay == 0) return 1;
    if (delay == delayTimedOutValue) return 2;
    return 3;
  }

  int compareTo(DelayState other) {
    if (priority != other.priority) {
      return priority.compareTo(other.priority);
    }
    if (delay != other.delay) {
      return delay.compareTo(other.delay);
    }
    if (group && !other.group) return -1;
    if (!group && other.group) return 1;
    return 0;
  }
}

const defaultProxiesStyleProps = ProxiesStyleProps();

@immutable
class ProxiesStyleProps {
  final ProxiesType type;
  final ProxiesSortType sortType;
  final ProxiesLayout layout;
  final ProxiesIconStyle iconStyle;
  final ProxyCardType cardType;
  final bool hideTimeoutProxies;

  const ProxiesStyleProps({
    this.type = ProxiesType.list,
    this.sortType = ProxiesSortType.none,
    this.layout = ProxiesLayout.standard,
    this.iconStyle = ProxiesIconStyle.filled,
    this.cardType = ProxyCardType.standard,
    this.hideTimeoutProxies = false,
  });

  ProxiesStyleProps copyWith({
    ProxiesType? type,
    ProxiesSortType? sortType,
    ProxiesLayout? layout,
    ProxiesIconStyle? iconStyle,
    ProxyCardType? cardType,
    bool? hideTimeoutProxies,
  }) {
    return ProxiesStyleProps(
      type: type ?? this.type,
      sortType: sortType ?? this.sortType,
      layout: layout ?? this.layout,
      iconStyle: iconStyle ?? this.iconStyle,
      cardType: cardType ?? this.cardType,
      hideTimeoutProxies: hideTimeoutProxies ?? this.hideTimeoutProxies,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProxiesStyleProps &&
          other.type == type &&
          other.sortType == sortType &&
          other.layout == layout &&
          other.iconStyle == iconStyle &&
          other.cardType == cardType &&
          other.hideTimeoutProxies == hideTimeoutProxies;

  @override
  int get hashCode => Object.hash(
        type,
        sortType,
        layout,
        iconStyle,
        cardType,
        hideTimeoutProxies,
      );
}

@immutable
class ProxiesListState {
  final List<Group> groups;
  final Set<String> currentUnfoldSet;
  final ProxyCardType proxyCardType;

  const ProxiesListState({
    required this.groups,
    required this.currentUnfoldSet,
    required this.proxyCardType,
  });

  ProxiesListState copyWith({
    List<Group>? groups,
    Set<String>? currentUnfoldSet,
    ProxyCardType? proxyCardType,
  }) {
    return ProxiesListState(
      groups: groups ?? this.groups,
      currentUnfoldSet: currentUnfoldSet ?? this.currentUnfoldSet,
      proxyCardType: proxyCardType ?? this.proxyCardType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProxiesListState &&
          listEquals(other.groups, groups) &&
          setEquals(other.currentUnfoldSet, currentUnfoldSet) &&
          other.proxyCardType == proxyCardType;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(groups),
        Object.hashAll(currentUnfoldSet),
        proxyCardType,
      );
}

@immutable
class ProxiesTabState {
  final List<Group> groups;
  final String? currentGroupName;
  final ProxyCardType proxyCardType;

  const ProxiesTabState({
    required this.groups,
    required this.currentGroupName,
    required this.proxyCardType,
  });

  ProxiesTabState copyWith({
    List<Group>? groups,
    String? currentGroupName,
    ProxyCardType? proxyCardType,
  }) {
    return ProxiesTabState(
      groups: groups ?? this.groups,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      proxyCardType: proxyCardType ?? this.proxyCardType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProxiesTabState &&
          listEquals(other.groups, groups) &&
          other.currentGroupName == currentGroupName &&
          other.proxyCardType == proxyCardType;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(groups),
        currentGroupName,
        proxyCardType,
      );
}

@immutable
class ProxiesTabControllerState {
  final List<String> groupNames;
  final String? currentGroupName;

  const ProxiesTabControllerState({
    required this.groupNames,
    required this.currentGroupName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProxiesTabControllerState &&
          stringListEquality.equals(other.groupNames, groupNames) &&
          other.currentGroupName == currentGroupName;

  @override
  int get hashCode =>
      Object.hash(stringListEquality.hash(groupNames), currentGroupName);
}
