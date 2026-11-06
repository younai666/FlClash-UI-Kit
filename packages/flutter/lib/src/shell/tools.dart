// Derived from chen08209/FlClash, lib/views/tools.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


class ToolsView extends StatefulWidget {
  const ToolsView({super.key, this.settingsItems = const [], this.otherItems = const []});
  final List<Widget> settingsItems, otherItems;

  @override
  State<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends State<ToolsView> {
  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: GlyphIcon(navigationItem.glyph),
      title: Text(navigationItem.titleOf(context)),
      widget: navigationItem.builder(context),
      forceFull: navigationItem.modes.contains(NavigationItemMode.moreFull),
    );
  }

  Widget _getOtherList(bool enableDeveloperMode) {
    return generateSection(
      title: KitLocalizations.of(context).other,
      items: [
        if (widget.otherItems.isEmpty) ...const [
          _DisclaimerItem(),
        ],
        ...widget.otherItems,
      ],
    );
  }

  Widget _getSettingList() {
    return generateSection(
      title: KitLocalizations.of(context).settings,
      items: [
        const _LocaleItem(),
        if (ThemeScope.maybeOf(context) != null)
          ListItem.open(leading: const GlyphIcon(AppGlyphs.paintbrush), title: Text(KitLocalizations.of(context).theme), widget: const ThemeView()),
        if (HotKeyScope.maybeOf(context) != null)
          ListItem.open(leading: const GlyphIcon(AppGlyphs.keyboard), title: Text(KitLocalizations.of(context).hotkeyManagement), widget: const HotKeyView()),
        ...widget.settingsItems,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final developerMode = HomeShellScope.of(context).developerMode;
    final items = [
      Builder(
        builder: (context) {
          final state = (navigationItems: HomeShellScope.of(context).moreNavigationItemsOf(context));
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return generateSection(
            items: state.navigationItems.map(_buildNavigationMenuItem),
          );
        },
      ),
      _getSettingList(),
      _getOtherList(developerMode),
    ];
    return Scaffold(
      title: KitLocalizations.of(context).tools,
      body: Builder(
        builder: (context) => PrismListView(
          key: toolsStoreKey,
          itemCount: items.length,
          itemBuilder: (_, index) => items[index],
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: context.sectionsTopPadding,
            bottom: 20 + context.bottomInset,
          ),
        ),
      ),
    );
  }
}

class _LocaleItem extends StatelessWidget {
  const _LocaleItem();

  String _getLocaleString(BuildContext context, Locale? locale) {
    if (locale == null) return KitLocalizations.of(context).defaultText;
    return locale.labelOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = HomeShellScope.of(context).locale;
    final currentLocale = locale;
    return ListItem<Locale?>.options(
      leading: const GlyphIcon(AppGlyphs.language),
      title: Text(KitLocalizations.of(context).language),
      options: [null, ...HomeShellScope.of(context).supportedLocales],
      onChanged: (Locale? locale) {
        HomeShellScope.read(context).setLocale(locale);
      },
      textBuilder: (locale) => _getLocaleString(context, locale),
      value: currentLocale,
    );
  }
}
class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const GlyphIcon(AppGlyphs.gavel),
      title: Text(KitLocalizations.of(context).disclaimer),
      widget: const DisclaimerView(),
    );
  }
}
