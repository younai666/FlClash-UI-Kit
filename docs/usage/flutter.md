# Flutter 使用

依赖完整的 `packages/flutter`，不要丢掉其中的 `vendor/prism_ui`。本地 path 安装见根 README。源码发布到 Git 仓库后，也可用 Git dependency 的 `path: packages/flutter`，固定具体 Commit；发布前先运行本文末尾的独立消费测试。

```yaml
dependencies:
  flclash_ui_kit:
    git:
      url: YOUR_REPOSITORY_URL
      ref: YOUR_VERIFIED_COMMIT
      path: packages/flutter
```

运行时没有对 `source/upstream` 的路径依赖；该目录供审计、原始测试与移植调查使用。

## 宿主

使用 `KitApp(home: Scaffold(...))`。默认蓝色种子生成亮暗两套 vivid 主题，应用级玻璃默认关闭，跟随系统明暗；与锁定 FlClash 默认值一致。可设置 `colorStyle` 为 vivid/tinted/soft/monochrome，设置 `themeMode`、`seedColor`、`theme/darkTheme`、`locale`、`liquidGlass` 和 `remoteFocus`。`liquidGlass: null` 关闭应用级玻璃。减少动态效果由系统 MediaQuery 控制；Showcase 的开关只为演示注入相同设置，不宣称所有原始组件都完全停止动画。

中英文 `UiLocalizations` 已提供。自建 PrismApp 宿主时，注册 `KitLocalizations.delegate`、`KitLocalizations.stringsDelegate` 与 `GlobalWidgetsLocalizations.delegate`，并调用 `registerKitLicenses()`，在 builder 中建立 ViewScope，并保持 MeasureScope、单个 LiquidGlassHost、BannerHost 等 PrismApp 原有层级。扩展语言应同时实现组件与应用提取部分的字符串，不能只翻译 Showcase。

```dart
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart' as kit;

// 使用别名前缀可避免与 Material 的 Scaffold、Switch、ThemeData 等冲突。
final button = kit.FilledButton(
  onPressed: () {},
  child: const Text('Continue'),
);
```

## 选取示例

### 字体保真

KitApp 按 FlClash `lib/manager/theme_manager.dart` 的方式调用 `appFontFamilyFallback`。例如 Windows 简体中文使用 Segoe UI 主字体和 Microsoft YaHei UI 中文回退；亮暗主题使用同一字体策略。可通过 `fontFamily`、`fontFamilyFallback` 指定已安装或由宿主依法注册的字体。显式传入 `theme/darkTheme` 时以宿主主题为准。

Flutter Web 的 CanvasKit 字体来自注册资产和引擎回退，不能靠填写 Windows 字体名称获得本机系统字体文件。当前 FontManifest 已注册 JetBrains Mono 等宽字库；未捆绑中文字体，所以其 Web 预览不作为 Windows 字体逐像素验收依据。需要 Web 字体外观稳定时，在宿主 pubspec 中注册有明确授权、含所需字重的字体，再通过 KitApp 的字体参数使用。不能把 Windows 自带字库复制进开源仓库，也不能把统一加粗当成字体复现。

- 基础控件、输入、ListItem 变体、Palette、HexColorField、二维码：`showcase/lib/controls.dart`。
- 长列表、按 key 增删、拖动、折叠组、记录表格：`showcase/lib/collections.dart`。
- Dock、Sidebar、TabBarView：`showcase/lib/demos.dart`。
- 弹窗、菜单、吸附面板、OpenContainer、玻璃、Goo、反馈：`showcase/lib/effects.dart`。
- 自绘图标、形状与文字：`showcase/lib/glyph_catalog.dart`。
- Dashboard 密度、卡片与编辑回调：`showcase/lib/dashboard.dart`。

这些文件参与编译，展示真实调用；支持类通过对应场景和上游测试覆盖，未逐项提供独立展示的 API 见组件目录状态。

## 常见集成

`Palette` 接收宿主创建并释放的 `ValueNotifier<Color>`；`QrCodeView` 保持白底和安静区，超容量时显示文字。`ListItem.open` 在手机使用 OpenContainer、桌面使用扩展页面/面板。

`showSnapSheet(context, builder: (context, scroll) => Scaffold(body: ListView(controller: scroll, ...)))` 让列表与拖动手势共享控制器。不要再嵌套一个玻璃主机。FloatingNavigationBar 与 LineChart 必须获得有限高度。Dashboard 编辑需要稳定的 GlobalKey 和唯一 id；回调只报告展示顺序，持久化交给宿主。

## 验证

```bash
cd packages/flutter
flutter pub get
flutter analyze --no-fatal-infos
flutter test
cd ../../showcase
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build windows --release
flutter build web --release
```

平台工程存在不代表该平台已经验收；当前证据见 [verification.md](../audit/verification.md)。

应用层数据/回调、配置卡与详情见 [presentation.md](../components/presentation.md)。原生 CodeForge 与窗口/托盘见 [native.md](native.md)，它们属于可选包；使用整个 Showcase 需要这些原生工具链。
