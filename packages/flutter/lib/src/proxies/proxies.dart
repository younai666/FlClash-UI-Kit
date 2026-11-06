// Derived from chen08209/FlClash, lib/views/proxies/proxies.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
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
}

class ProxiesView extends StatefulWidget {
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
  }

  List<PopupMenuItem> _buildMenuItems(
    BuildContext context,
    ProxiesController controller,
    ProxiesStyleProps style,
  ) {
    final appLocalizations = KitLocalizations.of(context);
    return [
      _optionsMenuItem(
        glyph: AppGlyphs.appsList,
        label: appLocalizations.style,
        section: const PopupMenuSection(),
        options: ProxiesType.values,
        value: style.type,
        textOf: (type) => type.labelOf(context),
        onSelected: (type) =>
            _updateStyle(controller, (state) => state.copyWith(type: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.sort,
        label: appLocalizations.sort,
        options: ProxiesSortType.values,
        value: style.sortType,
        textOf: (type) => switch (type) {
          ProxiesSortType.none => appLocalizations.defaultText,
          ProxiesSortType.delay => appLocalizations.delay,
          ProxiesSortType.name => appLocalizations.name,
        },
        onSelected: (type) =>
            _updateStyle(controller, (state) => state.copyWith(sortType: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.dashboard,
        label: appLocalizations.layout,
        options: ProxiesLayout.values,
        value: style.layout,
        textOf: (layout) => switch (layout) {
          ProxiesLayout.tight => appLocalizations.tight,
          ProxiesLayout.standard => appLocalizations.standard,
          ProxiesLayout.loose => appLocalizations.loose,
        },
        onSelected: (layout) =>
            _updateStyle(controller, (state) => state.copyWith(layout: layout)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.textSize,
        label: appLocalizations.size,
        options: ProxyCardType.values,
        value: style.cardType,
        textOf: (type) => type.labelOf(context),
        onSelected: (type) =>
            _updateStyle(controller, (state) => state.copyWith(cardType: type)),
      ),
      if (style.type == ProxiesType.list)
        _optionsMenuItem(
          glyph: AppGlyphs.iconTile,
          label: appLocalizations.iconStyle,
          options: ProxiesIconStyle.values,
          value: style.iconStyle,
          textOf: (iconStyle) => switch (iconStyle) {
            ProxiesIconStyle.filled => appLocalizations.iconStyleFilled,
            ProxiesIconStyle.plain => appLocalizations.iconStylePlain,
            ProxiesIconStyle.hidden => appLocalizations.iconStyleHidden,
          },
          onSelected: (iconStyle) =>
              _updateStyle(controller, (state) => state.copyWith(iconStyle: iconStyle)),
        ),
      PopupMenuItem(
        glyph: AppGlyphs.eyeOff,
        label: appLocalizations.hideTimeoutProxies,
        checked: style.hideTimeoutProxies,
        section: const PopupMenuSection(),
        onPressed: () => _updateStyle(
          controller,
          (state) =>
              state.copyWith(hideTimeoutProxies: !state.hideTimeoutProxies),
        ),
      ),
    ];
  }

  IconButtonData? _buildPrimaryAction(
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
  }
}

PopupMenuItem _optionsMenuItem<T>({
  required Glyph glyph,
  required String label,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
  PopupMenuSection? section,
}) {
  return PopupMenuItem(
    glyph: glyph,
    label: label,
    section: section,
    subItems: [
      for (final option in options)
        PopupMenuItem(
          label: textOf(option),
          checked: option == value,
          onPressed: () => onSelected(option),
        ),
    ],
  );
}
