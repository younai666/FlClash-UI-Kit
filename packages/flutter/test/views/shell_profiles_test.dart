// Behavior coverage derived from upstream test/pages/home_test.dart,
// test/widgets/profile_focus_test.dart and test/views/add_profile_view_test.dart.
// GPL-3.0; adapted 2026-11-06 to explicit host scopes and arbitrary identifiers.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import '../helpers/glyph_finders.dart';

void viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget host(
  Widget page, {
  HomeShellController? shell,
  ProfilesController? profiles,
  ThemeController? theme,
  HotKeyController? keys,
}) => KitApp(
  locale: const Locale('en'),
  builder: (_, child) {
    Widget current = child!;
    if (keys != null) current = HotKeyScope(controller: keys, child: current);
    if (theme != null) current = ThemeScope(controller: theme, child: current);
    if (profiles != null) {
      current = ProfilesScope(controller: profiles, child: current);
    }
    if (shell != null) {
      current = HomeShellScope(controller: shell, child: current);
    }
    return current;
  },
  home: page,
);
List<NavigationItem> destinations() => [
  for (final id in ['First', 'Second', 'Third', 'Fourth'])
    NavigationItem(
      label: id,
      title: id,
      glyph: AppGlyphs.layers,
      builder: (_) => Scaffold(
        title: id,
        body: Center(child: TextField(key: ValueKey('input-$id'))),
      ),
    ),
];
void main() {
  for (final size in [const Size(390, 844), const Size(1200, 850)]) {
    testWidgets('home uses custom identifiers and preserves edits at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final shell = HomeShellController(
        navigationItems: destinations(),
        pageLabel: 'First',
      );
      addTearDown(shell.dispose);
      await tester.pumpWidget(host(const HomePage(), shell: shell));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('input-First')), 'kept');
      shell.openPage('Fourth');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('input-Fourth')), findsOneWidget);
      shell.openPage('First');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        tester
                .widget<TextField>(find.byKey(const ValueKey('input-First')))
                .controller
                ?.text ??
            tester
                .widget<EditableText>(
                  find.descendant(
                    of: find.byKey(const ValueKey('input-First')),
                    matching: find.byType(EditableText),
                  ),
                )
                .controller
                .text,
        'kept',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('sidebar expansion and mobile dock use the same host state', (
    tester,
  ) async {
    viewport(tester, const Size(1280, 900));
    final shell = HomeShellController(
      navigationItems: destinations(),
      pageLabel: 'First',
    );
    addTearDown(shell.dispose);
    await tester.pumpWidget(host(const HomePage(), shell: shell));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationSidebar>(find.byType(NavigationSidebar)).expanded,
      isTrue,
    );
    tester
        .widget<NavigationSidebar>(find.byType(NavigationSidebar))
        .onToggle!();
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationSidebar>(find.byType(NavigationSidebar)).expanded,
      isFalse,
    );
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDock), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationDock),
        matching: find.text('Second'),
      ),
    );
    await tester.pumpAndSettle();
    expect(shell.pageLabel, 'Second');
    shell.setFloatingNavigationBar(false);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDock), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('navigation insertion, removal and empty lists stay valid', (
    tester,
  ) async {
    viewport(tester, const Size(1200, 850));
    final items = destinations();
    final shell = HomeShellController(
      navigationItems: items,
      pageLabel: 'Second',
    );
    addTearDown(shell.dispose);
    await tester.pumpWidget(host(const HomePage(), shell: shell));
    await tester.pumpAndSettle();
    shell.setNavigationItems([items[3], ...items.take(3)]);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('input-Second')), findsOneWidget);
    shell.setNavigationItems([items.first]);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('input-First')), findsOneWidget);
    shell.setNavigationItems([]);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationSidebar), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'independent shell instances can use equal destination identifiers',
    (tester) async {
      viewport(tester, const Size(1400, 900));
      final a = HomeShellController(
        navigationItems: destinations().take(1).toList(),
        pageLabel: 'First',
      );
      final b = HomeShellController(
        navigationItems: destinations().take(1).toList(),
        pageLabel: 'First',
      );
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await tester.pumpWidget(
        KitApp(
          home: Row(
            children: [
              Expanded(
                child: HomeShellScope(controller: a, child: const HomePage()),
              ),
              Expanded(
                child: HomeShellScope(controller: b, child: const HomePage()),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('profiles select a card and expose custom group counts', (
    tester,
  ) async {
    viewport(tester, const Size(900, 800));
    final first = Profile.normal(label: 'Daily');
    final second = Profile.custom(label: 'Lab');
    final selected = <int>[];
    final profiles = ProfilesController(
      profiles: [first, second],
      currentProfileId: first.id,
      profileGroupsCounts: {second.id: 7},
      onSelectProfile: selected.add,
    );
    addTearDown(profiles.dispose);
    await tester.pumpWidget(host(const ProfilesView(), profiles: profiles));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    expect(profiles.currentProfileId, second.id);
    expect(selected, [second.id]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'profile reorder keeps the latest objects and newly added profiles',
    (tester) async {
      viewport(tester, const Size(900, 800));
      final first = Profile.normal(label: 'One');
      final second = Profile.normal(label: 'Two');
      final extra = Profile.normal(label: 'Added');
      final profiles = ProfilesController(profiles: [first, second]);
      addTearDown(profiles.dispose);
      await tester.pumpWidget(
        host(
          ReorderableProfilesSheet(profiles: [second, first]),
          profiles: profiles,
        ),
      );
      await tester.pumpAndSettle();
      profiles.setProfiles([first.copyWith(label: 'Renamed'), second, extra]);
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();
      expect(profiles.profiles.map((p) => p.realLabel), [
        'Two',
        'Renamed',
        'Added',
      ]);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('link form validates, then dispatches a named URL to the host', (
    tester,
  ) async {
    viewport(tester, const Size(1200, 1000));
    final added = <String>[];
    final profiles = ProfilesController(
      onAddFromLink: (url, {label, ageSecretKey = ''}) {
        added.add(url);
      },
    );
    addTearDown(profiles.dispose);
    await tester.pumpWidget(host(const ProfilesView(), profiles: profiles));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.widgetWithText(FormRow, 'Link'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(field, 'bad link');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(added, isEmpty);
    await tester.enterText(field, 'https://example.com/catalog');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(added, ['https://example.com/catalog']);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test(
    'missing update callback cannot manufacture a successful sync',
    () async {
      final profile = Profile.normal(
        label: 'Remote',
        url: 'https://example.com/sub',
      );
      final controller = ProfilesController(profiles: [profile]);
      addTearDown(controller.dispose);
      await expectLater(
        controller.updateSingleProfile(profile),
        throwsUnsupportedError,
      );
      expect(controller.profiles.single.lastUpdateDate, profile.lastUpdateDate);
      expect(controller.updatingKeys, isEmpty);
    },
  );
  test(
    'subscription completion can arrive after its host is disposed',
    () async {
      final completed = Completer<UpdatingMessage?>();
      final profile = Profile.normal(url: 'https://example.com/sub');
      final controller = ProfilesController(
        onUpdateProfile: (_) => completed.future,
      );
      final pending = controller.updateSingleProfile(profile);
      controller.dispose();
      completed.complete(null);
      await pending;
    },
  );
  test('a local URL entry has no fabricated download timestamp', () async {
    final controller = ProfilesController();
    addTearDown(controller.dispose);
    await controller.addProfileFromLink('https://example.com/sub');
    expect(controller.currentProfileId, controller.profiles.single.id);
    expect(controller.profiles.single.lastUpdateDate, isNull);
  });
  for (final duringStart in [true, false]) {
    testWidgets(
      'phone receiver shows host errors during ${duringStart ? 'start' : 'receive'}',
      (tester) async {
        final received = Completer<String?>();
        var closed = 0;
        final controller = ProfilesController(
          isTV: true,
          startPhoneLinkReceiver: () async {
            if (duringStart) throw StateError('receiver test failure');
            return (
              address: Uri.parse('http://127.0.0.1:8123'),
              link: received.future,
              close: () async {
                closed++;
              },
            );
          },
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          host(const ProfilesView(), profiles: controller),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Send from phone'));
        await tester.pumpAndSettle();
        if (!duringStart) {
          received.completeError(StateError('receiver test failure'));
          await tester.pumpAndSettle();
        }
        expect(find.textContaining('receiver test failure'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(closed, duringStart ? 0 : 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('a receiver created after cancelling is closed once', (
    tester,
  ) async {
    final started = Completer<PhoneLinkSession?>();
    var closed = 0;
    final controller = ProfilesController(
      isTV: true,
      startPhoneLinkReceiver: () => started.future,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(const ProfilesView(), profiles: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send from phone'));
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    started.complete((
      address: Uri.parse('http://127.0.0.1:8123'),
      link: Future.value(null),
      close: () async {
        closed++;
      },
    ));
    await tester.pumpAndSettle();
    expect(closed, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('About delegates links and its five-tap developer action', (
    tester,
  ) async {
    viewport(tester, const Size(1000, 1000));
    final urls = <String>[];
    var developer = 0;
    await tester.pumpWidget(
      host(
        AboutView(
          appName: 'Library host',
          version: '2.4',
          description: 'Host metadata',
          logo: const GlyphIcon(AppGlyphs.layers),
          links: const [
            AboutLink(
              glyph: AppGlyphs.code,
              title: 'Source',
              url: 'https://example.com',
              label: 'example.com',
            ),
          ],
          contributors: const [Contributor(name: 'Ada', role: 'Design')],
          onOpenUrl: urls.add,
          onEnterDeveloperMode: () => developer++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Library host'), findsOneWidget);
    expect(find.text('v2.4'), findsOneWidget);
    await tester.tap(find.text('Source'));
    expect(urls, ['https://example.com']);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byGlyph(AppGlyphs.layers));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(developer, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'tools open the real appearance and hotkey views through scopes',
    (tester) async {
      viewport(tester, const Size(1200, 1000));
      final shell = HomeShellController();
      final theme = ThemeController();
      final keys = HotKeyController();
      addTearDown(shell.dispose);
      addTearDown(theme.dispose);
      addTearDown(keys.dispose);
      await tester.pumpWidget(
        host(const ToolsView(), shell: shell, theme: theme, keys: keys),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.byType(ThemeView), findsOneWidget);
      expect(find.byType(ThemeLivePreview), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
