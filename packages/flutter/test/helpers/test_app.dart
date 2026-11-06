// Derived from chen08209/FlClash, test/helpers/test_app.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: provenance header only.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child, this.homeBuilder, this.locale});
  final Widget Function(Widget child)? homeBuilder;
  final Locale? locale;
  final Widget child;
  @override
  Widget build(BuildContext context) => KitApp(liquidGlass: null, locale: locale ?? const Locale('en'), home: homeBuilder != null ? homeBuilder!(child) : child);
}
class HostApp extends StatelessWidget {
  const HostApp({super.key, required this.home});
  final Widget home;
  @override
  Widget build(BuildContext context) => TestApp(child: home);
}

class HostPageRoute<T> extends PageRoute<T> {
  HostPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
  });

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}

