// Derived from chen08209/FlClash, lib/ui/fonts.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';

/// JetBrains Mono is packaged here under OFL-1.1. Twemoji is a host-supplied optional family; its upstream binary remains quarantined.
enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('packages/flclash_ui_kit/JetBrainsMono');

  final String value;

  const FontFamily(this.value);
}

extension FontFamilyTextStyle on TextStyle {
  TextStyle get toJetBrainsMono =>
      copyWith(fontFamily: FontFamily.jetBrainsMono.value);
}
