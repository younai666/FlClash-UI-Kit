"""Preserve the profile summary, wavy indicator and detail presentation."""


def register_profiles(register, base):
    prefix = "import 'package:flutter/widgets.dart';\nimport 'package:flclash_ui_kit/flclash_ui_kit.dart';\n\n"
    source = (base / 'lib/views/dashboard/widgets/profiles.dart').read_text(encoding='utf-8')
    open_profile = source[source.index('void _openProfile'):source.index('const _nearlyUsedShare')]
    config_state = source[source.index('class _ConfigStats extends'):source.index('    final figure = DashboardText.figure(', source.index('class _ConfigStatsState'))]
    register('lib/views/dashboard/widgets/profiles.dart', 'dashboard/profiles.dart', [
        (source[:source.index('typedef _Usage')], "import 'dart:math' as math;\n" + prefix),
        (open_profile, ''),
        ('ConsumerWidget', 'StatelessWidget'), ('BuildContext context, WidgetRef ref', 'BuildContext context'),
        ('const ProfilesCard({super.key});', '''const ProfilesCard({super.key, this.profile, this.switchable = false, this.isUpdating = false,
    this.stats, this.statsFailed = false, this.onOpen, this.onSwitch, this.onSync});
  final Profile? profile;
  final bool switchable;
  final bool isUpdating;
  final ProfileStats? stats;
  final bool statsFailed;
  final VoidCallback? onOpen;
  final VoidCallback? onSwitch;
  final VoidCallback? onSync;'''),
        ('    final profile = ref.watch(currentProfileProvider);\n    final switchable = ref.watch(\n      profilesProvider.select((profiles) => profiles.length > 1),\n    );',
         '    final profile = this.profile;\n    final switchable = this.switchable;'),
        ('_SyncButton(profile: profile)', '_SyncButton(isUpdating: isUpdating, onPressed: onSync)'),
        ('() => showProfilesSheet(context)', 'onSwitch'),
        ('() => _openProfile(context, profile)', 'onOpen'),
        ('chevron: mobile,', 'chevron: mobile && onOpen != null,'),
        ('_ConfigStats(figure: figure)', '_ConfigStats(figure: figure, stats: stats, failed: statsFailed)'),
        ('double _widthOf(String text, TextStyle style) =>\n    globalState.measure.computeTextSize(Text(text, style: style)).width;',
         'double _textWidth(BuildContext context, String text, TextStyle style) =>\n    MeasureScope.of(context).computeTextSize(Text(text, style: style)).width;'),
        ('_widthOf(', '_textWidth(context, '),
        ('const _SyncButton({required this.profile});\n\n  final Profile profile;',
         'const _SyncButton({required this.isUpdating, this.onPressed});\n\n  final bool isUpdating;\n  final VoidCallback? onPressed;'),
        ('    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));\n', ''),
        ('onPressed: () => syncProfile(ref, profile),', 'onPressed: onPressed,'),
        (config_state, '''class _ConfigStats extends StatelessWidget {
  const _ConfigStats({required this.figure, required this.stats, required this.failed});
  final AppTextStyle figure;
  final ProfileStats? stats;
  final bool failed;
  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
'''),
        ('widget.figure', 'this.figure'), ('configCountsFailed', 'failed'),
        ('Profile?', 'DashboardProfile?'), ('ProfileType', 'DashboardProfileType'),
        ('profile?.realLabel', 'profile?.label'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('_WavyProgressPainter', 'WavyProgressPainter'),
    ])
    source = (base / 'lib/views/dashboard/widgets/profile_detail.dart').read_text(encoding='utf-8')
    state = source[source.index('class ProfileDetailSheet'):source.index('    final appLocalizations = context.appLocalizations;', source.index('class _ProfileDetailSheetState'))]
    stats = '''stats: switch (configCounts) {
                        final counts? => profileStatsOf(counts, providers),
                        null => null,
                      },'''
    extend = source[source.index('String _extendLabel'):source.index('class _StatsGrid')]
    register('lib/views/dashboard/widgets/profile_detail.dart', 'dashboard/profile_detail.dart', [
        (state, '''class ProfileDetailSheet extends StatelessWidget {
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
'''),
        ('profile.realLabel', 'profile.label'), ('ProfileType', 'DashboardProfileType'),
        ('onPressed: () => syncProfile(ref, profile),', 'onPressed: onSync,'),
        ('onPressed: () => _handlePreview(profile),', 'onPressed: onPreview,'),
        (stats, 'stats: stats,'), ('configCountsFailed', 'statsFailed'),
        ('_extendLabel(context, profile.extendType)', "profile.extensionLabel ?? KitLocalizations.of(context).standard"),
        (extend, ''),
        ('                if (providers.isNotEmpty)\n                  ExternalProvidersSliver(providers: providers),', '                ...providerSlivers,'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('_StatsGrid', 'ProfileStatsGrid'), ('_InfoRow', 'ProfileInfoRow'),
        ('const ProfileStatsGrid({', 'const ProfileStatsGrid({super.key, '),
        ('const ProfileInfoRow({', 'const ProfileInfoRow({super.key, '),
        ('body: CustomScrollView(', 'body: Builder(builder: (context) => CustomScrollView('),
        ('        ],\n      ),\n    );\n  }\n}\n\nclass ProfileStatsGrid', '        ],\n      )),\n    );\n  }\n}\n\nclass ProfileStatsGrid'),
    ], excerpt=('class ProfileDetailSheet', None, prefix + 'const _statSpacing = 8.0;\n\n',
        '完整详情与统计网格/信息行；文件计数、数据库、更新/预览和外部 Provider 表由宿主负责'))
