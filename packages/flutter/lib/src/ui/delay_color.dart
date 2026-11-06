// Derived from chen08209/FlClash, lib/ui/delay_color.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: provenance header only.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

extension DelayColorScheme on ColorScheme {
  Color? delayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return error;
    if (delay < 600) return success;
    return warning;
  }
}
