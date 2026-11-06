// Presentation projections of FlClash lib/enum/enum.dart, lib/models/common.dart,
// lib/common/constant.dart, and lib/common/l10n_labels.dart,
// commit be84736605527034689c95bf27828ff27d912c5e.
// Modified 2026-11-06: remove Freezed/JSON codegen and global locale singletons;
// retain value equality, search/filter facets, groupers, and stream caps. GPL-3.0.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../datetime.dart';
import '../localizations.dart';
import '../search.dart';
import 'log_payload.dart';
import 'model.dart';
import 'types.dart';

const renderThrottleDuration = Duration(milliseconds: 300);

const maxLogsLength = 5000;
const maxRequestsLength = 2000;
const maxDnsQueriesLength = 3000;
const pausedMaxLogsLength = maxLogsLength * 2;
const pausedMaxRequestsLength = maxRequestsLength * 2;
const pausedMaxDnsQueriesLength = maxDnsQueriesLength * 2;

enum DnsMode { normal, fakeIp, redirHost, hosts }

enum DnsQueryInitiator { app, rule, direct, proxy, other }

extension DnsQueryInitiatorL10n on DnsQueryInitiator {
  String labelOfStrings(KitLocalizations appLocalizations) {
    return switch (this) {
      DnsQueryInitiator.app => appLocalizations.app,
      DnsQueryInitiator.rule => appLocalizations.rule,
      DnsQueryInitiator.direct => appLocalizations.direct,
      DnsQueryInitiator.proxy => appLocalizations.proxies,
      DnsQueryInitiator.other => appLocalizations.other,
    };
  }

  String labelOf(BuildContext context) =>
      labelOfStrings(KitLocalizations.of(context));
}

enum LogLevel { debug, info, warning, error, silent }

enum RequestFeed { recent, live }

@immutable
class Metadata {
  final int uid;
  final String network;
  final String sourceIP;
  final String sourcePort;
  final String destinationIP;
  final String destinationPort;
  final String host;
  final DnsMode? dnsMode;
  final String process;
  final String processPath;
  final String remoteDestination;
  final List<String> sourceGeoIP;
  final List<String> destinationGeoIP;
  final String destinationIPASN;
  final String sourceIPASN;
  final String specialRules;
  final String specialProxy;
  final bool mitm;
  final bool mitmRefused;

  const Metadata({
    this.uid = 0,
    this.network = '',
    this.sourceIP = '',
    this.sourcePort = '',
    this.destinationIP = '',
    this.destinationPort = '',
    this.host = '',
    this.dnsMode,
    this.process = '',
    this.processPath = '',
    this.remoteDestination = '',
    this.sourceGeoIP = const [],
    this.destinationGeoIP = const [],
    this.destinationIPASN = '',
    this.sourceIPASN = '',
    this.specialRules = '',
    this.specialProxy = '',
    this.mitm = false,
    this.mitmRefused = false,
  });

  Metadata copyWith({
    int? uid,
    String? network,
    String? sourceIP,
    String? sourcePort,
    String? destinationIP,
    String? destinationPort,
    String? host,
    DnsMode? dnsMode,
    String? process,
    String? processPath,
    String? remoteDestination,
    List<String>? sourceGeoIP,
    List<String>? destinationGeoIP,
    String? destinationIPASN,
    String? sourceIPASN,
    String? specialRules,
    String? specialProxy,
    bool? mitm,
    bool? mitmRefused,
  }) {
    return Metadata(
      uid: uid ?? this.uid,
      network: network ?? this.network,
      sourceIP: sourceIP ?? this.sourceIP,
      sourcePort: sourcePort ?? this.sourcePort,
      destinationIP: destinationIP ?? this.destinationIP,
      destinationPort: destinationPort ?? this.destinationPort,
      host: host ?? this.host,
      dnsMode: dnsMode ?? this.dnsMode,
      process: process ?? this.process,
      processPath: processPath ?? this.processPath,
      remoteDestination: remoteDestination ?? this.remoteDestination,
      sourceGeoIP: sourceGeoIP ?? this.sourceGeoIP,
      destinationGeoIP: destinationGeoIP ?? this.destinationGeoIP,
      destinationIPASN: destinationIPASN ?? this.destinationIPASN,
      sourceIPASN: sourceIPASN ?? this.sourceIPASN,
      specialRules: specialRules ?? this.specialRules,
      specialProxy: specialProxy ?? this.specialProxy,
      mitm: mitm ?? this.mitm,
      mitmRefused: mitmRefused ?? this.mitmRefused,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metadata &&
          other.uid == uid &&
          other.network == network &&
          other.sourceIP == sourceIP &&
          other.sourcePort == sourcePort &&
          other.destinationIP == destinationIP &&
          other.destinationPort == destinationPort &&
          other.host == host &&
          other.dnsMode == dnsMode &&
          other.process == process &&
          other.processPath == processPath &&
          other.remoteDestination == remoteDestination &&
          listEquals(other.sourceGeoIP, sourceGeoIP) &&
          listEquals(other.destinationGeoIP, destinationGeoIP) &&
          other.destinationIPASN == destinationIPASN &&
          other.sourceIPASN == sourceIPASN &&
          other.specialRules == specialRules &&
          other.specialProxy == specialProxy &&
          other.mitm == mitm &&
          other.mitmRefused == mitmRefused;

  @override
  int get hashCode => Object.hash(
        uid,
        network,
        sourceIP,
        sourcePort,
        destinationIP,
        destinationPort,
        host,
        dnsMode,
        process,
        processPath,
        remoteDestination,
        Object.hashAll(sourceGeoIP),
        Object.hashAll(destinationGeoIP),
        destinationIPASN,
        sourceIPASN,
        specialRules,
        specialProxy,
        mitm,
        mitmRefused,
      );
}

@immutable
class TrackerInfo {
  final String id;
  final int upload;
  final int download;
  final DateTime start;
  final Metadata metadata;
  final List<String> chains;
  final String rule;
  final String rulePayload;
  final int? downloadSpeed;
  final int? uploadSpeed;

  const TrackerInfo({
    required this.id,
    this.upload = 0,
    this.download = 0,
    required this.start,
    this.metadata = const Metadata(),
    this.chains = const [],
    this.rule = '',
    this.rulePayload = '',
    this.downloadSpeed,
    this.uploadSpeed,
  });

  TrackerInfo copyWith({
    String? id,
    int? upload,
    int? download,
    DateTime? start,
    Metadata? metadata,
    List<String>? chains,
    String? rule,
    String? rulePayload,
    int? downloadSpeed,
    int? uploadSpeed,
  }) {
    return TrackerInfo(
      id: id ?? this.id,
      upload: upload ?? this.upload,
      download: download ?? this.download,
      start: start ?? this.start,
      metadata: metadata ?? this.metadata,
      chains: chains ?? this.chains,
      rule: rule ?? this.rule,
      rulePayload: rulePayload ?? this.rulePayload,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerInfo &&
          other.id == id &&
          other.upload == upload &&
          other.download == download &&
          other.start == start &&
          other.metadata == metadata &&
          listEquals(other.chains, chains) &&
          other.rule == rule &&
          other.rulePayload == rulePayload &&
          other.downloadSpeed == downloadSpeed &&
          other.uploadSpeed == uploadSpeed;

  @override
  int get hashCode => Object.hash(
        id,
        upload,
        download,
        start,
        metadata,
        Object.hashAll(chains),
        rule,
        rulePayload,
        downloadSpeed,
        uploadSpeed,
      );
}

typedef RequestTraffic = ({int upload, int download});

extension TrackerInfoExt on TrackerInfo {
  String get title {
    final host = metadata.host;
    if (host.isNotEmpty) {
      return host;
    }
    return metadata.destinationIP;
  }

  String get progressText {
    final process = metadata.process;
    final uid = metadata.uid;
    if (uid != 0) {
      return '$process($uid)'.trim();
    }
    return process.trim();
  }

  String get ruleText => rulePayload.isNotEmpty ? '$rule($rulePayload)' : rule;

  List<String> get searchFields => [
        metadata.network,
        metadata.host,
        metadata.destinationIP,
        metadata.destinationPort,
        metadata.sourceIP,
        metadata.sourcePort,
        metadata.process,
        metadata.processPath,
        metadata.remoteDestination,
        metadata.destinationIPASN,
        ...metadata.destinationGeoIP,
        metadata.specialProxy,
        metadata.specialRules,
        rule,
        rulePayload,
        ...chains,
      ];
}

final trackerInfoFacets = <RecordFacet<TrackerInfo>>[
  RecordFacet(
    RecordFacetKind.network,
    (info) => [info.metadata.network],
    offered: true,
    order: const ['tcp', 'udp'],
    labelOf: (value) => value.toUpperCase(),
  ),
  RecordFacet(RecordFacetKind.rule, (info) => [info.rule], offered: true),
  RecordFacet(
    RecordFacetKind.mitm,
    (info) => [if (info.metadata.mitm) 'MITM'],
    offered: true,
  ),
  RecordFacet(RecordFacetKind.app, (info) => [info.metadata.process]),
  RecordFacet(RecordFacetKind.proxy, (info) => info.chains),
];

final trackerInfoGroupers = <RecordGrouper<TrackerInfo>>[
  RecordGrouper(RecordGrouping.app, (info) => info.metadata.process),
  RecordGrouper(RecordGrouping.host, (info) => info.title),
  RecordGrouper(RecordGrouping.rule, (info) => info.ruleText),
  RecordGrouper(RecordGrouping.exit, (info) => info.chains.firstOrNull ?? ''),
];

@immutable
class TrackerInfosState {
  final List<TrackerInfo> trackerInfos;
  final String query;
  final bool autoScrollToEnd;

  const TrackerInfosState({
    this.trackerInfos = const [],
    this.query = '',
    this.autoScrollToEnd = true,
  });

  TrackerInfosState copyWith({
    List<TrackerInfo>? trackerInfos,
    String? query,
    bool? autoScrollToEnd,
  }) {
    return TrackerInfosState(
      trackerInfos: trackerInfos ?? this.trackerInfos,
      query: query ?? this.query,
      autoScrollToEnd: autoScrollToEnd ?? this.autoScrollToEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerInfosState &&
          listEquals(other.trackerInfos, trackerInfos) &&
          other.query == query &&
          other.autoScrollToEnd == autoScrollToEnd;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(trackerInfos), query, autoScrollToEnd);
}

final _trackerInfoSearchTexts = Expando<String>();

extension TrackerInfosStateExt on TrackerInfosState {
  bool get isSearching => SearchQuery(query).isNotEmpty;

  List<TrackerInfo> get list {
    final searchQuery = SearchQuery(query);
    if (searchQuery.isEmpty) {
      return trackerInfos;
    }
    return trackerInfos
        .whereMatches(
          searchQuery,
          (trackerInfo) => trackerInfo.searchFields,
          texts: _trackerInfoSearchTexts,
        )
        .toList();
  }
}

@immutable
class DnsQuery {
  final String domain;
  final String type;
  final DnsQueryInitiator? initiator;
  final String upstream;
  final bool cached;
  final List<String> answers;
  final String rcode;
  final String error;
  final int delay;
  final DateTime time;

  const DnsQuery({
    required this.domain,
    required this.type,
    this.initiator,
    this.upstream = '',
    this.cached = false,
    this.answers = const [],
    this.rcode = '',
    this.error = '',
    this.delay = 0,
    required this.time,
  });

  DnsQuery copyWith({
    String? domain,
    String? type,
    DnsQueryInitiator? initiator,
    String? upstream,
    bool? cached,
    List<String>? answers,
    String? rcode,
    String? error,
    int? delay,
    DateTime? time,
  }) {
    return DnsQuery(
      domain: domain ?? this.domain,
      type: type ?? this.type,
      initiator: initiator ?? this.initiator,
      upstream: upstream ?? this.upstream,
      cached: cached ?? this.cached,
      answers: answers ?? this.answers,
      rcode: rcode ?? this.rcode,
      error: error ?? this.error,
      delay: delay ?? this.delay,
      time: time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DnsQuery &&
          other.domain == domain &&
          other.type == type &&
          other.initiator == initiator &&
          other.upstream == upstream &&
          other.cached == cached &&
          listEquals(other.answers, answers) &&
          other.rcode == rcode &&
          other.error == error &&
          other.delay == delay &&
          other.time == time;

  @override
  int get hashCode => Object.hash(
        domain,
        type,
        initiator,
        upstream,
        cached,
        Object.hashAll(answers),
        rcode,
        error,
        delay,
        time,
      );
}

extension DnsQueryExt on DnsQuery {
  bool get hasFailureRcode => rcode.isNotEmpty && rcode != 'NOERROR';

  bool get isFailed => error.isNotEmpty || hasFailureRcode;

  String get summary => error.isNotEmpty ? error : answers.join(', ');

  List<RecordFilter> resultFiltersOf(KitLocalizations appLocalizations) {
    final initiator = this.initiator;
    return [
      if (initiator != null)
        RecordFilter(
          RecordFacetKind.initiator,
          initiator.labelOfStrings(appLocalizations),
        ),
      if (cached) RecordFilter(RecordFacetKind.cache, appLocalizations.cache),
      if (hasFailureRcode) RecordFilter(RecordFacetKind.rcode, rcode),
    ];
  }

  List<String> tagsOf(KitLocalizations appLocalizations) => [
        type,
        for (final filter in resultFiltersOf(appLocalizations)) filter.value,
      ];

  List<String> searchFieldsOf(KitLocalizations appLocalizations) => [
        domain,
        ...tagsOf(appLocalizations),
        rcode,
        upstream,
        error,
        ...answers,
      ];
}

List<RecordFacet<DnsQuery>> dnsQueryFacetsOf(
  KitLocalizations appLocalizations,
) => [
  RecordFacet(RecordFacetKind.type, (query) => [query.type], offered: true),
  for (final kind in const [
    RecordFacetKind.initiator,
    RecordFacetKind.cache,
    RecordFacetKind.rcode,
  ])
    RecordFacet(
      kind,
      (query) => [
        for (final filter in query.resultFiltersOf(appLocalizations))
          if (filter.kind == kind) filter.value,
      ],
      offered: true,
    ),
];

@immutable
class DnsQueriesState {
  final List<DnsQuery> dnsQueries;
  final String query;
  final bool autoScrollToEnd;

  const DnsQueriesState({
    this.dnsQueries = const [],
    this.query = '',
    this.autoScrollToEnd = true,
  });

  DnsQueriesState copyWith({
    List<DnsQuery>? dnsQueries,
    String? query,
    bool? autoScrollToEnd,
  }) {
    return DnsQueriesState(
      dnsQueries: dnsQueries ?? this.dnsQueries,
      query: query ?? this.query,
      autoScrollToEnd: autoScrollToEnd ?? this.autoScrollToEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DnsQueriesState &&
          listEquals(other.dnsQueries, dnsQueries) &&
          other.query == query &&
          other.autoScrollToEnd == autoScrollToEnd;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(dnsQueries), query, autoScrollToEnd);
}

extension DnsQueriesStateExt on DnsQueriesState {
  bool get isSearching => SearchQuery(query).isNotEmpty;

  List<DnsQuery> listOf(KitLocalizations appLocalizations) {
    final searchQuery = SearchQuery(query);
    if (searchQuery.isEmpty) {
      return dnsQueries;
    }
    return dnsQueries
        .whereMatches(
          searchQuery,
          (dnsQuery) => dnsQuery.searchFieldsOf(appLocalizations),
        )
        .toList();
  }
}

@immutable
class Log {
  final LogLevel logLevel;
  final String payload;
  final String dateTime;

  const Log({
    this.logLevel = LogLevel.info,
    this.payload = '',
    required this.dateTime,
  });

  factory Log.app(String payload) {
    return Log(payload: payload, dateTime: DateTime.now().showFull);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log &&
          other.logLevel == logLevel &&
          other.payload == payload &&
          other.dateTime == dateTime;

  @override
  int get hashCode => Object.hash(logLevel, payload, dateTime);
}

final _logPayloads = Expando<LogPayload>();

extension LogExt on Log {
  LogPayload get parsed => _logPayloads[this] ??= LogPayload.parse(payload);
}

final logFacets = <RecordFacet<Log>>[
  RecordFacet(
    RecordFacetKind.level,
    (log) => [log.logLevel.name],
    offered: true,
    order: [for (final level in LogLevel.values) level.name],
  ),
];

@immutable
class LogsState {
  final List<Log> logs;
  final String query;
  final bool autoScrollToEnd;

  const LogsState({
    this.logs = const [],
    this.query = '',
    this.autoScrollToEnd = true,
  });

  LogsState copyWith({
    List<Log>? logs,
    String? query,
    bool? autoScrollToEnd,
  }) {
    return LogsState(
      logs: logs ?? this.logs,
      query: query ?? this.query,
      autoScrollToEnd: autoScrollToEnd ?? this.autoScrollToEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogsState &&
          listEquals(other.logs, logs) &&
          other.query == query &&
          other.autoScrollToEnd == autoScrollToEnd;

  @override
  int get hashCode => Object.hash(Object.hashAll(logs), query, autoScrollToEnd);
}

final _logSearchTexts = Expando<String>();

extension LogsStateExt on LogsState {
  bool get isSearching => SearchQuery(query).isNotEmpty;

  List<Log> get list {
    final searchQuery = SearchQuery(query);
    if (searchQuery.isEmpty) {
      return logs;
    }
    return logs
        .whereMatches(
          searchQuery,
          (log) => [log.payload, log.logLevel.name],
          texts: _logSearchTexts,
        )
        .toList();
  }
}
