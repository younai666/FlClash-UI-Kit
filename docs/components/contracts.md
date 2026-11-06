# 集成契约

|边界|契约与理由|真实调用|
|---|---|---|
|宿主层|PrismApp 提供 theme/measure/glass/banner/focus；ViewScope 定义当前可用窗口，不能只设物理设备类型|KitApp，showcase/lib/main.dart|
|绘制|完整保留连续圆角、glass shader 与捕获层。仅一个 LiquidGlassHost 包围 pane；uniform 顺序不可独立改动|showcase/lib/effects.dart|
|尺寸|FloatingNavigationBar、LineChart 需要有限高度；列表/表格需要有限滚动区域|demos.dart 的 SizedBox(height:80)，effects.dart 的 SampleChart|
|滚动|使用 sheet builder 给的 ScrollController；嵌套独立 controller 会争抢拖动/滚动。调用者拥有自己创建的 controller|OverlaysDemo|
|列表|Key 唯一且稳定；更新 RecordFeedList 使用新 List 实例。latest() 获取复用行对应的最新数据；不可原地改变同一 List 然后期待 didUpdateWidget 检出变化|RecordsDemo|
|排序|RecordSorter 假定同列 sortKey 返回可互相比较的值。RecordTableFrame 的 initialColumnWidths 仅初始化，拖动结束通过必需回调保存；tableId 由宿主命名|RecordsDemo|
|Dashboard|DashboardItem.id 在 available 中唯一且稳定；GlobalKey 在编辑和普通布局中共用。宿主负责可用平台过滤、数据与保存；编辑器只返回当前顺序|DashboardDemo|
|运行按钮|RunningToggle 接收 running/enabled/suspended 和 onToggle；不连接代理、不私自改变业务状态。circle→cookie9 的形变及 play→pause 保持原实现|DashboardDemo 的 _SwitchCard|
|搜索/返回|Scaffold 搜索支持 Ctrl/Cmd+F；返回通过 LocalHistoryEntry/BackLayerScope 先关闭搜索。独立 KitApp 未增加上游没有的全局 Escape 约定|integration_test.dart|
|生命周期|ActivePollingMixin 在前台、活动页面与 TickerMode 启用时串行轮询；poll 收到的 isCurrent 必须在异步结果写回前判断。错误交给 FlutterError|src/widgets/active_polling.dart|
|字体|默认使用系统字体；JetBrains Mono 2.304 已按 OFL 注册并使用 package 命名空间。原 Twemoji 字库仍隔离。appFontFamilyFallback 只返回平台字体名|vendor/prism_ui/lib/font.dart|
|授权|上游 GPL 与嵌入第三方许可保留；参考页面不等于已解耦的组件|NOTICE.md、extraction-matrix.md|
|文案与视觉|禁止添加无实际价值的小字注释、辅助说明、占位文案及装饰性文字；保持界面克制、专注核心任务与真实数据|全库遵循|

支持类（MeasureScope、RouteMotionHold、BarItemPresence、FocusRing、Sliver 计算等）通过原组件的组合路径使用。绕过这些层前先阅读其调用者，不能只因为没有可见像素而删除它们。

新增应用层组件的显式状态、异步 reader、事件与释放契约见 [presentation.md](presentation.md)。原生编辑器内嵌区域使用 topInset: 0；完整页面保留 null 的原 AppBar 留白。跨框架移植不能直接调用 Flutter widget。
