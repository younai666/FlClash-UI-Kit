// Derived from chen08209/FlClash, lib/manager/app_manager.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.viewMode,
    required this.onSelected,
  });

  final List<NavigationItem> items;
  final int currentIndex;
  final ViewMode viewMode;
  final void Function(int index) onSelected;

  @override
  Widget build(BuildContext context) {
    final canExpand = canExpandSidebar(viewMode);
    final sidebarExpanded = HomeShellScope.of(context).sidebarExpanded;
    final version = HomeShellScope.of(context).osVersion;
    return NavigationSidebar(
      destinations: [
        for (final item in items)
          SidebarDestination(glyph: item.glyph, label: item.titleOf(context)),
      ],
      selectedIndex: currentIndex,
      expanded: canExpand && sidebarExpanded,
      onSelected: onSelected,
      onToggle: canExpand
          ? () {
              final shell = HomeShellScope.read(context);
              shell.setSidebarExpanded(!shell.sidebarExpanded);
            }
          : null,
      windowControls: windowControlsOverSidebar(
        isMacOS: HomeShellScope.of(context).isMacOS,
        version: version,
      ),
    );
  }
}

class AppSidebarContainer extends StatelessWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  void _updateSideBarWidth(BuildContext context, double contentWidth) {
    final shell = HomeShellScope.read(context);
    final width = shell.viewSizeOf(context).width - contentWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) shell.setSideWidth(width);
    });
  }

  void _handleToPage(BuildContext context, Object pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final focusContext = focusNode?.context;
    final preserveNavigationFocus =
        focusContext?.findAncestorWidgetOfExactType<NavigationSidebar>() !=
        null;
    HomeShellScope.read(context).openPage(pageLabel);
    if (!preserveNavigationFocus || focusNode == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.context != null && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = HomeShellScope.of(context).navigationStateOf(context);
    final navigationItems = navigationState.navigationItems;
    final viewMode = navigationState.viewMode;
    final currentIndex = navigationState.currentIndex;
    final backdropOpacity = HomeShellScope.of(context).backdropOpacity;
    final page = SurfaceLevel.page.colorOf(context.colorScheme);
    final chrome = context.colorScheme.chromeSurface;
    void onSelected(int index) {
      _handleToPage(context, navigationItems[index].label);
    }

    final hasSidebar = viewMode != ViewMode.mobile;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    return Container(
      color: backdropOpacity != null ? Colors.transparent : page,
      child: Row(
        children: [
          AnimatedVisibility.sidebar(
            visible: hasSidebar,
            child: Surface(
              color: backdropOpacity != null
                  ? chrome.withValues(alpha: backdropOpacity)
                  : chrome,
              shape: BorderDirectional(end: Divider.createBorderSide(context)),
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: !isLtr,
                removeRight: isLtr,
                child: _Sidebar(
                  items: navigationItems,
                  currentIndex: currentIndex,
                  viewMode: viewMode,
                  onSelected: onSelected,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRect(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  _updateSideBarWidth(context, constraints.maxWidth);
                  return MediaQuery.removePadding(
                    context: context,
                    removeLeft: hasSidebar && isLtr,
                    removeRight: hasSidebar && !isLtr,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
