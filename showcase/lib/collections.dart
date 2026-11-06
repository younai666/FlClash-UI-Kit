import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'section.dart';

class CollectionsDemo extends StatefulWidget {
  const CollectionsDemo({super.key});
  @override
  State<CollectionsDemo> createState() => _CollectionsDemoState();
}

class _CollectionsDemoState extends State<CollectionsDemo> {
  var _items = [0, 1, 2, 3, 4];
  var _next = 5;
  var _sorting = false;
  final _jump = ListController();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _jump.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _reorder(int from, int to) => setState(() {
    final item = _items.removeAt(from);
    _items.insert(to, item);
  });
  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'PrismReorderableListView / SortableItem',
        source: 'prism_ui/lib/prism_list.dart · sortable.dart',
        code: 'SortModeScope(sorting: sorting, child: PrismReorderableListView(\n  itemCount: items.length, itemBuilder: buildItem, onReorderItem: reorder,\n  proxyDecorator: (child, index, animation) => Surface.transparent(child: child)))',
        child: Column(
          children: [
            ListRow(
              title: const Text('开启排序后拖动行或手柄'),
              trailing: Switch(
                value: _sorting,
                onChanged: (v) => setState(() => _sorting = v),
              ),
            ),
            SizedBox(
              height: 260,
              child: SortModeScope(
                sorting: _sorting,
                child: PrismReorderableListView(
                  itemCount: _items.length,
                  onReorderItem: _reorder,
                  proxyDecorator: (child, index, animation) =>
                      Surface.transparent(child: child),
                  itemBuilder: (_, index) => SortableItem(
                    key: ValueKey(_items[index]),
                    index: index,
                    child: ItemPositionProvider(
                      position: ItemPosition.get(index, _items.length),
                      child: DecorationListItem(
                        title: Text('可重排条目 ${_items[index]}'),
                        trailing: SortHandle(index: index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'KeyedAnimatedList / AnimatedEntries',
        source: 'prism_ui/lib/keyed_animated_list.dart · animated_entries.dart',
        code: r'KeyedAnimatedList<int>(items: items, keyOf: (v) => v, itemBuilder: (_, v) => ListRow(title: Text("$v")))',
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      setState(() => _items = [..._items, _next++]),
                  child: const Text('添加'),
                ),
                TextButton(
                  onPressed: _items.isEmpty
                      ? null
                      : () => setState(() => _items = _items.skip(1).toList()),
                  child: const Text('删除首项'),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _items = _items.reversed.toList()),
                  child: const Text('反转'),
                ),
              ],
            ),
            SizedBox(
              height: 220,
              child: KeyedAnimatedList<int>(
                items: _items,
                keyOf: (v) => v,
                itemBuilder: (_, value) => ListRow(title: Text('动态条目 $value')),
              ),
            ),
            AnimatedEntries(
              grouped: true,
              children: [
                for (final value in _items.take(3))
                  ListItem(key: ValueKey(value), title: Text('出现顺序 $value')),
              ],
            ),
          ],
        ),
      ),
      DemoSection(
        title: '高性能 Sliver / FloatingScrollbar',
        source: 'prism_ui/lib/sliver_list/ · scroll.dart',
        code: 'listController.jumpToItem(index: 900, scrollController: scroll, alignment: 0.5);\nPrismListView(listController: listController, controller: scroll, itemCount: 1000, itemBuilder: build)',
        child: Column(
          children: [
            TextButton(
              onPressed: () => _jump.jumpToItem(
                index: 900,
                scrollController: _scroll,
                alignment: 0.5,
              ),
              child: const Text('跳转到第 901 行'),
            ),
            SizedBox(
              height: 230,
              child: FloatingScrollbar(
                controller: _scroll,
                hintBuilder: (fraction) => '${(fraction * 999).round() + 1}',
                child: PrismListView(
                  controller: _scroll,
                  listController: _jump,
                  itemCount: 1000,
                  estimatedItemExtent: 56,
                  itemBuilder: (_, i) => ListRow(title: Text('虚拟列表 ${i + 1}')),
                ),
              ),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'SliverCollapsibleSection',
        source: 'prism_ui/lib/collapsible_section.dart',
        code: 'CustomScrollView(slivers: [SliverCollapsibleSection(label: label, itemCount: 6, itemBuilder: build)])',
        child: SizedBox(
          height: 260,
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleSection(
                label: '点击展开/收起',
                itemCount: 6,
                itemBuilder: (_, index) =>
                    DecorationListItem(title: Text('折叠组 $index')),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

typedef SampleRecord = ({int id, String host, int delay});

class RecordsDemo extends StatefulWidget {
  const RecordsDemo({super.key});
  @override
  State<RecordsDemo> createState() => _RecordsDemoState();
}

class _RecordsDemoState extends State<RecordsDemo> {
  List<SampleRecord> _rows = List.generate(
    30,
    (i) => (id: i, host: 'node-${i + 1}.example.com', delay: 20 + i * 17),
  );
  int _next = 30;
  Map<String, double> _widths = {};
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          context.contentTopPadding + 12,
          20,
          12,
        ),
        child: Column(
          children: [
            const Text('本地示例记录。宽屏可点击表头三态排序、拖动列边界，窄屏自动使用记录卡片。'),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => setState(() {
                    _rows = [
                      ..._rows.skip(1),
                      (
                        id: _next,
                        host: 'node-${_next++}.example.com',
                        delay: 42,
                      ),
                    ];
                  }),
                  child: const Text('追加并裁掉首项'),
                ),
                Text('已记录列宽：${_widths.length}'),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: RecordTableFrame<SampleRecord>(
          tableId: 'showcase-records',
          items: _rows,
          initialColumnWidths: _widths,
          onColumnWidthsChanged: (widths) =>
              setState(() => _widths = {...widths}),
          columnsOf: (_) => [
            RecordColumn(
              const TableColumn('id', '编号', width: 90),
              cell: (_, item) => RecordCellText('${item.id}'),
              sortKey: (item) => item.id,
            ),
            RecordColumn(
              const TableColumn('host', '主机', flex: 1),
              cell: (_, item) => RecordCellText(item.host),
              sortKey: (item) => item.host,
            ),
            RecordColumn(
              const TableColumn('delay', '延迟 (ms)', width: 150, end: true),
              cell: (_, item) => RecordCellText('${item.delay}'),
              sortKey: (item) => item.delay,
            ),
          ],
          builder: (context, table, items) => RecordFeedList<SampleRecord>(
            items: items,
            keyOf: (item) => ValueKey(item.id),
            estimatedItemExtent: table?.rowHeight ?? 72,
            itemBuilder: (item, striped, latest) => table == null
                ? ListRow(
                    title: Text(item.host),
                    subtitle: Text('编号 ${item.id}'),
                    trailing: Text('${item.delay} ms'),
                  )
                : RecordTableRow(
                    table: table,
                    cells: table.cellsOf(context, item),
                    striped: striped,
                    onTap: () => notifyDemo(context, latest().host),
                  ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          '源码与完整调用：showcase/lib/collections.dart · src/widgets/record_table.dart · record_feed_list.dart',
        ),
      ),
    ],
  );
}
