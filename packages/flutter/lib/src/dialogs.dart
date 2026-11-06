// Derived from FlClash lib/common/dialog.dart:44-316,
// be84736605527034689c95bf27828ff27d912c5e. GPL-3.0.
// Modified 2026-11-06: explicit context; no global navigator or service state.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';
import 'localizations.dart';
import 'scaffold/scaffold.dart';
import 'ui/qr_code.dart';

typedef UpdatingMessage = ({String label, String message});

// From dialog.dart:14-33, using the caller's context instead of global focus.
BuildContext _alertContext(BuildContext caller) {
  BuildContext? cursor = caller;
  while (cursor != null) {
    final route = ModalRoute.of(cursor);
    if (route is AlertHostRoute) {
      final host = route.navigator;
      if (host != null && host.mounted) return host.context;
      break;
    }
    final next = route?.navigator?.context;
    if (identical(next, cursor)) break;
    cursor = next;
  }
  return caller;
}

Future<bool?> showKitMessage(BuildContext context, {
  required InlineSpan message,
  String? title,
  String? confirmText,
  String? cancelText,
  bool dismissible = true,
  bool destructive = false,
}) => showFloatingDialog<bool>(
  context: _alertContext(context),
  dismissible: dismissible,
  child: Builder(builder: (context) {
    final l = KitLocalizations.of(context);
    return AlertDialog(
      title: title ?? l.tip,
      destructive: destructive,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelText ?? l.cancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmText ?? l.confirm)),
      ],
      child: SelectableText.rich(TextSpan(children: [message]), style: const TextStyle(overflow: TextOverflow.visible)),
    );
  }),
);

/// True saves, false discards, null stays. Preserve all three outcomes.
Future<bool?> showKitSaveChanges(BuildContext context) => showKitMessage(
  context,
  message: TextSpan(text: KitLocalizations.of(context).saveChanges),
);

Future<void> showKitQrCode(
  BuildContext context, {
  required String title,
  required String data,
  String? message,
}) {
  return showFloatingDialog<void>(
    context: _alertContext(context),
    child: Builder(
      builder: (context) {
        final l = KitLocalizations.of(context);
        return AlertDialog(
          title: title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.close),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              if (QrCodeView.fits(data)) ...[
                QrCodeView(data: data),
                if (message != null) Text(message, textAlign: TextAlign.center),
              ] else
                Text(
                  l.qrcodeTooLongTip,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> showKitFailureDetails(
  BuildContext context,
  List<UpdatingMessage> failures,
) {
  return showSheet(
    context: _alertContext(context),
    builder: (_) => FailureDetailsSheet(failures: failures),
  );
}

void showKitFailures(BuildContext context, List<UpdatingMessage> failures) {
  final l = KitLocalizations.of(context);
  final host = BannerHost.maybeOf(context);
  if (host == null) return;
  switch (failures) {
    case []:
      return;
    case [final failure]:
      host.show(
        l.failedItem(failure.label, failure.message),
        level: BannerLevel.error,
      );
    default:
      host.show(
        l.failedCount(failures.length),
        level: BannerLevel.error,
        onTap: () {
          if (context.mounted) {
            unawaited(showKitFailureDetails(context, failures));
          }
        },
      );
  }
}

class FailureDetailsSheet extends StatelessWidget {
  final List<UpdatingMessage> failures;

  const FailureDetailsSheet({super.key, required this.failures});

  @override
  Widget build(BuildContext context) {
    final labelsByMessage = <String, List<String>>{};
    for (final failure in failures) {
      (labelsByMessage[failure.message] ??= []).add(failure.label);
    }
    final groups = labelsByMessage.entries.toList();
    return Scaffold(
      title: KitLocalizations.of(context).errorDetails,
      body: Builder(
        builder: (context) => SelectionArea(
          child: PrismListView(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.sectionsTopPadding,
              bottom: 20 + context.bottomInset,
            ),
            itemCount: groups.length,
            itemBuilder: (_, index) {
              final MapEntry(key: message, value: labels) = groups[index];
              return generateSection(
                items: [
                  for (final label in labels)
                    DecorationListItem(
                      title: TooltipText(
                        text: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
                footer: message,
              );
            },
          ),
        ),
      ),
    );
  }
}
