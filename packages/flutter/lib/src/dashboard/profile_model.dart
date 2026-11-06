// Presentation projections of FlClash lib/models/profile.dart and
// lib/views/dashboard/widgets/profile_detail.dart:40, commit
// be84736605527034689c95bf27828ff27d912c5e; GPL-3.0.
// Modified 2026-11-05: no IDs, database, filesystem or update services.
import '../data.dart';

enum DashboardProfileType { url, file, custom }
typedef ProfileStats = ({int groups, int proxies, int rules, int providers});

class DashboardProfile {
  const DashboardProfile({required this.label, this.type = DashboardProfileType.url,
    this.subscriptionInfo, this.lastUpdateDate, this.extensionLabel});
  final String label;
  final DashboardProfileType type;
  final SubscriptionInfo? subscriptionInfo;
  final DateTime? lastUpdateDate;
  final String? extensionLabel;
}
