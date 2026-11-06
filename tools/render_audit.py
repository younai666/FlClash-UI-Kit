"""Render human-readable views of the complete, checkable upstream census."""
import collections
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / 'docs/audit'
FRONT = {'design-system', 'page', 'feature', 'app-ui', 'app-widget', 'editor', 'native-editor', 'native-ui', 'native-bridge', 'platform-host', 'asset', 'asset-source', 'website', 'example', 'localization', 'entrypoint', 'lifecycle', 'state', 'utility', 'model'}
PURPOSE = {
    'liquid_glass': '折射、色散、雾化、边缘高光及统一背后图层捕获；保留 shader uniform 顺序',
    'snap_sheet': '9/16、0.9 吸附点，投掷速度投影、橡皮筋、键盘和滚轮协调',
    'bar_item_presence': '导航栏标题、按钮、底栏跨路由位置与显隐衔接',
    'navigation_dock': '液滴选中、弹性按压、悬停、浮动导航及原始物理参数',
    'page_transition': '卡片转场、被覆盖页面变换及导航元素衔接',
    'open_container': '从现有元素几何打开页面、push/zoom、拖动关闭与回传值',
    'route_motion_hold': '转场期间保持路由数据及缓存范围，避免移动中触发重工作',
    'deferred_push': '等待首屏布局稳定后开始转场',
    'goo': '相邻液滴融合、轮廓及自定义 RenderObject 绘制',
    'text_field': '输入布局、验证、IME、光标、选择菜单与移动端放大镜',
    'palette': 'HCT 网格、HSL 色谱、HSV 滑块及 hex 输入；拖动优先争夺手势',
    'record_feed_list': '按 key 复用记录行，裁掉头部时保持条纹及滚动身份',
    'qr_matrix': 'UTF-8 ECI、M 纠错、掩码与版本选择；Dart QR BSD 版权保留',
    'qr_code': '固定白底、四模块安静区及超容量文本处理',
    'active_polling': '前台且页面活跃时串行轮询，代次隔离过期结果',
    'scaffold_search': '搜索源几何测量、弹簧形变、液滴/收缩返回与键盘协调',
    'scaffold_actions': '动作折叠、表单确认与取消、搜索/排序/选择栏',
    'list_item': '普通、打开页面、选项、输入、勾选和开关六种行行为',
    'app_glyphs': '应用自绘矢量图标及随状态变化的动态图形',
    'layout': '尺寸断点、列数与布局密度',
    'style': 'Dashboard 颜色、CSS blur 到 Flutter sigma 的阴影换算、排版',
    'current_outbound': '1500ms 旋转、450ms 形变、150ms 状态切换及运行按钮',
    'edit': '页面编辑/重排；Dashboard 另含摇摆、移除占位收起与拖动抬升',
    'scan': '扫码摄像头生命周期、识别区域、自绘遮罩、权限与图库入口',
    'theme_preview': '主题预览插值、滑动淡入、迷你双栏屏幕',
    'editor': '编辑器补全、查找替换、选区、折叠及 Rust 文档桥接',
    'memory_info': '独立详情生命周期、2 秒轮询、内存占比插值、展开交叉淡入与释放反馈',
    'service_status': '服务网格/磁贴、圆角镂空状态点、延迟/失败/加载语义；探测由宿主提供',
    'icon': '16 MiB 图标缓存、192 px 解码、加载回退、monogram 与原生包图标异步代次',
    'network_takeover': '系统代理/TUN/VPN 的卡片与磁贴变体、尺寸感知图标及形状反馈',
    'window_manager': '原生窗口事件、标题栏拖动、双击、置顶、最大化、全屏及关闭策略',
    'field': 'Canvas 胶囊场：避让、弹簧伸缩、鼠标唤起、滚动加速、可见性暂停、明暗调色',
    'home': '响应式主壳层；远距离切页重排、淡入/滑动、快照、页面活跃与焦点隔离、返回行为',
    'app_manager': '侧栏宽度与材质已摘录；网络、后台服务与应用生命周期保留宿主边界',
    'theme': '种子调色板、色彩风格、玻璃、文字缩放、导航/转场配置与实时缩略预览',
    'font_family': '字体选择、每帧延迟预览、滚动与转场暂停；原生枚举由 platform 提供',
    'system_fonts': 'DirectWrite/CoreText/fontconfig/Android 字体枚举；isolate 与原生资源释放',
    'hotkey': '热键录制、USB HID、修饰键验证、冲突移动与失败详情；宿主负责系统注册',
    'profiles': '配置网格、焦点/选中定位、拖动重排、上下文菜单；文件与同步由宿主提供',
    'about': '元数据、贡献者、链接和五次点击入口；品牌资源由宿主合法提供',
    'tools': '更多导航、语言与设置/工具入口；通过宿主 Scope 连接实际视图',
    'connections_table': '连接/请求/DNS 三类 feed、快照/节流/轮询、列宽与页面活跃状态',
    'proxy_groups': '策略组 grid、summary、选中节点与跳转交互；选择数据来自宿主',
}


def purpose(r):
    stem = Path(r['path']).stem
    return PURPOSE.get(stem, f"{r['category']}：" + ', '.join(s['name'] for s in r.get('symbols', []) if not s['name'].startswith('_')))


def src(r, line=1):
    return f"https://github.com/chen08209/{r['repo']}/blob/{r['commit']}/{r['path']}#L{line}"


def state(r, extracted):
    key = r['repo'] + '/' + r['path']
    if key in extracted:
        items = extracted[key]
        return '；'.join(dict.fromkeys(item['status'] for item in items)), '；'.join(dict.fromkeys(
            target for item in items for target in [item['target'], *item.get('additional_targets', [])]))
    if r['repo'] == 'FlClash' and r['path'] in {
        'lib/pages/pages.dart', 'lib/views/views.dart', 'lib/features/features.dart',
        'lib/features/form/form.dart', 'lib/ui/ui.dart', 'lib/ui/icons/icons.dart',
        'lib/widgets/widgets.dart', 'lib/views/dashboard/widgets/widgets.dart',
    }:
        return '上游 export 聚合入口；无独立 UI，不作为缺失组件计数', '统一入口 packages/flutter/lib/flclash_ui_kit.dart；业务 export 仍为参考'
    if r['repo'] == 'prism_ui':
        return ('原样依赖（待运行验证）', 'packages/flutter → pinned prism_ui') if r['path'].startswith(('lib/', 'shaders/')) else ('保留上游验证/文档', 'source/upstream/prism_ui')
    if r['category'] in {'app-ui', 'app-widget'}:
        return '待提取/解耦', 'packages/flutter/lib/src（计划）'
    if r['category'] in {'page', 'feature', 'editor', 'native-editor'}:
        return '业务或原生依赖，尚未独立提取', '保留完整源文件；见下方解耦策略'
    if r['category'] in {'native-ui', 'native-bridge', 'platform-host'}:
        return '平台源码参考；尚未独立验证', 'source/upstream/FlClash/' + r['path'].split('/')[0]
    if r['category'] in {'asset', 'asset-source'}:
        return '仅上游参考，未进入组件分发包', '按 license-inventory.md 授权边界复用'
    if r['category'] == 'website':
        return '营销页业务组合参考；独立交互待拆分', 'source/upstream/FlClash/site；Canvas 效果与 token 已另行提取'
    return '已归类，参考实现', 'source/upstream/FlClash'


def write(name, parts):
    (AUDIT / name).write_text('\n'.join(parts) + '\n', encoding='utf-8')


def main():
    records = json.loads((AUDIT / 'source-index.json').read_text(encoding='utf-8'))
    extracted = collections.defaultdict(list)
    for name in ['extractions', 'editor-extractions', 'platform-extractions', 'web-extractions']:
        for key, value in json.loads((AUDIT / (name + '.json')).read_text(encoding='utf-8')).items():
            extracted[key].append(value)
    frontend = [r for r in records if r['category'] in FRONT]
    intro = ['固定源码的静态调查，日期：2026-11-05。文件枚举、全文特征扫描和 import/export/part 反向关系由 `python tools/audit.py --write` 生成；人工分析聚焦入口、组件、绘制、动效及服务耦合。枚举覆盖不等于逐行人工语义审查或逐组件运行验收。', '', '独立复查与边界见 [review-findings.md](review-findings.md)。完整逐文件证据（包括所有依赖边、反向调用者、行号、平台、生命周期和许可证头）见 [source-index.json](source-index.json)。使用 `python tools/audit.py --check` 检查清单是否仍与锁定源码一致。', '']
    source = ['# 源码结构与调用关系', *intro]
    for repo in ['FlClash', 'prism_ui']:
        group = [r for r in records if r['repo'] == repo]
        source += [f"## {repo} · `{group[0]['commit']}`", '', f"{len(group)} 个直接跟踪文件/子模块条目。", '']
        counts = collections.Counter((r['category'], str(Path(r['path']).parent).replace('\\', '/')) for r in group)
        source += ['|目录|分类|文件数|', '|---|---|---|']
        source += [f'|`{p}`|{c}|{n}|' for (c, p), n in sorted(counts.items())]
        source += ['']
    source += ['## 运行与模块边界', '', 'FlClash：`main → RustLib.init / bootstrap → ProviderContainer → Application → HomePage → Navigation → views/features → ui/widgets → prism_ui`。主题经过 `ThemeManager/providers/state/theme` 生成 `PrismApp` 的 ThemeData；桌面窗口、托盘、Android 输入/返回与服务均由 manager、plugin 和原生 host 协作。', '', 'prism_ui：`PrismApp → Theme / MeasureScope / ThemeCrossFade / LiquidGlassScope + Host / BannerHost / RemoteFocusAdapter`；页面使用 `ViewScope → PrismScaffold → AppBar/BarItemPresence`；`BaseNavigator → CardPageRoute → DeferredPush/DragBack/RouteMotionHold`；sheet 选择 Snap/Side/Form/Paged 并共享 SheetProvider 与 SheetScrollScope。', '', '绘制链：`PressSurface → CardSurface / PressSparkles → ink_sparkle.frag`；`LiquidGlass → liquid_glass_capture → liquid_glass.frag`；`NullStatus → EmptyIllustration → shapes/Morph`；`PrismListView → SuperSliverList → extent manager/Fenwick tree`。不能只复制外层 widget。', '', '其他：`code_forge → rust_api/editor → Rust rope/folding`；Windows DWM、macOS NSVisualEffectView、Linux GTK 的窗口材质位于 `plugins/window`；托盘菜单的 macOS title view 是系统级 UI。完整源文件均保留。', '', '## 全文件交叉核对', '', f'主树共 {len(records)} 项，其中前端/关联候选 {len(frontend)} 项；其他 {len(records)-len(frontend)} 项也在 source-index.json 中明确归类（测试、构建、数据、后端等）。二进制仅做文件、用途和授权调查，未宣称视觉核验。相同 commit 的嵌套 prism_ui 复用该清单。Clash.Meta 的独立递归清单见 upstream-lock.json。', '', '每个文件都有分类；从每个 Dart 文件提取 imports/exports/parts，并建立反向边。生成文件属于原包，不人工改写。README、隐藏 .agents、CI、原生 host 和本地插件也纳入枚举。']
    write('source-map.md', source)
    ui = ['# UI 与页面清单', *intro, '|源码（固定 Commit，点击定位）|公开类型/用途|直接依赖|复用与状态|', '|---|---|---|---|']
    matrix = ['# 提取矩阵与未完成项', *intro, '状态严格区分：**原样依赖** 是可获取的原生实现；**已提取** 指库内解耦代码；**参考** 不计作可运行组件；运行与测试结果另见 verification.md。', '', '## 解耦策略', '', '- 页面中的 Riverpod、数据库、网络动作：改为显式数据、ValueListenable、回调和 builder，保留排版及原始动画。保留参考不意味着完成这项工作。', '- 编辑器：保留 code_forge、Rust editor 和许可证；现已在 packages/editor 分出 editor-only Rust 桥接、hook、完整 CodeForge 与真实原生编辑宿主；文件工作流、应用 schema 与服务仍需解耦。禁止用 TextField 替代后标记提取成功。', '- 原生窗口、托盘、摄像头：由宿主选择平台插件并完成注册、权限和生命周期；不得放进跨平台 widget 入口并宣称 Web 可用。', '- 字体、头像、Logo：未明确授权的文件不复制进发布资产；系统字体 fallback 可直接使用。', '', '|源码|用途|依赖|目标|状态|', '|---|---|---|---|---|']
    for r in frontend:
        status, target = state(r, extracted)
        deps = ', '.join(f'`{p}`' for p in r.get('imports', []) if p.startswith('package:') and not p.startswith('package:flutter')) or '见 source-index.json'
        use = purpose(r).replace('|', '/')
        declarations = ', '.join(s['name'] for s in r.get('symbols', []))
        if declarations:
            use += '；声明（含内部类型）：' + declarations
        link = f"[{r['repo']}/{r['path']}]({src(r)})"
        if r['category'] in {'design-system', 'page', 'feature', 'app-ui', 'app-widget', 'editor', 'native-editor', 'native-ui', 'native-bridge', 'website', 'example'}:
            ui.append(f'|{link}|{use}|{deps}|{target}；{status}|')
        matrix.append(f'|{link}|{use}|{deps}|`{target}`|{status}|')
    write('ui-inventory.md', ui)
    write('extraction-matrix.md', matrix)
    motion = ['# 动效、交互、渲染与生命周期', *intro, '## 关键语义', '', '|实现|行为与保持条件|', '|---|---|', '|液态玻璃|主机捕获、模糊 atlas、渐隐/遮罩层与 pane 采样必须一并保留；保留全部 uniform 和 shader|', '|底部 sheet|detents 9/16、0.9；1000/3 刚度、0.8 投掷阻尼；滚轮 500ms 序列；嵌套覆盖缩放 0.9204|', '|液滴与按压|dropletSpring mass=1、stiffness=165、ratio=0.8；按压/拖动/悬停使用原始模拟|', '|主题/无动画|ThemeCrossFade；所有依赖 disableAnimations 的路径保留，不能统一用固定时长代替|', '|路由|drag back、open container、bar item presence、arrival hold、keyboard inset hold 共同协作|', '|输入|移动端 text loupe、选区菜单、IME；桌面鼠标和键盘；remote focus 的方向键/浮动键盘|', '|Dashboard|编辑摇摆 3600ms、占位 260ms、出现 200ms；连接按钮 240ms；运行按钮旋转/形变见源码|', '|应用特有|搜索形变、调色器即时手势、扫码遮罩、主题缩略图、记录流 identity 与 stripeShift|', '', '## 逐文件证据', '', '以下为全文匹配得到的候选点，包含非动画 Timer、常量和注释；它们是可追踪证据，不应直接作为动效数量统计。']
    for r in frontend:
        effects = {k: v for k, v in r.get('evidence', {}).items() if v}
        if not effects:
            continue
        status, target = state(r, extracted)
        motion += ['', f"### {r['repo']}/{r['path']}", '', f'用途：{purpose(r)}。复用：`{target}`。状态：{status}。依赖边见 source-index.json。', '', '|类别|源码位置|证据|', '|---|---|---|']
        for kind, points in effects.items():
            motion += [f"|{kind}|[L{p['line']}]({src(r,p['line'])})|`{p['code'].replace('`','').replace('|',' / ')}`|" for p in points]
    write('motion-inventory.md', motion)
    assets = ['# 资源、依赖与关联', *intro, '## 依赖边界', '', '`prism_ui` 仅依赖 Flutter、collection、freezed_annotation、path_parsing，shader 由该包 pubspec 声明。FlClash 另有 Riverpod、Drift、Rust、Go、窗口/托盘/动态颜色、SVG/缓存、文件/扫码、系统字体和网络依赖。每个 pubspec 均保留于原树；组件库的实际依赖以 packages/flutter/pubspec.yaml 和锁文件为准。', '', '## 所有上游 pubspec', '']
    for r in records:
        if r['path'].endswith('pubspec.yaml'):
            assets += [f"- [{r['repo']}/{r['path']}]({src(r)})"]
    assets += ['', '## 所有资产及声明/调用者', '', '|来源|用途/引用者|复用|状态|', '|---|---|---|---|']
    for r in records:
        if r['category'] not in {'asset', 'asset-source'} and not (r['kind'] == 'binary' and r['category'] in FRONT):
            continue
        users = [x['repo'] + '/' + x['path'] for x in records if r['path'] in x.get('references', [])]
        status, target = state(r, extracted)
        assets.append(f"|[{r['repo']}/{r['path']}]({src(r)})|{', '.join(users) or '目录/字体/平台条件声明，见源 pubspec；data 为业务数据库'}|{target}|{status}|")
    assets += ['', '平台图标、Android XML/drawable、macOS asset catalog、Windows 图标也在 platform-host 分类完整保留（逐文件见 source-index.json）。systemFontOf、appFontFamilyFallback 为字体名引用，不捆绑或授权分发系统字体。']
    write('assets-dependencies.md', assets)
    licenses = ['# 许可证与分发边界', *intro, '此表记录源码证据与分发决定；未知内容保持未知。根 LICENSE 使用 GPL-3.0 文本，衍生代码按 GPL-3.0-only 处理，上游已有更具体的授权头保持原样。完整源码和版本随 Git 子模块可获取。', '', '|内容|源码证据|授权/版权|分发决定|', '|---|---|---|---|', '|FlClash、prism_ui|各根 LICENSE，README|GPL-3.0；原作者 chen08209/贡献者|保留完整来源和许可；修改逐文件标记|', '|prism_ui/hct|每个文件 Apache 头；NOTICE|Google LLC 2021，Apache-2.0|保留原头和 NOTICE|', '|prism_ui/shapes|shapes.dart 完整 MIT；NOTICE|Agbama Gifted 2025，MIT|保留完整许可|', '|prism_ui/sliver_list|每个文件完整 MIT；NOTICE|Matej Knopp、Superlist 及贡献者 2024，MIT|保留完整许可|', '|navigator_resizable|文件头完整 MIT|Daichi Fujita 2024，MIT|保留完整许可|', '|ink_sparkle shader|shader 头及 NOTICE|Flutter Authors 2013，BSD-3-Clause|保留版权并补齐许可文本|', '|QrMatrix|lib/ui/qr_matrix.dart 完整 BSD 头|Dart QR project authors 2014，BSD-3-Clause|保留完整许可|', '|code_forge 与 Rust editor|plugins/code_forge/LICENSE；Rust editor/mod.rs|FlClash、Athul A S 2025，MIT；适配集成 GPL-3.0|独立原生可选包，保持 MIT 原文及生成桥接来源|', '|window、tray、wifi_ssid|各插件 LICENSE|MIT；window 含 LiJianying 版权|保留，平台注册仍由宿主负责|', '|dynamic_color|插件 LICENSE|Apache-2.0|保留|', '|服务图标|assets/images/services/LICENSE.md；完整 CC0 文本已保留|Simple Icons 13.0 CC0；Claude/Disney 中性标记由 FlClash 自绘|已原样纳入服务组件；不授予商标权|', '|JetBrainsMono-Regular.ttf|name 表为 2.304；与 JetBrains 官方 v2.304 字节一致；完整 OFL 在包内|OFL-1.1；2020 JetBrains Mono Project Authors|已原样注册；字体包名命名空间已适配|', '|Twemoji.Mozilla.ttf|内部 family 实为 Twemoji COLRv0；与 Emoji-COLRv0 项目字体字节一致|具体来源已定位，项目表格 BY-SA 与正文 BY 授权描述冲突；见 review-findings|继续隔离，未注册到运行时；不以 Mozilla 文件名推断授权|', '|avatar/arue.jpg、june2.jpg，应用/托盘 Logo|未见独立资源授权|未明确|隔离：不纳入组件库资源、不声称可自由使用|', '|GeoIP/ASN/geosite/CA|assets/data；core 子模块|业务数据/证书各自授权，UI 无需使用|不纳入组件包|', '', '## 已发现的所有版权/许可头', '', '|源文件|证据|', '|---|---|']
    for r in records:
        for p in r.get('license_lines', []):
            if 'LICENSE' in r['path'] or len(p['text']) > 240:
                continue
            licenses.append(f"|[{r['repo']}/{r['path']}:L{p['line']}]({src(r,p['line'])})|{p['text'].replace('|','/')}|")
    licenses += ['', '五个实际消费包（含 standalone 示例）的 Dart 依赖完整许可见 ../../licenses/dependencies/index.json；Rust Cargo.lock 全图见 ../../licenses/rust/index.json。tools/dependency_licenses.py、rust_licenses.py 与 bundled_notices.py 保存完整许可证并将必要原文装入运行时包；许可证缺失或字体授权未清之前，不发布含这些内容的二进制/资产包。法律条文以各原始许可证为准。']
    write('license-inventory.md', licenses)
    print(f'Rendered six audit documents; {len(records)} source records; {len(frontend)} associated frontend records.')


if __name__ == '__main__':
    main()
