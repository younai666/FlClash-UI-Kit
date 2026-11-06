import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

class HostScaffold extends StatelessWidget {
  const HostScaffold({super.key, required this.body});
  final Widget body;
  @override
  Widget build(BuildContext context) => PrismScaffold(
    bar: const PreferredSize(
      preferredSize: Size.zero,
      child: SizedBox.shrink(),
    ),
    body: body,
  );
}
