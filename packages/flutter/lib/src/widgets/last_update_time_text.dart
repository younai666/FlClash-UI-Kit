// Derived from chen08209/FlClash, lib/widgets/last_update_time_text.dart
// Commit: be84736605527034689c95bf27828ff27d912c5e; GPL-3.0, except retained third-party headers.
// Modified 2026-11-05 for FlClash-UI-Kit: imports, localization/host contracts; original drawing and motion retained.

import 'package:flclash_ui_kit/src/datetime.dart';
import 'package:flutter/widgets.dart';

import 'active_polling.dart';

class LastUpdateTimeText extends StatelessWidget {
  final DateTime? lastUpdateDate;
  final TextStyle? style;
  final bool compact;

  const LastUpdateTimeText({
    super.key,
    required this.lastUpdateDate,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdateDate == null) {
      return Text('', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) {
        return Text(
          lastUpdateDate!.getLastUpdateTimeDesc(context, compact: compact),
          style: style,
        );
      },
    );
  }
}
