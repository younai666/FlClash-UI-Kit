# FlClash 应用层组件的独立契约

入口是 `package:flclash_ui_kit/flclash_ui_kit.dart`。每项都应先读实际构造器和 [Showcase 调用](../../showcase/lib)，完整变换与部分文件边界见 [extractions.json](../audit/extractions.json)。下表列的是现有实现，不包含参考页面的未来接口。

|实现|宿主输入与责任|真实调用|
|---|---|---|
|CurrentOutboundCard|OutboundInfo、OutboundQuality、运行/暂停/加载/失败/隐藏 IP 状态、毫秒 runTime；onToggle、onRefresh、可选 onDetails。宿主负责探测与服务启停|dashboard.dart 的 _StatusExample|
|SpeedCard / NetworkSpeedCard|有界 FixedList&lt;Traffic&gt;、累计流量；采样由宿主 append。保留缓冲区 revision、曲线与移动端/桌面排版|dashboard.dart 的 _TrafficExample|
|MemoryInfo / MemoryDetailSheet|必需异步 memoryReader，可选 onRelease。详情独立轮询，卡片休眠；释放失败不会报告成功|dashboard.dart 的 _MemoryExample|
|ServiceStatusCard / ServiceBadge|ServiceStatusItem 列表、ProbePhase、ServiceCheck、刷新/详情回调。保留可用/受限/失败/加载表现；不自动联网|dashboard.dart 的 _ServiceExample|
|NetworkTakeoverCard / Tile、VpnCard / Tile|显式布尔值、端口和 onChanged；不修改网络配置|dashboard.dart 的 _TakeoverExample|
|ProfilesCard / ProfileDetailSheet|DashboardProfile 显示数据、ProfileStats、更新状态与打开/切换/同步/预览回调；额外 providerSlivers 由宿主提供|dashboard.dart 的 _ProfileExample|
|WavyProgressPainter|0–1 的 value、active/track 颜色，保留原波长、振幅、间隙和止点。配额输入在 ProfilesCard 中按原逻辑归一化|ProfilesCard 的配额渲染与 profile_presentation_test|
|DashboardEditor|稳定 DashboardItem、GlobalKey、可用卡片和 onChanged；宿主保存顺序|dashboard.dart|
|ListEditorPage|items、稳定 idOf、itemBuilder、重排/添加/删除回调、搜索字段；搜索时暂停重排，删除只针对选中的可见身份|application.dart 的 ListEditorExample|
|NestedFormSheet / FormPage|currentValue 获取宿主草稿、formBuilder、bindSave；true 保存、false 放弃、null 继续编辑|application.dart 的 _DraftForm|
|RecordFilterController / Scope / GroupedList|facets、groupers、记录输入与过滤/分组回调；存储由宿主负责|application.dart 的 RecordFilterExample|
|BatchInput / BatchSection / EntryDialog|解析回调、ParsedInput、控制器、Field 校验和 toEntry；原批量错误行号/最大 3 条提示保留|application.dart 的 BatchInputExample|
|CommonTargetIcon / GroupMonogram / PackageIcon|URL 或 data URI、回退图标；PackageIcon 的 loadIcon/cachedIconOf 由宿主提供。原 16 MiB 缓存、192 px 解码、8 并发和迟到结果隔离保留|target_icon_test.dart、resources_test.dart|
|ThemeLivePreview / MiniScreen / MiniSplitScreen / MiniScreenThumb / PreviewChoiceGroup|主题、浮动栏、玻璃、slide/fade 和预览选择由宿主输入；保留原缩略绘制|application.dart 的 ThemePreviewDemo|
|ScanLayout / ScannerOverlay / ScanEffectPainter|可用尺寸、安全边距、扫描区域和 Animation；原 4800 ms 周期中两次光束扫描、彗星边框和 18 格网格|scan.dart|
|WindowHeaderLayout / Bar / Actions|显式窗口状态与拖动/双击/按钮回调；事件控制器在 platform 可选包|platform.dart|

扫描器组件是实际绘制和响应布局；摄像头权限、识别、图库与相机生命周期尚由上游 ScanPage 展示参考，不把示例二维码背景称为相机实现。

网络图标的 URL 是显式联网输入。Android 宿主需在主 Manifest 声明 `android.permission.INTERNET`（不能只依赖 debug Manifest）；macOS 沙箱应用需允许网络客户端，Web 资源服务需满足浏览器 CORS。当前 Showcase 不请求外部图标，Android Release 的实际外网图标加载未验收；data URI、服务 SVG 和占位不需要这些网络权限。PackageIcon 的平台应用清单/图标读取也由宿主接入，组件不自行请求应用枚举权限。

内存计数全部为字节。`MemorySnapshot.resolve` 保留共享进程的扣分方式：Android 共享 RSS 中分列内核运行时内存，分进程则分别相加；不要重复计算内核。读取或释放异常保留失败诊断/反馈，不能用零或成功文案吞掉错误。

列表、表单与 Dashboard 的内部布局需要有限约束；桌面卡片含 Expanded/Spacer，宿主提供高度。带 AppBar 的页面正文应在其 Builder 下读取自己的 `contentTopPadding`。编辑器嵌入布局和原生平台要求见 [native.md](../usage/native.md)。

字体策略继承上游 ThemeManager：系统字体名是引用，JetBrains Mono 是包内 OFL 资产，等宽角色通过 `FontFamily.jetBrainsMono.value` 使用正确的 package 名称。未获明确许可的原 emoji 字库仍不注册，跨系统旗帜/emoji 字形不能宣称一致。
