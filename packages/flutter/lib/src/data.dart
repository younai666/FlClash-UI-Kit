// Presentation-only projections of FlClash lib/models/common.dart (Traffic),
// lib/models/profile.dart (SubscriptionInfo), lib/enum/enum.dart (CoreStatus,
// IpType, IpQualityLevel, IpQualitySource, IpQualitySourceStatus),
// lib/common/ip_quality.dart (IpQualityFailure, IpQualityLookupException), and
// lib/common/constant.dart (collection equalities), commit be84736605527034689c95bf27828ff27d912c5e.
// Modified 2026-11-06: remove serialization, providers and persistence. GPL-3.0.
import 'package:collection/collection.dart';

import 'dashboard/service_types.dart';

const stringListEquality = ListEquality<String>();
const stringAndStringMapEntryListEquality =
    ListEquality<MapEntry<String, String>>();

/// Projection of FlClash lib/enum/enum.dart:862.
enum CoreStatus { connecting, connected, disconnected }

/// Bytes sampled in one interval; the host owns sampling and history updates.
class Traffic {
  const Traffic({this.up = 0, this.down = 0});
  final num up;
  final num down;

  num get speed => up + down;
}

/// Subscription counters in bytes; [expire] is Unix time in seconds, or zero.
class SubscriptionInfo {
  const SubscriptionInfo({
    this.upload = 0,
    this.download = 0,
    this.total = 0,
    this.expire = 0,
  });
  final int upload;
  final int download;
  final int total;
  final int expire;
}

// Projections of models/common.dart:604 and models/ip_quality.dart:8-40.
// Classification, network lookup, storage and startup holds belong to the host.
class OutboundInfo {
  const OutboundInfo({required this.ip, this.countryCode});
  final String ip;
  final String? countryCode;
}

enum OutboundQualityLevel { good, normal, risky }

class OutboundQuality {
  const OutboundQuality({
    required this.typeLabel,
    required this.levelLabel,
    this.level = OutboundQualityLevel.normal,
    this.organization,
    this.asn,
  });
  final String typeLabel;
  final String levelLabel;
  final OutboundQualityLevel level;
  final String? organization;
  final int? asn;
}

// Projections of FlClash lib/enum/enum.dart:470-486 and lib/common/ip_quality.dart:9-18.
enum IpType { residential, mobile, business, hosting }

enum IpQualityLevel { good, normal, risky }

enum IpQualitySource {
  identMe('ident.me'),
  ipApiCom('ip-api.com'),
  ipQuery('ipquery.io'),
  ipLocate('iplocate.io'),
  proxyCheck('proxycheck.io'),
  ipApiIs('ipapi.is');

  const IpQualitySource(this.label);

  final String label;
}

enum IpQualitySourceStatus { noType, timeout, rateLimited, failed, ipMismatch }

typedef IpQualityFailure = ({
  IpQualitySource source,
  IpQualitySourceStatus status,
});

class IpQualityLookupException implements Exception {
  const IpQualityLookupException(this.failures);

  final List<IpQualityFailure> failures;
}

/// Projection of FlClash lib/models/core.dart:427-446. Bytes, supplied by host.
class CoreMemoryStats {
  const CoreMemoryStats({
    this.rss = 0,
    this.heapInuse = 0,
    this.heapIdle = 0,
    this.stackInuse = 0,
    this.runtimeOther = 0,
  });
  final int rss;
  final int heapInuse;
  final int heapIdle;
  final int stackInuse;
  final int runtimeOther;
  int get runtimeTotal => heapInuse + heapIdle + stackInuse + runtimeOther;
}

// Presentation projection of common/service_probe.dart:83–110 and
// providers/routed_probe.dart. Hosts own scheduling, epochs and route validation.
enum ProbePhase { idle, probing, ready, failed }

class ServiceCheck {
  const ServiceCheck(this.status, {this.delay});
  final ServiceProbeStatus status;
  final int? delay;
}
