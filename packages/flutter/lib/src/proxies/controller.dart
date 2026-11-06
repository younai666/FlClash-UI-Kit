// Host-owned controller and InheritedNotifier scope for FlClash proxies views
// (adapted from FlClash lib/providers/state/proxies.dart and
// lib/providers/action.dart, commit be84736605527034689c95bf27828ff27d912c5e).
// GPL-3.0.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../dashboard/mode.dart';
import '../search.dart';
import '../string.dart';
import 'compute.dart';
import 'models.dart';

class ProxiesController extends ChangeNotifier {
  ProxiesController({
    List<Group> groups = const [],
    this._mode,
    this._viewModeOverride,
    this._style = defaultProxiesStyleProps,
    Map<String, String> selectedMap = const {},
    DelayMap delayMap = const {},
    Set<String> unfoldSet = const {},
    String? currentGroupName,
    this._query = '',
    this.testUrl = defaultTestUrl,
    this._isCustomProfile = false,
    this.profileId = 'default',
    this._isLoading = false,
    this.onStyleChanged,
    this.onSelectProxy,
    this.onUnfoldSetChanged,
    this.onCurrentGroupChanged,
    this.onTestProxyDelay,
    this.onTestGroupDelay,
    this.onAddToLocalProxies,
  }) : _rawGroups = List<Group>.unmodifiable(groups),
       _selectedMap = Map<String, String>.unmodifiable(selectedMap),
       _delayMap = _cloneDelayMap(delayMap),
       _delaysAtLastTestBatch = _cloneDelayMap(delayMap),
       _unfoldSet = Set<String>.unmodifiable(unfoldSet),
       _currentGroupName =
           currentGroupName ?? (groups.isEmpty ? null : groups.first.name);

  List<Group> _rawGroups;
  Mode? _mode;
  ViewMode? _viewModeOverride;
  ProxiesStyleProps _style;
  Map<String, String> _selectedMap;
  DelayMap _delayMap;
  DelayMap _delaysAtLastTestBatch;
  Set<String> _unfoldSet;
  String? _currentGroupName;
  String _query;
  final String testUrl;
  bool _isCustomProfile;
  final String profileId;
  bool _isLoading;
  List<Group>? _cachedFilteredGroups;
  final Map<String, DelayTestPhase> _pendingDelayTests = {};
  final Set<String> _delayTestingGroups = {};

  final ValueChanged<ProxiesStyleProps>? onStyleChanged;
  final void Function(String groupName, String proxyName)? onSelectProxy;
  final ValueChanged<Set<String>>? onUnfoldSetChanged;
  final ValueChanged<String>? onCurrentGroupChanged;
  final Future<int?> Function(Proxy proxy, String testUrl)? onTestProxyDelay;
  final Future<void> Function(String groupName)? onTestGroupDelay;
  final FutureOr<void> Function(Proxy proxy)? onAddToLocalProxies;

  static DelayMap _cloneDelayMap(DelayMap source) => {
    for (final entry in source.entries)
      entry.key: Map<String, int?>.unmodifiable(entry.value),
  };

  List<Group> get rawGroups => _rawGroups;
  Mode? get mode => _mode;
  ViewMode? get viewModeOverride => _viewModeOverride;
  ProxiesStyleProps get style => _style;
  Map<String, String> get selectedMap => _selectedMap;
  DelayMap get delayMap => _delayMap;
  Set<String> get unfoldSet => _unfoldSet;
  String? get currentGroupName => _currentGroupName;
  String get query => _query;
  bool get isCustomProfile => _isCustomProfile;
  bool get isLoading => _isLoading;
  bool get isSearching => SearchQuery(_query).isNotEmpty;

  ViewMode viewModeOf(BuildContext context) =>
      _viewModeOverride ?? getViewMode(ViewScope.sizeOf(context).width);

  String realTestUrl([String? groupTestUrl]) =>
      groupTestUrl.takeFirstValid([testUrl, defaultTestUrl]);

  String? proxyNameOf(String groupName) => _selectedMap[groupName];

  String? selectedProxyNameOf(String groupName) {
    final group = _rawGroups.getGroup(groupName);
    return group?.getCurrentSelectedName(_selectedMap[groupName] ?? '');
  }

  SelectedProxyState realSelectedProxyStateOf(String proxyName) {
    return computeRealSelectedProxyState(
      proxyName,
      groups: _rawGroups,
      selectedMap: _selectedMap,
    );
  }

  int? delayOf(String proxyName, [String? groupTestUrl]) {
    final currentTestUrl = realTestUrl(groupTestUrl);
    final proxyState = realSelectedProxyStateOf(proxyName);
    final effectiveTestUrl = proxyState.testUrl.takeFirstValid([
      currentTestUrl,
    ]);
    return _delayMap[effectiveTestUrl]?[proxyState.proxyName];
  }

  DelayTestPhase? delayTestPhaseOf(String proxyName, [String? groupTestUrl]) {
    final currentTestUrl = realTestUrl(groupTestUrl);
    final proxyState = realSelectedProxyStateOf(proxyName);
    final effectiveTestUrl = proxyState.testUrl.takeFirstValid([
      currentTestUrl,
    ]);
    return _pendingDelayTests[delayTestKey(
      effectiveTestUrl,
      proxyState.proxyName,
    )];
  }

  bool isGroupDelayTesting(String? groupName) =>
      groupName != null && _delayTestingGroups.contains(groupName);

  bool get currentGroupDelayTesting =>
      isGroupDelayTesting(tabControllerState.currentGroupName);

  List<Group> get _sortedCurrentGroups {
    final sorted = computeSort(
      groups: _rawGroups,
      sortType: _style.sortType,
      delayMap: _delaysAtLastTestBatch,
      selectedMap: _selectedMap,
      defaultTestUrl: realTestUrl(),
    );
    final shown = switch (_mode) {
      Mode.direct => const <Group>[],
      Mode.global => sorted,
      Mode.rule || null => sorted.where((item) => item.hidden != true),
    };
    return shown.map(_withoutSelection).toList();
  }

  static Group _withoutSelection(Group group) {
    final all = group.all.any(_hasSelection)
        ? [
            for (final proxy in group.all)
              _hasSelection(proxy) ? proxy.copyWith(now: '') : proxy,
          ]
        : group.all;
    return group.copyWith(now: '', all: all);
  }

  static bool _hasSelection(Proxy proxy) => proxy.now?.isNotEmpty ?? false;

  List<Group> _applyHideTimeout(List<Group> groups) {
    if (!_style.hideTimeoutProxies) {
      return groups;
    }
    return computeHideTimeout(
      groups: groups,
      allGroups: _rawGroups,
      delayMap: _delaysAtLastTestBatch,
      selectedMap: _selectedMap,
      defaultTestUrl: realTestUrl(),
    );
  }

  List<Group> get visibleGroups => _applyHideTimeout(_sortedCurrentGroups);

  List<Group> get filteredGroups {
    final cached = _cachedFilteredGroups;
    if (cached != null) {
      return cached;
    }
    final searchQuery = SearchQuery(_query);
    final List<Group> computed;
    if (searchQuery.isEmpty) {
      computed = List<Group>.unmodifiable(visibleGroups);
    } else {
      final matches = <Proxy, bool>{};
      final groups = _sortedCurrentGroups
          .map(
            (group) => group.copyWith(
              all: group.all
                  .where(
                    (proxy) => matches[proxy] ??= searchQuery.matches(
                      proxy.searchFields,
                    ),
                  )
                  .toList(),
            ),
          )
          .where((group) => group.all.isNotEmpty)
          .toList();
      computed = List<Group>.unmodifiable(_applyHideTimeout(groups));
    }
    _cachedFilteredGroups = computed;
    return computed;
  }

  void _invalidateGroups() {
    _cachedFilteredGroups = null;
  }

  ProxiesListState get listState => ProxiesListState(
    groups: filteredGroups,
    currentUnfoldSet: _unfoldSet,
    proxyCardType: _style.cardType,
  );

  ProxiesTabState get tabState => ProxiesTabState(
    groups: filteredGroups,
    currentGroupName: _currentGroupName,
    proxyCardType: _style.cardType,
  );

  ProxiesTabControllerState get tabControllerState {
    final state = tabState;
    return ProxiesTabControllerState(
      groupNames: [for (final group in state.groups) group.name],
      currentGroupName: state.currentGroupName,
    );
  }

  void setGroups(List<Group> groups) {
    if (listEquals(_rawGroups, groups)) return;
    _rawGroups = List<Group>.unmodifiable(groups);
    _invalidateGroups();
    if (_currentGroupName == null && groups.isNotEmpty) {
      _currentGroupName = groups.first.name;
    }
    notifyListeners();
  }

  void setMode(Mode? mode) {
    if (_mode == mode) return;
    _mode = mode;
    _invalidateGroups();
    notifyListeners();
  }

  void setViewModeOverride(ViewMode? viewMode) {
    if (_viewModeOverride == viewMode) return;
    _viewModeOverride = viewMode;
    notifyListeners();
  }

  void setCustomProfile(bool isCustomProfile) {
    if (_isCustomProfile == isCustomProfile) return;
    _isCustomProfile = isCustomProfile;
    notifyListeners();
  }

  void updateStyle(
    ProxiesStyleProps Function(ProxiesStyleProps current) updater,
  ) {
    final next = updater(_style);
    if (next == _style) return;
    if (next.sortType != _style.sortType ||
        next.hideTimeoutProxies != _style.hideTimeoutProxies) {
      _invalidateGroups();
    }
    _style = next;
    onStyleChanged?.call(next);
    notifyListeners();
  }

  void setStyle(ProxiesStyleProps style) {
    if (_style == style) return;
    if (style.sortType != _style.sortType ||
        style.hideTimeoutProxies != _style.hideTimeoutProxies) {
      _invalidateGroups();
    }
    _style = style;
    notifyListeners();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    _invalidateGroups();
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    if (_isLoading == isLoading) return;
    _isLoading = isLoading;
    notifyListeners();
  }

  void selectProxy(String groupName, String proxyName) {
    final next = Map<String, String>.from(_selectedMap);
    if (proxyName.isEmpty) {
      next.remove(groupName);
    } else {
      next[groupName] = proxyName;
    }
    _selectedMap = Map<String, String>.unmodifiable(next);
    _invalidateGroups();
    onSelectProxy?.call(groupName, proxyName);
    notifyListeners();
  }

  void setSelectedMap(Map<String, String> selectedMap) {
    if (mapEquals(_selectedMap, selectedMap)) return;
    _selectedMap = Map<String, String>.unmodifiable(selectedMap);
    _invalidateGroups();
    notifyListeners();
  }

  void updateCurrentUnfoldSet(Set<String> unfoldSet) {
    if (setEquals(_unfoldSet, unfoldSet)) return;
    _unfoldSet = Set<String>.unmodifiable(unfoldSet);
    onUnfoldSetChanged?.call(_unfoldSet);
    notifyListeners();
  }

  void updateCurrentGroupName(String groupName) {
    if (_currentGroupName == groupName) return;
    _currentGroupName = groupName;
    onCurrentGroupChanged?.call(groupName);
    notifyListeners();
  }

  void startGroupDelayTest(String groupName) {
    if (_delayTestingGroups.add(groupName)) {
      notifyListeners();
    }
  }

  void stopGroupDelayTest(String groupName) {
    if (_delayTestingGroups.remove(groupName)) {
      notifyListeners();
    }
  }

  void setDelayMap(DelayMap delayMap, {bool commitBatch = true}) {
    _delayMap = _cloneDelayMap(delayMap);
    if (commitBatch || delayMap.isEmpty) {
      _delaysAtLastTestBatch = _delayMap;
      _invalidateGroups();
    }
    notifyListeners();
  }

  void setDelay({
    required String proxyName,
    required int? delay,
    String? testUrl,
    bool commitBatch = false,
  }) {
    final effectiveTestUrl = realTestUrl(testUrl);
    final nextOuter = <String, Map<String, int?>>{
      for (final entry in _delayMap.entries)
        entry.key: Map<String, int?>.from(entry.value),
    };
    final bucket = nextOuter.putIfAbsent(effectiveTestUrl, () => {});
    if (delay == null) {
      bucket.remove(proxyName);
    } else {
      bucket[proxyName] = delay;
    }
    _delayMap = _cloneDelayMap(nextOuter);
    if (commitBatch) {
      _delaysAtLastTestBatch = _delayMap;
      _invalidateGroups();
    }
    notifyListeners();
  }

  void commitDelayBatch() {
    _delaysAtLastTestBatch = _delayMap;
    _invalidateGroups();
    notifyListeners();
  }

  void setDelayTestPhase({
    required String proxyName,
    required DelayTestPhase? phase,
    String? testUrl,
  }) {
    final effectiveTestUrl = realTestUrl(testUrl);
    final key = delayTestKey(effectiveTestUrl, proxyName);
    if (phase == null) {
      if (_pendingDelayTests.remove(key) != null) {
        notifyListeners();
      }
    } else if (_pendingDelayTests[key] != phase) {
      _pendingDelayTests[key] = phase;
      notifyListeners();
    }
  }

  Future<void> testProxyDelay(Proxy proxy, String? groupTestUrl) async {
    final probe = onTestProxyDelay;
    if (probe == null) return;
    final state = realSelectedProxyStateOf(proxy.name);
    final effectiveTestUrl = state.testUrl.takeFirstValid([
      realTestUrl(groupTestUrl),
    ]);
    final targetProxy = state.proxyName == proxy.name
        ? proxy
        : Proxy(name: state.proxyName, type: proxy.type);
    final key = delayTestKey(effectiveTestUrl, targetProxy.name);
    if (_pendingDelayTests.containsKey(key)) return;
    _pendingDelayTests[key] = DelayTestPhase.running;
    notifyListeners();
    try {
      final result = await probe(targetProxy, effectiveTestUrl);
      setDelay(
        proxyName: targetProxy.name,
        delay: result,
        testUrl: effectiveTestUrl,
      );
    } finally {
      _pendingDelayTests.remove(key);
      notifyListeners();
    }
  }

  Future<void> delayTestPageGroup(String groupName) async {
    if (_delayTestingGroups.contains(groupName)) return;
    final customGroupProbe = onTestGroupDelay;
    if (customGroupProbe != null) {
      _delayTestingGroups.add(groupName);
      notifyListeners();
      try {
        await customGroupProbe(groupName);
      } finally {
        _delayTestingGroups.remove(groupName);
        commitDelayBatch();
      }
      return;
    }
    final probe = onTestProxyDelay;
    if (probe == null) return;
    final group = filteredGroups.getGroup(groupName) ?? _rawGroups.getGroup(groupName);
    if (group == null || group.all.isEmpty) return;
    _delayTestingGroups.add(groupName);
    final groupUrl = realTestUrl(group.testUrl);
    final targets = <(Proxy, String, String)>[];
    for (final proxy in group.all) {
      final state = realSelectedProxyStateOf(proxy.name);
      final url = state.testUrl.takeFirstValid([groupUrl]);
      final key = delayTestKey(url, state.proxyName);
      if (!_pendingDelayTests.containsKey(key)) {
        _pendingDelayTests[key] = DelayTestPhase.queued;
        final leaf = state.proxyName == proxy.name
            ? proxy
            : Proxy(name: state.proxyName, type: proxy.type);
        targets.add((leaf, url, key));
      }
    }
    notifyListeners();
    try {
      await Future.wait(
        targets.map((entry) async {
          final (leaf, url, key) = entry;
          _pendingDelayTests[key] = DelayTestPhase.running;
          notifyListeners();
          try {
            final delay = await probe(leaf, url);
            setDelay(proxyName: leaf.name, delay: delay, testUrl: url);
          } finally {
            _pendingDelayTests.remove(key);
            notifyListeners();
          }
        }),
      );
    } finally {
      _delayTestingGroups.remove(groupName);
      commitDelayBatch();
    }
  }

  Future<void> addToLocalProxies(Proxy proxy) async {
    await onAddToLocalProxies?.call(proxy);
  }
}

class ProxiesScope extends InheritedNotifier<ProxiesController> {
  const ProxiesScope({
    super.key,
    required ProxiesController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProxiesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProxiesScope>();
    assert(scope != null, 'No ProxiesScope found in context.');
    return scope!.notifier!;
  }

  static ProxiesController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ProxiesScope>();
    assert(scope != null, 'No ProxiesScope found in context.');
    return scope!.notifier!;
  }

  static ProxiesController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProxiesScope>()?.notifier;
  }
}
