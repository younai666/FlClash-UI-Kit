import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_kit/shapes.dart' as shapes;

import 'section.dart';

class OverlaysDemo extends StatelessWidget {
  const OverlaysDemo({super.key});
  Widget _sheet(BuildContext context, [ScrollController? scroll]) => Scaffold(
    title: '可交互面板',
    body: Builder(
      builder: (context) => ListView(
        controller: scroll,
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          20,
          context.contentTopPadding + 12,
          20,
          32,
        ),
        children: [
          const Text('手机上下拖动切换吸附点；桌面以侧面板呈现。'),
          TextButton(
            onPressed: () => showFormSheet<void>(
              context: context,
              builder: (context) => _sheet(context),
            ),
            child: const Text('再打开一层'),
          ),
          TextButton(
            onPressed: () => showInSheet<void>(
              context,
              builder: (context) => _sheet(context),
            ),
            child: const Text('面板内打开页面'),
          ),
          for (var i = 0; i < 15; i++)
            ListItem(
              title: Text('面板内容 ${i + 1}'),
              onTap: () => notifyDemo(context, '已点击 ${i + 1}'),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'Sheet / FormSheet / SnapSheet / PagedSheet',
        source: 'prism_ui/lib/sheet.dart · snap_sheet.dart · paged_sheet.dart',
        code: 'showSnapSheet<void>(context, builder: (context, controller) => Scaffold(\n  title: "Panel", body: ListView(controller: controller, children: rows)));',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () =>
                  showSheet<void>(context: context, builder: (c) => _sheet(c)),
              child: const Text('自适应 Sheet'),
            ),
            OutlinedButton(
              onPressed: () => showFormSheet<void>(
                context: context,
                builder: (c) => _sheet(c),
              ),
              child: const Text('表单 Sheet'),
            ),
            OutlinedButton(
              onPressed: () => showSnapSheet<void>(context, builder: _sheet),
              child: const Text('吸附 Sheet'),
            ),
            TextButton(
              onPressed: () => showExtend<void>(
                context,
                props: const ExtendProps(forceFull: true),
                builder: (c) => _sheet(c),
              ),
              child: const Text('整页转场'),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'AlertDialog / InputDialog',
        source: 'prism_ui/lib/dialog.dart · input.dart',
        code: "showFloatingDialog<void>(context: context, child: AlertDialog(title: '标题', child: const Text('正文'), actions: actions))",
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => showFloatingDialog<void>(
                context: context,
                child: Builder(
                  builder: (context) => AlertDialog(
                    title: '删除此项目？',
                    destructive: true,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          notifyDemo(context, '已确认删除');
                        },
                        child: const Text('删除'),
                      ),
                    ],
                    child: const Text('这是本地交互示例，确认后显示结果。'),
                  ),
                ),
              ),
              child: const Text('确认弹窗'),
            ),
            OutlinedButton(
              onPressed: () async {
                final result = await showFloatingDialog<String>(
                  context: context,
                  child: const InputDialog(
                    title: '输入内容',
                    value: 'FlClash UI Kit',
                  ),
                );
                if (context.mounted && result != null) {
                  notifyDemo(context, result);
                }
              },
              child: const Text('输入弹窗'),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'PopupAnchor / ContextMenuRegion / 子菜单',
        source: 'prism_ui/lib/popup.dart · context_menu.dart',
        code: 'PopupAnchor(targetBuilder: (open) => FilledButton(onPressed: open, child: label),\n  popupBuilder: (_) => PopupMenu(items: items))',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupAnchor(
              targetBuilder: (open) =>
                  FilledButton(onPressed: open, child: const Text('打开层级菜单')),
              popupBuilder: (_) => PopupMenu(
                items: [
                  PopupMenuItem(
                    label: '已选项',
                    checked: true,
                    glyph: AppGlyphs.check,
                    onPressed: () => notifyDemo(context, '已选项'),
                  ),
                  PopupMenuItem(
                    label: '子菜单',
                    glyph: AppGlyphs.more,
                    subItems: [
                      PopupMenuItem(
                        label: '复制',
                        glyph: AppGlyphs.copy,
                        onPressed: () => notifyDemo(context, '复制'),
                      ),
                      PopupMenuItem(
                        label: '粘贴',
                        glyph: AppGlyphs.paste,
                        onPressed: () => notifyDemo(context, '粘贴'),
                      ),
                    ],
                  ),
                  PopupMenuItem(
                    label: '删除',
                    glyph: AppGlyphs.delete,
                    danger: true,
                    onPressed: () => notifyDemo(context, '删除'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ContextMenuRegion(
              menuItems: [
                PopupMenuItem(
                  label: '检查交互',
                  onPressed: () => notifyDemo(context, '右键或长按菜单已工作'),
                ),
              ],
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text('在这里右键 / 长按'),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class MotionDemo extends StatefulWidget {
  const MotionDemo({super.key});
  @override
  State<MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<MotionDemo> {
  bool _visible = true;
  int _version = 0;
  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      FilledButton(
        onPressed: () => setState(() {
          _visible = !_visible;
          _version++;
        }),
        child: const Text('触发状态变化'),
      ),
      DemoSection(
        title: 'FadeBox / FadeThroughBox / FadeScaleBox',
        source: 'prism_ui/lib/fade_box.dart · fade_through.dart',
        code: 'FadeThroughBox(child: Text("state", key: ValueKey(state)))',
        child: Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            FadeBox(child: Text('淡入 $_version', key: ValueKey(_version))),
            FadeThroughBox(
              child: Text('穿透 $_version', key: ValueKey(_version)),
            ),
            FadeScaleBox(child: Text('缩放 $_version', key: ValueKey(_version))),
            FadeScaleEnterBox(
              key: ValueKey(_version),
              child: const SelectionBadge(),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'AnimatedVisibility / ExpandIcon',
        source: 'prism_ui/lib/animated_visibility.dart · effect.dart',
        code: 'AnimatedVisibility.bottomNavigation(visible: visible, child: content)',
        child: Column(
          children: [
            ExpandIcon(expand: _visible),
            AnimatedVisibility.bottomNavigation(
              visible: _visible,
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('显隐时参与布局动画'),
                ),
              ),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'OpenContainer push / zoom 与返回手势',
        source: 'prism_ui/lib/open_container.dart · drag_back.dart',
        code: 'OpenContainer<void>(transition: OpenContainerTransition.zoom,\n  closedBuilder: (_, open) => Card(onPressed: open, child: label),\n  openBuilder: (_, close) => page)',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final transition in OpenContainerTransition.values)
              SizedBox(
                width: 230,
                child: OpenContainer<void>(
                  transition: transition,
                  closedBuilder: (_, open) => Card(
                    onPressed: open,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('打开 ${transition.name}'),
                    ),
                  ),
                  openBuilder: (_, close) => Scaffold(
                    title: '${transition.name} 转场',
                    body: Center(
                      child: FilledButton(
                        onPressed: close,
                        child: const Text('返回'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      DemoSection(
        title: 'ElasticPress / ElasticHover / PressSurface',
        source: 'prism_ui/lib/navigation_dock.dart · press_surface.dart',
        code: 'ElasticHover(child: ElasticPress(child: PressSurface(fill: color, shape: AppShape.xl, onPressed: tap, child: content)))',
        child: Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            for (final look in PressLook.values)
              ElasticHover(
                child: ElasticPress(
                  child: PressSurface(
                    fill: context.colorScheme.primaryContainer,
                    shape: AppShape.xl,
                    look: look,
                    padding: const EdgeInsets.all(24),
                    onPressed: () => notifyDemo(context, look.name),
                    child: Text(look.name),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class GlassDemo extends StatefulWidget {
  const GlassDemo({super.key});
  @override
  State<GlassDemo> createState() => _GlassDemoState();
}

class _GlassDemoState extends State<GlassDemo> {
  double _position = 0.3;
  double _gap = 12;
  int _style = 0;
  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final style = [
      LiquidGlassStyle.regular(scheme),
      LiquidGlassStyle.menu(scheme),
      LiquidGlassStyle.editMenu(scheme),
    ][_style];
    return DemoList(
      children: [
        DemoSection(
          title: 'LiquidGlass / GlassHost 捕获与折射',
          source: 'prism_ui/lib/liquid_glass.dart · liquid_glass_capture.dart · shaders/liquid_glass.frag',
          code: 'KitApp(liquidGlass: LiquidGlassQuality.standard, home: page);\nLiquidGlass(style: LiquidGlassStyle.regular(context.colorScheme), borderRadius: AppRadius.xl, child: content)',
          child: Column(
            children: [
              SegmentedControl<int>(
                segments: const [(0, 'regular'), (1, 'menu'), (2, 'editMenu')],
                value: _style,
                onChanged: (v) => setState(() => _style = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 290,
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary,
                              const Color(0xFF29D3AD),
                              const Color(0xFFFFBD60),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      for (var i = 0; i < 7; i++)
                        Positioned(
                          left: 30 + i * 65 - _position * 180,
                          top: i.isOdd ? 50 : 160,
                          child: Text(
                            'Aa ${i + 1}',
                            style: const TextStyle(
                              fontSize: 54,
                              color: Color(0xAAFFFFFF),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      Center(
                        child: LiquidGlass(
                          style: style,
                          borderRadius: AppRadius.xxl,
                          child: const Padding(
                            padding: EdgeInsets.all(28),
                            child: Text('真实 Shader · 拖动背景'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Slider(
                value: _position,
                onChanged: (v) => setState(() => _position = v),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'GooSurface / GooPane / 融合轮廓',
          source: 'prism_ui/lib/goo.dart · navigation_dock.dart',
          code: 'GooSurface(color: color, child: Row(children: [GooPane(child: button), GooPane(child: button)]))',
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GooSurface(
                  color: scheme.primaryContainer,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: _gap,
                    children: [
                      for (var i = 0; i < 3; i++)
                        GooPane(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Center(
                              child: IconButton(
                                onPressed: () => notifyDemo(context, '液滴 $i'),
                                tooltip: '液滴 $i',
                                icon: const GlyphIcon(AppGlyphs.star),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Slider(
                value: _gap,
                min: 0,
                max: 28,
                onChanged: (v) => setState(() => _gap = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeedbackDemo extends StatefulWidget {
  const FeedbackDemo({super.key});
  @override
  State<FeedbackDemo> createState() => _FeedbackDemoState();
}

class _FeedbackDemoState extends State<FeedbackDemo> {
  int _status = 1;
  double _progress = 0.45;
  bool _loading = true;
  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'NullStatusSwitcher / EmptyIllustration',
        source: 'prism_ui/lib/null_status.dart · shapes/',
        code: 'NullStatusSwitcher(isLoading: loading, isEmpty: empty, isSearching: searching,\n  nullStatus: NullStatus(label: label, illustration: NullStatusIllustration.data), child: content)',
        child: Column(
          children: [
            SegmentedControl<int>(
              segments: const [(0, '内容'), (1, '空白'), (2, '搜索'), (3, '加载')],
              value: _status,
              onChanged: (v) => setState(() => _status = v),
            ),
            SizedBox(
              height: 250,
              child: NullStatusSwitcher(
                isLoading: _status == 3,
                isEmpty: _status == 1 || _status == 2,
                isSearching: _status == 2,
                nullStatus: const NullStatus(
                  label: '暂无资料',
                  illustration: NullStatusIllustration.data,
                ),
                child: const Center(child: Text('内容已加载')),
              ),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'ActivityIndicator / Skeleton / Progress',
        source:
            'prism_ui/lib/loading.dart · skeleton.dart · linear_progress.dart',
        code: 'ActivityIndicator();\nSkeletonText(width: 180);\nLinearProgressIndicator(value: progress);\nLoadingBar(active: loading)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListRow(
              title: const Text('加载动画'),
              trailing: Switch(
                value: _loading,
                onChanged: (v) => setState(() => _loading = v),
              ),
            ),
            LoadingBar(active: _loading),
            const SizedBox(height: 16),
            if (_loading)
              const Row(
                spacing: 16,
                children: [
                  ActivityIndicator(),
                  SkeletonPill(width: 60, height: 32),
                  SkeletonText(width: 110),
                ],
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            Slider(
              value: _progress,
              onChanged: (v) => setState(() => _progress = v),
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'BannerHost / 级别与排队',
        source: 'prism_ui/lib/banner.dart',
        code: "BannerHost.maybeOf(context)!.show('消息', level: BannerLevel.success)",
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in BannerLevel.values)
              OutlinedButton(
                onPressed: () =>
                    notifyDemo(context, '${level.name} 消息', level: level),
                child: Text(level.name),
              ),
          ],
        ),
      ),
    ],
  );
}

class MorphPreview extends StatelessWidget {
  const MorphPreview({super.key, required this.progress});
  final double progress;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size.square(140),
    painter: _MorphPainter(
      shapes.Morph(
        shapes.MaterialShapes.circle,
        shapes.MaterialShapes.cookie6Sided,
      ).toPath(progress: progress),
      context.colorScheme.primary,
    ),
  );
}

class _MorphPainter extends CustomPainter {
  _MorphPainter(this.path, this.color);
  final Path path;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width, size.height);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MorphPainter old) =>
      old.path != path || old.color != color;
}

class SampleChart extends StatefulWidget {
  const SampleChart({super.key});
  @override
  State<SampleChart> createState() => _SampleChartState();
}

class _SampleChartState extends State<SampleChart> {
  var _revision = 20;
  final _values = List.generate(20, (i) => 40 + 30 * math.sin(i * 0.8));
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 120,
        child: LineChart(
          values: _values,
          revision: _revision,
          capacity: 40,
          minScale: 100,
          color: context.colorScheme.primary,
          baselineRatio: 0.9,
        ),
      ),
      TextButton(
        onPressed: () => setState(() {
          _values.add(40 + 30 * math.sin(_revision++ * 0.8));
        }),
        child: const Text('追加采样'),
      ),
    ],
  );
}
