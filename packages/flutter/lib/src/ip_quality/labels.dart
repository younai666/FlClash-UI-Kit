// Derived from chen08209/FlClash, lib/features/ip_quality/labels.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:prism_ui/prism_ui.dart';

import '../data.dart';
import '../localizations.dart';
import 'package:flutter/widgets.dart';

extension IpTypeLabel on IpType {
  String label(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    return switch (this) {
      IpType.residential => localizations.ipTypeResidential,
      IpType.mobile => localizations.ipTypeMobile,
      IpType.business => localizations.ipTypeBusiness,
      IpType.hosting => localizations.ipTypeHosting,
    };
  }
}

extension IpQualityLevelView on IpQualityLevel {
  String label(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    return switch (this) {
      IpQualityLevel.good => localizations.ipQualityGood,
      IpQualityLevel.normal => localizations.ipQualityNormal,
      IpQualityLevel.risky => localizations.ipQualityRisky,
    };
  }

  Color? color(BuildContext context) {
    return switch (this) {
      IpQualityLevel.good => context.colorScheme.success,
      IpQualityLevel.normal => null,
      IpQualityLevel.risky => context.colorScheme.error,
    };
  }
}

extension IpQualitySourceStatusLabel on IpQualitySourceStatus {
  String label(BuildContext context) {
    final localizations = KitLocalizations.of(context);
    return switch (this) {
      IpQualitySourceStatus.noType => localizations.ipSourceNoType,
      IpQualitySourceStatus.timeout => localizations.timeout,
      IpQualitySourceStatus.rateLimited => localizations.ipSourceRateLimited,
      IpQualitySourceStatus.failed => localizations.serviceFailed,
      IpQualitySourceStatus.ipMismatch => localizations.ipSourceIpMismatch,
    };
  }
}
