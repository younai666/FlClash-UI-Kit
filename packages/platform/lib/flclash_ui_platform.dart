/// Optional native integrations; initialize only those the host needs.
/// Window/tray support Windows, macOS and Linux; dynamic color also Android.
library;

export 'src/system_fonts_stub.dart'
    if (dart.library.io) 'src/system_fonts.dart'
    show loadNativeFontFamilies;
export 'src/window_caption.dart';

export 'package:window/window.dart';
export 'package:tray/tray.dart';
export 'package:dynamic_color/dynamic_color.dart';
