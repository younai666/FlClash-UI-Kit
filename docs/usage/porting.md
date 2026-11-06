# 移植到其他技术栈

主要组件是 Flutter/Dart；SwiftUI、Compose、React、CSS 等不能直接导入这些组件。另有已提取的原生 JavaScript Canvas 动效，可直接在 Web 使用，见 [packages/web](../../packages/web/README.md)。其余移植结果必须区分精确移植、受目标渲染器限制的近似和缺失。

|维度|应读取的源实现|移植要求|
|---|---|---|
|色彩|vendor/prism_ui/lib/color.dart、color_scheme.dart、hct/|保留 HCT 和四种风格、亮暗两套语义色，不只截取几个 hex|
|形状/文字|shape.dart、typography.dart、surface.dart|连续 superellipse、表面层级、排版、文字放大、平台字体 fallback；polygon morph 需移植曲线配准算法|
|动效|motion.dart、navigation_dock.dart、page_transition.dart、FlClash scaffold_search.dart|保留质量/刚度/阻尼、速度投影、状态机、被打断后从当前值继续的语义；不以统一 ease 曲线替代弹簧|
|玻璃|liquid_glass.dart、liquid_glass_capture.dart、shaders/liquid_glass.frag|需要背后图层捕获、blur atlas、uniform 映射和混合；单个 CSS backdrop-filter 不能声称等价|
|Sheet|snap_sheet.dart、sheet.dart、sheet_navigator.dart、paged_sheet.dart|detent、投掷、橡皮筋、键盘、滚轮、嵌套覆盖与导航返回共同移植|
|输入/焦点|text_field.dart、text_loupe.dart、text_selection_menu.dart、focus*.dart|尊重平台 IME、选区/放大镜、键盘/遥控方向、鼠标长按与右键|
|页面状态|inherited.dart、route_motion_hold.dart、deferred_push.dart、active_polling.dart|保持前后台、当前页面、转场停留、过期结果隔离与对象释放|
|长列表|prism_list.dart、sliver_list/、record_feed_list.dart|保留 identity、虚拟化、位置估计、滚动锚点与裁掉头部后的条纹；采用目标框架成熟虚拟列表并验证差异|
|业务分离|docs/audit/extraction-matrix.md|输入数据与回调显式化。原生窗口材质、摄像头和 Rust 编辑器需要目标平台单独集成|

先用原生 Showcase 确认交互与中间帧，再在目标栈实现。检查小屏/大屏、亮暗、字体放大、减少动效、触摸/鼠标/键盘，覆盖按住、拖动、取消、被中断和反向触发。原始动效逐文件行号可在 motion-inventory.md 检索。

移植文档记录源 Commit、源文件、目标文件、依赖、差异与验证设备。衍生移植仍需遵守原许可证，不能因改写语言而改成任意授权。
