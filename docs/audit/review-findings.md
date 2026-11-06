# 独立复查发现与处理

日期：2026-11-05–06。复查重新从 Git 跟踪树、源码全文、引用/part、原生插件、资源和测试开始，没有把旧清单当成范围上限。1,604 个主树条目均重新枚举；嵌套 prism_ui 与独立仓库同 Commit，Clash.Meta 的递归文件清单另在 upstream-lock.json。

**覆盖边界：文件枚举和静态归类覆盖全部主树，不代表所有文件已逐行完成人工语义审查，也不代表全部业务页面已独立运行。** 下面是有具体源码、实现或运行证据的发现；其余文件保留在逐文件矩阵中，不计入已提取组件。

|发现|源码与影响|处理和证据|
|---|---|---|
|清单遗漏 Flutter 目录之外的 UI|`FlClash/site/assets/field.js`、`app.js`、`style.css`，原先被归入 build-support|新增 website 分类、HTML/JS 与原生 UI 特征，保留依赖/全局依赖证据。Canvas 胶囊场与 CSS token 已进 packages/web；其余营销业务组合仍是参考|
|原生桥被分类掩盖|`plugins/rust_api`、其他本地插件，原分类仅识别 editor 子目录|补 native-bridge 分类；窗口命中测试、DWM、NSVisualEffect/NSGlassEffect、GTK、Android Insets/返回、原生生命周期纳入全文候选扫描|
|字体宿主与默认主题偏差|`manager/theme_manager.dart`、`providers/state/theme.dart`|KitApp 接回系统/中文 fallback，默认蓝色/vivid/可选 glass，纯黑和暗色 elevated scheme；缓存 ThemeData 身份，避免普通重建触发主题交叉淡入。原生 Windows 像素一致性尚未验收|
|Rust 编辑器没有独立出口|`plugins/code_forge`、`plugins/rust_api/rust/src/editor`、`pages/editor.dart:661–1377`|可选 editor 包保留完整 CodeForge 与 editor-only Rust，重生成 FRB 2.13.0；238 个原行为测试、13 个 Rust 测试和原生公开入口测试已有通过证据。文件/Clash schema 工作流仍未全部解耦|
|原生编辑器嵌入留白与窄屏问题|原 CodeEditor 的 `context.appBarInset`，FindPanel 的窄屏 replace Row|新增可选 topInset，null 保留原样、0 用于已排好工具栏的宿主；390 px 英文替换输入出现的 17 px 溢出改为窄屏分行。真实 Android 运行发现留白，真实 Rust UI 测试验证编辑、撤销、查找、替换和无溢出|
|Showcase 键盘下仍保留说明区|Prism Scaffold 已消费 bottom viewInsets，子级读到零|按实际高度和 FlutterView 键盘指标隐藏外部工具栏/说明，给编辑区让出空间。外部子项变化时为编辑器保留稳定 key，防止重挂载断开输入；新增键盘开合的状态身份、焦点和编辑区回归，不改上游 Scaffold 契约|
|窗口初始异步查询可覆盖新事件|`manager/window_manager.dart` 的 WindowCaptionController|初始 Future.wait 尚未结束时收到最大化/全屏/置顶结果，保留较新的对应字段，仍载入无关字段。新增延迟响应/事件交错测试；原生插件源码保持原样|
|Dashboard 仅保留部分基础外壳|`views/dashboard/widgets/current_outbound.dart`、traffic、memory_info、service_status、network_takeover、profiles、profile_detail|补完整状态卡、图形背景、流量、内存/详情、服务与徽标、网络开关、配置摘要/详情与波浪进度。业务动作改为显式数据/回调；原参数、绘制和密度规则保留|
|内存释放可能把读失败当成功|`memory_info.dart` 原 nullable reader 包装与释放返回零|reader 成为必需回调，异常进入轮询诊断或释放失败反馈；共享/独立进程计数和失败分支有测试|
|暂停扫描后颜色不更新|`pages/scan.dart` ScanEffectPainter.shouldRepaint 没有比较 contrast|补 contrast 比较与空区域处理；原 4800 ms、两次 sweep、18 格、渐变和模糊保留。摄像头与图库仍由宿主接入|
|应用通用表单与记录实现未抽离|`features/form`、`widgets/record*`、input、subscription_info、theme_preview|补 ListEditorPage、三态退出草稿、批量输入、字段验证、筛选分组、订阅状态和原主题缩略绘制；真实操作与保存/放弃/取消回归已有通过证据|
|图标加载含隐藏服务依赖|`widgets/icon.dart`、`common/cache.dart`|保留缓存、8 并发、192 px 解码、回退与迟到结果隔离；PackageIcon 接宿主 loadIcon/cachedIconOf。保留的 8 个上游图标行为测试通过|
|许可随源树存在，独立运行包可能丢失|prism 嵌入第三方代码、字体、SVG、Rust crates|收集实际 Dart 图与 Cargo.lock 全图；补 crate 包遗漏的固定 Commit 许可、Dart C API BSD；必要原文进运行时资产与 LicenseRegistry。APK 中已查到这些资产|
|审计只检查文件存在，不比较账册|各 extraction ledger 与生成器|主库、editor、platform、web 的 --check 都比较输出与完整账册；矩阵合并同一源文件的多个目标，保留部分摘录边界|

## 字体与资源核对

JetBrains Mono 内部版本为 2.304，与官方 v2.304 字体字节一致。已保留完整 OFL-1.1，并按 Flutter package 字体命名空间使用。具体来源、Commit、SHA256 和决定见 [font-evidence.json](font-evidence.json)。

上游 `Twemoji.Mozilla.ttf` 的内部 family 实际为 **Twemoji COLRv0**。复查已定位到 [Emoji-COLRv0 源项目](https://github.com/Emoji-COLRv0/Emoji-COLRv0)，并与其字体字节对上；这不是按文件名证明它是 Mozilla 版本。该项目根表格写 BY-SA，正文及 Twemoji 子目录写 BY；当前保留这个矛盾，继续隔离原字库，未以推断补授权或注册到运行时。源链接与比较 Commit 见字体证据文件。

13 个服务 SVG 的上游目录明确记录 Simple Icons 13.0.0/CC0，以及 FlClash 自绘的 Claude/中性 streaming glyph；原说明和完整 CC0 原文随包保留。应用/托盘 Logo、头像和代理数据库不进入运行时包。

## 仍未完成的提取与验证

|范围|当前缺口与下一步契约|
|---|---|
|完整配置/设置/代理等业务页面|84 个 page 分类**文件**包含 views 子组件，不能当成 84 个独立屏幕。逐文件参考、依赖与状态在 extraction-matrix。仍需将数据库、全局 provider、文件/VPN/核心动作改为宿主数据与回调，逐页面保留布局后运行|
|代理组与连接业务组合|`proxy_groups.dart` 的完整 grid/summary/选中链路，`connections_table.dart` 的三类 feed、节流计数、轮询与 snapshot 生命周期尚未完整抽离；需要分组显示数据、选中/详情回调、feed reader 与取消/节流契约。通用记录表格已提取，不等同于这些业务组合|
|更新与核心状态 UI|`update_status.dart`、`core_status_button.dart` 仍含下载/安装/核心连通状态；需提取状态模型与 onRetry/onInstall 等动作，保留消失占位和动画衔接|
|其他业务呈现|连接/MITM 请求正文、IP 质量详情、规则/资源/配置等自定义编辑和选择页仍有业务依赖；不能将一个通用表单替代它们后标为完成|
|编辑器应用层|Clash schema、业务 completion、文件安全加载/保存、QuickEdit 的完整工作流仍保留参考。CodeForge 自身与 NativeCodeEditor 可运行并非整页 EditorPage 全部迁移|
|相机与平台服务|扫描绘制可用，实际相机权限、二维码识别、图库、返回与应用服务生命周期未独立接入验证；窗口/托盘实际系统效果也需各平台运行|
|本地化与所有变体|目前 Kit 提供英/中文；上游完整 ARB 与调用者保留。公开支持类型不都拥有独立 Showcase，目录列出真实调用与缺口|
|平台与视觉|构建、运行、截图与测试各自记录在 verification；未运行的平台不算通过。Windows 原生截图通道故障不再反复排查；Android 原生与 Web 的实测不能替代所有系统的字体、材质、输入法和性能验收|
|Skill 与发布|格式、目录、链接和独立包使用可自动检查；新的 Agent 会话主动发现/调用行为与其他 Agent 机制仍需分别证明。没有发布 GitHub 远程或宣称整体目标完成|
