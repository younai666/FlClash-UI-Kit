// Derived from chen08209/FlClash, test/views/hotkey_view_test.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


const _labels = ShortcutLabels(isMacOS: false, isWindows: true);

final _keyA = PhysicalKeyboardKey.keyA.usbHidUsage;
final _keyB = PhysicalKeyboardKey.keyB.usbHidUsage;

HotKeyController _containerFor(WidgetTester tester, {List<HotKeyAction> hotKeyActions = const []}) {
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

Future<void> _press(
  WidgetTester tester,
  PhysicalKeyboardKey key,
  LogicalKeyboardKey logicalKey, {
  List<(PhysicalKeyboardKey, LogicalKeyboardKey)> holding = const [],
}) async {
  for (final (physical, logical) in holding) {
    await simulateKeyDownEvent(logical, physicalKey: physical);
  }
  await simulateKeyDownEvent(logicalKey, physicalKey: key);
  await tester.pumpAndSettle();
  await simulateKeyUpEvent(logicalKey, physicalKey: key);
  for (final (physical, logical) in holding.reversed) {
    await simulateKeyUpEvent(logical, physicalKey: physical);
  }
  await tester.pumpAndSettle();
}

const _control = (
  PhysicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlLeft,
);

Future<void> _pressControlA(WidgetTester tester) {
  return _press(
    tester,
    PhysicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyA,
    holding: const [_control],
  );
}

TextButton _button(WidgetTester tester, String label) {
  return tester.widget<TextButton>(find.widgetWithText(TextButton, label));
}

String _label(WidgetTester tester, HotAction action) => action.labelOf(tester.element(find.byType(HotKeyScope)));

void main() {
  group('HotKeyView', () {
    testWidgets('lists every action, bound or not', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      await _pumpView(tester, container);

      for (final action in HotAction.values) {
        await tester.scrollUntilVisible(find.text(_label(tester, action)), 100);
        expect(find.text(_label(tester, action)), findsOne, reason: action.name);
      }
      expect(
        find.text(const KitLocalizations(Locale('en')).hotkeyNotSet),
        findsAtLeastNWidgets(1),
      );
      expect(tester.takeException(), null);
    });

    testWidgets('shows a binding as key caps and clears it in place', (
      tester,
    ) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.shift},
          ),
        ],
      );
      await _pumpView(tester, container);

      final labels = ShortcutLabels.host();
      expect(find.text(labels.modifier(KeyboardModifier.shift)), findsOne);
      expect(find.text(labels.key(_keyA)), findsOne);

      await tester.tap(find.byTooltip(const KitLocalizations(Locale('en')).remove));
      await tester.pumpAndSettle();

      expect(container.actions, isEmpty);
      expect(find.text(labels.key(_keyA)), findsNothing);
    });

    testWidgets('flags a binding the OS refused', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      container.setFailures({HotAction.view: 'already registered'});
      await _pumpView(tester, container);

      expect(find.text(const KitLocalizations(Locale('en')).hotkeyUnavailable), findsOne);
      expect(find.byTooltip('already registered'), findsOne);
    });
  });

  group('HotKeyRecorder', () {
    testWidgets('pauses global hotkeys while it is open', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(container.isRecording, isTrue);

      await tester.tap(find.text(const KitLocalizations(Locale('en')).cancel));
      await tester.pumpAndSettle();

      expect(container.isRecording, isFalse);
    });

    testWidgets('previews held modifiers until a key completes it', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(find.text(const KitLocalizations(Locale('en')).pressKeyboard), findsOne);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(find.text('Ctrl'), findsOne);
      expect(find.text('…'), findsOne);
      expect(_button(tester, const KitLocalizations(Locale('en')).save).onPressed, isNull);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.keyA,
        physicalKey: PhysicalKeyboardKey.keyA,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.keyA,
        physicalKey: PhysicalKeyboardKey.keyA,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(find.text('…'), findsNothing);
      expect(find.text('Ctrl'), findsOne);
      expect(find.text('A'), findsOne);
      expect(tester.takeException(), null);
    });

    testWidgets('save stores a modifier plus key combination', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _pressControlA(tester);
      await tester.tap(find.text(const KitLocalizations(Locale('en')).save));
      await tester.pumpAndSettle();

      final stored = container.actions;
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.mode);
      expect(stored.single.key, _keyA);
      expect(stored.single.modifiers, {KeyboardModifier.control});
    });

    testWidgets('a bare key cannot be saved and says why', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _press(tester, PhysicalKeyboardKey.keyA, LogicalKeyboardKey.keyA);

      expect(_button(tester, const KitLocalizations(Locale('en')).save).onPressed, isNull);
      expect(
        find.text(
          const KitLocalizations(Locale('en')).hotkeyNeedsModifier('Ctrl, Alt, Shift, Win'),
        ),
        findsOne,
      );
      expect(container.actions, isEmpty);
    });

    testWidgets('saving a taken combination moves it from the other action', (
      tester,
    ) async {
      final taken = HotKeyAction(
        action: HotAction.start,
        key: _keyA,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [taken]);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _pressControlA(tester);

      expect(
        find.text(
          const KitLocalizations(Locale('en')).hotkeyConflictWith(_label(tester, HotAction.start)),
        ),
        findsOne,
      );

      await tester.tap(find.text(const KitLocalizations(Locale('en')).save));
      await tester.pumpAndSettle();

      final stored = container.actions;
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.mode);
      expect(stored.single.key, _keyA);
    });

    testWidgets('save replaces the binding for the same action', (
      tester,
    ) async {
      final existing = HotKeyAction(
        action: HotAction.mode,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing]);
      await _pumpRecorder(tester, container, existing);

      await _pressControlA(tester);
      await tester.tap(find.text(const KitLocalizations(Locale('en')).save));
      await tester.pumpAndSettle();

      final stored = container.actions;
      expect(stored, hasLength(1), reason: 'replaces rather than appends');
      expect(stored.single.key, _keyA);
    });

    testWidgets('remove clears the binding for the action', (tester) async {
      final existing = HotKeyAction(
        action: HotAction.mode,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final other = HotKeyAction(
        action: HotAction.tun,
        key: _keyA,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing, other]);
      await _pumpRecorder(tester, container, existing);

      await tester.tap(find.text(const KitLocalizations(Locale('en')).remove));
      await tester.pumpAndSettle();

      expect(container.actions, [other]);
    });

    testWidgets('remove is offered only for a bound action', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(find.text(const KitLocalizations(Locale('en')).remove), findsNothing);
    });

    testWidgets('a bare Escape closes without saving', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _press(
        tester,
        PhysicalKeyboardKey.escape,
        LogicalKeyboardKey.escape,
      );

      expect(find.byType(HotKeyRecorder), findsNothing);
      expect(container.actions, isEmpty);
    });
  });
}
