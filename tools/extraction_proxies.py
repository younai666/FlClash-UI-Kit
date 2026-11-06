"""Reviewed proxies compute helpers, cards, group tabs, list/tab views, and page."""


def register_proxies(register, base):
    register('lib/common/compute.dart', 'proxies/compute.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';''', '''import '../string.dart';
import 'models.dart';'''),
    ])

    register('test/common/compute_test.dart', '@test/common/compute_test.dart', [
        ('''import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';'''),
    ])

    register('lib/views/proxies/common.dart', 'proxies/common.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/typography.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import 'models.dart';'''),
        ('''double get listHeaderHeight {
  final measure = globalState.measure;''', '''double listHeaderHeightOf(Measure measure) {'''),
        ('''double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;''', '''double getItemHeight(Measure measure, ProxyCardType proxyCardType) {'''),
        ('''double getRowExtent(ProxyCardType proxyCardType) =>
    getItemHeight(proxyCardType) + proxyGridSpacing;''', '''double getRowExtent(Measure measure, ProxyCardType proxyCardType) =>
    getItemHeight(measure, proxyCardType) + proxyGridSpacing;'''),
    ])

    register('lib/views/proxies/card.dart', 'proxies/card.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';''', '''import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../localizations.dart';
import '../ui/delay_color.dart';
import 'controller.dart';
import 'models.dart';'''),
        ('''void selectGroupProxy(
  WidgetRef ref, {
  required String groupName,
  required GroupType groupType,
  required String proxyName,
}) {
  final isComputedSelected = groupType.isComputedSelected;
  if (isComputedSelected || groupType == GroupType.Selector) {
    final currentProxyName = ref.read(proxyNameProvider(groupName));
    final nextProxyName = switch (isComputedSelected) {
      true => currentProxyName == proxyName ? '' : proxyName,
      false => proxyName,
    };
    ref
        .read(proxiesActionProvider.notifier)
        .changeProxyDebounce(groupName, nextProxyName);
    return;
  }
  dialogs.showBanner(
    currentAppLocalizations.notSelectedTip,
    level: BannerLevel.warning,
  );
}''', '''void selectGroupProxy(
  BuildContext context,
  ProxiesController controller, {
  required String groupName,
  required GroupType groupType,
  required String proxyName,
}) {
  final isComputedSelected = groupType.isComputedSelected;
  if (isComputedSelected || groupType == GroupType.Selector) {
    final currentProxyName = controller.proxyNameOf(groupName);
    final nextProxyName = switch (isComputedSelected) {
      true => currentProxyName == proxyName ? '' : proxyName,
      false => proxyName,
    };
    controller.selectProxy(groupName, nextProxyName);
    return;
  }
  BannerHost.maybeOf(context)?.show(
    KitLocalizations.of(context).notSelectedTip,
    level: BannerLevel.warning,
  );
}'''),
        ('class ProxyCard extends ConsumerWidget {', 'class ProxyCard extends StatelessWidget {'),
        ('  Measure get measure => globalState.measure;\n\n', ''),
        ('  Widget _buildProxyNameText(BuildContext context) {', '  Widget _buildProxyNameText(BuildContext context, Measure measure) {'),
        ('''  void _handleSelect(WidgetRef ref) {
    selectGroupProxy(
      ref,
      groupName: groupName,
      groupType: groupType,
      proxyName: proxy.name,
    );
  }

  void _handleAddToLocalProxies(WidgetRef ref) {
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    globalState.safeRun(() => proxiesAction.addToLocalProxies(proxy.name));
  }

  List<PopupMenuItem> _menuItems(
    BuildContext context,
    WidgetRef ref, {
    required bool inUse,
    required bool pinned,
    required bool addable,
  }) {
    final appLocalizations = context.appLocalizations;
    return [
      if (groupType == GroupType.Selector)
        PopupMenuItem(
          glyph: AppGlyphs.checkCircle,
          label: appLocalizations.select,
          checked: inUse,
          onPressed: () => _handleSelect(ref),
        )
      else if (groupType.isComputedSelected)
        PopupMenuItem(
          glyph: AppGlyphs.pin,
          label: appLocalizations.preferred,
          checked: pinned,
          onPressed: () => _handleSelect(ref),
        ),
      if (addable)
        PopupMenuItem(
          glyph: AppGlyphs.listAdd,
          label: appLocalizations.addToLocalProxies,
          onPressed: () => _handleAddToLocalProxies(ref),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measure = globalState.measure;
    final isLoose = type == ProxyCardType.loose;
    final delayText = _DelayText(
      proxy: proxy,
      testUrl: testUrl,
      alignment: isLoose ? Alignment.centerLeft : Alignment.centerRight,
    );
    final proxyNameText = _buildProxyNameText(context);''', '''  void _handleSelect(BuildContext context, ProxiesController controller) {
    selectGroupProxy(
      context,
      controller,
      groupName: groupName,
      groupType: groupType,
      proxyName: proxy.name,
    );
  }

  void _handleAddToLocalProxies(
    BuildContext context,
    ProxiesController controller,
  ) {
    unawaited(
      controller.addToLocalProxies(proxy).catchError((Object error) {
        if (context.mounted) {
          BannerHost.maybeOf(
            context,
          )?.show(error.toString(), level: BannerLevel.error);
        }
      }),
    );
  }

  List<PopupMenuItem> _menuItems(
    BuildContext context,
    ProxiesController controller, {
    required bool inUse,
    required bool pinned,
    required bool addable,
  }) {
    final appLocalizations = KitLocalizations.of(context);
    return [
      if (groupType == GroupType.Selector)
        PopupMenuItem(
          glyph: AppGlyphs.checkCircle,
          label: appLocalizations.select,
          checked: inUse,
          onPressed: () => _handleSelect(context, controller),
        )
      else if (groupType.isComputedSelected)
        PopupMenuItem(
          glyph: AppGlyphs.pin,
          label: appLocalizations.preferred,
          checked: pinned,
          onPressed: () => _handleSelect(context, controller),
        ),
      if (addable && controller.onAddToLocalProxies != null)
        PopupMenuItem(
          glyph: AppGlyphs.listAdd,
          label: appLocalizations.addToLocalProxies,
          onPressed: () => _handleAddToLocalProxies(context, controller),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProxiesScope.of(context);
    final measure = MeasureScope.of(context);
    final isLoose = type == ProxyCardType.loose;
    final delayText = _DelayText(
      proxy: proxy,
      testUrl: testUrl,
      alignment: isLoose ? Alignment.centerLeft : Alignment.centerRight,
    );
    final proxyNameText = _buildProxyNameText(context, measure);'''),
        ('''    return Consumer(
      builder: (context, ref, _) {
        final inUse = ref.watch(
          selectedProxyNameProvider(
            groupName,
          ).select((name) => name == proxy.name),
        );
        final pinned =
            groupType.isComputedSelected &&
            ref.watch(
              proxyNameProvider(groupName).select((name) => name == proxy.name),
            );
        final isCustomProfile = ref.watch(
          currentProfileProvider.select(
            (profile) => profile?.type == ProfileType.custom,
          ),
        );
        return ContextMenuRegion(
          menuItems: _menuItems(
            context,
            ref,
            inUse: inUse,
            pinned: pinned,
            addable: _isAddableToLocal(proxy, isCustomProfile: isCustomProfile),
          ),
          child: Card(
            radius: AppCorner.lg,
            enterActionsOnRight: true,
            key: key,
            onPressed: () => _handleSelect(ref),''', '''    final inUse = controller.selectedProxyNameOf(groupName) == proxy.name;
    final pinned =
        groupType.isComputedSelected &&
        controller.proxyNameOf(groupName) == proxy.name;
    final isCustomProfile = controller.isCustomProfile;
    return ContextMenuRegion(
      menuItems: _menuItems(
        context,
        controller,
        inUse: inUse,
        pinned: pinned,
        addable: _isAddableToLocal(proxy, isCustomProfile: isCustomProfile),
      ),
      child: Card(
        radius: AppCorner.lg,
        enterActionsOnRight: true,
        key: key,
        onPressed: () => _handleSelect(context, controller),'''),
        ('''            ),
          ),
        );
      },
    );
  }
}''', '''        ),
      ),
    );
  }
}'''),
        ('''class _ProxyDesc extends ConsumerWidget {
  const _ProxyDesc({required this.proxy, required this.style});

  final Proxy proxy;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGroup = GroupType.values.any((type) => type.name == proxy.type);
    final nodeName = isGroup
        ? ref.watch(
            realSelectedProxyStateProvider(
              proxy.name,
            ).select((state) => state.proxyName),
          )
        : proxy.name;''', '''class _ProxyDesc extends StatelessWidget {
  const _ProxyDesc({required this.proxy, required this.style});

  final Proxy proxy;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final isGroup = GroupType.values.any((type) => type.name == proxy.type);
    final nodeName = isGroup
        ? ProxiesScope.of(context).realSelectedProxyStateOf(proxy.name).proxyName
        : proxy.name;'''),
        ('''class _DelayText extends ConsumerStatefulWidget {
  const _DelayText({
    required this.proxy,
    required this.testUrl,
    required this.alignment,
  });

  final Proxy proxy;
  final String? testUrl;
  final Alignment alignment;

  @override
  ConsumerState<_DelayText> createState() => _DelayTextState();
}

class _DelayTextState extends ConsumerState<_DelayText> {''', '''class _DelayText extends StatefulWidget {
  const _DelayText({
    required this.proxy,
    required this.testUrl,
    required this.alignment,
  });

  final Proxy proxy;
  final String? testUrl;
  final Alignment alignment;

  @override
  State<_DelayText> createState() => _DelayTextState();
}

class _DelayTextState extends State<_DelayText> {'''),
        ('''  void _handleTestCurrentDelay() {
    ref
        .read(proxiesActionProvider.notifier)
        .proxyDelayTest(widget.proxy, widget.testUrl);
  }''', '''  void _handleTestCurrentDelay() {
    unawaited(
      ProxiesScope.read(context).testProxyDelay(widget.proxy, widget.testUrl),
    );
  }'''),
        ('''  @override
  Widget build(BuildContext context) {
    final measure = globalState.measure;
    final delay = ref.watch(
      delayProvider(proxyName: widget.proxy.name, testUrl: widget.testUrl),
    );
    final phase = ref.watch(
      delayTestPhaseProvider(
        proxyName: widget.proxy.name,
        testUrl: widget.testUrl,
      ),
    );''', '''  @override
  Widget build(BuildContext context) {
    final controller = ProxiesScope.of(context);
    final measure = MeasureScope.of(context);
    final delay = controller.delayOf(widget.proxy.name, widget.testUrl);
    final phase = controller.delayTestPhaseOf(widget.proxy.name, widget.testUrl);'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/views/proxies/group_tabs.dart', 'proxies/group_tabs.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';''', '''import '../../icons.dart';
import '../data.dart';
import '../localizations.dart';
import 'models.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ])

    register('lib/views/proxies/list.dart', 'proxies/list.dart', [
        ('''import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';''', '''import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../iterable.dart';
import '../localizations.dart';
import '../string.dart';
import '../ui/null_status_illustration.dart';
import '../widgets/target_icon.dart';
import 'card.dart';
import 'common.dart';
import 'controller.dart';
import 'models.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class ProxiesListView extends ConsumerStatefulWidget {
  const ProxiesListView({super.key});

  @override
  ConsumerState<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends ConsumerState<ProxiesListView> {''', '''class ProxiesListView extends StatefulWidget {
  const ProxiesListView({super.key});

  @override
  State<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends State<ProxiesListView> {'''),
        ('''  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String groupName) {
    _autoScrollToGroup(groupName);
    final tempUnfoldSet = Set<String>.from(ref.read(unfoldSetProvider));
    if (!tempUnfoldSet.remove(groupName)) {
      tempUnfoldSet.add(groupName);
    }
    ref
        .read(proxiesActionProvider.notifier)
        .updateCurrentUnfoldSet(tempUnfoldSet);
  }''', '''  ProxiesController? _proxiesController;
  List<Group>? _watchedGroups;
  ProxyCardType? _watchedCardType;
  ProxiesLayout? _watchedLayout;
  bool? _watchedSearching;
  ViewMode? _watchedViewModeOverride;

  void _captureWatched(ProxiesController controller) {
    _watchedGroups = controller.filteredGroups;
    _watchedCardType = controller.style.cardType;
    _watchedLayout = controller.style.layout;
    _watchedSearching = controller.isSearching;
    _watchedViewModeOverride = controller.viewModeOverride;
  }

  void _onProxiesChanged() {
    final controller = _proxiesController;
    if (controller == null || !mounted) return;
    final nextGroups = controller.filteredGroups;
    final nextCardType = controller.style.cardType;
    final nextLayout = controller.style.layout;
    final nextSearching = controller.isSearching;
    final nextViewModeOverride = controller.viewModeOverride;
    if (!identical(_watchedGroups, nextGroups) &&
            !listEquals(_watchedGroups, nextGroups) ||
        _watchedCardType != nextCardType ||
        _watchedLayout != nextLayout ||
        _watchedSearching != nextSearching ||
        _watchedViewModeOverride != nextViewModeOverride) {
      _captureWatched(controller);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ProxiesScope.read(context);
    if (_proxiesController != nextController) {
      _proxiesController?.removeListener(_onProxiesChanged);
      _proxiesController = nextController;
      _captureWatched(nextController);
      nextController.addListener(_onProxiesChanged);
    }
  }

  @override
  void dispose() {
    _proxiesController?.removeListener(_onProxiesChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String groupName) {
    final controller = ProxiesScope.read(context);
    _autoScrollToGroup(groupName);
    final tempUnfoldSet = Set<String>.from(controller.unfoldSet);
    if (!tempUnfoldSet.remove(groupName)) {
      tempUnfoldSet.add(groupName);
    }
    controller.updateCurrentUnfoldSet(tempUnfoldSet);
  }'''),
        ('''  GroupOffsets _getGroupOffsets() {
    final state = ref.read(proxiesListStateProvider);''', '''  GroupOffsets _getGroupOffsets() {
    final controller = ProxiesScope.read(context);
    final measure = MeasureScope.of(context);
    final headerHeight = listHeaderHeightOf(measure);
    final state = controller.listState;'''),
        ('''    final rowExtent = getRowExtent(state.proxyCardType);
    final columnOffsets = List.filled(_groupColumns, 0.0);
    for (final (index, group) in state.groups.indexed) {
      final column = index % _groupColumns;
      offsets.add(columnOffsets[column]);
      columnOffsets[column] += listHeaderHeight + _gap;''', '''    final rowExtent = getRowExtent(measure, state.proxyCardType);
    final columnOffsets = List.filled(_groupColumns, 0.0);
    for (final (index, group) in state.groups.indexed) {
      final column = index % _groupColumns;
      offsets.add(columnOffsets[column]);
      columnOffsets[column] += headerHeight + _gap;'''),
        ('''  void _autoScrollToGroup(String groupName) {
    final pixels = _controller.position.pixels;
    final offset = _getGroupOffset(groupName);
    _scrollToMakeVisibleWithPadding(
      containerHeight: max(
        _controller.position.viewportDimension - context.contentTopPadding,
        0,
      ),
      pixels: pixels,
      start: offset,
      end: offset + listHeaderHeight,
    );
  }

  void _scrollToGroupSelected(String groupName) {
    final cardType = ref.read(proxiesListStateProvider).proxyCardType;
    final proxies = ref
        .read(proxiesListStateProvider)
        .groups
        .getGroup(groupName)
        ?.all;
    if (proxies == null) {
      return;
    }
    final rowOffset = selectedRowOffset(
      proxies: proxies,
      selectedProxyName: ref.read(selectedProxyNameProvider(groupName)),
      columns: _columns,
      rowExtent: getRowExtent(cardType),
    );
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(_controller, _getGroupOffset(groupName) + rowOffset);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return Consumer(
      builder: (_, ref, _) {
        final groups = ref.watch(
          proxiesListStateProvider.select((state) => state.groups),
        );
        final cardType = ref.watch(
          proxiesListStateProvider.select((state) => state.proxyCardType),
        );
        ref.watch(themeSettingProvider.select((state) => state.textScale));
        final viewMode = ref.watch(viewModeProvider);
        final proxiesLayout = ref.watch(
          proxiesStyleSettingProvider.select((state) => state.layout),
        );
        final isSearching = ref.watch(
          queryProvider(
            QueryTag.proxies,
          ).select((query) => SearchQuery(query).isNotEmpty),
        );''', '''  void _autoScrollToGroup(String groupName) {
    if (!_controller.hasClients) return;
    final headerHeight = listHeaderHeightOf(MeasureScope.of(context));
    final pixels = _controller.position.pixels;
    final offset = _getGroupOffset(groupName);
    _scrollToMakeVisibleWithPadding(
      containerHeight: max(
        _controller.position.viewportDimension - context.contentTopPadding,
        0,
      ),
      pixels: pixels,
      start: offset,
      end: offset + headerHeight,
    );
  }

  void _scrollToGroupSelected(String groupName) {
    final controller = ProxiesScope.read(context);
    final measure = MeasureScope.of(context);
    final state = controller.listState;
    final cardType = state.proxyCardType;
    final proxies = state.groups.getGroup(groupName)?.all;
    if (proxies == null) {
      return;
    }
    final rowOffset = selectedRowOffset(
      proxies: proxies,
      selectedProxyName: controller.selectedProxyNameOf(groupName),
      columns: _columns,
      rowExtent: getRowExtent(measure, cardType),
    );
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(_controller, _getGroupOffset(groupName) + rowOffset);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final proxiesController = ProxiesScope.read(context);
    final state = proxiesController.listState;
    final groups = state.groups;
    final cardType = state.proxyCardType;
    MediaQuery.textScalerOf(context);
    final viewMode = proxiesController.viewModeOf(context);
    final proxiesLayout = proxiesController.style.layout;
    final isSearching = proxiesController.isSearching;'''),
        ('''            },
          ),
        );
      },
    );
  }
}''', '''            },
          ),
        );
  }
}'''),
        ('''class _GroupSliver extends ConsumerStatefulWidget {
  const _GroupSliver({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.gap,
    required this.onChange,
    required this.onScrollToSelected,
  });

  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final double gap;
  final void Function(String groupName) onChange;
  final void Function(String groupName) onScrollToSelected;

  @override
  ConsumerState<_GroupSliver> createState() => _GroupSliverState();
}

class _GroupSliverState extends ConsumerState<_GroupSliver>
    with SingleTickerProviderStateMixin {
  Widget? _rows;
  double _rowExtent = 0;
  late final _controller = AnimationController(
    vsync: this,
    value: ref.read(unfoldSetProvider).contains(widget.group.name) ? 1 : 0,
  );
  late final _unfold = UnfoldEntryTransition.curveOf(_controller);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((_) => setState(() {}));
    ref.listenManual(
      unfoldSetProvider.select((state) => state.contains(widget.group.name)),
      (_, isExpand) => _handleUnfold(isExpand),
    );
  }

  @override
  void dispose() {
    _unfold.dispose();
    _controller.dispose();
    super.dispose();
  }''', '''class _GroupSliver extends StatefulWidget {
  const _GroupSliver({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.gap,
    required this.onChange,
    required this.onScrollToSelected,
  });

  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final double gap;
  final void Function(String groupName) onChange;
  final void Function(String groupName) onScrollToSelected;

  @override
  State<_GroupSliver> createState() => _GroupSliverState();
}

class _GroupSliverState extends State<_GroupSliver>
    with SingleTickerProviderStateMixin {
  Widget? _rows;
  double _rowExtent = 0;
  ProxiesController? _proxiesController;
  bool _isExpand = false;
  late final AnimationController _controller = AnimationController(vsync: this);
  late final _unfold = UnfoldEntryTransition.curveOf(_controller);

  void _onProxiesChanged() {
    final controller = _proxiesController;
    if (controller == null || !mounted) return;
    final nextExpand = controller.unfoldSet.contains(widget.group.name);
    if (nextExpand != _isExpand) {
      _isExpand = nextExpand;
      _handleUnfold(nextExpand);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((_) => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ProxiesScope.read(context);
    if (_proxiesController != nextController) {
      final firstBind = _proxiesController == null;
      _proxiesController?.removeListener(_onProxiesChanged);
      _proxiesController = nextController;
      _isExpand = nextController.unfoldSet.contains(widget.group.name);
      if (firstBind) {
        _controller.value = _isExpand ? 1 : 0;
      } else {
        _handleUnfold(_isExpand);
      }
      nextController.addListener(_onProxiesChanged);
    }
  }

  @override
  void dispose() {
    _proxiesController?.removeListener(_onProxiesChanged);
    _unfold.dispose();
    _controller.dispose();
    super.dispose();
  }'''),
        ('              height: getItemHeight(cardType),', '              height: getItemHeight(MeasureScope.of(context), cardType),'),
        ('''  @override
  Widget build(BuildContext context) {
    final groupName = widget.group.name;
    final isExpand = ref.watch(
      unfoldSetProvider.select((state) => state.contains(groupName)),
    );
    final unfolded = _controller.isCompleted;
    Widget? rows;
    if (!_controller.isDismissed && widget.group.all.isNotEmpty) {
      final extent = getRowExtent(widget.cardType);''', '''  @override
  Widget build(BuildContext context) {
    final measure = MeasureScope.of(context);
    final headerHeight = listHeaderHeightOf(measure);
    final groupName = widget.group.name;
    final isExpand = _isExpand;
    final unfolded = _controller.isCompleted;
    Widget? rows;
    if (!_controller.isDismissed && widget.group.all.isNotEmpty) {
      final extent = getRowExtent(measure, widget.cardType);'''),
        ('''    Widget buildHeader({double floating = 0, double lift = 0}) => SizedBox(
      height: listHeaderHeight,
      child: ListHeader(
        enterAnimated: false,
        floating: floating,
        lift: lift,
        onScrollToSelected: widget.onScrollToSelected,
        key: ValueKey(groupName),
        isExpand: isExpand,
        unfolded: unfolded,
        group: widget.group,
        onChange: widget.onChange,
      ),
    );
    return SliverPadding(
      padding: EdgeInsets.only(bottom: widget.gap),
      sliver: SliverMainAxisGroup(
        slivers: [_buildPinnedHeader(isExpand, buildHeader), ?rows],
      ),
    );
  }

  /// Rounds the header and lifts it as its own rows scroll under it, and lets
  /// the shadow go before the end of the group pushes it out. The page color
  /// behind its upper half hides the rows that went under it, which would
  /// otherwise show around its top corners and above it. Every header is laid
  /// out on every pass, so one beyond the cache area builds nothing.
  Widget _buildPinnedHeader(
    bool isExpand,
    Widget Function({double floating, double lift}) buildHeader,
  ) {
    final columns = widget.columns;
    final rowCount = (widget.group.all.length + columns - 1) ~/ columns;
    final rowsExtent = isExpand ? _rowsExtent(rowCount, _rowExtent) : 0.0;
    final groupExtent =
        listHeaderHeight +
        (_controller.isDismissed
            ? 0.0
            : _rowsExtent(rowCount, getRowExtent(widget.cardType)));''', '''    Widget buildHeader({double floating = 0, double lift = 0}) => SizedBox(
      height: headerHeight,
      child: ListHeader(
        enterAnimated: false,
        floating: floating,
        lift: lift,
        onScrollToSelected: widget.onScrollToSelected,
        key: ValueKey(groupName),
        isExpand: isExpand,
        unfolded: unfolded,
        group: widget.group,
        onChange: widget.onChange,
      ),
    );
    return SliverPadding(
      padding: EdgeInsets.only(bottom: widget.gap),
      sliver: SliverMainAxisGroup(
        slivers: [
          _buildPinnedHeader(measure, headerHeight, isExpand, buildHeader),
          ?rows,
        ],
      ),
    );
  }

  /// Rounds the header and lifts it as its own rows scroll under it, and lets
  /// the shadow go before the end of the group pushes it out. The page color
  /// behind its upper half hides the rows that went under it, which would
  /// otherwise show around its top corners and above it. Every header is laid
  /// out on every pass, so one beyond the cache area builds nothing.
  Widget _buildPinnedHeader(
    Measure measure,
    double headerHeight,
    bool isExpand,
    Widget Function({double floating, double lift}) buildHeader,
  ) {
    final columns = widget.columns;
    final rowCount = (widget.group.all.length + columns - 1) ~/ columns;
    final rowsExtent = isExpand ? _rowsExtent(rowCount, _rowExtent) : 0.0;
    final groupExtent =
        headerHeight +
        (_controller.isDismissed
            ? 0.0
            : _rowsExtent(rowCount, getRowExtent(measure, widget.cardType)));'''),
        ('            child: SizedBox(height: listHeaderHeight),', '            child: SizedBox(height: headerHeight),'),
        ('                  height: cover + listHeaderHeight / 2,', '                  height: cover + headerHeight / 2,'),
        ('''class ListHeader extends ConsumerWidget {''', '''class ListHeader extends StatelessWidget {'''),
        ('''  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupName = group.name;
    final isDelayTesting = ref.watch(
      delayTestingGroupsProvider.select((state) => state.contains(groupName)),
    );''', '''  @override
  Widget build(BuildContext context) {
    final controller = ProxiesScope.of(context);
    final groupName = group.name;
    final isDelayTesting = controller.isGroupDelayTesting(groupName);'''),
        ('''              onDelayTest: () {
                ref
                    .read(proxiesActionProvider.notifier)
                    .delayTestPageGroup(groupName);
              },''', '''              onDelayTest: () {
                unawaited(controller.delayTestPageGroup(groupName));
              },'''),
        ('''class _GroupIcon extends ConsumerWidget {
  const _GroupIcon({required this.src, required this.name});

  final String src;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconStyle = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconStyle),
    );''', '''class _GroupIcon extends StatelessWidget {
  const _GroupIcon({required this.src, required this.name});

  final String src;
  final String name;

  @override
  Widget build(BuildContext context) {
    final iconStyle = ProxiesScope.of(context).style.iconStyle;'''),
        ('''class _SelectedProxyName extends ConsumerWidget {
  const _SelectedProxyName({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref
        .watch(selectedProxyNameProvider(groupName))
        .takeFirstValid([]);''', '''class _SelectedProxyName extends StatelessWidget {
  const _SelectedProxyName({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    final proxyName = ProxiesScope.of(
      context,
    ).selectedProxyNameOf(groupName).takeFirstValid([]);'''),
    ])

    register('lib/views/proxies/tab.dart', 'proxies/tab.dart', [
        ('''import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';
import 'group_tabs.dart';''', '''import 'dart:async';
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
import 'models.dart';'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final Map<String, ScrollController> _scrollControllers = {};
  int _columns = 1;

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxiesTabControllerStateProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (!stringListEquality.equals(prev?.groupNames, next.groupNames)) {
        final groupNames = next.groupNames;
        final currentGroupName = next.currentGroupName;
        final index = groupNames.indexWhere((item) => item == currentGroupName);
        _updateTabController(groupNames.length, index);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _destroyTabController();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }''', '''class ProxiesTabView extends StatefulWidget {
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
  }'''),
        ('''  void scrollToGroupSelected() {
    final group = currentGroup;
    final controller = _scrollControllers[group?.name];
    if (group == null || controller == null) {
      return;
    }
    final cardType = ref.read(proxiesTabStateProvider).proxyCardType;
    final rowOffset = selectedRowOffset(
      proxies: group.all,
      selectedProxyName: ref.read(selectedProxyNameProvider(group.name)),
      columns: _columns,
      rowExtent: getRowExtent(cardType),
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
    await ref
        .read(proxiesActionProvider.notifier)
        .delayTestPageGroup(group.name);
  }

  Group? get currentGroup {
    return _getGroup(_tabController?.index);
  }

  Group? _getGroup(int? index) {
    final groups = ref.read(proxiesTabStateProvider).groups;
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
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(group.name);
    });
  }''', '''  void scrollToGroupSelected() {
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
  }'''),
        ('''  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final groups = ref.watch(
      proxiesTabStateProvider.select((state) => state.groups),
    );
    final cardType = ref.watch(
      proxiesTabStateProvider.select((state) => state.proxyCardType),
    );
    final proxiesLayout = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.layout),
    );
    final isSearching = ref.watch(
      queryProvider(
        QueryTag.proxies,
      ).select((query) => SearchQuery(query).isNotEmpty),
    );''', '''  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final proxiesController = ProxiesScope.read(context);
    MediaQuery.textScalerOf(context);
    final tabState = proxiesController.tabState;
    final groups = tabState.groups;
    final cardType = tabState.proxyCardType;
    final proxiesLayout = proxiesController.style.layout;
    final isSearching = proxiesController.isSearching;'''),
        ('''class ProxyGroupView extends ConsumerWidget {
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

  PageStorageKey _getPageStorageKey(WidgetRef ref) {
    final profile = ref.read(currentProfileProvider);
    final key =
        '${profile?.id}_${ScrollPositionCacheKey.proxiesTabList.name}_${group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxies = group.all;
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: GridView.builder(
        key: _getPageStorageKey(ref),
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
          mainAxisExtent: getItemHeight(cardType),
        ),''', '''class ProxyGroupView extends StatelessWidget {
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
        ),'''),
    ])

    register('lib/views/proxies/proxies.dart', 'proxies/proxies.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tab.dart';''', '''import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../localizations.dart';
import '../scaffold/scaffold.dart';
import 'controller.dart';
import 'list.dart';
import 'models.dart';
import 'tab.dart';

Future<void> showProxiesSheet(
  BuildContext context, {
  required ProxiesController controller,
  String? groupName,
}) async {
  if (groupName != null) {
    controller.updateCurrentGroupName(groupName);
  }
  final pageQuery = controller.query;
  controller.setQuery('');
  await showSheet<void>(
    context: context,
    builder: (_) => ProxiesView(controller: controller, picker: true),
  );
  controller.setQuery(pageQuery);
}'''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('''class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key, this.picker = false});

  /// Leaves the bar only its search and delay test, for picking a proxy from a
  /// sheet.
  final bool picker;

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();

  // The same instance on every build, so the bar changing with the current
  // group or its delay test leaves the page alone.
  late final _tabView = ProxiesTabView(key: _proxiesTabKey);
  bool _isTab = false;

  void _updateStyle(
    ProxiesStyleProps Function(ProxiesStyleProps state) update,
  ) {
    ref.read(proxiesStyleSettingProvider.notifier).update(update);
  }''', '''class ProxiesView extends StatefulWidget {
  const ProxiesView({
    super.key,
    this.controller,
    this.groups,
    this.picker = false,
  });

  final ProxiesController? controller;
  final List<Group>? groups;

  /// Leaves the bar only its search and delay test, for picking a proxy from a
  /// sheet.
  final bool picker;

  @override
  State<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends State<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  ProxiesController? _ownedController;

  // The same instance on every build, so the bar changing with the current
  // group or its delay test leaves the page alone.
  late final _tabView = ProxiesTabView(key: _proxiesTabKey);

  ProxiesController _resolveController(BuildContext context) {
    if (widget.controller != null) return widget.controller!;
    final inherited = ProxiesScope.maybeOf(context);
    if (inherited != null) return inherited;
    return _ownedController ??= ProxiesController(
      groups: widget.groups ?? const [],
    );
  }

  @override
  void didUpdateWidget(ProxiesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && _ownedController != null) {
      _ownedController!.dispose();
      _ownedController = null;
    } else if (_ownedController != null &&
        widget.groups != null &&
        widget.groups != oldWidget.groups) {
      _ownedController!.setGroups(widget.groups!);
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  void _updateStyle(
    ProxiesController controller,
    ProxiesStyleProps Function(ProxiesStyleProps state) update,
  ) {
    controller.updateStyle(update);
  }'''),
        ('''  List<PopupMenuItem> _buildMenuItems(
    BuildContext context,
    ProxiesStyleProps style,
  ) {''', '''  List<PopupMenuItem> _buildMenuItems(
    BuildContext context,
    ProxiesController controller,
    ProxiesStyleProps style,
  ) {'''),
        ('textOf: (type) => type.label,', 'textOf: (type) => type.labelOf(context),'),
        ('            _updateStyle((state) => state.copyWith(type: type)),', '            _updateStyle(controller, (state) => state.copyWith(type: type)),'),
        ('            _updateStyle((state) => state.copyWith(sortType: type)),', '            _updateStyle(controller, (state) => state.copyWith(sortType: type)),'),
        ('            _updateStyle((state) => state.copyWith(layout: layout)),', '            _updateStyle(controller, (state) => state.copyWith(layout: layout)),'),
        ('            _updateStyle((state) => state.copyWith(cardType: type)),', '            _updateStyle(controller, (state) => state.copyWith(cardType: type)),'),
        ('              _updateStyle((state) => state.copyWith(iconStyle: iconStyle)),', '              _updateStyle(controller, (state) => state.copyWith(iconStyle: iconStyle)),'),
        ('''        onPressed: () => _updateStyle(
          (state) =>
              state.copyWith(hideTimeoutProxies: !state.hideTimeoutProxies),
        ),''', '''        onPressed: () => _updateStyle(
          controller,
          (state) =>
              state.copyWith(hideTimeoutProxies: !state.hideTimeoutProxies),
        ),'''),
        ('''  IconButtonData? _buildPrimaryAction() {
    if (!_isTab) {
      return null;
    }
    final isDelayTesting = ref.watch(currentGroupDelayTestingProvider);
    return IconButtonData(
      glyph: AppGlyphs.bolt,
      onPressed: () {
        _proxiesTabKey.currentState?.delayTestCurrentGroup();
      },
      tooltip: KitLocalizations.of(context).delayTest,
      isLoading: isDelayTesting,
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = ref.watch(proxiesStyleSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    final picker = widget.picker;
    final primaryAction = _buildPrimaryAction();
    return Scaffold(
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      primaryAction: primaryAction,
      searchActions: [?primaryAction],
      iconActions: [
        if (_isTab && !picker)
          IconButtonData(
            glyph: AppGlyphs.locate,
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            tooltip: KitLocalizations.of(context).scrollToSelected,
          ),
      ],
      menuItems: picker ? const [] : _buildMenuItems(context, style),
      title: KitLocalizations.of(context).proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (style.type) {
        ProxiesType.tab => _tabView,
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }''', '''  IconButtonData? _buildPrimaryAction(
    BuildContext context,
    ProxiesController controller,
    bool isTab,
  ) {
    if (!isTab) {
      return null;
    }
    return IconButtonData(
      glyph: AppGlyphs.bolt,
      onPressed: () {
        _proxiesTabKey.currentState?.delayTestCurrentGroup();
      },
      tooltip: KitLocalizations.of(context).delayTest,
      isLoading: controller.currentGroupDelayTesting,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _resolveController(context);
    return ProxiesScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final style = controller.style;
          final isTab = style.type == ProxiesType.tab;
          final picker = widget.picker;
          final primaryAction = _buildPrimaryAction(context, controller, isTab);
          return Scaffold(
            isLoading: controller.isLoading,
            resizeToAvoidBottomInset: false,
            primaryAction: primaryAction,
            searchActions: [?primaryAction],
            iconActions: [
              if (isTab && !picker)
                IconButtonData(
                  glyph: AppGlyphs.locate,
                  onPressed: () {
                    _proxiesTabKey.currentState?.scrollToGroupSelected();
                  },
                  tooltip: KitLocalizations.of(context).scrollToSelected,
                ),
            ],
            menuItems: picker
                ? const []
                : _buildMenuItems(context, controller, style),
            title: KitLocalizations.of(context).proxies,
            searchState: AppBarSearchState(
              query: controller.query.isEmpty ? null : controller.query,
              onSearch: controller.setQuery,
            ),
            body: switch (style.type) {
              ProxiesType.tab => _tabView,
              ProxiesType.list => const ProxiesListView(),
            },
          );
        },
      ),
    );
  }'''),
    ])

    register('test/widgets/proxy_card_focus_test.dart', '@test/widgets/proxy_card_focus_test.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../helpers/host_scaffold.dart';

const _testUrl = 'https://example.com/generate_204';

class _RecordingProxiesAction extends ProxiesAction {
  static final List<String> tested = [];

  @override
  Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
    tested.add(proxy.name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    _RecordingProxiesAction.tested.clear();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        proxiesActionProvider.overrideWith(_RecordingProxiesAction.new),
        delayDataSourceProvider.overrideWithBuild(
          (_, _) => {
            _testUrl: {'proxy 0': 123, 'proxy 1': 456},
          },
        ),
      ],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(900, 600);
  });

  tearDown(() => container.dispose());''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

const _testUrl = 'https://example.com/generate_204';

class _RecordingProxiesAction {
  static final List<String> tested = [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProxiesController controller;

  setUp(() {
    _RecordingProxiesAction.tested.clear();
    controller = ProxiesController(
      delayMap: {
        _testUrl: {'proxy 0': 123, 'proxy 1': 456},
      },
      onTestProxyDelay: (proxy, _) async {
        _RecordingProxiesAction.tested.add(proxy.name);
        return 123;
      },
    );
  });

  tearDown(() => controller.dispose());'''),
        ('''      UncontrolledProviderScope(
        container: container,
        child: TestApp(''' , '''      ProxiesScope(
        controller: controller,
        child: TestApp('''),
    ])

    register('test/widgets/list_header_focus_test.dart', '@test/widgets/list_header_focus_test.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import 'package:prism_ui/prism_ui.dart' hide ListHeader;

void main() {
  Future<ProviderContainer> pumpListLayout(
    WidgetTester tester, {
    Size size = const Size(1400, 1000),
    int proxyCount = 12,
    bool expanded = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      currentGroupName: 'Selector',
      selectedMap: {'Selector': 'Proxy 1'},
      unfoldSet: expanded ? {'Selector'} : {},
    );
    final proxies = List.generate(
      proxyCount,
      (index) => Proxy(name: 'Proxy $index', type: 'Direct'),
    );
    final group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Proxy 1',
      all: proxies,
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [group]),
        ),
        groupsProvider.overrideWithValue([group]),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);
    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.list));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: HostApp(
          builder: (context, child) {
            return wrapAppScopes(context, child!);
          },
          home: const ProxiesView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return container;
  }''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart' hide ListHeader;
import 'package:flclash_ui_kit/src/proxies/list.dart' show ListHeader;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<ProxiesController> pumpListLayout(
    WidgetTester tester, {
    Size size = const Size(1400, 1000),
    int proxyCount = 12,
    bool expanded = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final proxies = List.generate(
      proxyCount,
      (index) => Proxy(name: 'Proxy $index', type: 'Direct'),
    );
    final group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Proxy 1',
      all: proxies,
    );
    final controller = ProxiesController(
      groups: [group],
      currentGroupName: 'Selector',
      selectedMap: {'Selector': 'Proxy 1'},
      unfoldSet: expanded ? {'Selector'} : {},
      style: const ProxiesStyleProps(type: ProxiesType.list),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      HostApp(home: ProxiesView(controller: controller)),
    );
    await tester.pump();
    await tester.pump();
    return controller;
  }'''),
    ])

    register('test/widgets/proxies_list_test.dart', '@test/widgets/proxies_list_test.dart', [
        ('''import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/widgets/widgets.dart' hide ListHeader;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../helpers/host_scaffold.dart';
import 'package:prism_ui/prism_ui.dart' hide ListHeader;

class _RecordingProxiesAction extends ProxiesAction {
  static final List<String> tested = [];

  @override
  Future<void> delayTestPageGroup(
    String groupName, {
    bool matchSearch = true,
  }) async {
    tested.add(groupName);
  }
}''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart' hide ListHeader;
import 'package:flclash_ui_kit/src/proxies/list.dart' show ListHeader;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

class _RecordingProxiesAction {
  static final List<String> tested = [];
}'''),
        ('''void main() {
  late ProviderContainer container;

  Future<void> pumpList(
    WidgetTester tester, {
    Map<String, String> selectedMap = const {},
    ViewMode viewMode = ViewMode.mobile,
    List<Group>? groups,
    Set<String> unfoldSet = const {'G0', 'G1', 'G2'},
    ValueListenable<Brightness>? brightness,
  }) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    groups ??= [_group('G0', 40), _group('G1', 30), _group('G2', 60)];
    final profile = Profile.normal().copyWith(
      selectedMap: selectedMap,
      unfoldSet: unfoldSet,
    );
    _RecordingProxiesAction.tested.clear();
    container = ProviderContainer(
      overrides: [
        viewModeProvider.overrideWithValue(viewMode),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: groups),
        ),
        proxiesActionProvider.overrideWith(_RecordingProxiesAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(groupsProvider.notifier).value = groups;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,''', '''void main() {
  late ProxiesController controller;

  Future<void> pumpList(
    WidgetTester tester, {
    Map<String, String> selectedMap = const {},
    ViewMode viewMode = ViewMode.mobile,
    List<Group>? groups,
    Set<String> unfoldSet = const {'G0', 'G1', 'G2'},
    ValueListenable<Brightness>? brightness,
  }) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    groups ??= [_group('G0', 40), _group('G1', 30), _group('G2', 60)];
    _RecordingProxiesAction.tested.clear();
    controller = ProxiesController(
      groups: groups,
      selectedMap: selectedMap,
      unfoldSet: unfoldSet,
      viewModeOverride: viewMode,
      onTestGroupDelay: (groupName) async {
        _RecordingProxiesAction.tested.add(groupName);
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProxiesScope(
        controller: controller,'''),
        ('container.read(proxiesActionProvider.notifier).updateCurrentUnfoldSet(', 'controller.updateCurrentUnfoldSet('),
        ("container.read(delayTestingGroupsProvider.notifier).start('G0');", "controller.startGroupDelayTest('G0');"),
        ("container.read(delayTestingGroupsProvider.notifier).stop('G0');", "controller.stopGroupDelayTest('G0');"),
    ])

    register('test/widgets/proxies_tab_test.dart', '@test/widgets/proxies_tab_test.dart', [
        ('''import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/views/proxies/group_tabs.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../helpers/host_scaffold.dart';

final _tabStateProvider = NotifierProvider<_TabStateNotifier, ProxiesTabState>(
  _TabStateNotifier.new,
);

class _TabStateNotifier extends Notifier<ProxiesTabState> {
  @override
  ProxiesTabState build() => _tabState([_group('B'), _group('C')]);

  void set(ProxiesTabState value) => state = value;
}

void main() {
  late ProviderContainer globalContainer;
  late ProviderSubscription<Profile?> currentProfileSubscription;

  setUp(() {
    final profile = Profile.normal().copyWith(currentGroupName: 'B');
    globalContainer = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [_group('A'), _group('B'), _group('C')]),
        ),
        proxiesTabStateProvider.overrideWith(
          (ref) => ref.watch(_tabStateProvider),
        ),
      ],
    );
    globalState.container = globalContainer;
    currentProfileSubscription = globalContainer.listen(
      currentProfileProvider,
      (_, _) {},
    );
  });

  tearDown(() {
    currentProfileSubscription.close();
    globalContainer.dispose();
  });

  Future<GlobalKey<ProxiesTabViewState>> pumpTabView(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProxiesTabViewState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalContainer,
        child: TestApp(
          child: ProxiesTabView(key: key),
          homeBuilder: (child) => HostScaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    return key;
  }''', '''import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

void main() {
  late ProxiesController controller;

  void applyTabState(ProxiesTabState state) {
    controller.setGroups(state.groups);
    if (state.currentGroupName != null) {
      controller.updateCurrentGroupName(state.currentGroupName!);
    }
    controller.updateStyle((s) => s.copyWith(cardType: state.proxyCardType));
  }

  setUp(() {
    controller = ProxiesController(
      groups: [_group('B'), _group('C')],
      currentGroupName: 'B',
      onAddToLocalProxies: (_) {},
    );
  });

  tearDown(() {
    controller.dispose();
  });

  Future<GlobalKey<ProxiesTabViewState>> pumpTabView(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProxiesTabViewState>();
    await tester.pumpWidget(
      ProxiesScope(
        controller: controller,
        child: TestApp(
          child: ProxiesTabView(key: key),
          homeBuilder: (child) => HostScaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    return key;
  }'''),
        ("expect(globalContainer.read(currentProfileProvider)?.currentGroupName, 'C');",
         "expect(controller.currentGroupName, 'C');"),
        ('''    globalContainer
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.tab));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalContainer,
        child: const TestApp(child: ProxiesView()),
      ),
    );
    await tester.pump();
    final tabs = tester.widget(find.byType(GroupTabs));

    final state = globalContainer.read(_tabStateProvider);
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(state.copyWith(currentGroupName: 'C'));
    globalContainer.read(delayTestingGroupsProvider.notifier).start('C');
    await tester.pump();

    expect(globalContainer.read(currentGroupDelayTestingProvider), isTrue);''', '''    controller.updateStyle((state) => state.copyWith(type: ProxiesType.tab));
    await tester.pumpWidget(
      TestApp(child: ProxiesView(controller: controller)),
    );
    await tester.pump();
    final tabs = tester.widget(find.byType(GroupTabs));

    controller.updateCurrentGroupName('C');
    controller.startGroupDelayTest('C');
    await tester.pump();

    expect(controller.currentGroupDelayTesting, isTrue);'''),
        ('globalContainer.read(_tabStateProvider.notifier).set(', 'applyTabState('),
        ('''    globalContainer
        .read(_tabStateProvider.notifier)
        .set(''', '    applyTabState('),
        ('''    globalContainer.read(groupsProvider.notifier).value = [group];
    final profile = globalContainer.read(currentProfileProvider)!;
    globalContainer
        .read(profilesProvider.notifier)
        .put(profile.copyWith(selectedMap: {'B': 'B-41'}));''', "    controller.setSelectedMap({'B': 'B-41'});"),
        ('''    globalContainer.read(groupsProvider.notifier).value = [group];
    final profile = globalContainer.read(currentProfileProvider)!;
    globalContainer
        .read(profilesProvider.notifier)
        .put(profile.copyWith(selectedMap: {'B': 'B-0'}));''', "    controller.setSelectedMap({'B': 'B-0'});"),
        ('''    globalContainer.read(groupsProvider.notifier).value = [group];
    final profile = globalContainer.read(currentProfileProvider)!;
    globalContainer
        .read(profilesProvider.notifier)
        .put(profile.copyWith(type: ProfileType.custom));''', '    controller.setCustomProfile(true);'),
    ])
