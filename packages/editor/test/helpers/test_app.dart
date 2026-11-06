import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

class HostApp extends StatelessWidget {
  const HostApp({super.key, required this.home, this.builder});
  final Widget home;
  final TransitionBuilder? builder;
  @override
  Widget build(BuildContext context) => KitApp(home: home, builder: builder, locale: const Locale('en'));
}
