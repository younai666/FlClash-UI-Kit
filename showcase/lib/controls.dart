import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'section.dart';

class ControlsDemo extends StatefulWidget {
  const ControlsDemo({super.key});
  @override
  State<ControlsDemo> createState() => _ControlsDemoState();
}

class _ControlsDemoState extends State<ControlsDemo> {
  bool _on = true;
  bool _checked = false;
  bool _selected = false;
  bool _chip = true;
  double _value = 0.35;
  int _segment = 0;
  int _presses = 0;
  void _press() => setState(() => _presses++);
  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'Button / TonalButton / Tooltip',
        source: 'prism_ui/lib/common_button.dart · button.dart',
        code: "FilledButton(onPressed: onPressed, child: const Text('确认'))",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(onPressed: _press, child: const Text('确认')),
                OutlinedButton(onPressed: _press, child: const Text('描边')),
                TextButton(onPressed: _press, child: const Text('文本')),
                const FilledButton(onPressed: null, child: Text('禁用')),
                IconButton(
                  onPressed: _press,
                  tooltip: '收藏',
                  icon: AnimatedGlyph(glyph: AppGlyphs.star, filled: _selected),
                ),
                TonalButton(
                  onPressed: _press,
                  glyph: AppGlyphs.add,
                  label: '添加',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('已触发 $_presses 次'),
            TonalButtonGroup(
              children: [
                TonalButton(
                  onPressed: _press,
                  glyph: AppGlyphs.copy,
                  label: '复制',
                ),
                TonalButton(
                  onPressed: _press,
                  glyph: AppGlyphs.paste,
                  label: '粘贴',
                ),
              ],
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'Card / SettingTextCard / Chip',
        source:
            'prism_ui/lib/card.dart · chip.dart; src/ui/setting_text_card.dart',
        code: 'Card(isSelected: selected, fillsSelection: true, onPressed: toggle, child: content)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              isSelected: _selected,
              fillsSelection: true,
              onPressed: () => setState(() => _selected = !_selected),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text('点击切换选中状态'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              isError: true,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('错误卡片'),
              ),
            ),
            const SizedBox(height: 8),
            SettingTextCard(
              '设置预览',
              isSelected: _selected,
              onPressed: () => setState(() => _selected = !_selected),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: '可切换',
                  selected: _selected,
                  onPressed: () => setState(() => _selected = !_selected),
                ),
                if (_chip)
                  Chip(
                    label: '可移除',
                    onDeleted: () => setState(() => _chip = false),
                  ),
                if (!_chip)
                  TextButton(
                    onPressed: () => setState(() => _chip = true),
                    child: const Text('恢复标签'),
                  ),
                TonalChip(
                  label: '信息',
                  color: context.colorScheme.primaryContainer,
                  foregroundColor: context.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'Switch / Checkbox / Slider',
        source: 'prism_ui/lib/switch.dart · checkbox.dart · slider.dart',
        code: 'Switch(value: on, onChanged: update);\nSlider(value: value, min: 0, max: 1, divisions: 10, onChanged: update)',
        child: Column(
          children: [
            ListRow(
              title: const Text('支持拖动的开关'),
              trailing: Switch(
                value: _on,
                onChanged: (v) => setState(() => _on = v),
              ),
            ),
            ListRow(
              title: const Text('勾选与禁用'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _checked,
                    onChanged: (v) => setState(() => _checked = v ?? false),
                  ),
                  const Checkbox(value: true, onChanged: null),
                ],
              ),
            ),
            Slider(
              value: _value,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: (v) => setState(() => _value = v),
            ),
            Text('数值 ${_value.toStringAsFixed(2)}'),
            const Switch(value: true, onChanged: null),
          ],
        ),
      ),
      DemoSection(
        title: 'SegmentedControl / SelectionBadge',
        source: 'prism_ui/lib/segmented_control.dart · selection_mark.dart',
        code: "SegmentedControl<int>(segments: const [(0, 'A'), (1, 'B')], value: value, onChanged: select)",
        child: Column(
          children: [
            SegmentedControl<int>(
              segments: const [(0, 'A'), (1, 'B'), (2, 'C')],
              value: _segment,
              onChanged: (v) => setState(() => _segment = v),
            ),
            const SizedBox(height: 12),
            const SelectionCheck(),
          ],
        ),
      ),
    ],
  );
}

class FormsDemo extends StatefulWidget {
  const FormsDemo({super.key});
  @override
  State<FormsDemo> createState() => _FormsDemoState();
}

class _FormsDemoState extends State<FormsDemo> {
  final _name = TextEditingController(text: 'FlClash');
  final _secret = TextEditingController(text: 'native-widgets');
  final _form = GlobalKey<FormState>();
  String _option = '自动';
  bool _toggle = true;
  String _search = '';
  @override
  void dispose() {
    _name.dispose();
    _secret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'TextField / Form / SecretTextFormField',
        source: 'prism_ui/lib/text_field.dart · input.dart',
        code: 'TextFormField(controller: name, validator: validate);\nSecretTextFormField(controller: secret)',
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledInputTheme(
                child: TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: '请输入名称'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '名称不能为空' : null,
                ),
              ),
              const SizedBox(height: 12),
              SecretTextFormField(
                controller: _secret,
                decoration: const InputDecoration(hintText: '密码'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    notifyDemo(context, '验证通过');
                  }
                },
                child: const Text('验证表单'),
              ),
              const SizedBox(height: 12),
              const SelectableText('长按选择 / 桌面右键：使用原生文本选择菜单与放大镜。'),
            ],
          ),
        ),
      ),
      DemoSection(
        title: 'FormRow / FormRowTextField / Secret',
        source: 'FlClash/lib/features/form/form_row.dart → src/forms',
        code: "FormRow(title: '名称', trailing: FormRowTextField(controller: name))",
        child: generateSection(
          items: [
            FormRow(
              title: '名称',
              trailing: FormRowTextField(controller: _name),
            ),
            FormRow(
              title: '密码',
              trailing: FormRowSecretTextField(controller: _secret),
            ),
            FormRow(
              title: '验证状态',
              invalid: true,
              trailing: InfoMessageButton(message: '这里展示错误行与提示弹窗'),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'ListItem 六种行为',
        source: 'FlClash/lib/ui/list_item.dart → src/ui/list_item.dart',
        code: "ListItem<String>.options(title: const Text('模式'), options: modes, value: mode, textBuilder: (v) => v, onChanged: update)",
        child: generateSection(
          items: [
            ListItem(
              title: const Text('普通点击'),
              onTap: () => notifyDemo(context, '已点击'),
            ),
            ListItem.toggle(
              title: const Text('开关行'),
              value: _toggle,
              onChanged: (v) => setState(() => _toggle = v),
            ),
            ListItem.checkbox(
              title: const Text('勾选行'),
              value: _toggle,
              onChanged: (v) => setState(() => _toggle = v ?? false),
            ),
            ListItem<String>.options(
              title: const Text('模式'),
              options: const ['自动', '手动'],
              value: _option,
              textBuilder: (v) => v,
              onChanged: (v) => setState(() => _option = v),
            ),
            ListItem.input(
              title: const Text('输入弹窗'),
              dialogTitle: '名称',
              value: _name.text,
              onChanged: (v) {
                if (v != null) setState(() => _name.text = v);
              },
            ),
            ListItem.open(
              title: const Text('打开页面'),
              widget: const Scaffold(
                title: '子页面',
                body: Center(child: Text('从列表行变换进入，支持返回手势')),
              ),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'SearchField / SelectionSheet',
        source: 'prism_ui/lib/search_field.dart; FlClash/lib/features/form/selection_sheet.dart',
        code: 'SelectionSheet<String>(title: title, sections: sections, labelBuilder: (v) => v, selected: selected, onSelected: update)',
        child: Column(
          children: [
            SearchField(onChanged: (v) => setState(() => _search = v)),
            Text('搜索内容：$_search'),
            FilledButton(
              onPressed: () => showSheet<void>(
                context: context,
                builder: (context) => SelectionSheet<String>(
                  title: '选择项目',
                  sections: [
                    SelectionSection(
                      label: '可搜索列表',
                      items: List.generate(50, (i) => '项目 ${i + 1}'),
                    ),
                  ],
                  selected: _option,
                  labelBuilder: (v) => v,
                  onSelected: (v) {
                    setState(() => _option = v);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              child: const Text('打开选择面板'),
            ),
          ],
        ),
      ),
    ],
  );
}

class PaletteDemo extends StatefulWidget {
  const PaletteDemo({super.key});
  @override
  State<PaletteDemo> createState() => _PaletteDemoState();
}

class _PaletteDemoState extends State<PaletteDemo> {
  final _color = ValueNotifier(const Color(0xFF007AFF));
  final _qr = TextEditingController(
    text: 'https://github.com/chen08209/FlClash',
  );
  @override
  void dispose() {
    _color.dispose();
    _qr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'Palette / HexColorField',
        source: 'FlClash/lib/widgets/palette.dart → src/widgets/palette.dart',
        code: 'final color = ValueNotifier(const Color(0xFF007AFF));\nPalette(controller: color);\nHexColorField(color: color.value, onChanged: (v) => color.value = v);\n// dispose color in State.dispose',
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Palette(controller: _color),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: _color,
                  builder: (_, color, _) => HexColorField(
                    color: color,
                    onChanged: (v) => _color.value = v,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      DemoSection(
        title: 'QrCodeView / QrMatrix',
        source: 'FlClash/lib/ui/qr_code.dart · qr_matrix.dart',
        code: 'QrCodeView(data: text, size: 240);\nfinal fits = QrCodeView.fits(text);',
        child: Column(
          children: [
            TextField(
              controller: _qr,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '输入文本实时生成二维码'),
            ),
            const SizedBox(height: 16),
            QrCodeView(data: _qr.text),
          ],
        ),
      ),
    ],
  );
}
