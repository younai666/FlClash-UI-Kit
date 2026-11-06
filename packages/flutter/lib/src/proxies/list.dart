// Derived from chen08209/FlClash, lib/views/proxies/list.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';
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
import 'models.dart';

const _headerInset = 10.0;
const _headerButtonInset = 4.0;
const _groupInset = 16.0;
const _liftDistance = 16.0;
const _groupMinWidth = 360.0;
const _groupMaxColumns = 3;
const _lastRowGrowth = _headerInset - proxyGridSpacing;

class ProxiesListView extends StatefulWidget {
  const ProxiesListView({super.key});

  @override
  State<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends State<ProxiesListView> {
  late final ScrollController _controller;
  int _columns = 1;
  int _groupColumns = 1;
  double _gap = 0;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  ProxiesController? _proxiesController;
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
  }

  GroupOffsets _getGroupOffsets() {
    final controller = ProxiesScope.read(context);
    final measure = MeasureScope.of(context);
    final headerHeight = listHeaderHeightOf(measure);
    final state = controller.listState;
    final offsets = <double>[];
    final rowExtent = getRowExtent(measure, state.proxyCardType);
    final columnOffsets = List.filled(_groupColumns, 0.0);
    for (final (index, group) in state.groups.indexed) {
      final column = index % _groupColumns;
      offsets.add(columnOffsets[column]);
      columnOffsets[column] += headerHeight + _gap;
      if (state.currentUnfoldSet.contains(group.name)) {
        final rowCount = (group.all.length + _columns - 1) ~/ _columns;
        columnOffsets[column] += _rowsExtent(rowCount, rowExtent);
      }
    }
    return GroupOffsets(state.groups, offsets);
  }

  double _getGroupOffset(String groupName) {
    if (!_controller.hasClients || _controller.position.maxScrollExtent == 0) {
      return 0;
    }
    return _getGroupOffsets().offsetOf(groupName);
  }

  void _scrollToMakeVisibleWithPadding({
    required double containerHeight,
    required double pixels,
    required double start,
    required double end,
    double padding = 24,
  }) {
    final visibleStart = pixels;
    final visibleEnd = pixels + containerHeight;

    final isElementVisible = start >= visibleStart && end <= visibleEnd;
    if (isElementVisible) {
      return;
    }

    double targetScrollOffset;

    if (end <= visibleStart) {
      targetScrollOffset = start;
    } else if (start >= visibleEnd) {
      targetScrollOffset = end - containerHeight + padding;
    } else {
      final visibleTopPart = end - visibleStart;
      final visibleBottomPart = visibleEnd - start;
      if (visibleTopPart.abs() >= visibleBottomPart.abs()) {
        targetScrollOffset = end - containerHeight + padding;
      } else {
        targetScrollOffset = start;
      }
    }

    targetScrollOffset = targetScrollOffset.clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );

    _controller.jumpTo(targetScrollOffset);
  }

  void _autoScrollToGroup(String groupName) {
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
    final isSearching = proxiesController.isSearching;
        return NullStatusSwitcher(
          isEmpty: groups.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            illustration: NullStatusIllustration.proxies,
            label: appLocalizations.nullTip(appLocalizations.proxies),
          ),
          child: WidthBuilder(
            builder: (_, maxWidth) {
              final gap = cardSpacingOf(context, viewMode);
              final width = max(maxWidth - _groupInset * 2, 0.0);
              final groupColumns = viewMode == ViewMode.mobile
                  ? 1
                  : ((width + gap) / (_groupMinWidth + gap)).floor().clamp(
                      1,
                      _groupMaxColumns,
                    );
              final groupWidth =
                  (width - gap * (groupColumns - 1)) / groupColumns;
              final columns = getProxiesColumns(
                max(groupWidth - _headerInset * 2, 0),
                proxiesLayout,
              );
              _columns = columns;
              _groupColumns = groupColumns;
              _gap = gap;
              Widget buildGroup(Group group) => _GroupSliver(
                key: _GroupSliverKey(group.name),
                group: group,
                columns: columns,
                cardType: cardType,
                gap: gap,
                onChange: _handleChange,
                onScrollToSelected: _scrollToGroupSelected,
              );
              return Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                child: CustomScrollView(
                  key: proxiesListStoreKey,
                  controller: _controller,
                  slivers: [
                    PinnedHeaderSliver(
                      child: SizedBox(height: context.contentTopPadding),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _groupInset,
                      ),
                      sliver: groupColumns == 1
                          ? SliverMainAxisGroup(
                              slivers: groups.map(buildGroup).toList(),
                            )
                          : SliverCrossAxisGroup(
                              slivers: [
                                for (
                                  var column = 0;
                                  column < groupColumns;
                                  column++
                                ) ...[
                                  if (column > 0)
                                    SliverConstrainedCrossAxis(
                                      maxExtent: gap,
                                      sliver: const SliverToBoxAdapter(),
                                    ),
                                  SliverCrossAxisExpanded(
                                    flex: 1,
                                    sliver: SliverMainAxisGroup(
                                      slivers: [
                                        for (
                                          var index = column;
                                          index < groups.length;
                                          index += groupColumns
                                        )
                                          buildGroup(groups[index]),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 16 + context.bottomInset),
                    ),
                  ],
                ),
              );
            },
          ),
        );
  }
}

double _rowsExtent(int rowCount, double rowExtent) =>
    rowCount == 0 ? 0 : rowCount * rowExtent + _lastRowGrowth;

class _GroupSliverKey extends ValueKey<String> {
  const _GroupSliverKey(super.value);
}

/// Watches only its own group's fold state, so folding one group leaves the
/// cards of every other group untouched, and keeps its rows sliver while the
/// inputs that shape it are equal.
class _GroupSliver extends StatefulWidget {
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
  }

  void _handleUnfold(bool isExpand) {
    _controller.duration = context.motionDuration(
      UnfoldEntryTransition.duration,
    );
    isExpand ? _controller.forward() : _controller.reverse();
  }

  @override
  void didUpdateWidget(_GroupSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group != oldWidget.group ||
        widget.columns != oldWidget.columns ||
        widget.cardType != oldWidget.cardType) {
      _rows = null;
    }
  }

  Widget _buildRow(BuildContext context, List<Proxy> proxies) {
    final group = widget.group;
    final cardType = widget.cardType;
    final groupName = group.name;
    final children = proxies
        .map<Widget>(
          (proxy) => Flexible(
            child: SizedBox(
              height: getItemHeight(MeasureScope.of(context), cardType),
              child: ProxyCard(
                testUrl: group.testUrl,
                type: cardType,
                groupType: group.type,
                key: ValueKey('$groupName.${proxy.name}'),
                proxy: proxy,
                groupName: groupName,
              ),
            ),
          ),
        )
        .fill(widget.columns, filler: (_) => const Flexible(child: SizedBox()))
        .separated(const SizedBox(width: 8));
    return SurfaceScope(
      level: context.raisedSurfaceLevel,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _headerInset,
          right: _headerInset,
          bottom: proxyGridSpacing,
        ),
        child: Row(children: children.toList()),
      ),
    );
  }

  Widget _buildRows(double extent) {
    final rows = widget.group.all.chunks(widget.columns).toList();
    return SliverFixedExtentList(
      itemExtent: extent,
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildRow(context, rows[index]),
        childCount: rows.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }

  /// The card reaches up behind the header's rounded bottom corners, so the
  /// two read as one while the rows unfold or fold.
  Widget _buildUnfoldingRows(double extent, ShapeDecoration decoration) {
    final rows = widget.group.all.chunks(widget.columns).toList();
    final visible = min(
      rows.length.toDouble(),
      MediaQuery.sizeOf(context).height / extent,
    );
    final count = min(rows.length, visible.floor() + 1);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -AppCorner.xl.ap(context),
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(decoration: decoration),
        ),
        SizeTransition(
          sizeFactor: _unfold,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (var index = 0; index < count; index++)
                UnfoldEntryTransition(
                  animation: _unfold,
                  index: index,
                  visibleCount: visible,
                  child: SizedBox(
                    height: extent,
                    child: _buildRow(context, rows[index]),
                  ),
                ),
              if (count == rows.length) const SizedBox(height: _lastRowGrowth),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final measure = MeasureScope.of(context);
    final headerHeight = listHeaderHeightOf(measure);
    final groupName = widget.group.name;
    final isExpand = _isExpand;
    final unfolded = _controller.isCompleted;
    Widget? rows;
    if (!_controller.isDismissed && widget.group.all.isNotEmpty) {
      final extent = getRowExtent(measure, widget.cardType);
      final decoration = ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
        shape: AppShape.vertical(
          top: AppCorner.none,
          bottom: AppCorner.xl.ap(context),
        ),
      );
      if (!unfolded) {
        _rows = null;
        rows = SliverToBoxAdapter(
          child: _buildUnfoldingRows(extent, decoration),
        );
      } else {
        if (_rows == null || _rowExtent != extent) {
          _rows = _buildRows(extent);
          _rowExtent = extent;
        }
        rows = DecoratedSliver(
          decoration: decoration,
          sliver: SliverMainAxisGroup(
            slivers: [
              _rows!,
              const SliverToBoxAdapter(child: SizedBox(height: _lastRowGrowth)),
            ],
          ),
        );
      }
    } else {
      _rows = null;
    }
    Widget buildHeader({double floating = 0, double lift = 0}) => SizedBox(
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
            : _rowsExtent(rowCount, getRowExtent(measure, widget.cardType)));
    (double, double, double, Color)? headerState;
    Widget? header;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final beyondCache =
            constraints.remainingCacheExtent <= 0 ||
            constraints.scrollOffset + constraints.cacheOrigin >= groupExtent;
        final under = isExpand
            ? constraints.scrollOffset + constraints.overlap
            : 0.0;
        final state = beyondCache
            ? null
            : (
                (under / _liftDistance).clamp(0.0, 1.0),
                (min(under, rowsExtent - under) / _liftDistance).clamp(
                  0.0,
                  1.0,
                ),
                isExpand ? constraints.overlap : 0.0,
                context.surfaceLevel.colorOf(context.colorScheme),
              );
        if (header != null && state == headerState) {
          return header!;
        }
        headerState = state;
        if (state == null) {
          return header = PinnedHeaderSliver(
            child: SizedBox(height: headerHeight),
          );
        }
        final (floating, lift, cover, pageColor) = state;
        return header = PinnedHeaderSliver(
          child: RepaintBoundary(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -cover,
                  left: 0,
                  right: 0,
                  height: cover + headerHeight / 2,
                  child: ColoredBox(color: pageColor),
                ),
                buildHeader(floating: floating, lift: lift),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListHeader extends StatelessWidget {
  final Group group;

  final Function(String groupName) onChange;
  final Function(String groupName) onScrollToSelected;
  final bool isExpand;

  /// Whether the rows have settled under the header, squaring its bottom.
  final bool unfolded;

  final bool enterAnimated;

  /// How far the group's own rows have scrolled under the pinned header, as a
  /// fraction of the distance that rounds its bottom corners.
  final double floating;

  /// The shadow that lifts the header off the rows under it.
  final double lift;

  const ListHeader({
    super.key,
    this.enterAnimated = true,
    this.floating = 0,
    this.lift = 0,
    required this.group,
    required this.onChange,
    required this.onScrollToSelected,
    required this.isExpand,
    required this.unfolded,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ProxiesScope.of(context);
    final groupName = group.name;
    final isDelayTesting = controller.isGroupDelayTesting(groupName);
    final colorScheme = context.colorScheme;
    final level = floating > 0
        ? SurfaceLevel.floatingOf(colorScheme)
        : context.raisedSurfaceLevel;
    final radius = AppCorner.xl.ap(context);
    final card = Card(
      enterActionsOnRight: true,
      enterAnimated: enterAnimated,
      key: key,
      radius: radius - _headerButtonInset,
      child: Padding(
        padding: const EdgeInsets.all(_headerInset - _headerButtonInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  _GroupIcon(src: group.icon, name: groupName),
                  Flexible(child: _GroupSummary(groupName: groupName)),
                ],
              ),
            ),
            _GroupActions(
              isExpand: isExpand,
              isDelayTesting: isDelayTesting,
              groupType: group.type.name,
              onScrollToSelected: () {
                onScrollToSelected(groupName);
              },
              onDelayTest: () {
                unawaited(controller.delayTestPageGroup(groupName));
              },
              onToggle: () {
                onChange(groupName);
              },
            ),
          ],
        ),
      ),
      onPressed: () {
        onChange(groupName);
      },
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.vertical(
          top: radius,
          bottom: unfolded ? radius * floating : radius,
        ),
        shadows: lift == 0 ? null : _floatingShadows(colorScheme, lift),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_headerButtonInset),
        child: SurfaceScope(
          // Card fills one level above its scope.
          level: SurfaceLevel.values[level.index - 1],
          child: card,
        ),
      ),
    );
  }
}

List<BoxShadow> _floatingShadows(ColorScheme colorScheme, double lift) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.08 * strength * lift),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * strength * lift),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

class _GroupIcon extends StatelessWidget {
  const _GroupIcon({required this.src, required this.name});

  final String src;
  final String name;

  @override
  Widget build(BuildContext context) {
    final iconStyle = ProxiesScope.of(context).style.iconStyle;
    return switch (iconStyle) {
      ProxiesIconStyle.filled => LayoutBuilder(
        builder: (_, constraints) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                padding: EdgeInsets.all(6.ap(context)),
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(
                    context.colorScheme,
                  ),
                  shape: AppShape.all(AppCorner.xl.ap(context) - _headerInset),
                ),
                clipBehavior: Clip.antiAlias,
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: constraints.maxHeight - 12.ap(context),
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  child: CommonTargetIcon(
                    src: src,
                    fallback: GroupMonogram(name),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ProxiesIconStyle.plain => Container(
        margin: const EdgeInsets.only(left: 2, right: 10),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return IconTheme.merge(
              data: IconThemeData(
                size: constraints.maxHeight,
                color: context.colorScheme.primary,
              ),
              child: CommonTargetIcon(src: src, fallback: GroupMonogram(name)),
            );
          },
        ),
      ),
      // Lines the title up with the proxy card names below, which sit at the
      // row inset plus the card padding.
      ProxiesIconStyle.hidden => const SizedBox(width: 4),
    };
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmojiText(
          groupName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.callout.of(context, emphasized: true),
        ),
        const SizedBox(height: 2),
        Flexible(flex: 1, child: _SelectedProxyName(groupName: groupName)),
      ],
    );
  }
}

class _SelectedProxyName extends StatelessWidget {
  const _SelectedProxyName({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    final proxyName = ProxiesScope.of(
      context,
    ).selectedProxyNameOf(groupName).takeFirstValid([]);
    if (proxyName.isEmpty) {
      return const SizedBox.shrink();
    }
    return EmojiText(
      proxyName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.caption1.of(context, emphasized: true).toLight,
    );
  }
}

class _GroupActions extends StatelessWidget {
  const _GroupActions({
    required this.isExpand,
    required this.isDelayTesting,
    required this.groupType,
    required this.onScrollToSelected,
    required this.onDelayTest,
    required this.onToggle,
  });

  final bool isExpand;
  final bool isDelayTesting;
  final String groupType;
  final VoidCallback onScrollToSelected;
  final VoidCallback onDelayTest;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TonalButtonTheme(
      size: TonalButtonSize.compact,
      child: Row(
        children: [
          if (isExpand)
            TonalButtonGroup(
              size: TonalButtonSize.compact,
              children: [
                IconButton(
                  tooltip: KitLocalizations.of(context).scrollToSelected,
                  onPressed: onScrollToSelected,
                  iconSize: 19,
                  icon: const GlyphIcon(AppGlyphs.locate),
                ),
                IconButton(
                  tooltip: KitLocalizations.of(context).delayTest,
                  onPressed: isDelayTesting ? null : onDelayTest,
                  icon: isDelayTesting
                      ? const ActivityIndicator(size: 24)
                      : const GlyphIcon(AppGlyphs.bolt),
                ),
              ],
            )
          else
            Text(
              groupType,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .toLight,
            ),
          const SizedBox(width: 6),
          ElasticPress(
            child: IconButton(
              tooltip: isExpand
                  ? KitLocalizations.of(context).showLess
                  : KitLocalizations.of(context).showMore,
              onPressed: onToggle,
              icon: ExpandIcon(expand: isExpand),
            ),
          ),
        ],
      ),
    );
  }
}
