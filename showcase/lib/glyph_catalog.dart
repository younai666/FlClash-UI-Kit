import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';
import 'package:flclash_ui_kit/shapes.dart' as shapes;

import 'effects.dart';
import 'section.dart';

final allGlyphs = <String, Glyph>{
  'dashboard': AppGlyphs.dashboard,
  'proxies': AppGlyphs.proxies,
  'profiles': AppGlyphs.profiles,
  'requests': AppGlyphs.requests,
  'clock': AppGlyphs.clock,
  'connections': AppGlyphs.connections,
  'dns': AppGlyphs.dns,
  'resources': AppGlyphs.resources,
  'logs': AppGlyphs.logs,
  'tools': AppGlyphs.tools,
  'target': AppGlyphs.target,
  'arrowBack': AppGlyphs.arrowBack,
  'chevronBack': AppGlyphs.chevronBack,
  'chevronForward': AppGlyphs.chevronForward,
  'chevronDown': AppGlyphs.chevronDown,
  'chevronUp': AppGlyphs.chevronUp,
  'picker': AppGlyphs.picker,
  'caretDown': AppGlyphs.caretDown,
  'arrowUp': AppGlyphs.arrowUp,
  'arrowDown': AppGlyphs.arrowDown,
  'openExternal': AppGlyphs.openExternal,
  'undo': AppGlyphs.undo,
  'redo': AppGlyphs.redo,
  'sync': AppGlyphs.sync,
  'refresh': AppGlyphs.refresh,
  'reset': AppGlyphs.reset,
  'export': AppGlyphs.export,
  'upload': AppGlyphs.upload,
  'add': AppGlyphs.add,
  'remove': AppGlyphs.remove,
  'addCircle': AppGlyphs.addCircle,
  'removeCircle': AppGlyphs.removeCircle,
  'close': AppGlyphs.close,
  'clearField': AppGlyphs.clearField,
  'check': AppGlyphs.check,
  'checkDouble': AppGlyphs.checkDouble,
  'checkCircle': AppGlyphs.checkCircle,
  'block': AppGlyphs.block,
  'info': AppGlyphs.info,
  'warning': AppGlyphs.warning,
  'error': AppGlyphs.error,
  'more': AppGlyphs.more,
  'moreCircle': AppGlyphs.moreCircle,
  'dragHandle': AppGlyphs.dragHandle,
  'sort': AppGlyphs.sort,
  'filter': AppGlyphs.filter,
  'textShort': AppGlyphs.textShort,
  'wrap': AppGlyphs.wrap,
  'listAdd': AppGlyphs.listAdd,
  'edit': AppGlyphs.edit,
  'compose': AppGlyphs.compose,
  'delete': AppGlyphs.delete,
  'clearAll': AppGlyphs.clearAll,
  'copy': AppGlyphs.copy,
  'cut': AppGlyphs.cut,
  'paste': AppGlyphs.paste,
  'selectAll': AppGlyphs.selectAll,
  'deselect': AppGlyphs.deselect,
  'search': AppGlyphs.search,
  'matchCase': AppGlyphs.matchCase,
  'regex': AppGlyphs.regex,
  'importFile': AppGlyphs.importFile,
  'cloudDownload': AppGlyphs.cloudDownload,
  'cloudSync': AppGlyphs.cloudSync,
  'link': AppGlyphs.link,
  'send': AppGlyphs.send,
  'rules': AppGlyphs.rules,
  'rulePresets': AppGlyphs.rulePresets,
  'code': AppGlyphs.code,
  'settings': AppGlyphs.settings,
  'sliders': AppGlyphs.sliders,
  'wrench': AppGlyphs.wrench,
  'toggle': AppGlyphs.toggle,
  'toggleOn': AppGlyphs.toggleOn,
  'pin': AppGlyphs.pin,
  'eye': AppGlyphs.eye,
  'eyeOff': AppGlyphs.eyeOff,
  'lock': AppGlyphs.lock,
  'lockOpen': AppGlyphs.lockOpen,
  'key': AppGlyphs.key,
  'password': AppGlyphs.password,
  'account': AppGlyphs.account,
  'sparkle': AppGlyphs.sparkle,
  'bolt': AppGlyphs.bolt,
  'locate': AppGlyphs.locate,
  'star': AppGlyphs.star,
  'puzzle': AppGlyphs.puzzle,
  'customize': AppGlyphs.customize,
  'layers': AppGlyphs.layers,
  'sun': AppGlyphs.sun,
  'pureBlack': AppGlyphs.pureBlack,
  'palette': AppGlyphs.palette,
  'paintbrush': AppGlyphs.paintbrush,
  'eyedropper': AppGlyphs.eyedropper,
  'motion': AppGlyphs.motion,
  'blur': AppGlyphs.blur,
  'liquidGlass': AppGlyphs.liquidGlass,
  'font': AppGlyphs.font,
  'textSize': AppGlyphs.textSize,
  'language': AppGlyphs.language,
  'keyboard': AppGlyphs.keyboard,
  'photos': AppGlyphs.photos,
  'camera': AppGlyphs.camera,
  'qrCode': AppGlyphs.qrCode,
  'torch': AppGlyphs.torch,
  'torchOff': AppGlyphs.torchOff,
  'torchAuto': AppGlyphs.torchAuto,
  'vpn': AppGlyphs.vpn,
  'status': AppGlyphs.status,
  'verified': AppGlyphs.verified,
  'swap': AppGlyphs.swap,
  'shuffle': AppGlyphs.shuffle,
  'split': AppGlyphs.split,
  'speed': AppGlyphs.speed,
  'dataUsage': AppGlyphs.dataUsage,
  'memory': AppGlyphs.memory,
  'cpu': AppGlyphs.cpu,
  'devices': AppGlyphs.devices,
  'broom': AppGlyphs.broom,
  'wifi': AppGlyphs.wifi,
  'wifiOff': AppGlyphs.wifiOff,
  'gavel': AppGlyphs.gavel,
  'appsList': AppGlyphs.appsList,
  'iconTile': AppGlyphs.iconTile,
};

class GraphicsDemo extends StatefulWidget {
  const GraphicsDemo({super.key});
  @override
  State<GraphicsDemo> createState() => _GraphicsDemoState();
}

class _GraphicsDemoState extends State<GraphicsDemo> {
  String _query = '';
  double _fill = 0;
  double _morph = 0.4;
  @override
  Widget build(BuildContext context) => DemoList(
    children: [
      DemoSection(
        title: 'AppGlyphs / GlyphIcon / AnimatedGlyph',
        source: 'FlClash/lib/ui/icons/app_glyphs.dart; prism_ui/lib/icons/',
        code: 'GlyphIcon(AppGlyphs.dashboard, fill: fill);\nAnimatedGlyph(glyph: AppGlyphs.star, filled: selected)',
        child: Column(
          children: [
            SearchField(
              hintText: '按图标名称检索',
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
            Slider(value: _fill, onChanged: (v) => setState(() => _fill = v)),
            AnimatedGlyph(glyph: AppGlyphs.star, filled: _fill > 0.5),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in allGlyphs.entries.where(
                  (e) => e.key.toLowerCase().contains(_query),
                ))
                  SizedBox(
                    width: 94,
                    child: Card(
                      onPressed: () => notifyDemo(context, entry.key),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            GlyphIcon(entry.value, fill: _fill, size: 30),
                            const SizedBox(height: 8),
                            Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.caption2.of(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      DemoSection(
        title: 'RoundedPolygon / Morph / ShapeBadge',
        source: 'prism_ui/lib/shapes/; src/dashboard/card.dart',
        code: 'Morph(MaterialShapes.circle, MaterialShapes.cookie6Sided).toPath(progress: value);\nShapeBadge(shape: shape, color: color, size: 80)',
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final shape in [
                  shapes.MaterialShapes.circle,
                  shapes.MaterialShapes.cookie6Sided,
                  shapes.MaterialShapes.cookie9Sided,
                  shapes.MaterialShapes.cookie12Sided,
                  shapes.MaterialShapes.clover4Leaf,
                ])
                  ShapeBadge(
                    shape: shape,
                    color: context.colorScheme.primary,
                    size: 64,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            MorphPreview(progress: _morph),
            Slider(value: _morph, onChanged: (v) => setState(() => _morph = v)),
          ],
        ),
      ),
      DemoSection(
        title: 'Typography / SurfaceLevel / AppShape',
        source: 'prism_ui/lib/typography.dart · surface.dart · shape.dart',
        code: 'Text(label, style: AppTextStyle.title1.of(context));\nSurface(color: SurfaceLevel.card.colorOf(context.colorScheme), shape: AppShape.xl, child: content)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final role in AppTextStyle.values)
              Text('${role.name} · Aa 字体', style: role.of(context)),
          ],
        ),
      ),
    ],
  );
}
