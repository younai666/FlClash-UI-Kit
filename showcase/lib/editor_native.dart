import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_editor/flclash_ui_editor.dart';

class EditorDemo extends StatefulWidget {
  const EditorDemo({super.key});
  @override
  State<EditorDemo> createState() => _EditorDemoState();
}

class _EditorDemoState extends State<EditorDemo> {
  CodeForgeController? _code;
  FindController? _find;
  UndoRedoController? _undo;
  Object? _error;
  bool _readOnly = false;
  bool _wrap = false;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      await initializeEditor();
      if (!mounted) return;
      setState(() {
        _code = CodeForgeController()..text = '# Real Rust document backend\napplication:\n  name: FlClash UI Kit\n  components:\n    - editor\n    - glass\n    - sheets\n\n# Edit, fold, select, find or replace this document.\n';
        _find = FindController(_code!);
        _undo = UndoRedoController();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _find?.dispose();
    _code?.dispose();
    _undo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorBanner(message: '原生编辑器初始化失败：$error'),
        ),
      );
    }
    final code = _code;
    if (code == null) return const Center(child: ActivityIndicator.page());
    // Scaffold has already consumed keyboard insets before laying out its body.
    // Use the available height, so the example footer yields to the editor.
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardVisible = View.of(context).viewInsets.bottom > 0;
        return Column(
          children: [
            if (keyboardVisible)
              SizedBox(height: context.contentTopPadding)
            else
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  context.contentTopPadding + 8,
                  16,
                  8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => _find!.show(),
                        child: const Text('查找'),
                      ),
                      TextButton(
                        onPressed: () => _find!.show(replace: !_readOnly),
                        child: const Text('查找 / 替换'),
                      ),
                      TextButton(
                        onPressed: () => _undo!.undo(),
                        child: const Text('撤销'),
                      ),
                      TextButton(
                        onPressed: () => _undo!.redo(),
                        child: const Text('重做'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _wrap = !_wrap),
                        child: Text(_wrap ? '关闭折行' : '开启折行'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _readOnly = !_readOnly),
                        child: Text(_readOnly ? '允许编辑' : '切换只读'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              key: const ValueKey('native-editor'),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: NativeCodeEditor(
                  controller: code,
                  findController: _find!,
                  undoController: _undo!,
                  readOnly: _readOnly,
                  lineWrap: _wrap,
                  language: EditorLanguage.yaml,
                  topInset: 0,
                ),
              ),
            ),
            if (constraints.maxHeight > 480 && !keyboardVisible)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '真实调用：packages/editor · initializeEditor() → NativeCodeEditor。Ctrl/Cmd+F 查找，Ctrl/Cmd+Z 撤销。',
                ),
              ),
          ],
        );
      },
    );
  }
}
