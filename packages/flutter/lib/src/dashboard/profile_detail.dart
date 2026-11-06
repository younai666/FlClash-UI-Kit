// Derived from chen08209/FlClash, lib/views/dashboard/widgets/profile_detail.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

const _statSpacing = 8.0;

class ProfileDetailSheet extends StatelessWidget {
  const ProfileDetailSheet({super.key, required this.profile, this.stats, this.statsFailed = false,
    this.isUpdating = false, this.onSync, this.onPreview, this.providerSlivers = const []});
  final DashboardProfile profile;
  final ProfileStats? stats;
  final bool statsFailed;
  final bool isUpdating;
  final VoidCallback? onSync;
  final VoidCallback? onPreview;
  final List<Widget> providerSlivers;
  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final subscriptionInfo = profile.subscriptionInfo;
    return Scaffold(
      title: profile.label,
      iconActions: [
        if (profile.type == DashboardProfileType.url)
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: appLocalizations.sync,
            isLoading: isUpdating,
            onPressed: onSync,
          ),
        IconButtonData(
          glyph: AppGlyphs.eye,
          tooltip: appLocalizations.runtimeConfig,
          onPressed: onPreview,
        ),
      ],
      body: Builder(builder: (context) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.contentTopPadding,
              bottom: 20 + context.bottomInset,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverList.list(
                  children: [
                    ProfileStatsGrid(
                      stats: stats,
                      failed: statsFailed,
                    ),
                    if (subscriptionInfo != null && subscriptionInfo.total > 0)
                      generateSection(
                        title: appLocalizations.subscriptionInfo,
                        items: [
                          ListItem(
                            title: SubscriptionInfoView(
                              subscriptionInfo: subscriptionInfo,
                            ),
                          ),
                        ],
                      ),
                    generateSection(
                      title: appLocalizations.profile,
                      items: [
                        ProfileInfoRow(
                          label: appLocalizations.lastUpdated,
                          value: LastUpdateTimeText(
                            lastUpdateDate: profile.lastUpdateDate,
                          ),
                        ),
                        if (profile.type != DashboardProfileType.custom)
                          ProfileInfoRow(
                            label: appLocalizations.extendMode,
                            value: Text(
                              profile.extensionLabel ?? KitLocalizations.of(context).standard,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                ...providerSlivers,
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key, required this.stats, required this.failed});

  final ProfileStats? stats;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    final stats = this.stats;
    final tiles = [
      (appLocalizations.proxyGroup, stats?.groups),
      (appLocalizations.proxies, stats?.proxies),
      (appLocalizations.rules, stats?.rules),
      (appLocalizations.providers, stats?.providers),
    ];
    Widget rowOf(Iterable<(String, int?)> pair) {
      return Row(
        spacing: _statSpacing,
        children: [
          for (final (label, value) in pair)
            Expanded(
              child: _StatTile(
                label: label,
                value: value?.toString() ?? (failed ? '-' : null),
              ),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        spacing: _statSpacing,
        children: [rowOf(tiles.take(2)), rowOf(tiles.skip(2))],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            value ?? '0',
            maxLines: 1,
            style: AppTextStyle.title2
                .of(context, emphasized: true)
                .copyWith(color: colorScheme.onSurface),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(label),
      trailing: DefaultTextStyle.merge(
        style: AppTextStyle.subheadline
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
        child: value,
      ),
    );
  }
}
