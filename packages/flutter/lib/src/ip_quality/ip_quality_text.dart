// Derived from chen08209/FlClash, lib/features/ip_quality/ip_quality_text.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../ui/fonts.dart';
import 'model.dart';

import 'labels.dart';

class IpQualityText extends StatelessWidget {
  const IpQualityText({
    super.key,
    required this.ip,
    this.quality,
    this.hideIp = false,
    this.style,
  });

  final String ip;
  final IpQuality? quality;
  final bool hideIp;
  final TextStyle? style;

  static const _mask = '*****';

  @override
  Widget build(BuildContext context) {
    final shownIp = hideIp ? _mask : ip;
    final color = quality?.level.color(context);
    var style = this.style;
    if (hideIp) {
      style = (style ?? const TextStyle()).toJetBrainsMono;
    }
    if (color != null) {
      style = (style ?? const TextStyle()).copyWith(color: color);
    }
    return Tooltip(
      preferBelow: false,
      message: shownIp,
      child: Text(
        shownIp,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
