// Derived from chen08209/FlClash, lib/features/form/list_edit_view.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

/// Public for `MapEditView`, whose entries are entered in a form.
abstract class EditViewState<W extends StatefulWidget, T> extends State<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  Set<String> _selected = {};

  String get title;

  String? get description;

  List<T> get initialEntries;

  String idOf(T entry);

  Widget buildTitle(T entry);

  Widget? buildSubtitle(T entry);

  bool sameEntries(List<T> a, List<T> b);

  Object popResult(List<T> entries);

  @protected
  List<T> get entries => _entries;

  /// Adds when [entry] is null and edits it otherwise.
  Future<T?> showEntryEditor(T? entry);

  bool get hasQuickEdit => false;

  Future<void> showQuickEdit(List<T> entries, ValueChanged<List<T>> onChanged);

  @override
  void initState() {
    super.initState();
    _entries = List<T>.from(initialEntries);
    _initialEntries = List<T>.from(_entries);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    _entries = _entries.copyAndReorder(oldIndex, newIndex);
    setState(() {});
  }

  void _handleSelected(T entry) {
    setState(() {
      _selected = Set<String>.from(_selected)..addOrRemove(idOf(entry));
    });
  }

  void _handleSelectAll() {
    final ids = _entries.map(idOf).toSet();
    setState(() {
      _selected = _selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleAdd() async {
    final added = await showEntryEditor(null);
    if (!mounted || added == null) return;
    _entries = [..._entries, added];
    setState(() {});
  }

  Future<void> _handleQuickEdit() {
    return showQuickEdit(_entries, (entries) {
      if (!mounted) return;
      _entries = entries;
      setState(() {});
    });
  }

  Future<void> _handleEdit(T entry) async {
    final next = await showEntryEditor(entry);
    if (!mounted || next == null) return;
    final id = idOf(entry);
    _entries = [
      for (final current in _entries)
        if (idOf(current) == id) next else current,
    ];
    setState(() {});
  }

  Future<void> _handleDelete() async {
    final res = await showKitMessage(
      context,
      message: TextSpan(text: KitLocalizations.of(context).deleteMultipTip(title)),
      destructive: true,
      confirmText: KitLocalizations.of(context).delete,
    );
    if (res != true || !mounted) {
      return;
    }
    _entries = _entries
        .where((entry) => !_selected.contains(idOf(entry)))
        .toList();
    _selected = {};
    setState(() {});
  }

  void _handleSave() {
    Navigator.of(context).pop(popResult(_entries));
  }

  Future<void> _handleBack() async {
    final res = await showKitSaveChanges(context);
    if (res == null || !mounted) {
      return;
    }
    if (res) {
      _handleSave();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleReset() async {
    final res = await showKitMessage(
      context,
      message: TextSpan(text: KitLocalizations.of(context).resetPageChangesTip),
      destructive: true,
      confirmText: KitLocalizations.of(context).reset,
    );
    if (!mounted || res != true) {
      return;
    }
    _entries = _initialEntries;
    setState(() {});
  }

  Widget _buildEntry({
    required T entry,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderDragStartListener(
      key: ValueKey(idOf(entry)),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: SelectedDecorationListItem(
          title: buildTitle(entry),
          subtitle: buildSubtitle(entry),
          isSelected: isSelected,
          isEditing: isEditing,
          onSelected: () {
            _handleSelected(entry);
          },
          onPressed: () {
            _handleEdit(entry);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final selected = _selected;
    final isEditing = selected.isNotEmpty;
    final hasChanges = !sameEntries(_entries, _initialEntries);
    return PopGuard(
      onPop: isEditing
          ? (_) {
              setState(() => _selected = {});
              return false;
            }
          : hasChanges
          ? (_) {
              _handleBack();
              return false;
            }
          : null,
      child: Scaffold(
        title: title,
        confirmationAction: !isEditing && hasChanges
            ? IconButtonData(
                glyph: AppGlyphs.check,
                onPressed: _handleSave,
                tooltip: appLocalizations.save,
              )
            : null,
        selectionActions: [
          if (isEditing) ...[
            IconButtonData(
              glyph: AppGlyphs.delete,
              tooltip: appLocalizations.delete,
              onPressed: _handleDelete,
            ),
            IconButtonData(
              glyph: AppGlyphs.selectAll,
              tooltip: appLocalizations.selectAll,
              onPressed: _handleSelectAll,
            ),
          ],
        ],
        iconActions: [
          if (!isEditing && hasChanges)
            IconButtonData(
              glyph: AppGlyphs.reset,
              tooltip: appLocalizations.reset,
              onPressed: _handleReset,
            ),
        ],
        actions: [
          if (!isEditing)
            ListEditorAddAction(
              onAdd: _handleAdd,
              onQuickEdit: hasQuickEdit ? _handleQuickEdit : null,
            ),
        ],
        body: NullStatusSwitcher(
          isEmpty: _entries.isEmpty,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            description: description,
            illustration: NullStatusIllustration.data,
          ),
          child: PrismReorderableListView(
            padding: EdgeInsets.only(
              bottom: 16 + context.bottomInset,
              top: context.contentTopPadding,
              left: 16,
              right: 16,
            ),
            itemCount: _entries.length,
            footer: description == null ? null : ListFooter(text: description!),
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _buildEntry(
                entry: entry,
                index: index,
                length: _entries.length,
                isSelected: selected.contains(idOf(entry)),
                isEditing: isEditing,
              );
            },
            proxyDecorator: (child, index, animation) {
              final entry = _entries[index];
              return commonProxyDecorator(
                _buildEntry(
                  entry: entry,
                  index: index,
                  length: _entries.length,
                  isSelected: selected.contains(idOf(entry)),
                  isEditing: isEditing,
                ),
                index,
                animation,
              );
            },
            onReorderItem: _handleReorder,
          ),
        ),
      ),
    );
  }
}

class ConfigListEditItem extends StatelessWidget {
  const ConfigListEditItem({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
    this.itemMaxLength,
    this.itemValidator,
    this.description,
    this.subtitle,
    this.leading,
    this.onQuickEdit,
  });

  final List<String> value;
  final ConfigLabel title;
  final ValueChanged<List<String>> onChanged;
  final int? itemMaxLength;
  final ConfigValidator? itemValidator;
  final ConfigLabel? description;
  final ConfigLabel? subtitle;
  final Widget? leading;
  final Future<void> Function(List<String> items, ValueChanged<List<String>> onChanged)? onQuickEdit;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final subtitle = this.subtitle;
    final label = title(appLocalizations);
    final itemValidator = this.itemValidator;
    return ListItem.open(
      leading: leading,
      title: Text(label),
      subtitle: Text(
        subtitle != null
            ? subtitle(appLocalizations)
            : value.isEmpty
            ? appLocalizations.none
            : appLocalizations.itemsCount(value.length),
      ),
      widget: ListEditView(
        title: label,
        description: description?.call(appLocalizations),
        items: value,
        itemMaxLength: itemMaxLength,
        itemValidator: itemValidator == null
            ? null
            : (item) => itemValidator(item, appLocalizations),
        titleBuilder: (item) => Text(item),
        onQuickEdit: onQuickEdit,
      ),
      onChanged: (items) {
        if (items is! List) {
          return;
        }
        final next = List<String>.from(items);
        if (!listEquals(next, value)) {
          onChanged(next);
        }
      },
    );
  }
}

class ListEditView extends StatefulWidget {
  final String title;
  final String? description;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final int? itemMaxLength;
  final String? Function(String item)? itemValidator;
  final Future<void> Function(
    List<String> items,
    ValueChanged<List<String>> onChanged,
  )? onQuickEdit;

  const ListEditView({
    super.key,
    required this.title,
    this.description,
    required this.items,
    required this.titleBuilder,
    this.itemMaxLength,
    this.itemValidator,
    this.onQuickEdit,
  });

  @override
  State<ListEditView> createState() => _ListEditViewState();
}

class _ListEditViewState extends EditViewState<ListEditView, String> {
  @override
  String get title => widget.title;

  @override
  String? get description => widget.description;

  @override
  List<String> get initialEntries => widget.items;

  @override
  String idOf(String entry) => entry;

  @override
  Widget buildTitle(String entry) => widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(String entry) {
    if (widget.itemValidator?.call(entry) case final error?) {
      return Text(error, style: TextStyle(color: context.colorScheme.error));
    }
    return null;
  }

  @override
  bool sameEntries(List<String> a, List<String> b) =>
      stringListEquality.equals(a, b);

  @override
  Object popResult(List<String> entries) => entries;

  @override
  Future<String?> showEntryEditor(String? entry) {
    return showListEntryDialog(
      context,
      entries: _entries,
      entry: entry,
      itemMaxLength: widget.itemMaxLength,
      itemValidator: widget.itemValidator,
    );
  }

  @override
  bool get hasQuickEdit => widget.onQuickEdit != null;

  @override
  Future<void> showQuickEdit(
    List<String> entries,
    ValueChanged<List<String>> onChanged,
  ) {
    final runner = widget.onQuickEdit;
    if (runner == null) return Future.value();
    return runner(entries, onChanged);
  }
}

Future<String?> showListEntryDialog(
  BuildContext context, {
  required List<String> entries,
  String? entry,
  String? valueLabel,
  int? itemMaxLength,
  String? Function(String item)? itemValidator,
}) {
  final appLocalizations = KitLocalizations.of(context);
  final label = valueLabel ?? appLocalizations.value;

  String? validator(String? value) {
    final parsed = parseListInput(value ?? '', maxLength: itemMaxLength);
    if (!parsed.isValid) {
      return appLocalizations.maxLengthTip(label, itemMaxLength!);
    }
    if (parsed.entries.isEmpty) {
      return appLocalizations.emptyTip(label);
    }
    if (parsed.entries.length > 1) {
      return appLocalizations.singleValueTip(label);
    }
    final next = parsed.entries.single;
    if (next != entry && entries.contains(next)) {
      return appLocalizations.existsTip(label);
    }
    return itemValidator?.call(next);
  }

  return showFloatingDialog<String>(
    context: context,
    child: EntryDialog<String>(
      title: entry == null ? appLocalizations.add : appLocalizations.edit,
      valueField: Field(label: label, value: entry ?? '', validator: validator),
      valueMaxLength: itemMaxLength,
      toEntry: (value) => parseListInput(value).entries.single,
    ),
  );
}
