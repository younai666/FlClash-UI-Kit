// Derived from chen08209/FlClash, lib/views/hotkey.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


List<(String, List<Object>)> _sections(KitLocalizations appLocalizations) {
  return [
    (
      appLocalizations.general,
      const [HotAction.view, HotAction.start, HotAction.exit],
    ),
    (
      appLocalizations.outboundMode,
      const [
        HotAction.mode,
        HotAction.ruleMode,
        HotAction.globalMode,
        HotAction.directMode,
      ],
    ),
    (
      appLocalizations.network,
      const [HotAction.proxy, HotAction.tun, HotAction.copyEnv],
    ),
    (
      appLocalizations.proxies,
      const [HotAction.delayTest, HotAction.updateProfiles],
    ),
  ];
}

bool _sameCombination(HotKeyAction a, HotKeyAction b) {
  return a.key != null &&
      a.key == b.key &&
      keyboardModifierListEquality.equals(a.modifiers, b.modifiers);
}

HotKeyAction? _conflictOf(List<HotKeyAction> actions, HotKeyAction binding) {
  for (final item in actions) {
    if (item.action != binding.action && _sameCombination(item, binding)) {
      return item;
    }
  }
  return null;
}

/// Stores [binding] for its action, or clears the action when it has no key.
/// Another action holding the same combination loses it.
List<HotKeyAction> _withBinding(
  List<HotKeyAction> actions,
  HotKeyAction binding,
) {
  final isBound = binding.key != null;
  var isPlaced = false;
  final result = <HotKeyAction>[];
  for (final item in actions) {
    if (item.action == binding.action) {
      isPlaced = true;
      if (isBound) {
        result.add(binding);
      }
    } else if (!(isBound && _sameCombination(item, binding))) {
      result.add(item);
    }
  }
  if (isBound && !isPlaced) {
    result.add(binding);
  }
  return result;
}

void _saveBinding(BuildContext context, HotKeyAction binding) {
  final notifier = HotKeyScope.read(context);
  notifier.setActions(_withBinding(notifier.actions, binding));
}

class HotKeyView extends StatelessWidget {
  const HotKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final labels = HotKeyScope.of(context).labels;
    return BaseScaffold(
      title: appLocalizations.hotkeyManagement,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          const _HotKeyIntro(),
          for (final (title, actions) in (HotKeyScope.of(context).sectionsBuilder?.call(context) ?? _sections(appLocalizations)))
            generateSection(
              title: title,
              items: [
                for (final action in actions)
                  _HotKeyItem(action: action, labels: labels),
              ],
            ),
        ],
      ),
    );
  }
}

class _HotKeyIntro extends StatelessWidget {
  const _HotKeyIntro();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.xl,
      ),
      child: Row(
        spacing: 14,
        children: [
          GlyphIcon(AppGlyphs.keyboard, color: colorScheme.primary),
          Expanded(
            child: Text(
              KitLocalizations.of(context).hotkeyDesc,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotKeyItem extends StatelessWidget {
  const _HotKeyItem({required this.action, required this.labels});

  final Object action;
  final ShortcutLabels labels;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final hotKeyAction = HotKeyScope.of(context).actions.firstWhere((item) => item.action == action, orElse: () => HotKeyAction(action: action));
    final failure = HotKeyScope.of(context).failures[action];
    final key = hotKeyAction.key;
    return DecorationListItem(
      contentPadding: EdgeInsets.only(left: 16, right: key == null ? 16 : 6),
      leading: GlyphIcon(HotKeyScope.of(context).glyphOfAction(action)),
      title: Text(HotKeyScope.of(context).labelOfAction(context, action), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: failure == null
          ? null
          : Tooltip(
              message: failure,
              child: Text(
                appLocalizations.hotkeyUnavailable,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: colorScheme.error),
              ),
            ),
      trailing: key == null
          ? Text(
              appLocalizations.hotkeyNotSet,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.outline),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _KeyCaps(
                  parts: labels.parts(hotKeyAction.modifiers, key),
                  isError: failure != null,
                ),
                IconButton(
                  tooltip: appLocalizations.remove,
                  onPressed: () {
                    _saveBinding(context, HotKeyAction(action: action));
                  },
                  icon: const GlyphIcon(AppGlyphs.close, size: 20),
                ),
              ],
            ),
      onPressed: () {
        showFloatingDialog(context: context,
          child: HotKeyRecorder(hotKeyAction: hotKeyAction, labels: labels),
        );
      },
    );
  }
}

class _KeyCaps extends StatelessWidget {
  const _KeyCaps({
    required this.parts,
    this.isLarge = false,
    this.isError = false,
  });

  final List<String> parts;
  final bool isLarge;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isLarge ? 8 : 4,
      runSpacing: isLarge ? 8 : 4,
      alignment: WrapAlignment.center,
      children: [
        for (final part in parts)
          _KeyCap(label: part, isLarge: isLarge, isError: isError),
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.label,
    this.isLarge = false,
    this.isError = false,
    this.isPlaceholder = false,
  });

  final String label;
  final bool isLarge;
  final bool isError;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final side = isLarge ? 44.0 : 26.0;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    final textStyle = isLarge
        ? AppTextStyle.headline.of(context)
        : AppTextStyle.caption1.of(context, emphasized: true);
    return Container(
      constraints: BoxConstraints(minWidth: side, minHeight: side),
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 7),
      decoration: ShapeDecoration(
        color: isPlaceholder
            ? Colors.transparent
            : isError
            ? colorScheme.errorContainer
            : context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: isLarge ? AppShape.md : AppShape.sm,
      ),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(label, style: textStyle.copyWith(color: foregroundColor)),
      ),
    );
  }
}

class HotKeyRecorder extends StatefulWidget {
  const HotKeyRecorder({
    super.key,
    required this.hotKeyAction,
    required this.labels,
  });

  final HotKeyAction hotKeyAction;
  final ShortcutLabels labels;

  @override
  State<HotKeyRecorder> createState() => _HotKeyRecorderState();
}

class _HotKeyRecorderState extends State<HotKeyRecorder> {
  late final HotKeyController _recording;
  Set<KeyboardModifier> _modifiers = const {};
  int? _key;

  HotKeyAction get _draft =>
      widget.hotKeyAction.copyWith(modifiers: _modifiers, key: _key);

  @override
  void initState() {
    super.initState();
    _recording = HotKeyScope.read(context);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recording.setRecording(true);
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    final recording = _recording;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recording.setRecording(false);
    });
    super.dispose();
  }

  Set<KeyboardModifier> _heldModifiers({PhysicalKeyboardKey? except}) {
    final pressed = HardwareKeyboard.instance.physicalKeysPressed;
    return {
      for (final modifier in KeyboardModifier.values)
        if (modifier.physicalKeys.any(pressed.contains) &&
            !modifier.physicalKeys.contains(except))
          modifier,
    };
  }

  bool _handleKeyEvent(KeyEvent event) {
    final physicalKey = event.physicalKey;
    if (isModifierKey(physicalKey)) {
      if (event is KeyDownEvent || (event is KeyUpEvent && _key == null)) {
        setState(() {
          _key = null;
          _modifiers = _heldModifiers();
        });
      }
      return false;
    }
    if (event is KeyUpEvent) {
      return false;
    }
    final modifiers = _heldModifiers(except: physicalKey);
    if (physicalKey == PhysicalKeyboardKey.escape && modifiers.isEmpty) {
      Navigator.of(context).pop();
      return false;
    }
    setState(() {
      _modifiers = modifiers;
      _key = physicalKey.usbHidUsage;
    });
    return false;
  }

  void _handleSave() {
    Navigator.of(context).pop();
    _saveBinding(context, _draft);
  }

  void _handleRemove() {
    Navigator.of(context).pop();
    _saveBinding(context, HotKeyAction(action: widget.hotKeyAction.action));
  }

  Widget _buildCapture(BuildContext context, {required bool isError}) {
    final colorScheme = context.colorScheme;
    final key = _key;
    final Widget content;
    if (key != null) {
      content = _KeyCaps(
        parts: widget.labels.parts(_modifiers, key),
        isLarge: true,
        isError: isError,
      );
    } else if (_modifiers.isNotEmpty) {
      content = Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final part in widget.labels.modifierParts(_modifiers))
            _KeyCap(label: part, isLarge: true),
          const _KeyCap(label: '…', isLarge: true, isPlaceholder: true),
        ],
      );
    } else {
      content = Text(
        KitLocalizations.of(context).pressKeyboard,
        textAlign: TextAlign.center,
        style: AppTextStyle.body
            .of(context)
            .copyWith(color: colorScheme.onSurfaceVariant),
      );
    }
    final level = context.raisedSurfaceLevel;
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.md.copyWith(
          side: BorderSide(
            color: isError ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      child: SurfaceScope(level: level, child: content),
    );
  }

  Widget? _buildStatus(
    BuildContext context, {
    required bool isInvalid,
    required HotKeyAction? conflict,
  }) {
    final appLocalizations = KitLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final (text, color) = switch ((isInvalid, conflict)) {
      (true, _) => (
        appLocalizations.hotkeyNeedsModifier(
          widget.labels
              .modifierParts(primaryHotKeyModifiers)
              .join(widget.labels.isMacOS ? ' ' : ', '),
        ),
        colorScheme.error,
      ),
      (false, final HotKeyAction conflict) => (
        appLocalizations.hotkeyConflictWith(HotKeyScope.of(context).labelOfAction(context, conflict.action)),
        colorScheme.tertiary,
      ),
      _ => (null, null),
    };
    if (text == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: AppTextStyle.subheadline.of(context).copyWith(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final draft = _draft;
    final isComplete = draft.key != null;
    final isValid = isValidHotKey(draft.modifiers, draft.key);
    final isInvalid = isComplete && !isValid;
    final conflict = isValid
        ? _conflictOf(HotKeyScope.of(context).actions, draft)
        : null;
    final status = _buildStatus(
      context,
      isInvalid: isInvalid,
      conflict: conflict,
    );
    return Focus(
      onKeyEvent: (_, _) {
        return KeyEventResult.handled;
      },
      autofocus: true,
      child: AlertDialog(
        title: HotKeyScope.of(context).labelOfAction(context, widget.hotKeyAction.action),
        hasFields: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(appLocalizations.cancel),
          ),
          if (widget.hotKeyAction.key != null)
            TextButton(
              onPressed: _handleRemove,
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  context.colorScheme.destructive,
                ),
              ),
              child: Text(appLocalizations.remove),
            ),
          TextButton(
            onPressed: isValid ? _handleSave : null,
            child: Text(appLocalizations.save),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCapture(context, isError: isInvalid),
            AnimatedSize(
              duration: commonDuration,
              alignment: Alignment.topCenter,
              child: status ?? const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
