// Derived from chen08209/FlClash, lib/features/form/form_page.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import '../localizations.dart';
import '../scaffold/scaffold.dart';
import 'package:flclash_ui_kit/icons.dart';
import 'package:prism_ui/prism_ui.dart';
import 'package:flutter/widgets.dart';

import 'error_banner.dart';

/// A form [showFormSheet] opens: grouped rows under a bar whose check saves,
/// with why the last save was refused above them.
class FormPage extends StatelessWidget {
  final String title;
  final VoidCallback onSave;
  final String? saveLabel;
  final List<IconButtonData> actions;
  final String? error;
  final bool saving;
  final List<Widget> children;

  const FormPage({
    super.key,
    required this.title,
    required this.onSave,
    this.saveLabel,
    this.actions = const [],
    this.error,
    this.saving = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      title: title,
      iconActions: actions,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: saveLabel ?? KitLocalizations.of(context).save,
        isLoading: saving,
        onPressed: saving ? null : onSave,
      ),
      body: Builder(builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.sectionsTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          ErrorBanner(message: error),
          ...children,
        ],
      )),
    );
  }
}
