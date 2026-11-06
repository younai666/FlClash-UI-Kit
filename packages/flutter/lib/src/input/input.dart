// Derived from chen08209/FlClash, lib/widgets/input.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'model.dart';
import 'limits.dart';
import '../localizations.dart';
import 'field.dart';


import 'package:prism_ui/prism_ui.dart';
import 'package:flutter/widgets.dart';

class BatchInput<T> {
  static const maxShownIssues = 3;

  final String label;
  final String formatTip;
  final ParsedInput<T> Function(String text) parse;
  final String Function(InputIssue issue) issueMessage;

  const BatchInput({
    required this.label,
    required this.formatTip,
    required this.parse,
    required this.issueMessage,
  });

  String? issuesOf(KitLocalizations appLocalizations, ParsedInput<T>? parsed) {
    if (parsed == null || parsed.isValid) {
      return null;
    }
    return parsed.issues
        .take(maxShownIssues)
        .map(
          (issue) =>
              appLocalizations.lineIssueTip(issue.line, issueMessage(issue)),
        )
        .join('\n');
  }

  /// [issuesOf], or once a save was [attempted], that nothing was entered.
  String? errorOf(
    KitLocalizations appLocalizations,
    ParsedInput<T>? parsed, {
    required bool attempted,
  }) {
    final issues = issuesOf(appLocalizations, parsed);
    if (issues != null) {
      return issues;
    }
    if (attempted && parsed?.entries.isNotEmpty != true) {
      return appLocalizations.emptyTip(label);
    }
    return null;
  }
}

class EntryDialog<T> extends StatefulWidget {
  final String title;
  final Field valueField;
  final int? valueMaxLength;
  final T Function(String value) toEntry;

  const EntryDialog({
    super.key,
    required this.title,
    required this.valueField,
    this.valueMaxLength,
    required this.toEntry,
  });

  @override
  State<EntryDialog<T>> createState() => _EntryDialogState<T>();
}

class _EntryDialogState<T> extends State<EntryDialog<T>> {
  late final TextEditingController _valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Field get valueField => widget.valueField;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: valueField.value);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop<T>(widget.toEntry(_valueController.text));
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Widget _buildForm(KitLocalizations appLocalizations) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: TextFormField(
        maxLines: null,
        minLines: 1,
        inputFormatters: widget.valueMaxLength == null
            ? null
            : TextInputLimits.limit(widget.valueMaxLength!),
        keyboardType: TextInputType.text,
        controller: _valueController,
        decoration: InputDecoration(hintText: valueField.label),
        onFieldSubmitted: (_) {
          _submit();
        },
        validator: (String? value) {
          String? res;
          if (valueField.validator != null) {
            res = valueField.validator!(value);
          }
          if (res != null) {
            return res;
          }
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.value);
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return AlertDialog(
      title: widget.title,
      hasFields: true,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: _buildForm(appLocalizations),
    );
  }
}
