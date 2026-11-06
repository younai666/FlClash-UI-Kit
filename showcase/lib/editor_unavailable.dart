import 'package:flutter/widgets.dart';

class EditorDemo extends StatelessWidget {
  const EditorDemo({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Padding(
    padding: EdgeInsets.all(24),
    child: Text('CodeForge 使用 Rust Native Assets、dart:io 和原生输入法。请运行 Windows / macOS / Linux / Android / iOS Showcase 测试该组件。当前 Web 构建不支持此原生编辑器。'),
  ));
}
