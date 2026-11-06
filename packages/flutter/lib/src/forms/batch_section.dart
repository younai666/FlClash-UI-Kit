// Derived from chen08209/FlClash, lib/features/form/batch_section.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.


import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// A form's batch mode: one field of lines, and how many of them it adds.
class BatchSection<T> extends StatelessWidget {
  final BatchInput<T> batch;
  final TextEditingController controller;
  final ParsedInput<T>? parsed;
  final ValueChanged<String> onChanged;

  const BatchSection({
    super.key,
    required this.batch,
    required this.controller,
    required this.parsed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = this.parsed;
    return generateSection(
      footer: parsed == null || controller.text.trim().isEmpty
          ? null
          : KitLocalizations.of(context).batchPreviewTip(
              parsed.entries.length,
              parsed.skippedExisting,
            ),
      items: [
        DecorationListItem(
          title: TextField(
            controller: controller,
            autofocus: true,
            minLines: 4,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            autocorrect: false,
            onChanged: onChanged,
            decoration: InputDecoration.collapsed(
              border: const NoInputBorder(),
              hintText: batch.formatTip,
            ),
          ),
        ),
      ],
    );
  }
}
