// Derived from chen08209/FlClash, lib/models/ip_quality.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flutter/foundation.dart';

import '../data.dart';

@immutable
class IpQuality {
  final String ip;
  final IpQualitySource source;
  final IpType type;
  final String? organization;
  final int? asn;
  final bool isProxy;
  final bool isVpn;
  final bool isTor;
  final bool isAbuser;

  const IpQuality({
    required this.ip,
    required this.source,
    required this.type,
    this.organization,
    this.asn,
    this.isProxy = false,
    this.isVpn = false,
    this.isTor = false,
    this.isAbuser = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpQuality &&
          other.ip == ip &&
          other.source == source &&
          other.type == type &&
          other.organization == organization &&
          other.asn == asn &&
          other.isProxy == isProxy &&
          other.isVpn == isVpn &&
          other.isTor == isTor &&
          other.isAbuser == isAbuser;

  @override
  int get hashCode => Object.hash(
        ip,
        source,
        type,
        organization,
        asn,
        isProxy,
        isVpn,
        isTor,
        isAbuser,
      );
}

extension IpQualityExt on IpQuality {
  IpQualityLevel get level {
    if (isTor || isAbuser) {
      return IpQualityLevel.risky;
    }
    return switch (type) {
      IpType.residential ||
      IpType.mobile ||
      IpType.business => IpQualityLevel.good,
      IpType.hosting => IpQualityLevel.normal,
    };
  }
}
