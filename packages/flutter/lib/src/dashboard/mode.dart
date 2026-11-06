// FlClash lib/enum/enum.dart:116 and common/l10n_labels.dart,
// be84736605527034689c95bf27828ff27d912c5e; GPL-3.0.
// Modified 2026-11-05: explicit locale context, no global app state.
import 'package:flutter/widgets.dart';
import '../localizations.dart';

enum Mode { rule, global, direct }

extension ModeLabel on Mode {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) { Mode.rule => l.rule, Mode.global => l.global, Mode.direct => l.direct };
  }
}
