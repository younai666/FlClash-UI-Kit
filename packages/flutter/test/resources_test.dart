import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  test('batch errors retain line numbers and cap visible issues', () {
    final batch = BatchInput<String>(label: 'Names', formatTip: 'one per line',
      parse: (_) => const ParsedInput(entries: [], skippedExisting: 0, issues: []), issueMessage: (_) => 'invalid');
    final parsed = ParsedInput<String>(entries: const [], skippedExisting: 0, issues: [
      for (var line = 1; line <= 4; line++) InputIssue(line: line, raw: 'bad', kind: InputIssueKind.invalidValue)]);
    expect(batch.issuesOf(const KitLocalizations(Locale('en')), parsed), 'Line 1: invalid\nLine 2: invalid\nLine 3: invalid');
    expect(batch.errorOf(const KitLocalizations(Locale('en')), null, attempted: true), 'Names is required');
  });
  testWidgets('entry dialog validates then returns the converted value', (tester) async {
    String? result;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: Builder(builder: (context) => TextButton(
      onPressed: () async { result = await showFloatingDialog<String>(context: context,
        child: EntryDialog<String>(title: 'Entry', valueField: const Field(label: 'Value', value: ''), toEntry: (v) => v.toUpperCase())); },
      child: const Text('Open entry')))));
    await tester.tap(find.text('Open entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(find.text('Value is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'alpha');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, 'ALPHA');
  });
  testWidgets('service SVGs load from package assets and refresh is host-owned', (tester) async {
    var refreshes = 0;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: DashboardDensityScope(
      density: DashboardDensity.standard, scale: 1,
      child: Column(children: [SizedBox(width: 560, height: 210, child: ServiceStatusCard(
        services: const [ServiceStatusItem(ServiceTarget.github, check: ServiceCheck(ServiceProbeStatus.available, delay: 83))],
        onRefresh: () => refreshes++)),
        Wrap(children: [for (final service in ServiceTarget.values) ServiceBadge(target: service, size: 32)]),
      ]))));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Check all'));
    expect(refreshes, 1);
    expect(find.text('83 ms'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('network rows report explicit values without platform services', (tester) async {
    bool? proxy, tun, vpn;
    await tester.pumpWidget(KitApp(locale: const Locale('en'), home: Center(child: SizedBox(width: 360,
      child: DashboardDensityScope(density: DashboardDensity.mobile, scale: 1, child: Column(mainAxisSize: MainAxisSize.min, children: [
        NetworkTakeoverCard(systemProxy: false, tun: true, onSystemProxyChanged: (v) => proxy = v, onTunChanged: (v) => tun = v),
        VpnCard(enabled: false, onChanged: (v) => vpn = v),
      ]))))));
    await tester.tap(find.text('System proxy'));
    await tester.tap(find.text('Virtual interface'));
    await tester.tap(find.text('VPN'));
    expect(proxy, isTrue);
    expect(tun, isFalse);
    expect(vpn, isTrue);
  });
  testWidgets('package icon ignores a stale asynchronous native result', (tester) async {
    final first = Completer<ImageProvider?>(), second = Completer<ImageProvider?>();
    Future<ImageProvider?> load(String name) => name == 'first' ? first.future : second.future;
    Widget probe(String name) => KitApp(home: PackageIcon(packageName: name, size: 32, loadIcon: load));
    final bytes = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
    final current = MemoryImage(bytes), stale = MemoryImage(Uint8List.fromList(bytes));
    await tester.pumpWidget(probe('first'));
    await tester.pumpWidget(probe('second'));
    second.complete(current);
    await tester.pump();
    first.complete(stale);
    await tester.pump();
    expect(tester.widget<Image>(find.byType(Image)).image, same(current));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('custom Prism strings do not replace kit application strings', (tester) async {
    await tester.pumpWidget(KitApp(locale: const Locale('en'), localizationsDelegates: const [_HostDelegate()],
      home: Builder(builder: (context) {
        expect(UiLocalizations.of(context), isA<_HostStrings>());
        return Text(KitLocalizations.of(context).memoryInfo);
      })));
    expect(find.text('Memory'), findsOneWidget);
  });
}

class _HostStrings implements UiLocalizations {
  @override
  dynamic noSuchMethod(Invocation invocation) => 'Host label';
}
class _HostDelegate extends LocalizationsDelegate<UiLocalizations> {
  const _HostDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<UiLocalizations> load(Locale locale) => SynchronousFuture(_HostStrings());
  @override
  bool shouldReload(_HostDelegate old) => false;
}
