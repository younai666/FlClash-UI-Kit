# 验收记录

更新：2026-11-06。续接基线为 `480033e`；本轮重点是阶段 3.5 视图、阶段 4 完整页面 Showcase 与独立消费验收。下面将当前测试、沿用证据和未完成事项分开记录，不能据文件计数宣称最初的完整提取目标全部达成。

## 最终检查清单

- [x] 固定完整上游与递归子模块；1,604 个直接条目、965 个前端关联条目与当前源码清点相符。清点不等于逐行语义审查或全 UI 提取。
- [x] 阶段 3.5 主壳层、侧栏、工具、主题/字体、快捷键、关于、配置列表/添加进入核心库，并通过宿主 Scope 独立调用。
- [x] 原生系统字体枚举移入可选 platform；原绘制、导航/快照/活跃状态、远距离切页、焦点、录制冲突及延迟字体预览保留。
- [x] 完整应用 Showcase 与 17 个组件分类均能交互；关键调用和宿主责任可检索。
- [x] 仓库外新项目仅复制核心包，安装、分析、交互测试、Web/Windows Release 构建、Windows 原生 Profile 复用测试通过。
- [x] Windows、Android 模拟器（Skia）与当前 Web Release 有实际画面/交互证据。
- [x] Skill 格式、文档路径、项目级目录链接和 Codex CLI 发现通过；按实际接口编写的独立示例可运行。
- [ ] 新 Agent 会话自动调用 Skill 未通过环境验收；其他 Agent 的原生发现机制未验证。
- [ ] Android 默认 Impeller、本机以外设备和 macOS/Linux/iOS 未完成运行与视觉验收。
- [ ] 剩余业务页面、全部组件变体、所有主题/输入组合、动画逐帧对照与持续性能尚未完成。

## 本轮自动测试与源码门禁

|范围|实际结果|可复现入口 / 本地日志|
|---|---|---|
|核心库|分析无问题；247 项测试通过（基线 194 + 本轮 53）|`packages/flutter/test`；`.local/stage4-core-{analyze,tests}.log`|
|Showcase|分析无问题；11 项测试通过，覆盖手机/桌面完整页面、控件目录、数据追加、实际模式选择及主题切换|`showcase/test`；`.local/stage4-{analyze,showcase-tests}.log`|
|可选 platform|分析无问题；7 项测试通过，含 4 项原生字体行为测试|`packages/platform/test`；`.local/stage4-platform-{analyze,tests}.log`|
|独立应用示例|分析无问题；1 项多步骤交互测试通过|`examples/standalone/test/reuse_test.dart`；`.local/standalone-{analyze,test}.log`|
|来源与分发检查|292 主库 + 54 editor + 99 platform + 3 Web 来源记录；106 Dart 包/版本与 84 Rust 许可记录；两份运行时许可资产|`python tools/check_repository.py`；`.local/stage4-repository-check.log`|
|Skill|quick_validate 通过；本地相对文档/资源路径可达|根 `SKILL.md`；来源门禁检查所有文档链接|

不合并测试数与组件数。目录共索引 778 个公开声明、223 个含 Showcase 直接调用，含支持类型；不表示 778 个视觉组件或所有变体均已有独立演示。provenance 的摘录范围、修改与 Commit 以四份 extraction JSON 为准。

上游 prism_ui 355 项、CodeForge 238 项、Rust 13 项、原生 JS 1 项的较早通过证据沿用，未因本轮未修改其实现而重复执行；相关历史日志为 `.local/{prism-tests,vendor-tests,rust-tests}.log` 等。新字体模块的原始 4 项测试本轮已实际运行。未把这些历史结果写成本轮新测。

## 构建、运行与画面

|目标|本轮构建|实际运行及限制|
|---|---|---|
|Windows x64|Showcase Release 通过；Profile 集成测试通过|真实 Windows 引擎执行导航、模式选择、主题、配置选择和原生字体枚举（111 family）；窗口设为 1280×900，内容 1264×861。画面由 RenderRepaintBoundary.toImage 获取，不包含系统窗口边框；未修复/依赖故障的系统截图通道|
|Android|当前 Release APK 62.4 MB 构建通过；Profile 集成测试通过|隔离 Android 11 x86_64 模拟器实际运行，Skia（`--no-enable-impeller`）完成同一导航/主题/配置及字体枚举（9 family）。逻辑内容约 411×683，DPR 2.625。默认 Impeller 在此模拟器出现 GLES pipeline/link 着色器错误，未将 Skia 成功当成默认渲染器验收；没有改写上游 Shader 或全局禁用 Impeller|
|Flutter Web|当前 Release 与 Wasm dry run 通过|Chrome 157 headless 实际加载 1280×900 页面，通过语义树定位后发送鼠标事件，验证工具、追加本地记录后请求列表出现 example-2.test、打开主题页；未捕获到 JS runtime exception。未声称 Wasm 发布包、其他浏览器或全部交互通过|
|macOS / Linux|本轮未在对应系统构建|属于锁定上游应用平台；字体 FFI、材质、托盘、IME、触摸/返回、签名与性能均未验收|
|iOS 附加目标|未构建验证|锁定 FlClash 没有 iOS 应用目录，Showcase 工程为额外 Flutter 模板；可选 editor 没有 iOS Rust target，不宣称完整 Showcase 支持|

原生测试输入由 WidgetTester 指针与宿主控制器驱动；独立示例的文本录入使用 Flutter test text-input channel，不证明 Windows 系统输入法或物理键盘组合均已兼容。Android Release 采用 debug key，仅供本地验收。Windows 分发应保留整个 Release 目录。

实际证据：[Windows 仪表盘](screenshots/stage4-windows-dashboard.png)、[主题](screenshots/stage4-windows-theme.png)、[配置](screenshots/stage4-windows-profiles.png)；[Android 仪表盘](screenshots/stage4-android-dashboard.png)、[主题](screenshots/stage4-android-theme.png)、[配置](screenshots/stage4-android-profiles.png)；[Web 仪表盘](screenshots/stage4-web-dashboard.png)、[主题](screenshots/stage4-web-theme.png)。原始度量见 [runtime-windows.json](runtime-windows.json)、[runtime-android.json](runtime-android.json)、[runtime-web.json](runtime-web.json)。截图证明对应运行帧，不证明与上游全部中间帧逐像素一致。

本轮只采集导航期间的 40 帧小样本：Windows build/raster 平均 1.333/1.487 ms，两种预算超限均 0；Android 模拟器 Skia 为 2.794/15.208 ms，raster 14/40 超过 16.67 ms。未采集 GC、长时内存、压力或实际手机 GPU 基准；Android 性能不能标为完全通过，也没有比较前后数据宣称性能提升。

构建/运行日志：`.local/stage4-{windows,android}-{build,runtime}.log`、`stage4-web-{build,runtime}.log`。从测试模式切回 Release 必须正常运行 `flutter build ... --release` 以重生成排除 dev 插件的注册文件；曾复用 `--no-pub` 测试注册结果导致 Android Java 找不到 IntegrationTestPlugin，正常 Release 流程后通过。Android 的帧采样改用公开 FrameTiming callback，避免测试 SDK 的设备内 VM/DDS 连接问题。

## 全新项目独立复用

`tools/verify_consumer.py` 在仓库外新建临时 Flutter 项目，复制完整 `packages/flutter`（含 vendor、字体、Shader、许可资产），不复制上游树、editor、platform 或代理业务。用 [独立示例](../../examples/standalone/lib/main.dart) 与 [复用测试](../../examples/standalone/test/reuse_test.dart) 验证：任意字符串页面 ID、自有笔记/布局数据、按钮、跨页文本保留、任意操作 ID 的 Ctrl+N 录制、主题切换。

新项目 `pub get`、`analyze`、测试、Web Release 与 Windows Release 均通过；同一项目的 Windows Profile 原生复用测试亦通过。临时路径和逐命令结果保留在 `.local/stage4-consumer-{path.txt,results.json}`，原生日志为 `stage4-consumer-native-runtime.log`。临时项目首次改装测试依赖后残留 Windows C++ wrapper 缓存，清理该一次性项目生成物后构建通过；未修改本机 Flutter SDK或复制缺失系统文件。

复现（Flutter 已配置在 PATH）：

```bash
python tools/verify_consumer.py
# Windows 完整本机复现：
python tools/verify_consumer.py --windows --native-runtime
```

这证明完整核心包的 path 独立使用；未发布远程仓库，未声称远程 Git dependency 或 pub.dev 安装已验收。

## Skill 安装与支持范围

按 README 安装提示词，在临时项目建立 `.agents/skills/flclash-ui-kit` 到整个仓库的目录链接，没有改全局配置。Codex CLI 0.149.1 app-server `skills/list`（forceReload）返回 name=flclash-ui-kit、scope=repo、enabled=true、errors=[]；证据 `.local/skill-discovery.json`。Skill frontmatter 和资源检索入口有效，独立示例实际调用与 Skill 文档一致。

新会话主动调用未取得完整成功证据：较早会话识别了 Skill，但所有只读命令被该会话的本地策略拒绝，实际读取文件数为 0；随后标准 workspace-write 环境试验在模型请求阶段被当前 CLI/账户拒绝（配置的 gpt-6.1-sol 不受该 CLI/账户支持），未更改账户/全局配置或绕过策略。日志为 `.local/skill-{implicit,workspace}-events.log`。因此区分“被发现”“手动按 Skill 检索/使用”“新会话自动调用”，不将前两项替代第三项。

README 的通用提示词保留识别当前 Agent、项目级安装、检索实际构造器与手动降级路径。Codex 的项目发现机制有本机实证；其他 Agent 需逐一检查，不能承诺通用自动安装。机制参考 [Codex Skills](https://learn.chatgpt.com/docs/build-skills)。

## 资源、许可证与剩余范围

原 GPL 与第三方授权头保留，新摘录记录来源路径、固定 Commit、修改与日期。JetBrains Mono 2.304、13 个服务 SVG、Shader 和两份完整运行时 Notice 保持原字节/授权边界；106 个 Dart 包/版本（含新增测试 SDK 与原生 ffi/win32）和 84 个 Rust 依赖记录可查。`Twemoji.Mozilla.ttf` 的 COLRv0 授权描述矛盾、未知头像与品牌图继续隔离，未复制进运行时。见 [license-inventory.md](license-inventory.md)、[font-evidence.json](font-evidence.json)。

尚未独立提取的具体范围包括 `views/config/*`、配置自定义/扩展/预览、资源、分应用代理、备份、连接/MITM 正文与菜单、Clash schema/completion/QuickEdit，以及相机权限、图库和识别服务。它们保留完整来源和依赖，不能用通用表单或回调空壳计作完整页面实现。完整逐文件状态见 [extraction-matrix.md](extraction-matrix.md)，决策与新发现见 [review-findings.md](review-findings.md)。仅英/中文被接入套件；其余本地化和未单独演示的变体仍待迁移/验收。

本次没有发布或推送远程，没有正式签名发布；整体项目仍不能标为最初“全部 FlClash UI/UX、全部平台均完整验收”的终态。
