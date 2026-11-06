# FlClash-UI-Kit 交接

更新：2026-11-06。接续基线 `480033e`，保留 master 的既有提交；本轮只提交本地，不推送。目标仍是完整复用 FlClash/prism_ui 的 UI、动效与交互，脱离代理业务独立运行；当前完成阶段 3.5 的目标视图与阶段 4 的应用集成/消费验证，**不代表剩余业务页面和全部平台已验收**。

## 架构与关键路径

- `packages/flutter/lib/flclash_ui_kit.dart`：统一入口；`vendor/prism_ui` 为完整运行时。核心自有 lib 不得导入 IO/FFI/Isolate、Riverpod 或原 app，门禁已检查。
- `src/shell/{controller,home,sidebar,tools,about}.dart`：宿主控制器、自适应导航、原切页/快照/活跃状态/返回与元数据页。
- `src/theme/{models,view,font_family}.dart`、`src/hotkey/{models,view,keyboard}.dart`、`src/profiles/{models,view,add}.dart`：显式模型与 Scope；全局字体、热键注册、文件/下载/持久化由宿主接入。
- `src/dashboard`、`src/proxies`、`src/records`：已保留完整 Dashboard、节点列表/tab、请求/DNS/日志、feed/table/summary。不要重新把它们列作未提取。
- `packages/platform`：可选窗口/托盘/系统色及 `loadNativeFontFamilies`；FFI 字体枚举保持上游 DirectWrite/CoreText/fontconfig/Android。`packages/editor` 为独立 CodeForge + editor-only Rust，`packages/web` 为原生 JS Canvas。
- `showcase/lib/app_pages.dart`：完整应用组合；主入口为 HomePage/Dashboard；“工具 → 组件目录”进入既有 17 分类。状态/延迟/服务均为明确本地样本，不启动代理或改系统网络。
- `examples/standalone`：无 Clash 业务的笔记/布局示例、任意页面与操作 ID、自有草稿和快捷键录制；只依赖核心包。`tools/verify_consumer.py` 创建仓库外副本进行安装、测试、构建和可选原生运行。
- 来源、修改与摘录边界由 `tools/extract.py` / `extraction_*.py`、`extract_{editor,platform,web}.py` 重现。**修改生成文件应先改 recipe**；原始上游树保持冻结。

## 上游与清点

|仓库/子模块|冻结 Commit|
|---|---|
|FlClash v0.9.3|`be84736605527034689c95bf27828ff27d912c5e`|
|独立及嵌套 prism_ui|`63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`|
|Clash.Meta|`024245dc72bc92f48237f865119afe0cd53ac9e6`|

完整 Git 子模块与版本：[source/upstream-lock.json](source/upstream-lock.json)。1,604 个直接条目、965 个前端关联条目；292 主库、54 editor、99 platform、3 Web 来源记录；778 个公开声明含支持类型，223 个有 Showcase 直接调用。**索引/来源记录数不等于组件数、逐行人工审查或所有变体覆盖率。** [六项审计](docs/audit/source-map.md)、[逐文件矩阵](docs/audit/extraction-matrix.md)、[发现与剩余范围](docs/audit/review-findings.md)。

锁定上游应用含 Android/Windows/macOS/Linux，未含 iOS 目录；Showcase 的 iOS 仅为附加 Flutter 模板，不构成已支持平台。

## 本轮实质完成与决策

- 阶段 3.5 全部目标视图接入 Scope，保留原布局、物理参数、淡入/滑动、远距离切页、焦点、字体分帧预览、录制冲突移动、配置重排/菜单和五次点击开发者入口。
- Home 页面 GlobalKey 改为每个控制器独立持有，避免相同页面 ID 的多个壳层冲突。宿主 builder 捕获 setState 字段时，使用可重建的 `HomePage()`；所有 Scope 放在 Navigator 上方，保证弹层访问。
- 未接入更新不再刷新成功时间；URL 本地条目不伪造下载；异步完成不通知已销毁控制器。PhoneLinkSession 启动/接收错误可见，取消后的迟到会话关闭一次。未提供的业务动作禁用。
- 字体 reader 位于可选原生包，核心保持 Web 可用；Windows 实测 111 family，Android 模拟器 9 family。字体名仅为引用，不授予分发权。
- Showcase 修正手机/桌面模式栏错用、手机 feed 跳转和宿主状态刷新；新增实际应用导航测试和原生验收 harness。
- Showcase 使用 KitApp 原有字体/fallback/暗色 elevated 主题，不另建仅有颜色的 ThemeData；字体实际应用与导航语言切换已有回归。请求/DNS 图标按上游 Navigation 选择。
- **空间审计与安全瘦身**：完成全工作区递归空间审计（工具 `tools/space_audit.py`）。工作区物理总占用从 **17,502.86 MB (17.09 GB, 39,115 文件)** 安全降至 **11,694.38 MB (11.42 GB, 24,883 文件)**，释放 **5,808.48 MB (-5.67 GB)**。安全清理项包括：Showcase 构建产物与 APK (3.72 GB)、Rust 编译 target (322 MB)、Flutter ephemeral 与测试缓存 (500+ MB)、临时字体评测副本 (396 MB)、无用 Chrome 临时缓存 (156 MB) 与 rustup-init 安装包 (12 MB)。Git 跟踪源码资产 (15.99 MB / 1,070 文件)、Git 历史 (100.70 MB)、上游源码快照 (126.61 MB)、必要的本地 Rust 工具链与 AVD 镜像 100% 完好保留。GitHub 干净克隆仅需约 **117 MB**（递归子模块约 **243 MB**）。
- **规则与结构优化**：优化 `.gitignore` 为全局通配规则（递归忽略 `**/ephemeral/`, `**/.gradle/`, `**/*.tmp` 等），防止各工程构建时再次污染工作区。瘦身后重新执行全量门禁、全部测试套件与空白项目独立 Release 构建，零功能退化。

## 已验证证据

详表、命令、画面及限制集中在 [verification.md](docs/audit/verification.md)，避免把历史结果当作新测。

|范围|本轮结果|
|---|---|
|核心库|分析无问题；247 项测试通过（较基线新增 53）|
|Showcase|分析无问题；11 项测试通过，包含 390×844 / 1280×900 完整应用导航和目录交互|
|platform / standalone|分析无问题；7 / 1 项测试通过|
|Windows|Showcase Release、真实 Profile 导航/主题/配置/字体/帧捕获通过；独立新项目 Release 和 Profile 复用测试通过|
|Android|Release APK 62.4 MB；Android 11 x86_64 模拟器 Skia Profile 实测通过，默认 Impeller 仍有环境问题|
|Web|当前 Release / Wasm dry run 通过；Chrome 157 实际导航、追加记录、请求与主题检查通过，无捕获到的 JS runtime exception|
|来源/许可证|`check_repository.py` 复核完整源树、账册、资源、文档和核心移植边界；106 Dart 包/版本与 84 Rust 许可记录、2 份运行时许可资产|
|Skill|格式与项目级目录链接有效；Codex CLI 0.149.1 skills/list 返回 repo/enabled/errors=[]；新会话自动调用未通过环境验收|

原始度量：[Windows](docs/audit/runtime-windows.json)、[Android](docs/audit/runtime-android.json)、[Web](docs/audit/runtime-web.json)；真实截图在 `docs/audit/screenshots/stage4-*`。原生画面通过 Flutter 引擎导出，不含系统窗口边框，不再排查 Computer Use 截图后端。导航小样本各 40 帧；Windows build/raster 平均 1.333/1.487 ms，Android 2.794/15.208 ms 且 raster 14/40 超预算，不能宣称性能全面通过。

`.local/stage4-*`、`standalone-*` 保留本机日志；消费项目路径/结果为 `.local/stage4-consumer-{path.txt,results.json}`，原生额外日志 `stage4-consumer-native-runtime.log`。旧 prism_ui 355、CodeForge 238、Rust 13、JS 1 项为沿用历史证据，本轮未重复执行未改动的实现。

## 未完成与继续方向

1. 按矩阵解耦 `views/config/*`、配置自定义/编辑/扩展/预览、资源、分应用代理、备份、连接/MITM 正文与菜单；Clash schema/completion/QuickEdit、相机/识别/图库/权限仍是参考/宿主边界。不能把这些全部叫作纯后端或用回调空壳计为完成。
2. 补公开变体、其他本地化（目前英/中文）、更多布局/缩放/输入法/无障碍组合、动画中间帧对照、长时性能。Android 默认 Impeller 在此模拟器有 GLES shader link 错误；Skia 成功不能替代默认后端/真机验收。macOS/Linux/iOS 未构建运行；editor 没有 iOS Rust target。
3. Skill 新会话调用曾遇到只读命令策略拒绝，后遇 CLI/账户不支持当前配置模型；未改全局配置或绕过策略。其他 Agent 原生机制、远程 Git 安装和 GitHub 发布未验证；README 保留手动资源路径接入。
4. GPL/第三方原文保留；Twemoji COLRv0 许可描述冲突、未知头像/品牌资源仍隔离。未正式签名或发布，Android 为 debug key。见 [license-inventory.md](docs/audit/license-inventory.md)、[NOTICE.md](NOTICE.md)。

## 构建与复核

本机 Flutter `D:\tools\flutter` 3.47.9 / Dart 3.13.7，Rust 1.99.0，VS Build Tools `D:\mita\vsbt`，Android SDK `D:\Android\Sdk`，JDK 17。环境与依赖不自动装入全局 Skill。

```powershell
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
$env:CARGO_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\cargo'
$env:RUSTUP_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\rustup'
$env:RUSTUP_TOOLCHAIN = '1.99.0-x86_64-pc-windows-msvc'
$env:PATH = 'D:\FlClash-UI-Kit\.local\toolchains\cargo\bin;D:\tools\flutter\bin;' + $env:PATH
python tools/check_repository.py
# 在对应包执行 flutter pub get / flutter analyze / flutter test
python tools/verify_consumer.py --windows --native-runtime
# showcase 下，顺序执行：
flutter drive --profile -d windows --driver test_driver/acceptance.dart --target integration_test/acceptance_test.dart --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false
# Android 模拟器当前需加 --no-enable-impeller；不要推断默认后端已通过
flutter build windows --release
flutter build apk --release
flutter build web --release
```

切回 Release 使用正常 pub 生成流程，避免测试 dev 插件注册残留（勿沿用该状态的 --no-pub）。可选 editor/平台工具链详见 [native.md](docs/usage/native.md)，维护/再提取见 [maintenance.md](docs/usage/maintenance.md)，接入契约见 [presentation.md](docs/components/presentation.md)。不要重复已通过的无关检查；新失败或相关实现变化后再运行对应测试。
