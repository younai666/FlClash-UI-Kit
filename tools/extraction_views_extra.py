"""Extra shell, hotkey, theme, about, tools, and profiles extractions."""


def register_views_extra(register, base):
    register('lib/common/keyboard.dart', 'hotkey/keyboard.dart', [
        ("import 'package:fl_clash/enum/enum.dart';", "import 'package:flutter/foundation.dart';\nimport 'models.dart';"),
        ("\nimport 'system.dart';\n", '\n'),
        (
            "  ShortcutLabels.host()\n    : this(isMacOS: system.isMacOS, isWindows: system.isWindows);",
            "  ShortcutLabels.host()\n    : this(\n        isMacOS: !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS,\n        isWindows: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows,\n      );",
        ),
    ])

    register('test/common/keyboard_test.dart', '@test/common/keyboard_test.dart', [
        ("import 'package:fl_clash/common/keyboard.dart';\nimport 'package:fl_clash/enum/enum.dart';", "import 'package:flclash_ui_kit/flclash_ui_kit.dart';"),
    ])
