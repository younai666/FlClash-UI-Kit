// Derived from chen08209/FlClash, lib/pages/scan.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

const _scanWindowMaxSide = 400.0;
const _scanWindowShortestSideRatio = 0.67;
const _hintGap = 24.0;
const _hintInset = 32.0;
const _torchSize = 64.0;
const _torchBottomMargin = 48.0;
const _torchSideMargin = 24.0;
const _controlGap = 16.0;
const _edgeMargin = 16.0;

class ScanLayout {
  const ScanLayout._({
    required this.scanWindow,
    required this.hint,
    required this.torch,
  });

  // Short viewports, landscape or split screen, cannot stack the window, its
  // hint and the torch vertically, so the torch moves beside the window there.
  factory ScanLayout({
    required Size size,
    required EdgeInsets padding,
    required double hintHeight,
  }) {
    final below = ScanLayout._torchBelow(size, padding, hintHeight);
    final beside = ScanLayout._torchBeside(size, padding, hintHeight);
    return beside.scanWindow.width > below.scanWindow.width ? beside : below;
  }

  factory ScanLayout._torchBelow(
    Size size,
    EdgeInsets padding,
    double hintHeight,
  ) {
    final torchTop =
        size.height - max(padding.bottom, _torchBottomMargin) - _torchSize;
    final scanWindow = _fitScanWindow(
      size: size,
      top: padding.top + pageToolbarHeight,
      bottom: torchTop - _controlGap - _hintGap - hintHeight,
      maxWidth: size.width,
    );
    return ScanLayout._(
      scanWindow: scanWindow,
      hint: Rect.fromLTWH(
        padding.left + _hintInset,
        scanWindow.bottom + _hintGap,
        max(0, size.width - padding.horizontal - 2 * _hintInset),
        hintHeight,
      ),
      torch: Rect.fromLTWH(
        padding.left + (size.width - padding.horizontal - _torchSize) / 2,
        torchTop,
        _torchSize,
        _torchSize,
      ),
    );
  }

  factory ScanLayout._torchBeside(
    Size size,
    EdgeInsets padding,
    double hintHeight,
  ) {
    final inset =
        max(padding.left, padding.right) +
        _torchSideMargin +
        _torchSize +
        _controlGap;
    final scanWindow = _fitScanWindow(
      size: size,
      top: padding.top + _edgeMargin,
      bottom:
          size.height -
          max(padding.bottom, _edgeMargin) -
          _hintGap -
          hintHeight,
      maxWidth: size.width - 2 * inset,
    );
    final torch = Rect.fromLTWH(
      size.width - padding.right - _torchSideMargin - _torchSize,
      max(
        padding.top + pageToolbarHeight,
        scanWindow.center.dy - _torchSize / 2,
      ),
      _torchSize,
      _torchSize,
    );
    final hintTop = scanWindow.bottom + _hintGap;
    final hintInset = torch.bottom <= hintTop
        ? max(padding.left, padding.right) + _hintInset
        : inset;
    return ScanLayout._(
      scanWindow: scanWindow,
      hint: Rect.fromLTWH(
        hintInset,
        hintTop,
        max(0, size.width - 2 * hintInset),
        hintHeight,
      ),
      torch: torch,
    );
  }

  final Rect scanWindow;
  final Rect hint;
  final Rect torch;

  static Rect _fitScanWindow({
    required Size size,
    required double top,
    required double bottom,
    required double maxWidth,
  }) {
    final side = max(
      0.0,
      [
        _scanWindowMaxSide,
        size.shortestSide * _scanWindowShortestSideRatio,
        bottom - top,
        maxWidth,
      ].reduce(min),
    );
    final centerY = max(
      top + side / 2,
      min(size.height / 2, bottom - side / 2),
    );
    return Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: side,
      height: side,
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    required this.color,
    this.borderRadius = AppCorner.md,
  });

  final Rect scanWindow;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundWithCutout = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );
    canvas.drawPath(backgroundWithCutout, Paint()..color = color);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius;
  }
}

class ScanEffectPainter extends CustomPainter {
  ScanEffectPainter({
    required this.animation,
    required this.scanWindow,
    required this.borderRadius,
    required this.color,
    required this.highlight,
    required this.contrast,
  }) : super(repaint: animation);

  static const _sweepsPerCycle = 2;
  static const _gridCells = 18;

  final Animation<double> animation;
  final Rect scanWindow;
  final double borderRadius;
  final Color color;
  final Color highlight;
  final Color contrast;

  @override
  void paint(Canvas canvas, Size size) {
    if (scanWindow.isEmpty) return;
    final t = animation.value;
    final window = RSuperellipse.fromRectAndRadius(
      scanWindow,
      Radius.circular(borderRadius),
    );
    _paintBorder(canvas, window, t);
    canvas.save();
    canvas.clipRSuperellipse(window);
    _paintBeam(canvas, t);
    canvas.restore();
  }

  void _paintBorder(Canvas canvas, RSuperellipse window, double t) {
    Shader comet(Color tail, Color head) => SweepGradient(
      colors: [tail, tail, head, tail],
      stops: const [0, 0.55, 0.9, 1],
      transform: GradientRotation(2 * pi * t),
    ).createShader(scanWindow);
    canvas.drawRSuperellipse(
      window,
      Paint()
        ..shader = comet(contrast.opacity0, contrast)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRSuperellipse(
      window,
      Paint()
        ..shader = comet(color, highlight)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _paintBeam(Canvas canvas, double t) {
    final sweep = (t * _sweepsPerCycle) % 1;
    final opacity = sweep < 0.1
        ? sweep / 0.1
        : sweep > 0.85
        ? (1 - sweep) / 0.15
        : 1.0;
    if (opacity <= 0) {
      return;
    }
    final y =
        scanWindow.top + scanWindow.height * Curves.easeInOut.transform(sweep);
    final trail = Rect.fromLTRB(
      scanWindow.left,
      max(scanWindow.top, y - scanWindow.height * 0.45),
      scanWindow.right,
      y,
    );
    if (trail.height > 0) {
      canvas.saveLayer(trail, Paint());
      canvas.drawRect(
        trail,
        Paint()..shader = _edgeFadeShader(trail, contrast, opacity * 0.24),
      );
      canvas.drawPath(
        _gridPath(trail),
        Paint()
          ..shader = _edgeFadeShader(trail, contrast, opacity * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawRect(
        trail,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ).createShader(trail),
      );
      canvas.restore();
    }
    final line = Rect.fromCenter(
      center: Offset(scanWindow.center.dx, y),
      width: scanWindow.width,
      height: 3,
    );
    canvas.drawRect(
      line.inflate(4),
      Paint()
        ..shader = _edgeFadeShader(line, contrast, opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRect(
      line,
      Paint()..shader = _edgeFadeShader(line, color, opacity),
    );
    canvas.drawRect(
      Rect.fromCenter(center: line.center, width: line.width, height: 1),
      Paint()..shader = _edgeFadeShader(line, highlight, opacity),
    );
  }

  Shader _edgeFadeShader(Rect rect, Color color, double opacity) {
    const stops = 12;
    return LinearGradient(
      colors: [
        for (var i = 0; i <= stops; i++)
          color.withValues(alpha: opacity * sin(pi * i / stops)),
      ],
    ).createShader(rect);
  }

  Path _gridPath(Rect trail) {
    final cell = scanWindow.width / _gridCells;
    final path = Path();
    for (var x = scanWindow.left; x <= scanWindow.right; x += cell) {
      path
        ..moveTo(x, trail.top)
        ..lineTo(x, trail.bottom);
    }
    final firstRow = ((trail.top - scanWindow.top) / cell).ceil();
    for (
      var y = scanWindow.top + firstRow * cell;
      y <= trail.bottom;
      y += cell
    ) {
      path
        ..moveTo(trail.left, y)
        ..lineTo(trail.right, y);
    }
    return path;
  }

  @override
  bool shouldRepaint(ScanEffectPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius ||
        color != oldDelegate.color ||
        highlight != oldDelegate.highlight ||
        contrast != oldDelegate.contrast;
  }
}
