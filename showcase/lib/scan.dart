import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'section.dart';

/// The original scan renderer, driven by a host preview rather than a camera.
class ScanDemo extends StatefulWidget {
  const ScanDemo({super.key});
  @override
  State<ScanDemo> createState() => _ScanDemoState();
}

class _ScanDemoState extends State<ScanDemo> with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 4800));
  var _running = true;
  var _landscape = false;
  var _torch = false;
  var _contrast = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motionDuration(const Duration(milliseconds: 4800)) == Duration.zero) {
      _animation.stop();
      _animation.value = 0.3;
    } else if (_running) {
      _animation.repeat();
    }
  }
  @override
  void dispose() { _animation.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => DemoList(children: [
    DemoSection(
      title: '原始扫描绘制与响应布局', source: 'FlClash lib/pages/scan.dart:449–887',
      code: 'final layout = ScanLayout(size: size, padding: padding, hintHeight: 42);\n'
        'CustomPaint(painter: ScannerOverlay(scanWindow: layout.scanWindow, color: mask));\n'
        'CustomPaint(painter: ScanEffectPainter(animation: animation, scanWindow: layout.scanWindow,\n'
        '  borderRadius: AppCorner.md, color: color, highlight: highlight, contrast: contrast));',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('此处展示实际扫描动效和布局，背景为示例二维码。相机、权限和识别结果由宿主接入。'),
        Wrap(spacing: 12, children: [
          TextButton(onPressed: () => setState(() {
            _running = !_running;
            if (_running) { _animation.repeat(); } else { _animation.stop(); }
          }), child: Text(_running ? '暂停扫描动效' : '继续扫描动效')),
          TextButton(onPressed: () => setState(() => _landscape = !_landscape), child: const Text('横竖布局')),
          TextButton(onPressed: () => setState(() => _contrast = !_contrast), child: const Text('切换光束颜色')),
        ]),
        SizedBox(height: _landscape ? 300 : 540, child: LayoutBuilder(builder: (context, constraints) {
          final layout = ScanLayout(size: constraints.biggest, padding: EdgeInsets.zero, hintHeight: 42);
          final scheme = context.colorScheme;
          return ClipRSuperellipse(borderRadius: AppRadius.lg, child: Stack(children: [
            Positioned.fill(child: ColoredBox(color: scheme.surfaceContainer,
              child: Center(child: QrCodeView(data: 'https://github.com/chen08209/FlClash', size: 180)))),
            Positioned.fill(child: CustomPaint(painter: ScannerOverlay(scanWindow: layout.scanWindow, color: scheme.onSurface.withValues(alpha: .35)))),
            Positioned.fill(child: CustomPaint(painter: ScanEffectPainter(animation: _animation,
              scanWindow: layout.scanWindow, borderRadius: AppCorner.md, color: scheme.primary,
              highlight: scheme.onPrimary, contrast: _contrast ? scheme.error : scheme.primary))),
            Positioned.fromRect(rect: layout.hint, child: const Center(child: Text('将二维码放入框中 · 示例预览'))),
            Positioned.fromRect(rect: layout.torch, child: IconButton(
              tooltip: '示例手电筒状态', onPressed: () => setState(() => _torch = !_torch),
              icon: GlyphIcon(_torch ? AppGlyphs.check : AppGlyphs.sparkle))),
          ]));
        })),
      ]),
    ),
  ]);
}
