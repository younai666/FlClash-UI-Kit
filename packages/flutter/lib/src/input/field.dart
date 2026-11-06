// Derived from chen08209/FlClash, lib/models/common.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';

class Field {
  const Field({required this.label, required this.value, this.validator});
  final String label;
  final String value;
  final FormFieldValidator<String>? validator;
}

