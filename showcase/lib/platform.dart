import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_platform/flclash_ui_platform.dart';
import 'section.dart';

class PlatformDemo extends StatefulWidget {
  const PlatformDemo({super.key});
  @override
  State<PlatformDemo> createState() => _PlatformDemoState();
}

class _PlatformDemoState extends State<PlatformDemo> {
  final _caption = ValueNotifier(const WindowCaptionState());
  var _lastAction = '尚未操作';
  var _capabilities = '点击读取，查看当前宿主的原生能力';
  bool get _desktop => !kIsWeb && [TargetPlatform.windows, TargetPlatform.linux, TargetPlatform.macOS].contains(defaultTargetPlatform);
  @override
  void dispose() { _caption.dispose(); super.dispose(); }
  Future<void> _read() async {
    try {
      final accent = await DynamicColorPlugin.getAccentColor();
      final seeds = await DynamicColorPlugin.getSystemSeeds();
      final bounds = _desktop ? await desktopWindow.getBounds() : null;
      if (mounted) setState(() => _capabilities = '窗口 $bounds\n系统强调色 $accent\n明暗种子 $seeds');
    } catch (error) {
      if (mounted) setState(() => _capabilities = '原生能力读取失败：$error');
    }
  }
  @override
  Widget build(BuildContext context) => DemoList(children: [
    DemoSection(title: '桌面标题栏与按钮状态', source: 'FlClash lib/manager/window_manager.dart',
      code: 'final caption = WindowCaptionController(); // dispose when unmounted\n'
        'WindowHeaderBar(height: getWindowHeaderHeight(isDesktop: true, isMacOS: false),\n'
        '  onDragStart: desktopWindow.startDragging, onDoubleTap: caption.toggleMaximized,\n'
        '  actions: WindowHeaderActions(state: caption, onPin: caption.togglePin,\n'
        '    onMinimize: desktopWindow.minimize, onMaximize: caption.toggleMaximized, onClose: hostClose));',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        WindowHeaderBar(height: 32,
          onDragStart: () => setState(() => _lastAction = '拖动窗口栏'),
          onDoubleTap: () => _caption.value = _caption.value.copyWith(isMaximized: !_caption.value.isMaximized),
          actions: WindowHeaderActions(state: _caption,
            onPin: () => _caption.value = _caption.value.copyWith(isPinned: !_caption.value.isPinned),
            onMinimize: () => setState(() => _lastAction = '最小化回调'),
            onMaximize: () => _caption.value = _caption.value.copyWith(isMaximized: !_caption.value.isMaximized),
            onClose: () => setState(() => _lastAction = '关闭回调'))),
        const SizedBox(height: 12),
        Text('交互状态：$_lastAction。此区域演示宿主回调；上方代码可接真实窗口控制器。'),
      ])),
    DemoSection(title: '实际原生能力读取', source: '可选包 packages/platform',
      code: 'await desktopWindow.ensureInitialized();\nawait desktopWindow.getBounds();\n'
        'await DynamicColorPlugin.getAccentColor();\nawait DynamicColorPlugin.getSystemSeeds();',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FilledButton(onPressed: kIsWeb ? null : _read, child: const Text('读取窗口与系统颜色')),
        const SizedBox(height: 12), Text(kIsWeb ? 'Web 无原生窗口/托盘通道，请运行桌面应用。' : _capabilities),
      ])),
  ]);
}
