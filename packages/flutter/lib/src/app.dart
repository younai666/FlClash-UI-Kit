// Theme policy adapted from FlClash lib/manager/theme_manager.dart and
// lib/providers/state/theme.dart, be84736605527034689c95bf27828ff27d912c5e.
// Modified 2026-11-05: host-owned configuration and locale-aware caches. GPL-3.0.
import 'package:flutter/foundation.dart' show defaultTargetPlatform, listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prism_ui/prism_ui.dart';

import 'localizations.dart';
import 'licenses.dart';

/// The upstream application scopes with ready-to-use English/Chinese UI strings.
class KitApp extends StatefulWidget {
  const KitApp({
    super.key,
    required this.home,
    this.title = 'FlClash UI Kit',
    this.seedColor = const Color(0xFF007AFF),
    this.colorStyle = ColorStyle.vivid,
    this.pureBlack = false,
    this.themeMode = ThemeMode.system,
    this.theme,
    this.darkTheme,
    this.locale,
    this.liquidGlass,
    this.remoteFocus = false,
    this.navigatorKey,
    this.builder,
    this.mobileBreakpoint = 600,
    this.windowControls = Size.zero,
    this.localizationsDelegates = const [],
    this.fontFamily,
    this.fontFamilyFallback,
    this.textScale,
    this.minTextScale = 0.8,
    this.maxTextScale = 1.4,
    this.stackedBanners,
    this.bannerTopInset = 0,
  });

  final Widget home;
  final String title;
  final Color seedColor;
  final ColorStyle colorStyle;
  final bool pureBlack;
  final ThemeMode themeMode;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final Locale? locale;
  final LiquidGlassQuality? liquidGlass;
  final bool remoteFocus;
  final GlobalKey<NavigatorState>? navigatorKey;
  final TransitionBuilder? builder;
  final double mobileBreakpoint;
  final Size windowControls;
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? textScale;
  final double minTextScale;
  final double maxTextScale;
  final bool? stackedBanners;
  final double bannerTopInset;

  @override
  State<KitApp> createState() => _KitAppState();
}

class _KitAppState extends State<KitApp> with WidgetsBindingObserver {
  final _themes = <Brightness, ({Object inputs, List<String> fonts, ThemeData theme})>{};

  @override
  void initState() {
    super.initState();
    registerKitLicenses();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  List<String> get _fallbackFonts =>
      widget.fontFamilyFallback ??
      appFontFamilyFallback(
        platform: defaultTargetPlatform,
        locales: [
          ?widget.locale,
          ...WidgetsBinding.instance.platformDispatcher.locales,
        ],
        fontFamily: widget.fontFamily,
      );

  ThemeData _theme(Brightness brightness) {
    final inputs = (defaultTargetPlatform, widget.seedColor, widget.colorStyle, widget.pureBlack, widget.fontFamily);
    final fonts = _fallbackFonts;
    final previous = _themes[brightness];
    if (previous != null && previous.inputs == inputs && listEquals(previous.fonts, fonts)) {
      return previous.theme;
    }
    final scheme = seededColorScheme(seedColor: widget.seedColor, brightness: brightness, style: widget.colorStyle).toPureBlack(widget.pureBlack);
    final savedFonts = List<String>.unmodifiable(fonts);
    final theme = ThemeData(
      fontFamily: widget.fontFamily,
      fontFamilyFallback: savedFonts,
      colorScheme: scheme,
      elevatedColorScheme: brightness == Brightness.dark ? scheme.elevated : null,
    );
    _themes[brightness] = (inputs: inputs, fonts: savedFonts, theme: theme);
    return theme;
  }

  @override
  Widget build(BuildContext context) => PrismApp(
    navigatorKey: widget.navigatorKey,
    title: widget.title,
    home: widget.home,
    theme: widget.theme ?? _theme(Brightness.light),
    darkTheme: widget.darkTheme ?? _theme(Brightness.dark),
    themeMode: widget.themeMode,
    locale: widget.locale,
    supportedLocales: const [Locale('en'), Locale('zh')],
    localizationsDelegates: [
      ...widget.localizationsDelegates,
      KitLocalizations.stringsDelegate,
      KitLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    liquidGlass: widget.liquidGlass,
    textScale: widget.textScale,
    minTextScale: widget.minTextScale,
    maxTextScale: widget.maxTextScale,
    stackedBanners: widget.stackedBanners ?? false,
    bannerTopInset: widget.bannerTopInset,
    remoteFocus: widget.remoteFocus,
    debugShowCheckedModeBanner: false,
    builder: (context, child) {
      final size = MediaQuery.sizeOf(context);
      return ViewScope(
        size: size,
        isMobile: size.width <= widget.mobileBreakpoint,
        windowControls: widget.windowControls,
        child: widget.builder == null
            ? child!
            : Builder(builder: (context) => widget.builder!(context, child)),
      );
    },
  );
}
