import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'demos.dart';
import 'section.dart';
import 'app_pages.dart';

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});
  @override
  Widget build(BuildContext context) => ApplicationShowcase(
    catalogBuilder: (settings) => GalleryHome(onSettings: settings),
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
