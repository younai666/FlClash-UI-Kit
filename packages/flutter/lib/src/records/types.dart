// Derived from chen08209/FlClash, lib/enum/enum.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: provenance header only.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

enum RecordTone { neutral, warning, error }

enum RecordFacetKind {
  network,
  rule,
  mitm,
  app,
  proxy,
  level,
  type,
  initiator,
  cache,
  rcode,
}

enum RecordGrouping { app, host, rule, exit }

extension RecordToneExt on RecordTone {
  Color? accentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.warning,
      RecordTone.error => colorScheme.error,
      RecordTone.neutral => null,
    };
  }

  Color labelColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.neutral => colorScheme.onSurfaceVariant,
      RecordTone.warning => colorScheme.onWarningContainer,
      RecordTone.error => colorScheme.onErrorContainer,
    };
  }

  Color labelContainerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.neutral => context.raisedSurfaceLevel.colorOf(colorScheme),
      RecordTone.warning => colorScheme.warningContainer,
      RecordTone.error => colorScheme.errorContainer,
    };
  }
}

