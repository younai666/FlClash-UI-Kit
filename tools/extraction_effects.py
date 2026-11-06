"""Additional presentation found by following native chrome and camera paths."""


def register_effects(register, base):
    prefix = "import 'package:flutter/widgets.dart';\nimport 'package:prism_ui/prism_ui.dart';\n"
    source = (base / 'lib/manager/window_manager.dart').read_text(encoding='utf-8')
    controller = source[source.index('/// Maximize and fullscreen'):source.index('class WindowHeaderBar')]
    register('lib/manager/window_manager.dart', 'window/header.dart', [
        (controller, ''),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
    ], excerpt=('class WindowHeaderLayout', None,
        prefix + "import 'package:flutter/foundation.dart' show ValueListenable;\nimport '../../icons.dart';\nimport '../localizations.dart';\nimport 'layout.dart';\n\n",
        'WindowHeaderLayout/State/Bar/Actions；原生事件控制器在 platform 包，应用生命周期与系统动作仍在上游'))
    register('lib/common/layout.dart', 'window/layout.dart', [
        ("import 'package:fl_clash/enum/enum.dart';", "import '../proxies/models.dart';"),
        ("import 'package:fl_clash/ui/ui.dart';", "import 'package:prism_ui/prism_ui.dart';"),
        ("\nimport 'constant.dart';\n", '\n'),
    ])

    source = (base / 'lib/views/dashboard/widgets/memory_info.dart').read_text(encoding='utf-8')
    reader = source[source.index('Future<MemorySnapshot?> _readMemory'):source.index('class MemoryInfo')]
    register('lib/views/dashboard/widgets/memory_info.dart', 'dashboard/memory_info.dart', [
        ("import 'dart:io';", ''),
        ("import 'package:fl_clash/common/common.dart';", ''),
        ("import 'package:fl_clash/core/method.dart';", ''),
        ("import 'package:fl_clash/enum/enum.dart';", ''),
        ("import 'package:fl_clash/l10n/l10n.dart';", ''),
        ("import 'package:fl_clash/models/models.dart';", ''),
        ("import 'package:fl_clash/providers/app.dart';", ''),
        ("import 'package:fl_clash/providers/core.dart';", ''),
        ("import 'package:fl_clash/ui/icons/icons.dart';", ''),
        ("import 'package:fl_clash/views/dashboard/layout.dart';", ''),
        ("import 'package:fl_clash/views/dashboard/style.dart';", ''),
        ('package:fl_clash/widgets/widgets.dart', 'package:flclash_ui_kit/flclash_ui_kit.dart'),
        ("import 'package:flutter_riverpod/flutter_riverpod.dart';", ''),
        ("import 'card.dart';", ''),
        (reader, ''),
        ('ConsumerStatefulWidget', 'StatefulWidget'), ('ConsumerState<', 'State<'),
        ('final MemoryReader? memoryReader;', 'final MemoryReader memoryReader;\n  final Future<void> Function()? onRelease;'),
        ('@visibleForTesting this.memoryReader', 'required this.memoryReader, this.onRelease'),
        ('_readMemory(ref, widget.memoryReader)', 'widget.memoryReader()'),
        ('memory == null || !isCurrent()', '!isCurrent()'),
        ('memory == null || !mounted', '!mounted'),
        ('        memoryReader: widget.memoryReader,', '        memoryReader: widget.memoryReader,\n        onRelease: widget.onRelease,'),
        ('await ref.read(coreHandlerProvider).forceGc();', 'await widget.onRelease!();'),
        ('if (_isReleasing) {', 'if (_isReleasing || widget.onRelease == null) {'),
        ("      commonPrint.log(\n        'releaseMemory error: $error',\n        logLevel: coreFailureLogLevel(error),\n      );\n", ''),
        ('dialogs.showBanner(message, level: level);', 'BannerHost.maybeOf(context)?.show(message, level: level);'),
        ('AppLocalizations appLocalizations', 'KitLocalizations appLocalizations'),
        ('context.appLocalizations', 'KitLocalizations.of(context)'),
        ('onPressed: _handleRelease,', 'onPressed: widget.onRelease == null ? null : _handleRelease,'),
        ('body: ListView(', 'body: Builder(builder: (context) => ListView('),
        ('          ),\n        ],\n      ),\n    );\n  }\n}\n\nclass _MemorySection', '          ),\n        ],\n      )),\n    );\n  }\n}\n\nclass _MemorySection'),
    ])
    source = (base / 'lib/pages/scan.dart').read_text(encoding='utf-8')
    camera = source[source.index('class _ScannerError'):source.index('class ScannerOverlay')]
    register('lib/pages/scan.dart', 'scan.dart', [
        (camera, ''),
        ('const _hintMaxLines = 2;\n', ''), ('const _torchIconSize = 32.0;\n', ''),
        ('_ScanLayout', 'ScanLayout'), ('_ScanEffectPainter', 'ScanEffectPainter'),
        ('    final t = animation.value;', '    if (scanWindow.isEmpty) return;\n    final t = animation.value;'),
        ('highlight != oldDelegate.highlight;', 'highlight != oldDelegate.highlight ||\n        contrast != oldDelegate.contrast;'),
    ], excerpt=('const _scanWindowMaxSide', None,
        "import 'dart:math';\n" + prefix + '\n',
        'ScanLayout、ScannerOverlay、ScanEffectPainter；相机、权限、扫码、照片导入由宿主提供'))
