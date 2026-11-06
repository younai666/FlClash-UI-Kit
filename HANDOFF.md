# FlClash-UI-Kit 交接

更新：2026-11-06。接续基线 `480033e`，保留 master 既有提交；**本轮已完成 v0.1.0 开源预览版准备工作，提交本地 Git，严格禁止推送远程或创建 Release**。目标仍是完整复用 FlClash/prism_ui 的 UI、动效与交互，脱离代理业务独立运行。

## 架构与关键路径

- `packages/flutter/lib/flclash_ui_kit.dart`：统一入口；`vendor/prism_ui` 为完整运行时。核心自有 lib 不得导入 IO/FFI/Isolate、Riverpod 或原 app，门禁已检查（100% Web-safe）。
- `src/shell/{controller,home,sidebar,tools,about,disclaimer}.dart`：宿主控制器、自适应导航、原切页/快照/活跃状态/返回、元数据页及免责声明（含签署确认流与复述校验）。
- `src/theme/{models,view,font_family}.dart`、`src/hotkey/{models,view,keyboard}.dart`、`src/profiles/{models,view,add}.dart`：显式模型与 Scope；全局字体、热键注册、文件/下载/持久化由宿主接入。
- `src/dashboard`、`src/proxies`、`src/records`：已保留完整 Dashboard、节点列表/tab、请求/DNS/日志、feed/table/summary。不要重新把它们列作未提取。
- `packages/platform`：可选窗口/托盘/系统色及 `loadNativeFontFamilies`；FFI 字体枚举保持上游 DirectWrite/CoreText/fontconfig/Android。`packages/editor` 为独立 CodeForge + editor-only Rust，`packages/web` 为原生 JS Canvas。
- `showcase/lib/app_pages.dart`：完整应用组合；主入口为 HomePage/Dashboard；“工具 → 组件目录”进入既有 17 分类。状态/延迟/服务均为明确本地样本，不启动代理或改系统网络。
- `examples/standalone`：无 Clash 业务的独立消费示例；只依赖核心包。`tools/verify_consumer.py` 创建仓库外副本进行安装、测试、构建和可选原生运行。
- 来源、修改与摘录边界由 `tools/extract.py` / `extraction_*.py`、`extract_{editor,platform,web}.py` 重现。**修改生成文件应先改 recipe**；原始上游树保持冻结。

## 上游与清点

|仓库/子模块|冻结 Commit|
|---|---|
|FlClash v0.9.3|`be84736605527034689c95bf27828ff27d912c5e`|
|独立及嵌套 prism_ui|`63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`|
|Clash.Meta|`024245dc72bc92f48237f865119afe0cd53ac9e6`|

完整 Git 子模块与版本：[source/upstream-lock.json](source/upstream-lock.json)。1,604 个直接条目、965 个前端关联条目；293 主库、54 editor、99 platform、3 Web 来源记录；778 个公开声明含支持类型，223 个有 Showcase 直接调用。[六项审计](docs/audit/source-map.md)、[逐文件矩阵](docs/audit/extraction-matrix.md)、[发现与剩余范围](docs/audit/review-findings.md)。

## v0.1.0 预览版准备与安全审查实质完成

1. **安全与敏感信息审查**：
   - 编写 `audit_secrets.py` 对 Git 跟踪的全部 1,073 个文件执行全量敏感信息正则审查（API Keys, GitHub Tokens, Google API Keys, AWS Keys, 私钥, 硬编码口令及绝对隐私路径）。
   - 结果：**0 个敏感密钥，0 处隐私信息泄露**，仅包含交接文档中规范的复核指导命令与路径。
   - 版本统一：`packages/flutter` (0.1.0), `packages/platform` (0.1.0), `packages/editor` (0.1.0), `showcase` (0.1.0+1), `packages/web` (0.1.0), Rust `rust_api` (0.1.0)。
2. **发布整理与双语文档**：
   - 编写全新中文 [`README.md`](README.md) 与英文 [`README_EN.md`](README_EN.md)，包含完整版本徽标、通用 Agent Skill 安装提示词、6 大核心组件使用示例（`KitApp`、`HomePage`、`Dashboard`、`ThemeView`、`DisclaimerView`、`FormSheet/Records`）、扩展模块矩阵、已知限制与解耦边界。
   - 更新 `tools/check_repository.py` 将 `README_EN.md` 纳入链接与目录校验，全库 23 个文档路由相对链接 100% 校验通过。
3. **开源合规核查**：
   - 衍生代码基于 **GPL-3.0**，保留作者 **chen08209** 及贡献者版权声明与 upstream 冻结 commit 映射。
   - JetBrains Mono 遵循 OFL-1.1 授权；Simple Icons 遵循 CC0 1.0；第三方 Dart/Rust 依赖许可证完整保留于 [`NOTICE.md`](NOTICE.md) 与 [`licenses/`](licenses)。
   - 未获分发授权的 Emoji 字库、头像及商标完全隔离在运行时库之外。
4. **仓库瘦身与忽略规则加固**：
   - 强化 [`.gitignore`](.gitignore)，新增操作系统元数据（`.DS_Store`、`Thumbs.db`）、敏感私钥/凭据（`*.key`、`*.keystore`、`*.jks`、`*.p12`、`*.pem`、`*.env`）及本地构建临时产物规则。
   - 清理所有 Flutter/Cargo 构建缓存后：工作区本地占用 11.42 GB（含本地 Rust/AVD 工具链 11.2 GB），Git 跟踪源码资产仅 **16.04 MB (1,073 文件)**，干净克隆体积约 **117 MB**（含 Git 历史）。
5. **回归与门禁验证**：
   - `python tools/check_repository.py`：1,604 个源码条目、449 份提取记录、23 篇文档路径及 190 项依赖许可校验通过，0 错误。
   - `packages/flutter`：`flutter analyze` 0 issues，`flutter test` 全部 250 项单元与组件测试 100% 通过。

## 已验证证据汇总

|范围|测试结果|
|---|---|
|静态门禁|`python tools/check_repository.py` 全数通过（0 坏链，0 偏离）|
|核心库|`flutter analyze` 0 警告；`flutter test` 250/250 全部通过|
|Showcase|11 项集成测试通过，包含 390×844 及 1280×900 完整应用导航与 17 类组件目录|
|platform / standalone|分析无问题；7 / 1 项测试通过|
|Windows|Showcase Release、真实 Profile 导航/主题/配置/字体/帧捕获通过；独立新项目 Release 通过|
|Android|Release APK 62.4 MB；Android 11 x86_64 模拟器 Skia Profile 实测通过（默认 Impeller 渲染受限于模拟器驱动 GLES）|
|Web|Release / Wasm dry run 通过；Chrome 157 实际导航、追加记录、请求与主题检查通过，0 JS 运行时异常|
|安全审查|1,073 个 Git 跟踪文件密钥/敏感信息扫描 0 泄露|

## 未完成与继续方向

1. 按矩阵解耦 `views/config/*`、配置自定义/编辑/扩展/预览、资源、分应用代理、备份、连接/MITM 正文与菜单；Clash schema/completion/QuickEdit、相机/识别/图库/权限仍是参考/宿主边界。
2. 补公开变体、其他本地化（目前英/中文）、更多布局/缩放/输入法/无障碍组合。Android 默认 Impeller 在特定模拟器上的 GLES 报错需在真机或更新的驱动环境复核。macOS/Linux/iOS 未在当前 Windows 宿主构建运行；editor 暂无 iOS Rust target。
3. 独立 Agent 新会话验收由用户另行执行。项目级 Skill 目录链接与 Codex CLI 识别已通过，远程 Git 安装和 GitHub 官方 Release 尚未发布（等待用户确认）。
4. 约束确认：**未推送远程、未创建 Release 或 Tag**。

## 构建与复核命令

```powershell
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
$env:CARGO_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\cargo'
$env:RUSTUP_HOME = 'D:\FlClash-UI-Kit\.local\toolchains\rustup'
$env:RUSTUP_TOOLCHAIN = '1.99.0-x86_64-pc-windows-msvc'
$env:PATH = 'D:\FlClash-UI-Kit\.local\toolchains\cargo\bin;D:\tools\flutter\bin;' + $env:PATH

# 1. 验证仓库完整性与相对链接
python tools/check_repository.py

# 2. 核心包分析与测试
cd packages/flutter
flutter analyze
flutter test
cd ../..

# 3. 消费端与 Showcase 验证
python tools/verify_consumer.py --windows --native-runtime
flutter build windows --release --target showcase/lib/main.dart
```
