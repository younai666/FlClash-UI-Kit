import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'section.dart';

class ApplicationDemo extends StatelessWidget {
  const ApplicationDemo({super.key});

  @override
  Widget build(BuildContext context) => DemoList(children: [
    DemoSection(
      title: '独立页面 / 保存与筛选',
      source: 'src/forms/list_editor_page.dart · nested_form_sheet.dart · records/filter.dart',
      code: 'ListEditorPage<String, String>(items: items, idOf: (v) => v, onReorder: reorder, onAdd: add, emptyLabel: "Empty", title: "Editor", itemBuilder: row);\nshowNestedFormSheet<String>(context: context, currentValue: () => draft, formBuilder: buildForm);',
      child: Wrap(spacing: 12, runSpacing: 12, children: [
        FilledButton(onPressed: () => BaseNavigator.push(context, const ListEditorExample()), child: const Text('打开列表编辑器')),
        FilledButton(onPressed: () => BaseNavigator.push(context, const RecordFilterExample()), child: const Text('打开记录筛选页')),
        FilledButton(onPressed: () {
          var draft = '初始标题';
          showNestedFormSheet<String>(context: context, currentValue: () => draft, formBuilder: (_) => _DraftForm(onChanged: (v) => draft = v));
        }, child: const Text('编辑未保存草稿')),
      ]),
    ),
    const DemoSection(title: '批量输入 / 字段验证 / 等宽标签',
      source: 'src/input · src/forms/batch_section.dart · filter_regex_text.dart',
      code: 'BatchSection<String>(batch: batch, controller: controller, parsed: parsed, onChanged: parse);\n'
        'EntryDialog<String>(title: "Value", valueField: Field(label: "Value", value: ""), toEntry: (v) => v.trim());\n'
        r'FilterRegexText("^example[0-9]+$");', child: BatchInputExample()),
    DemoSection(
      title: 'ChipTitle / SubscriptionInfo / LastUpdateTimeText',
      source: 'src/widgets/chip_title.dart · subscription_info_view.dart · last_update_time_text.dart',
      code: 'ChipTitle(title: "订阅", chip: "4", expire: expires);\nSubscriptionInfoView(subscriptionInfo: info);\nSubscriptionInfoDetailView(subscriptionInfo: info);\nLastUpdateTimeText(lastUpdateDate: updated);',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ChipTitle(title: '订阅信息与自适应标题', chip: '4', expire: DateTime(2100)),
        const SizedBox(height: 12),
        const SubscriptionInfoView(subscriptionInfo: SubscriptionInfo(upload: 1024 * 1024 * 18, download: 1024 * 1024 * 220, total: 1024 * 1024 * 1024, expire: 4102444800)),
        LastUpdateTimeText(lastUpdateDate: DateTime.now().subtract(const Duration(hours: 2))),
        const SubscriptionInfoDetailView(subscriptionInfo: SubscriptionInfo(upload: 1024 * 1024 * 18, download: 1024 * 1024 * 220, total: 1024 * 1024 * 1024, expire: 4102444800)),
        DetailRow.text(title: '可复制的详情', value: 'example.invalid'),
      ]),
    ),
  ]);
}

class BatchInputExample extends StatefulWidget {
  const BatchInputExample({super.key});
  @override
  State<BatchInputExample> createState() => _BatchInputExampleState();
}
class _BatchInputExampleState extends State<BatchInputExample> {
  final _controller = TextEditingController();
  ParsedInput<String>? _parsed;
  String? _entry;
  ParsedInput<String> _parse(String text) {
    final values = text.split('\n').map((v) => v.trim()).where((v) => v.isNotEmpty).toSet();
    return ParsedInput(entries: values.where((v) => v != 'Existing').toList(),
      skippedExisting: values.contains('Existing') ? 1 : 0, issues: const []);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    BatchSection(batch: BatchInput<String>(label: '条目', formatTip: '每行一个条目；Existing 会被跳过',
      parse: _parse, issueMessage: (issue) => issue.raw), controller: _controller,
      parsed: _parsed, onChanged: (value) => setState(() => _parsed = _parse(value))),
    Text('实际解析：${_parsed?.entries.join(", ") ?? "尚未输入"}'),
    const FilterRegexText(r'^example[0-9]+$'),
    TextButton(onPressed: () async {
      final entry = await showFloatingDialog<String>(context: context,
        child: EntryDialog<String>(title: '添加值', valueField: const Field(label: '值', value: ''), toEntry: (value) => value.trim()));
      if (mounted && entry != null) setState(() => _entry = entry);
    }, child: const Text('验证并返回输入值')),
    if (_entry != null) Text('返回值：$_entry'),
  ]);
}

class ListEditorExample extends StatefulWidget {
  const ListEditorExample({super.key});
  @override
  State<ListEditorExample> createState() => _ListEditorExampleState();
}

class _ListEditorExampleState extends State<ListEditorExample> {
  var _items = ['Alpha', 'Beta', 'Gamma', 'Delta'];
  Future<void> _add() async {
    final value = await showFloatingDialog<String>(context: context, child: InputDialog(
      title: '添加条目', value: '', labelText: '名称',
      validator: (v) => v == null || v.trim().isEmpty ? '请输入名称' : _items.contains(v.trim()) ? '名称已存在' : null,
    ));
    if (mounted && value != null) setState(() => _items = [..._items, value.trim()]);
  }
  @override
  Widget build(BuildContext context) => ListEditorPage<String, String>(
    title: '独立列表编辑', items: _items, idOf: (v) => v, emptyLabel: '暂无条目',
    onAdd: _add,
    onReorder: (from, to) => setState(() => _items = _items.copyAndReorder(from, to)),
    onDelete: (ids) => setState(() => _items = _items.where((v) => !ids.contains(v)).toList()),
    searchFieldsOf: (v) => [v],
    itemBuilder: (context, item, index, editing, selected, toggle) => SelectedDecorationListItem(
      title: Text(item), isEditing: editing, isSelected: selected, onSelected: toggle, onPressed: toggle,
    ),
  );
}

class _DraftForm extends StatefulWidget {
  const _DraftForm({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  State<_DraftForm> createState() => _DraftFormState();
}

class _DraftFormState extends State<_DraftForm> {
  final _text = TextEditingController(text: '初始标题');
  String? _error;
  @override
  void initState() { super.initState(); NestedFormSheet.bindSave(context, _save); }
  void _save() {
    if (_text.text.trim().isEmpty) { setState(() => _error = '标题不能为空'); return; }
    context.safeNestedPop();
  }
  @override
  void dispose() { _text.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FormPage(
    title: '未保存草稿', error: _error, onSave: _save,
    children: [generateSection(items: [FormRow(title: '标题', trailing: FormRowTextField(controller: _text, onChanged: widget.onChanged))]), const Text('修改后关闭，可选择保存、放弃，或返回继续编辑。')],
  );
}

typedef _Event = ({String id, String app, String protocol});
const _events = <_Event>[
  (id: '1', app: 'Browser', protocol: 'TCP'),
  (id: '2', app: 'Terminal', protocol: 'TCP'),
  (id: '3', app: 'Browser', protocol: 'UDP'),
  (id: '4', app: 'Editor', protocol: 'UDP'),
];

class RecordFilterExample extends StatefulWidget {
  const RecordFilterExample({super.key});
  @override
  State<RecordFilterExample> createState() => _RecordFilterExampleState();
}

class _RecordFilterExampleState extends State<RecordFilterExample> {
  late final _filters = RecordFilterController<_Event>(
    facets: [RecordFacet(RecordFacetKind.network, (v) => [v.protocol], offered: true), RecordFacet(RecordFacetKind.app, (v) => [v.app])],
    groupers: [RecordGrouper(RecordGrouping.app, (v) => v.app)],
  )..offer(_events)..addListener(_changed);
  void _changed() => setState(() {});
  @override
  void initState() { super.initState(); _filters; }
  @override
  void dispose() { _filters.dispose(); super.dispose(); }

  Widget _row(BuildContext context, _Event event) => RecordListItem(
    header: RecordHeader(trailing: RecordLabel(label: event.app), children: [RecordLabel(label: event.protocol, onPressed: () => RecordFilterScope.add(context, RecordFilter(RecordFacetKind.network, event.protocol))), const RecordTimestamp('12:30:00')]),
    body: Row(spacing: 8, children: [Text(event.app, style: RecordTextStyles.of(context).title), const RecordArrow(), Expanded(child: Text('event ${event.id}', style: RecordTextStyles.of(context).secondary))]),
  );

  @override
  Widget build(BuildContext context) {
    final shown = _filters.apply(_events);
    final groups = _filters.groupsOf(shown);
    return RecordFilterScope(onFilter: _filters.add, child: Scaffold(
      title: '记录筛选与分组', keywords: _filters.keywordsOf(pinned: true), menuItems: _filters.menuItems(context, pinned: true),
      body: Builder(builder: (context) {
        final padding = EdgeInsets.only(top: context.contentTopPadding + 8, bottom: 32);
        if (groups != null) return RecordGroupedList(groups: groups, grouping: _filters.value.grouping!, padding: padding, itemBuilder: (context, item, index) => _row(context, item));
        return RecordFeedList(items: shown, keyOf: (v) => ValueKey(v.id), padding: padding, gap: recordListGap, estimatedItemExtent: recordListEstimatedExtent, itemBuilder: (item, striped, latest) => Builder(builder: (context) => _row(context, latest())));
      }),
    ));
  }
}

class ThemePreviewDemo extends StatefulWidget {
  const ThemePreviewDemo({super.key});
  @override
  State<ThemePreviewDemo> createState() => _ThemePreviewDemoState();
}

class _ThemePreviewDemoState extends State<ThemePreviewDemo> {
  bool _floating = true;
  bool _glass = false;
  TabAnimation _animation = TabAnimation.slide;
  @override
  Widget build(BuildContext context) => DemoList(children: [
    DemoSection(title: 'ThemeLivePreview / MiniScreen / MiniSplitScreen', source: 'src/theme_preview.dart',
      code: 'ThemeLivePreview(floatingBar: floating, liquidGlass: glass, tabAnimation: animation);\nMiniSplitScreen(light: MiniScreen(colorScheme: light, floatingBar: true), dark: MiniScreen(colorScheme: dark, floatingBar: true));',
      child: Column(children: [
        ListItem.toggle(title: const Text('浮动导航栏'), value: _floating, onChanged: (v) => setState(() => _floating = v)),
        ListItem.toggle(title: const Text('缩略玻璃绘制'), value: _glass, onChanged: (v) => setState(() => _glass = v)),
        SegmentedControl<TabAnimation>(segments: const [(TabAnimation.slide, '滑动'), (TabAnimation.fade, '淡入')], value: _animation, onChanged: (v) => setState(() => _animation = v)),
        ThemeLivePreview(floatingBar: _floating, liquidGlass: _glass, tabAnimation: _animation),
        SizedBox(width: 168, height: 300, child: MiniSplitScreen(light: MiniScreen(colorScheme: seededColorScheme(seedColor: const Color(0xFF007AFF), brightness: Brightness.light), floatingBar: _floating), dark: MiniScreen(colorScheme: seededColorScheme(seedColor: const Color(0xFF007AFF), brightness: Brightness.dark), floatingBar: _floating))),
      ])),
    DemoSection(title: 'PreviewChoiceGroup / MiniScreenThumb', source: 'src/theme_preview.dart', code: 'PreviewChoiceGroup<bool>(info: const Info(label: "布局"), choices: choices, value: floating, onChanged: update);',
      child: PreviewChoiceGroup<bool>(info: const Info(label: '导航布局'), choices: [for (final floating in [true, false]) PreviewChoice(value: floating, label: floating ? '浮动' : '停靠', pictogram: MiniScreenThumb(screen: MiniScreen(colorScheme: context.colorScheme, floatingBar: floating)))], value: _floating, onChanged: (v) => setState(() => _floating = v))),
  ]);
}
