// Derived from chen08209/FlClash, lib/views/proxies/common.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import 'models.dart';

const proxyGridSpacing = 8.0;

double listHeaderHeightOf(Measure measure) {
  return 20 +
      measure.textHeight(AppTextStyle.callout) +
      2 +
      measure.textHeight(AppTextStyle.caption1) +
      2;
}

double getItemHeight(Measure measure, ProxyCardType proxyCardType) {
  final baseHeight =
      16 +
      measure.textHeight(AppTextStyle.subheadline) * 2 +
      measure.textHeight(AppTextStyle.footnote) +
      8 +
      4;
  return switch (proxyCardType) {
    ProxyCardType.loose =>
      baseHeight + measure.textHeight(AppTextStyle.caption2) + 6,
    ProxyCardType.standard => baseHeight,
    ProxyCardType.compact =>
      baseHeight - measure.textHeight(AppTextStyle.subheadline),
  };
}

double getRowExtent(Measure measure, ProxyCardType proxyCardType) =>
    getItemHeight(measure, proxyCardType) + proxyGridSpacing;

class GroupOffsets {
  const GroupOffsets(this.groups, this.offsets);

  static const empty = GroupOffsets(<Group>[], <double>[]);

  final List<Group> groups;
  final List<double> offsets;

  bool get isEmpty => offsets.isEmpty;

  double offsetOf(String groupName) {
    final index = groups.indexWhere((group) => group.name == groupName);
    if (index < 0 || index >= offsets.length) {
      return 0;
    }
    return offsets[index];
  }
}

double? selectedRowOffset({
  required List<Proxy> proxies,
  required String? selectedProxyName,
  required int columns,
  required double rowExtent,
}) {
  final index = proxies.indexWhere((proxy) => proxy.name == selectedProxyName);
  if (index < 0) {
    return null;
  }
  return (index ~/ columns) * rowExtent;
}

void animateScrollTo(ScrollController controller, double offset) {
  if (!controller.hasClients) {
    return;
  }
  final position = controller.position;
  controller.animateTo(
    offset.clamp(position.minScrollExtent, position.maxScrollExtent),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
}
