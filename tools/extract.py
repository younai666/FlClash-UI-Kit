"""Reproduce the explicitly adapted FlClash files and their provenance ledger."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'source/upstream/FlClash'
COMMIT = 'be84736605527034689c95bf27828ff27d912c5e'
FILES = {}
EXCERPTS = {}


def register(source, target, changes=(), *, excerpt=None):
    FILES[source] = (target, changes)
    if excerpt:
        EXCERPTS[source] = excerpt


for name in ['list_item', 'delay_color', 'emoji', 'profile_id', 'setting_text_card', 'qr_code', 'qr_matrix']:
    register(f'lib/ui/{name}.dart', f'ui/{name}.dart')
register('lib/ui/icons/app_glyphs.dart', 'icons/app_glyphs.dart')
register('lib/ui/null_status_illustration.dart', 'ui/null_status_illustration.dart', [
    ("package:fl_clash/ui/icons/app_glyphs.dart", 'package:flclash_ui_kit/src/icons/app_glyphs.dart'),
])
for name in ['scaffold', 'scaffold_actions', 'scaffold_search']:
    register(f'lib/ui/scaffold/{name}.dart', f'scaffold/{name}.dart')
register('lib/widgets/record_feed_list.dart', 'widgets/record_feed_list.dart')
register('lib/views/dashboard/layout.dart', 'dashboard/layout.dart')
register('lib/widgets/palette.dart', 'widgets/palette.dart', [
    ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';"),
    ("package:fl_clash/ui/ui.dart", 'package:prism_ui/prism_ui.dart'),
    ('context.appLocalizations', 'KitLocalizations.of(context)'),
])
register('lib/features/form/form_row.dart', 'forms/form_row.dart', [
    ("import 'package:fl_clash/common/common.dart';", "import '../localizations.dart';"),
    ("import 'package:fl_clash/state.dart';", ''),
    ("package:fl_clash/ui/icons/icons.dart", 'package:flclash_ui_kit/icons.dart'),
    ("import 'package:fl_clash/widgets/widgets.dart';", ''),
    ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ('dialogs.showAlert(message: TextSpan(text: message));', 'showFloatingDialog<void>(context: context, child: AlertDialog(title: KitLocalizations.of(context).tip, child: Text(message)));'),
    ('globalState.measure.listRowHeight', 'MeasureScope.of(context).listRowHeight'),
])
register('lib/widgets/active_polling.dart', 'widgets/active_polling.dart', [
    ("import 'package:fl_clash/common/print.dart';", ''),
    ("import 'package:fl_clash/enum/enum.dart';", ''),
    ('} catch (error) {', '} catch (error, stack) {'),
    ("commonPrint.log(\n        '$runtimeType poll error: $error',\n        logLevel: LogLevel.warning,\n      );", "FlutterError.reportError(FlutterErrorDetails(\n        exception: error, stack: stack, library: 'flclash_ui_kit',\n        context: ErrorDescription('$runtimeType polling'),\n      ));"),
])
register('lib/views/dashboard/widgets/card.dart', 'dashboard/card.dart', [
    ("import 'package:fl_clash/state.dart';", ''),
    ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/icons.dart'),
    ('package:fl_clash/views/dashboard/layout.dart', 'package:flclash_ui_kit/src/dashboard/layout.dart'),
    ('package:fl_clash/views/dashboard/style.dart', 'package:flclash_ui_kit/src/dashboard/style.dart'),
    ("import 'package:fl_clash/widgets/widgets.dart';", ''),
    ('globalState.measure', 'MeasureScope.of(context)'),
    ('''          Text(
            label,
            maxLines: 1,
            style: AppTextStyle.caption1
                .of(context, emphasized: true)
                .toTabular
                .copyWith(color: foreground),
          ),''', '''          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .toTabular
                  .copyWith(color: foreground),
            ),
          ),'''),
])
register('lib/common/num.dart', 'format.dart', [
    ("import 'package:fl_clash/enum/enum.dart';", ''),
    ("import 'package:fl_clash/models/common.dart';", ''),
    ('return TrafficShow(', 'return ('),
])
register('lib/views/dashboard/style.dart', 'dashboard/style.dart', [
    ('package:fl_clash/common/common.dart', 'package:flclash_ui_kit/src/format.dart'),
    ('package:fl_clash/ui/ui.dart', 'package:prism_ui/prism_ui.dart'),
])
register('lib/common/search.dart', 'search.dart')
_edit = (BASE / 'lib/views/dashboard/edit.dart').read_text(encoding='utf-8')
_storage = _edit[_edit.index('  void _save() {'):_edit.index('  void _remove(')]
register('lib/views/dashboard/edit.dart', 'dashboard/edit.dart', [
    ("package:fl_clash/common/common.dart", 'package:flclash_ui_kit/src/localizations.dart'),
    ("import 'package:fl_clash/enum/enum.dart';", ''),
    ("import 'package:fl_clash/providers/providers.dart';", ''),
    ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/icons.dart'),
    ("import 'package:fl_clash/widgets/widgets.dart';", ''),
    ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
    ("import 'widget_registry.dart';", "import 'items.dart';"),
    (_storage, '  void _save() => widget.onChanged(_shown);\n\n'),
    ('ConsumerStatefulWidget', 'StatefulWidget'),
    ('ConsumerState<', 'State<'),
    ('DashboardWidget', 'DashboardItem'),
    ('required this.platform,', 'required this.available,\n    required this.onChanged,'),
    ('final SupportPlatform platform;', 'final List<DashboardItem> available;\n  final ValueChanged<List<DashboardItem>> onChanged;'),
    ('DashboardItem.values', 'widget.available'),
    ('if (card.platforms.contains(widget.platform) && !shown.contains(card))', 'if (!shown.contains(card))'),
    ('setState(() => _cards = _cards.copyAndReorder(from, to));', 'setState(() {\n      final reordered = [..._cards];\n      final item = reordered.removeAt(from);\n      reordered.insert(to, item);\n      _cards = reordered;\n    });'),
    ('context.appLocalizations', 'KitLocalizations.of(context)'),
])
_table = (BASE / 'lib/widgets/record_table.dart').read_text(encoding='utf-8')
_table_store = _table[_table.index('  void saveColumnWidths() {'):_table.index('\n}\n\nclass RecordTable<T>')]
register('lib/widgets/record_table.dart', 'widgets/record_table.dart', [
    ("import 'package:fl_clash/providers/config.dart';", ''),
    ('package:fl_clash/ui/icons/icons.dart', 'package:flclash_ui_kit/icons.dart'),
    ('package:fl_clash/ui/ui.dart', 'package:prism_ui/prism_ui.dart'),
    ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
    ('ConsumerStatefulWidget', 'StatefulWidget'),
    ('ConsumerState<', 'State<'),
    ('late Map<String, double> columnWidths =\n      ref.read(appSettingProvider).tableColumnWidths[tableId] ?? const {};', 'Map<String, double> get initialColumnWidths;\n  void onColumnWidthsChanged(Map<String, double> widths);\n  late Map<String, double> columnWidths = initialColumnWidths;'),
    (_table_store, '  void saveColumnWidths() => onColumnWidthsChanged(columnWidths);'),
    ('final String tableId;\n  final List<T> items;', 'final String tableId;\n  final Map<String, double> initialColumnWidths;\n  final ValueChanged<Map<String, double>> onColumnWidthsChanged;\n  final List<T> items;'),
    ('required this.tableId,\n    required this.items,', 'required this.tableId,\n    this.initialColumnWidths = const {},\n    required this.onColumnWidthsChanged,\n    required this.items,'),
    ('String get tableId => widget.tableId;', 'String get tableId => widget.tableId;\n  @override\n  Map<String, double> get initialColumnWidths => widget.initialColumnWidths;\n  @override\n  void onColumnWidthsChanged(Map<String, double> widths) => widget.onColumnWidthsChanged(widths);'),
])
register('lib/features/form/selection_sheet.dart', 'forms/selection_sheet.dart', [
    ("import 'package:fl_clash/common/common.dart';", ''),
    ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
    ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
    ('ConsumerStatefulWidget', 'StatefulWidget'),
    ('ConsumerState<', 'State<'),
    ('final T? Function(WidgetRef ref) selectedOf;', 'final T? selected;'),
    ('required this.selectedOf,', 'this.selected,'),
    ('widget.selectedOf(ref)', 'widget.selected'),
])
# Additional independently reviewed presentation families, kept separately so
# changes to a source-to-library contract remain reviewable.
from extraction_recipes import register_reviewed
register_reviewed(register, BASE)
from extraction_effects import register_effects
register_effects(register, BASE)
from extraction_resources import register_resources
register_resources(register, BASE)
from extraction_profiles import register_profiles
register_profiles(register, BASE)
from extraction_forms_extra import register_forms_extra
register_forms_extra(register, BASE)
from extraction_connections import register_connections
register_connections(register, BASE)
from extraction_dashboard import register_dashboard
register_dashboard(register, BASE)
from extraction_proxies import register_proxies
register_proxies(register, BASE)
from extraction_views_extra import register_views_extra
register_views_extra(register, BASE)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest = {}
    prism = ROOT / 'source/upstream/prism_ui'
    vendor = ROOT / 'packages/flutter/vendor/prism_ui'
    prism_files = [*prism.glob('lib/**/*.dart'), *prism.glob('shaders/*.frag'),
                   prism / 'pubspec.yaml', prism / 'LICENSE', prism / 'NOTICE',
                   prism / 'analysis_options.yaml', prism / 'lint_options.yaml', prism / 'build.yaml']
    for source in prism_files:
        relative = source.relative_to(prism).as_posix()
        content = source.read_text(encoding='utf-8')
        modifications = []
        if relative == 'lib/liquid_glass.dart':
            old = 'builder.pushClipRSuperellipse(corners.toRSuperellipse(rect));'
            new = 'builder.pushClipRSuperellipse(corners.toRSuperellipse(rect), clipBehavior: Clip.antiAlias);'
            if old not in content:
                raise ValueError('Review Flutter Web SceneBuilder compatibility patch against new prism_ui.')
            content = content.replace(old, new)
            content = '// Modified 2026-11-05 by FlClash-UI-Kit: explicit clipBehavior for Flutter 3.47.9 Web SceneBuilder.\n' + content
            modifications.append({'from': old, 'to': new})
        target = vendor / relative
        if args.check:
            if target.read_text(encoding='utf-8') != content:
                raise ValueError(f'Vendored source drift: {relative}')
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content, encoding='utf-8')
        manifest['prism_ui/' + relative] = {'status': '已原样提取' if not modifications else '已提取并修复 Web 编译；见 verification.md',
            'target': target.relative_to(ROOT).as_posix(), 'source_commit': '63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185',
            'modifications': modifications}
    for source, (target, changes) in FILES.items():
        content = (BASE / source).read_text(encoding='utf-8')
        source_range = [1, len(content.splitlines())]
        excerpt = EXCERPTS.get(source)
        if excerpt:
            start, end, prefix, _ = excerpt
            begin = content.index(start)
            finish = content.index(end, begin) if end else len(content)
            source_range = [content.count('\n', 0, begin) + 1, content.count('\n', 0, finish)]
            content = prefix + content[begin:finish]
        for old, new in changes:
            if old not in content:
                raise ValueError(f'Upstream transformation no longer matches {source}: {old}')
            content = content.replace(old, new)
        if target == 'format.dart':
            content = '// ignore_for_file: constant_identifier_names\n' + content
            content += '\nenum TrafficUnit { B, KB, MB, GB, TB }\ntypedef TrafficShow = ({String value, String unit});\n'
            content += "\n// From lib/models/common.dart:560-562, adapted to the record projection.\nextension TrafficShowExt on TrafficShow {\n  String get show => '$value$unit';\n}\n"
        relative = ('packages/flutter/' + target[1:]) if target.startswith('@') else f'packages/flutter/lib/src/{target}'
        provenance = f'// Derived from chen08209/FlClash, {source}\n// Commit: {COMMIT}; GPL-3.0, except retained third-party headers.\n// Modified 2026-11-05 for FlClash-UI-Kit: '
        note = 'imports, localization/host contracts; original drawing and motion retained.' if changes else 'provenance header only.'
        content = provenance + note + '\n\n' + content
        file = ROOT / relative
        if args.check:
            if file.read_text(encoding='utf-8') != content:
                raise ValueError(f'Adaptation drift: {relative}; update the explicit extraction recipe.')
        else:
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(content, encoding='utf-8')
        manifest['FlClash/' + source] = {
            'status': ('部分提取：' + excerpt[3]) if excerpt else '已提取；运行验证见 verification.md', 'target': relative,
            'source_commit': COMMIT, 'modifications': [{'from': old, 'to': new} for old, new in changes],
            'source_lines': source_range,
        }
    # The name table identifies 2.304; its bytes were compared to the official
    # JetBrains v2.304 release. The independent package retains the full OFL.
    asset = 'assets/fonts/JetBrainsMono-Regular.ttf'
    target = ROOT / 'packages/flutter' / asset
    content = (BASE / asset).read_bytes()
    if args.check:
        if target.read_bytes() != content:
            raise ValueError('JetBrains Mono asset differs from the reviewed source.')
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)
    manifest['FlClash/' + asset] = {
        'status': '已原样提取；与 JetBrains Mono v2.304 官方字节一致，OFL-1.1',
        'target': target.relative_to(ROOT).as_posix(), 'source_commit': COMMIT,
        'modifications': [], 'license': 'packages/flutter/assets/fonts/JetBrainsMono-OFL.txt',
        'license_source': 'https://github.com/JetBrains/JetBrainsMono/blob/cd5227bd1f61dff3bbd6c814ceaf7ffd95e947d9/OFL.txt',
    }
    for file in sorted((BASE / 'assets/images/services').iterdir()):
        asset = file.relative_to(BASE).as_posix()
        target = ROOT / 'packages/flutter' / asset
        if args.check:
            if target.read_bytes() != file.read_bytes():
                raise ValueError(f'Service asset drift: {asset}')
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(file.read_bytes())
        manifest['FlClash/' + asset] = {
            'status': '已原样提取；Simple Icons CC0 / FlClash 自绘 GPL；保留品牌说明',
            'target': target.relative_to(ROOT).as_posix(), 'source_commit': COMMIT,
            'modifications': [], 'license': 'packages/flutter/assets/images/services/LICENSE.md',
        }
    ledger = ROOT / 'docs/audit/extractions.json'
    if args.check:
        if json.loads(ledger.read_text(encoding='utf-8')) != json.loads(json.dumps(manifest)):
            raise ValueError('Extraction ledger drift; regenerate after reviewing recipes.')
    else:
        ledger.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(manifest)} source files {"checked" if args.check else "extracted"}.')


if __name__ == '__main__':
    main()
