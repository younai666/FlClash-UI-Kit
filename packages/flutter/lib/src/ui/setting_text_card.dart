// Derived from chen08209/FlClash, lib/ui/setting_text_card.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: provenance header only.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      onPressed: onPressed,
      isSelected: isSelected,
      fillsSelection: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(
                color: isSelected == true
                    ? context.colorScheme.onPrimary
                    : null,
              ),
        ),
      ),
    );
  }
}
