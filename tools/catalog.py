"""Locate public types and actual calls, distinguishing UI demos from support APIs."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    output = ROOT / 'docs/components/catalog.md'
    callsites = []
    for folder in ['showcase/lib', 'examples/standalone/lib', 'examples/standalone/test', 'packages/flutter/test', 'packages/editor/test', 'packages/platform/test', 'source/upstream/prism_ui/test']:
        callsites += [(p, p.read_text(encoding='utf-8')) for p in (ROOT / folder).rglob('*.dart')]
    sections = ['# 组件目录与真实调用', '', '统一入口：`package:flclash_ui_kit/flclash_ui_kit.dart`；图标入口 `icons.dart`；多边形入口 `shapes.dart`。多边形 Cubic 与 Flutter Cubic 同名，使用前缀。部分内部类型不从统一入口导出，先检查对应 export 和调用者。', '', '|分类|可交互调用文件|主要 API|', '|---|---|---|',
                '|控件/表单/调色/QR|[controls.dart](../../showcase/lib/controls.dart)|按钮、卡片、Switch、Checkbox、Slider、ListItem 六种、FormRow、SelectionSheet、Palette、HexColorField、QrCodeView|',
                '|列表/表格|[collections.dart](../../showcase/lib/collections.dart)|PrismList、Sortable、KeyedAnimatedList、Collapsible、RecordFeedList、RecordTableFrame|',
                '|导航|[demos.dart](../../showcase/lib/demos.dart)|NavigationDock、FloatingNavigationBar、NavigationBar、NavigationSidebar、TabBarView|',
                '|弹层/动效/材质/状态|[effects.dart](../../showcase/lib/effects.dart)|Sheet/Form/Snap/Paged、Dialog、Popup、ContextMenu、Fade、OpenContainer、Elastic、LiquidGlass、Goo、Skeleton、NullStatus、Banner、LineChart|',
                '|图标/形状/文字|[glyph_catalog.dart](../../showcase/lib/glyph_catalog.dart)|124 个 AppGlyphs 常量、GlyphIcon、AnimatedGlyph、RoundedPolygon、Morph、AppTextStyle|',
                '|Dashboard|[dashboard.dart](../../showcase/lib/dashboard.dart)|DashboardItem、DashboardEditor、Card/Header/Connected/Switch/ShapeBadge、CurrentOutboundCard、MemoryInfo、ServiceStatusCard、ProfilesCard、ProfileDetailSheet、RunningToggle|', '',
                '可选编辑器/平台与原生 JavaScript 入口见 [native.md](../usage/native.md)、[packages/web](../../packages/web/README.md)；应用层数据契约见 [presentation.md](presentation.md)。', '', '## 逐类型索引', '', '“调用”指可定位的真实源码调用，不代表每个公开类型都有独立 Showcase。上游测试调用是保留的行为示例；依赖其他应用服务的 FlClash 测试没有冒充组件包测试。支持 API 和尚无独立样例的类型明确标记；补全独立示例仍属于未完成覆盖。', '', '|公开类型|定义|真实调用或覆盖状态|', '|---|---|---|']
    declared = 0
    demonstrated = 0
    for folder in ['packages/flutter/lib', 'packages/flutter/vendor/prism_ui/lib',
                   'packages/editor/lib', 'packages/editor/vendor/code_forge/lib',
                   'packages/platform/lib', 'packages/platform/vendor/window/lib',
                   'packages/platform/vendor/tray/lib', 'packages/platform/vendor/dynamic_color/lib']:
        for file in sorted((ROOT / folder).rglob('*.dart')):
            if 'generated' in file.parts:
                continue
            source = file.read_text(encoding='utf-8')
            for match in re.finditer(r'^(?:(?:abstract|sealed|base|final|interface)[ \t]+)*(class|enum|mixin|extension|typedef)[ \t]+(\w+)', source, re.M):
                name = match.group(2)
                if name.startswith('_') or name in {'on', 'class'}:
                    continue
                declared += 1
                location = file.relative_to(ROOT).as_posix()
                calls = []
                pattern = re.compile(r'\b' + re.escape(name) + r'(?:<[^;\n]*?>)?(?:\.\w+)?\(')
                for caller, text in callsites:
                    found = pattern.search(text)
                    if found:
                        calls.append((caller.relative_to(ROOT).as_posix(), text.count('\n', 0, found.start()) + 1))
                if any(p.startswith('showcase') for p, _ in calls):
                    demonstrated += 1
                if calls:
                    reuse = '；'.join(f'[{p}:L{line}](../../{p})' for p, line in calls[:2])
                else:
                    reuse = '支持类型或尚无独立调用样例；请沿 source-index.json 的 callers 追踪，不计作独立 Showcase 覆盖'
                sections.append(f'|`{name}`|[{location}:L{source.count(chr(10),0,match.start())+1}](../../{location})|{reuse}|')
    sections += ['', f'共索引 {declared} 个公开声明，其中 {demonstrated} 个在 Showcase 源文件有直接调用（包含支持类型；不是视觉组件数量）。没有独立展示/样例的声明不从统计中隐去。', '', 'Scaffold 动态搜索、路由保持、玻璃捕获、输入选区、HCT、Sliver 等基础实现通过上层组合路径工作。完整源码行号、import 与反向边见 [source-index.json](../audit/source-index.json)，运行证据见 [verification.md](../audit/verification.md)。']
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text('\n'.join(sections) + '\n', encoding='utf-8')
    print(f'Catalogued {declared} declarations; {demonstrated} with direct Showcase calls.')


if __name__ == '__main__':
    main()
