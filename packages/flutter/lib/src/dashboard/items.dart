import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';

/// Presentation data replacing the application's service-backed dashboard enum.
class DashboardItem {
  const DashboardItem({
    required this.id,
    required this.title,
    required this.glyph,
    required this.card,
    this.subtitle,
    this.removable = true,
    this.index = 0,
  });

  final Object id;
  final String title;
  final String? subtitle;
  final Glyph glyph;
  final Widget card;
  final bool removable;
  final int index;

  String label(BuildContext context) => title;
  String? description(BuildContext context) => subtitle;

  @override
  bool operator ==(Object other) => other is DashboardItem && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
