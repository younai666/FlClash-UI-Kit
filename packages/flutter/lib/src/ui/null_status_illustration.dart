// Derived from chen08209/FlClash, lib/ui/null_status_illustration.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/src/icons/app_glyphs.dart';
import 'package:prism_ui/icons/glyph.dart';
import 'package:prism_ui/null_status.dart';

/// The illustrations of FlClash's empty pages.
enum NullStatusIllustration implements Illustration {
  data,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  dns,
  ntp,
  sniffer,
  tun,
  wifi,
  apps,
  icons,
  fonts,
  permission,
  camera,
  error;

  @override
  Glyph get glyph => switch (this) {
    data => AppGlyphs.resources,
    logs => AppGlyphs.logs,
    proxies => AppGlyphs.proxies,
    profile => AppGlyphs.profiles,
    scripts => AppGlyphs.code,
    rules => AppGlyphs.rules,
    connections => AppGlyphs.connections,
    requests => AppGlyphs.requests,
    dns => AppGlyphs.dns,
    ntp => AppGlyphs.clock,
    sniffer => AppGlyphs.eye,
    tun => AppGlyphs.vpn,
    wifi => AppGlyphs.wifi,
    apps => AppGlyphs.appsList,
    icons => AppGlyphs.iconTile,
    fonts => AppGlyphs.font,
    permission => AppGlyphs.lock,
    camera => AppGlyphs.camera,
    error => AppGlyphs.error,
  };

  @override
  bool get isError => this == error;
}
