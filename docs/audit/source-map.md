# 源码结构与调用关系
固定源码的静态调查，日期：2026-11-05。文件枚举、全文特征扫描和 import/export/part 反向关系由 `python tools/audit.py --write` 生成；人工分析聚焦入口、组件、绘制、动效及服务耦合。枚举覆盖不等于逐行人工语义审查或逐组件运行验收。

独立复查与边界见 [review-findings.md](review-findings.md)。完整逐文件证据（包括所有依赖边、反向调用者、行号、平台、生命周期和许可证头）见 [source-index.json](source-index.json)。使用 `python tools/audit.py --check` 检查清单是否仍与锁定源码一致。

## FlClash · `be84736605527034689c95bf27828ff27d912c5e`

1411 个直接跟踪文件/子模块条目。

|目录|分类|文件数|
|---|---|---|
|`lib/ui`|app-ui|10|
|`lib/ui/icons`|app-ui|2|
|`lib/ui/scaffold`|app-ui|3|
|`lib/widgets`|app-widget|13|
|`arb`|asset|7|
|`assets/data`|asset|4|
|`assets/fonts`|asset|2|
|`assets/images`|asset|2|
|`assets/images/avatar`|asset|2|
|`assets/images/services`|asset|14|
|`assets/images/tray/macos`|asset|2|
|`assets/images/tray/macos/2.0x`|asset|2|
|`assets/images/tray/macos/3.0x`|asset|2|
|`assets/images/tray/macos/4.0x`|asset|2|
|`assets/images/tray/unix`|asset|4|
|`assets/images/tray/unix/2.0x`|asset|4|
|`assets/images/tray/unix/3.0x`|asset|4|
|`assets/images/tray/unix/4.0x`|asset|4|
|`assets/images/tray/windows`|asset|4|
|`assets_source/images/icon`|asset-source|5|
|`.`|build-support|19|
|`.codegraph`|build-support|1|
|`.run`|build-support|2|
|`.zed`|build-support|3|
|`services/helper`|build-support|3|
|`services/helper/src`|build-support|1|
|`services/helper/src/service`|build-support|6|
|`snapshots`|build-support|4|
|`tool`|build-support|10|
|`tool/hooks`|build-support|5|
|`tool/src/changelog`|build-support|5|
|`tool/src/icons`|build-support|1|
|`core`|core|59|
|`core/cmd/core`|core|1|
|`core/mobile`|core|1|
|`core/platform`|core|2|
|`core/timezone`|core|2|
|`core/tun`|core|1|
|`lib/core`|core|8|
|`lib/core/desktop`|core|9|
|`lib/database`|data|12|
|`lib/database/generated`|data|1|
|`.`|documentation-config|4|
|`.agents`|documentation-config|10|
|`.agents/skills/core-platform`|documentation-config|1|
|`.agents/skills/localization`|documentation-config|1|
|`.agents/skills/pre-commit-quality-review`|documentation-config|1|
|`.agents/skills/ui-performance`|documentation-config|1|
|`.agents/skills/ui-work`|documentation-config|1|
|`.claude`|documentation-config|1|
|`.claude/skills`|documentation-config|5|
|`.codex`|documentation-config|1|
|`.gemini`|documentation-config|1|
|`.github`|documentation-config|2|
|`.github/ISSUE_TEMPLATE`|documentation-config|3|
|`.github/workflows`|documentation-config|2|
|`plugins/code_forge`|editor|5|
|`plugins/code_forge/lib`|editor|1|
|`plugins/code_forge/lib/code_forge`|editor|13|
|`plugins/code_forge/lib/code_forge/code_area`|editor|10|
|`plugins/code_forge/lib/code_forge/controller`|editor|8|
|`lib`|entrypoint|4|
|`lib/enum`|entrypoint|1|
|`lib/plugins`|entrypoint|4|
|`lib/features`|feature|1|
|`lib/features/connection`|feature|9|
|`lib/features/editor`|feature|9|
|`lib/features/form`|feature|15|
|`lib/features/ip_quality`|feature|4|
|`lib/features/mitm`|feature|2|
|`lib/manager`|lifecycle|13|
|`lib/l10n`|localization|1|
|`lib/l10n/intl`|localization|8|
|`lib/models`|model|12|
|`lib/models/generated`|model|17|
|`plugins`|native-bridge|1|
|`plugins/proxy`|native-bridge|7|
|`plugins/proxy/lib`|native-bridge|3|
|`plugins/proxy/lib/src`|native-bridge|4|
|`plugins/proxy/windows`|native-bridge|5|
|`plugins/proxy/windows/.vscode`|native-bridge|1|
|`plugins/proxy/windows/include/proxy`|native-bridge|1|
|`plugins/rust_api`|native-bridge|9|
|`plugins/rust_api/hook`|native-bridge|1|
|`plugins/rust_api/lib`|native-bridge|1|
|`plugins/rust_api/lib/src/rust`|native-bridge|3|
|`plugins/rust_api/lib/src/rust/api`|native-bridge|4|
|`plugins/rust_api/rust`|native-bridge|4|
|`plugins/rust_api/rust/src`|native-bridge|2|
|`plugins/rust_api/rust/src/api`|native-bridge|6|
|`plugins/rust_api/rust/src/hotkey`|native-bridge|5|
|`plugins/rust_api/rust/src/ipc`|native-bridge|6|
|`plugins/rust_api/rust/src/script`|native-bridge|2|
|`plugins/rust_api/rust/tests/fixtures`|native-bridge|2|
|`plugins/rust_api/test_driver`|native-bridge|1|
|`plugins/setup`|native-bridge|3|
|`plugins/setup/hook`|native-bridge|1|
|`plugins/setup/setup_hooks`|native-bridge|3|
|`plugins/setup/setup_hooks/lib`|native-bridge|1|
|`plugins/setup/setup_hooks/lib/src`|native-bridge|11|
|`plugins/wifi_ssid`|native-bridge|4|
|`plugins/wifi_ssid/android`|native-bridge|1|
|`plugins/wifi_ssid/android/src/main`|native-bridge|1|
|`plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid`|native-bridge|1|
|`plugins/wifi_ssid/lib`|native-bridge|2|
|`plugins/wifi_ssid/linux`|native-bridge|2|
|`plugins/wifi_ssid/linux/include/wifi_ssid`|native-bridge|1|
|`plugins/wifi_ssid/macos/wifi_ssid`|native-bridge|1|
|`plugins/wifi_ssid/macos/wifi_ssid/Sources/wifi_ssid`|native-bridge|1|
|`plugins/wifi_ssid/windows`|native-bridge|4|
|`plugins/wifi_ssid/windows/include/wifi_ssid`|native-bridge|1|
|`plugins/rust_api/lib`|native-editor|1|
|`plugins/rust_api/lib/src/rust/api`|native-editor|1|
|`plugins/rust_api/rust/src/api`|native-editor|1|
|`plugins/rust_api/rust/src/editor`|native-editor|5|
|`plugins/dynamic_color`|native-ui|3|
|`plugins/dynamic_color/android`|native-ui|2|
|`plugins/dynamic_color/android/src/main`|native-ui|1|
|`plugins/dynamic_color/android/src/main/kotlin/io/material/plugins/dynamic_color`|native-ui|1|
|`plugins/dynamic_color/lib`|native-ui|1|
|`plugins/dynamic_color/linux`|native-ui|2|
|`plugins/dynamic_color/linux/include/dynamic_color`|native-ui|1|
|`plugins/dynamic_color/macos`|native-ui|1|
|`plugins/dynamic_color/macos/dynamic_color`|native-ui|1|
|`plugins/dynamic_color/macos/dynamic_color/Sources/dynamic_color`|native-ui|2|
|`plugins/dynamic_color/windows`|native-ui|5|
|`plugins/dynamic_color/windows/include/dynamic_color`|native-ui|1|
|`plugins/tray`|native-ui|5|
|`plugins/tray/lib`|native-ui|1|
|`plugins/tray/lib/src`|native-ui|6|
|`plugins/tray/linux`|native-ui|2|
|`plugins/tray/linux/include/tray`|native-ui|1|
|`plugins/tray/macos/tray`|native-ui|1|
|`plugins/tray/macos/tray/Sources/tray`|native-ui|5|
|`plugins/tray/windows`|native-ui|4|
|`plugins/tray/windows/include/tray`|native-ui|1|
|`plugins/window`|native-ui|5|
|`plugins/window/lib`|native-ui|1|
|`plugins/window/lib/src`|native-ui|5|
|`plugins/window/linux`|native-ui|9|
|`plugins/window/linux/include/window`|native-ui|1|
|`plugins/window/macos/window`|native-ui|1|
|`plugins/window/macos/window/Sources/window`|native-ui|6|
|`plugins/window/windows`|native-ui|10|
|`plugins/window/windows/include/window`|native-ui|2|
|`lib/pages`|page|5|
|`lib/views`|page|15|
|`lib/views/config`|page|17|
|`lib/views/config/general`|page|2|
|`lib/views/connection`|page|1|
|`lib/views/dashboard`|page|6|
|`lib/views/dashboard/widgets`|page|16|
|`lib/views/profiles`|page|4|
|`lib/views/profiles/custom`|page|8|
|`lib/views/profiles/extend`|page|3|
|`lib/views/proxies`|page|7|
|`android`|platform-host|4|
|`android/app`|platform-host|2|
|`android/app/src/debug`|platform-host|1|
|`android/app/src/main`|platform-host|2|
|`android/app/src/main/assets/mitm_ca`|platform-host|7|
|`android/app/src/main/kotlin/com/follow/clash`|platform-host|11|
|`android/app/src/main/kotlin/com/follow/clash/models`|platform-host|2|
|`android/app/src/main/kotlin/com/follow/clash/packages`|platform-host|2|
|`android/app/src/main/kotlin/com/follow/clash/plugins`|platform-host|4|
|`android/app/src/main/res/drawable`|platform-host|5|
|`android/app/src/main/res/mipmap-anydpi-v26`|platform-host|2|
|`android/app/src/main/res/mipmap-hdpi`|platform-host|2|
|`android/app/src/main/res/mipmap-mdpi`|platform-host|2|
|`android/app/src/main/res/mipmap-television-anydpi-v26`|platform-host|1|
|`android/app/src/main/res/mipmap-television-hdpi`|platform-host|1|
|`android/app/src/main/res/mipmap-television-mdpi`|platform-host|1|
|`android/app/src/main/res/mipmap-television-xhdpi`|platform-host|1|
|`android/app/src/main/res/mipmap-television-xxhdpi`|platform-host|1|
|`android/app/src/main/res/mipmap-television-xxxhdpi`|platform-host|1|
|`android/app/src/main/res/mipmap-xhdpi`|platform-host|3|
|`android/app/src/main/res/mipmap-xxhdpi`|platform-host|2|
|`android/app/src/main/res/mipmap-xxxhdpi`|platform-host|2|
|`android/app/src/main/res/values`|platform-host|3|
|`android/app/src/main/res/values-night`|platform-host|1|
|`android/app/src/main/res/values-night-v27`|platform-host|1|
|`android/app/src/main/res/values-v27`|platform-host|1|
|`android/common`|platform-host|2|
|`android/common/src/main`|platform-host|1|
|`android/common/src/main/java/com/follow/clash/common`|platform-host|7|
|`android/common/src/main/res/values`|platform-host|1|
|`android/core`|platform-host|3|
|`android/core/src/main`|platform-host|1|
|`android/core/src/main/java/com/follow/clash/core`|platform-host|1|
|`android/gradle`|platform-host|1|
|`android/gradle/wrapper`|platform-host|1|
|`android/service`|platform-host|2|
|`android/service/src/main`|platform-host|1|
|`android/service/src/main/java/com/follow/clash/service`|platform-host|7|
|`android/service/src/main/java/com/follow/clash/service/models`|platform-host|3|
|`android/service/src/main/java/com/follow/clash/service/modules`|platform-host|3|
|`android/service/src/main/res/drawable`|platform-host|2|
|`android/tests/app`|platform-host|3|
|`android/tests/common`|platform-host|4|
|`android/tests/service`|platform-host|3|
|`linux`|platform-host|2|
|`linux/flutter`|platform-host|4|
|`linux/packaging/appimage`|platform-host|1|
|`linux/packaging/deb`|platform-host|1|
|`linux/packaging/rpm`|platform-host|1|
|`linux/runner`|platform-host|4|
|`macos`|platform-host|1|
|`macos/Flutter`|platform-host|3|
|`macos/Runner`|platform-host|5|
|`macos/Runner.xcodeproj`|platform-host|1|
|`macos/Runner.xcodeproj/project.xcworkspace/xcshareddata`|platform-host|1|
|`macos/Runner.xcodeproj/xcshareddata/xcschemes`|platform-host|1|
|`macos/Runner.xcworkspace`|platform-host|1|
|`macos/Runner.xcworkspace/xcshareddata`|platform-host|1|
|`macos/Runner/Assets.xcassets`|platform-host|1|
|`macos/Runner/Assets.xcassets/AppIcon.appiconset`|platform-host|8|
|`macos/Runner/Base.lproj`|platform-host|1|
|`macos/Runner/Configs`|platform-host|4|
|`macos/RunnerTests`|platform-host|1|
|`macos/packaging/dmg`|platform-host|1|
|`windows`|platform-host|3|
|`windows/flutter`|platform-host|4|
|`windows/packaging/exe`|platform-host|3|
|`windows/runner`|platform-host|11|
|`windows/runner/resources`|platform-host|1|
|`lib/providers`|state|14|
|`lib/providers/actions`|state|17|
|`lib/providers/generated`|state|12|
|`lib/providers/state`|state|7|
|`plugins/proxy/test`|test|1|
|`plugins/proxy/windows/test`|test|1|
|`plugins/setup/setup_hooks/test`|test|7|
|`plugins/tray/test`|test|5|
|`plugins/wifi_ssid/test`|test|2|
|`plugins/window/test`|test|2|
|`test`|test|6|
|`test/common`|test|74|
|`test/core`|test|9|
|`test/core/desktop`|test|10|
|`test/database`|test|5|
|`test/enum`|test|1|
|`test/features`|test|14|
|`test/fixtures`|test|1|
|`test/helpers`|test|9|
|`test/icons`|test|3|
|`test/l10n`|test|2|
|`test/lint`|test|20|
|`test/manager`|test|13|
|`test/models`|test|15|
|`test/pages`|test|5|
|`test/plugins`|test|3|
|`test/plugins/code_forge`|test|16|
|`test/providers`|test|27|
|`test/tool`|test|5|
|`test/ui`|test|1|
|`test/views`|test|33|
|`test/views/dashboard`|test|16|
|`test/widgets`|test|97|
|`lib/common`|utility|73|
|`site`|website|1|
|`site/assets`|website|4|

## prism_ui · `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`

193 个直接跟踪文件/子模块条目。

|目录|分类|文件数|
|---|---|---|
|`shaders`|asset|2|
|`.`|build-support|7|
|`lib`|design-system|109|
|`lib/generated`|design-system|1|
|`lib/hct`|design-system|8|
|`lib/icons`|design-system|7|
|`lib/shapes`|design-system|12|
|`lib/sliver_list`|design-system|8|
|`.`|documentation-config|2|
|`test`|test|1|
|`test/common`|test|2|
|`test/helpers`|test|4|
|`test/widgets`|test|30|

## 运行与模块边界

FlClash：`main → RustLib.init / bootstrap → ProviderContainer → Application → HomePage → Navigation → views/features → ui/widgets → prism_ui`。主题经过 `ThemeManager/providers/state/theme` 生成 `PrismApp` 的 ThemeData；桌面窗口、托盘、Android 输入/返回与服务均由 manager、plugin 和原生 host 协作。

prism_ui：`PrismApp → Theme / MeasureScope / ThemeCrossFade / LiquidGlassScope + Host / BannerHost / RemoteFocusAdapter`；页面使用 `ViewScope → PrismScaffold → AppBar/BarItemPresence`；`BaseNavigator → CardPageRoute → DeferredPush/DragBack/RouteMotionHold`；sheet 选择 Snap/Side/Form/Paged 并共享 SheetProvider 与 SheetScrollScope。

绘制链：`PressSurface → CardSurface / PressSparkles → ink_sparkle.frag`；`LiquidGlass → liquid_glass_capture → liquid_glass.frag`；`NullStatus → EmptyIllustration → shapes/Morph`；`PrismListView → SuperSliverList → extent manager/Fenwick tree`。不能只复制外层 widget。

其他：`code_forge → rust_api/editor → Rust rope/folding`；Windows DWM、macOS NSVisualEffectView、Linux GTK 的窗口材质位于 `plugins/window`；托盘菜单的 macOS title view 是系统级 UI。完整源文件均保留。

## 全文件交叉核对

主树共 1604 项，其中前端/关联候选 965 项；其他 639 项也在 source-index.json 中明确归类（测试、构建、数据、后端等）。二进制仅做文件、用途和授权调查，未宣称视觉核验。相同 commit 的嵌套 prism_ui 复用该清单。Clash.Meta 的独立递归清单见 upstream-lock.json。

每个文件都有分类；从每个 Dart 文件提取 imports/exports/parts，并建立反向边。生成文件属于原包，不人工改写。README、隐藏 .agents、CI、原生 host 和本地插件也纳入枚举。
