import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'demos.dart';
import 'section.dart';

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});
  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _mode = ThemeMode.light;
  ColorStyle _style = ColorStyle.vivid;
  LiquidGlassQuality? _glass;
  bool _pureBlack = false;
  bool _reduceMotion = false;
  final _seed = ValueNotifier(const Color(0xFF007AFF));

  @override
  void dispose() {
    _seed.dispose();
    super.dispose();
  }

  Future<void> _settings(BuildContext context) => showFormSheet<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) {
        void change(VoidCallback action) {
          setState(action);
          update(() {});
        }

        return Scaffold(
          title: '外观与辅助功能',
          body: Builder(
            builder: (context) => ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                20,
                context.contentTopPadding + 16,
                20,
                32,
              ),
              children: [
                generateSection(
                  items: [
                    ListItem<ThemeMode>.options(
                      title: const Text('明暗主题'),
                      options: ThemeMode.values,
                      value: _mode,
                      textBuilder: (v) => v.name,
                      onChanged: (v) => change(() => _mode = v),
                    ),
                    ListItem<ColorStyle>.options(
                      title: const Text('色彩风格'),
                      options: ColorStyle.values,
                      value: _style,
                      textBuilder: (v) => v.name,
                      onChanged: (v) => change(() => _style = v),
                    ),
                    ListItem<int>.options(
                      title: const Text('Liquid Glass'),
                      options: const [0, 1, 2],
                      value: _glass == null ? 0 : _glass!.index + 1,
                      textBuilder: (v) => ['关闭', 'standard', 'ultra'][v],
                      onChanged: (v) => change(
                        () => _glass = v == 0
                            ? null
                            : LiquidGlassQuality.values[v - 1],
                      ),
                    ),
                    ListItem.toggle(
                      title: const Text('纯黑背景'),
                      value: _pureBlack,
                      onChanged: (v) => change(() => _pureBlack = v),
                    ),
                    ListItem.toggle(
                      title: const Text('减少动态效果'),
                      value: _reduceMotion,
                      onChanged: (v) => change(() => _reduceMotion = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Palette(controller: _seed),
                ValueListenableBuilder(
                  valueListenable: _seed,
                  builder: (_, value, _) => HexColorField(
                    color: value,
                    onChanged: (color) => _seed.value = color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _seed,
    builder: (_, seed, _) => KitApp(
      seedColor: seed,
      colorStyle: _style,
      pureBlack: _pureBlack,
      themeMode: _mode,
      liquidGlass: _glass,
      locale: const Locale('zh'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: _reduceMotion),
        child: child!,
      ),
      home: GalleryHome(onSettings: _settings),
    ),
  );
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.onSettings});
  final void Function(BuildContext context) onSettings;
  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  var _index = 0;
  var _expanded = true;
  var _query = SearchQuery('');

  @override
  Widget build(BuildContext context) {
    final settings = IconButtonData(
      glyph: AppGlyphs.settings,
      tooltip: '外观设置',
      onPressed: () => widget.onSettings(context),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Surface(
            color: context.colorScheme.surface,
            child: Row(
              children: [
                NavigationSidebar(
                  expanded: _expanded,
                  onToggle: () => setState(() => _expanded = !_expanded),
                  destinations: [
                    for (final demo in demos)
                      SidebarDestination(glyph: demo.glyph, label: demo.title),
                  ],
                  selectedIndex: _index,
                  onSelected: (index) => setState(() => _index = index),
                ),
                Expanded(
                  child: DemoPage(
                    key: ValueKey(_index),
                    demo: demos[_index],
                    actions: [settings],
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          title: 'FlClash UI Kit',
          primaryAction: settings,
          searchState: AppBarSearchState(
            onSearch: (query) => setState(() => _query = SearchQuery(query)),
          ),
          body: Builder(
            builder: (context) => ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                context.contentTopPadding + 12,
                16,
                32,
              ),
              children: [
                const Text('原生组件 · 可交互动效 · 可检索源码'),
                const SizedBox(height: 20),
                generateSection(
                  items: [
                    for (final demo in demos.where(
                      (d) => _query.matches([d.title, d.keywords]),
                    ))
                      ListItem.open(
                        leading: GlyphIcon(demo.glyph),
                        title: Text(demo.title),
                        subtitle: Text(demo.keywords),
                        widget: DemoPage(demo: demo),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
