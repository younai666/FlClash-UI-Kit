# FlClash-UI-Kit

[English](README_EN.md) · [简体中文](README.md)

[![Version](https://img.shields.io/badge/version-v0.1.0--preview-blue.svg)](docs/audit/verification.md)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.47.2-02569B.svg?logo=flutter)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/decoupled-100%25%20core%20free-brightgreen.svg)](docs/components/presentation.md)

从 [FlClash](https://github.com/chen08209/FlClash) 与 [prism_ui](https://github.com/chen08209/prism_ui) 完整提取的 Flutter 原生高保真 UI、设计系统、动效与可复用页面套件，附带通用的 AI Agent Skill。

已将前端视觉、交互及物理动效与原 Clash 代理核心（Clash.Meta）、全局状态管理器（Riverpod）及底层业务服务彻底解耦。任何通用 Flutter 项目均可脱离原有业务，直接复用其自适应壳层、精美仪表盘、系统调色板、平滑手势与高质量组件。

---

## 目录

- [核心特性](#核心特性)
- [AI Agent Skill 安装](#ai-agent-skill-安装)
- [快速开始](#快速开始)
- [核心组件与代码示例](#核心组件与代码示例)
  - [1. 基础应用环境 (KitApp)](#1-基础应用环境-kitapp)
  - [2. 自适应主壳层与侧边栏 (HomePage)](#2-自适应主壳层与侧边栏-homepage)
  - [3. 仪表盘与性能卡片 (Dashboard)](#3-仪表盘与性能卡片-dashboard)
  - [4. 主题设置与延迟字体预览 (ThemeView)](#4-主题设置与延迟字体预览-themeview)
  - [5. 法律条款与复述签署弹窗 (DisclaimerView)](#5-法律条款与复述签署弹窗-disclaimerview)
  - [6. 表单编辑与记录过滤 (Form & Records)](#6-表单编辑与记录过滤-form--records)
- [可选原生与 Web 扩展模块](#可选原生与-web-扩展模块)
- [Showcase 交互画廊与运行](#showcase-交互画廊与运行)
- [已知限制与解耦边界](#已知限制与解耦边界)
- [工程结构与技术栈](#工程结构与技术栈)
- [开源合规与许可证](#开源合规与许可证)

---

## 核心特性

- **完整的设计系统**：基于 `prism_ui` 现代化设计语言，内置液态玻璃（Liquid Glass）、超椭圆材质（Superellipse Shapes）、弹簧阻尼物理、平滑触摸回弹与全套语义化 Typography。
- **纯粹的前端解耦**：核心包（`packages/flutter`）零导入 `dart:io`、`dart:ffi`、`dart:isolate`，彻底剔除 Riverpod 与原全局单例，100% 支持 Web 与全跨平台。
- **开箱即用的完整视图**：自适应桌面/移动端壳层（`HomePage`）、全功能仪表盘（`DashboardView`）、节点选择与延迟测速卡片（`ProxiesView`）、配置管理（`ProfilesView`）、网络/DNS/日志监控（`RequestsView`、`LogsView`）、主题与字体定制（`ThemeView`、`FontFamilyView`）、全局快捷键录制（`HotKeyView`）、关于与法律免责签署（`AboutView`、`DisclaimerView`）。
- **可选原生增强与 Web 特效**：可选原生代码编辑器（`packages/editor`，基于 Rust CodeForge 与 FRB 2.13.0）、桌面原生窗口与托盘控制（`packages/platform`）、以及 FlClash 官网原版原生 JavaScript 胶囊流场特效（`packages/web`）。
- **通用 Agent 赋能**：内置遵循 Open Agent Skill 规范的 [`SKILL.md`](SKILL.md)，让 AI 编程助手能快速定位、理解并准确复用整套组件库。

---

## AI Agent Skill 安装

将本仓库整体作为技能安装到您的 AI Agent（如 Google Antigravity、Codex CLI、Claude Code、Cursor 等），即可让 AI 在后续开发中直接调用原版组件，避免重复造轮子。

> [!TIP]
> **发给 AI Agent 的安装提示词：**
> ```text
> 请将我提供的 FlClash-UI-Kit 仓库安装为当前项目可用的 UI/UX Skill。
> 
> 1. 先识别你当前是哪一种 Agent，检查当前项目约定及你实际支持的 Skill 发现/安装机制；不要假定所有 Agent 使用相同目录。
> 2. 获取仓库的完整内容，阅读根 README.md 和 SKILL.md。若已有本地 checkout，优先复用。远程克隆需保留源码子模块；上游公共子模块使用 SSH URL 时，仅对本次 Git 命令使用 HTTPS URL 重写，不改全局 Git 配置。
> 3. 根据你实际支持的机制进行项目级安装。可使用该机制支持的目录、完整目录链接，或在项目 Agent 指引中登记资源根路径；不要仅复制 SKILL.md，且不要擅自修改全局配置或覆盖已有 Skill。
> 4. 确保相对于资源根的整个 packages（包括各自 vendor、字体、shader 和许可资源）、showcase、docs、source/upstream、licenses、LICENSE 和 NOTICE.md 均可访问。安装说明中记录实际资源根路径。
> 5. 用你的实际发现机制检查 flclash-ui-kit 是否被识别；读取 Skill 指向的组件目录，定位 Palette 与 showSnapSheet 的真实源码和调用示例。若有 Flutter 环境，再用一个临时项目引用完整 packages/flutter 执行 flutter pub get 和 flutter analyze。不要把只读到 frontmatter 当成已经成功调用 Skill。
> 6. 报告实际安装位置、使用方式和已完成的检查。若当前 Agent 不支持自动安装或无法确认识别，请明确说明，并给出最简单的项目级手动步骤；不要声称安装成功。未经我要求，不安装复杂适配器、不改全局配置、不发布或上传项目。
> 
> 以后我要求采用 FlClash 的视觉和交互时，请先按该 Skill 检索并复用实际实现。Flutter 直接调用；其他技术栈阅读原始源码再移植，并说明保真边界。
> ```

---

## 快速开始

### 1. 克隆与获取仓库（含子模块）

```bash
git clone --recurse-submodules https://github.com/YOUR_REPO/FlClash-UI-Kit.git
```

### 2. 在 Flutter 项目中添加依赖

在您的 `pubspec.yaml` 中引用核心包路径：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flclash_ui_kit:
    path: /path/to/FlClash-UI-Kit/packages/flutter
```

---

## 核心组件与代码示例

### 1. 基础应用环境 (KitApp)

`KitApp` 预设了双模式深浅色主题、自适应文字缩放（`MeasureScope`）、视口尺寸断点（`ViewScope`）、液态玻璃渲染器与中英双语代理：

```dart
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  runApp(const KitApp(
    locale: Locale('zh'),
    home: Scaffold(
      title: 'FlClash UI Kit Demo',
      body: Center(
        child: FilledButton(
          onPressed: null,
          child: Text('Hello FlClash UI'),
        ),
      ),
    ),
  ));
}
```

### 2. 自适应主壳层与侧边栏 (HomePage)

`HomePage` 完整封装了桌面侧边栏展开/浮动切换、移动端底栏导航（`NavigationDock`）、远距离切页快照保护及页面活跃状态分发：

```dart
Widget buildAppShell(BuildContext context) {
  final shellController = HomeShellController(
    initialLabel: 'dashboard',
  );

  final items = [
    NavigationItem(
      label: 'dashboard',
      glyph: AppGlyphs.dashboard,
      titleOf: (context) => '仪表盘',
      builder: (context) => const DashboardView(),
    ),
    NavigationItem(
      label: 'tools',
      glyph: AppGlyphs.wrench,
      titleOf: (context) => '工具',
      builder: (context) => const ToolsView(),
    ),
  ];

  return HomeShellScope(
    controller: shellController,
    items: items,
    child: const HomePage(),
  );
}
```

### 3. 仪表盘与性能卡片 (Dashboard)

支持独立的网络状态卡片、有界实时流量折线图、内存监控与轮询：

```dart
// 实时出口状态卡片
CurrentOutboundCard(
  info: const OutboundInfo(ip: '198.51.100.1', countryCode: 'US'),
  quality: const OutboundQuality(
    typeLabel: 'Datacenter',
    levelLabel: 'Fast',
    organization: 'Example Cloud',
  ),
  running: true,
  runTime: 3600000,
  hideIp: false,
  onToggle: () => print('Toggle service'),
  onRefresh: () => print('Refresh IP detection'),
);

// 实时网络流量历史图
final trafficHistory = FixedList<Traffic>(capacity: 60);
// 每次收到测速样本时调用 trafficHistory.add(Traffic(up: 1024, down: 2048));
SpeedCard(
  traffic: trafficHistory,
  totalTraffic: '12.4 GB',
);
```

### 4. 主题设置与延迟字体预览 (ThemeView)

完整的色彩方案生成（动态调色板、单色、氛围、柔和风格）、纯黑模式、导航栏悬浮开关及字体平滑滚动预览：

```dart
Widget buildThemeSettings(BuildContext context) {
  final themeController = ThemeController();

  return ThemeScope(
    controller: themeController,
    child: const ThemeView(),
  );
}
```

### 5. 法律条款与复述签署弹窗 (DisclaimerView)

开箱即用的合规声明页面及带有输入法合成态保护的确认弹窗：

```dart
// 1. 作为完整页面打开
BaseNavigator.push(context, const DisclaimerView());

// 2. 作为需强制签署同意的交互流调用
Future<void> requireConsent(BuildContext context) async {
  final agreed = await requestDisclaimerConsent(context);
  if (agreed) {
    print('用户已完成声明复述并同意条款');
  }
}
```

### 6. 表单编辑与记录过滤 (Form & Records)

提供带有取消保护与撤销的表单流，以及支持分组排序与关键字过滤的多维数据视图：

```dart
// 打开嵌套草稿表单弹窗
showNestedFormSheet<String>(
  context: context,
  currentValue: () => '当前草稿内容',
  formBuilder: (context) => MyCustomFormEditor(),
);

// 记录多维分类器与过滤器
final filterController = RecordFilterController<ConnectionRecord>(
  facets: [RecordFacet(RecordFacetKind.network, (r) => [r.network])],
  groupers: [RecordGrouper(RecordGrouping.host, (r) => r.host)],
);
```

---

## 可选原生与 Web 扩展模块

| 模块包路径 | 功能说明 | 依赖与平台要求 |
|---|---|---|
| [`packages/flutter`](packages/flutter) | **核心组件包**（含 `vendor/prism_ui`、JetBrains Mono 字体与 Shader 资产） | 任何 Flutter 3.47.2+ 平台（纯 Web-safe，无原生绑定） |
| [`packages/editor`](packages/editor) | **原生代码编辑器**（原版 CodeForge、Rust Document Backend 与 FRB 2.13.0） | 仅限原生平台；需 Rust 1.99.0 与 C++ 工具链 |
| [`packages/platform`](packages/platform) | **系统能力桥接**（原生窗口控制、系统托盘、动态取色、系统 DirectWrite 字体枚举） | Windows / macOS / Linux 桌面平台 |
| [`packages/web`](packages/web) | **原生 JavaScript 动效**（FlClash 官网原版 Canvas 胶囊流场） | 现代浏览器原生 JS 环境，独立运行无需 Flutter |

详细的原生编译与初始化指引请阅读 [原生与平台集成说明](docs/usage/native.md)。

---

## Showcase 交互画廊与运行

仓库内的 [`showcase`](showcase) 是完整的编译与验收画廊应用，集成了全部解耦页面以及 17 个细分组件演示。

```bash
cd showcase
flutter pub get

# 运行桌面原生端（Windows）
flutter run -d windows

# 运行 Web 端
flutter run -d chrome
```

在交互界面中：
- 主页呈现自适应应用壳层与仪表盘联动。
- 点击 **“工具 → 免责声明”** 浏览条款或进入 **“应用”** 体验复述签署。
- 点击 **“工具 → 组件目录”** 可按 17 个分类交互检索所有按钮、表单、特效、图表、调色板及 230+ 矢量图标。

---

## 已知限制与解耦边界

为了确保组件库通用、轻量且无侵入，以下**属于代理业务领域专有**的功能保持为参考实现，并未强行纳入通用组件核心：

1. **Clash 业务内核与配置生成**：`views/config/*`（YAML/JS 配置转译、规则分流引擎绑定）不属于通用 UI。
2. **底层网络服务与权限**：VPN 网络接管驱动、Android 辅助应用控制（`access.dart`）、WebDAV 云同步备份、根证书注入（`mitm`）由业务宿主自行实现。
3. **平台构建与渲染器验证边界**：
   - Windows x64 Release、Web Release 已经完成像素与交互级构建验证。
   - Android Release APK（62.4 MB）构建通过；在模拟器环境下 Skia 渲染测试通过，默认 Impeller 渲染器存在宿主驱动的 GLES shader 链接报错。
   - macOS / Linux / iOS 在本 Windows 宿主环境下未执行原生构建验证；可选 CodeForge 编辑器暂无 iOS Rust target。

完整逐文件分析与状态矩阵请参阅 [逐文件提取矩阵](docs/audit/extraction-matrix.md) 与 [独立复查记录](docs/audit/review-findings.md)。

---

## 工程结构与技术栈

```text
FlClash-UI-Kit/
├── packages/
│   ├── flutter/          # 核心跨平台 UI 包 (包含 vendor/prism_ui、Shader 与字体)
│   ├── editor/           # 可选 Rust CodeForge 原生代码编辑器
│   ├── platform/         # 可选原生窗口、托盘与 DirectWrite 字体枚举
│   └── web/              # 原生 JavaScript Canvas 流场动效包
├── showcase/             # 交互式完整画廊与验收演示项目
├── examples/
│   └── standalone/       # 零业务依赖的独立消费项目参考
├── docs/                 # 架构设计、全文件索引、组件目录与使用文档
│   ├── audit/            # 溯源账册、空间审计与测试证据
│   └── components/       # 独立调用契约与组件目录
├── source/upstream/      # 冻结的 upstream Git 子模块 (FlClash 与 prism_ui)
├── tools/                # 自动化提取、契约校验、空间瘦身与消费测试脚本
├── LICENSE               # GNU GPL-3.0 许可证
├── NOTICE.md             # 上游版权说明与第三方授权明细
└── SKILL.md              # 开放 AI Agent 技能定义文件
```

---

## 开源合规与许可证

- 本项目衍生代码采用 **[GNU General Public License v3.0 (GPL-3.0)](LICENSE)** 开源。
- 原始版权归原作者 **chen08209** 及上游贡献者所有。
- 内置第三方资源保持各自独立授权：
  - **JetBrains Mono** 字体：SIL Open Font License 1.1 ([OFL-1.1](docs/audit/font-evidence.json))。
  - **服务矢量图标**：Simple Icons 13.0.0 ([CC0 1.0](docs/audit/license-inventory.md)) 与 FlClash 自绘矢量。
  - **第三方 Dart / Rust 库**：完整保留 Apache-2.0、MIT、BSD-3-Clause 原文说明，详见 [`NOTICE.md`](NOTICE.md) 与 [`licenses/`](licenses)。
- 未获明确分发授权的 Emoji 字库、头像图片及应用商标资产**已完全隔离**，未打包进运行时库。

---

*欢迎在您的项目中基于 FlClash-UI-Kit 构建高颜值的 Flutter 应用程序！*
