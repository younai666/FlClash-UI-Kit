// Derived from chen08209/FlClash, lib/features/form/filter.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

class FilterRegexText extends StatelessWidget {
  final String regex;

  const FilterRegexText(this.regex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      regex,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.footnote
          .of(context)
          .toJetBrainsMono
          .copyWith(color: context.colorScheme.tertiary),
    );
  }
}
