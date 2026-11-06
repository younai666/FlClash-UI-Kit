// Derived from FlClash lib/common/l10n_labels.dart:140-168,
// be84736605527034689c95bf27828ff27d912c5e. GPL-3.0.
// Modified 2026-11-05: read the route's locale rather than a global provider.
import 'package:flutter/widgets.dart';
import '../localizations.dart';
import 'types.dart';

extension RecordFacetKindL10n on RecordFacetKind {
  String? titleOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) {
      RecordFacetKind.network => l.protocol,
      RecordFacetKind.rule => l.rule,
      RecordFacetKind.level => l.logLevel,
      _ => null,
    };
  }
}

extension RecordGroupingL10n on RecordGrouping {
  String labelOf(BuildContext context) {
    final l = KitLocalizations.of(context);
    return switch (this) {
      RecordGrouping.app => l.app,
      RecordGrouping.host => l.host,
      RecordGrouping.rule => l.rule,
      RecordGrouping.exit => l.outboundExit,
    };
  }
}
