// Extracted from FlClash lib/pages/editor.dart:661-1377,
// be84736605527034689c95bf27828ff27d912c5e; modified 2026-11-05.
// GPL-3.0: explicit font/wrap/language/completion inputs; original renderer,
// find panel, touch selection, context menu and caret anchoring retained.
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:code_forge/code_forge.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'completion_popup.dart';
enum EditorLanguage { yaml, javaScript, json, ini, xml, text }
class NativeCodeEditor extends StatefulWidget {
  const NativeCodeEditor({
    super.key,
    this.fontSize = 14,
    this.lineWrap = false,
    this.topInset,
    this.completionSource,
    required this.controller,
    required this.findController,
    required this.undoController,
    required this.readOnly,
    required this.language,
    
  });

  final CodeForgeController controller;
  final FindController findController;
  final UndoRedoController undoController;
  final bool readOnly;
  final EditorLanguage language;
  final double fontSize;
  final bool lineWrap;
  /// Null retains upstream floating-bar clearance; use zero in an inline host.
  final double? topInset;
  final CodeForgeCompletionSource? completionSource;

  @override
  State<NativeCodeEditor> createState() => _NativeCodeEditorState();
}

class _NativeCodeEditorState extends State<NativeCodeEditor> {
  // CodeForge compares these by identity and rebuilds its whole layout and
  // highlighter on any change, so each is rebuilt only when its inputs change.
  ColorScheme? _colorScheme;
  Map<String, TextStyle> _editorTheme = const {};
  CodeSelectionStyle? _selectionStyle;
  TextStyle? _textStyle;
  TextStyle? _lineNumberStyle;
  EdgeInsets _innerPadding = const EdgeInsets.only(right: 16);
  late bool _findActive = widget.findController.isActive;
  CodeForgeCompletionSource? get _completionSource => widget.completionSource;
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    _verticalController = sheetScrollController(context);
    widget.findController.addListener(_handleFindChanged);
  }

  @override
  void didUpdateWidget(covariant NativeCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.findController != widget.findController) {
      oldWidget.findController.removeListener(_handleFindChanged);
      widget.findController.addListener(_handleFindChanged);
      _handleFindChanged();
    }
    if (oldWidget.language != widget.language) _colorScheme = null;
  }

  @override
  void dispose() {
    widget.findController.removeListener(_handleFindChanged);
    _verticalController.dispose();
    super.dispose();
  }

  void _handleFindChanged() {
    final isActive = widget.findController.isActive;
    if (isActive != _findActive) {
      setState(() {
        _findActive = isActive;
      });
    }
  }

  // The bar floats over the text, which scrolls under it from a first line
  // held clear of it; an open find panel takes that clearance instead.
  void _updateInnerPadding(BuildContext context) {
    final padding = EdgeInsets.only(
      top: _findActive ? _findRowGap : (widget.topInset ?? context.appBarInset),
      right: 16,
      bottom: context.bottomInset,
    );
    if (padding != _innerPadding) {
      _innerPadding = padding;
    }
  }

  void _updateStyles(BuildContext context, double fontSize) {
    final colorScheme = context.colorScheme;
    final schemeChanged = colorScheme != _colorScheme;
    if (schemeChanged) {
      _colorScheme = colorScheme;
      _editorTheme = _highlightTheme(colorScheme, widget.language);
      _selectionStyle = CodeSelectionStyle(
        cursorColor: colorScheme.primary,
        selectionColor: textSelectionColorOf(colorScheme),
        cursorBubbleColor: colorScheme.primary,
      );
    }
    final appFont = AppTextStyle.footnote.of(context);
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: FontFamily.jetBrainsMono.value,
      fontFamilyFallback: [
        FontFamily.twEmoji.value,
        ?appFont.fontFamily,
        ...?appFont.fontFamilyFallback,
      ],
    );
    if (textStyle != _textStyle) {
      _textStyle = textStyle;
    }
    _lineNumberStyle = TextStyle(
      fontSize: 12,
      fontFamily: appFont.fontFamily,
      fontFamilyFallback: appFont.fontFamilyFallback,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  void _showClipboardWriteFailed() {
    if (!mounted) {
      return;
    }
    BannerHost.maybeOf(context)?.show(
      KitLocalizations.of(context).clipboardWriteFailed,
      level: BannerLevel.error,
    );
  }

  void _showContextMenu(
    BuildContext context,
    CodeForgeContextMenuRequest request,
  ) {
    final appLocalizations = KitLocalizations.of(context);
    final navigator = Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject();
    if (navigatorBox is! RenderBox) {
      return;
    }
    final point = navigatorBox.globalToLocal(request.globalPosition);
    final controller = widget.controller;
    late final PopupRoute<void> route;
    late final ValueNotifier<List<PopupMenuItem>> items;
    late final ValueNotifier<Rect> anchor;
    var selection = controller.selection;
    var selectingAll = false;

    void close() {
      if (route.isCurrent) navigator.pop();
    }

    Rect anchorRect() {
      final rect = request.selectionRect;
      return rect == null
          ? point & Size.zero
          : Rect.fromPoints(
              navigatorBox.globalToLocal(rect.topLeft),
              navigatorBox.globalToLocal(rect.bottomRight),
            );
    }

    List<PopupMenuItem> menuItems() => [
      if (request.hasSelection && !request.readOnly)
        PopupMenuItem(
          glyph: AppGlyphs.cut,
          label: appLocalizations.cut,
          onPressed: () {
            request.cut();
            close();
          },
        ),
      if (request.hasSelection)
        PopupMenuItem(
          glyph: AppGlyphs.copy,
          label: appLocalizations.copy,
          onPressed: () {
            request.copy();
            close();
          },
        ),
      if (!request.readOnly)
        PopupMenuItem(
          glyph: AppGlyphs.paste,
          label: appLocalizations.paste,
          onPressed: () {
            request.paste();
            close();
          },
        ),
      if (!request.isAllSelected)
        PopupMenuItem(
          glyph: AppGlyphs.selectAll,
          label: appLocalizations.selectAll,
          onPressed: () {
            selectingAll = true;
            request.selectAll();
            selectingAll = false;
            selection = controller.selection;
            if (!route.isCurrent) return;
            items.value = menuItems();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (route.isActive) anchor.value = anchorRect();
            });
          },
        ),
    ];

    items = ValueNotifier(menuItems());
    if (items.value.isEmpty) {
      return;
    }
    anchor = ValueNotifier(anchorRect());
    route = (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux)
        ? AnchoredPopupRoute<void>(
            barrierLabel: UiLocalizations.of(context).close,
            placement: PopupPlacement.belowPoint,
            modal: false,
            anchorOf: () => point & Size.zero,
            builder: (_) => PopupMenu(items: items.value),
          )
        : EditMenuRoute(
            barrierLabel: UiLocalizations.of(context).close,
            items: items,
            selection: anchor,
          );
    final version = controller.contentVersion;
    final composition = controller.imeComposition;
    final focusNode = controller.focusNode;
    final hadFocus = focusNode?.hasFocus ?? false;
    // Typing or a focus change reaches the editor with no pointer down.
    void closeOnceOutdated() {
      if (selectingAll) return;
      final outdated =
          controller.selection != selection ||
          controller.contentVersion != version ||
          controller.imeComposition != composition ||
          hadFocus && !focusNode!.hasFocus;
      if (outdated) close();
    }

    controller.addListener(closeOnceOutdated);
    focusNode?.addListener(closeOnceOutdated);
    navigator.push(route).whenComplete(() {
      controller.removeListener(closeOnceOutdated);
      focusNode?.removeListener(closeOnceOutdated);
    });
    unawaited(
      route.completed.whenComplete(() {
        items.dispose();
        anchor.dispose();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateStyles(
      context,
      widget.fontSize,
    );
    _updateInnerPadding(context);
    final lineWrap = widget.lineWrap;
    widget.controller
      ..enableLocalSuggestions = !widget.readOnly
      ..completionSource = widget.readOnly ? null : _completionSource
      ..onClipboardWriteFailed = _showClipboardWriteFailed;
    return CodeForge(
      controller: widget.controller,
      findController: widget.findController,
      undoController: widget.undoController,
      verticalScrollController: _verticalController,
      readOnly: widget.readOnly,
      language: switch (widget.language) {
        EditorLanguage.yaml => langYaml,
        EditorLanguage.javaScript => langJavascript,
        EditorLanguage.json => langJson,
        EditorLanguage.ini => langIni,
        EditorLanguage.xml => langXml,
        EditorLanguage.text => langPlaintext,
      },
      editorTheme: _editorTheme,
      tabSize: 2,
      useSpaceAsTab: true,
      selectionStyle: _selectionStyle,
      suggestionPopupBuilder: (_, details) => CustomSingleChildLayout(
        delegate: CaretPopupLayout(
          caretRect: details.caretRect,
          padding: EdgeInsets.only(top: _innerPadding.top),
        ),
        child: EditorCompletionPopup(details: details, textStyle: _textStyle!),
      ),
      magnifierBuilder: (context, controller, magnifierInfo) =>
          TextLoupe(controller: controller, magnifierInfo: magnifierInfo),
      textStyle: _textStyle,
      lineWrap: lineWrap,
      lineNumberStyle: _lineNumberStyle,
      innerPadding: _innerPadding,
      onContextMenu: _showContextMenu,
      scrollbarBuilder: (context, details, child) => FloatingScrollbar(
        controller: details.controller,
        thumbVisibility: true,
        hintBuilder: (_) =>
            '${details.firstVisibleLine.value} / ${widget.controller.lineCount}',
        child: _NoMouseDragScroll(child: child),
      ),
      finderBuilder: (context, findController) => FindPanel(
        controller: findController,
        topInset: widget.topInset ?? context.appBarInset,
        readOnly: widget.readOnly,
      ),
    );
  }
}

// The app's desktop behavior would also pan the view on a mouse drag-select.
class _NoMouseDragScroll extends StatelessWidget {
  const _NoMouseDragScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: {...behavior.dragDevices}..remove(PointerDeviceKind.mouse),
      ),
      child: child,
    );
  }
}

// atom-one colours keys and numbers alike and has no entry for several scopes
// highlight.js emits, which then render as plain text. Mapping them onto the
// palette gives each kind of token one colour in every language.
Map<String, TextStyle> _highlightTheme(
  ColorScheme colorScheme,
  EditorLanguage language,
) {
  final palette = colorScheme.brightness == Brightness.dark
      ? atomOneDarkTheme
      : atomOneLightTheme;
  return {
    ...palette,
    'attr': palette['name']!,
    'property': palette['name']!,
    'title.function': palette['title']!,
    'title.class': palette['title.class_']!,
    'title.class.inherited': palette['title.class_']!,
    'variable.language': palette['built_in']!,
    // The JSON grammar nests `true`, `false` and `null` as keywords in a literal.
    if (language == EditorLanguage.json) 'keyword': palette['literal']!,
    'root': TextStyle(
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surface,
    ),
  };
}

const _findButtonSize = TonalButtonSize.bar;
const double _findRowGap = 8;
const double _findInlineMinWidth = 440;
const _findPanelPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

class FindPanel extends StatelessWidget implements PreferredSizeWidget {
  final FindController controller;
  final bool readOnly;
  final double topInset;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    this.topInset = 0,
  });

  bool get _showReplace => controller.isReplaceMode && !readOnly;

  double get height {
    final rows = _showReplace ? 2 : 1;
    return _findButtonSize.button * rows +
        _findRowGap * (rows - 1) +
        _findPanelPadding.vertical;
  }

  @override
  Size get preferredSize => Size(double.infinity, height + topInset);

  @override
  Widget build(BuildContext context) {
    // On macOS a focused text field hands Escape to the input method, which
    // comes back as a DismissIntent rather than a key event.
    return Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) => controller.hide(),
        ),
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): controller.hide,
          const SingleActivator(LogicalKeyboardKey.enter, shift: true):
              controller.previous,
        },
        child: Container(
          margin: EdgeInsets.only(top: topInset),
          padding: _findPanelPadding,
          color: context.surfaceLevel.colorOf(context.colorScheme),
          child: GooSurface(
            color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
            child: LayoutBuilder(builder: _buildRows),
          ),
        ),
      ),
    );
  }

  // A table, so the replace field lines up with the find field above it
  // whatever width the localized replace labels take. Too narrow for the
  // buttons beside the field, they move under it.
  Widget _buildRows(BuildContext context, BoxConstraints constraints) {
    final appLocalizations = KitLocalizations.of(context);
    final hasMatches = controller.matchCount > 0;
    final findInput = _buildFindInput(context);
    final controls = Row(
      children: [
        TonalButtonGroup(
          size: _findButtonSize,
          children: [
            IconButton(
              tooltip: appLocalizations.previousMatch,
              onPressed: hasMatches ? controller.previous : null,
              icon: const GlyphIcon(AppGlyphs.chevronUp),
            ),
            IconButton(
              tooltip: appLocalizations.nextMatch,
              onPressed: hasMatches ? controller.next : null,
              icon: const GlyphIcon(AppGlyphs.chevronDown),
            ),
          ],
        ),
        if (!readOnly) ...[
          const SizedBox(width: 8),
          _FindBarButton(
            glyph: AppGlyphs.swap,
            tooltip: appLocalizations.replace,
            selected: _showReplace,
            onPressed: controller.toggleReplaceMode,
          ),
        ],
        const Spacer(),
        const SizedBox(width: 8),
        _FindBarButton(
          glyph: AppGlyphs.close,
          tooltip: appLocalizations.close,
          onPressed: controller.hide,
        ),
      ],
    );
    final replaceActions = TonalButtonGroup(
      size: _findButtonSize,
      children: [
        FilledButton(
          onPressed: hasMatches ? controller.replace : null,
          child: Text(appLocalizations.replace),
        ),
        FilledButton(
          onPressed: hasMatches ? controller.replaceAll : null,
          child: Text(appLocalizations.replaceAll),
        ),
      ],
    );
    final inlineMinWidth = MediaQuery.textScalerOf(
      context,
    ).scale(_findInlineMinWidth);
    if (constraints.maxWidth < inlineMinWidth) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _findRowGap,
        children: [
          findInput,
          controls,
          if (_showReplace) ...[
            _buildReplaceInput(context),
            Align(alignment: AlignmentDirectional.centerEnd, child: replaceActions),
          ],
        ],
      );
    }
    return Table(
      columnWidths: const {0: FlexColumnWidth(), 1: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            findInput,
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: controls,
            ),
          ],
        ),
        if (_showReplace)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: _findRowGap),
                child: _buildReplaceInput(context),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  top: _findRowGap,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: replaceActions,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFindInput(BuildContext context) {
    final String? result;
    if (controller.findInputController.text.isEmpty) {
      result = null;
    } else if (controller.matchCount == 0) {
      result = KitLocalizations.of(context).none;
    } else {
      result = '${controller.currentMatchIndex + 1}/${controller.matchCount}';
    }
    return _FindField(
      glyph: AppGlyphs.search,
      hintText: KitLocalizations.of(context).search,
      controller: controller.findInputController,
      focusNode: controller.findInputFocusNode,
      onSubmitted: () {
        controller.next();
        controller.findInputFocusNode.requestFocus();
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: Text(
                result,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
          _FindOptionToggle(
            glyph: AppGlyphs.matchCase,
            tooltip: KitLocalizations.of(context).matchCase,
            selected: controller.caseSensitive,
            onPressed: controller.toggleCaseSensitive,
          ),
          const SizedBox(width: 2),
          _FindOptionToggle(
            glyph: AppGlyphs.regex,
            tooltip: KitLocalizations.of(context).regex,
            selected: controller.isRegex,
            onPressed: controller.toggleRegex,
          ),
        ],
      ),
    );
  }

  Widget _buildReplaceInput(BuildContext context) {
    return _FindField(
      glyph: AppGlyphs.swap,
      hintText: KitLocalizations.of(context).replace,
      controller: controller.replaceInputController,
      focusNode: controller.replaceInputFocusNode,
      onSubmitted: () {
        if (controller.matchCount == 0) {
          return;
        }
        controller.replace();
        controller.replaceInputFocusNode.requestFocus();
      },
    );
  }
}

/// A search field among the bar's buttons, on the surface they share.
class _FindField extends StatelessWidget {
  const _FindField({
    required this.glyph,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    this.trailing,
  });

  final Glyph glyph;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ElasticPress(
      child: GooPane(
        child: SearchField(
          height: _findButtonSize.button,
          glyph: glyph,
          hintText: hintText,
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          trailing: trailing,
        ),
      ),
    );
  }
}

class _FindOptionToggle extends StatelessWidget {
  const _FindOptionToggle({
    required this.glyph,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ElasticPress(
      child: IconButton(
        tooltip: tooltip,
        isSelected: selected,
        onPressed: onPressed,
        style: ButtonStyle.from(
          backgroundColor: selected ? colorScheme.primary : null,
          foregroundColor: selected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          fixedSize: Size.square(TonalButtonSize.compact.button),
          minimumSize: Size.square(TonalButtonSize.compact.button),
          padding: EdgeInsets.zero,
          iconSize: TonalButtonSize.compact.icon,
          visualDensity: VisualDensity.standard,
          tapTargetSize: TapTargetSize.shrinkWrap,
          pressLook: PressLook.none,
          ringStandsOff: selected,
        ),
        icon: AnimatedGlyph(glyph: glyph, filled: selected),
      ),
    );
  }
}

class _FindBarButton extends StatelessWidget {
  const _FindBarButton({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return TonalButtonTheme(
      size: _findButtonSize,
      child: ElasticPress(
        child: IconButton(
          tooltip: tooltip,
          isSelected: selected,
          onPressed: onPressed,
          style: selected
              ? ButtonStyle.from(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  ringStandsOff: true,
                )
              : null,
          icon: GlyphIcon(glyph),
        ),
      ),
    );
  }
}
