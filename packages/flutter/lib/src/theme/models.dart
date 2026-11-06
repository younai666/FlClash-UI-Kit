// ignore_for_file: prefer_initializing_formals
// Host-owned appearance models, ColorScheme cache, font-family helpers, and
// InheritedNotifier scope (adapted from FlClash lib/models/config.dart,
// lib/providers/state/theme.dart, lib/common/constant.dart, and
// lib/common/system_fonts.dart, commit be84736605527034689c95bf27828ff27d912c5e).
// GPL-3.0.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../localizations.dart';
import '../theme_preview.dart';

const maxTextScale = 1.4;
const minTextScale = 0.8;
const defaultPrimaryColor = 0xFF007AFF;
const intListEquality = ListEquality<int>();

/// iOS 27's system colors with classic deep blue first, in macOS accent order.
const defaultPrimaryColors = [
  defaultPrimaryColor,
  0xFFCB30E0,
  0xFFFF2D55,
  0xFFFF383C,
  0xFFFF8D28,
  0xFFFFCC00,
  0xFF34C759,
  0xFF8E8E93,
];

/// Depends on [context]'s text scaler so the caller rebuilds when the system
/// font scale changes.
double systemTextScaleOf(BuildContext context) {
  MediaQuery.textScalerOf(context);
  return WidgetsBinding.instance.platformDispatcher.textScaleFactor;
}

enum LiquidGlassMode {
  none,
  standard,
  ultra;

  LiquidGlassQuality? get toQuality => switch (this) {
    LiquidGlassMode.none => null,
    LiquidGlassMode.standard => LiquidGlassQuality.standard,
    LiquidGlassMode.ultra => LiquidGlassQuality.ultra,
  };
}

extension ColorStyleL10n on ColorStyle {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) {
      ColorStyle.vivid => l.vividStyle,
      ColorStyle.tinted => l.tintedStyle,
      ColorStyle.soft => l.softStyle,
      ColorStyle.monochrome => l.monochromeScheme,
    };
  }
}

@immutable
class TextScale {
  final bool enable;
  final double scale;

  const TextScale({this.enable = false, this.scale = 1.0});

  TextScale copyWith({bool? enable, double? scale}) {
    return TextScale(
      enable: enable ?? this.enable,
      scale: scale ?? this.scale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextScale && other.enable == enable && other.scale == scale;

  @override
  int get hashCode => Object.hash(enable, scale);
}

const _unset = Object();

const defaultThemeProps = ThemeProps(primaryColor: defaultPrimaryColor);

@immutable
class ThemeProps {
  final int? primaryColor;
  final List<int> primaryColors;
  final ThemeMode themeMode;
  final ColorStyle colorStyle;
  final bool pureBlack;
  final bool sidebarBlur;
  final LiquidGlassMode liquidGlass;
  final TextScale textScale;
  final String? fontFamily;

  const ThemeProps({
    this.primaryColor,
    this.primaryColors = defaultPrimaryColors,
    this.themeMode = ThemeMode.system,
    this.colorStyle = ColorStyle.vivid,
    this.pureBlack = false,
    this.sidebarBlur = false,
    this.liquidGlass = LiquidGlassMode.none,
    this.textScale = const TextScale(),
    this.fontFamily,
  });

  ThemeProps copyWith({
    Object? primaryColor = _unset,
    List<int>? primaryColors,
    ThemeMode? themeMode,
    ColorStyle? colorStyle,
    bool? pureBlack,
    bool? sidebarBlur,
    LiquidGlassMode? liquidGlass,
    TextScale? textScale,
    Object? fontFamily = _unset,
  }) {
    return ThemeProps(
      primaryColor: identical(primaryColor, _unset)
          ? this.primaryColor
          : primaryColor as int?,
      primaryColors: primaryColors ?? this.primaryColors,
      themeMode: themeMode ?? this.themeMode,
      colorStyle: colorStyle ?? this.colorStyle,
      pureBlack: pureBlack ?? this.pureBlack,
      sidebarBlur: sidebarBlur ?? this.sidebarBlur,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      textScale: textScale ?? this.textScale,
      fontFamily: identical(fontFamily, _unset)
          ? this.fontFamily
          : fontFamily as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeProps &&
          other.primaryColor == primaryColor &&
          intListEquality.equals(other.primaryColors, primaryColors) &&
          other.themeMode == themeMode &&
          other.colorStyle == colorStyle &&
          other.pureBlack == pureBlack &&
          other.sidebarBlur == sidebarBlur &&
          other.liquidGlass == liquidGlass &&
          other.textScale == textScale &&
          other.fontFamily == fontFamily;

  @override
  int get hashCode => Object.hash(
        primaryColor,
        intListEquality.hash(primaryColors),
        themeMode,
        colorStyle,
        pureBlack,
        sidebarBlur,
        liquidGlass,
        textScale,
        fontFamily,
      );
}

@immutable
class DynamicColorSeeds {
  final Color? lightSeed;
  final Color? darkSeed;
  final Color? accentColor;

  const DynamicColorSeeds({this.lightSeed, this.darkSeed, this.accentColor});

  Color seedOf(Brightness brightness) {
    final seed = switch (brightness) {
      Brightness.light => lightSeed,
      Brightness.dark => darkSeed,
    };
    return seed ?? accentColor ?? const Color(defaultPrimaryColor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DynamicColorSeeds &&
          other.lightSeed == lightSeed &&
          other.darkSeed == darkSeed &&
          other.accentColor == accentColor;

  @override
  int get hashCode => Object.hash(lightSeed, darkSeed, accentColor);
}

/// Fonts Android distributes in `/system/fonts`, for hosts without native enumeration.
const androidFontFamilies = [
  'sans-serif',
  'sans-serif-medium',
  'sans-serif-light',
  'sans-serif-thin',
  'sans-serif-condensed',
  'serif',
  'monospace',
  'casual',
  'cursive',
];

@visibleForTesting
List<String> sortFontFamilies(Iterable<String> names) {
  final seen = <String>{};
  final result = <String>[];
  for (final raw in names) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.startsWith('.') || trimmed.startsWith('@')) {
      continue;
    }
    if (seen.add(trimmed.toLowerCase())) {
      result.add(trimmed);
    }
  }
  result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return result;
}

/// Optional host/test hook supplying system font family names.
Future<List<String>> Function()? systemFontFamiliesReader;

Future<List<String>> _loadSystemFonts(
  Future<List<String>> Function()? reader,
) async {
  try {
    final activeReader = reader ?? systemFontFamiliesReader;
    final raw = activeReader != null
        ? await activeReader()
        : (defaultTargetPlatform == TargetPlatform.android
              ? androidFontFamilies
              : const <String>[]);
    return sortFontFamilies(raw);
  } catch (_) {
    return const [];
  }
}

/// Loads and normalizes system font family names without throwing.
Future<List<String>> loadSystemFontFamilies({
  Future<List<String>> Function()? reader,
}) => _loadSystemFonts(reader);

typedef _SchemeKey = (int, Brightness, ColorStyle, bool);
final _colorSchemeCache = <_SchemeKey, ColorScheme>{};
const _maxCachedSchemes = 64;

ColorScheme cachedSeededColorScheme({
  required Color seedColor,
  required Brightness brightness,
  required ColorStyle style,
  required bool pureBlack,
}) {
  final key = (seedColor.toARGB32(), brightness, style, pureBlack);
  final hit = _colorSchemeCache.remove(key);
  if (hit != null) {
    _colorSchemeCache[key] = hit;
    return hit;
  }
  if (_colorSchemeCache.length >= _maxCachedSchemes) {
    _colorSchemeCache.remove(_colorSchemeCache.keys.first);
  }
  final scheme = seededColorScheme(
    seedColor: seedColor,
    brightness: brightness,
    style: style,
  ).toPureBlack(pureBlack);
  return _colorSchemeCache[key] = scheme;
}

class ThemeController extends ChangeNotifier {
  ThemeController({
    ThemeProps themeProps = defaultThemeProps,
    bool floatingNavigationBar = true,
    TabAnimation tabAnimation = TabAnimation.fade,
    DynamicColorSeeds dynamicColor = const DynamicColorSeeds(),
    bool? supportsSidebarBlur,
    Future<List<String>> Function()? fontFamiliesReader,
    this.onThemePropsChanged,
    this.onFloatingNavigationBarChanged,
    this.onTabAnimationChanged,
  }) : _themeProps = themeProps,
       _floatingNavigationBar = floatingNavigationBar,
       _tabAnimation = tabAnimation,
       _dynamicColor = dynamicColor,
       supportsSidebarBlur =
           supportsSidebarBlur ??
           (defaultTargetPlatform == TargetPlatform.macOS ||
               defaultTargetPlatform == TargetPlatform.windows),
       _fontFamiliesReader = fontFamiliesReader;

  ThemeProps _themeProps;
  bool _floatingNavigationBar;
  TabAnimation _tabAnimation;
  DynamicColorSeeds _dynamicColor;
  final bool supportsSidebarBlur;
  final Future<List<String>> Function()? _fontFamiliesReader;

  final ValueChanged<ThemeProps>? onThemePropsChanged;
  final ValueChanged<bool>? onFloatingNavigationBarChanged;
  final ValueChanged<TabAnimation>? onTabAnimationChanged;

  ThemeProps get themeProps => _themeProps;
  bool get floatingNavigationBar => _floatingNavigationBar;
  TabAnimation get tabAnimation => _tabAnimation;
  DynamicColorSeeds get dynamicColor => _dynamicColor;

  Color seedColorFor(Brightness brightness) {
    final primaryColor = _themeProps.primaryColor;
    if (primaryColor != null) return Color(primaryColor);
    return _dynamicColor.seedOf(brightness);
  }

  ColorScheme colorSchemeFor(
    Brightness brightness, {
    Color? color,
    bool? pureBlack,
  }) {
    return cachedSeededColorScheme(
      seedColor: color ?? seedColorFor(brightness),
      brightness: brightness,
      style: _themeProps.colorStyle,
      pureBlack: pureBlack ?? _themeProps.pureBlack,
    );
  }

  Brightness currentBrightnessOf(BuildContext context) {
    return switch (_themeProps.themeMode) {
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };
  }

  double? sidebarBackdropOpacityOf(BuildContext context) {
    if (!supportsSidebarBlur || !_themeProps.sidebarBlur) return null;
    if (defaultTargetPlatform == TargetPlatform.macOS) return 0.0;
    return currentBrightnessOf(context) == Brightness.dark ? 0.55 : 0.72;
  }

  Future<List<String>> loadSystemFontFamilies() =>
      _loadSystemFonts(_fontFamiliesReader);

  void updateThemeProps(ThemeProps Function(ThemeProps state) updater) {
    final next = updater(_themeProps);
    if (next == _themeProps) return;
    _themeProps = next;
    notifyListeners();
    onThemePropsChanged?.call(next);
  }

  void setThemeProps(ThemeProps props) {
    if (_themeProps == props) return;
    _themeProps = props;
    notifyListeners();
    onThemePropsChanged?.call(props);
  }

  void setFloatingNavigationBar(bool floating) {
    if (_floatingNavigationBar == floating) return;
    _floatingNavigationBar = floating;
    notifyListeners();
    onFloatingNavigationBarChanged?.call(floating);
  }

  void setTabAnimation(TabAnimation animation) {
    if (_tabAnimation == animation) return;
    _tabAnimation = animation;
    notifyListeners();
    onTabAnimationChanged?.call(animation);
  }

  void setDynamicColor(DynamicColorSeeds seeds) {
    if (_dynamicColor == seeds) return;
    _dynamicColor = seeds;
    notifyListeners();
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('ThemeScope not found above context.');
    }
    return scope.notifier!;
  }

  static ThemeController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ThemeScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('ThemeScope not found above context.');
    }
    return scope.notifier!;
  }

  static ThemeController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()?.notifier;
  }
}
