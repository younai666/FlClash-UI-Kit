// Host-owned hotkey models, controller, and InheritedNotifier scope
// (adapted from FlClash lib/enum/enum.dart, lib/models/common.dart,
// lib/models/config.dart, and lib/providers/app.dart,
// commit be84736605527034689c95bf27828ff27d912c5e). GPL-3.0.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../icons.dart';
import '../localizations.dart';
import 'keyboard.dart';

enum KeyboardModifier {
  alt([PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight]),
  capsLock([PhysicalKeyboardKey.capsLock]),
  control([PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight]),
  fn([PhysicalKeyboardKey.fn]),
  meta([PhysicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaRight]),
  shift([PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight]);

  final List<PhysicalKeyboardKey> physicalKeys;

  const KeyboardModifier(this.physicalKeys);
}

const keyboardModifierListEquality = SetEquality<KeyboardModifier>();
const hotKeyActionListEquality = ListEquality<HotKeyAction>();

enum HotAction {
  start,
  view,
  mode,
  proxy,
  tun,
  ruleMode,
  globalMode,
  directMode,
  delayTest,
  updateProfiles,
  copyEnv,
  exit,
}

extension HotActionL10n on HotAction {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) {
      HotAction.view => l.actionView,
      HotAction.start => l.actionStart,
      HotAction.mode => l.actionMode,
      HotAction.proxy => l.actionProxy,
      HotAction.tun => l.actionTun,
      HotAction.ruleMode => l.actionRuleMode,
      HotAction.globalMode => l.actionGlobalMode,
      HotAction.directMode => l.actionDirectMode,
      HotAction.delayTest => l.actionDelayTest,
      HotAction.updateProfiles => l.actionUpdateProfiles,
      HotAction.copyEnv => l.copyEnvVar,
      HotAction.exit => l.exit,
    };
  }
}

const _unsetKey = Object();

/// Key combination bound to an [action].
///
/// [action] may be a [HotAction] or any custom identifier (`String`, `enum`,
/// etc.) for standalone applications using [HotKeyView] / [HotKeyRecorder].
@immutable
class HotKeyAction {
  final Object action;
  final int? key;
  final Set<KeyboardModifier> modifiers;

  const HotKeyAction({
    required this.action,
    this.key,
    this.modifiers = const {},
  });

  HotKeyAction copyWith({
    Object? action,
    Object? key = _unsetKey,
    Set<KeyboardModifier>? modifiers,
  }) {
    return HotKeyAction(
      action: action ?? this.action,
      key: identical(key, _unsetKey) ? this.key : key as int?,
      modifiers: modifiers ?? this.modifiers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotKeyAction &&
          other.action == action &&
          other.key == key &&
          keyboardModifierListEquality.equals(other.modifiers, modifiers);

  @override
  int get hashCode => Object.hash(
        action,
        key,
        keyboardModifierListEquality.hash(modifiers),
      );
}

HotKeyAction _defaultHotKeyAction(HotAction action, PhysicalKeyboardKey key) {
  return HotKeyAction(
    action: action,
    key: key.usbHidUsage,
    modifiers: const {KeyboardModifier.control, KeyboardModifier.alt},
  );
}

List<HotKeyAction> defaultHotKeyActionsFor({bool? isWindows}) {
  final windows =
      isWindows ?? (defaultTargetPlatform == TargetPlatform.windows);
  if (windows) return const [];
  return [
    _defaultHotKeyAction(HotAction.view, PhysicalKeyboardKey.keyV),
    _defaultHotKeyAction(HotAction.start, PhysicalKeyboardKey.keyS),
    _defaultHotKeyAction(HotAction.mode, PhysicalKeyboardKey.keyM),
    _defaultHotKeyAction(HotAction.proxy, PhysicalKeyboardKey.keyP),
    _defaultHotKeyAction(HotAction.delayTest, PhysicalKeyboardKey.keyD),
  ];
}

List<HotKeyAction> get defaultHotKeyActions => defaultHotKeyActionsFor();

typedef HotKeySectionBuilder =
    List<(String, List<Object>)> Function(BuildContext context);

class HotKeyController extends ChangeNotifier {
  HotKeyController({
    List<HotKeyAction>? actions,
    List<HotKeyAction>? defaultActions,
    Map<Object, String> failures = const {},
    ShortcutLabels? labels,
    this.sectionsBuilder,
    this.actionLabelBuilder,
    this.actionGlyphBuilder,
    this.onActionsChanged,
    this.onRecordingChanged,
  }) : _actions = List<HotKeyAction>.unmodifiable(
         actions ?? defaultHotKeyActionsFor(),
       ),
       _defaultActions = List<HotKeyAction>.unmodifiable(
         defaultActions ?? defaultHotKeyActionsFor(),
       ),
       _failures = Map<Object, String>.unmodifiable(failures),
       _labels = labels ?? ShortcutLabels.host();

  List<HotKeyAction> _actions;
  final List<HotKeyAction> _defaultActions;
  Map<Object, String> _failures;
  bool _isRecording = false;
  ShortcutLabels _labels;

  final HotKeySectionBuilder? sectionsBuilder;
  final String Function(BuildContext context, Object action)? actionLabelBuilder;
  final Glyph Function(Object action)? actionGlyphBuilder;
  final ValueChanged<List<HotKeyAction>>? onActionsChanged;
  final ValueChanged<bool>? onRecordingChanged;

  List<HotKeyAction> get actions => _actions;
  List<HotKeyAction> get defaultActions => _defaultActions;
  Map<Object, String> get failures => _failures;
  bool get isRecording => _isRecording;
  ShortcutLabels get labels => _labels;

  String labelOfAction(BuildContext context, Object action) {
    if (actionLabelBuilder != null) {
      return actionLabelBuilder!(context, action);
    }
    if (action is HotAction) return action.labelOf(context);
    return action.toString();
  }

  Glyph glyphOfAction(Object action) {
    if (actionGlyphBuilder != null) {
      return actionGlyphBuilder!(action);
    }
    if (action is HotAction) {
      return switch (action) {
        HotAction.view => AppGlyphs.eye,
        HotAction.start => AppGlyphs.playPause(0),
        HotAction.exit => AppGlyphs.close,
        HotAction.mode => AppGlyphs.split,
        HotAction.ruleMode => AppGlyphs.rules,
        HotAction.globalMode => AppGlyphs.language,
        HotAction.directMode => AppGlyphs.target,
        HotAction.proxy => AppGlyphs.shuffle,
        HotAction.tun => AppGlyphs.vpn,
        HotAction.copyEnv => AppGlyphs.code,
        HotAction.delayTest => AppGlyphs.bolt,
        HotAction.updateProfiles => AppGlyphs.sync,
      };
    }
    return AppGlyphs.keyboard;
  }

  void setActions(List<HotKeyAction> next) {
    if (hotKeyActionListEquality.equals(_actions, next)) return;
    _actions = List<HotKeyAction>.unmodifiable(next);
    notifyListeners();
    onActionsChanged?.call(_actions);
  }

  void resetToDefault() => setActions(_defaultActions);

  void setFailures(Map<Object, String> next) {
    if (mapEquals(_failures, next)) return;
    _failures = Map<Object, String>.unmodifiable(next);
    notifyListeners();
  }

  void setRecording(bool recording) {
    if (_isRecording == recording) return;
    _isRecording = recording;
    notifyListeners();
    onRecordingChanged?.call(recording);
  }

  void setLabels(ShortcutLabels next) {
    if (identical(_labels, next)) return;
    _labels = next;
    notifyListeners();
  }
}

class HotKeyScope extends InheritedNotifier<HotKeyController> {
  const HotKeyScope({
    super.key,
    required HotKeyController controller,
    required super.child,
  }) : super(notifier: controller);

  static HotKeyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HotKeyScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('HotKeyScope not found above context.');
    }
    return scope.notifier!;
  }

  static HotKeyController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<HotKeyScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('HotKeyScope not found above context.');
    }
    return scope.notifier!;
  }

  static HotKeyController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HotKeyScope>()?.notifier;
  }
}
