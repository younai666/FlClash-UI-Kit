"""Reproduce shell, appearance, hotkey, profile and metadata presentation views.

Provider/service access is replaced with the existing host-owned scopes. The
original layout, focus handling, gestures and motion remain in the source body.
"""
import re


class Adaptation:
    def __init__(self, base, source, imports):
        self.source = source
        self.code = (base / source).read_text(encoding='utf-8')
        self.changes = []
        matches = list(re.finditer(r'^import .*?;\n', self.code, re.M))
        header = self.code[:matches[-1].end()]
        self.replace(header, imports + '\n')

    def replace(self, old, new):
        if old not in self.code:
            raise ValueError(f'{self.source}: missing adaptation: {old[:120]}')
        self.code = self.code.replace(old, new)
        self.changes.append((old, new))

    def sub(self, pattern, replacement):
        for match in list(re.finditer(pattern, self.code, re.S)):
            old = match.group()
            if old in self.code:
                self.replace(old, replacement(match) if callable(replacement) else replacement)

    def calls(self, method, transform):
        pattern = rf'ref\s*\.\s*{method}\('
        while (match := re.search(pattern, self.code)) is not None:
            end = match.end()
            depth = 1
            while depth:
                char = self.code[end]
                depth += (char == '(') - (char == ')')
                end += 1
            body = self.code[match.end():end - 1]
            self.replace(self.code[match.start():end], transform(re.sub(r'\s+', ' ', body).strip().rstrip(',').strip()))

    def common(self):
        for old, new in [
            ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
            ('extends ConsumerWidget', 'extends StatelessWidget'),
            ('Widget build(BuildContext context, WidgetRef ref)', 'Widget build(BuildContext context)'),
            ('BuildContext context, WidgetRef ref,', 'BuildContext context,'),
            ('BuildContext context, WidgetRef ref)', 'BuildContext context)'),
            ('BuildContext context, ref)', 'BuildContext context)'),
            ('WidgetRef ref', 'BuildContext context'),
            ('context.appLocalizations', 'KitLocalizations.of(context)'),
            ('AppLocalizations', 'KitLocalizations'),
            ('Consumer(', 'Builder('), ('builder: (_, ref, _)', 'builder: (context)'),
            ('dialogs.showMessage(', 'showKitMessage(context, '),
            ('dialogs.showCommonDialog(', 'showFloatingDialog(context: context, '),
        ]:
            if old in self.code: self.replace(old, new)
        self.sub(r'\bref\b', 'context')
        self.sub(r'BuildContext context,\s*BuildContext context,', 'BuildContext context,')
        self.sub(r'context,\s*context\b', 'context')
        if 'context, \n' in self.code:
            self.replace('context, \n', 'context,\n')

    def save(self, register, target):
        register(self.source, target, self.changes, modified='2026-11-06')


WIDGETS = "import 'package:flutter/widgets.dart';\nimport 'package:flclash_ui_kit/flclash_ui_kit.dart';\n"


def register_views_extra(register, base):
    register('lib/common/keyboard.dart', 'hotkey/keyboard.dart', [
        ("import 'package:fl_clash/enum/enum.dart';", "import 'package:flutter/foundation.dart';\nimport 'models.dart';"),
        ("\nimport 'system.dart';\n", '\n'),
        ("  ShortcutLabels.host()\n    : this(isMacOS: system.isMacOS, isWindows: system.isWindows);",
         "  ShortcutLabels.host()\n    : this(\n        isMacOS: !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS,\n        isWindows: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows,\n      );"),
    ])
    register('test/common/keyboard_test.dart', '@test/common/keyboard_test.dart', [
        ("import 'package:fl_clash/common/keyboard.dart';\nimport 'package:fl_clash/enum/enum.dart';", "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
    ])
    register_home(register, base)
    register_theme(register, base)
    register_hotkey(register, base)
    register_about_tools(register, base)
    register_profiles(register, base)
    register_view_tests(register, base)


def register_home(register, base):
    a = Adaptation(base, 'lib/pages/home.dart', "import 'package:flutter/foundation.dart';\n" + WIDGETS)
    a.replace('''    final hasViewSize = ref.watch(
      viewSizeProvider.select((size) => !size.isEmpty),
    );''', '''    final shell = HomeShellScope.of(context);
    final hasViewSize = !shell.viewSizeOf(context).isEmpty && shell.currentNavigationItemsOf(context).isNotEmpty;''')
    a.replace('''              final navigationItems = ref
                  .watch(currentNavigationItemsStateProvider)
                  .value;
              final isMobile = ref.watch(isMobileViewProvider);''', '''              final shell = HomeShellScope.of(context);
              final navigationItems = shell.currentNavigationItemsOf(context);
              final isMobile = shell.viewModeOf(context) == ViewMode.mobile;''')
    a.replace('''  void _handleToPage(PageLabel pageLabel, WidgetRef ref) {
    ref.read(currentPageLabelProvider.notifier).toPage(pageLabel);
  }''', '''  void _handleToPage(Object pageLabel, BuildContext context) {
    HomeShellScope.read(context).openPage(pageLabel);
  }''')
    a.replace('ref.watch(navigationStateProvider)', 'HomeShellScope.of(context).navigationStateOf(context)')
    a.replace('''ref.watch(
      appSettingProvider.select((state) => state.floatingNavigationBar),
    )''', 'HomeShellScope.of(context).floatingNavigationBar')
    a.replace('item.label.label', 'item.titleOf(context)')
    start = a.code.index('    return Consumer(', a.code.index('class _NavigationPage'))
    end = a.code.index('\n  }\n}', start)
    a.replace(a.code[start:end], '''    final isActive = HomeShellScope.of(context).shownPageLabel(context) == item.label;
    return PageActivityScope(
      isActive: isActive,
      child: TickerMode(
        enabled: isActive,
        child: ExcludeFocus(
          excluding: !isActive,
          child: KeyboardInsetHold(child: keptView),
        ),
      ),
    );''')
    a.replace('ConsumerState createState()', 'State<_HomePageView> createState()')
    a.replace('''    ref.listenManual(currentPageLabelProvider, (prev, next) {
      if (prev != next) {
        _toPage(next);
      }
    });''', '''    _shell = HomeShellScope.read(context);
    _lastLabel = _shell.pageLabel;
    _shell.addListener(_handleShellChanged);''')
    a.replace('  List<int>? _order;', '''  late HomeShellController _shell;
  late Object _lastLabel;
  void _handleShellChanged() {
    if (_lastLabel == _shell.pageLabel) return;
    _lastLabel = _shell.pageLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) _toPage(_shell.pageLabel);
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = HomeShellScope.of(context);
    if (!identical(next, _shell)) {
      _shell.removeListener(_handleShellChanged);
      _shell = next;
      _shell.addListener(_handleShellChanged);
      _handleShellChanged();
    }
  }
  List<int>? _order;''')
    a.replace('List<PageLabel>', 'List<Object>')
    a.replace('PageLabel pageLabel', 'Object pageLabel')
    a.replace('ref.read(currentPageLabelProvider)', 'HomeShellScope.read(context).pageLabel')
    a.replace('ref.read(appSettingProvider).tabAnimation', 'HomeShellScope.read(context).tabAnimation')
    a.replace('ref.read(isMobileViewProvider)', '(HomeShellScope.read(context).viewModeOf(context) == ViewMode.mobile)')
    a.replace('''    final itemCount = ref.watch(
      currentNavigationItemsStateProvider.select((state) => state.value.length),
    );''', '    final itemCount = widget.navigationItems.length;')
    a.replace('''ref.watch(
      appSettingProvider.select(
        (state) => state.tabAnimation == TabAnimation.fade,
      ),
    )''', '(HomeShellScope.of(context).tabAnimation == TabAnimation.fade)')
    a.replace('ValueKey<PageLabel>', 'ValueKey<Object>')
    a.replace('GlobalObjectKey(item.label)', 'HomeShellScope.read(context).pageKeyOf(item.label)')
    a.replace('GlobalObjectKey(pageLabel).currentContext', 'HomeShellScope.read(context).pageKeyOf(pageLabel).currentContext')
    a.replace("${item.label.name}_navigator", "${item.label}_navigator")
    a.replace('    _pageController.dispose();', '    _shell.removeListener(_handleShellChanged);\n    _pageController.dispose();')
    a.replace('ref.read(shownPageLabelProvider)', 'HomeShellScope.read(context).shownPageLabel(context)')
    a.replace('system.isTV && pageLabel != PageLabel.dashboard', 'HomeShellScope.read(context).isTV && pageLabel != HomeShellScope.read(context).fallbackPageLabel')
    a.replace('''ref
              .read(currentPageLabelProvider.notifier)
              .toPage(PageLabel.dashboard);''', 'HomeShellScope.read(context).openPage(HomeShellScope.read(context).fallbackPageLabel);')
    a.replace('ref.read(systemActionProvider.notifier).handleClose()', 'HomeShellScope.read(context).requestExit()')
    a.common()
    a.save(register, 'shell/home.dart')

    source = (base / 'lib/manager/app_manager.dart').read_text(encoding='utf-8')
    prefix = WIDGETS
    changes = [
        ('ConsumerWidget', 'StatelessWidget'), ('Widget build(BuildContext context, WidgetRef ref)', 'Widget build(BuildContext context)'),
        ('''ref.watch(
      appSettingProvider.select((state) => state.sidebarExpanded),
    )''', 'HomeShellScope.of(context).sidebarExpanded'),
        ('ref.watch(versionProvider)', 'HomeShellScope.of(context).osVersion'),
        ('item.label.label', 'item.titleOf(context)'),
        ('''ref
                  .read(appSettingProvider.notifier)
                  .update(
                    (state) =>
                        state.copyWith(sidebarExpanded: !state.sidebarExpanded),
                  );''', 'final shell = HomeShellScope.read(context);\n              shell.setSidebarExpanded(!shell.sidebarExpanded);'),
        ('system.isMacOS', 'HomeShellScope.of(context).isMacOS'),
        ('''  void _updateSideBarWidth(WidgetRef ref, double contentWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value =
          ref.read(viewSizeProvider.select((state) => state.width)) -
          contentWidth;
    });
  }''', '''  void _updateSideBarWidth(BuildContext context, double contentWidth) {
    final shell = HomeShellScope.read(context);
    final width = shell.viewSizeOf(context).width - contentWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) shell.setSideWidth(width);
    });
  }'''),
        ('WidgetRef ref, PageLabel pageLabel', 'BuildContext context, Object pageLabel'),
        ('ref.read(currentPageLabelProvider.notifier).toPage(pageLabel)', 'HomeShellScope.read(context).openPage(pageLabel)'),
        ('ref.watch(navigationStateProvider)', 'HomeShellScope.of(context).navigationStateOf(context)'),
        ('ref.watch(windowBlurProvider)', 'HomeShellScope.of(context).backdropOpacity'),
        ('_handleToPage(ref,', '_handleToPage(context,'), ('_updateSideBarWidth(ref,', '_updateSideBarWidth(context,'),
    ]
    register('lib/manager/app_manager.dart', 'shell/sidebar.dart', changes,
             excerpt=('class _Sidebar ', None, prefix, 'Sidebar presentation only; app lifecycle/network/service managers remain in upstream'), modified='2026-11-06')


def register_theme(register, base):
    a = Adaptation(base, 'lib/views/theme.dart', "import 'dart:async';\nimport 'dart:math';\n" + WIDGETS)
    # The source's selector record is presentation state, not a new provider.
    start = a.code.index('    final themeColors = ref.watch(')
    end = a.code.index('\n    return Column(', start)
    a.replace(a.code[start:end], '''    final props = ThemeScope.of(context).themeProps;
    final themeColors = (
      primaryColor: props.primaryColor, primaryColors: props.primaryColors, colorStyle: props.colorStyle,
      isDefault: props.primaryColor == defaultPrimaryColor && intListEquality.equals(props.primaryColors, defaultPrimaryColors) && props.colorStyle == ColorStyle.vivid,
    );''')
    start = a.code.index('final _floatingBarProvider =')
    end = a.code.index('class _PureBlackItem', start)
    a.replace(a.code[start:end], '')
    a.replace('''selector: themeSettingProvider.select(
                (state) => state.sidebarBlur,
              ),
              onChanged: (ref, value) => ref
                  .read(themeSettingProvider.notifier)
                  .update((state) => state.copyWith(sidebarBlur: value)),''', '''value: ThemeScope.of(context).themeProps.sidebarBlur,
              onChanged: (value) => ThemeScope.read(context).updateThemeProps((state) => state.copyWith(sidebarBlur: value)),''')
    def watch(body):
        if body == '_floatingBarProvider': return 'ThemeScope.of(context).floatingNavigationBar'
        if body == '_liquidGlassProvider': return '(ThemeScope.of(context).themeProps.liquidGlass != LiquidGlassMode.none)'
        if body == 'dynamicColorProvider': return 'ThemeScope.of(context).dynamicColor'
        if body.startswith('genColorSchemeProvider('):
            return 'ThemeScope.of(context).colorSchemeFor(' + body[len('genColorSchemeProvider('):-1] + ')'
        match = re.fullmatch(r'(themeSettingProvider|appSettingProvider)\.select\(\(state\) => state\.(\w+),?\s*\)', body)
        if match:
            return 'ThemeScope.of(context).' + ('themeProps.' if match[1] == 'themeSettingProvider' else '') + match[2]
        raise ValueError('Unmapped theme watch: ' + body)
    a.calls('watch', watch)
    a.calls('read', lambda body: {'themeSettingProvider.notifier': 'ThemeScope.read(context)', 'themeSettingProvider': 'ThemeScope.read(context).themeProps', 'dynamicColorProvider': 'ThemeScope.read(context).dynamicColor', 'appSettingProvider.notifier': 'ThemeScope.read(context)'}[body])
    a.sub(r'ThemeScope\.read\(context\)\s*\.update\(', 'ThemeScope.read(context).updateThemeProps(')
    a.replace('ThemeScope.read(context).updateThemeProps((state) => state.copyWith(floatingNavigationBar: value))', 'ThemeScope.read(context).setFloatingNavigationBar(value)')
    a.replace('ThemeScope.read(context).updateThemeProps((state) => state.copyWith(tabAnimation: value))', 'ThemeScope.read(context).setTabAnimation(value)')
    a.replace('system.isMacOS || system.isWindows', 'ThemeScope.of(context).supportsSidebarBlur')
    a.replace('ThemeScope.read(context).dynamicColor.accentColor', 'ThemeScope.read(context).seedColorFor(Theme.of(context).brightness)')
    a.replace('const ThemeLivePreview()', '''ThemeLivePreview(
            floatingBar: ThemeScope.of(context).floatingNavigationBar,
            liquidGlass: ThemeScope.of(context).themeProps.liquidGlass != LiquidGlassMode.none,
            tabAnimation: ThemeScope.of(context).tabAnimation,
          )''')
    a.replace('style.label', 'style.labelOf(context)')
    a.common()
    a.save(register, 'theme/view.dart')

    a = Adaptation(base, 'lib/views/font_family.dart', "import 'dart:async';\nimport 'dart:collection';\nimport 'package:flutter/scheduler.dart';\n" + WIDGETS)
    a.replace('await loadSystemFontFamilies()', 'await ThemeScope.read(context).loadSystemFontFamilies()')
    a.replace('''selectedOf: (ref) => switch (ref.watch(
        themeSettingProvider.select((state) => state.fontFamily),
      ))''', 'selected: switch (ThemeScope.of(context).themeProps.fontFamily)')
    a.replace('''ref
            .read(themeSettingProvider.notifier)
            .update((state) => state.copyWith(fontFamily: family));''', 'ThemeScope.read(context).updateThemeProps((state) => state.copyWith(fontFamily: family));')
    a.common()
    a.save(register, 'theme/font_family.dart')


def register_hotkey(register, base):
    a = Adaptation(base, 'lib/views/hotkey.dart', "import 'package:flutter/services.dart';\n" + WIDGETS)
    start = a.code.index('Glyph _glyphOf(')
    end = a.code.index('List<(String, List<HotAction>)>', start)
    a.replace(a.code[start:end], '')
    a.replace('List<(String, List<HotAction>)>', 'List<(String, List<Object>)>')
    a.replace('''  final notifier = ref.read(hotKeyActionsProvider.notifier);
  notifier.value = _withBinding(notifier.value, binding);''', '''  final notifier = HotKeyScope.read(context);
  notifier.setActions(_withBinding(notifier.actions, binding));''')
    a.replace('final labels = ShortcutLabels.host();', 'final labels = HotKeyScope.of(context).labels;')
    a.replace('_sections(appLocalizations)', '(HotKeyScope.of(context).sectionsBuilder?.call(context) ?? _sections(appLocalizations))')
    a.replace('final HotAction action;', 'final Object action;')
    a.replace('ref.watch(getHotKeyActionProvider(action))', "HotKeyScope.of(context).actions.firstWhere((item) => item.action == action, orElse: () => HotKeyAction(action: action))")
    a.replace('''ref.watch(
      hotKeyFailuresProvider.select((state) => state[action]),
    )''', 'HotKeyScope.of(context).failures[action]')
    a.replace('_glyphOf(action)', 'HotKeyScope.of(context).glyphOfAction(action)')
    a.replace('action.label', 'HotKeyScope.of(context).labelOfAction(context, action)')
    a.replace('conflict.HotKeyScope.of(context).labelOfAction(context, action)', 'HotKeyScope.of(context).labelOfAction(context, conflict.action)')
    a.replace('widget.hotKeyAction.HotKeyScope.of(context).labelOfAction(context, action)', 'HotKeyScope.of(context).labelOfAction(context, widget.hotKeyAction.action)')
    a.replace('HotKeyRecording _recording', 'HotKeyController _recording')
    a.replace('ref.read(hotKeyRecordingProvider.notifier)', 'HotKeyScope.read(context)')
    a.replace('_recording.value = true', '_recording.setRecording(true)')
    a.replace('recording.value = false', 'recording.setRecording(false)')
    a.replace('ref.watch(hotKeyActionsProvider)', 'HotKeyScope.of(context).actions')
    a.common()
    a.save(register, 'hotkey/view.dart')


def register_about_tools(register, base):
    a = Adaptation(base, 'lib/views/about.dart', "import 'dart:async';\n" + WIDGETS)
    start = a.code.index('@immutable')
    end = a.code.index('class AboutView', start)
    a.replace(a.code[start:end], '')
    start = a.code.index('  const AboutView(')
    end = a.code.index('  Widget _buildLinkItem', start)
    a.replace(a.code[start:end], '''  const AboutView({super.key, required this.appName, required this.version,
    required this.description, required this.logo, this.licenseLabel = 'GPL-3.0',
    this.links = const [], this.contributors = const [], this.isCheckingUpdate = false,
    this.onCheckUpdate, this.onEnterDeveloperMode, this.onOpenUrl});
  final String appName, version, description, licenseLabel;
  final Widget logo;
  final List<AboutLink> links;
  final List<Contributor> contributors;
  final bool isCheckingUpdate;
  final VoidCallback? onCheckUpdate, onEnterDeveloperMode;
  final ValueChanged<String>? onOpenUrl;

''')
    a.replace('dialogs.openUrl(url);', 'onOpenUrl?.call(url);')
    a.replace('onTap: () {\n        onOpenUrl?.call(url);\n      },', 'onTap: onOpenUrl == null ? null : () => onOpenUrl!(url),')
    a.replace('ref.watch(loadingProvider(LoadingTag.checkUpdate))', 'isCheckingUpdate')
    start = a.code.index('          _AboutHero(')
    end = a.code.index('          const SizedBox(height: 8)', start)
    a.replace(a.code[start:end], '''          _AboutHero(
            appName: appName, version: version, description: description, logo: logo, licenseLabel: licenseLabel,
            isCheckingUpdate: isLoading, onCheckUpdate: onCheckUpdate,
            onEnterDeveloperMode: () => onEnterDeveloperMode?.call(),
          ),
''')
    start = a.code.index('              _buildLinkItem(')
    end = a.code.index('\n            ],', start)
    a.replace(a.code[start:end], '''              for (final link in links)
                _buildLinkItem(glyph: link.glyph, title: link.title, url: link.url, label: link.label),''')
    a.replace('_contributors', 'contributors')
    start = a.code.index('                    foregroundDecoration:')
    end = a.code.index('                    decoration:', start)
    a.replace(a.code[start:end], '''                    child: contributor.avatar ?? (contributor.avatarImage == null
                      ? Center(child: Text(contributor.name.characters.firstOrNull ?? '?'))
                      : ClipOval(child: Image(image: contributor.avatarImage!, fit: BoxFit.cover))),
''')
    a.replace('subtitle: Text(appLocalizations.appIconDesign)', 'subtitle: contributor.role == null ? null : Text(contributor.role!)')
    a.replace('final VoidCallback onCheckUpdate;', 'final VoidCallback? onCheckUpdate;\n  final String appName, version, description, licenseLabel;\n  final Widget logo;')
    a.replace('''    required this.isCheckingUpdate,''', '''    required this.appName, required this.version, required this.description, required this.licenseLabel, required this.logo,
    required this.isCheckingUpdate,''')
    start = a.code.index('child: Image.asset(')
    end = a.code.index('\n              ),', start)
    a.replace(a.code[start:end], 'child: SizedBox.square(dimension: _logoSize - _logoInset * 2, child: logo),')
    a.replace("'v${globalState.packageInfo.version}'", "'v$version'")
    a.replace("label: 'GPL-3.0'", 'label: licenseLabel')
    a.replace('appLocalizations.desc', 'description')
    a.replace('''                    child: contributor.avatar ?? (contributor.avatarImage == null
                      ? Center(child: Text(contributor.name.characters.firstOrNull ?? '?'))
                      : ClipOval(child: Image(image: contributor.avatarImage!, fit: BoxFit.cover))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorScheme.primaryContainer,
                    ),''', '''                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorScheme.primaryContainer,
                    ),
                    child: contributor.avatar ?? (contributor.avatarImage == null
                      ? Center(child: Text(contributor.name.characters.firstOrNull ?? '?'))
                      : ClipOval(child: Image(image: contributor.avatarImage!, fit: BoxFit.cover))),''')
    a.common()
    a.save(register, 'shell/about.dart')

    a = Adaptation(base, 'lib/views/tools.dart', WIDGETS)
    start = a.code.index('class _ThemeItem')
    a.replace(a.code[start:], '')
    a.replace('const ToolsView({super.key});', '''const ToolsView({super.key, this.settingsItems = const [], this.otherItems = const []});
  final List<Widget> settingsItems, otherItems;''')
    a.replace('navigationItem.label.label', 'navigationItem.titleOf(context)')
    a.replace('''        const _DisclaimerItem(),
        if (enableDeveloperMode) const _DeveloperItem(),
        const _InfoItem(),''', '        ...widget.otherItems,')
    start = a.code.index('        const _LocaleItem(),')
    end = a.code.index('\n      ],', start)
    a.replace(a.code[start:end], '''        const _LocaleItem(),
        if (ThemeScope.maybeOf(context) != null)
          ListItem.open(leading: const GlyphIcon(AppGlyphs.paintbrush), title: Text(KitLocalizations.of(context).theme), widget: const ThemeView()),
        if (HotKeyScope.maybeOf(context) != null)
          ListItem.open(leading: const GlyphIcon(AppGlyphs.keyboard), title: Text(KitLocalizations.of(context).hotkeyManagement), widget: const HotKeyView()),
        ...widget.settingsItems,''')
    a.replace('''ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    )''', 'HomeShellScope.of(context).developerMode')
    a.replace('ref.watch(moreToolsSelectorStateProvider)', '(navigationItems: HomeShellScope.of(context).moreNavigationItemsOf(context))')
    a.replace('''ref.watch(
      appSettingProvider.select((state) => state.locale),
    )''', 'HomeShellScope.of(context).locale')
    a.replace('getLocaleForString(locale)', 'locale')
    a.replace('locale.label', 'locale.labelOf(context)')
    a.replace('AppLocalizations.delegate.supportedLocales', 'HomeShellScope.of(context).supportedLocales')
    a.replace('''ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(locale: locale?.toString()));''', 'HomeShellScope.read(context).setLocale(locale);')
    a.common()
    a.replace('      value: currentLocale,\n    );\n  }\n}\n\n',
              '      value: currentLocale,\n    );\n  }\n}\n')
    a.save(register, 'shell/tools.dart')


def register_profiles(register, base):
    register('lib/models/profile.dart', 'profiles/subscription_extensions.dart', [
        ('expire * 1000) : null;\n}\n\n', 'expire * 1000) : null;\n}\n'),
    ],
      excerpt=('extension SubscriptionInfoExt ', '@freezed', "import '../data.dart';\n", 'Subscription usage and expiry projections; persistence remains upstream'), modified='2026-11-06')
    a = Adaptation(base, 'lib/views/profiles/profiles.dart', "import 'dart:async';\nimport 'package:flutter/services.dart';\n" + WIDGETS)
    a.replace('double get _profileItemHeight {\n  final measure = globalState.measure;', 'double _profileItemHeight(BuildContext context) {\n  final measure = MeasureScope.of(context);')
    a.replace('final height = _profileItemHeight;', 'final height = _profileItemHeight(context);')
    a.replace('mainAxisExtent: _profileItemHeight,', 'mainAxisExtent: _profileItemHeight(context),')
    a.replace('minTileHeight: _profileItemHeight,', 'minTileHeight: _profileItemHeight(context),')
    start = a.code.index('    final profilesAction = ref.read(profilesActionProvider.notifier);')
    end = a.code.index('\n    _isUpdating = false;', start)
    a.replace(a.code[start:end + len('\n    _isUpdating = false;')], '''    try {
      final messages = await ProfilesScope.read(context).updateAllProfiles();
      if (mounted) showKitFailures(context, messages);
    } catch (error) {
      if (mounted) await showKitMessage(context, message: TextSpan(text: error.toString()), title: appLocalizations.tip);
    } finally {
      _isUpdating = false;
    }''')
    a.replace('''final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));''', 'final isLoading = ProfilesScope.of(context).isLoading;')
    a.replace('ref.watch(profilesStateProvider)', 'ProfilesScope.of(context)')
    a.replace('ref.watch(viewModeProvider)', 'ProfilesScope.of(context).viewModeOf(context)')
    a.replace('ref.read(currentProfileIdProvider.notifier).value = profileId;', 'if (profileId != null) ProfilesScope.read(context).selectProfile(profileId);')
    a.replace('ref.read(profilesActionProvider.notifier)', 'ProfilesScope.read(context)')
    a.replace('profilesAction.providerUsers(profile)', 'profilesAction.checkProviderUsers(profile)')
    a.replace('final users = await profilesAction.checkProviderUsers(profile);', 'final users = await profilesAction.checkProviderUsers(profile);\n    if (!context.mounted) return;')
    start = a.code.index('    unawaited(\n      BaseNavigator.push<String>')
    end = a.code.index('\n  SubscriptionInfo? get', start)
    a.replace(a.code[start:end], '''    await ProfilesScope.read(context).onPreviewProfile?.call(context, profile);
  }

  Future<void> updateProfile(BuildContext context) async {
    if (profile.type != ProfileType.url) return;
    try {
      final failure = await ProfilesScope.read(context).updateSingleProfile(profile);
      if (context.mounted && failure != null) showKitFailures(context, [failure]);
    } catch (error) {
      if (context.mounted) await showKitMessage(context, message: TextSpan(text: error.toString()));
    }
  }

  void _handleShowEditExtendPage(BuildContext context) {
    ProfilesScope.read(context).onEditProfile?.call(context, profile);
  }
''')
    a.replace('''dialogs.showBanner(
        context.appLocalizations.copySuccess,
        level: BannerLevel.success,
      );''', 'BannerHost.maybeOf(context)?.show(KitLocalizations.of(context).copySuccess, level: BannerLevel.success);')
    start = a.code.index('    final res = await globalState.safeRun<bool>')
    end = a.code.index('\n  void _handleEdit(', start)
    a.replace(a.code[start:end], '''    final result = await ProfilesScope.read(context).onExportProfile?.call(profile);
    if (result == true && context.mounted) {
      BannerHost.maybeOf(context)?.show(appLocalizations.exportSuccess, level: BannerLevel.success);
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    ProfilesScope.read(context).onExtendProfile?.call(context, profile);
  }
  void _handlePushCustomProfilePage(BuildContext context, int id) {
    ProfilesScope.read(context).onEditCustomProfile?.call(context, profile);
  }
''')
    a.replace('renameProfile(context, ref, profile)', 'renameKitProfile(context, profile)')
    a.replace('dialogs.showQrCode(', 'showKitQrCode(context, ')
    a.replace('ref.watch(isUpdatingProvider(profile.updatingKey))', 'ProfilesScope.of(context).isUpdating(profile.updatingKey)')
    a.replace('ref.watch(profileGroupsCountProvider(profileId)).value', 'ProfilesScope.of(context).groupsCountOf(profileId)')
    a.replace('ref.read(profilesProvider)', 'ProfilesScope.read(context).profiles')
    a.replace('ref.read(profilesProvider.notifier).reorder', 'ProfilesScope.read(context).reorder')
    # Keep menu entries visible, but never simulate unavailable host workflows.
    a.replace('onPressed: () => _handleEdit(context),', '''onPressed: (profile.type == ProfileType.custom ? ProfilesScope.of(context).onEditCustomProfile : ProfilesScope.of(context).onEditProfile) == null ? null : () => _handleEdit(context),''')
    a.replace('''onPressed: () {
            _handlePushGenProfilePage(context, profile.id);
          },''', '''onPressed: ProfilesScope.of(context).onExtendProfile == null ? null : () {
            _handlePushGenProfilePage(context, profile.id);
          },''')
    a.replace('''onPressed: () {
            updateProfile(ref);
          },''', '''onPressed: ProfilesScope.of(context).onUpdateProfile == null ? null : () {
            updateProfile(context);
          },''')
    a.sub(r'onPressed: \(\) \{\s*_handlePreview\(context\);\s*\}', 'onPressed: ProfilesScope.of(context).onPreviewProfile == null ? null : () => _handlePreview(context)')
    a.replace('''onPressed: () {
                _handleExportFile(context);
              },''', '''onPressed: ProfilesScope.of(context).onExportProfile == null ? null : () {
                _handleExportFile(context);
              },''')
    a.replace('''onPressed: () {
                _updateProfiles(profiles);
              },''', '''onPressed: ProfilesScope.of(context).onUpdateProfile == null && ProfilesScope.of(context).onUpdateProfiles == null ? null : () {
                _updateProfiles(profiles);
              },''')
    a.common()
    a.save(register, 'profiles/view.dart')

    a = Adaptation(base, 'lib/views/profiles/add.dart', "import 'dart:async';\n" + WIDGETS)
    a.replace('ref.read(profilesActionProvider.notifier)', 'ProfilesScope.read(context)')
    a.replace('addProfileFormFile()', 'addProfileFromFile()')
    start = a.code.index('    final profilesAction = ProfilesScope.read(context);', a.code.index('Future<void> _toScan'))
    end = a.code.index('\n  Future<void> _toAdd(', start)
    a.replace(a.code[start:end], '''    final profilesAction = ProfilesScope.read(context);
    final url = await profilesAction.scanQrCode();
    if (url == null || !context.mounted) return;
    await whenRouteUncovered(context);
    if (context.mounted) await profilesAction.addProfileFromLink(url);
  }
''')
    a.replace('ref.read(profilesProvider)', 'ProfilesScope.read(context).profiles')
    start = a.code.index('    if (!(await app?.requestLocalNetworkPermission()')
    end = a.code.index('    final link = await dialogs.showCommonDialog<String>(', start)
    a.replace(a.code[start:end], '')
    a.replace('currentAppLocalizations', 'KitLocalizations.of(context)')
    a.replace('if (link == null) {', 'if (link == null || !context.mounted) {')
    a.replace('dialogs.showCommonDialog<String>(', 'showFloatingDialog<String>(context: context, ')
    start = a.code.index('    final profileId = ref', a.code.index('  void _toAddCustom'))
    end = a.code.index('\n  @override', start)
    a.replace(a.code[start:end], '''    unawaited(ProfilesScope.read(context).addCustomProfile(KitLocalizations.of(context).unnamed));
  }
''')
    a.replace('system.isTV', 'ProfilesScope.of(context).isTV && ProfilesScope.of(context).startPhoneLinkReceiver != null')
    a.replace('LinkReceiver? _receiver;', 'PhoneLinkSession? _receiver;')
    start = a.code.index('    final appLocalizations = KitLocalizations.of(context);', a.code.index('  Future<void> _start()'))
    end = a.code.index('    if (!mounted)', start)
    a.replace(a.code[start:end], '''    PhoneLinkSession? receiver;
    try {
      receiver = await ProfilesScope.read(context).startPhoneLinkReceiver?.call();
    } catch (_) {
      receiver = null;
    }
''')
    a.replace('bool _failed = false;', 'bool _failed = false;\n  Object? _error;')
    start = a.code.index('    PhoneLinkSession? receiver;', a.code.index('  Future<void> _start()'))
    end = a.code.index('\n  @override', start)
    a.replace(a.code[start:end], '''    try {
      final receiver = await ProfilesScope.read(context).startPhoneLinkReceiver?.call();
      if (!mounted) {
        await receiver?.close();
        return;
      }
      setState(() {
        _receiver = receiver;
        _failed = receiver == null;
      });
      final link = await receiver?.link;
      if (link != null && mounted) Navigator.of(context).pop(link);
    } catch (error) {
      if (mounted) setState(() { _failed = true; _error = error; });
    }
  }
''')
    a.replace('appLocalizations.sendFromPhoneNoNetwork,', '_error?.toString() ?? appLocalizations.sendFromPhoneNoNetwork,')
    # Method tear-off is a record field: invoke it, not an OS service.
    a.replace('onPressed: () => _toScan(context, ref),', 'onPressed: ProfilesScope.of(context).onScanQrCode == null ? null : () => _toScan(context),')
    a.replace('onPressed: () => _handleAddProfileFormFile(ref),', 'onPressed: ProfilesScope.of(context).onAddFromFile == null ? null : () => _handleAddProfileFormFile(context),')
    a.common()
    a.save(register, 'profiles/add.dart')



def register_view_tests(register, base):
    imports = "import 'package:flutter_test/flutter_test.dart';\nimport 'package:flutter/services.dart';\n" + WIDGETS
    a = Adaptation(base, 'test/views/hotkey_view_test.dart', imports)
    start = a.code.index('ProviderContainer _containerFor(')
    end = a.code.index('Future<void> _press(', start)
    a.replace(a.code[start:end], '''HotKeyController _containerFor(WidgetTester tester, {List<HotKeyAction> hotKeyActions = const []}) {
  tester.view.physicalSize = const Size(1400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = HotKeyController(actions: hotKeyActions, labels: _labels);
  addTearDown(controller.dispose);
  return controller;
}
Widget _host(HotKeyController controller, Widget home) => KitApp(
  locale: const Locale('en'),
  builder: (_, child) => HotKeyScope(controller: controller, child: child!),
  home: home,
);
Future<void> _pumpView(WidgetTester tester, HotKeyController container) async {
  await tester.pumpWidget(_host(container, const HotKeyView()));
  await tester.pumpAndSettle();
}
Future<void> _pumpRecorder(WidgetTester tester, HotKeyController container, HotKeyAction action) async {
  await tester.pumpWidget(_host(container, Builder(builder: (context) => TextButton(
    onPressed: () => showFloatingDialog<void>(context: context,
      child: HotKeyRecorder(hotKeyAction: action, labels: _labels)),
    child: const Text('open'),
  ))));
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

''')
    a.replace('container.read(hotKeyActionsProvider)', 'container.actions')
    a.replace('container.read(hotKeyRecordingProvider)', 'container.isRecording')
    a.replace("container.read(hotKeyFailuresProvider.notifier).value = {\n        HotAction.view: 'already registered',\n      };", "container.setFailures({HotAction.view: 'already registered'});")
    a.replace('currentAppLocalizations.', "const KitLocalizations(Locale('en')).")
    a.replace('action.label', '_label(tester, action)')
    a.replace('HotAction.start.label', '_label(tester, HotAction.start)')
    a.replace('void main() {', 'String _label(WidgetTester tester, HotAction action) => action.labelOf(tester.element(find.byType(HotKeyScope)));\n\nvoid main() {')
    a.save(register, '@test/views/hotkey_view_test.dart')

    a = Adaptation(base, 'test/views/theme_test.dart', "import 'dart:async';\nimport 'dart:io';\nimport 'package:flutter_test/flutter_test.dart';\n" + WIDGETS)
    start = a.code.index('  late ProviderContainer container;')
    end = a.code.index("  group('theme mode'", start)
    a.replace(a.code[start:end], '''  late ThemeController container;
  setUp(() => container = ThemeController(supportsSidebarBlur: Platform.isMacOS || Platform.isWindows));
  tearDown(() => container.dispose());
  Widget host() => KitApp(locale: const Locale('en'),
    builder: (_, child) => ThemeScope(controller: container, child: child!),
    home: const ThemeView());
  Future<void> pumpThemeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
  }
  ThemeProps readTheme() => container.themeProps;

''')
    a.sub(r'container\s*\.read\(themeSettingProvider.notifier\)\s*\.update\(', 'container.updateThemeProps(')
    a.replace('      container.read(viewSizeProvider.notifier).value = size;\n', '')
    a.replace('''        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ThemeView()),
        ),''', '        host(),')
    a.replace('AppSettingProps readSetting() => container.read(appSettingProvider);', 'ThemeController readSetting() => container;')
    a.replace('state.copyWith.textScale(enable: true, scale: 1.2)', 'state.copyWith(textScale: state.textScale.copyWith(enable: true, scale: 1.2))')
    a.save(register, '@test/views/theme_test.dart')
