// Derived from chen08209/FlClash, lib/features/ip_quality/ip_quality_sheet.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flutter/widgets.dart';

Future<void> showIpQualitySheet(
  BuildContext context, {
  required String ip,
  IpQuality? quality,
  bool isLoading = false,
  Object? error,
  bool hideIp = false,
  ValueChanged<bool>? onHideIpChanged,
  VoidCallback? onRetry,
}) {
  return showSheet<void>(
    context: context,
    builder: (_) => IpQualitySheet(
      ip: ip,
      quality: quality,
      isLoading: isLoading,
      error: error,
      hideIp: hideIp,
      onHideIpChanged: onHideIpChanged,
      onRetry: onRetry,
    ),
  );
}

class IpQualitySheet extends StatelessWidget {
  const IpQualitySheet({
    super.key,
    required this.ip,
    this.quality,
    this.isLoading = false,
    this.error,
    this.hideIp = false,
    this.onHideIpChanged,
    this.onRetry,
  });

  final String ip;
  final IpQuality? quality;
  final bool isLoading;
  final Object? error;
  final bool hideIp;
  final ValueChanged<bool>? onHideIpChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    return Scaffold(
      title: localizations.outboundIp,
      actions: [
        if (onRetry != null || isLoading)
          AppBarActionButton(
            data: IconButtonData(
              glyph: AppGlyphs.refresh,
              tooltip: localizations.ipQualityRetry,
              isLoading: isLoading,
              onPressed: onRetry,
            ),
          ),
      ],
      body: _IpQualityDetail(
        ip: ip,
        quality: quality,
        isLoading: isLoading,
        error: error,
        hideIp: hideIp,
        onHideIpChanged: onHideIpChanged,
      ),
    );
  }
}

class _HideIpItem extends StatelessWidget {
  const _HideIpItem({required this.hideIp, required this.onChanged});

  final bool hideIp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      title: Text(KitLocalizations.of(context).hideIp),
      onPressed: () => onChanged(!hideIp),
      trailing: Switch(value: hideIp, onChanged: onChanged),
    );
  }
}

class _IpQualityDetail extends StatelessWidget {
  const _IpQualityDetail({
    required this.ip,
    required this.quality,
    required this.isLoading,
    required this.error,
    required this.hideIp,
    required this.onHideIpChanged,
  });

  /// The optical edge of the xl-radius cards, as in the memory sheet.
  static const _tipInset = 5.0;

  final String ip;
  final IpQuality? quality;
  final bool isLoading;
  final Object? error;
  final bool hideIp;
  final ValueChanged<bool>? onHideIpChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    final error = this.error;
    final failed = quality == null && !isLoading;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
        bottom: 20 + context.bottomInset,
        top: context.contentTopPadding,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_tipInset, 8, _tipInset, 0),
          child: Text(
            localizations.detectionTip,
            style: AppTextStyle.body
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
        generateSection(
          title: localizations.basicInfo,
          items: [
            DetailRow(
              title: localizations.ipAddress,
              copyText: ip,
              value: IpQualityText(ip: ip, quality: quality, hideIp: hideIp),
            ),
            if (failed)
              DetailRow(
                title: localizations.ipType,
                value: Text(
                  localizations.ipQualityFailed,
                  style: TextStyle(color: context.colorScheme.error),
                ),
              )
            else
              ..._qualityRows(context, quality),
          ],
        ),
        if (!failed)
          generateSection(
            title: localizations.network,
            items: _networkRows(context, quality),
          ),
        if (failed && error is IpQualityLookupException)
          generateSection(
            title: localizations.ipQualitySources,
            items: [
              for (final failure in error.failures)
                DetailRow(
                  title: failure.source.label,
                  value: Text(failure.status.label(context)),
                ),
            ],
          ),
        if (onHideIpChanged != null)
          generateSection(
            title: localizations.other,
            items: [_HideIpItem(hideIp: hideIp, onChanged: onHideIpChanged!)],
          ),
      ],
    );
  }

  /// A lookup still running lays out every row it will fill, so the page
  /// keeps its height when the values arrive.
  List<Widget> _qualityRows(BuildContext context, IpQuality? quality) {
    final localizations = KitLocalizations.of(context);
    if (quality == null) {
      return [
        DetailRow(
          title: localizations.ipQualityLevel,
          value: const SkeletonText(width: 40),
        ),
        DetailRow(
          title: localizations.ipType,
          value: const SkeletonText(width: 64),
        ),
        DetailRow(
          title: localizations.ipFlags,
          value: const SkeletonText(width: 40),
        ),
      ];
    }
    final flags = [
      if (quality.isTor) localizations.ipFlagTor,
      if (quality.isAbuser) localizations.ipFlagAbuser,
      if (quality.isVpn) localizations.ipFlagVpn,
      if (quality.isProxy) localizations.ipFlagProxy,
    ];
    return [
      DetailRow(
        title: localizations.ipQualityLevel,
        value: Text(
          quality.level.label(context),
          style: TextStyle(color: quality.level.color(context)),
        ),
      ),
      DetailRow(
        title: localizations.ipType,
        value: Text(quality.type.label(context)),
      ),
      DetailRow(
        title: localizations.ipFlags,
        value: flags.isEmpty
            ? Text(localizations.none)
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [for (final flag in flags) MetaChip(label: flag)],
              ),
      ),
    ];
  }

  List<Widget> _networkRows(BuildContext context, IpQuality? quality) {
    final localizations = KitLocalizations.of(context);
    Widget valueOf(String? text, {required double width}) =>
        switch ((quality, text)) {
          (null, _) => SkeletonText(width: width),
          (_, final text?) => Text(text),
          _ => const Text('—'),
        };
    final organization = quality?.organization;
    final asn = switch (quality?.asn) {
      final asn? => 'AS$asn',
      null => null,
    };
    return [
      DetailRow(
        title: localizations.ipOrganization,
        copyText: organization,
        value: valueOf(organization, width: 120),
      ),
      DetailRow(
        title: localizations.ipAsn,
        copyText: asn,
        value: valueOf(asn, width: 56),
      ),
      DetailRow(
        title: localizations.ipQualitySource,
        value: valueOf(quality?.source.label, width: 72),
      ),
    ];
  }
}
