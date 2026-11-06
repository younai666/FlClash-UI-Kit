// Derived from chen08209/FlClash, lib/pages/home.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = HomeShellScope.of(context);
    final hasViewSize = !shell.viewSizeOf(context).isEmpty && shell.currentNavigationItemsOf(context).isNotEmpty;
    // The window is revealed on this frame; under the Windows sidebar
    // material an unpainted body shows black until the next frame lands.
    if (!hasViewSize) {
      return ColoredBox(color: SurfaceLevel.page.colorOf(context.colorScheme));
    }
    return HomeBackScopeContainer(
      child: AppSidebarContainer(
        child: _HomeShell(
          child: Builder(
            builder: (context) {
              final shell = HomeShellScope.of(context);
              final navigationItems = shell.currentNavigationItemsOf(context);
              final isMobile = shell.viewModeOf(context) == ViewMode.mobile;
              return _HomePageView(
                navigationItems: navigationItems,
                pageBuilder: (_, index) {
                  final navigationItem = navigationItems[index];
                  return _NavigationPage(
                    key: ValueKey(navigationItem.label),
                    item: navigationItem,
                    isMobile: isMobile,
                    view: navigationItem.builder(context),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.child});

  final Widget child;

  void _handleToPage(Object pageLabel, BuildContext context) {
    HomeShellScope.read(context).openPage(pageLabel);
  }

  @override
  Widget build(BuildContext context) {
    final state = HomeShellScope.of(context).navigationStateOf(context);
    final isMobile = state.viewMode == ViewMode.mobile;
    final navigationItems = state.navigationItems;
    final floating = HomeShellScope.of(context).floatingNavigationBar;
    return Surface(
      color: SurfaceLevel.page.colorOf(context.colorScheme),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FocusTraversalGroup(
                    policy: PageTraversalPolicy(),
                    child: BottomInsetScope(
                      inset: isMobile && floating
                          ? NavigationDock.insetOf(context)
                          : 0,
                      child: _BodyPadding(isMobile: isMobile, child: child),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: AnimatedVisibility.bottomNavigation(
                    visible: isMobile && floating,
                    child: BarItemPresence.held(
                      child: _NavigationPadding(
                        child: NavigationDock(
                          destinations: [
                            for (final item in navigationItems)
                              NavigationDockDestination(
                                glyph: item.glyph,
                                label: item.titleOf(context),
                              ),
                          ],
                          selectedIndex: state.currentIndex,
                          onSelected: (index) {
                            _handleToPage(navigationItems[index].label, context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedVisibility.bottomNavigation(
            visible: isMobile && !floating,
            child: _NavigationPadding(
              child: NavigationBar(
                destinations: [
                  for (final (index, item) in navigationItems.indexed)
                    NavigationDestination(
                      icon: AnimatedGlyph(
                        glyph: item.glyph,
                        filled: index == state.currentIndex,
                      ),
                      label: item.titleOf(context),
                    ),
                ],
                selectedIndex: state.currentIndex,
                onDestinationSelected: (index) {
                  _handleToPage(navigationItems[index].label, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPadding extends StatelessWidget {
  const _BodyPadding({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: false,
      removeBottom: isMobile,
      removeLeft: isMobile,
      removeRight: isMobile,
      context: context,
      child: child,
    );
  }
}

class _NavigationPadding extends StatelessWidget {
  const _NavigationPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: false,
      removeLeft: true,
      removeRight: true,
      context: context,
      child: child,
    );
  }
}

class _NavigationPage extends StatelessWidget {
  const _NavigationPage({
    super.key,
    required this.item,
    required this.isMobile,
    required this.view,
  });

  final NavigationItem item;
  final bool isMobile;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    // The global key lives here, not on the view: the same view also opens as
    // a pushed page, which may overlap a pop of itself.
    final scopedView = PageFocusScope(
      child: KeyedSubtree(key: HomeShellScope.read(context).pageKeyOf(item.label), child: view),
    );
    final keptView = KeepScope(
      key: ValueKey(item.label),
      child: isMobile
          ? scopedView
          : Navigator(
              key: ValueKey('${item.label}_navigator'),
              pages: [RootPage(child: scopedView)],
              onDidRemovePage: (_) {},
            ),
    );
    final isActive = HomeShellScope.of(context).shownPageLabel(context) == item.label;
    return PageActivityScope(
      isActive: isActive,
      child: TickerMode(
        enabled: isActive,
        child: ExcludeFocus(
          excluding: !isActive,
          child: KeyboardInsetHold(child: keptView),
        ),
      ),
    );
  }
}

class _HomePageView extends StatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
  });

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  late PageController _pageController;

  late HomeShellController _shell;
  late Object _lastLabel;
  void _handleShellChanged() {
    if (_lastLabel == _shell.pageLabel) return;
    _lastLabel = _shell.pageLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) _toPage(_shell.pageLabel);
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = HomeShellScope.of(context);
    if (!identical(next, _shell)) {
      _shell.removeListener(_handleShellChanged);
      _shell = next;
      _shell.addListener(_handleShellChanged);
      _handleShellChanged();
    }
  }
  List<int>? _order;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    _shell = HomeShellScope.read(context);
    _lastLabel = _shell.pageLabel;
    _shell.addListener(_handleShellChanged);
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      _labelsOf(oldWidget.navigationItems),
      _labelsOf(widget.navigationItems),
    )) {
      _order = null;
      _updatePageController();
    }
  }

  static List<Object> _labelsOf(List<NavigationItem> items) => [
    for (final item in items) item.label,
  ];

  int get _pageIndex => _indexOf(HomeShellScope.read(context).pageLabel);

  int _indexOf(Object pageLabel) {
    final shown = shownPageLabelOf(pageLabel, widget.navigationItems);
    return widget.navigationItems.indexWhere((item) => item.label == shown);
  }

  Future<void> _toPage(
    Object pageLabel, [
    bool ignoreAnimateTo = false,
  ]) async {
    if (!mounted) {
      return;
    }
    final index = _indexOf(pageLabel);
    if (index == -1) {
      return;
    }
    final tabAnimation = HomeShellScope.read(context).tabAnimation;
    final isMobile = (HomeShellScope.read(context).viewModeOf(context) == ViewMode.mobile);
    final slide = ++_slide;
    final page = _pageController.hasClients
        ? _pageController.page?.round() ?? index
        : index;
    final current = _order?[page] ?? page;
    if (_order != null) {
      setState(() => _order = null);
      _pageController.jumpToPage(current);
    }
    if (!isMobile || ignoreAnimateTo) {
      _pageController.jumpToPage(index);
      return;
    }
    // As TabBarView does, so no page between is built and painted on the way.
    if ((index - current).abs() > 1) {
      final adjacent = index > current ? index - 1 : index + 1;
      setState(() {
        _order = List.generate(widget.navigationItems.length, (item) => item)
          ..[adjacent] = current
          ..[current] = adjacent;
      });
      _pageController.jumpToPage(adjacent);
    }
    final fade = tabAnimation == TabAnimation.fade;
    await _pageController.animateToPage(
      index,
      duration: fade ? fadeTabDuration : kTabScrollDuration,
      curve: fade ? fadeTabCurve : Curves.easeOut,
    );
    if (mounted && slide == _slide && _order != null) {
      setState(() => _order = null);
    }
  }

  void _updatePageController() {
    final pageLabel = HomeShellScope.read(context).pageLabel;
    _toPage(pageLabel, true);
  }

  @override
  void dispose() {
    _shell.removeListener(_handleShellChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.navigationItems.length;
    final fade = (HomeShellScope.of(context).tabAnimation == TabAnimation.fade);
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<Object>) {
          return null;
        }
        final index = widget.navigationItems.indexWhere(
          (item) => item.label == key.value,
        );
        if (index == -1) {
          return null;
        }
        return _order?.indexOf(index) ?? index;
      },
      itemBuilder: (context, index) {
        final page = widget.pageBuilder(context, _order?[index] ?? index);
        return _FadeTabPage(
          key: page.key,
          controller: _pageController,
          position: index,
          enabled: fade,
          child: page,
        );
      },
    );
  }
}

const _restingDelta = 0.001;

/// Cancels the page view's slide so a tab switch cross-fades in place, and
/// wraps every page even when off so switching the setting keeps their state.
/// A page off its resting place is drawn from a snapshot, as a moving route is.
class _FadeTabPage extends StatefulWidget {
  const _FadeTabPage({
    super.key,
    required this.controller,
    required this.position,
    required this.enabled,
    required this.child,
  });

  final PageController controller;
  final int position;
  final bool enabled;
  final Widget child;

  @override
  State<_FadeTabPage> createState() => _FadeTabPageState();
}

class _FadeTabPageState extends State<_FadeTabPage> {
  final _snapshot = SnapshotController();

  @override
  void dispose() {
    _snapshot.dispose();
    super.dispose();
  }

  // Not controller.page: it clamps to the extent of the last layout, which a
  // page inserted before the current one outgrows before the next layout.
  double get _delta {
    final controller = widget.controller;
    if (!controller.hasClients) {
      return 0;
    }
    final metrics = controller.position;
    if (!metrics.hasContentDimensions || metrics.viewportDimension == 0) {
      return 0;
    }
    final page = metrics.pixels / metrics.viewportDimension;
    return (widget.position - page).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, child) {
        final offset = _delta;
        _snapshot.allowSnapshotting = offset.abs() > _restingDelta;
        final delta = widget.enabled ? offset : 0.0;
        return FractionalTranslation(
          translation: Offset(-delta, 0),
          child: Opacity(opacity: 1 - delta.abs(), child: child),
        );
      },
      child: SnapshotWidget(
        controller: _snapshot,
        mode: SnapshotMode.permissive,
        autoresize: true,
        child: LiquidGlassHost(
          enabled: LiquidGlassScope.of(context),
          child: widget.child,
        ),
      ),
    );
  }
}

class HomeBackScopeContainer extends StatelessWidget {
  final Widget child;

  const HomeBackScopeContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopGuard(
      onPop: (context) async {
        final pageLabel = HomeShellScope.read(context).shownPageLabel(context);
        final realContext =
            HomeShellScope.read(context).pageKeyOf(pageLabel).currentContext ?? context;
        final canPop = Navigator.canPop(realContext);
        if (canPop) {
          Navigator.of(realContext).pop();
        } else if (HomeShellScope.read(context).isTV && pageLabel != HomeShellScope.read(context).fallbackPageLabel) {
          HomeShellScope.read(context).openPage(HomeShellScope.read(context).fallbackPageLabel);
        } else {
          await HomeShellScope.read(context).requestExit();
        }
        return false;
      },
      child: child,
    );
  }
}
