// Derived from chen08209/FlClash, test/helpers/glyph_finders.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

extension GlyphFinders on CommonFinders {
  Finder byGlyph(Glyph glyph) => byWidgetPredicate(
    (widget) => widget is GlyphIcon && widget.glyph == glyph,
    description: 'GlyphIcon($glyph)',
  );

  Finder widgetWithGlyph(Type widgetType, Glyph glyph) =>
      ancestor(of: byGlyph(glyph), matching: byType(widgetType));
}
