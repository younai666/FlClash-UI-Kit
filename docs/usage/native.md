# 可选原生集成

基础 UI 只需 `packages/flutter`。完整 Showcase 还依赖 editor 和 platform；不要遗漏它们的 vendor、Rust 源码、Cargo.lock 或许可资源。

## CodeForge 编辑器

```yaml
dependencies:
  flclash_ui_editor:
    path: /your/FlClash-UI-Kit/packages/editor
```

该包还引用相邻的 `../flutter`。复制时保留两个包之间的结构。使用原生 Flutter 工具链、Rust **1.99.0** 和可见于构建进程 PATH 的 `cargo` / `rustup`。原 Native Assets 构建器要求完整声明目标列表；首次构建可能下载相应标准库。Windows 需要 MSVC/Windows SDK；Android 需要 SDK、NDK 和兼容的 Java；macOS/Linux 需要各自的 Flutter 构建工具。

```dart
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_editor/flclash_ui_editor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeEditor();
  // 然后创建应用、CodeForgeController、FindController、UndoRedoController。
}
```

实际可运行调用见 [editor_native.dart](../../showcase/lib/editor_native.dart)。组件参数：

```dart
NativeCodeEditor(
  controller: code,
  findController: search,
  undoController: history,
  readOnly: false,
  language: EditorLanguage.yaml,
  fontSize: 14,
  lineWrap: false,
  topInset: 0, // 嵌在已有工具栏下；null 保留原来的浮动 AppBar 留白。
  completionSource: hostCompletionSource,
)
```

宿主释放三个控制器。编辑器内部释放自己创建的 sheet-compatible 滚动控制器，并跟踪 FindController 更换。文件读写、保存提示、网络获取和 Clash schema 不在组件内自动执行。保留原触摸选区、放大镜、右键菜单、折叠、IME、查找替换和滚动条。窄屏替换操作采用分行布局，避免英文按钮挤坏输入框。

`EditorCompletionPopup` 是原始补全 UI，CodeForge 保留本地建议与 snippet API。业务 completion/schema 尚在上游，不能声称本包包含完整 Clash 配置编辑工作流。

当前 Rust 目标声明对应上游的 Android、Windows、macOS、Linux 架构；Web 不支持这个原生包，Showcase 用条件导入展示明确的不可用状态。基础 UI 的 iOS 工程与可选编辑器的 iOS 支持不是同一件事；当前编辑器未声明 iOS Rust 目标，不应直接宣称 iOS 可运行。

## 窗口、托盘、系统颜色

```yaml
dependencies:
  flclash_ui_platform:
    path: /your/FlClash-UI-Kit/packages/platform
```

```dart
await desktopWindow.ensureInitialized();
final caption = WindowCaptionController();
// WindowHeaderBar / WindowHeaderActions 位于基础 UI 包。
// 将 caption.togglePin / toggleMaximized 和 desktopWindow 的方法接到回调。
// 原生最大化与全屏事件更新状态；调用返回不等于窗口管理器已经应用状态。
// 宿主退出时 caption.dispose()。
final accent = await DynamicColorPlugin.getAccentColor();
final seeds = await DynamicColorPlugin.getSystemSeeds();
```

真实接口与示例见 [platform.dart](../../showcase/lib/platform.dart)、`packages/platform/vendor/window/lib`、`vendor/tray/lib`。托盘使用 `TraySpec` / `TrayIcon.asset` / `TrayMenuItem` 和事件流；图标由宿主提供已授权资源。库不会自动修改关闭策略、自动启动或创建托盘。

窗口/托盘原生实现覆盖 Windows/macOS/Linux；动态颜色另含 Android。窗口材质先查询 `desktopWindow.isEffectSupported`，再选择 `WindowEffect`；缺少某平台效果时不能把普通透明窗口当成同一材质。Linux 托盘 CMake 需要 `ayatana-appindicator3-0.1` 或 `appindicator3-0.1`，通常对应 `libayatana-appindicator3-dev`。

## 维护与验证

编辑器修改通过 `tools/extract_editor.py` 重现；插件与窗口控制器通过 `tools/extract_platform.py` 重现。不要改写原始快照或未修改的 vendor 代码来消除样式提示。

生成桥接使用 `flutter_rust_bridge_codegen 2.13.0`，在 `packages/editor/vendor/rust_api` 执行 `flutter_rust_bridge_codegen generate`。配置、API 和 Cargo.lock 已随包提供。编译时 Native Assets 构建 editor-only crate；不加载原 app 的 QuickJS、IPC、热键或代理服务。完整 Rust 依赖许可由 `tools/rust_licenses.py` 根据 `cargo metadata --locked --format-version 1` 与 Cargo.lock 交叉核对。

具体已通过的构建、测试和实际运行，以及未验证的系统见 [verification.md](../audit/verification.md)。单个平台的成功不代表所有平台成功。
