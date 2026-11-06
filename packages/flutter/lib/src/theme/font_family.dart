// Derived from chen08209/FlClash, lib/views/font_family.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';
import 'dart:collection';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


sealed class _FontChoice {
  const _FontChoice();
}

final class _DefaultFont extends _FontChoice {
  const _DefaultFont();
}

final class _InstalledFont extends _FontChoice {
  const _InstalledFont(this.family);

  final String family;

  @override
  bool operator ==(Object other) =>
      other is _InstalledFont && other.family == family;

  @override
  int get hashCode => family.hashCode;
}

class FontFamilyView extends StatefulWidget {
  const FontFamilyView({super.key});

  @override
  State<FontFamilyView> createState() => _FontFamilyViewState();
}

class _FontFamilyViewState extends State<FontFamilyView> {
  List<_InstalledFont>? _installed;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final families = await ThemeScope.read(context).loadSystemFontFamilies();
    if (mounted) {
      setState(() => _installed = families.map(_InstalledFont.new).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final installed = _installed ?? const <_InstalledFont>[];
    return SelectionSheet<_FontChoice>(
      title: appLocalizations.fontFamily,
      loadingStatus: _installed == null
          ? const NullStatus(illustration: NullStatusIllustration.fonts)
          : null,
      sections: [
        const SelectionSection(items: [_DefaultFont()]),
        if (installed.isNotEmpty)
          SelectionSection(
            label: appLocalizations.installedFonts,
            items: installed,
          ),
      ],
      labelBuilder: (choice) => switch (choice) {
        _DefaultFont() => appLocalizations.defaultText,
        _InstalledFont(:final family) => family,
      },
      titleBuilder: (choice, title) => switch (choice) {
        _DefaultFont() => title,
        _InstalledFont(:final family) => _FontLabel(
          family: family,
          child: title,
        ),
      },
      selected: switch (ThemeScope.of(context).themeProps.fontFamily) {
        final family? => _InstalledFont(family),
        null => const _DefaultFont(),
      },
      onSelected: (choice) {
        final String? family;
        switch (choice) {
          case _DefaultFont():
            family = null;
          case _InstalledFont():
            family = choice.family;
        }
        ThemeScope.read(context).updateThemeProps((state) => state.copyWith(fontFamily: family));
      },
    );
  }
}

/// Laying out a family for the first time loads it on the UI thread, longer
/// for a large CJK one, so each name switches to its family on a frame of its
/// own and none while the list or the route moves.
class _FontLabel extends StatefulWidget {
  const _FontLabel({required this.family, required this.child});

  final String family;
  final Widget child;

  @override
  State<_FontLabel> createState() => _FontLabelState();
}

class _FontLabelState extends State<_FontLabel> {
  static final _shown = <String>{};
  static final _waiting = Queue<_FontLabelState>();
  static var _scheduled = false;

  bool get _isShown => _shown.contains(widget.family);

  @override
  void initState() {
    super.initState();
    _request();
  }

  @override
  void didUpdateWidget(_FontLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.family != widget.family) {
      _request();
    }
  }

  @override
  void dispose() {
    _waiting.remove(this);
    super.dispose();
  }

  void _request() {
    if (_isShown || _waiting.contains(this)) {
      return;
    }
    _waiting.add(this);
    _schedule();
  }

  static void _schedule() {
    if (_scheduled || _waiting.isEmpty) {
      return;
    }
    _scheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback(_showNext)
      ..ensureVisualUpdate();
  }

  static void _showNext(Duration _) {
    final next = _waiting.firstOrNull;
    if (next != null && next.mounted) {
      if (isRouteMoving(next.context)) {
        // The frames of the motion carry the queue until it stops.
        SchedulerBinding.instance.addPostFrameCallback(_showNext);
        return;
      }
      final scrollPosition = Scrollable.maybeOf(next.context)?.position;
      // A scroll can end without another frame to carry the queue.
      if (scrollPosition?.isScrollingNotifier.value ?? false) {
        SchedulerBinding.instance
          ..addPostFrameCallback(_showNext)
          ..ensureVisualUpdate();
        return;
      }
    }
    _scheduled = false;
    while (_waiting.isNotEmpty) {
      final label = _waiting.removeFirst();
      if (!label.mounted || label._isShown) {
        continue;
      }
      _shown.add(label.widget.family);
      label.setState(() {});
      break;
    }
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShown) {
      return widget.child;
    }
    return DefaultTextStyle.merge(
      style: TextStyle(fontFamily: widget.family),
      child: widget.child,
    );
  }
}
