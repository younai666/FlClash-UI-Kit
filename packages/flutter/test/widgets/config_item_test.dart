// Derived from chen08209/FlClash, test/widgets/config_item_test.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/flclash_ui_kit.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const appLocalizations = KitLocalizations(Locale('en'));

  test('a DNS listen address takes what net.SplitHostPort reads', () {
    for (final value in [
      '0.0.0.0:1053',
      ':53',
      '127.0.0.1:65535',
      'localhost:53',
      '[::]:1053',
      '[fe80::1]:53',
    ]) {
      expect(
        validateListenAddress(value, appLocalizations),
        isNull,
        reason: value,
      );
    }
    for (final value in [
      '0.0.0.0',
      '0.0.0.0:0',
      '0.0.0.0:65536',
      '0.0.0.0:+53',
      ':::53',
      '[::1]',
      '[1.2.3.4]:53',
      'bad host:53',
    ]) {
      expect(
        validateListenAddress(value, appLocalizations),
        appLocalizations.invalidListenContent,
        reason: value,
      );
    }
  });

  test('an NTP server is a domain or an IP address', () {
    for (final value in ['time.apple.com', '162.159.200.1', '2606:4700::1']) {
      expect(validateHost(value, appLocalizations), isNull, reason: value);
    }
    for (final value in [
      'https://time.apple.com',
      'time.apple.com:123',
      'time..com',
      'time apple',
      '-time.com',
    ]) {
      expect(
        validateHost(value, appLocalizations),
        appLocalizations.invalidHostContent,
        reason: value,
      );
    }
  });
}
