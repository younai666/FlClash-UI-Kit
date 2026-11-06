# FlClash-UI-Kit

从 [FlClash](https://github.com/chen08209/FlClash) 与 [prism_ui](https://github.com/chen08209/prism_ui) 提取的 Flutter 原生 UI、动效和交互资源库，附通用 Agent Skill。

> **Install to Your AI Agent**
>
> 将下面整段提示词发给你的 Agent，并附上本仓库地址或本地路径。安装的是整个资源库，`SKILL.md` 是入口。

```text
请将我提供的 FlClash-UI-Kit 仓库安装为当前项目可用的 UI/UX Skill。

1. 先识别你当前是哪一种 Agent，检查当前项目约定及你实际支持的 Skill 发现/安装机制；不要假定所有 Agent 使用相同目录。
2. 获取仓库的完整内容，阅读根 README.md 和 SKILL.md。若已有本地 checkout，优先复用。远程克隆需保留源码子模块；上游公共子模块使用 SSH URL 时，仅对本次 Git 命令使用 HTTPS URL 重写，不改全局 Git 配置。
3. 根据你实际支持的机制进行项目级安装。可使用该机制支持的目录、完整目录链接，或在项目 Agent 指引中登记资源根路径；不要仅复制 SKILL.md，且不要擅自修改全局配置或覆盖已有 Skill。
4. 确保相对于资源根的整个 packages（包括各自 vendor、字体、shader 和许可资源）、showcase、docs、source/upstream、licenses、LICENSE 和 NOTICE.md 均可访问。安装说明中记录实际资源根路径。
5. 用你的实际发现机制检查 flclash-ui-kit 是否被识别；读取 Skill 指向的组件目录，定位 Palette 与 showSnapSheet 的真实源码和调用示例。若有 Flutter 环境，再用一个临时项目引用完整 packages/flutter 执行 flutter pub get 和 flutter analyze。不要把只读到 frontmatter 当成已经成功调用 Skill。
6. 报告实际安装位置、使用方式和已完成的检查。若当前 Agent 不支持自动安装或无法确认识别，请明确说明，并给出最简单的项目级手动步骤；不要声称安装成功。未经我要求，不安装复杂适配器、不改全局配置、不发布或上传项目。

以后我要求采用 FlClash 的视觉和交互时，请先按该 Skill 检索并复用实际实现。Flutter 直接调用；其他技术栈阅读原始源码再移植，并说明保真边界。
```

完整 `prism_ui` 运行时，以及 FlClash 主壳层、Dashboard、代理列表/标签页、配置列表与添加、连接/请求/DNS/日志、工具、主题/字体、快捷键录制、关于页面与免责声明（含独立浏览与输入校验签署流）已按宿主数据和回调解耦。通用控件、表单、筛选、扫描绘制和原始动效保留。可选包提供真实 CodeForge + Rust 编辑器、窗口/托盘/系统颜色和原生字体枚举，另含官网原生 JavaScript Canvas 动效。

完整业务页面、部分应用特有交互和所有平台的运行验收仍未完成。**源码清点完整不等于全部页面已解耦或逐行人工审查完成。** 当前范围以 [提取矩阵](docs/audit/extraction-matrix.md)、[独立复查](docs/audit/review-findings.md) 和 [验证记录](docs/audit/verification.md) 为准。

## 获取与手动安装

```bash
# 将 YOUR_REPOSITORY_URL 替换为你实际获取本仓库的地址。
git -c url.https://github.com/.insteadOf=git@github.com: clone --recurse-submodules YOUR_REPOSITORY_URL FlClash-UI-Kit
```

Agent 支持项目级 Skill 目录时，将**完整仓库**放入或链接到它支持的 `flclash-ui-kit` 目录。例如支持 `.agents/skills` 的 Agent 可使用 `.agents/skills/flclash-ui-kit/SKILL.md` 作为入口。目录链接是否有效取决于该 Agent 的实际实现。若只有项目指引机制，在当前项目 Agent 指引中记录本仓库绝对路径并要求先读取该路径下的 `SKILL.md`；这属于指引方式，不宣称原生 Skill 自动发现。

本机 Codex CLI 0.149.1 已通过项目目录链接及 `skills/list` 的发现验证；新会话自动调用未通过环境验收，其他 Agent 的自动发现机制尚未验证。提示词中的结果检查和手动路径方式必须保留，详见 [验证记录](docs/audit/verification.md)。

不要将本资源库安装到自身子目录中形成递归链接。不要只下载单个 Skill 文件，也不要把仓库 ZIP 缺失的子模块误认为完整审计源。

## Flutter 使用与展示

包声明 Flutter 3.47.2+、Dart 3.13.2+；当前实际验证使用 Flutter 3.47.9 / Dart 3.13.7。基础组件包不启动代理核心、VPN、托盘或系统网络设置。可选原生编辑器需要 Rust 1.99.0 与目标平台工具链。

```yaml
dependencies:
  flclash_ui_kit:
    path: /your/path/FlClash-UI-Kit/packages/flutter
```

```dart
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() => runApp(KitApp(
  home: Scaffold(
    title: 'My app',
    body: Center(child: FilledButton(
      onPressed: () {},
      child: const Text('Continue'),
    )),
  ),
));
```

```bash
cd showcase
flutter pub get
flutter run -d windows   # 原生桌面
flutter run -d chrome    # Flutter Web
# Android/macOS/Linux 使用对应已配置的 Flutter 目标；验收状态见下文。
```

Showcase 默认进入原版自适应主壳层与仪表盘，可切换完整页面；“工具 → 免责声明”与“应用”页的签署弹窗完整展示法律声明与复述校验体验；“工具 → 组件目录”保留 17 个交互分类、源码示例和图标检索。“工具 → 主题”使用提取的完整主题页，提供调色板、字体、缩放、玻璃和导航/转场预览；工具页另有预览宽度和减少动效开关。数据均为明确标示的本地样本，不执行代理服务或系统网络操作。Web 明确显示原生编辑器不可用；原生版本使用真实 Rust 实现。

[独立应用示例](examples/standalone/lib/main.dart) 使用任意页面/操作 ID 构建笔记与布局应用，只依赖核心包。复现全新项目安装、交互测试及构建：`python tools/verify_consumer.py --flutter /path/to/flutter`；Windows 可追加 `--windows --native-runtime`。临时项目只包含核心包副本，不依赖上游源码树或可选原生包。

[可选原生编辑器与平台集成](docs/usage/native.md) 说明初始化、控制器释放、编译要求与实际验证边界。只用基础 UI 时，无需依赖 `packages/editor` 或安装 Rust。

锁定上游应用的平台为 Android、Windows、macOS、Linux。Showcase 的 iOS 工程只是额外 Flutter 模板，未构建验证；可选 editor 缺少 iOS Rust target，不能将模板存在视为支持。

原生 JavaScript 动效使用 [packages/web](packages/web/README.md)，独立可交互展示为 [showcase/web-field.html](showcase/web-field.html)。从仓库根运行 `python -m http.server 8767 --bind 127.0.0.1`，打开 `http://127.0.0.1:8767/showcase/web-field.html`；浏览器模块应通过 HTTP 加载。

[Flutter 教程](docs/usage/flutter.md) · [组件目录](docs/components/catalog.md) · [集成契约](docs/components/contracts.md) · [其他技术栈移植](docs/usage/porting.md)

## 结构与维护

```text
packages/flutter/             原生组件包；vendor/prism_ui 为完整必需依赖
packages/editor/              可选 CodeForge / Rust 原生编辑器及其独立桥接
packages/platform/            可选窗口、托盘、动态系统颜色及窗口事件控制器
packages/web/                 原生 JavaScript Canvas 动效；不依赖 Flutter
source/upstream/              原始 Git 子模块与 upstream-lock.json
showcase/                     Flutter 交互展示应用，含平台工程与测试
examples/standalone/          核心包独立应用与真实复用测试
docs/audit/                   全文件索引、六项调研、提取矩阵、验证结果
docs/components/, docs/usage/ 调用、契约、移植与维护说明
tools/                        审计、差异复现、许可证与交付检查
SKILL.md                      通用 Agent 入口
```

原始快照与可分发运行时代码分别保留：前者用于精确溯源，后者使组件包在没有上游 app 的情况下独立使用。除了记录过的适配，优先保留原始实现。[维护流程](docs/usage/maintenance.md) 说明如何比较和升级，而不是直接追随上游 HEAD。

## 授权

整体衍生代码按 GPL-3.0 分发；原始第三方 MIT、Apache-2.0、BSD 等授权保留，详见 [LICENSE](LICENSE)、[NOTICE.md](NOTICE.md) 和 [许可证清单](docs/audit/license-inventory.md)。GPL 的适用范围与源代码提供义务应按实际分发方式处理；Skill 安装不会将组件变成宽松许可证代码。已核对的 JetBrains Mono 和服务矢量图标连同原始许可进入组件包；未明确授权的 emoji 字库、头像和应用品牌资产继续隔离。

尚未创建或推送 GitHub 远程发布。发布前应确认提取矩阵、测试和授权边界符合自己的目标。
