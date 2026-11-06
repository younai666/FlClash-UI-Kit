// Derived from chen08209/FlClash, lib/common/num.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

// ignore_for_file: constant_identifier_names


import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:flutter/widgets.dart';

/// Pinned to English so every locale reads K and M, never 万 or тыс.
final _compactFormat = NumberFormat.compact(locale: 'en');

extension NumExt on num {
  String get compact => _compactFormat.format(this);

  String fixed({int decimals = 2}) {
    String formatted = toStringAsFixed(decimals);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }
    return formatted;
  }

  TrafficShow get traffic {
    const units = TrafficUnit.values;
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return (
      value: size.fixed(decimals: 1),
      unit: units[unitIndex].name,
    );
  }

  TrafficShow get shortTraffic {
    const units = TrafficUnit.values;
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return (
      value: size.toStringAsFixed(0),
      unit: ' ${units[unitIndex].name}',
    );
  }
}

extension DoubleExt on double {
  bool moreOrEqual(double value) {
    return this > value || (value - this).abs() < precisionErrorTolerance;
  }
}

extension OffsetExt on Offset {
  double getCrossAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dx : dy;
  }

  double getMainAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dy : dx;
  }
}

enum TrafficUnit { B, KB, MB, GB, TB }
typedef TrafficShow = ({String value, String unit});

// From lib/models/common.dart:560-562, adapted to the record projection.
extension TrafficShowExt on TrafficShow {
  String get show => '$value$unit';
}
