// Derived from chen08209/FlClash, lib/views/profiles/add.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-06 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';


/// The ways to add a profile, in a menu out of the control [builder] makes.
class AddProfileMenu extends StatelessWidget {
  const AddProfileMenu({super.key, required this.builder});

  final Widget Function(PopupOpen open) builder;

  Future<void> _handleAddProfileFormFile(BuildContext context) async {
    unawaited(ProfilesScope.read(context).addProfileFromFile());
  }

  Future<void> _toScan(BuildContext context) async {
    final profilesAction = ProfilesScope.read(context);
    final url = await profilesAction.scanQrCode();
    if (url == null || !context.mounted) return;
    await whenRouteUncovered(context);
    if (context.mounted) await profilesAction.addProfileFromLink(url);
  }

  Future<void> _toAdd(BuildContext context) async {
    final profilesAction = ProfilesScope.read(context);
    final appLocalizations = KitLocalizations.of(context);
    final res = await showNamedUrlsForm(
      context,
      title: appLocalizations.importFromLink,
      urlLabel: appLocalizations.link,
      batchTip: appLocalizations.batchLinkInputTip,
      urlValidator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.link);
        }
        if (!value.isUrl && !value.isShareLink) {
          return appLocalizations.invalidLinkTip;
        }
        return null;
      },
      existingUrls: {
        for (final profile in ProfilesScope.read(context).profiles)
          if (profile.url.isNotEmpty) profile.url,
      },
      withAgeSecretKey: true,
    );
    switch (res) {
      case null:
        return;
      case [final single]:
        unawaited(
          profilesAction.addProfileFromLink(
            single.url,
            label: single.label,
            ageSecretKey: single.ageSecretKey,
          ),
        );
      default:
        unawaited(
          profilesAction.addProfilesFromLinks([
            for (final item in res) item.url,
          ]),
        );
    }
  }

  Future<void> _toSendFromPhone(BuildContext context) async {
    final profilesAction = ProfilesScope.read(context);
    final link = await showFloatingDialog<String>(context: context,
      child: const _SendFromPhoneDialog(),
    );
    if (link == null || !context.mounted) {
      return;
    }
    final appLocalizations = KitLocalizations.of(context);
    final confirmed = await showKitMessage(context,
      title: appLocalizations.sendFromPhoneConfirmTitle,
      message: TextSpan(text: link),
      confirmText: appLocalizations.import,
    );
    if (confirmed == true) {
      unawaited(profilesAction.addProfileFromLink(link));
    }
  }

  void _toAddCustom(BuildContext context) {
    unawaited(ProfilesScope.read(context).addCustomProfile(KitLocalizations.of(context).unnamed));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    return PopupAnchor(
      targetBuilder: builder,
      popupBuilder: (_) => PopupMenu(
        items: [
          PopupMenuItem(
            glyph: AppGlyphs.qrCode,
            label: appLocalizations.qrcode,
            onPressed: ProfilesScope.of(context).onScanQrCode == null ? null : () => _toScan(context),
          ),
          PopupMenuItem(
            glyph: AppGlyphs.importFile,
            label: appLocalizations.file,
            onPressed: ProfilesScope.of(context).onAddFromFile == null ? null : () => _handleAddProfileFormFile(context),
          ),
          PopupMenuItem(
            glyph: AppGlyphs.cloudDownload,
            label: appLocalizations.link,
            onPressed: () => _toAdd(context),
          ),
          if (ProfilesScope.of(context).isTV && ProfilesScope.of(context).startPhoneLinkReceiver != null)
            PopupMenuItem(
              glyph: AppGlyphs.devices,
              label: appLocalizations.sendFromPhone,
              onPressed: () => _toSendFromPhone(context),
            ),
          PopupMenuItem(
            section: const PopupMenuSection(),
            glyph: AppGlyphs.customize,
            label: appLocalizations.customProfile,
            onPressed: () => _toAddCustom(context),
          ),
        ],
      ),
    );
  }
}

class _SendFromPhoneDialog extends StatefulWidget {
  const _SendFromPhoneDialog();

  @override
  State<_SendFromPhoneDialog> createState() => _SendFromPhoneDialogState();
}

class _SendFromPhoneDialogState extends State<_SendFromPhoneDialog> {
  PhoneLinkSession? _receiver;
  bool _failed = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      final receiver = await ProfilesScope.read(context).startPhoneLinkReceiver?.call();
      if (!mounted) {
        await receiver?.close();
        return;
      }
      setState(() {
        _receiver = receiver;
        _failed = receiver == null;
      });
      final link = await receiver?.link;
      if (link != null && mounted) Navigator.of(context).pop(link);
    } catch (error) {
      if (mounted) setState(() { _failed = true; _error = error; });
    }
  }

  @override
  void dispose() {
    unawaited(_receiver?.close());
    super.dispose();
  }

  Widget _buildContent(BuildContext context) {
    final appLocalizations = KitLocalizations.of(context);
    if (_failed) {
      return Text(
        _error?.toString() ?? appLocalizations.sendFromPhoneNoNetwork,
        textAlign: TextAlign.center,
      );
    }
    final address = _receiver?.address.toString();
    if (address == null) {
      return const SizedBox.square(
        dimension: 96,
        child: Center(child: ActivityIndicator()),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        QrCodeView(data: address, size: 200),
        SelectableText(address, textAlign: TextAlign.center),
        Text(appLocalizations.sendFromPhoneTip, textAlign: TextAlign.center),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: KitLocalizations.of(context).sendFromPhone,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(KitLocalizations.of(context).cancel),
        ),
      ],
      child: _buildContent(context),
    );
  }
}
