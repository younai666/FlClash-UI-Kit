import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

class DemoSpec {
  const DemoSpec(this.id, this.title, this.keywords, this.glyph, this.builder);
  final String id;
  final String title;
  final String keywords;
  final Glyph glyph;
  final WidgetBuilder builder;
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.demo, this.actions = const []});
  final DemoSpec demo;
  final List<IconButtonData> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    title: demo.title,
    iconActions: actions,
    body: Builder(builder: demo.builder),
  );
}

class DemoList extends StatelessWidget {
  const DemoList({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(
      20,
      context.contentTopPadding + 12,
      20,
      32 + context.bottomInset,
    ),
    children: [
      for (final child in children)
        Padding(padding: const EdgeInsets.only(bottom: 24), child: child),
    ],
  );
}

class DemoSection extends StatefulWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.source,
    required this.code,
    required this.child,
  });
  final String title;
  final String source;
  final String code;
  final Widget child;
  @override
  State<DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<DemoSection> {
  var _code = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyle.title3.of(context, emphasized: true),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _code = !_code),
            child: Text(_code ? '收起代码' : '调用代码'),
          ),
        ],
      ),
      Text(widget.source, style: AppTextStyle.caption1.of(context)),
      const SizedBox(height: 12),
      widget.child,
      if (_code)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    widget.code,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(fontFamily: 'monospace'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: widget.code)),
                    child: const Text('复制代码'),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

void notifyDemo(
  BuildContext context,
  String text, {
  BannerLevel level = BannerLevel.info,
}) => BannerHost.maybeOf(context)!.show(text, level: level);
