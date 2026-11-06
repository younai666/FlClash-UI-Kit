// ignore_for_file: prefer_initializing_formals
// Host-owned adaptive shell models, controller, and InheritedNotifier scope
// (adapted from FlClash lib/providers/state/navigation.dart,
// lib/models/common.dart, and lib/enum/enum.dart,
// commit be84736605527034689c95bf27828ff27d912c5e). GPL-3.0.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../icons.dart';
import '../localizations.dart';
import '../proxies/models.dart';
import '../theme_preview.dart';

const toolsStoreKey = PageStorageKey<String>('tools');

enum NavigationItemMode { mobile, desktop, more, moreFull }

enum PageLabel {
  dashboard,
  proxies,
  profiles,
  tools,
  logs,
  requests,
  resources,
  dns,
}

extension PageLabelL10n on PageLabel {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) {
      PageLabel.dashboard => l.dashboard,
      PageLabel.proxies => l.proxies,
      PageLabel.profiles => l.profiles,
      PageLabel.tools => l.tools,
      PageLabel.logs => l.logs,
      PageLabel.requests => l.requests,
      PageLabel.resources => l.resources,
      PageLabel.dns => l.dnsQueries,
    };
  }
}

extension LocaleL10n on Locale {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (toString()) {
      'en' => l.en,
      'zh' || 'zh_CN' => l.zhCN,
      final code => code,
    };
  }
}

/// Destination entry for [HomePage] and [ToolsView].
///
/// [label] may be a [PageLabel] or any custom identifier (`String`, `enum`,
/// etc.) for standalone applications; provide [title] or [titleBuilder] when
/// using non-[PageLabel] identifiers.
@immutable
class NavigationItem {
  final Glyph glyph;
  final Object label;
  final String? title;
  final String Function(BuildContext context)? titleBuilder;
  final WidgetBuilder builder;
  final List<NavigationItemMode> modes;

  const NavigationItem({
    required this.glyph,
    required this.label,
    this.title,
    this.titleBuilder,
    required this.builder,
    this.modes = const [NavigationItemMode.mobile, NavigationItemMode.desktop],
  });

  String titleOf(BuildContext context) {
    if (titleBuilder != null) return titleBuilder!(context);
    if (title != null) return title!;
    final current = label;
    if (current is PageLabel) return current.labelOf(context);
    return current.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationItem &&
          other.glyph == glyph &&
          other.label == label &&
          other.title == title &&
          other.titleBuilder == titleBuilder &&
          other.builder == builder &&
          listEquals(other.modes, modes);

  @override
  int get hashCode => Object.hash(
        glyph,
        label,
        title,
        titleBuilder,
        builder,
        Object.hashAll(modes),
      );
}

Object shownPageLabelOf(
  Object current,
  List<NavigationItem> items, {
  Object fallback = PageLabel.dashboard,
}) {
  if (items.isEmpty) return current;
  if (items.any((item) => item.label == current)) return current;
  if (items.any((item) => item.label == fallback)) return fallback;
  return items.first.label;
}

@immutable
class NavigationState {
  final Object pageLabel;
  final List<NavigationItem> navigationItems;
  final ViewMode viewMode;
  final int currentIndex;

  const NavigationState({
    required this.pageLabel,
    required this.navigationItems,
    required this.viewMode,
    required this.currentIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationState &&
          other.pageLabel == pageLabel &&
          listEquals(other.navigationItems, navigationItems) &&
          other.viewMode == viewMode &&
          other.currentIndex == currentIndex;

  @override
  int get hashCode => Object.hash(
        pageLabel,
        Object.hashAll(navigationItems),
        viewMode,
        currentIndex,
      );
}

@immutable
class AboutLink {
  final Glyph glyph;
  final String title;
  final String url;
  final String label;

  const AboutLink({
    required this.glyph,
    required this.title,
    required this.url,
    required this.label,
  });
}

@immutable
class Contributor {
  final String name;
  final String? role;
  final ImageProvider? avatarImage;
  final Widget? avatar;

  const Contributor({
    required this.name,
    this.role,
    this.avatarImage,
    this.avatar,
  });
}

class HomeShellController extends ChangeNotifier {
  HomeShellController({
    List<NavigationItem> navigationItems = const [],
    Object pageLabel = PageLabel.dashboard,
    this.fallbackPageLabel = PageLabel.dashboard,
    Size? viewSize,
    bool sidebarExpanded = true,
    double sideWidth = 0,
    bool floatingNavigationBar = true,
    TabAnimation tabAnimation = TabAnimation.fade,
    double? backdropOpacity,
    bool? isMacOS,
    bool? isDesktop,
    this.isTV = false,
    this.osVersion = 0,
    Locale? locale,
    this.supportedLocales = const [Locale('en'), Locale('zh')],
    bool developerMode = false,
    this.onPageChanged,
    this.onSidebarExpandedChanged,
    this.onSidebarWidthChanged,
    this.onLocaleChanged,
    this.onDeveloperModeChanged,
    this.onExit,
  }) : _navigationItems = List<NavigationItem>.unmodifiable(navigationItems),
       _pageLabel = pageLabel,
       _viewSize = viewSize,
       _sidebarExpanded = sidebarExpanded,
       _sideWidth = sideWidth,
       _floatingNavigationBar = floatingNavigationBar,
       _tabAnimation = tabAnimation,
       _backdropOpacity = backdropOpacity,
       isMacOS = isMacOS ?? (defaultTargetPlatform == TargetPlatform.macOS),
       isDesktop =
           isDesktop ??
           (defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.linux ||
               defaultTargetPlatform == TargetPlatform.macOS),
       _locale = locale,
       _developerMode = developerMode;

  List<NavigationItem> _navigationItems;
  Object _pageLabel;
  final Object fallbackPageLabel;
  Size? _viewSize;
  bool _sidebarExpanded;
  double _sideWidth;
  bool _floatingNavigationBar;
  TabAnimation _tabAnimation;
  double? _backdropOpacity;
  final bool isMacOS;
  final bool isDesktop;
  final bool isTV;
  final int osVersion;
  Locale? _locale;
  final List<Locale> supportedLocales;
  bool _developerMode;

  final ValueChanged<Object>? onPageChanged;
  final ValueChanged<bool>? onSidebarExpandedChanged;
  final ValueChanged<double>? onSidebarWidthChanged;
  final ValueChanged<Locale?>? onLocaleChanged;
  final ValueChanged<bool>? onDeveloperModeChanged;
  final Future<void> Function()? onExit;

  List<NavigationItem> get navigationItems => _navigationItems;
  Object get pageLabel => _pageLabel;
  Size? get explicitViewSize => _viewSize;
  bool get sidebarExpanded => _sidebarExpanded;
  double get sideWidth => _sideWidth;
  bool get floatingNavigationBar => _floatingNavigationBar;
  TabAnimation get tabAnimation => _tabAnimation;
  double? get backdropOpacity => _backdropOpacity;
  Locale? get locale => _locale;
  bool get developerMode => _developerMode;

  Size viewSizeOf(BuildContext context) => _viewSize ?? ViewScope.sizeOf(context);

  ViewMode viewModeOf(BuildContext context) =>
      getViewMode(viewSizeOf(context).width);

  List<NavigationItem> currentNavigationItemsOf(BuildContext context) {
    final viewWidth = viewSizeOf(context).width;
    final requiredMode = viewWidth <= maxMobileWidth
        ? NavigationItemMode.mobile
        : NavigationItemMode.desktop;
    return _navigationItems
        .where((element) => element.modes.contains(requiredMode))
        .toList();
  }

  Object shownPageLabel(BuildContext context) {
    final items = currentNavigationItemsOf(context);
    return shownPageLabelOf(
      _pageLabel,
      items,
      fallback: fallbackPageLabel,
    );
  }

  NavigationState navigationStateOf(BuildContext context) {
    final items = currentNavigationItemsOf(context);
    final label = shownPageLabelOf(
      _pageLabel,
      items,
      fallback: fallbackPageLabel,
    );
    final index = items.indexWhere((element) => element.label == label);
    return NavigationState(
      pageLabel: label,
      navigationItems: items,
      viewMode: viewModeOf(context),
      currentIndex: index == -1 ? 0 : index,
    );
  }

  List<NavigationItem> moreNavigationItemsOf(BuildContext context) {
    if (viewModeOf(context) != ViewMode.mobile) {
      return const [];
    }
    return _navigationItems
        .where(
          (element) =>
              (element.modes.contains(NavigationItemMode.more) ||
                  element.modes.contains(NavigationItemMode.moreFull)) &&
              !element.modes.contains(NavigationItemMode.mobile),
        )
        .toList();
  }

  void setNavigationItems(List<NavigationItem> items) {
    if (listEquals(_navigationItems, items)) return;
    _navigationItems = List<NavigationItem>.unmodifiable(items);
    notifyListeners();
  }

  void openPage(Object label) {
    if (_pageLabel == label) return;
    _pageLabel = label;
    notifyListeners();
    onPageChanged?.call(label);
  }

  void updateViewSize(Size? size) {
    if (_viewSize == size) return;
    _viewSize = size;
    notifyListeners();
  }

  void setSidebarExpanded(bool expanded) {
    if (_sidebarExpanded == expanded) return;
    _sidebarExpanded = expanded;
    notifyListeners();
    onSidebarExpandedChanged?.call(expanded);
  }

  void setSideWidth(double width) {
    if (_sideWidth == width) return;
    _sideWidth = width;
    notifyListeners();
    onSidebarWidthChanged?.call(width);
  }

  void setFloatingNavigationBar(bool floating) {
    if (_floatingNavigationBar == floating) return;
    _floatingNavigationBar = floating;
    notifyListeners();
  }

  void setTabAnimation(TabAnimation animation) {
    if (_tabAnimation == animation) return;
    _tabAnimation = animation;
    notifyListeners();
  }

  void setBackdropOpacity(double? opacity) {
    if (_backdropOpacity == opacity) return;
    _backdropOpacity = opacity;
    notifyListeners();
  }

  void setLocale(Locale? value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    onLocaleChanged?.call(value);
  }

  void setDeveloperMode(bool enabled) {
    if (_developerMode == enabled) return;
    _developerMode = enabled;
    notifyListeners();
    onDeveloperModeChanged?.call(enabled);
  }

  Future<void> requestExit() async {
    if (onExit != null) {
      await onExit!();
      return;
    }
    await SystemNavigator.pop();
  }
}

class HomeShellScope extends InheritedNotifier<HomeShellController> {
  const HomeShellScope({
    super.key,
    required HomeShellController controller,
    required super.child,
  }) : super(notifier: controller);

  static HomeShellController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HomeShellScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('HomeShellScope not found above context.');
    }
    return scope.notifier!;
  }

  static HomeShellController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<HomeShellScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('HomeShellScope not found above context.');
    }
    return scope.notifier!;
  }

  static HomeShellController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeShellScope>()
        ?.notifier;
  }
}
