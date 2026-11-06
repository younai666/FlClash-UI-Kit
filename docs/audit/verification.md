# 验证与实际交付边界

日期：2026-11-05–06（Asia/Tokyo）。Windows 10 22H2、Flutter 3.47.9 / Dart 3.13.7、Visual Studio Build Tools 2022、Rust 1.99.0、FRB 2.13.0；Android 构建使用 Java 17 和本机 SDK/NDK。源码检查、测试、编译和实际交互分别记录，不能互相替代。

## 源码与提取覆盖

|检查|实际结果|
|---|---|
|固定上游|FlClash `be84736605527034689c95bf27828ff27d912c5e`；prism_ui `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`。完整 Git 历史、递归子模块与 Clash.Meta 文件清单见 [版本锁](../../source/upstream-lock.json)，原始快照未修改|
|完整文件清点|1,604 个主树跟踪项重新枚举，965 项归入前端及其关联类别；包括官网 JS/CSS、原生桥、插件、隐藏辅助目录、资源、测试和示例。全文特征、声明、import/part 和反向调用边保存在 [source-index.json](source-index.json)|
|提取交叉核对|基础库 232、editor 54、platform 97、web 3 条来源记录，共 386 条。四个提取器的 `--check` 比较实际内容、Commit 和完整账册；这是来源记录数，不是组件数量或完整业务文件数|
|设计系统|prism_ui 全部 145 个 Dart 运行时文件与 2 个 shader 保留；Web 的 `pushClipRSuperellipse` 补丁显式传入 `Clip.antiAlias`，其余交付差异由提取器核对|
|组件目录|610 项公开声明被索引，其中 188 项有直接 Showcase 调用；包含支持类型、枚举、控制器和函数，不能作为 610 个可视组件统计。其他调用与缺口见 [catalog.md](../components/catalog.md)|
|文档与资源|交付检查通过：21 条文档入口、四套来源账册、运行时资源、字体字节证据和完整许可证引用均可解析|
|调查边界|清点覆盖全部跟踪文件；尚未完成所有文件的逐行人工语义审查、全部业务页面解耦及逐变体视觉验收。未提取文件仍有明确参考/部分状态，见 [extraction-matrix.md](extraction-matrix.md) 与 [review-findings.md](review-findings.md)|

## 静态分析与测试

|范围|结果与证据|
|---|---|
|基础 UI 包|`flutter analyze --no-pub` 无问题；完整 75 项测试通过，覆盖宿主/本地化、生命周期、二维码、调色器、表单草稿、记录筛选、Dashboard、服务/网络、图标缓存、扫描绘制和配置详情|
|prism_ui|原始快照 355 项通过；同一套 355 项在交付包依赖上下文再次通过。设计系统未再改动，复用该有效证据|
|CodeForge|保留的上游 238 项行为测试通过；真实 NativeCodeEditor 公开入口 1 项通过，验证窄屏英文、topInset、编辑、撤销、查找和替换|
|Rust 文档后端|`cargo test --locked`：13 项通过；UTF-8、CRLF、越界编辑、复制、折叠和词边界均使用真实后端|
|platform|3 项测试通过，包括延迟初始化查询与最大化/全屏事件交错；静态分析无问题|
|editor 静态分析|无错误/警告，未改动的 CodeForge `code_area.dart:281–283` 保留 3 条 `prefer_initializing_formals` info；未以重写 vendor 消除风格提示|
|Showcase|静态分析无问题；完整 9 项测试通过，包括 390×844 / 1280×900 分类渲染和滚动、实际按钮反馈、表单保存/放弃/取消，以及键盘开合时保留编辑器 State、查找焦点和可用编辑区|
|原生 JS 动效|Node 生命周期测试 1 项通过：挂载、暂停、恢复、卸载的 RAF/Observer/监听器释放。该测试是模拟 DOM，不作为浏览器像素证据|
|独立消费者|仓库外 core/native 两个新项目均 `pub get`、静态分析和 1 项真实调用测试通过；core 另有 Web Release 编译通过，见下文|

本轮日志保存在本地 `.local/`：`kit-tests-final.log`、`prism-tests.log`、`vendor-tests.log`、`editor-tests.log`、`native-surface-test.log`、`rust-tests.log`、`platform-tests.log`、`showcase-tests.log`、各 `*-analyze.log`。日志不作为源文件发布；以上命令和仓库内测试可复现。避免将上游测试、消费测试和组件数量混为一个覆盖率。

## 编译与实际运行

|目标|编译|实际观察及边界|
|---|---|---|
|Windows x64|当前 Showcase Release 通过；目录包含 Rust、window、tray、dynamic_color 等实际 DLL|较早构建的原生进程启动/响应已观察；最终构建没有单独的原生视觉验收。Windows 截图后端在 Flutter 与空白记事本均超时，未继续反复排障|
|Android|Debug 与当前 Release APK 通过；Release 约 60 MB，包含三种 ABI 的真实 Rust 库、字体和两份运行时许可资产|Android 11 x86_64、1080×1920 隔离模拟器实际安装和运行。已点击控件获得计数反馈，打开原生 Rust 编辑器，实际查询命中，查看语法着色/折叠/替换面板及键盘布局。未测试物理设备和其他 Android 版本|
|Flutter Web|当前 Release 编译通过，Wasm dry run 通过；未声称 Wasm 发布构建已运行|实际浏览器验证了控件计数、扫描动效暂停/布局切换；Web 明确不提供原生 Rust 编辑器。编译仍输出 MaterialIcons/CupertinoIcons 字体 tree-shaker 提示，未隐藏；所有框架默认图标回退路径未逐一验收|
|原生 JavaScript|ES module 无构建依赖，Node 测试通过|通过 localhost 实际验证暂停/恢复、明暗切换、唤起和卸载后重新挂载；控制台 error/warn 为空。截图不是 Flutter 移植效果|
|macOS / Linux / iOS|未在对应系统构建|未做运行、输入法、窗口材质、托盘或性能验收；Linux 需 AppIndicator 依赖。可选编辑器尚未声明 iOS Rust 目标，不能因存在 iOS 工程而宣称支持|

Android Release 当前采用 Flutter 工程的 debug key 签名，仅作本地验收产物，未作为正式发布签名。Windows 分发需要完整 Release 目录，单独复制 EXE 不能运行。

可见运行证据：[Android 控件](screenshots/android-controls.png)、[原生编辑器](screenshots/android-editor.png)、[最终 Release 查找与键盘](screenshots/android-editor-keyboard.png)、[Web 扫描](screenshots/web-scan.jpg)、[原生 JS 动效](screenshots/web-field.jpg)。最终 Release 输入 FlClash 显示 1/1 命中，键盘打开时外部工具栏/说明让出空间，编辑内容仍可见；收起键盘后查询、焦点和匹配结果保留。这些是实际运行截图，不是组件实现或所有中间帧的保真证明。编译日志为 `.local/apk-build-final.log`、`windows-build-final.log`、`web-build-final.log`；Debug APK 的较早成功记录为 `apk-current-build.log`。

没有完成全量动画中间帧对照、GPU 帧预算、内存压力、全平台键盘/触摸/无障碍和全部主题/密度组合验收；不会把 widget 尺寸测试写成设备验收。

## 独立复用与安装提示词

按照 README 提示词建立仓库外临时项目 `flclash-ui-kit-acceptance-20261105-*`，将整个资源根以项目 `.agents/skills/flclash-ui-kit` junction 引用。未创建全局 Skill 或修改全局配置。

1. `quick_validate.py` 返回 `Skill is valid!`；入口可读取 README、SKILL、catalog、提取矩阵、上游、shader 与 licenses。实际定位到 `Palette` 构造器（`widgets/palette.dart`）及调用（`showcase/lib/controls.dart`），以及 `showSnapSheet`（prism `sheet.dart`）及调用（`showcase/lib/effects.dart`）。
2. 将整个 `packages/flutter` 复制到临时项目自己的 `ui-packages/flutter`，不引用本仓库源码或上游路径。新 core 项目仅依赖这个副本，实际按钮 0→1、完整 notice 与 JetBrains 字体加载测试通过，静态分析及 Web Release 编译通过；基础库无需 Rust。
3. 将完整 editor/platform 复制为相邻包。新 native 项目通过自己的依赖解析加载真实 Rust 后端，构建 NativeCodeEditor、修改文档、引用 WindowEffect 并读取 Rust 许可资产；静态分析与测试通过。
4. 日志为 `.local/consumer-{core,native}-*.log`，临时项目实际路径记录在 `.local/acceptance-path.txt`。测试中的外部资产 I/O 使用 `tester.runAsync`；一次测试区内异步加载等待已修正，不是组件失败。

本次证实的是格式、项目级目录引用、实际源码检索和独立消费。**尚未在新的 Agent 会话内证明自动发现/主动调用，也没有验证所有 Agent。** 通用提示词在不能确认发现机制时必须报告这一边界并提供手动路径方式；不把读取 frontmatter 等同于安装成功。机制参考为 [Codex Skill 文档](https://learn.chatgpt.com/docs/build-skills)，不能据此推断其他 Agent 的机制。

## 资源与开源分发检查

实际四个 Flutter 消费者的 98 条 Dart 包/版本许可、Cargo.lock 全图的 84 条 Rust 依赖许可均有完整原文；包括 published crate 漏带的固定 Commit 许可和 Dart C API 的独立 BSD。基础包和 editor 的必要原文作为两个运行时资产随包注册到 LicenseRegistry，独立消费者与 APK 均能加载。

JetBrains Mono 2.304 和 13 个服务 SVG 的来源/授权已核对；原始字节、OFL/CC0/源码许可保留。`Twemoji.Mozilla.ttf` 实际对应 Twemoji COLRv0，上游授权描述矛盾仍未消除；该字库、授权未确认的头像和品牌资源继续隔离。原 GPL 和第三方头不变，修改路径与 Commit 在来源账册中。详细证据见 [license-inventory.md](license-inventory.md) 和 [font-evidence.json](font-evidence.json)。这不是对所有原始资产授权的无条件保证。

## 剩余缺口

- 全部业务页面尚未独立解耦；page 分类的 84 个**文件**包含 views 子组件，不等于 84 个屏幕。代理组 grid/summary、连接/MITM 三类 feed 与节流/快照生命周期、更新与核心状态、规则/资源/设置/配置工作流仍需宿主契约和真实运行验证。
- 编辑器自身可用，但 Clash schema/业务补全、完整文件安全加载与保存等应用工作流尚未全部迁移；扫描绘制可用，但相机、图库、识别、权限和系统生命周期未作为独立套件接入验收。
- 公开组件与变体并非全部有独立示例，其他语言本地化未与英/中文一并解耦；系统字体、原生材质和完整原版视觉尚未跨平台逐项验证。
- 未发布或推送 GitHub 仓库，未进行远程 Git 依赖安装验证，未用正式签名发布二进制。当前交付不能标为最初最终目标已全部完成。
