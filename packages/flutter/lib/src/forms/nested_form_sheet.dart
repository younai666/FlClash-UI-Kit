// Derived from chen08209/FlClash, lib/features/form/nested_form_sheet.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';


import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';



/// Open an isolated form with a host-owned draft and exit confirmation.
Future<void> showNestedFormSheet<T>({
  required BuildContext context,
  required T Function() currentValue,
  required WidgetBuilder formBuilder,
  Widget Function(Widget child)? scopeBuilder,
}) => showFormSheet(
  context: context,
  props: nestedPagedSheetProps,
  builder: (_) {
    final sheet = NestedFormSheet<T>(currentValue: currentValue, formBuilder: formBuilder);
    return scopeBuilder?.call(sheet) ?? sheet;
  },
);

class NestedFormSheet<T> extends StatefulWidget {
  final T Function() currentValue;
  final WidgetBuilder formBuilder;

  const NestedFormSheet({
    super.key,
    required this.currentValue,
    required this.formBuilder,
  });

  /// Answers save in the prompt on leaving with the form's own save action,
  /// which closes the sheet once saved and otherwise shows the form why not.
  static void bindSave(BuildContext context, FutureOr<void> Function() save) {
    context.findAncestorStateOfType<_NestedFormSheetState>()?._save = save;
  }

  @override
  State<NestedFormSheet<T>> createState() => _NestedFormSheetState<T>();
}

class _NestedFormSheetState<T> extends State<NestedFormSheet<T>> {
  late final T _origin;
  FutureOr<void> Function()? _save;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _origin = widget.currentValue();
  }

  bool get _changed => _origin != widget.currentValue();

  Future<void> _handleDismiss(bool hasPushedPages) async {
    if (_closing) return;
    _closing = true;
    try {
      if (hasPushedPages && !_changed) {
        final res = await showKitMessage(context,
          message: TextSpan(text: KitLocalizations.of(context).confirmExitWindow),
        );
        if (res != true) {
          return;
        }
      }
      if (context.mounted) {
        await _handleExit();
      }
    } finally {
      _closing = false;
    }
  }

  Future<void> _handleExit() async {
    if (_changed) {
      final res = await showKitSaveChanges(context);
      if (res == null || !mounted) {
        return;
      }
      if (res) {
        await _save?.call();
        return;
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return NestedPagedSheet(
      builder: widget.formBuilder,
      onExit: () => unawaited(_handleDismiss(false)),
      onDismiss: _handleDismiss,
    );
  }
}
