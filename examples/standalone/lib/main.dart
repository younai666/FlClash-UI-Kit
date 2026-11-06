import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() => runApp(const WorkspaceApp());

/// Arbitrary page/action IDs, local presets, and host-owned state. No proxy
/// engine, persistence, OS services, optional native packages or upstream tree.
class WorkspaceApp extends StatefulWidget {
  const WorkspaceApp({super.key});
  @override
  State<WorkspaceApp> createState() => _WorkspaceAppState();
}

class _WorkspaceAppState extends State<WorkspaceApp> {
  late final HomeShellController shell;
  late final ThemeController appearance;
  final presets = ProfilesController(
    profiles: [Profile.custom(label: 'Writing layout')],
  );
  final shortcuts = HotKeyController(
    actions: const [],
    sectionsBuilder: (_) => [
      ('Workspace', ['create-note']),
    ],
    actionLabelBuilder: (_, _) => 'Create note',
  );
  final text = TextEditingController();
  var count = 0;
  @override
  void initState() {
    super.initState();
    shell = HomeShellController(
      pageLabel: 'notes',
      fallbackPageLabel: 'notes',
      navigationItems: [
        NavigationItem(
          label: 'notes',
          title: 'Notes',
          glyph: AppGlyphs.edit,
          builder: _notes,
        ),
        NavigationItem(
          label: 'presets',
          title: 'Layouts',
          glyph: AppGlyphs.layers,
          builder: (_) => const ProfilesView(),
        ),
        NavigationItem(
          label: 'tools',
          title: 'Tools',
          glyph: AppGlyphs.tools,
          builder: (_) => const ToolsView(),
        ),
      ],
    );
    appearance = ThemeController(
      onFloatingNavigationBarChanged: shell.setFloatingNavigationBar,
      onTabAnimationChanged: shell.setTabAnimation,
    );
  }

  Widget _notes(BuildContext context) => Scaffold(
    title: 'Notes',
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(controller: text),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => setState(() => count++),
            child: Text('Add note ($count)'),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([appearance, shell]),
    builder: (_, _) {
      final props = appearance.themeProps;
      return KitApp(
        locale: const Locale('en'),
        themeMode: props.themeMode,
        seedColor: appearance.seedColorFor(Brightness.light),
        colorStyle: props.colorStyle,
        pureBlack: props.pureBlack,
        liquidGlass: props.liquidGlass.toQuality,
        fontFamily: props.fontFamily,
        textScale: props.textScale.enable ? props.textScale.scale : null,
        builder: (_, child) => HomeShellScope(
          controller: shell,
          child: ThemeScope(
            controller: appearance,
            child: ProfilesScope(
              controller: presets,
              child: HotKeyScope(controller: shortcuts, child: child!),
            ),
          ),
        ),
        // The Notes builder closes over count, so rebuild the shell with the host.
        home: HomePage(),
      );
    },
  );
  @override
  void dispose() {
    shell.dispose();
    appearance.dispose();
    presets.dispose();
    shortcuts.dispose();
    text.dispose();
    super.dispose();
  }
}
