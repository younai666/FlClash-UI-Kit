# FlClash-UI-Kit 交接

更新时间：2026-11-06。本项目基于固定上游 commit 提取并解耦 FlClash 与 prism_ui 的优质 UI/UX 实现，构建完全独立的 Flutter 组件库、交互式 Showcase、原生辅助包及 Agent Skill。

## 核心架构原则

1. **完全解耦与独立运行**：组件库必须脱离 FlClash 独立使用，零依赖 Clash 内核（无 FFI/Go/Rust 核心交互）、无 Riverpod 业务状态、无全局单例（如 `globalState`、`dialogs`、`system`、`app`）、无文件/SQLite 业务存储。`packages/flutter/lib/` 严禁引入 `dart:io`、`dart:ffi`、`dart:isolate`，确保 100% Web 安全。
2. **三层分层驱动架构**：
   - **通用组件 (Generic Primitives)**：基础控件、动效、弹层、标头、排版、图标（继承并补全 prism_ui 与通用 UI 资产）。
   - **可复用页面/视图 (Reusable Views & Shells)**：自适应主壳层、仪表盘、代理列表/标签页、连接/请求/DNS/日志、工具、主题、快捷键、配置列表等。
   - **业务适配层 (Host Adapters & Controllers)**：通过显式数据、展示模型、`ChangeNotifier` 控制器与 `InheritedNotifier` 作用域向 UI 注入状态与事件回调，为宿主提供标准契约。对强耦合业务页面提取 UI 层与适配接口，不强行重写或伪造业务。
3. **真实空白项目验收标准**：最终必须在全新的外部空白 Flutter 项目中完成独立安装、引入、自定义页面驱动调用与 Release 构建验证，并准确记录尚未解耦的纯业务部分。

## 仓库结构与状态

- **上游基线**（保持冻结，禁止污染）：
  - FlClash: `be84736605527034689c95bf27828ff27d912c5e`
  - prism_ui: `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`
  - Clash.Meta (嵌套子模块): `024245dc72bc92f48237f865119afe0cd53ac9e6`
- **包划分**：
  - `packages/flutter`：核心基础 UI 库（入口 `lib/flclash_ui_kit.dart`，含 vendored prism_ui、Web-safe 补丁与解耦组件）。
  - `packages/editor`：独立 CodeForge + Rust 原生编辑器扩展。
  - `packages/platform`：桌面窗口控制、系统托盘、动态取色等可选原生适配。
  - `packages/web`：官网原生 JS Canvas 动效。
  - `showcase/`：交互式体验验证应用。
  - `SKILL.md` / `README.md`：通用 Agent Skill 与开发接入文档。
- **可追溯性账册与工具链**：
  - 提取脚本：`tools/extract.py` 驱动 `tools/extraction_*.py`，严格维护 `docs/audit/extractions.json` 账册。
  - 门禁工具：`python tools/check_repository.py` 校验生成物无漂移、文档相对链接完整性及依赖许可证；`python tools/render_audit.py` 生成审计矩阵；`python tools/catalog.py` 提取公共声明目录（当前已索引 763 个公共声明，1604 个上游条目分类归档）。

## 最新开发进度与已完成工作

当前已完成阶段 1 至阶段 3 全量解耦及阶段 3.5 核心控制器与模型基础设施，全部通过自动化测试：

1. **基础库与通用交互（阶段 1）**：
   - prism_ui 全量运行时（145 个 Dart 文件 + 2 个 Shader），含 Web 端 `SceneBuilder.pushClipRSuperellipse` 显式 `clipBehavior` 兼容补丁。
   - 基础控件、弹窗系统（`showFloatingModalBottomSheet`、`showFloatingDialog`、二维码与失败详情流式展示）、输入约束、Web-safe `Cidr` 与 `ConfigItem` 表单。
   - 列表/映射/批量订阅编辑视图（`ListEditView`、`MapEditView`、`NamedUrlForm`）。
   - IP 质量组件与详情弹窗（`IpQualityText`、`IpQualitySheet`）。
2. **记录与仪表盘体系（阶段 2）**：
   - 连接、请求、DNS、日志完整流式视图与详情（`RequestsView`、`DnsQueriesView`、`LogsView`、`TrackerInfoTable`、`TrackerInfoList`、`TrackerSpeedRanker`）。
   - 完整自适应仪表盘（`DashboardView`）、状态指示按钮（`CoreStatusButton`）、网络拓扑、分流模式、速度图表、内存指示与卡片布局编排。
3. **代理节点与测速体系（阶段 3）**：
   - 完整 `ProxiesView`，支持分组吸顶收折列表（`ProxiesListView`）与多标签页（`ProxiesTabView`）双模式。
   - 节点卡片（`ProxyCard`）、自适应网格、延迟测速状态机（`ProxiesController`、`computeProxyDelayState`、`computeRealSelectedProxyState`）。
   - 键盘/TV/遥控器焦点感知与滚动联动导航。
4. **主壳层、主题、快捷键与配置模型（阶段 3.5 基础架构）**：
   - `HomeShellController` / `HomeShellScope`：自适应侧边栏展开/收折、多端导航布局模式、Tab 切换动画。
   - `ThemeController` / `ThemeScope`：动态种子调色板缓存、纯黑模式、平滑模糊与系统字体扫描排序。
   - `HotKeyController` / `HotKeyScope` / `ShortcutLabels`：跨平台快捷键解析、平台字符映射、USB HID 键位标准化与热键有效性校验。
   - `ProfilesController` / `ProfilesScope`：配置订阅管理、重命名/重排序/分组统计计算、扫码与局域网同步协议适配。
   - 双语国际化扩展（`KitLocalizations`）：新增约 95 个通用展示词条。

## 验证结果矩阵

- **`packages/flutter`**：`flutter analyze` **0 警告 0 错误**；`flutter test` **194/194 项全部通过**。
- **`showcase`**：`flutter analyze` **0 警告 0 错误**；`flutter test` **9/9 项全部通过**。
- **`packages/platform`**：`flutter analyze` **0 警告 0 错误**；`flutter test` **3/3 项全部通过**。
- **`packages/editor`**：Rust 原生单元测试 **13/13 项全部通过**。
- **`packages/web`**：Node.js 动效单元测试 **1/1 项全部通过**。
- **全量门禁检查 (`python tools/check_repository.py`)**：
  - 280 个主提取源文件、54 个编辑器源码记录、97 个平台文件、3 个 Web 源码记录、2 项运行时 License 资产均严格吻合账册，零漂移。

## 剩余任务与接续路线

1. **完成阶段 3.5 视图提取与测试对接（当前接续首要任务）**：
   - 在 `tools/extraction_views_extra.py` 中提取并适配原版页面视图：
     - `HomePage` / `AppSidebarContainer`（主自适应壳层容器）。
     - `ToolsView`、`AboutView`（工具箱与关于页面，含贡献者与外部链接展示）。
     - `ThemeView`、`FontFamilyView`（主题与字体选择交互视图）。
     - `HotKeyView` / `HotKeyRecorder`（快捷键配置与热键录制器）。
     - `ProfilesView` / `AddProfileMenu`（配置列表与订阅添加交互视图）。
   - 提取并适配对应测试集（`home_test`、`theme_test`、`hotkey_view_test`、`add_profile_view_test`、`profile_focus_test`）。
2. **阶段 4 Showcase 全景集成升级**：
   - 升级 `showcase/`，基于 `HomePage` 自适应壳层，集成所有可复用页面（Dashboard、Proxies、Profiles、Requests/DNS/Logs、Tools、Theme、HotKey、About）。
   - 接入实时交互参数面板，动态控制 `KitApp` 的字体缩放、主题种子色、液态玻璃模式与布局模式。
3. **独立空白 Flutter 项目验收（核心架构要求）**：
   - 在仓库外全新创建空白 Flutter 项目，配置 `flclash_ui_kit` 路径依赖。
   - 验证独立安装、零 Clash 业务概念下的控制器调用、运行与 Release 构建。
4. **未解耦边界归档与文档交付**：
   - 明确归档纯业务模块（自定义规则组数据库构造器、Clash YAML/JS schema 补全、MITM 证书注入、Android 分应用代理、系统原生托盘/窗口事件循环等）的隔离边界，更新 `docs/components/presentation.md` 与 `README.md`。

## 已知问题与授权边界

- **环境与平台**：
  - `packages/editor` 保留上游 3 条 `prefer_initializing_formals` 提示，未声明 iOS Rust target；Android Release 采用本地 debug 签名。
  - Flutter Web 编译存在 Material/Cupertino 图标字体提示，不影响运行时。
  - macOS、Linux、iOS 真机与全平台完整性能帧率基准待进一步多端验证；Windows 原生截图故障已知，请勿重复排障。
- **许可证与资产隔离**：
  - 遵循 GPL-3.0 及原作者声明；JetBrains Mono (OFL-1.1) 与服务图标 (CC0/GPL) 已完整归档。
  - Twemoji COLRv0 上游许可描述冲突，且上游默认头像/品牌图片授权未明确，严格隔离，不作为组件库内置资产分发。

## 常用验证命令（Windows PowerShell）

```powershell
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
$env:CARGO_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\cargo'
$env:RUSTUP_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\rustup'
$env:RUSTUP_TOOLCHAIN = '1.99.0-x86_64-pc-windows-msvc'
$env:PATH = 'D:\FlClash-UI-Kit\.local\toolchains\cargo\bin;D:\tools\flutter\bin;' + $env:PATH

# 1. 账册一致性校验
python tools/check_repository.py

# 2. 核心组件库分析与测试
Push-Location packages/flutter; flutter analyze; flutter test; Pop-Location

# 3. Showcase 分析与测试
Push-Location showcase; flutter analyze; flutter test; Pop-Location

# 4. 原生平台与编辑器测试
Push-Location packages/platform; flutter analyze; flutter test; Pop-Location
Push-Location packages/editor/vendor/rust_api/rust; cargo test --locked; Pop-Location
node --test packages/web/test/field.test.js
```
