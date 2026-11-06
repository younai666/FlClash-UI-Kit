// Derived from chen08209/FlClash, lib/views/proxies/tab.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../data.dart';
import '../iterable.dart';
import '../localizations.dart';
import '../ui/null_status_illustration.dart';
import 'card.dart';
import 'common.dart';
import 'controller.dart';
import 'group_tabs.dart';
import 'models.dart';

class ProxiesTabView extends StatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  State<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends State<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  ProxiesController? _proxiesController;
  ProxiesTabControllerState? _prevTabState;
  List<Group>? _watchedGroups;
  ProxyCardType? _watchedCardType;
  ProxiesLayout? _watchedLayout;
  bool? _watchedSearching;
  final Map<String, ScrollController> _scrollControllers = {};
  int _columns = 1;

  void _captureWatched(ProxiesController controller) {
    _watchedGroups = controller.filteredGroups;
    _watchedCardType = controller.style.cardType;
    _watchedLayout = controller.style.layout;
    _watchedSearching = controller.isSearching;
  }

  void _syncTabController() {
    final controller = _proxiesController;
    if (controller == null) return;
    var shouldRebuild = false;
    final next = controller.tabControllerState;
    final prev = _prevTabState;
    if (prev != next) {
      _prevTabState = next;
      if (!stringListEquality.equals(prev?.groupNames, next.groupNames)) {
        final groupNames = next.groupNames;
        final currentGroupName = next.currentGroupName;
        final index = groupNames.indexWhere((item) => item == currentGroupName);
        _updateTabController(groupNames.length, index);
        shouldRebuild = true;
      }
    }
    final nextGroups = controller.filteredGroups;
    final nextCardType = controller.style.cardType;
    final nextLayout = controller.style.layout;
    final nextSearching = controller.isSearching;
    if (!identical(_watchedGroups, nextGroups) &&
            !listEquals(_watchedGroups, nextGroups) ||
        _watchedCardType != nextCardType ||
        _watchedLayout != nextLayout ||
        _watchedSearching != nextSearching) {
      _captureWatched(controller);
      shouldRebuild = true;
    }
    if (shouldRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ProxiesScope.read(context);
    if (_proxiesController != nextController) {
      _proxiesController?.removeListener(_syncTabController);
      _proxiesController = nextController;
      _prevTabState = null;
      _captureWatched(nextController);
      _syncTabController();
      nextController.addListener(_syncTabController);
    }
  }

  @override
  void dispose() {
    _proxiesController?.removeListener(_syncTabController);
    _destroyTabController();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ScrollController _scrollControllerOf(String groupName) {
    return _scrollControllers.putIfAbsent(
      groupName,
      () => sheetScrollController(context),
    );
  }

  // The page of a dropped group still holds its controller until this frame
  // unmounts it.
  void _pruneScrollControllers(List<Group> groups) {
    final names = {for (final group in groups) group.name};
    final dropped = [
      for (final entry in _scrollControllers.entries)
        if (!names.contains(entry.key)) entry,
    ];
    for (final entry in dropped) {
      _scrollControllers.remove(entry.key);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => entry.value.dispose(),
      );
    }
  }

  void scrollToGroupSelected() {
    final proxiesController = _proxiesController;
    final group = currentGroup;
    final controller = _scrollControllers[group?.name];
    if (proxiesController == null || group == null || controller == null) {
      return;
    }
    final measure = MeasureScope.of(context);
    final cardType = proxiesController.tabState.proxyCardType;
    final rowOffset = selectedRowOffset(
      proxies: group.all,
      selectedProxyName: proxiesController.selectedProxyNameOf(group.name),
      columns: _columns,
      rowExtent: getRowExtent(measure, cardType),
    );
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(controller, rowOffset);
  }

  Future<void> delayTestCurrentGroup() async {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    await _proxiesController?.delayTestPageGroup(group.name);
  }

  Group? get currentGroup {
    return _getGroup(_tabController?.index);
  }

  Group? _getGroup(int? index) {
    final groups = _proxiesController?.tabState.groups ?? const [];
    if (index == null || index < 0 || index >= groups.length) {
      return null;
    }
    return groups[index];
  }

  void _tabControllerListener([int? index]) {
    final group = _getGroup(index ?? _tabController?.index);
    if (group == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _proxiesController?.updateCurrentGroupName(group.name);
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  // An empty group list keeps the previous controller: the outgoing tab bar
  // still drives it while the empty state animates in.
  void _updateTabController(int length, int index) {
    if (length == 0) {
      return;
    }
    _destroyTabController();
    final realIndex = index == -1 ? 0 : index;
    final controller = TabController(
      length: length,
      initialIndex: realIndex,
      vsync: this,
    );
    _tabController = controller;
    _tabControllerListener(realIndex);
    controller.addListener(_tabControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final proxiesController = ProxiesScope.read(context);
    MediaQuery.textScalerOf(context);
    final tabState = proxiesController.tabState;
    final groups = tabState.groups;
    final cardType = tabState.proxyCardType;
    final proxiesLayout = proxiesController.style.layout;
    final isSearching = proxiesController.isSearching;
    _pruneScrollControllers(groups);
    final controller = _tabController;
    return NullStatusSwitcher(
      isEmpty: groups.isEmpty || controller == null,
      isSearching: isSearching,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.proxies,
        label: appLocalizations.nullTip(appLocalizations.proxies),
      ),
      child: controller == null
          ? const SizedBox.shrink()
          : AppBarClearance(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.contentTopPadding - context.appBarInset,
                      bottom: 16,
                    ),
                    child: GroupTabs(controller: controller, groups: groups),
                  ),
                  Expanded(
                    child: WidthBuilder(
                      builder: (_, width) {
                        final columns = getProxiesColumns(
                          max(width - 32, 0),
                          proxiesLayout,
                        );
                        _columns = columns;
                        return TabBarView(
                          controller: controller,
                          children: [
                            for (final group in groups)
                              ProxyGroupView(
                                key: ValueKey(group.name),
                                controller: _scrollControllerOf(group.name),
                                group: group,
                                columns: columns,
                                cardType: cardType,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProxyGroupView extends StatelessWidget {
  final Group group;
  final ScrollController controller;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.controller,
    required this.columns,
    required this.cardType,
  });

  PageStorageKey _getPageStorageKey(BuildContext context) {
    final profileId = ProxiesScope.read(context).profileId;
    final key = '${profileId}_proxiesTabList_${group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final measure = MeasureScope.of(context);
    final proxies = group.all;
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: GridView.builder(
        key: _getPageStorageKey(context),
        controller: controller,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + context.bottomInset,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: proxyGridSpacing,
          crossAxisSpacing: 8,
          mainAxisExtent: getItemHeight(measure, cardType),
        ),
        itemCount: proxies.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (_, index) {
          final proxy = proxies[index];
          return ProxyCard(
            testUrl: group.testUrl,
            groupType: group.type,
            type: cardType,
            proxy: proxy,
            groupName: group.name,
          );
        },
      ),
    );
  }
}
