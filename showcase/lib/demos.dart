import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'section.dart';
import 'controls.dart';
import 'collections.dart';
import 'effects.dart';
import 'dashboard.dart';
import 'glyph_catalog.dart';
import 'application.dart';
import 'scan.dart';
import 'platform.dart';
import 'editor_unavailable.dart' if (dart.library.io) 'editor_native.dart';

final demos = <DemoSpec>[
  DemoSpec(
    'controls',
    '基础控件',
    '按钮 卡片 开关 滑块 Chip',
    AppGlyphs.toggle,
    (_) => const ControlsDemo(),
  ),
  DemoSpec(
    'forms',
    '输入与表单',
    '验证 密码 选项 选择面板',
    AppGlyphs.edit,
    (_) => const FormsDemo(),
  ),
  DemoSpec(
    'lists',
    '列表与拖动',
    '虚拟列表 重排 展开 动态增删',
    AppGlyphs.dragHandle,
    (_) => const CollectionsDemo(),
  ),
  DemoSpec(
    'navigation',
    '导航与布局',
    'Dock Sidebar Tabs 自适应',
    AppGlyphs.dashboard,
    (_) => const NavigationDemo(),
  ),
  DemoSpec(
    'overlays',
    '弹层与菜单',
    'Sheet 弹窗 嵌套菜单 右键',
    AppGlyphs.layers,
    (_) => const OverlaysDemo(),
  ),
  DemoSpec(
    'motion',
    '动效与转场',
    '淡入 缩放 容器转场 返回手势',
    AppGlyphs.sparkle,
    (_) => const MotionDemo(),
  ),
  DemoSpec(
    'glass',
    '玻璃与材质',
    'Liquid Glass Goo 模糊 折射',
    AppGlyphs.eye,
    (_) => const GlassDemo(),
  ),
  DemoSpec(
    'graphics',
    '图形与图标',
    'Glyph 形状变换 字体 颜色',
    AppGlyphs.star,
    (_) => const GraphicsDemo(),
  ),
  DemoSpec(
    'feedback',
    '状态与反馈',
    '骨架屏 加载 空状态 Banner',
    AppGlyphs.info,
    (_) => const FeedbackDemo(),
  ),
  DemoSpec(
    'palette',
    '调色器与二维码',
    'HCT HSL HSV HEX QR',
    AppGlyphs.sliders,
    (_) => const PaletteDemo(),
  ),
  DemoSpec(
    'records',
    '记录流与表格',
    '按 key 复用 排序 列宽拖动',
    AppGlyphs.logs,
    (_) => const RecordsDemo(),
  ),
  DemoSpec(
    'dashboard',
    'Dashboard 编辑',
    '密度 阴影 摇摆 删除 添加 重排',
    AppGlyphs.customize,
    (_) => const DashboardDemo(),
  ),
  DemoSpec('application', '应用页面与筛选', '分组 多选 删除 草稿保存 订阅信息', AppGlyphs.filter, (_) => const ApplicationDemo()),
  DemoSpec('theme-preview', '主题动态预览', '原始缩略绘制 滑动 淡入 明暗 分屏', AppGlyphs.palette, (_) => const ThemePreviewDemo()),
  DemoSpec('editor', '原生代码编辑器', 'Rust CodeForge IME 折叠 查找 替换 补全 撤销', AppGlyphs.compose, (_) => const EditorDemo()),
  DemoSpec('scan', '扫描绘制与布局', '彗星边框 网格 光束 横竖屏', AppGlyphs.qrCode, (_) => const ScanDemo()),
  DemoSpec('platform', '桌面窗口与系统颜色', '标题栏 置顶 最大化 托盘 系统种子', AppGlyphs.customize, (_) => const PlatformDemo()),
];

class NavigationDemo extends StatefulWidget {
  const NavigationDemo({super.key});
  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this);
  int _selected = 0;
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      NavigationDockDestination(glyph: AppGlyphs.dashboard, label: '概览'),
      NavigationDockDestination(glyph: AppGlyphs.profiles, label: '资料'),
      NavigationDockDestination(glyph: AppGlyphs.tools, label: '工具'),
    ];
    void select(int v) => setState(() {
      _selected = v;
      _tabs.animateTo(v);
    });
    return DemoList(
      children: [
        DemoSection(
          title: 'NavigationDock / FloatingNavigationBar',
          source: 'prism_ui/lib/navigation_dock.dart',
          code: 'NavigationDock(destinations: destinations, selectedIndex: selected, onSelected: select)',
          child: Column(
            children: [
              NavigationDock(
                destinations: destinations,
                selectedIndex: _selected,
                onSelected: select,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: FloatingNavigationBar(
                  destinations: destinations,
                  selectedIndex: _selected,
                  onSelected: select,
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'NavigationBar / TabBarView',
          source: 'prism_ui/lib/navigation_bar.dart · tab_view.dart',
          code: 'TabController(length: 3, vsync: this);\nTabBarView(controller: tabs, children: pages)',
          child: Column(
            children: [
              NavigationBar(
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: GlyphIcon(d.glyph),
                      label: d.label,
                    ),
                ],
                selectedIndex: _selected,
                onDestinationSelected: select,
              ),
              SizedBox(
                height: 180,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Center(
                        child: Text(
                          '可左右滑动 · 页面 ${i + 1}',
                          style: AppTextStyle.title2.of(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'NavigationSidebar',
          source: 'prism_ui/lib/sidebar.dart',
          code: 'NavigationSidebar(expanded: true, destinations: destinations, selectedIndex: selected, onSelected: select)',
          child: SizedBox(
            height: 270,
            child: Align(
              alignment: Alignment.centerLeft,
              child: NavigationSidebar(
                destinations: [
                  for (final d in destinations)
                    SidebarDestination(glyph: d.glyph, label: d.label),
                ],
                expanded: true,
                selectedIndex: _selected,
                onSelected: select,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
