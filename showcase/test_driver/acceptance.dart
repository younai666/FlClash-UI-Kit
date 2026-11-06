import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) {
      stderr.writeln('No native report; inspect the test failure above.');
      return;
    }
    final platform = data['platform'] as String;
    final output = Directory('../docs/audit/screenshots')
      ..createSync(recursive: true);
    final report = Map<String, dynamic>.from(data);
    final paths = <String>[];
    for (final capture in report.remove('captures') as List<dynamic>) {
      final name = 'stage4-$platform-${capture['name']}.png';
      await File('${output.path}/$name')
          .writeAsBytes(base64Decode(capture['png'] as String));
      paths.add('screenshots/$name');
    }
    report['screenshots'] = paths;
    await File(
      '../docs/audit/runtime-$platform.json',
    ).writeAsString('${const JsonEncoder.withIndent('  ').convert(report)}\n');
  },
  writeResponseOnFailure: true,
);
