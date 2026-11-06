# 动效、交互、渲染与生命周期
固定源码的静态调查，日期：2026-11-05。文件枚举、全文特征扫描和 import/export/part 反向关系由 `python tools/audit.py --write` 生成；人工分析聚焦入口、组件、绘制、动效及服务耦合。枚举覆盖不等于逐行人工语义审查或逐组件运行验收。

独立复查与边界见 [review-findings.md](review-findings.md)。完整逐文件证据（包括所有依赖边、反向调用者、行号、平台、生命周期和许可证头）见 [source-index.json](source-index.json)。使用 `python tools/audit.py --check` 检查清单是否仍与锁定源码一致。

## 关键语义

|实现|行为与保持条件|
|---|---|
|液态玻璃|主机捕获、模糊 atlas、渐隐/遮罩层与 pane 采样必须一并保留；保留全部 uniform 和 shader|
|底部 sheet|detents 9/16、0.9；1000/3 刚度、0.8 投掷阻尼；滚轮 500ms 序列；嵌套覆盖缩放 0.9204|
|液滴与按压|dropletSpring mass=1、stiffness=165、ratio=0.8；按压/拖动/悬停使用原始模拟|
|主题/无动画|ThemeCrossFade；所有依赖 disableAnimations 的路径保留，不能统一用固定时长代替|
|路由|drag back、open container、bar item presence、arrival hold、keyboard inset hold 共同协作|
|输入|移动端 text loupe、选区菜单、IME；桌面鼠标和键盘；remote focus 的方向键/浮动键盘|
|Dashboard|编辑摇摆 3600ms、占位 260ms、出现 200ms；连接按钮 240ms；运行按钮旋转/形变见源码|
|应用特有|搜索形变、调色器即时手势、扫码遮罩、主题缩略图、记录流 identity 与 stripeShift|

## 逐文件证据

以下为全文匹配得到的候选点，包含非动画 Timer、常量和注释；它们是可追踪证据，不应直接作为动效数量统计。

### FlClash/android/app/src/main/kotlin/com/follow/clash/MainActivity.kt

用途：platform-host：MainActivity。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/MainActivity.kt#L20)|`override fun onDestroy() {`|
|lifecycle|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/MainActivity.kt#L22)|`super.onDestroy()`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/QuickActionActivity.kt

用途：platform-host：QuickActionActivity。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/QuickActionActivity.kt#L14)|`override fun onCreate(savedInstanceState: Bundle?) {`|
|lifecycle|[L15](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/QuickActionActivity.kt#L15)|`super.onCreate(savedInstanceState)`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/ServiceController.kt

用途：platform-host：。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/ServiceController.kt#L48)|`Core.stopListener()`|
|interaction|[L69](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/ServiceController.kt#L69)|`fun setEventListener(callback: ((ByteArray) -> Unit)?): Result<Unit> = runCatching {`|
|interaction|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/ServiceController.kt#L70)|`Core.updateEventListener(callback)`|
|interaction|[L109](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/ServiceController.kt#L109)|`Core.startListener()`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/ServiceStateMachine.kt

用途：platform-host：class。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/ServiceStateMachine.kt#L58)|`private var transition: RunState? = null`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt

用途：platform-host：AppPlugin。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L73)|`PluginRegistry.ActivityResultListener(::onActivityResult)`|
|interaction|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L76)|`PluginRegistry.RequestPermissionsResultListener(::onRequestPermissionsResultListener)`|
|interaction|[L207](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L207)|`initShortcuts(labels)`|
|interaction|[L554](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L554)|`private fun initShortcuts(labels: Map<QuickAction, String>) {`|
|interaction|[L564](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L564)|`ShortcutManagerCompat.setDynamicShortcuts(GlobalState.application, shortcuts)`|
|interaction|[L771](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L771)|`binding.addActivityResultListener(activityResultListener)`|
|interaction|[L772](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L772)|`binding.addRequestPermissionsResultListener(permissionsResultListener)`|
|interaction|[L774](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L774)|`ViewCompat.setOnApplyWindowInsetsListener(`|
|interaction|[L784](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L784)|`ViewCompat.setOnApplyWindowInsetsListener(it, null)`|
|interaction|[L791](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L791)|`binding.removeActivityResultListener(activityResultListener)`|
|interaction|[L792](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L792)|`binding.removeRequestPermissionsResultListener(permissionsResultListener)`|
|interaction|[L828](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L828)|`private fun onRequestPermissionsResultListener(`|
|lifecycle|[L726](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L726)|`override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {`|
|lifecycle|[L750](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt#L750)|`override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/plugins/BatteryPlugin.kt

用途：platform-host：BatteryPlugin。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L203](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/BatteryPlugin.kt#L203)|`binding.addActivityResultListener(activityResultListener)`|
|interaction|[L220](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/BatteryPlugin.kt#L220)|`activityBinding?.removeActivityResultListener(activityResultListener)`|
|lifecycle|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/BatteryPlugin.kt#L67)|`override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|
|lifecycle|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/BatteryPlugin.kt#L78)|`override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt

用途：platform-host：ServicePlugin。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt#L54)|`ServiceController.setEventListener(null)`|
|interaction|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt#L78)|`ServiceController.setEventListener(::sendEvent)`|
|interaction|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt#L84)|`ServiceController.setEventListener(null)`|
|lifecycle|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt#L30)|`override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|
|lifecycle|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/ServicePlugin.kt#L50)|`override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|

### FlClash/android/app/src/main/kotlin/com/follow/clash/plugins/TilePlugin.kt

用途：platform-host：TilePlugin。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L12](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/TilePlugin.kt#L12)|`override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {`|
|lifecycle|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/app/src/main/kotlin/com/follow/clash/plugins/TilePlugin.kt#L18)|`override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|

### FlClash/android/common/src/main/java/com/follow/clash/common/Ext.kt

用途：platform-host：。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L97](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/common/src/main/java/com/follow/clash/common/Ext.kt#L97)|`filter: IntentFilter,`|

### FlClash/android/core/build.gradle.kts

用途：platform-host：GomobileBind, UnpackJniLibs。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/core/build.gradle.kts#L41)|`?: gomobileTargetByPlatform.values.toList()`|

### FlClash/android/core/src/main/java/com/follow/clash/core/Core.kt

用途：platform-host：。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/core/src/main/java/com/follow/clash/core/Core.kt#L74)|`fun updateEventListener(`|
|interaction|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/core/src/main/java/com/follow/clash/core/Core.kt#L77)|`Mobile.setEventListener(`|
|interaction|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/core/src/main/java/com/follow/clash/core/Core.kt#L96)|`fun startListener() = Mobile.startListener()`|
|interaction|[L98](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/core/src/main/java/com/follow/clash/core/Core.kt#L98)|`fun stopListener() = Mobile.stopListener()`|

### FlClash/android/service/src/main/java/com/follow/clash/service/FilesProvider.kt

用途：platform-host：FilesProvider。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L15](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/service/src/main/java/com/follow/clash/service/FilesProvider.kt#L15)|`override fun onCreate() = true`|

### FlClash/android/service/src/main/java/com/follow/clash/service/ProxyService.kt

用途：platform-host：ProxyService。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L13](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/service/src/main/java/com/follow/clash/service/ProxyService.kt#L13)|`override fun onDestroy() {`|
|lifecycle|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/service/src/main/java/com/follow/clash/service/ProxyService.kt#L17)|`super.onDestroy()`|

### FlClash/android/service/src/main/java/com/follow/clash/service/VpnService.kt

用途：platform-host：VpnService。复用：`source/upstream/FlClash/android`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/service/src/main/java/com/follow/clash/service/VpnService.kt#L33)|`override fun onDestroy() {`|
|lifecycle|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/android/service/src/main/java/com/follow/clash/service/VpnService.kt#L37)|`super.onDestroy()`|

### FlClash/lib/application.dart

用途：entrypoint：Application, ApplicationState。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L118](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L118)|`_autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {`|
|motion|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L143)|`duration: const Duration(milliseconds: 200),`|
|interaction|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L83)|`unawaited(app?.initShortcuts());`|
|platform|[L25](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L25)|`required bool isDesktop,`|
|platform|[L31](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L31)|`final platformApp = isDesktop`|
|platform|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L42)|`final platformState = isDesktop`|
|platform|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L66)|`final _terminateSignals = system.isDesktop && !system.isWindows`|
|platform|[L139](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L139)|`if (system.isDesktop) {`|
|platform|[L170](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L170)|`isDesktop: system.isDesktop,`|
|platform|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L191)|`stackedBanners: !ref.watch(isMobileViewProvider),`|
|lifecycle|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L71)|`void initState() {`|
|lifecycle|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L72)|`super.initState();`|
|lifecycle|[L206](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L206)|`void dispose() {`|
|lifecycle|[L209](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart#L209)|`super.dispose();`|

### FlClash/lib/bootstrap.dart

用途：entrypoint：Bootstrap。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/bootstrap.dart#L78)|`if (!system.isDesktop  /  /  await singleInstanceLock.acquire()) {`|
|platform|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/bootstrap.dart#L228)|`system.isDesktop &&`|
|platform|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/bootstrap.dart#L229)|`Platform.environment['FLCLASH_ACCEPT_DISCLAIMER'] == '1';`|

### FlClash/lib/common/constant.dart

用途：utility：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L63)|`const delayTestGuardDuration = Duration(seconds: 30);`|
|motion|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L67)|`const probeTimeoutDuration = Duration(seconds: 10);`|
|motion|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L72)|`const probeSettleDuration = Duration(milliseconds: 1500);`|
|motion|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L76)|`const probeThrottleDuration = Duration(seconds: 5);`|
|motion|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L80)|`const probeMoveSettleDuration = Duration(milliseconds: 300);`|
|motion|[L82](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L82)|`const downloadTimeoutDuration = Duration(seconds: 20);`|
|motion|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L85)|`const outboundIpTimeoutDuration = Duration(seconds: 6);`|
|motion|[L91](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L91)|`Duration(milliseconds: timeout * budgetFactor) + const Duration(seconds: 5);`|
|motion|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L96)|`const coreConnectionWaitDuration = Duration(seconds: 10);`|
|motion|[L104](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L104)|`const renderThrottleDuration = Duration(milliseconds: 300);`|
|motion|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L105)|`const defaultUpdateDuration = Duration(days: 1);`|
|platform|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L27)|`final helperProtocolVersion = Platform.isWindows ? '8' : '6';`|
|platform|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L52)|`MediaQuery.textScalerOf(context);`|
|platform|[L112](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/constant.dart#L112)|`isDesktop: system.isDesktop,`|

### FlClash/lib/common/dav_client.dart

用途：utility：DAVClientFactory, DAVClient, DAVConnectionController。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L87](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/dav_client.dart#L87)|`void dispose() {`|
|lifecycle|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/dav_client.dart#L90)|`super.dispose();`|

### FlClash/lib/common/dialog.dart

用途：utility：Dialogs。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L226](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/dialog.dart#L226)|`VoidCallback? onTap,`|
|interaction|[L236](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/dialog.dart#L236)|`BannerHost.maybeOf(context)?.show(text, level: level, onTap: onTap);`|
|interaction|[L253](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/dialog.dart#L253)|`onTap: () {`|

### FlClash/lib/common/file.dart

用途：utility：FileExt, FileSystemEntityExt。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/file.dart#L4)|`const _replaceRetryDelay = Duration(milliseconds: 50);`|

### FlClash/lib/common/function.dart

用途：utility：Debouncer, SerialTaskScheduler, Throttler。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/function.dart#L39)|`_operations[tag] = Timer(duration ?? const Duration(milliseconds: 600), () {`|
|motion|[L88](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/function.dart#L88)|`Duration duration = const Duration(milliseconds: 600),`|

### FlClash/lib/common/future.dart

用途：utility：FutureExt, ResolveOnce, CompleterExt, LatestCompute。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L15](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/future.dart#L15)|`final realTimeout = timeout ?? const Duration(minutes: 3);`|

### FlClash/lib/common/ip_quality.dart

用途：utility：IpQualityFailure, IpQualityLookupException。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/ip_quality.dart#L41)|`Duration timeout = const Duration(seconds: 8),`|
|motion|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/ip_quality.dart#L42)|`Duration hedge = const Duration(seconds: 1),`|

### FlClash/lib/common/launch.dart

用途：utility：AutoLaunch。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/launch.dart#L14)|`launcher.setup(appName: appName, appPath: Platform.resolvedExecutable);`|
|platform|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/launch.dart#L50)|`final autoLaunch = system.isDesktop && !safeModeBuild ? AutoLaunch() : null;`|

### FlClash/lib/common/layout.dart

用途：尺寸断点、列数与布局密度。复用：`packages/flutter/lib/src/window/layout.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L10](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L10)|`double getWindowHeaderHeight({required bool isDesktop, required bool isMacOS}) {`|
|platform|[L11](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L11)|`if (!isDesktop) return 0;`|
|platform|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L26)|`required bool isDesktop,`|
|platform|[L29](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L29)|`required bool isMobileView,`|
|platform|[L31](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L31)|`if (!isDesktop) return false;`|
|platform|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L32)|`return !(isMacOS && (version <= 10  /  /  !isMobileView));`|
|platform|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L58)|`required bool isMobileView,`|
|platform|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/layout.dart#L60)|`if (isMobileView) return Size.zero;`|

### FlClash/lib/common/mitm_trust.dart

用途：utility：MitmTrustCheck, MitmTrustStore, TempFileWriter, MacOSMitmTrustStore, WindowsMitmTrustStore, LinuxMitmTrustStore, AndroidMitmTrustStore。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/mitm_trust.dart#L66)|`return MacOSMitmTrustStore(home: Platform.environment['HOME'] ?? '');`|
|platform|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/mitm_trust.dart#L73)|`home: Platform.environment['HOME'] ?? '',`|
|platform|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/mitm_trust.dart#L74)|`searchPath: Platform.environment['PATH'] ?? '',`|

### FlClash/lib/common/package.dart

用途：utility：PackageInfoExtension。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L11](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/package.dart#L11)|`'Platform/${Platform.operatingSystem}',`|

### FlClash/lib/common/path.dart

用途：utility：AppPath。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/path.dart#L60)|`final currentExecutablePath = Platform.resolvedExecutable;`|

### FlClash/lib/common/picker.dart

用途：utility：Picker, PlatformFileExt。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/picker.dart#L49)|`final capture = await MobileScannerPlatform.instance.analyzeImage(`|

### FlClash/lib/common/preferences_store.dart

用途：utility：AtomicFilePreferencesStore。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/preferences_store.dart#L66)|`GetAllParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),`|
|rendering|[L95](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/preferences_store.dart#L95)|`ClearParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),`|

### FlClash/lib/common/protocol.dart

用途：utility：ProtocolRegistrationPlan, LinuxProtocolRegistrationPlan, Protocol。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L87](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/protocol.dart#L87)|`executable: Platform.resolvedExecutable,`|
|platform|[L107](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/protocol.dart#L107)|`final env = Platform.environment;`|
|platform|[L115](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/protocol.dart#L115)|`executable: env['APPIMAGE'] ?? Platform.resolvedExecutable,`|

### FlClash/lib/common/proxy.dart

用途：utility：SystemProxyQueue。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L8](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/proxy.dart#L8)|`final proxy = system.isDesktop && !safeModeBuild ? Proxy() : null;`|

### FlClash/lib/common/system.dart

用途：utility：ProcessRunner, System, Windows, ElevatedHelperInstaller, Linux, MacOS。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L405](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L405)|`Duration timeout = const Duration(seconds: 6),`|
|motion|[L407](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L407)|`const interval = Duration(seconds: 1);`|
|motion|[L440](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L440)|`if (await _waitForHelperService(timeout: const Duration(seconds: 30))) {`|
|platform|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L33)|`bool get isDesktop => isWindows  /  /  isMacOS  /  /  isLinux;`|
|platform|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L35)|`bool get isWindows => Platform.isWindows;`|
|platform|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L37)|`bool get isMacOS => Platform.isMacOS;`|
|platform|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L39)|`bool get isAndroid => Platform.isAndroid;`|
|platform|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L41)|`bool get isLinux => Platform.isLinux;`|
|platform|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L64)|`return switch (Platform.operatingSystem) {`|
|platform|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L134)|`isLinux && Platform.environment.containsKey('APPIMAGE');`|
|platform|[L186](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system.dart#L186)|`final userName = Platform.environment['USER'];`|

### FlClash/lib/common/system_fonts.dart

用途：utility：type。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/system_fonts.dart#L28)|`return sortFontFamilies(switch (Platform.operatingSystem) {`|

### FlClash/lib/common/tray.dart

用途：utility：AppTray。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L297](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/tray.dart#L297)|`final appTray = system.isDesktop ? AppTray() : null;`|

### FlClash/lib/common/webdav.dart

用途：utility：DAVException, DAVTransport。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/webdav.dart#L43)|`..connectTimeout = const Duration(seconds: 8)`|
|motion|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/webdav.dart#L44)|`..sendTimeout = const Duration(seconds: 60)`|
|motion|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/webdav.dart#L45)|`..receiveTimeout = const Duration(seconds: 60);`|

### FlClash/lib/common/window.dart

用途：utility：Window, WindowVisibilityController。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L25](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L25)|`? const Duration(seconds: 1)`|
|interaction|[L167](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L167)|`desktopWindow.addListener(_InitFailureWindowListener(onExit));`|
|interaction|[L262](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L262)|`_InitFailureWindowListener(this.onExit);`|
|platform|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L17)|`WindowEffect? _blurEffect;`|
|platform|[L124](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L124)|`Future<WindowEffect> _resolveBlurEffect() async {`|
|platform|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L132)|`? const [WindowEffect.glass, WindowEffect.blur]`|
|platform|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L133)|`: const [WindowEffect.mica, WindowEffect.blur];`|
|platform|[L139](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L139)|`return WindowEffect.none;`|
|platform|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L155)|`final effect = enabled ? await _resolveBlurEffect() : WindowEffect.none;`|
|platform|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L161)|`return effect == WindowEffect.none ? null : _tintOpacity;`|
|platform|[L358](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/common/window.dart#L358)|`final window = system.isDesktop ? Window() : null;`|

### FlClash/lib/enum/enum.dart

用途：entrypoint：SupportPlatform, GroupName, GroupType, LoadBalanceStrategy, IpVersion, GroupTypeExtension, DelayTestPhase, Mode, ViewMode, LogLevel, RecordTone, RecordFacetKind, RecordGrouping, RecordToneExt, TrafficUnit, NavigationItemMode, ProxiesSortType, TunStack, AccessControlMode, AccessSortType, ProfileType, ResultType, CoreEventType, FindProcessMode, InterfaceNameMode, RestoreOption, ProxiesType, ProxiesLayout, ProxyCardType, DnsMode, DnsCacheAlgorithm, FakeIpFilterMode, OverrideKey, DnsOverrideKey, NtpOverrideKey, SnifferOverrideKey, TunOverrideKey, GeneralOverrideKey, ExternalControllerStatus, KeyboardModifier, HotAction, ProxiesIconStyle, EditorFontSize, AuthorizeCode, TunAuthorizationState, FunctionTag, DashboardWidget, DnsQueryInitiator, IpType, IpQualityLevel, IpQualitySource, IpQualitySourceStatus, GeodataLoader, GeoResource, GeoResourceExt, PageLabel, RuleAction, RuleActionExt, ProxyFieldKind, ProxyField, RulePayloadError, RulePayloadErrorExt, ExtendType, RuleTarget, ProviderKind, RuleProviderBehavior, RuleProviderFormat, RestoreStrategy, TabAnimation, LiquidGlassMode, Language, ScrollPositionCacheKey, QueryTag, LoadingTag, MitmList, MitmTrust, MitmInstallOutcome, CoreStatus, RequestFeed, UpdatingScope。复用：`packages/flutter/lib/src/records/types.dart`。状态：部分提取：RecordTone/RecordFacetKind/RecordGrouping 及颜色；其他业务枚举未提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L20)|`return SupportPlatform.Windows;`|
|platform|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L22)|`return SupportPlatform.MacOS;`|
|platform|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L23)|`} else if (Platform.isLinux) {`|
|platform|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L24)|`return SupportPlatform.Linux;`|
|platform|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L26)|`return SupportPlatform.Android;`|
|platform|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L28)|`throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');`|
|platform|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L33)|`SupportPlatform.Linux,`|
|platform|[L34](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L34)|`SupportPlatform.MacOS,`|
|platform|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L35)|`SupportPlatform.Windows,`|
|platform|[L454](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L454)|`vpnButton(platforms: [SupportPlatform.Android]),`|
|platform|[L465](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/enum/enum.dart#L465)|`const DashboardWidget({this.platforms = SupportPlatform.values});`|

### FlClash/lib/features/connection/detail_tabs.dart

用途：feature：DetailTabs。复用：`packages/flutter/lib/src/records/detail_tabs.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/detail_tabs.dart#L27)|`child: MediaQuery.removePadding(`|

### FlClash/lib/features/connection/mitm_body.dart

用途：feature：MitmBodySection。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/mitm_body.dart#L84)|`onTap: () => _open(context),`|
|platform|[L167](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/mitm_body.dart#L167)|`textScaler: MediaQuery.textScalerOf(context),`|
|lifecycle|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/mitm_body.dart#L171)|`painter.dispose();`|

### FlClash/lib/features/connection/mitm_exchanges.dart

用途：feature：MitmExchangesView, MitmExchangeView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/mitm_exchanges.dart#L162)|`onTap: () => showInSheet<void>(`|

### FlClash/lib/features/connection/tracker_info_item.dart

用途：feature：TrackerInfoItem, TrackerInfoDetailView。复用：`packages/flutter/lib/src/records/tracker_info_item.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L109](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_item.dart#L109)|`onTap: () => showTrackerInfoDetail(`|
|interaction|[L196](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_item.dart#L196)|`GestureDetector(`|
|interaction|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_item.dart#L197)|`onTap: () => RecordFilterScope.add(`|
|interaction|[L305](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_item.dart#L305)|`onTap: () => _confirm(`|

### FlClash/lib/features/connection/tracker_info_list.dart

用途：feature：TrackerInfoListController, TrackerInfoList, TrackerInfoAnimatedList, TrackerInfoGroupedList。复用：`packages/flutter/lib/src/records/tracker_info_list.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L224](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_list.dart#L224)|`void didUpdateWidget(TrackerInfoGroupedList oldWidget) {`|
|lifecycle|[L225](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_list.dart#L225)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/features/connection/tracker_info_table.dart

用途：feature：TrackerInfoTableRow, TrackerTargetText, TrackerRuleText。复用：`packages/flutter/lib/src/records/tracker_info_table.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_info_table.dart#L179)|`onTap: () => showTrackerInfoDetail(context, trackerInfo, detailTitle),`|

### FlClash/lib/features/connection/tracker_speed_ranker.dart

用途：feature：TrackerSpeedRanker。复用：`packages/flutter/lib/src/records/tracker_speed_ranker.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/connection/tracker_speed_ranker.dart#L30)|`static const _minSampleGap = Duration(milliseconds: 500);`|

### FlClash/lib/features/editor/completion_popup.dart

用途：feature：EditorCompletionPopup。复用：`packages/editor/lib/src/completion_popup.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L123](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L123)|`onTap: () => widget.details.onAccept(index),`|
|platform|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L81)|`textScaler: MediaQuery.textScalerOf(context),`|
|platform|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L171)|`return LayoutBuilder(`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L44)|`void didUpdateWidget(covariant EditorCompletionPopup oldWidget) {`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L45)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L52)|`void dispose() {`|
|lifecycle|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L53)|`_scrollController.dispose();`|
|lifecycle|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L54)|`super.dispose();`|
|lifecycle|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/editor/completion_popup.dart#L96)|`painter.dispose();`|

### FlClash/lib/features/form/form_row.dart

用途：feature：InfoMessageButton, EntryButton, FormRow, FormRowTextField, FormRowSecretTextField。复用：`packages/flutter/lib/src/forms/form_row.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L149](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/form_row.dart#L149)|`final FocusNode? focusNode;`|
|interaction|[L232](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/form_row.dart#L232)|`final FocusNode? focusNode;`|
|platform|[L106](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/form_row.dart#L106)|`title: LayoutBuilder(`|

### FlClash/lib/features/form/list_edit_view.dart

用途：feature：EditViewState, ConfigListEditItem, ListEditView。复用：`packages/flutter/lib/src/forms/list_edit_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L150](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_edit_view.dart#L150)|`return ReorderDragStartListener(`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_edit_view.dart#L45)|`void initState() {`|
|lifecycle|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_edit_view.dart#L46)|`super.initState();`|

### FlClash/lib/features/form/list_editor_page.dart

用途：feature：ListEditorItemBuilder, ListEditorPage, ListEditorAddAction。复用：`packages/flutter/lib/src/forms/list_editor_page.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L169](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L169)|`? ReorderDragStartListener(index: index, child: child)`|
|lifecycle|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L63)|`void initState() {`|
|lifecycle|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L64)|`super.initState();`|
|lifecycle|[L69](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L69)|`void dispose() {`|
|lifecycle|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L70)|`_scrollController.dispose();`|
|lifecycle|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/list_editor_page.dart#L71)|`super.dispose();`|

### FlClash/lib/features/form/map_edit_view.dart

用途：feature：MapEditView。复用：`packages/flutter/lib/src/forms/map_edit_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L136)|`final _valueFocusNode = FocusNode();`|
|interaction|[L154](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L154)|`_valueFocusNode.dispose();`|
|interaction|[L247](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L247)|`onFieldSubmitted: (_) => _valueFocusNode.requestFocus(),`|
|interaction|[L255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L255)|`focusNode: _valueFocusNode,`|
|lifecycle|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L146)|`void initState() {`|
|lifecycle|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L147)|`super.initState();`|
|lifecycle|[L153](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L153)|`void dispose() {`|
|lifecycle|[L154](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L154)|`_valueFocusNode.dispose();`|
|lifecycle|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L155)|`_keyController.dispose();`|
|lifecycle|[L156](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L156)|`_valueController.dispose();`|
|lifecycle|[L157](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/map_edit_view.dart#L157)|`super.dispose();`|

### FlClash/lib/features/form/named_url_form.dart

用途：feature：NamedUrl, NamedUrlForm。复用：`packages/flutter/lib/src/forms/named_url_form.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L96)|`final _urlFocusNode = FocusNode();`|
|interaction|[L97](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L97)|`final _ageSecretKeyFocusNode = FocusNode();`|
|interaction|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L131)|`_urlFocusNode.dispose();`|
|interaction|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L132)|`_ageSecretKeyFocusNode.dispose();`|
|interaction|[L284](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L284)|`onFieldSubmitted: (_) => _urlFocusNode.requestFocus(),`|
|interaction|[L292](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L292)|`focusNode: _urlFocusNode,`|
|interaction|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L304)|`_ageSecretKeyFocusNode.requestFocus();`|
|interaction|[L316](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L316)|`focusNode: _ageSecretKeyFocusNode,`|
|lifecycle|[L123](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L123)|`void initState() {`|
|lifecycle|[L124](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L124)|`super.initState();`|
|lifecycle|[L130](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L130)|`void dispose() {`|
|lifecycle|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L131)|`_urlFocusNode.dispose();`|
|lifecycle|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L132)|`_ageSecretKeyFocusNode.dispose();`|
|lifecycle|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L133)|`_labelController.dispose();`|
|lifecycle|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L134)|`_urlController.dispose();`|
|lifecycle|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L135)|`_ageSecretKeyController.dispose();`|
|lifecycle|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L136)|`_batchController.dispose();`|
|lifecycle|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/named_url_form.dart#L137)|`super.dispose();`|

### FlClash/lib/features/form/nested_form_sheet.dart

用途：feature：NestedFormSheet。复用：`packages/flutter/lib/src/forms/nested_form_sheet.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/nested_form_sheet.dart#L62)|`void initState() {`|
|lifecycle|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/nested_form_sheet.dart#L63)|`super.initState();`|

### FlClash/lib/features/form/quick_edit.dart

用途：feature：QuickEditCancelled。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L79](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/quick_edit.dart#L79)|`context.isMobileView`|

### FlClash/lib/features/form/rule.dart

用途：feature：RuleItem, RuleStatusItem, RuleForm。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L114](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L114)|`child: LayoutBuilder(`|
|lifecycle|[L266](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L266)|`void initState() {`|
|lifecycle|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L267)|`super.initState();`|
|lifecycle|[L277](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L277)|`void dispose() {`|
|lifecycle|[L278](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L278)|`_contentController.dispose();`|
|lifecycle|[L279](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/rule.dart#L279)|`super.dispose();`|

### FlClash/lib/features/form/selection_sheet.dart

用途：feature：SelectionSection, SelectionSheet。复用：`packages/flutter/lib/src/forms/selection_sheet.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L51)|`with TickerProviderStateMixin {`|
|motion|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L101)|`_transitions.leave(item, context.motionDuration(commonDuration));`|
|motion|[L226](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L226)|`animation: animation,`|
|motion|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L267)|`animation: _transitions.animationOf(item),`|
|rendering|[L189](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L189)|`if (box is! RenderBox  /  /  !box.hasSize) {`|
|lifecycle|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L64)|`void initState() {`|
|lifecycle|[L65](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L65)|`super.initState();`|
|lifecycle|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L70)|`void dispose() {`|
|lifecycle|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L71)|`_transitions.dispose();`|
|lifecycle|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L72)|`_controller.dispose();`|
|lifecycle|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L73)|`_revealController.dispose();`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/features/form/selection_sheet.dart#L74)|`super.dispose();`|

### FlClash/lib/main.dart

用途：entrypoint：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/main.dart#L22)|`if (Platform.isWindows  /  /  Platform.isLinux) {`|
|platform|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/main.dart#L23)|`SharedPreferencesStorePlatform.instance = AtomicFilePreferencesStore(`|
|platform|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/main.dart#L27)|`if (Platform.isLinux) {`|

### FlClash/lib/manager/android_manager.dart

用途：lifecycle：AndroidManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L42)|`}, duration: const Duration(seconds: 1));`|
|motion|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L62)|`}, duration: const Duration(seconds: 2));`|
|interaction|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L35)|`app?.initShortcuts();`|
|interaction|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L48)|`service?.addListener(this);`|
|interaction|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L71)|`service?.removeListener(this);`|
|lifecycle|[L25](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L25)|`void initState() {`|
|lifecycle|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L26)|`super.initState();`|
|lifecycle|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L66)|`void dispose() {`|
|lifecycle|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/android_manager.dart#L72)|`super.dispose();`|

### FlClash/lib/manager/app_manager.dart

用途：lifecycle：AppStateManager, AppEnvManager, AppSidebarContainer。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L248](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L248)|`child: MediaQuery.removePadding(`|
|platform|[L264](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L264)|`child: LayoutBuilder(`|
|platform|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L267)|`return MediaQuery.removePadding(`|
|lifecycle|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L26)|`with WidgetsBindingObserver {`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L28)|`void initState() {`|
|lifecycle|[L29](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L29)|`super.initState();`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L74)|`void dispose() {`|
|lifecycle|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L76)|`super.dispose();`|
|lifecycle|[L79](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L79)|`void _updateVisible(AppLifecycleState? state) {`|
|lifecycle|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L81)|`null  /  /  AppLifecycleState.resumed  /  /  AppLifecycleState.inactive => true,`|
|lifecycle|[L82](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L82)|`AppLifecycleState.hidden  /  / `|
|lifecycle|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L83)|`AppLifecycleState.paused  /  / `|
|lifecycle|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L84)|`AppLifecycleState.detached => false,`|
|lifecycle|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L89)|`Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {`|
|lifecycle|[L91](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/app_manager.dart#L91)|`if (state == AppLifecycleState.resumed) {`|

### FlClash/lib/manager/connectivity_manager.dart

用途：lifecycle：SsidReader, ConnectivityManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/connectivity_manager.dart#L43)|`void initState() {`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/connectivity_manager.dart#L44)|`super.initState();`|
|lifecycle|[L108](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/connectivity_manager.dart#L108)|`void dispose() {`|
|lifecycle|[L110](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/connectivity_manager.dart#L110)|`super.dispose();`|

### FlClash/lib/manager/core_manager.dart

用途：lifecycle：CoreManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L124](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L124)|`}, duration: const Duration(milliseconds: 5000));`|
|motion|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L134)|`duration: const Duration(seconds: 3),`|
|motion|[L149](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L149)|`duration: const Duration(seconds: 3),`|
|motion|[L187](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L187)|`}, duration: const Duration(milliseconds: 5000));`|
|interaction|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L39)|`coreEventManager.addListener(this);`|
|interaction|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L113)|`coreEventManager.removeListener(this);`|
|lifecycle|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L37)|`void initState() {`|
|lifecycle|[L38](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L38)|`super.initState();`|
|lifecycle|[L112](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L112)|`void dispose() {`|
|lifecycle|[L114](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L114)|`super.dispose();`|
|lifecycle|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/core_manager.dart#L197)|`if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {`|

### FlClash/lib/manager/hotkey_manager.dart

用途：lifecycle：KeyboardModifierExt, HotKeyActionExt, HotKeyRegistrar, HotKeyManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L203](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L203)|`Shortcuts _buildCloseShortcuts(Widget child) {`|
|interaction|[L204](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L204)|`return Shortcuts(`|
|interaction|[L206](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L206)|`controlSingleActivator(LogicalKeyboardKey.keyW):`|
|interaction|[L208](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L208)|`const SingleActivator(LogicalKeyboardKey.escape):`|
|interaction|[L237](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L237)|`return _buildCloseShortcuts(widget.child);`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L74)|`void initState() {`|
|lifecycle|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L75)|`super.initState();`|
|lifecycle|[L230](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L230)|`void dispose() {`|
|lifecycle|[L232](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/hotkey_manager.dart#L232)|`super.dispose();`|

### FlClash/lib/manager/locale_manager.dart

用途：lifecycle：LocaleManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/locale_manager.dart#L18)|`void didChangeDependencies() {`|
|lifecycle|[L19](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/locale_manager.dart#L19)|`super.didChangeDependencies();`|

### FlClash/lib/manager/proxy_manager.dart

用途：lifecycle：ProxyManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/proxy_manager.dart#L17)|`void initState() {`|
|lifecycle|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/proxy_manager.dart#L18)|`super.initState();`|

### FlClash/lib/manager/theme_manager.dart

用途：lifecycle：ThemeManager, AppViewScope。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L8](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L8)|`import 'package:flutter/foundation.dart' show defaultTargetPlatform;`|
|platform|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L28)|`platform: defaultTargetPlatform,`|
|platform|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L43)|`platform: defaultTargetPlatform,`|
|platform|[L92](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L92)|`child: _AppMediaQuery(`|
|platform|[L93](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L93)|`// Every rebuild outside a nearer LayoutBuilder, a route transition's`|
|platform|[L97](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L97)|`child: LayoutBuilder(`|
|platform|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L120)|`final isMobile = ref.watch(isMobileViewProvider);`|
|platform|[L123](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L123)|`isMobile: isMobile,`|
|platform|[L127](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L127)|`isMobileView: isMobile,`|
|platform|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L134)|`class _AppMediaQuery extends StatelessWidget {`|
|platform|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L135)|`const _AppMediaQuery({required this.child});`|
|platform|[L141](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L141)|`final data = MediaQuery.of(context);`|
|platform|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/theme_manager.dart#L143)|`return MediaQuery(`|

### FlClash/lib/manager/tile_manager.dart

用途：lifecycle：TileManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L41)|`tile?.addListener(this);`|
|interaction|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L46)|`tile?.removeListener(this);`|
|lifecycle|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L39)|`void initState() {`|
|lifecycle|[L40](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L40)|`super.initState();`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L45)|`void dispose() {`|
|lifecycle|[L47](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tile_manager.dart#L47)|`super.dispose();`|

### FlClash/lib/manager/tray_manager.dart

用途：lifecycle：TrayManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tray_manager.dart#L30)|`void initState() {`|
|lifecycle|[L31](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tray_manager.dart#L31)|`super.initState();`|
|lifecycle|[L117](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tray_manager.dart#L117)|`void dispose() {`|
|lifecycle|[L119](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/tray_manager.dart#L119)|`super.dispose();`|

### FlClash/lib/manager/vpn_manager.dart

用途：lifecycle：VpnManager。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/vpn_manager.dart#L43)|`onTap: () {`|
|lifecycle|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/vpn_manager.dart#L23)|`void initState() {`|
|lifecycle|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/vpn_manager.dart#L24)|`super.initState();`|

### FlClash/lib/manager/window_manager.dart

用途：原生窗口事件、标题栏拖动、双击、置顶、最大化、全屏及关闭策略。复用：`packages/flutter/lib/src/window/header.dart；packages/platform/lib/src/window_caption.dart`。状态：部分提取：WindowHeaderLayout/State/Bar/Actions；原生事件控制器在 platform 包，应用生命周期与系统动作仍在上游；部分提取：WindowCaptionController；应用持久化、退出策略仍在上游。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L16](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L16)|`const _windowGeometryDelay = Duration(milliseconds: 120);`|
|interaction|[L61](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L61)|`desktopWindow.addListener(this);`|
|interaction|[L201](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L201)|`desktopWindow.removeListener(this);`|
|interaction|[L309](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L309)|`desktopWindow.addListener(this);`|
|interaction|[L378](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L378)|`desktopWindow.removeListener(this);`|
|interaction|[L456](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L456)|`child: GestureDetector(`|
|interaction|[L457](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L457)|`onPanStart: (_) {`|
|platform|[L215](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L215)|`final isMobileView = ref.watch(isMobileViewProvider);`|
|platform|[L218](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L218)|`isDesktop: system.isDesktop,`|
|platform|[L221](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L221)|`isMobileView: isMobileView,`|
|platform|[L401](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L401)|`final backdropOpacity = ref.watch(isMobileViewProvider)`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L44)|`void initState() {`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L45)|`super.initState();`|
|lifecycle|[L198](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L198)|`void dispose() {`|
|lifecycle|[L202](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L202)|`super.dispose();`|
|lifecycle|[L376](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L376)|`void dispose() {`|
|lifecycle|[L379](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L379)|`super.dispose();`|
|lifecycle|[L394](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L394)|`void dispose() {`|
|lifecycle|[L395](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L395)|`caption.dispose();`|
|lifecycle|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/manager/window_manager.dart#L396)|`super.dispose();`|

### FlClash/lib/models/generated/clash_config.freezed.dart

用途：model：class, ProxyGroupPatterns, class, class, ProxyPatterns, class, class, CustomProxyPatterns, class, class, ProxyDialerPatterns, class, CustomIssuePatterns, EmptyNameIssue, ReservedNameIssue, class, DuplicateNameIssue, class, CoreRejectedIssue, class, MissingProxiesIssue, class, MissingProvidersIssue, class, NoProxySourceIssue, GroupLoopIssue, class, InvalidEmptyFallbackIssue, class, InvalidFilterIssue, class, InvalidPayloadIssue, class, MissingRuleSetIssue, class, MissingSubRuleIssue, class, MissingTargetIssue, class, MissingDialerIssue, class, DialerLoopIssue, class, class, CustomProfileIssuesPatterns, class, class, CustomProfileDataPatterns, class, class, SnifferPatterns, class, class, SnifferConfigPatterns, class, class, TunPatterns, class, class, FallbackFilterPatterns, class, class, DnsPatterns, class, class, NtpPatterns, class, class, ProfileTunPatterns, class, class, ProfileOverridesPatterns, class, class, ProviderHealthCheckPatterns, class, class, ProviderOverridePatterns, class, class, ProxyProviderOptionsPatterns, class, class, RulePatterns, class, class, ClashConfigPatterns, class, class, PatchClashConfigPatterns, class, class, MitmPatterns, class。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L48)|`return 'ProxyGroup(profileId: ${_this.profileId}, id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, proxies: ${_this.proxies}, use: ${_this.use}, usePosition: ${_this.usePosition}, interval: ${_this.interval}, lazy: ${_this.lazy}, disableUDP: ${_this.disableUDP}, url: ${_this.url}, timeout: ${_this.timeout}, maxFailedTimes: ${_this.maxFailedTimes}, filter: ${_this.filter}, excludeFilter: ${_this.excludeFilter}, excludeType: ${_this.excludeType}, expectedStatus: ${_this.expectedStatus}, tolerance: ${_this.tolerance}, strategy: ${_this.strategy}, hashKey: ${_this.hashKey}, defaultSelected: ${_this.defaultSelected}, emptyFallback: ${_this.emptyFallback}, includeAllProxies: ${_this.includeAllProxies}, includeAllProviders: ${_this.includeAllProviders}, hidden: ${_this.hidden}, icon: ${_this.icon}, order: ${_this.order}, memberLayout: ${_this.memberLayout})';`|
|rendering|[L91](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L91)|`as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable`|
|rendering|[L339](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L339)|`return 'ProxyGroup(profileId: $profileId, id: $id, name: $name, type: $type, proxies: $proxies, use: $use, usePosition: $usePosition, interval: $interval, lazy: $lazy, disableUDP: $disableUDP, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, tolerance: $tolerance, strategy: $strategy, hashKey: $hashKey, defaultSelected: $defaultSelected, emptyFallback: $emptyFallback, includeAllProxies: $includeAllProxies, includeAllProviders: $includeAllProviders, hidden: $hidden, icon: $icon, order: $order, memberLayout: $memberLayout)';`|
|rendering|[L382](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L382)|`as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable`|
|rendering|[L6414](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L6414)|`return 'ProxyProviderOptions(healthCheck: ${_this.healthCheck}, filter: ${_this.filter}, excludeFilter: ${_this.excludeFilter}, proxyOverride: ${_this.proxyOverride}, memberLayout: ${_this.memberLayout})';`|
|rendering|[L6445](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L6445)|`as ProviderHealthCheck,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable`|
|rendering|[L6653](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L6653)|`return 'ProxyProviderOptions(healthCheck: $healthCheck, filter: $filter, excludeFilter: $excludeFilter, proxyOverride: $proxyOverride, memberLayout: $memberLayout)';`|
|rendering|[L6684](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.freezed.dart#L6684)|`as ProviderHealthCheck,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable`|

### FlClash/lib/models/generated/clash_config.g.dart

用途：model：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.g.dart#L27)|`filter: json['filter'] as String?,`|
|rendering|[L743](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/clash_config.g.dart#L743)|`filter: json['filter'] as String?,`|

### FlClash/lib/models/generated/profile.g.dart

用途：model：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/generated/profile.g.dart#L37)|`autoUpdateDuration: Duration(`|

### FlClash/lib/pages/editor.dart

用途：编辑器补全、查找替换、选区、折叠及 Rust 文档桥接。复用：`packages/editor/lib/src/native_code_editor.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L801](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L801)|`if (navigatorBox is! RenderBox) {`|
|interaction|[L164](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L164)|`LogicalKeyboardKey.keyS,`|
|interaction|[L169](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L169)|`LogicalKeyboardKey.keyS,`|
|interaction|[L185](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L185)|`_undoController = UndoRedoController()..addListener(_syncBarState);`|
|interaction|[L187](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L187)|`..addListener(_syncBarState);`|
|interaction|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L229)|`controller?.addListener(_syncBarState);`|
|interaction|[L370](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L370)|`child: CallbackShortcuts(`|
|interaction|[L702](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L702)|`widget.findController.addListener(_handleFindChanged);`|
|interaction|[L709](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L709)|`oldWidget.findController.removeListener(_handleFindChanged);`|
|interaction|[L710](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L710)|`widget.findController.addListener(_handleFindChanged);`|
|interaction|[L724](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L724)|`widget.findController.removeListener(_handleFindChanged);`|
|interaction|[L905](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L905)|`controller.addListener(closeOnceOutdated);`|
|interaction|[L906](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L906)|`focusNode?.addListener(closeOnceOutdated);`|
|interaction|[L908](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L908)|`controller.removeListener(closeOnceOutdated);`|
|interaction|[L909](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L909)|`focusNode?.removeListener(closeOnceOutdated);`|
|interaction|[L1065](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1065)|`child: CallbackShortcuts(`|
|interaction|[L1067](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1067)|`const SingleActivator(LogicalKeyboardKey.escape): controller.hide,`|
|interaction|[L1068](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1068)|`const SingleActivator(LogicalKeyboardKey.enter, shift: true):`|
|interaction|[L1209](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1209)|`focusNode: controller.findInputFocusNode,`|
|interaction|[L1212](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1212)|`controller.findInputFocusNode.requestFocus();`|
|interaction|[L1253](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1253)|`focusNode: controller.replaceInputFocusNode,`|
|interaction|[L1259](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1259)|`controller.replaceInputFocusNode.requestFocus();`|
|interaction|[L1279](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1279)|`final FocusNode focusNode;`|
|platform|[L160](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L160)|`CodeForgeKeyboardShortcuts.forPlatform(defaultTargetPlatform);`|
|platform|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L162)|`SingleActivator get _saveShortcut => switch (defaultTargetPlatform) {`|
|platform|[L163](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L163)|`TargetPlatform.macOS  /  /  TargetPlatform.iOS => const SingleActivator(`|
|platform|[L877](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L877)|`route = system.isDesktop`|
|platform|[L1077](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1077)|`child: LayoutBuilder(builder: _buildRows),`|
|platform|[L1139](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L1139)|`final inlineMinWidth = MediaQuery.textScalerOf(`|
|lifecycle|[L182](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L182)|`void initState() {`|
|lifecycle|[L183](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L183)|`super.initState();`|
|lifecycle|[L201](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L201)|`void didUpdateWidget(covariant EditorPage oldWidget) {`|
|lifecycle|[L202](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L202)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L245](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L245)|`document.dispose();`|
|lifecycle|[L270](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L270)|`document?.dispose();`|
|lifecycle|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L282)|`_heldDocument?.dispose();`|
|lifecycle|[L295](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L295)|`previous?.dispose();`|
|lifecycle|[L299](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L299)|`void dispose() {`|
|lifecycle|[L300](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L300)|`_undoController.dispose();`|
|lifecycle|[L301](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L301)|`_titleController.dispose();`|
|lifecycle|[L302](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L302)|`_document?.dispose();`|
|lifecycle|[L303](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L303)|`_heldDocument?.dispose();`|
|lifecycle|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L304)|`super.dispose();`|
|lifecycle|[L501](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L501)|`void initState() {`|
|lifecycle|[L502](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L502)|`super.initState();`|
|lifecycle|[L511](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L511)|`void didUpdateWidget(covariant EditorView oldWidget) {`|
|lifecycle|[L512](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L512)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L546](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L546)|`void dispose() {`|
|lifecycle|[L547](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L547)|`_findController?.dispose();`|
|lifecycle|[L548](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L548)|`_controller?.dispose();`|
|lifecycle|[L549](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L549)|`_ownedUndoController?.dispose();`|
|lifecycle|[L550](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L550)|`super.dispose();`|
|lifecycle|[L699](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L699)|`void initState() {`|
|lifecycle|[L700](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L700)|`super.initState();`|
|lifecycle|[L706](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L706)|`void didUpdateWidget(covariant _CodeEditor oldWidget) {`|
|lifecycle|[L707](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L707)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L723](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L723)|`void dispose() {`|
|lifecycle|[L725](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L725)|`_verticalController.dispose();`|
|lifecycle|[L726](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L726)|`super.dispose();`|
|lifecycle|[L913](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L913)|`items.dispose();`|
|lifecycle|[L914](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/editor.dart#L914)|`anchor.dispose();`|

### FlClash/lib/pages/error.dart

用途：page：InitErrorApp, InitErrorScreen。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L93](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/error.dart#L93)|`_noticeTimer = Timer(const Duration(seconds: 4), () {`|
|motion|[L317](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/error.dart#L317)|`duration: const Duration(milliseconds: 200),`|
|lifecycle|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/error.dart#L84)|`void dispose() {`|
|lifecycle|[L86](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/error.dart#L86)|`_notice.dispose();`|
|lifecycle|[L87](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/error.dart#L87)|`super.dispose();`|

### FlClash/lib/pages/home.dart

用途：page：HomePage, HomeBackScopeContainer。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L324](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L324)|`await _pageController.animateToPage(`|
|motion|[L327](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L327)|`curve: fade ? fadeTabCurve : Curves.easeOut,`|
|motion|[L435](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L435)|`animation: widget.controller,`|
|interaction|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L80)|`child: FocusTraversalGroup(`|
|interaction|[L198](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L198)|`final scopedView = PageFocusScope(`|
|platform|[L34](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L34)|`final isMobile = ref.watch(isMobileViewProvider);`|
|platform|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L42)|`isMobile: isMobile,`|
|platform|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L67)|`final isMobile = state.viewMode == ViewMode.mobile;`|
|platform|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L83)|`inset: isMobile && floating`|
|platform|[L86](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L86)|`child: _BodyPadding(isMobile: isMobile, child: child),`|
|platform|[L95](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L95)|`visible: isMobile && floating,`|
|platform|[L119](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L119)|`visible: isMobile && !floating,`|
|platform|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L146)|`const _BodyPadding({required this.isMobile, required this.child});`|
|platform|[L148](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L148)|`final bool isMobile;`|
|platform|[L153](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L153)|`return MediaQuery.removePadding(`|
|platform|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L155)|`removeBottom: isMobile,`|
|platform|[L156](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L156)|`removeLeft: isMobile,`|
|platform|[L157](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L157)|`removeRight: isMobile,`|
|platform|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L171)|`return MediaQuery.removePadding(`|
|platform|[L186](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L186)|`required this.isMobile,`|
|platform|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L191)|`final bool isMobile;`|
|platform|[L203](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L203)|`child: isMobile`|
|platform|[L299](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L299)|`final isMobile = ref.read(isMobileViewProvider);`|
|platform|[L309](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L309)|`if (!isMobile  /  /  ignoreAnimateTo) {`|
|lifecycle|[L218](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L218)|`return PageActivityScope(`|
|lifecycle|[L254](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L254)|`void initState() {`|
|lifecycle|[L255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L255)|`super.initState();`|
|lifecycle|[L265](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L265)|`void didUpdateWidget(covariant _HomePageView oldWidget) {`|
|lifecycle|[L266](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L266)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L340](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L340)|`void dispose() {`|
|lifecycle|[L341](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L341)|`_pageController.dispose();`|
|lifecycle|[L342](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L342)|`super.dispose();`|
|lifecycle|[L412](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L412)|`void dispose() {`|
|lifecycle|[L413](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L413)|`_snapshot.dispose();`|
|lifecycle|[L414](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart#L414)|`super.dispose();`|

### FlClash/lib/pages/scan.dart

用途：扫码摄像头生命周期、识别区域、自绘遮罩、权限与图库入口。复用：`packages/flutter/lib/src/scan.dart`。状态：部分提取：ScanLayout、ScannerOverlay、ScanEffectPainter；相机、权限、扫码、照片导入由宿主提供。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L26)|`const _invalidHintDuration = Duration(seconds: 2);`|
|motion|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L28)|`const _previewRevealDuration = Duration(milliseconds: 600);`|
|motion|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L32)|`curve: Curves.easeOut,`|
|motion|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L45)|`SingleTickerProviderStateMixin,`|
|motion|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L53)|`late final AnimationController _effectController = AnimationController(`|
|motion|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L55)|`duration: const Duration(milliseconds: 4800),`|
|motion|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L396)|`animation: _effectController,`|
|motion|[L795](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L795)|`scanWindow.top + scanWindow.height * Curves.easeInOut.transform(sweep);`|
|rendering|[L694](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L694)|`class ScannerOverlay extends CustomPainter {`|
|rendering|[L710](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L710)|`..addRSuperellipse(`|
|rendering|[L716](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L716)|`canvas.drawPath(backgroundWithCutout, Paint()..color = color);`|
|rendering|[L727](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L727)|`class _ScanEffectPainter extends CustomPainter {`|
|rendering|[L767](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L767)|`canvas.drawRSuperellipse(`|
|rendering|[L775](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L775)|`canvas.drawRSuperellipse(`|
|rendering|[L803](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L803)|`canvas.saveLayer(trail, Paint());`|
|rendering|[L808](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L808)|`canvas.drawPath(`|
|interaction|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L73)|`_controller.addListener(_syncEffect);`|
|interaction|[L441](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L441)|`_controller.removeListener(_syncEffect);`|
|platform|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L267)|`child: LayoutBuilder(`|
|platform|[L272](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L272)|`padding: MediaQuery.paddingOf(context),`|
|platform|[L274](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L274)|`MediaQuery.textScalerOf(`|
|platform|[L628](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L628)|`MediaQuery.paddingOf(context) +`|
|platform|[L632](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L632)|`return LayoutBuilder(`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L44)|`WidgetsBindingObserver,`|
|lifecycle|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L70)|`void initState() {`|
|lifecycle|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L71)|`super.initState();`|
|lifecycle|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L81)|`void didChangeDependencies() {`|
|lifecycle|[L82](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L82)|`super.didChangeDependencies();`|
|lifecycle|[L223](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L223)|`void didChangeAppLifecycleState(AppLifecycleState state) {`|
|lifecycle|[L224](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L224)|`super.didChangeAppLifecycleState(state);`|
|lifecycle|[L226](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L226)|`case AppLifecycleState.detached:`|
|lifecycle|[L227](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L227)|`case AppLifecycleState.hidden:`|
|lifecycle|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L228)|`case AppLifecycleState.paused:`|
|lifecycle|[L230](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L230)|`case AppLifecycleState.resumed:`|
|lifecycle|[L244](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L244)|`case AppLifecycleState.inactive:`|
|lifecycle|[L432](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L432)|`// StatefulElement.unmount asserts that super.dispose() already ran by the`|
|lifecycle|[L433](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L433)|`// time dispose() returns, so nothing here may await first: the controller is`|
|lifecycle|[L436](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L436)|`void dispose() {`|
|lifecycle|[L442](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L442)|`unawaited(_controller.dispose());`|
|lifecycle|[L443](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L443)|`_effectController.dispose();`|
|lifecycle|[L444](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L444)|`_invalidHint.dispose();`|
|lifecycle|[L445](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/scan.dart#L445)|`super.dispose();`|

### FlClash/lib/plugins/app.dart

用途：entrypoint：App。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L12](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/app.dart#L12)|`const _platformProbeTimeout = Duration(seconds: 2);`|
|motion|[L19](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/app.dart#L19)|`const _downloadPollInterval = Duration(milliseconds: 500);`|
|interaction|[L151](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/app.dart#L151)|`Future<bool?> initShortcuts() async {`|
|platform|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/app.dart#L229)|`if (!Platform.isAndroid) return false;`|

### FlClash/lib/plugins/service.dart

用途：entrypoint：class, Service。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L159](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/service.dart#L159)|`void addListener(ServiceListener listener) {`|
|interaction|[L163](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/service.dart#L163)|`void removeListener(ServiceListener listener) {`|

### FlClash/lib/plugins/tile.dart

用途：entrypoint：class, Tile。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/tile.dart#L49)|`void addListener(TileListener listener) {`|
|interaction|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/plugins/tile.dart#L53)|`void removeListener(TileListener listener) {`|

### FlClash/lib/providers/actions/common.dart

用途：state：CommonAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L238](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/common.dart#L238)|`onTap: () => unawaited(installUpdate()),`|

### FlClash/lib/providers/actions/mitm_modules.dart

用途：state：MitmModulesAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/mitm_modules.dart#L396)|`final interval = Duration(hours: setting.geoUpdateInterval);`|

### FlClash/lib/providers/actions/proxies.dart

用途：state：ProxiesAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L400](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/proxies.dart#L400)|`Duration(milliseconds: ref.read(appSettingProvider).delayTestTimeout),`|

### FlClash/lib/providers/actions/resources.dart

用途：state：ResourcesAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/resources.dart#L120)|`final interval = Duration(hours: setting.geoUpdateInterval);`|

### FlClash/lib/providers/actions/setup.dart

用途：state：BuiltProfile, SetupAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/setup.dart#L120)|`const Duration(seconds: 1),`|
|motion|[L351](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/setup.dart#L351)|`Duration get minApplyDebounce => const Duration(seconds: 2);`|
|motion|[L356](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/setup.dart#L356)|`Duration get maxApplyDebounce => const Duration(seconds: 10);`|
|motion|[L368](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/setup.dart#L368)|`duration: Duration(`|
|interaction|[L323](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/setup.dart#L323)|`return running ? _core.startListener() : _core.stopListener();`|

### FlClash/lib/providers/actions/system.dart

用途：state：SystemAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/system.dart#L43)|`Duration get exitWatchdogDuration => const Duration(seconds: 3);`|
|platform|[L115](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/system.dart#L115)|`if (system.isDesktop) {`|

### FlClash/lib/providers/actions/updating.dart

用途：state：UpdatingAction。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L3](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/updating.dart#L3)|`const updatingSweepInterval = Duration(seconds: 30);`|
|motion|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/actions/updating.dart#L4)|`const updatingStaleTimeout = Duration(minutes: 3);`|

### FlClash/lib/providers/app.dart

用途：state：AuthorizedTunEnable, UpdateDownloadState, Logs, Requests, DnsQueries, DnsQueryCount, RequestCount, Providers, Packages, SystemBrightness, Traffics, TotalTraffic, LoadedLocale, LocalIp, RunTime, RunningVpnOptions, AppVisible, ViewSize, SideWidth, WindowBlur, Init, CurrentPageLabel, SortNum, Version, Groups, DelayDataSource, PendingDelayTests, DelayTestingGroups, HotKeyFailures, HotKeyRecording, SystemUiOverlayStyleState, Query, Loading, Items, UpdatingKeys, CurrentSSID。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L570](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/app.dart#L570)|`_timer = Timer(Duration(milliseconds: minDuration - elapsed), () {`|
|platform|[L286](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/app.dart#L286)|`bool isMobileView(Ref ref) {`|

### FlClash/lib/providers/generated/app.g.dart

用途：state：SafeModeProvider, RootAccessProvider, AuthorizedTunEnableProvider, UpdateDownloadStateProvider, LogsProvider, RequestsProvider, DnsQueriesProvider, DnsQueryCountProvider, RequestCountProvider, ProvidersProvider, PackagesProvider, SystemBrightnessProvider, TrafficsProvider, TotalTrafficProvider, LoadedLocaleProvider, LocalIpProvider, RunTimeProvider, RunningVpnOptionsProvider, AppVisibleProvider, ViewSizeProvider, SideWidthProvider, WindowBlurProvider, ViewWidthProvider, ViewModeProvider, IsMobileViewProvider, InitProvider, CurrentPageLabelProvider, SortNumProvider, VersionProvider, GroupsProvider, DelayDataSourceProvider, PendingDelayTestsProvider, DelayTestingGroupsProvider, HotKeyFailuresProvider, HotKeyRecordingProvider, SystemUiOverlayStyleStateProvider, QueryProvider, QueryFamily, LoadingProvider, LoadingFamily, ItemsProvider, ItemsFamily, UpdatingKeysProvider, IsUpdatingProvider, IsUpdatingFamily, CurrentSSIDProvider。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L1238](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1238)|`@ProviderFor(isMobileView)`|
|platform|[L1239](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1239)|`final isMobileViewProvider = IsMobileViewProvider._();`|
|platform|[L1248](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1248)|`name: r'isMobileViewProvider',`|
|platform|[L1255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1255)|`String debugGetCreateSourceHash() => _$isMobileViewHash();`|
|platform|[L1264](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1264)|`return isMobileView(ref);`|
|platform|[L1276](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/generated/app.g.dart#L1276)|`String _$isMobileViewHash() => r'1d75bccb4f50ae206bf43b68df869a5d95e5ea5f';`|

### FlClash/lib/providers/ip_quality.dart

用途：state：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L16](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/ip_quality.dart#L16)|`Duration ipQualityFailureCooldown(Ref ref) => const Duration(minutes: 5);`|
|motion|[L19](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/ip_quality.dart#L19)|`Duration ipQualityMaxAge(Ref ref) => const Duration(days: 3);`|

### FlClash/lib/providers/mitm.dart

用途：state：MitmCa, MitmTrustState, MitmCharsetTranscoder, MitmExportWarned, MitmModuleDetails。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L25](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/mitm.dart#L25)|`const _exchangesRefreshInterval = Duration(seconds: 2);`|

### FlClash/lib/providers/route_state.dart

用途：state：RouteState, RouteStamp, RouteTracker。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L141](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/route_state.dart#L141)|`Duration(seconds: 1),`|
|motion|[L142](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/route_state.dart#L142)|`Duration(seconds: 2),`|
|motion|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/route_state.dart#L143)|`Duration(seconds: 5),`|
|motion|[L144](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/route_state.dart#L144)|`Duration(seconds: 10),`|
|motion|[L145](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/route_state.dart#L145)|`Duration(seconds: 30),`|

### FlClash/lib/providers/state/navigation.dart

用途：state：。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L95](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/navigation.dart#L95)|`final isDesktop = element.modes.contains(`|
|platform|[L98](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/navigation.dart#L98)|`if (isMore && !isDesktop) return true;`|
|platform|[L114](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/navigation.dart#L114)|`final isMobileView = ref.watch(isMobileViewProvider);`|
|platform|[L118](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/navigation.dart#L118)|`isDesktop: system.isDesktop,`|
|platform|[L121](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/navigation.dart#L121)|`isMobileView: isMobileView,`|

### FlClash/lib/providers/state/system.dart

用途：state：AccessControlState。复用：`source/upstream/FlClash`。状态：已归类，参考实现。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/providers/state/system.dart#L54)|`system.isDesktop &&`|

### FlClash/lib/ui/icons/app_glyphs.dart

用途：应用自绘矢量图标及随状态变化的动态图形。复用：`packages/flutter/lib/src/icons/app_glyphs.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L1797](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/icons/app_glyphs.dart#L1797)|`static Glyph backFor(TargetPlatform platform) => Glyphs.backFor(platform);`|

### FlClash/lib/ui/list_item.dart

用途：普通、打开页面、选项、输入、勾选和开关六种行行为。复用：`packages/flutter/lib/src/ui/list_item.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L88](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L88)|`final void Function()? onTap;`|
|interaction|[L98](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L98)|`this.onTap,`|
|interaction|[L123](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L123)|`onTap = null;`|
|interaction|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L146)|`onTap = null;`|
|interaction|[L177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L177)|`onTap = null;`|
|interaction|[L193](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L193)|`onTap = null;`|
|interaction|[L209](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L209)|`onTap = null;`|
|interaction|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L214)|`void Function()? onTap,`|
|interaction|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L229)|`onPressed: onTap,`|
|interaction|[L244](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L244)|`if (onTap == null) {`|
|interaction|[L250](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L250)|`onPressed: onTap,`|
|interaction|[L270](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L270)|`onTap: () async {`|
|interaction|[L290](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L290)|`onTap: action,`|
|interaction|[L306](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L306)|`onTap: () => openMenu?.call(),`|
|interaction|[L331](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L331)|`onTap: () async {`|
|interaction|[L357](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L357)|`onTap: checkboxDelegate.onChanged == null`|
|interaction|[L371](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L371)|`onTap: toggleAction.onChanged == null`|
|interaction|[L382](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L382)|`return _buildRow(context, position: position, onTap: onTap);`|
|platform|[L265](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/list_item.dart#L265)|`if (!context.isMobileView) {`|

### FlClash/lib/ui/qr_code.dart

用途：固定白底、四模块安静区及超容量文本处理。复用：`packages/flutter/lib/src/ui/qr_code.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_code.dart#L44)|`class _QrPainter extends CustomPainter {`|
|rendering|[L69](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_code.dart#L69)|`canvas.drawPath(path, Paint()..color = Colors.black);`|

### FlClash/lib/ui/scaffold/scaffold.dart

用途：app-ui：AppBarSearchState, ScaffoldKeyword, AppBarSearchStateBuilder, Scaffold, ScaffoldState。复用：`packages/flutter/lib/src/scaffold/scaffold.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L113)|`with SingleTickerProviderStateMixin {`|
|motion|[L391](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L391)|`tween: Tween(end: active ? 1 : 0),`|
|motion|[L392](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L392)|`duration: context.motionDuration(_searchSettleDuration),`|
|motion|[L484](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L484)|`duration: context.motionDuration(kThemeAnimationDuration),`|
|rendering|[L2](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L2)|`import 'dart:ui' show ImageFilter, lerpDouble;`|
|rendering|[L176](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L176)|`if (box is! RenderBox  /  /  bar is! RenderBox  /  /  !box.hasSize) {`|
|interaction|[L117](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L117)|`final _searchFocusNode = FocusNode();`|
|interaction|[L154](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L154)|`_searchFocusNode.addListener(_handleSearchFocusChange);`|
|interaction|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L155)|`_searchMotion.addStatusListener((status) {`|
|interaction|[L216](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L216)|`if (_searchFocusNode.hasFocus  /  / `|
|interaction|[L235](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L235)|`LogicalKeyboardKey.keyF,`|
|interaction|[L241](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L241)|`_searchFocusNode.requestFocus();`|
|interaction|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L304)|`_searchFocusNode.unfocus();`|
|interaction|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L318)|`_searchFocusNode.unfocus();`|
|interaction|[L333](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L333)|`_searchFocusNode.dispose();`|
|interaction|[L351](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L351)|`focusNode: _searchFocusNode,`|
|interaction|[L384](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L384)|`listenable: Listenable.merge([_searchFocusNode, _textController]),`|
|interaction|[L387](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L387)|`_searchFocusNode.hasFocus  /  /  _textController.text.isNotEmpty;`|
|interaction|[L683](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L683)|`focusNode: _searchFocusNode,`|
|platform|[L732](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L732)|`final isMobileView = ViewScope.isMobileOf(context);`|
|platform|[L735](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L735)|`isMobileView &&`|
|platform|[L739](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L739)|`isCompactBar(context, isMobileView),`|
|platform|[L837](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L837)|`_searchFillsBar = isCompactBar(context, ViewScope.isMobileOf(context));`|
|lifecycle|[L150](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L150)|`void initState() {`|
|lifecycle|[L151](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L151)|`super.initState();`|
|lifecycle|[L255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L255)|`context.getInheritedWidgetOfExactType<PageActivityScope>()?.isActive ==`|
|lifecycle|[L274](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L274)|`void didUpdateWidget(Scaffold oldWidget) {`|
|lifecycle|[L275](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L275)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L329](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L329)|`void dispose() {`|
|lifecycle|[L331](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L331)|`_appBarState.dispose();`|
|lifecycle|[L332](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L332)|`_textController.dispose();`|
|lifecycle|[L333](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L333)|`_searchFocusNode.dispose();`|
|lifecycle|[L334](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L334)|`_searchMotion.dispose();`|
|lifecycle|[L335](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L335)|`_searchOrigin.dispose();`|
|lifecycle|[L336](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L336)|`_searchCovered.dispose();`|
|lifecycle|[L337](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L337)|`_loadingNotifier.dispose();`|
|lifecycle|[L338](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold.dart#L338)|`super.dispose();`|

### FlClash/lib/ui/scaffold/scaffold_actions.dart

用途：动作折叠、表单确认与取消、搜索/排序/选择栏。复用：`packages/flutter/lib/src/scaffold/scaffold_actions.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L221](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_actions.dart#L221)|`onTap: onPressed,`|
|platform|[L157](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_actions.dart#L157)|`ViewScope.isMobileOf(context) &&`|

### FlClash/lib/ui/scaffold/scaffold_search.dart

用途：搜索源几何测量、弹簧形变、液滴/收缩返回与键盘协调。复用：`packages/flutter/lib/src/scaffold/scaffold_search.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L13](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L13)|`final _searchSpring = SpringDescription.withDampingRatio(`|
|motion|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L18)|`final _searchCloseSpring = SpringDescription.withDampingRatio(`|
|motion|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L23)|`final _searchMorphSpring = SpringDescription.withDampingRatio(`|
|motion|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L28)|`final _droplet = SpringSimulation(dropletSpring, 0, 1, 0);`|
|motion|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L30)|`const _searchSettleDuration = Duration(milliseconds: 450);`|
|motion|[L153](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L153)|`required Simulation this.growth,`|
|motion|[L166](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L166)|`final Simulation? growth;`|
|motion|[L199](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L199)|`Curve curve = Curves.linear,`|
|motion|[L210](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L210)|`slotCollapse: to(from.slotCollapse, 1, 0, 0.08, Curves.easeOut),`|
|motion|[L221](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L221)|`to(from.glassLift, 1, 0.02, 0.12, Curves.easeOut),`|
|motion|[L225](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L225)|`Curves.easeInOut,`|
|motion|[L243](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L243)|`to(from.groupSwell, 1, 0.27, 0.36, Curves.easeOut),`|
|motion|[L247](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L247)|`Curves.easeInOut,`|
|motion|[L254](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L254)|`slotCollapse: to(from.slotCollapse, 0, 0.17, 0.33, Curves.easeInOut),`|
|motion|[L278](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L278)|`to(from.glassLift, 1, 0.06, 0.16, Curves.easeOut),`|
|motion|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L282)|`Curves.easeInOut,`|
|motion|[L317](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L317)|`class _SearchClock extends Simulation {`|
|motion|[L343](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L343)|`_SearchMotion(TickerProvider vsync)`|
|motion|[L344](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L344)|`: _clock = AnimationController.unbounded(vsync: vsync);`|
|motion|[L346](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L346)|`final AnimationController _clock;`|
|motion|[L381](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L381)|`growth: SpringSimulation(`|
|motion|[L404](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L404)|`_clock.animateWith(_SearchClock(_move));`|
|motion|[L489](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L489)|`animation: motion.listenable,`|
|motion|[L530](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L530)|`animation: Listenable.merge([motion.listenable, ?droplet]),`|
|motion|[L563](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L563)|`animation: motion.listenable,`|
|motion|[L677](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L677)|`animation: Listenable.merge([motion.listenable, origin]),`|
|rendering|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L51)|`child: ImageFiltered(`|
|rendering|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L53)|`imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),`|
|interaction|[L368](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L368)|`void addStatusListener(AnimationStatusListener listener) =>`|
|interaction|[L369](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L369)|`_clock.addStatusListener(listener);`|
|platform|[L633](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L633)|`final padding = MediaQuery.paddingOf(context);`|
|platform|[L648](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L648)|`child: LayoutBuilder(`|
|lifecycle|[L412](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/scaffold/scaffold_search.dart#L412)|`void dispose() => _clock.dispose();`|

### FlClash/lib/views/about.dart

用途：page：Contributor, AboutView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L307](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/about.dart#L307)|`_timer = Timer(const Duration(seconds: 1), _resetCounter);`|
|interaction|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/about.dart#L53)|`onTap: () {`|
|interaction|[L325](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/about.dart#L325)|`return GestureDetector(onTap: _handleTap, child: widget.child);`|
|lifecycle|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/about.dart#L318)|`void dispose() {`|
|lifecycle|[L320](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/about.dart#L320)|`super.dispose();`|

### FlClash/lib/views/access.dart

用途：page：AccessView, PackageListItem。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L29](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L29)|`void initState() {`|
|lifecycle|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L30)|`super.initState();`|
|lifecycle|[L486](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L486)|`void initState() {`|
|lifecycle|[L487](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L487)|`super.initState();`|
|lifecycle|[L492](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L492)|`void dispose() {`|
|lifecycle|[L493](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L493)|`_controller.dispose();`|
|lifecycle|[L494](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/access.dart#L494)|`super.dispose();`|

### FlClash/lib/views/backup_and_restore.dart

用途：page：BackupAndRestore, RestoreOptionsDialog, WebDAVForm。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L216](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L216)|`onTap: () {`|
|interaction|[L222](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L222)|`onTap: () {`|
|interaction|[L234](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L234)|`onTap: () {`|
|interaction|[L240](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L240)|`onTap: () {`|
|interaction|[L322](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L322)|`onTap: () {`|
|interaction|[L328](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L328)|`onTap: () {`|
|lifecycle|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L32)|`void initState() {`|
|lifecycle|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L33)|`super.initState();`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L44)|`void dispose() {`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L45)|`_davConnection.dispose();`|
|lifecycle|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L46)|`super.dispose();`|
|lifecycle|[L357](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L357)|`void initState() {`|
|lifecycle|[L358](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L358)|`super.initState();`|
|lifecycle|[L365](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L365)|`void dispose() {`|
|lifecycle|[L366](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L366)|`_uriController.dispose();`|
|lifecycle|[L367](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L367)|`_userController.dispose();`|
|lifecycle|[L368](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L368)|`_passwordController.dispose();`|
|lifecycle|[L369](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/backup_and_restore.dart#L369)|`super.dispose();`|

### FlClash/lib/views/config/filters.dart

用途：page：FiltersView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L30)|`filter: filter,`|
|rendering|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L84)|`filter: filter,`|
|lifecycle|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L161)|`void initState() {`|
|lifecycle|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L162)|`super.initState();`|
|lifecycle|[L168](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L168)|`void dispose() {`|
|lifecycle|[L169](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L169)|`_labelController.dispose();`|
|lifecycle|[L170](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L170)|`_regexController.dispose();`|
|lifecycle|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/filters.dart#L171)|`super.dispose();`|

### FlClash/lib/views/config/general.dart

用途：page：LogLevelItem, UaItem, DelayTestTimeoutItem, PortItem, HostsItem, AuthenticationItem, AuthenticationAccountItem, AuthenticationPasswordItem, ExternalControllerSecretItem, GeneralView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L88](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general.dart#L88)|`onTap: () {`|
|platform|[L246](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general.dart#L246)|`if (system.isDesktop) ...[`|

### FlClash/lib/views/config/general/port_form.dart

用途：page：。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L34](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L34)|`void initState() {`|
|lifecycle|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L35)|`super.initState();`|
|lifecycle|[L159](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L159)|`void dispose() {`|
|lifecycle|[L160](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L160)|`_mixedPortController.dispose();`|
|lifecycle|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L161)|`_portController.dispose();`|
|lifecycle|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L162)|`_socksPortController.dispose();`|
|lifecycle|[L163](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L163)|`_redirPortController.dispose();`|
|lifecycle|[L164](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L164)|`_tProxyPortController.dispose();`|
|lifecycle|[L165](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/general/port_form.dart#L165)|`super.dispose();`|

### FlClash/lib/views/config/icon_sets.dart

用途：page：IconSetsView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/icon_sets.dart#L27)|`void initState() {`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/icon_sets.dart#L28)|`super.initState();`|

### FlClash/lib/views/config/mitm.dart

用途：page：MitmView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L61](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L61)|`_lifecycle = AppLifecycleListener(onResume: _checkTrust);`|
|interaction|[L306](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L306)|`onTap: () => _generateCertificate(`|
|interaction|[L329](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L329)|`onTap: () => _showDetails(context, certificate),`|
|interaction|[L338](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L338)|`onTap: () => _install(context, ref),`|
|interaction|[L342](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L342)|`onTap: () => _export(context, certificate),`|
|interaction|[L346](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L346)|`onTap: () =>`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L58)|`void initState() {`|
|lifecycle|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L59)|`super.initState();`|
|lifecycle|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L66)|`void dispose() {`|
|lifecycle|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L67)|`_lifecycle.dispose();`|
|lifecycle|[L68](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm.dart#L68)|`super.dispose();`|

### FlClash/lib/views/config/mitm_modules.dart

用途：page：MitmTaskRunning, MitmModulesItem, MitmModulesView, MitmModuleView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L462](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm_modules.dart#L462)|`onTap: () => openMitmModuleEditor(context, ref, module: module),`|
|interaction|[L473](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm_modules.dart#L473)|`onTap: isUpdating ? null : () => _updateModule(ref, module),`|
|interaction|[L528](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/mitm_modules.dart#L528)|`onTap: () => _attach(ref, module),`|

### FlClash/lib/views/config/network.dart

用途：page：VPNItem, TUNItem, AllowBypassItem, VpnSystemProxyItem, SystemProxyItem, Ipv6Item, AutoSetSystemDnsItem, DNSHijackingItem, TunStackItem, InterfaceNameModeItem, InterfaceNameItem, BypassPrivateRouteItem, BypassDomainItem, RouteAddressItem, LoopbackItem, TunSection, VpnSections, SystemProxySection, NetworkOptionsSection, NetworkListView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L280](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L280)|`onTap: () {`|
|platform|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L282)|`'"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',`|
|platform|[L388](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L388)|`required this.isDesktop,`|
|platform|[L393](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L393)|`final bool isDesktop;`|
|platform|[L400](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L400)|`if (!isDesktop) {`|
|platform|[L421](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L421)|`List<Widget> outboundItems({required bool isDesktop, required bool isLinux}) {`|
|platform|[L423](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L423)|`if (isDesktop) ...[`|
|platform|[L456](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L456)|`required bool isDesktop,`|
|platform|[L461](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L461)|`if (isDesktop) const TUNItem(),`|
|platform|[L467](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L467)|`if (isDesktop) ...[`|
|platform|[L537](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L537)|`isDesktop: system.isDesktop,`|
|platform|[L541](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L541)|`footer: system.isDesktop ? appLocalizations.tunDesc : null,`|
|platform|[L558](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L558)|`if (system.isDesktop) const SystemProxySection(),`|
|platform|[L561](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L561)|`isDesktop: system.isDesktop,`|
|platform|[L568](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/network.dart#L568)|`isDesktop: system.isDesktop,`|

### FlClash/lib/views/config/on_demand.dart

用途：page：OnDemandView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L157](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/on_demand.dart#L157)|`return ReorderDragStartListener(`|

### FlClash/lib/views/config/override.dart

用途：page：OverrideState, OverrideModel, OverrideTarget, PatchOverrideTarget, ProfileOverrideTarget, OverrideField, ValueOverrideField, ToggleOverrideField, OptionsOverrideField, NumberOverrideField, TextOverrideField, ListOverrideField, OverrideSpec, OverrideQuickEdit, OverrideView, OverrideSection, OverrideEntry。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L484](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/override.dart#L484)|`context.isMobileView`|

### FlClash/lib/views/config/providers.dart

用途：page：ClashProvidersView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L27)|`void initState() {`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L28)|`super.initState();`|
|lifecycle|[L441](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L441)|`void didUpdateWidget(covariant _RuleSetUpdateTime oldWidget) {`|
|lifecycle|[L442](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L442)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L534](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L534)|`void initState() {`|
|lifecycle|[L535](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L535)|`super.initState();`|
|lifecycle|[L541](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L541)|`void dispose() {`|
|lifecycle|[L542](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L542)|`_labelController.dispose();`|
|lifecycle|[L543](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L543)|`_urlController.dispose();`|
|lifecycle|[L544](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/providers.dart#L544)|`super.dispose();`|

### FlClash/lib/views/config/rules.dart

用途：page：AddedRulesView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L160](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/rules.dart#L160)|`itemBuilder: (_, index) => ReorderDragStartListener(`|

### FlClash/lib/views/config/scripts.dart

用途：page：ScriptsView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L384](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/scripts.dart#L384)|`duration: context.motionDuration(commonDuration),`|
|lifecycle|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/scripts.dart#L30)|`void initState() {`|
|lifecycle|[L31](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/config/scripts.dart#L31)|`super.initState();`|

### FlClash/lib/views/connection/requests.dart

用途：page：RequestsView。复用：`packages/flutter/lib/src/records/requests_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L351](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L351)|`Duration get pollInterval => const Duration(seconds: 1);`|
|platform|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L131)|`final pinned = !ViewScope.isMobileOf(context);`|
|lifecycle|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L33)|`with RouteMotionHoldMixin<RequestsView> {`|
|lifecycle|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L42)|`void initState() {`|
|lifecycle|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L43)|`super.initState();`|
|lifecycle|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L56)|`void dispose() {`|
|lifecycle|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L57)|`_recent.dispose();`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L58)|`_live.dispose();`|
|lifecycle|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L59)|`_filters.dispose();`|
|lifecycle|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L60)|`super.dispose();`|
|lifecycle|[L204](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L204)|`void initState() {`|
|lifecycle|[L205](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L205)|`super.initState();`|
|lifecycle|[L220](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L220)|`void dispose() {`|
|lifecycle|[L222](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L222)|`_scrollController.dispose();`|
|lifecycle|[L224](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L224)|`super.dispose();`|
|lifecycle|[L332](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L332)|`WidgetsBindingObserver,`|
|lifecycle|[L334](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L334)|`RouteMotionHoldMixin<_LiveFeed> {`|
|lifecycle|[L344](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L344)|`void initState() {`|
|lifecycle|[L345](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L345)|`super.initState();`|
|lifecycle|[L432](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L432)|`void dispose() {`|
|lifecycle|[L434](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L434)|`_scrollController.dispose();`|
|lifecycle|[L436](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/connection/requests.dart#L436)|`super.dispose();`|

### FlClash/lib/views/dashboard/dashboard.dart

用途：page：DashboardView。复用：`packages/flutter/lib/src/dashboard/dashboard_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L49)|`final platform = widget.platform ?? SupportPlatform.currentPlatform;`|
|platform|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L52)|`final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));`|
|platform|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L54)|`final editable = !DashboardDensity.of(size).isDesktop;`|
|platform|[L86](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L86)|`body: LayoutBuilder(`|
|platform|[L93](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L93)|`child: layout.isDesktop`|
|platform|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L136)|`24 + MediaQuery.paddingOf(context).bottom,`|
|platform|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L143)|`return LayoutBuilder(`|
|platform|[L322](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/dashboard.dart#L322)|`SliverLayoutBuilder(`|

### FlClash/lib/views/dashboard/edit.dart

用途：页面编辑/重排；Dashboard 另含摇摆、移除占位收起与拖动抬升。复用：`packages/flutter/lib/src/dashboard/edit.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L22)|`const _swayLoop = Duration(milliseconds: 3600);`|
|motion|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L27)|`const _roomDuration = Duration(milliseconds: 260);`|
|motion|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L28)|`const _appearDuration = Duration(milliseconds: 200);`|
|motion|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L59)|`with SingleTickerProviderStateMixin {`|
|motion|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L60)|`late final _sway = AnimationController(vsync: this, duration: _swayLoop);`|
|motion|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L214)|`animation: animation,`|
|motion|[L273](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L273)|`with SingleTickerProviderStateMixin {`|
|motion|[L275](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L275)|`late final _controller = AnimationController(`|
|motion|[L284](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L284)|`curve: Interval(0, _roomShare, curve: Curves.easeOutCubic),`|
|motion|[L285](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L285)|`reverseCurve: Interval(0, _roomShare, curve: Curves.easeInCubic),`|
|motion|[L289](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L289)|`curve: Interval(_roomShare, 1, curve: Curves.easeOutCubic),`|
|motion|[L296](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L296)|`_controller.duration = context.motionDuration(`|
|motion|[L384](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L384)|`animation: _controller,`|
|motion|[L490](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L490)|`animation: animation,`|
|motion|[L492](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L492)|`final t = Curves.easeOut.transform(animation.value);`|
|rendering|[L334](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L334)|`if (!mounted  /  /  box is! RenderBox  /  /  !box.hasSize  /  /  position == null) {`|
|interaction|[L368](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L368)|`_room.addListener(follow);`|
|interaction|[L374](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L374)|`_room.removeListener(follow);`|
|interaction|[L430](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L430)|`ReorderDragStartListener(index: index, child: card),`|
|lifecycle|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L73)|`void didChangeDependencies() {`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L74)|`super.didChangeDependencies();`|
|lifecycle|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L83)|`void didUpdateWidget(DashboardEditor oldWidget) {`|
|lifecycle|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L84)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L93](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L93)|`void dispose() {`|
|lifecycle|[L94](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L94)|`_sway.dispose();`|
|lifecycle|[L95](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L95)|`super.dispose();`|
|lifecycle|[L294](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L294)|`void didChangeDependencies() {`|
|lifecycle|[L295](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L295)|`super.didChangeDependencies();`|
|lifecycle|[L306](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L306)|`void didUpdateWidget(_Presence oldWidget) {`|
|lifecycle|[L307](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L307)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L314](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L314)|`void dispose() {`|
|lifecycle|[L316](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L316)|`_room.dispose();`|
|lifecycle|[L317](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L317)|`_appear.dispose();`|
|lifecycle|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L318)|`_controller.dispose();`|
|lifecycle|[L319](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/edit.dart#L319)|`super.dispose();`|

### FlClash/lib/views/dashboard/layout.dart

用途：尺寸断点、列数与布局密度。复用：`packages/flutter/lib/src/dashboard/layout.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/layout.dart#L23)|`bool get isDesktop => this != mobile;`|

### FlClash/lib/views/dashboard/probe_start_hold.dart

用途：page：ProbeStartHold。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L9](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/probe_start_hold.dart#L9)|`static const _duration = Duration(seconds: 5);`|
|lifecycle|[L19](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/probe_start_hold.dart#L19)|`void initState() {`|
|lifecycle|[L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/probe_start_hold.dart#L20)|`super.initState();`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/probe_start_hold.dart#L28)|`void dispose() {`|
|lifecycle|[L30](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/probe_start_hold.dart#L30)|`super.dispose();`|

### FlClash/lib/views/dashboard/widgets/card.dart

用途：page：DashboardCard, DashboardCardHeader, DashboardFitText, DashboardCappedRow, DashboardConnectedGroup, DashboardConnectedButton, DashboardChipTone, DashboardChip, DashboardBlock, ShapeBadge, ShapePainter, DashboardSwitch, DashboardSwitchRow, DashboardFadeOut, DashboardIconButton。复用：`packages/flutter/lib/src/dashboard/card.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L251](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L251)|`const _connectedSelectDuration = Duration(milliseconds: 240);`|
|motion|[L395](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L395)|`tween: Tween(end: selected ? 1 : 0),`|
|motion|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L396)|`duration: context.motionDuration(_connectedSelectDuration),`|
|motion|[L397](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L397)|`curve: Curves.easeOutCubic,`|
|motion|[L729](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L729)|`duration: context.motionDuration(commonDuration),`|
|rendering|[L310](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L310)|`RenderBox? _raised;`|
|rendering|[L339](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L339)|`void paint(RenderBox child) => context.paintChild(`|
|rendering|[L574](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L574)|`class ShapePainter extends CustomPainter {`|
|rendering|[L595](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L595)|`..drawPath(path, Paint()..color = color);`|
|rendering|[L619](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L619)|`..drawPath(path, side.toPaint()..strokeWidth = side.width / extent / scale)`|
|interaction|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L37)|`this.onTap,`|
|interaction|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L45)|`final VoidCallback? onTap;`|
|interaction|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L64)|`final onTap = this.onTap;`|
|interaction|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L75)|`child: onTap == null`|
|interaction|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L80)|`onPressed: onTap,`|
|interaction|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L85)|`if (onTap != null) {`|
|interaction|[L366](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L366)|`required this.onTap,`|
|interaction|[L377](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L377)|`final VoidCallback onTap;`|
|interaction|[L419](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L419)|`onTap: onTap,`|
|interaction|[L496](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L496)|`this.onTap,`|
|interaction|[L504](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L504)|`final VoidCallback? onTap;`|
|interaction|[L513](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L513)|`final onTap = this.onTap;`|
|interaction|[L514](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L514)|`if (onTap == null) {`|
|interaction|[L523](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L523)|`onPressed: onTap,`|
|interaction|[L670](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L670)|`this.onTap,`|
|interaction|[L683](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L683)|`final VoidCallback? onTap;`|
|interaction|[L722](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L722)|`onTap: onTap,`|
|platform|[L29](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L29)|`double dashboardCardRadius(DashboardDensity density) => density.isDesktop`|
|platform|[L115](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L115)|`final mobile = !DashboardDensityScope.of(context).isDesktop;`|
|platform|[L181](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L181)|`return LayoutBuilder(`|
|platform|[L225](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/card.dart#L225)|`return LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/connection_stats.dart

用途：page：ConnectionStatsCard。复用：`packages/flutter/lib/src/dashboard/connection_stats.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connection_stats.dart#L24)|`WidgetsBindingObserver,`|
|lifecycle|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connection_stats.dart#L26)|`RouteMotionHoldMixin<ConnectionStatsCard>,`|

### FlClash/lib/views/dashboard/widgets/connections_table.dart

用途：page：DashboardFeed, ConnectionsPolling, ThrottledCount, ConnectionsTableCard。复用：`packages/flutter/lib/src/dashboard/connections_table.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L101)|`Duration get pollInterval => Duration(seconds: pollsConnections ? 1 : 2);`|
|interaction|[L313](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L313)|`onTap: () => _select(feed),`|
|interaction|[L584](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L584)|`onTap: column.sortKey == null`|
|platform|[L330](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L330)|`child: LayoutBuilder(`|
|platform|[L504](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L504)|`return LayoutBuilder(`|
|lifecycle|[L88](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L88)|`WidgetsBindingObserver,`|
|lifecycle|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L90)|`RouteMotionHoldMixin<T> {`|
|lifecycle|[L104](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L104)|`void dispose() {`|
|lifecycle|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L105)|`connectionCount.dispose();`|
|lifecycle|[L106](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L106)|`super.dispose();`|
|lifecycle|[L177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L177)|`void initState() {`|
|lifecycle|[L178](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L178)|`super.initState();`|
|lifecycle|[L210](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L210)|`void dispose() {`|
|lifecycle|[L212](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L212)|`super.dispose();`|
|lifecycle|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L229)|`WidgetsBindingObserver,`|
|lifecycle|[L231](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L231)|`RouteMotionHoldMixin<ConnectionsTableCard>,`|
|lifecycle|[L242](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L242)|`void initState() {`|
|lifecycle|[L243](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L243)|`super.initState();`|
|lifecycle|[L256](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L256)|`void dispose() {`|
|lifecycle|[L258](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/connections_table.dart#L258)|`super.dispose();`|

### FlClash/lib/views/dashboard/widgets/core_status_button.dart

用途：page：CoreStatusButton。复用：`packages/flutter/lib/src/dashboard/core_status_button.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L21](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L21)|`static const _holdDuration = Duration(milliseconds: 600);`|
|platform|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L105)|`coreStatus == CoreStatus.connected  /  /  ViewScope.isMobileOf(context);`|
|lifecycle|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L27)|`void initState() {`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L28)|`super.initState();`|
|lifecycle|[L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L36)|`void dispose() {`|
|lifecycle|[L38](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart#L38)|`super.dispose();`|

### FlClash/lib/views/dashboard/widgets/current_outbound.dart

用途：1500ms 旋转、450ms 形变、150ms 状态切换及运行按钮。复用：`packages/flutter/lib/src/dashboard/current_outbound.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L100](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L100)|`tween: Tween(end: rootAccess ? 1 : 0),`|
|motion|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L101)|`duration: context.motionDuration(commonDuration),`|
|motion|[L130](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L130)|`tween: Tween(end: isStart ? 1 : 0),`|
|motion|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L131)|`duration: context.motionDuration(_morphDuration),`|
|motion|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L132)|`curve: Curves.easeOutBack,`|
|motion|[L466](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L466)|`const _spinPeriod = Duration(milliseconds: 1500);`|
|motion|[L490](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L490)|`with SingleTickerProviderStateMixin {`|
|motion|[L491](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L491)|`late final AnimationController _turns = AnimationController(`|
|motion|[L526](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L526)|`_turns.animateTo(rest, duration: _spinPeriod * (rest - _turns.value));`|
|motion|[L557](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L557)|`animation: _turns,`|
|motion|[L695](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L695)|`const _morphDuration = Duration(milliseconds: 450);`|
|motion|[L696](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L696)|`const _stateDuration = Duration(milliseconds: 150);`|
|motion|[L724](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L724)|`with SingleTickerProviderStateMixin {`|
|motion|[L725](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L725)|`late final AnimationController _controller = AnimationController(`|
|motion|[L732](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L732)|`curve: Curves.easeOutBack,`|
|motion|[L733](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L733)|`reverseCurve: Curves.easeInCubic,`|
|motion|[L784](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L784)|`final stateDuration = context.motionDuration(_stateDuration);`|
|motion|[L799](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L799)|`tween: Tween(end: _overlay),`|
|motion|[L802](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L802)|`animation: _progress,`|
|motion|[L843](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L843)|`tween: Tween(end: widget.running ? 1 : 0),`|
|motion|[L845](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L845)|`curve: Curves.easeOutBack,`|
|rendering|[L865](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L865)|`class _MorphPainter extends CustomPainter {`|
|rendering|[L906](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L906)|`..drawPath(`|
|rendering|[L918](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L918)|`canvas.drawPath(path, Paint()..color = color);`|
|interaction|[L332](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L332)|`onTap: () => showIpQualitySheet(context, ip: info.ip),`|
|interaction|[L551](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L551)|`onTap: enabled ? widget.onRefresh : null,`|
|interaction|[L552](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L552)|`onHover: (value) => setState(() => _hovered = value),`|
|interaction|[L792](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L792)|`onTap: enabled ? _toggle : null,`|
|interaction|[L793](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L793)|`onHover: (value) => setState(() => _hovered = value),`|
|platform|[L187](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L187)|`large: !density.isDesktop,`|
|platform|[L189](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L189)|`if (density.isDesktop)`|
|lifecycle|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L49)|`void initState() {`|
|lifecycle|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L50)|`super.initState();`|
|lifecycle|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L55)|`void dispose() {`|
|lifecycle|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L57)|`super.dispose();`|
|lifecycle|[L499](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L499)|`void didChangeDependencies() {`|
|lifecycle|[L500](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L500)|`super.didChangeDependencies();`|
|lifecycle|[L505](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L505)|`void didUpdateWidget(_CountryBadge oldWidget) {`|
|lifecycle|[L506](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L506)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L513](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L513)|`void dispose() {`|
|lifecycle|[L514](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L514)|`_turns.dispose();`|
|lifecycle|[L515](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L515)|`super.dispose();`|
|lifecycle|[L750](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L750)|`void didUpdateWidget(_StartToggle oldWidget) {`|
|lifecycle|[L751](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L751)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L758](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L758)|`void dispose() {`|
|lifecycle|[L759](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L759)|`_progress.dispose();`|
|lifecycle|[L760](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L760)|`_controller.dispose();`|
|lifecycle|[L761](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/current_outbound.dart#L761)|`super.dispose();`|

### FlClash/lib/views/dashboard/widgets/intranet_ip.dart

用途：page：IntranetIpCard。复用：`packages/flutter/lib/src/dashboard/intranet_ip.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L140](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/intranet_ip.dart#L140)|`onTap: () => change(!allowLan),`|
|platform|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/intranet_ip.dart#L37)|`final mobile = !density.isDesktop;`|
|platform|[L117](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/intranet_ip.dart#L117)|`LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/memory_info.dart

用途：独立详情生命周期、2 秒轮询、内存占比插值、展开交叉淡入与释放反馈。复用：`packages/flutter/lib/src/dashboard/memory_info.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L105)|`Duration get pollInterval => const Duration(seconds: 2);`|
|motion|[L296](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L296)|`static const _minReleaseFeedback = Duration(milliseconds: 500);`|
|motion|[L302](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L302)|`Duration get pollInterval => const Duration(seconds: 2);`|
|motion|[L482](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L482)|`duration: context.motionDuration(commonDuration),`|
|motion|[L572](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L572)|`final duration = context.motionDuration(commonDuration);`|
|motion|[L602](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L602)|`tween: Tween(`|
|interaction|[L159](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L159)|`onTap: mobile ? _showDetail : null,`|
|platform|[L151](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L151)|`final mobile = !density.isDesktop;`|
|platform|[L206](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L206)|`final mobile = !density.isDesktop;`|
|lifecycle|[L98](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L98)|`with WidgetsBindingObserver, ActivePollingMixin<MemoryInfo> {`|
|lifecycle|[L111](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L111)|`void dispose() {`|
|lifecycle|[L112](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L112)|`_memoryStateNotifier.dispose();`|
|lifecycle|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L113)|`super.dispose();`|
|lifecycle|[L295](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/memory_info.dart#L295)|`with WidgetsBindingObserver, ActivePollingMixin<MemoryDetailSheet> {`|

### FlClash/lib/views/dashboard/widgets/network_takeover.dart

用途：系统代理/TUN/VPN 的卡片与磁贴变体、尺寸感知图标及形状反馈。复用：`packages/flutter/lib/src/dashboard/network_takeover.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L103](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/network_takeover.dart#L103)|`onTap: () => change(!value),`|
|interaction|[L225](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/network_takeover.dart#L225)|`onTap: () => _setVpn(ref, !enabled),`|
|interaction|[L251](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/network_takeover.dart#L251)|`onTap: () => change(!enabled),`|
|platform|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/network_takeover.dart#L133)|`LayoutBuilder(`|
|platform|[L175](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/network_takeover.dart#L175)|`child: LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/outbound_mode.dart

用途：page：OutboundModeCard, OutboundModeBar。复用：`packages/flutter/lib/src/dashboard/outbound_mode.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/outbound_mode.dart#L57)|`onTap: () => _changeMode(ref, item),`|
|interaction|[L144](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/outbound_mode.dart#L144)|`onTap: () => _changeMode(ref, item),`|
|platform|[L112](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/outbound_mode.dart#L112)|`child: LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/profile_detail.dart

用途：page：ProfileStats, ConfigCountsWatch, ProfileDetailSheet。复用：`packages/flutter/lib/src/dashboard/profile_detail.dart`。状态：部分提取：完整详情与统计网格/信息行；文件计数、数据库、更新/预览和外部 Provider 表由宿主负责。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L99](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profile_detail.dart#L99)|`void initState() {`|
|lifecycle|[L100](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profile_detail.dart#L100)|`super.initState();`|

### FlClash/lib/views/dashboard/widgets/profiles.dart

用途：page：ProfilesCard。复用：`packages/flutter/lib/src/dashboard/profiles.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L387](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L387)|`class _WavyProgressPainter extends CustomPainter {`|
|rendering|[L422](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L422)|`canvas.drawPath(wave, paint..color = active);`|
|interaction|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L137)|`onTap: mobile  /  /  profile == null`|
|platform|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L75)|`final mobile = !density.isDesktop;`|
|platform|[L176](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L176)|`LayoutBuilder(`|
|platform|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L282)|`return LayoutBuilder(`|
|platform|[L321](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/profiles.dart#L321)|`LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/proxy_groups.dart

用途：page：ProxyGroupsCard, ProxyGroupsSummaryCard。复用：`packages/flutter/lib/src/dashboard/proxy_groups.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L455](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L455)|`onTap: () =>`|
|interaction|[L469](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L469)|`required this.onTap,`|
|interaction|[L474](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L474)|`final VoidCallback onTap;`|
|interaction|[L481](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L481)|`onTap: onTap,`|
|interaction|[L541](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L541)|`onTap: groups.isEmpty ? null : () => showProxiesSheet(context),`|
|platform|[L216](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L216)|`if (!density.isDesktop) {`|
|platform|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L228)|`child: LayoutBuilder(`|
|platform|[L280](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L280)|`final mobile = !DashboardDensityScope.of(context).isDesktop;`|
|platform|[L438](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L438)|`return LayoutBuilder(`|
|platform|[L525](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/proxy_groups.dart#L525)|`if (density.isDesktop) {`|

### FlClash/lib/views/dashboard/widgets/service_status.dart

用途：服务网格/磁贴、圆角镂空状态点、延迟/失败/加载语义；探测由宿主提供。复用：`packages/flutter/lib/src/dashboard/service_status.dart`。状态：部分提取：ServiceStatusCard/Grid/Cell/Badge 与画笔；数据回调解耦；详情/管理及网络仍在源树；Badge 来自同文件 533–642 行。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L589](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L589)|`class _BadgePainter extends CustomPainter {`|
|rendering|[L613](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L613)|`canvas.drawRSuperellipse(tile, Paint()..color = color);`|
|rendering|[L620](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L620)|`..drawPath(`|
|rendering|[L623](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L623)|`Path()..addRSuperellipse(tile),`|
|interaction|[L222](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L222)|`onTap: mobile ? openSheet : null,`|
|interaction|[L507](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L507)|`onTap: () => showIpQualitySheet(context, ip: ip.ip),`|
|interaction|[L803](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L803)|`return ReorderDragStartListener(`|
|platform|[L174](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L174)|`final mobile = !density.isDesktop;`|
|platform|[L874](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L874)|`return LayoutBuilder(`|
|lifecycle|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L137)|`void initState() {`|
|lifecycle|[L138](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L138)|`super.initState();`|
|lifecycle|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L143)|`void dispose() {`|
|lifecycle|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L147)|`super.dispose();`|
|lifecycle|[L432](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L432)|`void initState() {`|
|lifecycle|[L433](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L433)|`super.initState();`|
|lifecycle|[L438](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L438)|`void dispose() {`|
|lifecycle|[L440](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/service_status.dart#L440)|`super.dispose();`|

### FlClash/lib/views/dashboard/widgets/traffic.dart

用途：page：TrafficDirection, SpeedCard, NetworkSpeedCard。复用：`packages/flutter/lib/src/dashboard/traffic.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L260](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/traffic.dart#L260)|`return LayoutBuilder(`|

### FlClash/lib/views/dashboard/widgets/update_status.dart

用途：page：UpdateStatusSlot, UpdateStatusButton。复用：`packages/flutter/lib/src/dashboard/update_status.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L42)|`with SingleTickerProviderStateMixin {`|
|motion|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L43)|`late final AnimationController _controller;`|
|motion|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L51)|`_controller = AnimationController(`|
|motion|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L56)|`_curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);`|
|motion|[L95](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L95)|`animation: _curve,`|
|interaction|[L123](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L123)|`onTap: ready ? () => unawaited(action.installUpdate()) : null,`|
|lifecycle|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L48)|`void initState() {`|
|lifecycle|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L49)|`super.initState();`|
|lifecycle|[L61](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L61)|`void dispose() {`|
|lifecycle|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L62)|`_curve.dispose();`|
|lifecycle|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L63)|`_controller.dispose();`|
|lifecycle|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/update_status.dart#L64)|`super.dispose();`|

### FlClash/lib/views/developer.dart

用途：page：DeveloperView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L24)|`onTap: () {`|
|interaction|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L35)|`onTap: () {`|
|interaction|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L50)|`onTap: () async {`|
|interaction|[L65](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L65)|`onTap: () {`|
|interaction|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L74)|`onTap: () async {`|
|interaction|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/developer.dart#L89)|`onTap: () async {`|

### FlClash/lib/views/disclaimer.dart

用途：page：DisclaimerView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/disclaimer.dart#L89)|`if (ref.watch(isMobileViewProvider)) {`|
|lifecycle|[L399](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/disclaimer.dart#L399)|`void dispose() {`|
|lifecycle|[L400](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/disclaimer.dart#L400)|`_controller.dispose();`|
|lifecycle|[L401](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/disclaimer.dart#L401)|`super.dispose();`|

### FlClash/lib/views/dns_queries.dart

用途：page：DnsQueryListController, DnsQueriesView, DnsQueryItem, DnsQueryDetailView。复用：`packages/flutter/lib/src/records/dns_queries_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L366](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L366)|`onTap: () => _showDnsQueryDetail(context, dnsQuery),`|
|interaction|[L383](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L383)|`onTap: () => _showDnsQueryDetail(context, dnsQuery),`|
|platform|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L136)|`final pinned = !ViewScope.isMobileOf(context);`|
|lifecycle|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L53)|`with RouteMotionHoldMixin<DnsQueriesView> {`|
|lifecycle|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L62)|`void initState() {`|
|lifecycle|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L63)|`super.initState();`|
|lifecycle|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L77)|`void dispose() {`|
|lifecycle|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L78)|`_listController.dispose();`|
|lifecycle|[L79](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L79)|`_filters.dispose();`|
|lifecycle|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L81)|`_scrollController.dispose();`|
|lifecycle|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dns_queries.dart#L83)|`super.dispose();`|

### FlClash/lib/views/font_family.dart

用途：page：FontFamilyView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L44)|`void initState() {`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L45)|`super.initState();`|
|lifecycle|[L127](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L127)|`void initState() {`|
|lifecycle|[L128](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L128)|`super.initState();`|
|lifecycle|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L133)|`void didUpdateWidget(_FontLabel oldWidget) {`|
|lifecycle|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L134)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L141](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L141)|`void dispose() {`|
|lifecycle|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/font_family.dart#L143)|`super.dispose();`|

### FlClash/lib/views/hotkey.dart

用途：page：HotKeyView, HotKeyRecorder。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L478](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/hotkey.dart#L478)|`onKeyEvent: (_, _) {`|
|lifecycle|[L314](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/hotkey.dart#L314)|`void initState() {`|
|lifecycle|[L315](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/hotkey.dart#L315)|`super.initState();`|
|lifecycle|[L326](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/hotkey.dart#L326)|`void dispose() {`|
|lifecycle|[L332](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/hotkey.dart#L332)|`super.dispose();`|

### FlClash/lib/views/logs.dart

用途：page：LogListController, LogsView, LogItem。复用：`packages/flutter/lib/src/records/logs_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L216](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L216)|`onTap: () {},`|
|platform|[L125](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L125)|`final pinned = !ViewScope.isMobileOf(context);`|
|lifecycle|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L48)|`with RouteMotionHoldMixin<LogsView> {`|
|lifecycle|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L57)|`void initState() {`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L58)|`super.initState();`|
|lifecycle|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L80)|`void dispose() {`|
|lifecycle|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L81)|`_listController.dispose();`|
|lifecycle|[L82](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L82)|`_filters.dispose();`|
|lifecycle|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L83)|`_scrollController.dispose();`|
|lifecycle|[L84](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/logs.dart#L84)|`super.dispose();`|

### FlClash/lib/views/profiles/add.dart

用途：page：AddProfileMenu。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/add.dart#L26)|`if (system.isDesktop) {`|
|lifecycle|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/add.dart#L179)|`void initState() {`|
|lifecycle|[L180](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/add.dart#L180)|`super.initState();`|
|lifecycle|[L208](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/add.dart#L208)|`void dispose() {`|
|lifecycle|[L210](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/add.dart#L210)|`super.dispose();`|

### FlClash/lib/views/profiles/custom/custom.dart

用途：page：CustomProfileView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L72)|`onTap: () => _push(context, view),`|
|platform|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L96)|`late final _overview = _Overview(showsTun: system.isDesktop);`|
|lifecycle|[L108](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L108)|`void initState() {`|
|lifecycle|[L109](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L109)|`super.initState();`|
|lifecycle|[L382](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L382)|`void dispose() {`|
|lifecycle|[L394](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom.dart#L394)|`super.dispose();`|

### FlClash/lib/views/profiles/custom/custom_proxies.dart

用途：page：on, CustomProxiesView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L809](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L809)|`static const _validateDelay = Duration(milliseconds: 400);`|
|interaction|[L415](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L415)|`return ReorderDragStartListener(index: dragIndex, child: item);`|
|lifecycle|[L213](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L213)|`void initState() {`|
|lifecycle|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L214)|`super.initState();`|
|lifecycle|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L228)|`void dispose() {`|
|lifecycle|[L232](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L232)|`super.dispose();`|
|lifecycle|[L650](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L650)|`void initState() {`|
|lifecycle|[L651](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L651)|`super.initState();`|
|lifecycle|[L656](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L656)|`void dispose() {`|
|lifecycle|[L657](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L657)|`_controller.dispose();`|
|lifecycle|[L658](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L658)|`super.dispose();`|
|lifecycle|[L828](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L828)|`void initState() {`|
|lifecycle|[L829](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L829)|`super.initState();`|
|lifecycle|[L849](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L849)|`void dispose() {`|
|lifecycle|[L851](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/custom_proxies.dart#L851)|`super.dispose();`|

### FlClash/lib/views/profiles/custom/groups.dart

用途：page：CustomProxyGroupsSection, EditProxyGroupView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L537](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/groups.dart#L537)|`static const _validateDelay = Duration(milliseconds: 400);`|
|lifecycle|[L552](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/groups.dart#L552)|`void initState() {`|
|lifecycle|[L553](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/groups.dart#L553)|`super.initState();`|
|lifecycle|[L572](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/groups.dart#L572)|`void dispose() {`|
|lifecycle|[L575](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/groups.dart#L575)|`super.dispose();`|

### FlClash/lib/views/profiles/custom/icon.dart

用途：16 MiB 图标缓存、192 px 解码、加载回退、monogram 与原生包图标异步代次。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L540](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/icon.dart#L540)|`child: GestureDetector(`|
|interaction|[L541](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/icon.dart#L541)|`onTap: onPressed,`|
|lifecycle|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/icon.dart#L78)|`void initState() {`|
|lifecycle|[L79](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/icon.dart#L79)|`super.initState();`|

### FlClash/lib/views/profiles/custom/members.dart

用途：page：ProxyGroupMembersSliver, ProxyProviderFiltersSliver。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L363](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L363)|`with TickerProviderStateMixin {`|
|motion|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L396)|`context.motionDuration(commonDuration),`|
|motion|[L499](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L499)|`animation: _transitions.animationOf(member),`|
|rendering|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L197)|`_MemberKind.filter => group.copyWith(filter: joinFilterParts(names)),`|
|rendering|[L305](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L305)|`_ => options.copyWith(filter: joinFilterParts(names)),`|
|interaction|[L503](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L503)|`builder: (_) => ReorderDragStartListener(`|
|lifecycle|[L375](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L375)|`void initState() {`|
|lifecycle|[L376](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L376)|`super.initState();`|
|lifecycle|[L384](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L384)|`void dispose() {`|
|lifecycle|[L385](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L385)|`_transitions.dispose();`|
|lifecycle|[L386](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/members.dart#L386)|`super.dispose();`|

### FlClash/lib/views/profiles/custom/providers.dart

用途：page：CustomProvidersView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L178](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L178)|`void initState() {`|
|lifecycle|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L179)|`super.initState();`|
|lifecycle|[L184](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L184)|`void didUpdateWidget(_RuleProviderItem oldWidget) {`|
|lifecycle|[L185](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L185)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L318)|`void initState() {`|
|lifecycle|[L319](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/providers.dart#L319)|`super.initState();`|

### FlClash/lib/views/profiles/custom/rules.dart

用途：page：CustomRulesView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L195](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/rules.dart#L195)|`void initState() {`|
|lifecycle|[L196](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/custom/rules.dart#L196)|`super.initState();`|

### FlClash/lib/views/profiles/edit.dart

用途：页面编辑/重排；Dashboard 另含摇摆、移除占位收起与拖动抬升。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L136)|`? Duration(minutes: interval)`|
|interaction|[L347](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L347)|`return FocusTraversalGroup(`|
|interaction|[L349](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L349)|`child: PageFocusScope(`|
|lifecycle|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L43)|`void initState() {`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L44)|`super.initState();`|
|lifecycle|[L289](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L289)|`void dispose() {`|
|lifecycle|[L290](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L290)|`_labelController.dispose();`|
|lifecycle|[L291](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L291)|`_urlController.dispose();`|
|lifecycle|[L292](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L292)|`_ageSecretKeyController.dispose();`|
|lifecycle|[L293](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L293)|`_fileInfoNotifier.dispose();`|
|lifecycle|[L294](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L294)|`_autoUpdateDurationController.dispose();`|
|lifecycle|[L295](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/edit.dart#L295)|`super.dispose();`|

### FlClash/lib/views/profiles/extend/extend.dart

用途：page：ExtendView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/extend.dart#L17)|`const _minApplyingDuration = Duration(milliseconds: 600);`|
|lifecycle|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/extend.dart#L35)|`void initState() {`|
|lifecycle|[L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/extend.dart#L36)|`super.initState();`|
|lifecycle|[L145](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/extend.dart#L145)|`void dispose() {`|
|lifecycle|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/extend.dart#L147)|`super.dispose();`|

### FlClash/lib/views/profiles/extend/standard.dart

用途：page：StandardContent。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/standard.dart#L96)|`return ReorderDragStartListener(`|
|lifecycle|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/standard.dart#L85)|`void didChangeDependencies() {`|
|lifecycle|[L86](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/extend/standard.dart#L86)|`super.didChangeDependencies();`|

### FlClash/lib/views/profiles/profiles.dart

用途：page：ProfilesView, ProfileItem, ReorderableProfilesSheet。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L344](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L344)|`duration: context.motionDuration(commonDuration),`|
|interaction|[L619](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L619)|`return ReorderDragStartListener(`|
|lifecycle|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L171)|`void initState() {`|
|lifecycle|[L172](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L172)|`super.initState();`|
|lifecycle|[L177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L177)|`void didChangeDependencies() {`|
|lifecycle|[L178](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L178)|`super.didChangeDependencies();`|
|lifecycle|[L181](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L181)|`!PageActivityScope.isActiveOf(context)) {`|
|lifecycle|[L189](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L189)|`void dispose() {`|
|lifecycle|[L190](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L190)|`_controller.dispose();`|
|lifecycle|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L191)|`super.dispose();`|
|lifecycle|[L611](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L611)|`void initState() {`|
|lifecycle|[L612](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/profiles/profiles.dart#L612)|`super.initState();`|

### FlClash/lib/views/proxies/card.dart

用途：page：ProxyCard。复用：`packages/flutter/lib/src/proxies/card.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L274](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L274)|`final FocusNode _focusNode = SkipTraversalFocusNode();`|
|interaction|[L280](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L280)|`_focusNode.addListener(_handleFocusChange);`|
|interaction|[L285](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L285)|`_focusNode.removeListener(_handleFocusChange);`|
|interaction|[L375](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L375)|`child: GestureDetector(`|
|interaction|[L377](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L377)|`onTap: _handleTestCurrentDelay,`|
|interaction|[L386](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L386)|`: GestureDetector(`|
|interaction|[L387](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L387)|`onTap: _handleTestCurrentDelay,`|
|lifecycle|[L278](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L278)|`void initState() {`|
|lifecycle|[L279](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L279)|`super.initState();`|
|lifecycle|[L284](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L284)|`void dispose() {`|
|lifecycle|[L286](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L286)|`_focusNode.dispose();`|
|lifecycle|[L287](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/card.dart#L287)|`super.dispose();`|

### FlClash/lib/views/proxies/common.dart

用途：page：GroupOffsets。复用：`packages/flutter/lib/src/proxies/common.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/common.dart#L75)|`controller.animateTo(`|
|motion|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/common.dart#L77)|`duration: const Duration(milliseconds: 300),`|
|motion|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/common.dart#L78)|`curve: Curves.easeOutCubic,`|

### FlClash/lib/views/proxies/group_tabs.dart

用途：page：GroupTabs。复用：`packages/flutter/lib/src/proxies/group_tabs.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L103](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L103)|`position.animateTo(`|
|motion|[L106](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L106)|`curve: Curves.easeOutCubic,`|
|motion|[L112](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L112)|`widget.controller.animateTo(index);`|
|interaction|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L48)|`oldWidget.controller.animation?.removeListener(_handleAnimation);`|
|interaction|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L55)|`widget.controller.animation?.removeListener(_handleAnimation);`|
|interaction|[L65](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L65)|`controller.animation!.addListener(_handleAnimation);`|
|interaction|[L354](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L354)|`widget.selected.addListener(_handleSelected);`|
|interaction|[L361](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L361)|`oldWidget.selected.removeListener(_handleSelected);`|
|interaction|[L362](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L362)|`widget.selected.addListener(_handleSelected);`|
|interaction|[L369](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L369)|`widget.selected.removeListener(_handleSelected);`|
|platform|[L275](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L275)|`MediaQuery.boldTextOf(context),`|
|platform|[L276](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L276)|`MediaQuery.textScalerOf(context),`|
|lifecycle|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L39)|`void initState() {`|
|lifecycle|[L40](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L40)|`super.initState();`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L45)|`void didUpdateWidget(GroupTabs oldWidget) {`|
|lifecycle|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L46)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L54)|`void dispose() {`|
|lifecycle|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L56)|`_scrollController.dispose();`|
|lifecycle|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L57)|`_hasMore.dispose();`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L58)|`_fade.dispose();`|
|lifecycle|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L59)|`_selected.dispose();`|
|lifecycle|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L60)|`super.dispose();`|
|lifecycle|[L351](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L351)|`void initState() {`|
|lifecycle|[L352](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L352)|`super.initState();`|
|lifecycle|[L358](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L358)|`void didUpdateWidget(_GroupTab oldWidget) {`|
|lifecycle|[L359](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L359)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L368](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L368)|`void dispose() {`|
|lifecycle|[L370](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/group_tabs.dart#L370)|`super.dispose();`|

### FlClash/lib/views/proxies/list.dart

用途：page：ProxiesListView, ListHeader。复用：`packages/flutter/lib/src/proxies/list.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L308](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L308)|`with SingleTickerProviderStateMixin {`|
|motion|[L311](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L311)|`late final _controller = AnimationController(`|
|motion|[L335](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L335)|`_controller.duration = context.motionDuration(`|
|motion|[L424](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L424)|`animation: _unfold,`|
|interaction|[L320](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L320)|`_controller.addStatusListener((_) => setState(() {}));`|
|platform|[L404](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L404)|`MediaQuery.sizeOf(context).height / extent,`|
|platform|[L521](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L521)|`return SliverLayoutBuilder(`|
|platform|[L704](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L704)|`ProxiesIconStyle.filled => LayoutBuilder(`|
|platform|[L739](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L739)|`child: LayoutBuilder(`|
|lifecycle|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L37)|`void initState() {`|
|lifecycle|[L38](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L38)|`super.initState();`|
|lifecycle|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L43)|`void dispose() {`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L44)|`_controller.dispose();`|
|lifecycle|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L45)|`super.dispose();`|
|lifecycle|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L318)|`void initState() {`|
|lifecycle|[L319](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L319)|`super.initState();`|
|lifecycle|[L328](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L328)|`void dispose() {`|
|lifecycle|[L329](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L329)|`_unfold.dispose();`|
|lifecycle|[L330](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L330)|`_controller.dispose();`|
|lifecycle|[L331](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L331)|`super.dispose();`|
|lifecycle|[L342](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L342)|`void didUpdateWidget(_GroupSliver oldWidget) {`|
|lifecycle|[L343](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/list.dart#L343)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/views/proxies/providers.dart

用途：page：ExternalProvidersSliver, ProviderItem。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L320](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/providers.dart#L320)|`duration: context.motionDuration(commonDuration),`|
|lifecycle|[L119](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/providers.dart#L119)|`void initState() {`|
|lifecycle|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/providers.dart#L120)|`super.initState();`|
|lifecycle|[L125](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/providers.dart#L125)|`void didUpdateWidget(covariant ProviderItem oldWidget) {`|
|lifecycle|[L126](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/providers.dart#L126)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/views/proxies/proxies.dart

用途：page：ProxiesView。复用：`packages/flutter/lib/src/proxies/proxies.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/proxies.dart#L136)|`void initState() {`|
|lifecycle|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/proxies.dart#L137)|`super.initState();`|

### FlClash/lib/views/proxies/tab.dart

用途：page：ProxiesTabView, ProxiesTabViewState, ProxyGroupView。复用：`packages/flutter/lib/src/proxies/tab.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L26)|`with TickerProviderStateMixin {`|
|interaction|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L120)|`void _tabControllerListener([int? index]) {`|
|interaction|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L136)|`_tabController?.removeListener(_tabControllerListener);`|
|interaction|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L155)|`_tabControllerListener(realIndex);`|
|interaction|[L156](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L156)|`controller.addListener(_tabControllerListener);`|
|lifecycle|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L32)|`void initState() {`|
|lifecycle|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L33)|`super.initState();`|
|lifecycle|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L48)|`void dispose() {`|
|lifecycle|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L51)|`controller.dispose();`|
|lifecycle|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L53)|`super.dispose();`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L74)|`(_) => entry.value.dispose(),`|
|lifecycle|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/proxies/tab.dart#L137)|`_tabController?.dispose();`|

### FlClash/lib/views/resources.dart

用途：page：ResourcesView, UpdateGeoUrlFormDialog。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L342](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L342)|`duration: context.motionDuration(commonDuration),`|
|interaction|[L223](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L223)|`onTap: _updateInterval,`|
|lifecycle|[L47](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L47)|`void initState() {`|
|lifecycle|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L48)|`super.initState();`|
|lifecycle|[L406](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L406)|`void initState() {`|
|lifecycle|[L407](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L407)|`super.initState();`|
|lifecycle|[L414](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L414)|`void didUpdateWidget(covariant _FileInfoBuilder oldWidget) {`|
|lifecycle|[L415](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/resources.dart#L415)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/views/theme.dart

用途：page：ThemeView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L398](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L398)|`static const _duration = Duration(milliseconds: 200);`|
|motion|[L461](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L461)|`curve: Curves.easeOutBack,`|
|motion|[L940](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L940)|`duration: const Duration(milliseconds: 200),`|
|motion|[L941](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L941)|`curve: Curves.easeOutCubic,`|
|interaction|[L827](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L827)|`Widget card(VoidCallback onTap) => PressSurface(`|
|interaction|[L832](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L832)|`onPressed: onTap,`|
|platform|[L335](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L335)|`child: LayoutBuilder(`|
|platform|[L843](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L843)|`child: context.isMobileView`|
|platform|[L943](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L943)|`child: MediaQuery(`|
|platform|[L944](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L944)|`data: MediaQuery.of(`|
|platform|[L992](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L992)|`MediaQuery.withNoTextScaling(`|
|platform|[L1102](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L1102)|`final gestureInsets = MediaQuery.systemGestureInsetsOf(context);`|
|lifecycle|[L1093](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L1093)|`void dispose() {`|
|lifecycle|[L1094](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L1094)|`_controller.dispose();`|
|lifecycle|[L1095](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme.dart#L1095)|`super.dispose();`|

### FlClash/lib/views/theme_preview.dart

用途：主题预览插值、滑动淡入、迷你双栏屏幕。复用：`packages/flutter/lib/src/theme_preview.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L98](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L98)|`class _ColorSchemeTween extends Tween<ColorScheme> {`|
|motion|[L99](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L99)|`_ColorSchemeTween({super.end});`|
|motion|[L115](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L115)|`with SingleTickerProviderStateMixin {`|
|motion|[L117](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L117)|`static const _duration = Duration(milliseconds: 300);`|
|motion|[L119](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L119)|`late final AnimationController _slide = AnimationController(`|
|motion|[L125](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L125)|`curve: Curves.easeOut,`|
|motion|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L146)|`_slideCurve.curve = fade ? fadeTabCurve : Curves.easeOut;`|
|motion|[L202](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L202)|`tween: _ColorSchemeTween(end: colorScheme),`|
|motion|[L208](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L208)|`animation: _slideCurve,`|
|rendering|[L372](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L372)|`class _MiniScreenPainter extends CustomPainter {`|
|rendering|[L514](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L514)|`..drawPath(path, Paint()..color = style.tint)`|
|rendering|[L515](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L515)|`..drawPath(`|
|rendering|[L554](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L554)|`canvas.saveLayer(null, Paint()..color = Color.fromARGB(alpha, 0, 0, 0));`|
|rendering|[L817](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L817)|`..drawPath(`|
|rendering|[L823](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L823)|`..drawPath(`|
|interaction|[L298](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L298)|`child: MouseRegion(`|
|interaction|[L300](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L300)|`child: GestureDetector(`|
|interaction|[L302](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L302)|`onTap: () => onSelect(i),`|
|platform|[L172](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L172)|`ThemeMode.system => MediaQuery.platformBrightnessOf(context),`|
|platform|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L282)|`return LayoutBuilder(`|
|lifecycle|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L131)|`void initState() {`|
|lifecycle|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L132)|`super.initState();`|
|lifecycle|[L158](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L158)|`void dispose() {`|
|lifecycle|[L159](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L159)|`_slideCurve.dispose();`|
|lifecycle|[L160](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L160)|`_slide.dispose();`|
|lifecycle|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/theme_preview.dart#L161)|`super.dispose();`|

### FlClash/lib/views/tools.dart

用途：page：ToolsView。复用：`保留完整源文件；见下方解耦策略`。状态：业务或原生依赖，尚未独立提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/tools.dart#L55)|`if (system.isDesktop) const _HotkeyItem(),`|

### FlClash/lib/widgets/active_polling.dart

用途：前台且页面活跃时串行轮询，代次隔离过期结果。复用：`packages/flutter/lib/src/widgets/active_polling.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L11](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L11)|`on State<T>, WidgetsBindingObserver {`|
|lifecycle|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L27)|`void initState() {`|
|lifecycle|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L28)|`super.initState();`|
|lifecycle|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L32)|`lifecycleState == null  /  /  lifecycleState == AppLifecycleState.resumed;`|
|lifecycle|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L41)|`void didChangeDependencies() {`|
|lifecycle|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L42)|`super.didChangeDependencies();`|
|lifecycle|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L46)|`PageActivityScope.isActiveOf(context) &&`|
|lifecycle|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L56)|`void didChangeAppLifecycleState(AppLifecycleState state) {`|
|lifecycle|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L57)|`super.didChangeAppLifecycleState(state);`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L58)|`final isForeground = state == AppLifecycleState.resumed;`|
|lifecycle|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L67)|`void dispose() {`|
|lifecycle|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L71)|`super.dispose();`|
|lifecycle|[L149](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L149)|`with WidgetsBindingObserver, ActivePollingMixin<TickBuilder> {`|
|lifecycle|[L168](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L168)|`void didChangeAppLifecycleState(AppLifecycleState state) {`|
|lifecycle|[L170](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L170)|`super.didChangeAppLifecycleState(state);`|
|lifecycle|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L179)|`void didUpdateWidget(covariant TickBuilder oldWidget) {`|
|lifecycle|[L180](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/active_polling.dart#L180)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/widgets/chip_title.dart

用途：app-widget：ExpireChip, ChipTitle。复用：`packages/flutter/lib/src/widgets/chip_title.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L111](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/chip_title.dart#L111)|`return LayoutBuilder(`|

### FlClash/lib/widgets/icon.dart

用途：16 MiB 图标缓存、192 px 解码、加载回退、monogram 与原生包图标异步代次。复用：`packages/flutter/lib/src/widgets/target_icon.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L241](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L241)|`stream.removeListener(listener);`|
|interaction|[L245](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L245)|`listener = ImageStreamListener(`|
|interaction|[L249](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L249)|`stream.addListener(listener);`|
|lifecycle|[L296](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L296)|`void initState() {`|
|lifecycle|[L297](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L297)|`super.initState();`|
|lifecycle|[L303](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L303)|`void didUpdateWidget(covariant ImageCacheWidget oldWidget) {`|
|lifecycle|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L304)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L337](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L337)|`void dispose() {`|
|lifecycle|[L339](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L339)|`_bytesNotifier.dispose();`|
|lifecycle|[L340](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L340)|`super.dispose();`|
|lifecycle|[L379](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L379)|`void initState() {`|
|lifecycle|[L380](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L380)|`super.initState();`|
|lifecycle|[L386](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L386)|`void didUpdateWidget(covariant PackageIcon oldWidget) {`|
|lifecycle|[L387](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/icon.dart#L387)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/widgets/input.dart

用途：app-widget：BatchInput, EntryDialog。复用：`packages/flutter/lib/src/input/input.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/input.dart#L77)|`void initState() {`|
|lifecycle|[L78](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/input.dart#L78)|`super.initState();`|
|lifecycle|[L88](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/input.dart#L88)|`void dispose() {`|
|lifecycle|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/input.dart#L89)|`_valueController.dispose();`|
|lifecycle|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/input.dart#L90)|`super.dispose();`|

### FlClash/lib/widgets/last_update_time_text.dart

用途：app-widget：LastUpdateTimeText。复用：`packages/flutter/lib/src/widgets/last_update_time_text.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/last_update_time_text.dart#L24)|`duration: const Duration(minutes: 1),`|

### FlClash/lib/widgets/palette.dart

用途：HCT 网格、HSL 色谱、HSV 滑块及 hex 输入；拖动优先争夺手势。复用：`packages/flutter/lib/src/widgets/palette.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L89)|`duration: const Duration(milliseconds: 250),`|
|motion|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L90)|`curve: Curves.easeOutCubic,`|
|rendering|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L162)|`class _GridPainter extends CustomPainter {`|
|rendering|[L201](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L201)|`canvas.drawRSuperellipse(`|
|rendering|[L276](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L276)|`class _SpectrumPainter extends CustomPainter {`|
|rendering|[L294](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L294)|`canvas.drawRSuperellipse(`|
|rendering|[L300](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L300)|`canvas.drawRSuperellipse(`|
|rendering|[L564](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L564)|`canvas.drawRSuperellipse(`|
|rendering|[L576](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L576)|`canvas.drawRSuperellipse(`|
|interaction|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L37)|`widget.controller.addListener(_syncHsv);`|
|interaction|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L44)|`oldWidget.controller.removeListener(_syncHsv);`|
|interaction|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L45)|`widget.controller.addListener(_syncHsv);`|
|interaction|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L52)|`widget.controller.removeListener(_syncHsv);`|
|interaction|[L358](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L358)|`return MouseRegion(`|
|interaction|[L360](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L360)|`child: RawGestureDetector(`|
|platform|[L348](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L348)|`return LayoutBuilder(`|
|lifecycle|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L35)|`void initState() {`|
|lifecycle|[L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L36)|`super.initState();`|
|lifecycle|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L41)|`void didUpdateWidget(Palette oldWidget) {`|
|lifecycle|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L42)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L51)|`void dispose() {`|
|lifecycle|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L53)|`super.dispose();`|
|lifecycle|[L650](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L650)|`void didUpdateWidget(HexColorField oldWidget) {`|
|lifecycle|[L651](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L651)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L663](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L663)|`void dispose() {`|
|lifecycle|[L664](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L664)|`_controller.dispose();`|
|lifecycle|[L665](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/palette.dart#L665)|`super.dispose();`|

### FlClash/lib/widgets/record.dart

用途：app-widget：RecordTextStyles, RecordListItem, RecordHeader, RecordLabel, RecordTimestamp, RecordArrow, DetailRow。复用：`packages/flutter/lib/src/widgets/record.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record.dart#L41)|`final VoidCallback? onTap;`|
|interaction|[L47](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record.dart#L47)|`this.onTap,`|
|interaction|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record.dart#L58)|`onPressed: onTap,`|

### FlClash/lib/widgets/record_feed_list.dart

用途：按 key 复用记录行，裁掉头部时保持条纹及滚动身份。复用：`packages/flutter/lib/src/widgets/record_feed_list.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_feed_list.dart#L76)|`void didUpdateWidget(RecordFeedList<T> oldWidget) {`|
|lifecycle|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_feed_list.dart#L77)|`super.didUpdateWidget(oldWidget);`|

### FlClash/lib/widgets/record_filter.dart

用途：app-widget：RecordFilterState, RecordFacetOptions, RecordFilterController, RecordFilterScope, RecordGroupedList。复用：`packages/flutter/lib/src/records/filter.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_filter.dart#L214)|`void dispose() {`|
|lifecycle|[L215](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_filter.dart#L215)|`_keywords.dispose();`|
|lifecycle|[L216](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_filter.dart#L216)|`_pinnedKeywords.dispose();`|
|lifecycle|[L217](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_filter.dart#L217)|`options.dispose();`|
|lifecycle|[L218](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_filter.dart#L218)|`super.dispose();`|

### FlClash/lib/widgets/record_table.dart

用途：app-widget：RecordColumn, RecordSort, RecordSorter, TableColumnWidthsMixin, RecordTable, RecordTableFrame, RecordHeaderCell, RecordTableRow, RecordCellText。复用：`packages/flutter/lib/src/widgets/record_table.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L336](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L336)|`onTap: column.sortKey == null ? null : () => onSort(column),`|
|interaction|[L367](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L367)|`final VoidCallback? onTap;`|
|interaction|[L376](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L376)|`required this.onTap,`|
|interaction|[L410](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L410)|`final onTap = this.onTap;`|
|interaction|[L411](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L411)|`if (onTap == null) {`|
|interaction|[L418](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L418)|`onPressed: onTap,`|
|interaction|[L428](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L428)|`final VoidCallback? onTap;`|
|interaction|[L435](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L435)|`this.onTap,`|
|interaction|[L448](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L448)|`onPressed: onTap,`|
|platform|[L195](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L195)|`MediaQuery.textScalerOf(context).scale(_recordCellLineHeight) +`|
|platform|[L240](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L240)|`child: MediaQuery.removePadding(`|
|platform|[L302](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/record_table.dart#L302)|`MediaQuery.textScalerOf(context).scale(_recordHeaderLineHeight) +`|

### FlClash/lib/widgets/subscription_info_view.dart

用途：app-widget：SubscriptionInfoView, SubscriptionInfoDetailView。复用：`packages/flutter/lib/src/widgets/subscription_info_view.dart`。状态：已提取；运行验证见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/subscription_info_view.dart#L17)|`textScaler: MediaQuery.textScalerOf(context),`|
|platform|[L61](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/subscription_info_view.dart#L61)|`LayoutBuilder(`|
|lifecycle|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/widgets/subscription_info_view.dart#L22)|`painter.dispose();`|

### FlClash/linux/runner/my_application.cc

用途：platform-host：。复用：`source/upstream/FlClash/linux`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L38](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L38)|`GdkScreen* screen = gtk_window_get_screen(window);`|
|rendering|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L48)|`gtk_widget_show(GTK_WIDGET(header_bar));`|
|rendering|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L51)|`gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));`|
|rendering|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L53)|`gtk_window_set_title(window, "FlClash");`|
|rendering|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L56)|`gtk_window_set_default_size(window, 680, 580);`|
|rendering|[L69](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L69)|`gtk_window_set_icon(window, icon);`|
|rendering|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L81)|`gtk_widget_show(GTK_WIDGET(view));`|
|rendering|[L86](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L86)|`gtk_widget_realize(GTK_WIDGET(view));`|
|rendering|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L90)|`gtk_widget_grab_focus(GTK_WIDGET(view));`|
|lifecycle|[L145](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L145)|`static void my_application_dispose(GObject* object) {`|
|lifecycle|[L148](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/linux/runner/my_application.cc#L148)|`G_OBJECT_CLASS(my_application_parent_class)->dispose(object);`|

### FlClash/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme

用途：platform-host：。复用：`source/upstream/FlClash/macos`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L81](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme#L81)|`allowLocationSimulation = "YES">`|

### FlClash/plugins/code_forge/lib/code_forge/clipboard.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/clipboard.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/clipboard.dart#L18)|`if (defaultTargetPlatform == TargetPlatform.android &&`|

### FlClash/plugins/code_forge/lib/code_forge/code_area.dart

用途：editor：CodeForge, CodeForgeContextMenuRequest, CodeForgeScrollbarDetails, CodeForgeSuggestionDetails。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L169](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L169)|`final AnimationController caretBlinkController;`|
|motion|[L170](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L170)|`final AnimationController lineHighlightController;`|
|interaction|[L167](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L167)|`final FocusNode focusNode;`|
|platform|[L168](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L168)|`final bool readOnly, isMobile, lineWrap;`|
|platform|[L192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L192)|`required this.isMobile,`|
|platform|[L218](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area.dart#L218)|`isMobile: isMobile,`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/editor_state.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/editor_state.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L4)|`with TickerProviderStateMixin, WidgetsBindingObserver`|
|motion|[L10](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L10)|`late final AnimationController _caretBlinkController;`|
|motion|[L11](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L11)|`late final AnimationController _lineHighlightController;`|
|motion|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L50)|`_caretBlinkController = AnimationController(`|
|motion|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L52)|`duration: const Duration(milliseconds: 500),`|
|motion|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L55)|`_lineHighlightController = AnimationController(`|
|motion|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L57)|`duration: const Duration(milliseconds: 800),`|
|interaction|[L9](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L9)|`late final FocusNode _focusNode;`|
|interaction|[L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L39)|`_focusNode = FocusNode();`|
|interaction|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L45)|`_magnifierNotifier.addListener(_syncMagnifier);`|
|interaction|[L61](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L61)|`..addListener(_handleFocusChange)`|
|interaction|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L62)|`..addListener(_resetCursorBlink);`|
|interaction|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L72)|`_vscrollController.addListener(_scrollbarLineNumberListener);`|
|interaction|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L85)|`FocusNode get focusNode => _focusNode;`|
|interaction|[L187](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L187)|`_vscrollController.removeListener(_scrollbarLineNumberListener);`|
|interaction|[L210](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L210)|`..addListener(_controllerListener);`|
|interaction|[L229](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L229)|`_controller.removeListener(_controllerListener);`|
|interaction|[L254](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L254)|`(tap) => tap.onTap = () {`|
|interaction|[L280](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L280)|`onKeyEvent: _handleKeyEvent,`|
|interaction|[L331](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L331)|`child: RawGestureDetector(`|
|interaction|[L333](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L333)|`child: MouseRegion(`|
|platform|[L27](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L27)|`final _isMobile = Platform.isAndroid  /  /  Platform.isIOS;`|
|platform|[L156](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L156)|`final bottomInset = View.of(context).viewInsets.bottom;`|
|platform|[L255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L255)|`if (_isMobile) return;`|
|platform|[L259](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L259)|`if (_isMobile)`|
|platform|[L296](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L296)|`isMobile: _isMobile,`|
|lifecycle|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L4)|`with TickerProviderStateMixin, WidgetsBindingObserver`|
|lifecycle|[L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L36)|`void initState() {`|
|lifecycle|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L37)|`super.initState();`|
|lifecycle|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L113)|`void didUpdateWidget(covariant CodeForge oldWidget) {`|
|lifecycle|[L114](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L114)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L185](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L185)|`void dispose() {`|
|lifecycle|[L189](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L189)|`_caretBlinkController.dispose();`|
|lifecycle|[L190](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L190)|`_lineHighlightController.dispose();`|
|lifecycle|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L191)|`_selectionActiveNotifier.dispose();`|
|lifecycle|[L192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L192)|`_caretRectNotifier.dispose();`|
|lifecycle|[L193](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L193)|`_magnifierNotifier.dispose();`|
|lifecycle|[L195](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L195)|`_magnifierInfo.dispose();`|
|lifecycle|[L196](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L196)|`_scrollbarLineNumberIndicator.dispose();`|
|lifecycle|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L197)|`_focusNode.dispose();`|
|lifecycle|[L198](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L198)|`_hscrollController.dispose();`|
|lifecycle|[L199](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L199)|`_ownedVscrollController?.dispose();`|
|lifecycle|[L200](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L200)|`_fieldDelegate?.dispose();`|
|lifecycle|[L201](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L201)|`super.dispose();`|
|lifecycle|[L237](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L237)|`if (_ownsFindController) _findController.dispose();`|
|lifecycle|[L247](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L247)|`if (_ownsUndoController) _undoRedoController.dispose();`|
|lifecycle|[L272](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state.dart#L272)|`WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L315](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L315)|`_vscrollController.animateTo(`|
|motion|[L317](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L317)|`duration: const Duration(milliseconds: 300),`|
|motion|[L318](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L318)|`curve: Curves.ease,`|
|interaction|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L214)|`KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {`|
|interaction|[L240](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L240)|`bool _handleSuggestionKey(LogicalKeyboardKey key) {`|
|interaction|[L243](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L243)|`case LogicalKeyboardKey.arrowDown:`|
|interaction|[L245](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L245)|`case LogicalKeyboardKey.arrowUp:`|
|interaction|[L247](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L247)|`case LogicalKeyboardKey.enter  /  /  LogicalKeyboardKey.tab:`|
|interaction|[L249](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L249)|`case LogicalKeyboardKey.escape:`|
|interaction|[L258](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L258)|`LogicalKeyboardKey key, {`|
|interaction|[L265](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L265)|`case LogicalKeyboardKey.tab when shift && !control:`|
|interaction|[L269](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L269)|`case LogicalKeyboardKey.backspace:`|
|interaction|[L273](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L273)|`case LogicalKeyboardKey.delete:`|
|interaction|[L277](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L277)|`case LogicalKeyboardKey.arrowDown when !alt:`|
|interaction|[L279](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L279)|`case LogicalKeyboardKey.arrowUp when !alt:`|
|interaction|[L281](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L281)|`case LogicalKeyboardKey.arrowRight:`|
|interaction|[L283](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L283)|`case LogicalKeyboardKey.arrowLeft:`|
|interaction|[L285](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L285)|`case LogicalKeyboardKey.home:`|
|interaction|[L287](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L287)|`case LogicalKeyboardKey.end:`|
|interaction|[L289](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L289)|`case LogicalKeyboardKey.escape:`|
|interaction|[L298](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L298)|`case LogicalKeyboardKey.tab:`|
|interaction|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L304)|`case LogicalKeyboardKey.pageUp:`|
|interaction|[L306](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L306)|`case LogicalKeyboardKey.pageDown:`|
|platform|[L24](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L24)|`if (!_isMobile) _connection!.show();`|
|platform|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_keyboard.dart#L80)|`defaultTargetPlatform,`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/editor_state_overlays.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/editor_state_overlays.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/editor_state_overlays.dart#L18)|`if (stack is! RenderBox  /  /  !stack.attached) return;`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L18)|`final AnimationController caretBlinkController;`|
|motion|[L19](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L19)|`final AnimationController lineHighlightController;`|
|motion|[L145](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L145)|`curve: Curves.easeOut,`|
|motion|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L147)|`_lineHighlightAnimation = Tween<double>(`|
|motion|[L347](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L347)|`_resizeTimer = Timer(const Duration(milliseconds: 150), () {`|
|rendering|[L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L14)|`class _CodeFieldRenderer extends RenderBox implements MouseTrackerAnnotation {`|
|interaction|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L17)|`final FocusNode focusNode;`|
|interaction|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L134)|`_onetap.onTap = () => controller.suggestionsNotifier.value = null;`|
|interaction|[L137](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L137)|`vscrollController.addListener(_onScroll);`|
|interaction|[L138](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L138)|`hscrollController.addListener(_onScroll);`|
|interaction|[L139](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L139)|`caretBlinkController.addListener(_onCaretBlink);`|
|interaction|[L140](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L140)|`controller.addListener(_onControllerChange);`|
|interaction|[L150](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L150)|`).animate(_lineHighlightCurve)..addListener(markNeedsPaint);`|
|interaction|[L541](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L541)|`controller.removeListener(_onControllerChange);`|
|interaction|[L542](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L542)|`vscrollController.removeListener(_onScroll);`|
|interaction|[L543](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L543)|`hscrollController.removeListener(_onScroll);`|
|interaction|[L544](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L544)|`caretBlinkController.removeListener(_onCaretBlink);`|
|interaction|[L545](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L545)|`_lineHighlightAnimation.removeListener(markNeedsPaint);`|
|interaction|[L569](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L569)|`_onPointerDown(event);`|
|interaction|[L571](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L571)|`_onPointerMove(event);`|
|interaction|[L573](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L573)|`_onPointerUp(event);`|
|platform|[L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L20)|`final bool isMobile;`|
|platform|[L107](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L107)|`required this.isMobile,`|
|platform|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L133)|`if (!isMobile) {`|
|platform|[L258](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L258)|`isMobile &&`|
|platform|[L272](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L272)|`if (isMobile) _showBubble = false;`|
|platform|[L531](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L531)|`if (isMobile) _paintMobileHandles(canvas, offset);`|
|lifecycle|[L540](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L540)|`void dispose() {`|
|lifecycle|[L546](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L546)|`_lineHighlightCurve.dispose();`|
|lifecycle|[L547](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L547)|`_syntaxHighlighter.dispose();`|
|lifecycle|[L548](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L548)|`_dtap.dispose();`|
|lifecycle|[L549](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L549)|`_onetap.dispose();`|
|lifecycle|[L550](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer.dart#L550)|`super.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_caret.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L102](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart#L102)|`.animateTo(`|
|motion|[L104](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart#L104)|`duration: const Duration(milliseconds: 300),`|
|motion|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart#L105)|`curve: Curves.easeInOut,`|
|rendering|[L385](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart#L385)|`canvas.drawRSuperellipse(`|
|platform|[L398](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_caret.dart#L398)|`if (!isMobile) return null;`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_folding.dart

用途：editor：on。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_folding.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L150](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_folding.dart#L150)|`_foldCacheRecheckTimer = Timer(const Duration(milliseconds: 300), () {`|
|motion|[L221](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_folding.dart#L221)|`_foldComputeTimer = Timer(const Duration(milliseconds: 300), () {`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_gutter.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_gutter.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L124](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_gutter.dart#L124)|`canvas.drawPath(`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_highlights.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_highlights.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_highlights.dart#L23)|`_bracketHighlightResumeTimer = Timer(const Duration(milliseconds: 500), () {`|
|rendering|[L127](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_highlights.dart#L127)|`canvas.drawRSuperellipse(bracketRect, _bracketHighlightPainter);`|
|platform|[L399](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_highlights.dart#L399)|`endRow + _lineHeight + (isMobile ? _handleSize : 0),`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_layout.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_layout.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L467](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_layout.dart#L467)|`!isMobile && HardwareKeyboard.instance.isShiftPressed`|
|platform|[L471](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_layout.dart#L471)|`if (isMobile) _selectionActive = true;`|
|lifecycle|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_layout.dart#L136)|`_syntaxHighlighter.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/code_area/renderer_pointer.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L80)|`_selectionTimer = Timer(const Duration(milliseconds: 500), () {`|
|interaction|[L8](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L8)|`void _onPointerDown(PointerDownEvent event) {`|
|interaction|[L142](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L142)|`void _onPointerMove(PointerMoveEvent event) {`|
|interaction|[L200](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L200)|`void _onPointerUp(PointerEvent event) {`|
|platform|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L56)|`if (isMobile) onContextMenuRequest(position);`|
|platform|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L59)|`if (isMobile) {`|
|platform|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L113)|`isMobile &&`|
|platform|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L147)|`if (isMobile) {`|
|platform|[L207](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L207)|`if (isMobile &&`|
|platform|[L215](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L215)|`if (isMobile && !wasDragging && !_selectionActive) {`|
|platform|[L227](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/code_area/renderer_pointer.dart#L227)|`if (isMobile && controller.selection.isCollapsed) _showBubble = true;`|

### FlClash/plugins/code_forge/lib/code_forge/controller.dart

用途：editor：DocumentEditListener, CodeForgeChange, CodeForgeView, CodeForgeController。复用：`packages/editor/vendor/code_forge/lib/code_forge/controller.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L100](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L100)|`static const _flushDelay = Duration(milliseconds: 100);`|
|motion|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L155)|`_debounceTimer = Timer(const Duration(milliseconds: 200), () async {`|
|interaction|[L65](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L65)|`FocusNode get focusNode;`|
|interaction|[L148](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L148)|`suggestionsNotifier.addListener(() {`|
|interaction|[L182](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L182)|`FocusNode? get focusNode => _view?.focusNode;`|
|interaction|[L494](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L494)|`void addListener(VoidCallback listener) {`|
|interaction|[L499](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L499)|`void removeListener(VoidCallback listener) {`|
|interaction|[L503](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L503)|`void addEditListener(DocumentEditListener listener) {`|
|interaction|[L507](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L507)|`void removeEditListener(DocumentEditListener listener) {`|
|platform|[L103](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L103)|`final _isMobile = Platform.isAndroid  /  /  Platform.isIOS;`|
|platform|[L150](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L150)|`suggestionsNotifier.value == null  /  /  _isMobile ? null : 0;`|
|lifecycle|[L412](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L412)|`snapshot.dispose();`|
|lifecycle|[L445](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L445)|`_rope.dispose();`|
|lifecycle|[L448](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L448)|`_original?.dispose();`|
|lifecycle|[L943](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L943)|`void dispose() {`|
|lifecycle|[L951](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L951)|`suggestionsNotifier.dispose();`|
|lifecycle|[L952](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L952)|`selectedSuggestionNotifier.dispose();`|
|lifecycle|[L953](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L953)|`_rope.dispose();`|
|lifecycle|[L954](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller.dart#L954)|`_original?.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/controller/document.dart

用途：editor：CodeForgeDocument。复用：`packages/editor/vendor/code_forge/lib/code_forge/controller/document.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller/document.dart#L44)|`void dispose() => _rope.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/controller/edit_pipeline.dart

用途：editor：。复用：`packages/editor/vendor/code_forge/lib/code_forge/controller/edit_pipeline.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller/edit_pipeline.dart#L56)|`previous.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/controller/ime.dart

用途：editor：ImeComposition。复用：`packages/editor/vendor/code_forge/lib/code_forge/controller/ime.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L372](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/controller/ime.dart#L372)|`const Duration(milliseconds: 150);`|

### FlClash/plugins/code_forge/lib/code_forge/find_controller.dart

用途：editor：FindController, SearchHighlight。复用：`packages/editor/vendor/code_forge/lib/code_forge/find_controller.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L21](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L21)|`static const _regexResearchDelay = Duration(milliseconds: 300);`|
|interaction|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L49)|`final FocusNode findInputFocusNode = FocusNode();`|
|interaction|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L50)|`final FocusNode replaceInputFocusNode = FocusNode();`|
|interaction|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L55)|`..addEditListener(_onEdit)`|
|interaction|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L56)|`..addListener(_onCodeControllerChanged);`|
|interaction|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L57)|`findInputController.addListener(_onFindInputChanged);`|
|interaction|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L70)|`..removeEditListener(_onEdit)`|
|interaction|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L71)|`..removeListener(_onCodeControllerChanged);`|
|interaction|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L72)|`findInputController.removeListener(_onFindInputChanged);`|
|interaction|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L75)|`findInputFocusNode.dispose();`|
|interaction|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L76)|`replaceInputFocusNode.dispose();`|
|interaction|[L250](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L250)|`Future.microtask(() => findInputFocusNode.requestFocus());`|
|interaction|[L269](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L269)|`if (_isActive) findInputFocusNode.requestFocus();`|
|lifecycle|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L66)|`void dispose() {`|
|lifecycle|[L73](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L73)|`findInputController.dispose();`|
|lifecycle|[L74](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L74)|`replaceInputController.dispose();`|
|lifecycle|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L75)|`findInputFocusNode.dispose();`|
|lifecycle|[L76](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L76)|`replaceInputFocusNode.dispose();`|
|lifecycle|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L77)|`super.dispose();`|
|lifecycle|[L423](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/find_controller.dart#L423)|`document.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart

用途：editor：CodeForgeKeyboardShortcuts, AnyShortcutActivator。复用：`packages/editor/vendor/code_forge/lib/code_forge/keyboard_shortcuts.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L43)|`const CodeForgeKeyboardShortcuts({`|
|interaction|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L45)|`LogicalKeyboardKey.keyD,`|
|interaction|[L49](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L49)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L54)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L59)|`LogicalKeyboardKey.backspace,`|
|interaction|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L63)|`LogicalKeyboardKey.delete,`|
|interaction|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L67)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L71](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L71)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L75](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L75)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L80](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L80)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L85)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L89](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L89)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L93](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L93)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L97](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L97)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L101)|`LogicalKeyboardKey.keyF,`|
|interaction|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L105)|`LogicalKeyboardKey.keyH,`|
|interaction|[L109](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L109)|`LogicalKeyboardKey.home,`|
|interaction|[L113](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L113)|`LogicalKeyboardKey.end,`|
|interaction|[L117](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L117)|`LogicalKeyboardKey.home,`|
|interaction|[L122](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L122)|`LogicalKeyboardKey.end,`|
|interaction|[L127](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L127)|`LogicalKeyboardKey.home,`|
|interaction|[L131](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L131)|`LogicalKeyboardKey.end,`|
|interaction|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L134)|`this.copy = const SingleActivator(LogicalKeyboardKey.keyC, control: true),`|
|interaction|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L135)|`this.cut = const SingleActivator(LogicalKeyboardKey.keyX, control: true),`|
|interaction|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L136)|`this.paste = const SingleActivator(LogicalKeyboardKey.keyV, control: true),`|
|interaction|[L138](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L138)|`LogicalKeyboardKey.keyA,`|
|interaction|[L141](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L141)|`this.undo = const SingleActivator(LogicalKeyboardKey.keyZ, control: true),`|
|interaction|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L143)|`SingleActivator(LogicalKeyboardKey.keyY, control: true),`|
|interaction|[L144](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L144)|`SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true),`|
|interaction|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L146)|`this.jumpToLineStart = const SingleActivator(LogicalKeyboardKey.home),`|
|interaction|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L147)|`this.jumpToLineEnd = const SingleActivator(LogicalKeyboardKey.end),`|
|interaction|[L153](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L153)|`this.duplicate = const SingleActivator(LogicalKeyboardKey.keyD, meta: true),`|
|interaction|[L155](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L155)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L159](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L159)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L163](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L163)|`LogicalKeyboardKey.backspace,`|
|interaction|[L167](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L167)|`LogicalKeyboardKey.delete,`|
|interaction|[L171](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L171)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L175](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L175)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L179)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L184](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L184)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L189](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L189)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L193](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L193)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L197)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L201](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L201)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L205](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L205)|`LogicalKeyboardKey.keyF,`|
|interaction|[L210](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L210)|`LogicalKeyboardKey.keyF,`|
|interaction|[L215](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L215)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L219](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L219)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L223](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L223)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L228)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L233](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L233)|`SingleActivator(LogicalKeyboardKey.home, shift: true),`|
|interaction|[L234](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L234)|`SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true, shift: true),`|
|interaction|[L237](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L237)|`SingleActivator(LogicalKeyboardKey.end, shift: true),`|
|interaction|[L238](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L238)|`SingleActivator(LogicalKeyboardKey.arrowRight, meta: true, shift: true),`|
|interaction|[L240](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L240)|`this.copy = const SingleActivator(LogicalKeyboardKey.keyC, meta: true),`|
|interaction|[L241](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L241)|`this.cut = const SingleActivator(LogicalKeyboardKey.keyX, meta: true),`|
|interaction|[L242](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L242)|`this.paste = const SingleActivator(LogicalKeyboardKey.keyV, meta: true),`|
|interaction|[L243](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L243)|`this.selectAll = const SingleActivator(LogicalKeyboardKey.keyA, meta: true),`|
|interaction|[L244](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L244)|`this.undo = const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),`|
|interaction|[L246](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L246)|`LogicalKeyboardKey.keyZ,`|
|interaction|[L251](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L251)|`SingleActivator(LogicalKeyboardKey.home),`|
|interaction|[L252](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L252)|`SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true),`|
|interaction|[L255](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L255)|`SingleActivator(LogicalKeyboardKey.end),`|
|interaction|[L256](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L256)|`SingleActivator(LogicalKeyboardKey.arrowRight, meta: true),`|
|interaction|[L259](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L259)|`LogicalKeyboardKey.backspace,`|
|interaction|[L269](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L269)|`_ => const CodeForgeKeyboardShortcuts(),`|
|interaction|[L282](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L282)|`Iterable<LogicalKeyboardKey>? get triggers {`|
|interaction|[L283](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L283)|`final keys = <LogicalKeyboardKey>{};`|
|platform|[L265](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L265)|`static CodeForgeKeyboardShortcuts forPlatform(TargetPlatform platform) {`|
|platform|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L267)|`TargetPlatform.macOS  /  / `|
|platform|[L268](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/keyboard_shortcuts.dart#L268)|`TargetPlatform.iOS => const CodeForgeKeyboardShortcuts.apple(),`|

### FlClash/plugins/code_forge/lib/code_forge/rope.dart

用途：editor：Rope。复用：`packages/editor/vendor/code_forge/lib/code_forge/rope.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/rope.dart#L36)|`upload.dispose();`|
|lifecycle|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/rope.dart#L58)|`void dispose() => _rope.dispose();`|

### FlClash/plugins/code_forge/lib/code_forge/syntax_highlighter.dart

用途：editor：SyntaxHighlighter。复用：`packages/editor/vendor/code_forge/lib/code_forge/syntax_highlighter.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/syntax_highlighter.dart#L192)|`void dispose() => _spans.clear();`|

### FlClash/plugins/code_forge/lib/code_forge/undo_redo.dart

用途：editor：EditOperation, InsertOperation, DeleteOperation, ReplaceOperation, DocumentOperation, UndoRedoController, CompoundOperationHandle, CompoundOperation。复用：`packages/editor/vendor/code_forge/lib/code_forge/undo_redo.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L426](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/undo_redo.dart#L426)|`void dispose() {`|
|lifecycle|[L429](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/undo_redo.dart#L429)|`super.dispose();`|
|lifecycle|[L442](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/undo_redo.dart#L442)|`before.dispose();`|
|lifecycle|[L443](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/lib/code_forge/undo_redo.dart#L443)|`after.dispose();`|

### FlClash/plugins/dynamic_color/android/src/main/kotlin/io/material/plugins/dynamic_color/DynamicColorPlugin.kt

用途：native-ui：DynamicColorPlugin。复用：`packages/platform/vendor/dynamic_color/android/src/main/kotlin/io/material/plugins/dynamic_color/DynamicColorPlugin.kt`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/android/src/main/kotlin/io/material/plugins/dynamic_color/DynamicColorPlugin.kt#L23)|`override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {`|
|lifecycle|[L44](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/android/src/main/kotlin/io/material/plugins/dynamic_color/DynamicColorPlugin.kt#L44)|`override fun onDetachedFromEngine(binding: FlutterPluginBinding) {`|

### FlClash/plugins/dynamic_color/linux/dynamic_color_plugin.cc

用途：native-ui：。复用：`packages/platform/vendor/dynamic_color/linux/dynamic_color_plugin.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/linux/dynamic_color_plugin.cc#L20)|`GtkStyleContext* context = gtk_widget_get_style_context(widget);`|
|lifecycle|[L83](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/linux/dynamic_color_plugin.cc#L83)|`static void dynamic_color_plugin_dispose(GObject* object) {`|
|lifecycle|[L85](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/linux/dynamic_color_plugin.cc#L85)|`G_OBJECT_CLASS(dynamic_color_plugin_parent_class)->dispose(object);`|

### FlClash/plugins/proxy/lib/proxy.dart

用途：native-bridge：Proxy。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L37](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L37)|`return switch (Platform.operatingSystem) {`|
|platform|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L42)|`desktop: Platform.environment['XDG_CURRENT_DESKTOP'],`|
|platform|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L43)|`homeDir: Platform.environment['HOME'],`|
|platform|[L45](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L45)|`'windows' => await ProxyPlatform.instance.startProxy(`|
|platform|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L54)|`return switch (Platform.operatingSystem) {`|
|platform|[L57](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L57)|`desktop: Platform.environment['XDG_CURRENT_DESKTOP'],`|
|platform|[L58](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L58)|`homeDir: Platform.environment['HOME'],`|
|platform|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/lib/proxy.dart#L60)|`'windows' => await ProxyPlatform.instance.stopProxy(),`|

### FlClash/plugins/proxy/windows/proxy_plugin.cpp

用途：native-bridge：。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/windows/proxy_plugin.cpp#L228)|`std::optional<bool> HasTcpListener(ULONG family, int port)`|
|interaction|[L256](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/proxy/windows/proxy_plugin.cpp#L256)|`if (HasTcpListener(family, port).value_or(true))`|

### FlClash/plugins/rust_api/hook/build.dart

用途：native-bridge：。复用：`packages/editor/vendor/rust_api/hook/build.dart`。状态：已提取；原生构建/运行状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/rust_api/hook/build.dart#L33)|`'${llvmRoot.path}${Platform.pathSeparator}$name',`|
|platform|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/rust_api/hook/build.dart#L46)|`return entity.path.split(Platform.pathSeparator).last.startsWith('libclang.');`|

### FlClash/plugins/rust_api/lib/src/rust/frb_generated.dart

用途：native-bridge：RustLib, RustLibApi, RustLibApiImpl, IpcServerImpl, RopeBridgeImpl, RopeUploadImpl。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/rust_api/lib/src/rust/frb_generated.dart#L50)|`static void dispose() => instance.disposeImpl();`|

### FlClash/plugins/setup/setup_hooks/lib/src/rust_builder.dart

用途：native-bridge：RustBuilder。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L127](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/setup/setup_hooks/lib/src/rust_builder.dart#L127)|`final entries = Platform.environment.entries.toList()`|

### FlClash/plugins/setup/setup_hooks/lib/src/util.dart

用途：native-bridge：。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L16](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/setup/setup_hooks/lib/src/util.dart#L16)|`if (Platform.isWindows) return null;`|
|platform|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/setup/setup_hooks/lib/src/util.dart#L17)|`final entries = (Platform.environment['PATH'] ?? '').split(':');`|
|platform|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/setup/setup_hooks/lib/src/util.dart#L18)|`final home = Platform.environment['HOME'];`|
|platform|[L90](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/setup/setup_hooks/lib/src/util.dart#L90)|`runInShell: Platform.isWindows,`|

### FlClash/plugins/tray/README.md

用途：native-ui：。复用：`packages/platform/vendor/tray/README.md`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L63](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/README.md#L63)|`rather than on Platform.isX.`|

### FlClash/plugins/tray/lib/src/tray.dart

用途：native-ui：Tray。复用：`packages/platform/vendor/tray/lib/src/tray.dart`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L46)|`TrayCapabilities.of(defaultTargetPlatform);`|
|platform|[L203](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L203)|`switch (defaultTargetPlatform) {`|
|platform|[L204](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L204)|`case TargetPlatform.macOS:`|
|platform|[L206](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L206)|`case TargetPlatform.linux:`|
|platform|[L243](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L243)|`path.dirname(Platform.resolvedExecutable),`|
|platform|[L251](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray.dart#L251)|`return path.basenameWithoutExtension(Platform.resolvedExecutable);`|

### FlClash/plugins/tray/lib/src/tray_capabilities.dart

用途：native-ui：TrayCapabilities。复用：`packages/platform/vendor/tray/lib/src/tray_capabilities.dart`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray_capabilities.dart#L52)|`static TrayCapabilities of(TargetPlatform platform) {`|
|platform|[L54](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray_capabilities.dart#L54)|`TargetPlatform.macOS => macOS,`|
|platform|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray_capabilities.dart#L55)|`TargetPlatform.windows => windows,`|
|platform|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/lib/src/tray_capabilities.dart#L56)|`TargetPlatform.linux => linux,`|

### FlClash/plugins/tray/linux/tray_plugin.cc

用途：native-ui：。复用：`packages/platform/vendor/tray/linux/tray_plugin.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L111](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L111)|`gtk_widget_set_sensitive(item, FALSE);`|
|rendering|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L136)|`gtk_widget_show_all(menu);`|
|rendering|[L139](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L139)|`gtk_widget_destroy(previous);`|
|rendering|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L161)|`gtk_widget_destroy(menu);`|
|lifecycle|[L238](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L238)|`static void tray_plugin_dispose(GObject* object) {`|
|lifecycle|[L248](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/linux/tray_plugin.cc#L248)|`G_OBJECT_CLASS(tray_plugin_parent_class)->dispose(object);`|

### FlClash/plugins/tray/macos/tray/Sources/tray/TrayMenuItemView.swift

用途：native-ui：TrayMenuItemView。复用：`packages/platform/vendor/tray/macos/tray/Sources/tray/TrayMenuItemView.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/macos/tray/Sources/tray/TrayMenuItemView.swift#L136)|`override func mouseUp(with event: NSEvent) {`|

### FlClash/plugins/tray/macos/tray/Sources/tray/TrayStatusItem.swift

用途：native-ui：TrayStatusItem。复用：`packages/platform/vendor/tray/macos/tray/Sources/tray/TrayStatusItem.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/tray/macos/tray/Sources/tray/TrayStatusItem.swift#L135)|`override func mouseDown(with event: NSEvent) {`|

### FlClash/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt

用途：native-bridge：WifiSsidPlugin。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L118](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt#L118)|`activityBinding?.removeRequestPermissionsResultListener(permissionResultListener)`|
|interaction|[L121](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt#L121)|`binding.addRequestPermissionsResultListener(permissionResultListener)`|
|interaction|[L426](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt#L426)|`activityBinding?.removeRequestPermissionsResultListener(permissionResultListener)`|
|lifecycle|[L92](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt#L92)|`override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|
|lifecycle|[L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/android/src/main/kotlin/com/follow/clash/wifi_ssid/WifiSsidPlugin.kt#L105)|`override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {`|

### FlClash/plugins/wifi_ssid/linux/wifi_ssid_plugin.cc

用途：native-bridge：。复用：`source/upstream/FlClash/plugins`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L402](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/linux/wifi_ssid_plugin.cc#L402)|`static void wifi_ssid_plugin_dispose(GObject* object) {`|
|lifecycle|[L403](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/wifi_ssid/linux/wifi_ssid_plugin.cc#L403)|`G_OBJECT_CLASS(wifi_ssid_plugin_parent_class)->dispose(object);`|

### FlClash/plugins/window/README.md

用途：native-ui：。复用：`packages/platform/vendor/window/README.md`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L92](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L92)|`frame border follow) and SetWindowCompositionAttribute; on macOS it owns`|
|rendering|[L107](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L107)|` /  blur  /  ACCENT_ENABLE_BLURBEHIND  /  NSVisualEffectView .sidebar, behind-window blending, follows the window's active state  / `|
|rendering|[L108](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L108)|` /  acrylic  /  ACCENT_ENABLE_ACRYLICBLURBEHIND (Windows 10 1803+)  /  NSVisualEffectView .fullScreenUI  / `|
|rendering|[L110](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L110)|` /  glass  /  unsupported  /  NSGlassEffectView in the variant AppKit gives a split view's sidebar, on macOS 26+ while sidebars there are glass; opaque window  / `|
|rendering|[L119](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L119)|`SetWindowCompositionAttribute, so isEffectSupported is false for them on a`|
|rendering|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L143)|`NSVisualEffectView and hosts the Flutter view controller as a child, so the`|
|interaction|[L122](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L122)|`With titleBarStyle: hidden on Windows, WM_NCCALCSIZE takes the frame`|
|interaction|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L132)|`the frame's border through it) and answers WM_NCHITTEST with HTTOP for it.`|
|interaction|[L146](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L146)|`AppKit hands an unhandled mouseDown from a non-opaque view to the sibling`|
|platform|[L107](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L107)|` /  blur  /  ACCENT_ENABLE_BLURBEHIND  /  NSVisualEffectView .sidebar, behind-window blending, follows the window's active state  / `|
|platform|[L108](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L108)|` /  acrylic  /  ACCENT_ENABLE_ACRYLICBLURBEHIND (Windows 10 1803+)  /  NSVisualEffectView .fullScreenUI  / `|
|platform|[L143](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L143)|`NSVisualEffectView and hosts the Flutter view controller as a child, so the`|
|lifecycle|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/README.md#L162)|`The engine reports AppLifecycleState from its own view of the window. Where`|

### FlClash/plugins/window/lib/src/desktop_window.dart

用途：native-ui：DesktopWindow。复用：`packages/platform/vendor/window/lib/src/desktop_window.dart`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L28](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/lib/src/desktop_window.dart#L28)|`void addListener(WindowListener listener) {`|
|interaction|[L32](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/lib/src/desktop_window.dart#L32)|`void removeListener(WindowListener listener) {`|
|platform|[L208](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/lib/src/desktop_window.dart#L208)|`Future<bool> isEffectSupported(WindowEffect effect) {`|
|platform|[L214](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/lib/src/desktop_window.dart#L214)|`WindowEffect effect, {`|

### FlClash/plugins/window/lib/src/window_effect.dart

用途：native-ui：WindowEffect。复用：`packages/platform/vendor/window/lib/src/window_effect.dart`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/lib/src/window_effect.dart#L4)|`enum WindowEffect { none, transparent, blur, acrylic, mica, glass }`|

### FlClash/plugins/window/linux/window_drag.cc

用途：native-ui：。复用：`packages/platform/vendor/window/linux/window_drag.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L35)|`GdkWindow* window = gtk_widget_get_window(self->drag.event_box);`|
|rendering|[L130](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L130)|`GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));`|
|rendering|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L135)|`gtk_window_begin_move_drag(window, GDK_BUTTON_PRIMARY, root_x, root_y,`|
|interaction|[L40](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L40)|`reinterpret_cast<GdkEventButton*>(gdk_event_new(GDK_BUTTON_RELEASE));`|
|interaction|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L135)|`gtk_window_begin_move_drag(window, GDK_BUTTON_PRIMARY, root_x, root_y,`|
|lifecycle|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.cc#L101)|`void window_drag_dispose(WindowPlugin* self) {`|

### FlClash/plugins/window/linux/window_drag.h

用途：native-ui：struct。复用：`packages/platform/vendor/window/linux/window_drag.h`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_drag.h#L17)|`void window_drag_dispose(WindowPlugin* self);`|

### FlClash/plugins/window/linux/window_geometry.cc

用途：native-ui：。复用：`packages/platform/vendor/window/linux/window_geometry.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L18](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L18)|`if (gtk_window_is_maximized(window)) {`|
|rendering|[L50](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L50)|`gtk_window_move(window, self->geometry.saved_x, self->geometry.saved_y);`|
|rendering|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L51)|`gtk_window_resize(window, self->geometry.saved_width,`|
|rendering|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L64)|`gtk_window_get_position(window, &self->geometry.saved_x,`|
|rendering|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L66)|`gtk_window_get_size(window, &self->geometry.saved_width,`|
|rendering|[L70](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L70)|`gtk_widget_hide(GTK_WIDGET(window));`|
|rendering|[L91](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L91)|`GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));`|
|rendering|[L107](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L107)|`GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));`|
|rendering|[L114](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L114)|`gtk_window_resize(window, width, height);`|
|rendering|[L120](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L120)|`gtk_window_move(window, workarea.x + MAX(0, (workarea.width - width) / 2),`|
|rendering|[L158](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L158)|`gtk_window_get_position(window, &x, &y);`|
|rendering|[L176](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L176)|`gtk_window_get_position(window, &x, &y);`|
|rendering|[L177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L177)|`gtk_window_get_size(window, &width, &height);`|
|lifecycle|[L34](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.cc#L34)|`void window_geometry_dispose(WindowGeometryState* state) {`|

### FlClash/plugins/window/linux/window_geometry.h

用途：native-ui：struct。复用：`packages/platform/vendor/window/linux/window_geometry.h`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L26](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_geometry.h#L26)|`void window_geometry_dispose(WindowGeometryState* state);`|

### FlClash/plugins/window/linux/window_plugin.cc

用途：native-ui：FlMethodResponse, struct。复用：`packages/platform/vendor/window/linux/window_plugin.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L25](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L25)|`return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));`|
|rendering|[L33](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L33)|`return gtk_widget_get_window(GTK_WIDGET(window));`|
|rendering|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L132)|`gtk_window_set_focus_on_map(window, FALSE);`|
|rendering|[L133](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L133)|`gtk_widget_show(GTK_WIDGET(window));`|
|rendering|[L134](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L134)|`gtk_window_set_focus_on_map(window, TRUE);`|
|rendering|[L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L136)|`gtk_widget_show(GTK_WIDGET(window));`|
|rendering|[L149](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L149)|`gtk_widget_is_visible(GTK_WIDGET(window)));`|
|rendering|[L156](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L156)|`GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(window));`|
|rendering|[L158](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L158)|`gtk_window_present_with_time(window, gdk_x11_get_server_time(gdk_window));`|
|rendering|[L162](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L162)|`gtk_window_present(window);`|
|rendering|[L179](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L179)|`gtk_window_close(window);`|
|rendering|[L196](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L196)|`return success_bool(window != nullptr && gtk_window_is_maximized(window));`|
|rendering|[L204](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L204)|`gtk_window_maximize(window);`|
|rendering|[L213](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L213)|`gtk_window_unmaximize(window);`|
|rendering|[L230](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L230)|`gtk_window_iconify(window);`|
|rendering|[L240](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L240)|`gtk_window_deiconify(window);`|
|rendering|[L264](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L264)|`gtk_window_fullscreen(window);`|
|rendering|[L266](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L266)|`gtk_window_unfullscreen(window);`|
|rendering|[L278](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L278)|`gtk_window_get_position(window, &x, &y);`|
|rendering|[L279](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L279)|`gtk_window_get_size(window, &width, &height);`|
|rendering|[L297](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L297)|`gtk_window_move(window, static_cast<gint>(x), static_cast<gint>(y));`|
|rendering|[L304](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L304)|`if (gtk_widget_get_mapped(GTK_WIDGET(window))) {`|
|rendering|[L305](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L305)|`gtk_window_resize(window, w, h);`|
|rendering|[L309](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L309)|`gtk_window_set_default_size(window, w, h);`|
|rendering|[L322](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L322)|`GdkScreen* screen = gtk_window_get_screen(window);`|
|rendering|[L371](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L371)|`gtk_window_set_keep_above(window, value);`|
|rendering|[L404](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L404)|`gtk_window_set_skip_taskbar_hint(window, value);`|
|lifecycle|[L545](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L545)|`g_autoptr(FlValue) state = fl_value_new_string("AppLifecycleState.hidden");`|
|lifecycle|[L609](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L609)|`static void window_plugin_dispose(GObject* object) {`|
|lifecycle|[L621](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L621)|`window_drag_dispose(self);`|
|lifecycle|[L622](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L622)|`window_geometry_dispose(&self->geometry);`|
|lifecycle|[L623](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L623)|`window_style_dispose(&self->style);`|
|lifecycle|[L628](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_plugin.cc#L628)|`G_OBJECT_CLASS(window_plugin_parent_class)->dispose(object);`|

### FlClash/plugins/window/linux/window_style.cc

用途：native-ui：。复用：`packages/platform/vendor/window/linux/window_style.cc`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L35)|`GtkWidget* titlebar = gtk_window_get_titlebar(window);`|
|rendering|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L62)|`gtk_widget_set_visible(header_bar, normal);`|
|rendering|[L67](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L67)|`} else if (gtk_window_get_title(window) != nullptr) {`|
|rendering|[L68](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L68)|`gtk_window_set_decorated(window, normal);`|
|rendering|[L72](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L72)|`gtk_window_set_decorated(window, true);`|
|lifecycle|[L47](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.cc#L47)|`void window_style_dispose(WindowStyle* style) {`|

### FlClash/plugins/window/linux/window_style.h

用途：native-ui：struct。复用：`packages/platform/vendor/window/linux/window_style.h`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/linux/window_style.h#L14)|`void window_style_dispose(WindowStyle* style);`|

### FlClash/plugins/window/macos/window/Sources/window/WindowController.swift

用途：native-ui：WindowController。复用：`packages/platform/vendor/window/macos/window/Sources/window/WindowController.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L191)|`func setEffect(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?) throws {`|
|platform|[L22](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L22)|`WindowEffectView.install(in: window)`|
|platform|[L186](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L186)|`func isEffectSupported(_ effect: WindowEffect) throws -> Bool {`|
|platform|[L188](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L188)|`return WindowEffectView.isSupported(effect)`|
|platform|[L191](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L191)|`func setEffect(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?) throws {`|
|lifecycle|[L3](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L3)|`final class WindowController: NSObject, NSWindowDelegate {`|
|lifecycle|[L8](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L8)|`private weak var previousDelegate: NSWindowDelegate?`|
|lifecycle|[L221](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L221)|`// MARK: - NSWindowDelegate`|
|lifecycle|[L228](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L228)|`if let previousDelegate, previousDelegate.responds(to: #selector(NSWindowDelegate.windowShouldClose(_:))) {`|
|lifecycle|[L234](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L234)|`func windowDidResize(_ notification: Notification) {`|
|lifecycle|[L246](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L246)|`func windowDidMove(_ notification: Notification) {`|
|lifecycle|[L250](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L250)|`func windowDidBecomeMain(_ notification: Notification) {`|
|lifecycle|[L254](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L254)|`func windowDidResignMain(_ notification: Notification) {`|
|lifecycle|[L258](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L258)|`func windowDidMiniaturize(_ notification: Notification) {`|
|lifecycle|[L262](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L262)|`func windowDidDeminiaturize(_ notification: Notification) {`|
|lifecycle|[L267](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L267)|`func windowDidEnterFullScreen(_ notification: Notification) {`|
|lifecycle|[L271](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowController.swift#L271)|`func windowDidExitFullScreen(_ notification: Notification) {`|

### FlClash/plugins/window/macos/window/Sources/window/WindowEffectView.swift

用途：native-ui：WindowEffect, WindowEffectView。复用：`packages/platform/vendor/window/macos/window/Sources/window/WindowEffectView.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L15](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L15)|`// A split view's sidebar glass is a private variant that NSGlassEffectView's`|
|rendering|[L42](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L42)|`static func make() -> NSGlassEffectView {`|
|rendering|[L43](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L43)|`let glass = NSGlassEffectView()`|
|rendering|[L51](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L51)|`private static func firstGlass(in view: NSView) -> NSGlassEffectView? {`|
|rendering|[L52](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L52)|`if let glass = view as? NSGlassEffectView {`|
|rendering|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L66)|`let effectView = NSVisualEffectView()`|
|rendering|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L101)|`let glass: NSGlassEffectView`|
|rendering|[L102](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L102)|`if let existing = glassView as? NSGlassEffectView {`|
|rendering|[L140](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L140)|`static func appearance(brightness: String?) throws -> NSAppearance? {`|
|rendering|[L145](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L145)|`return NSAppearance(named: .aqua)`|
|rendering|[L147](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L147)|`return NSAppearance(named: .darkAqua)`|
|rendering|[L166](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L166)|`static func apply(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?, to window: NSWindow) {`|
|rendering|[L192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L192)|`private static func applyTint(_ tint: NSColor?, to effectView: NSVisualEffectView) {`|
|rendering|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L197)|`// NSVisualEffectView paints the system material itself, so a translucent`|
|platform|[L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L4)|`enum WindowEffect: String {`|
|platform|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L66)|`let effectView = NSVisualEffectView()`|
|platform|[L125](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L125)|`enum WindowEffectView {`|
|platform|[L126](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L126)|`static func isSupported(_ effect: WindowEffect) -> Bool {`|
|platform|[L166](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L166)|`static func apply(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?, to window: NSWindow) {`|
|platform|[L192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L192)|`private static func applyTint(_ tint: NSColor?, to effectView: NSVisualEffectView) {`|
|platform|[L197](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowEffectView.swift#L197)|`// NSVisualEffectView paints the system material itself, so a translucent`|

### FlClash/plugins/window/macos/window/Sources/window/WindowPlugin.swift

用途：native-ui：。复用：`packages/platform/vendor/window/macos/window/Sources/window/WindowPlugin.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L164](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L164)|`guard let effect = WindowEffect(rawValue: try args.string("effect")) else {`|
|platform|[L170](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L170)|`guard let effect = WindowEffect(rawValue: try args.string("effect")) else {`|
|platform|[L173](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L173)|`guard WindowEffectView.isSupported(effect) else {`|
|platform|[L177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L177)|`let appearance = try WindowEffectView.appearance(brightness: try args.optionalString("brightness"))`|
|lifecycle|[L101](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L101)|`self.lifecycle?.sendMessage("AppLifecycleState.hidden")`|
|lifecycle|[L109](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowPlugin.swift#L109)|`lifecycle?.sendMessage(active ? "AppLifecycleState.resumed" : "AppLifecycleState.inactive")`|

### FlClash/plugins/window/macos/window/Sources/window/WindowStyle.swift

用途：native-ui：TitleBarStyle, NSColor。复用：`packages/platform/vendor/window/macos/window/Sources/window/WindowStyle.swift`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L23](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowStyle.swift#L23)|`var effectAppearance: NSAppearance?`|
|platform|[L21](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowStyle.swift#L21)|`var effect: WindowEffect = .none`|
|platform|[L53](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/macos/window/Sources/window/WindowStyle.swift#L53)|`WindowEffectView.apply(effect, tint: effectTint, appearance: effectAppearance, to: window)`|

### FlClash/plugins/window/windows/window_controller.cpp

用途：native-ui：。复用：`packages/platform/vendor/window/windows/window_controller.cpp`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L295](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_controller.cpp#L295)|`if (wparam && message == WM_NCCALCSIZE) {`|
|interaction|[L330](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_controller.cpp#L330)|`} else if (message == WM_NCACTIVATE) {`|
|interaction|[L389](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_controller.cpp#L389)|`} else if (message == WM_NCHITTEST) {`|

### FlClash/plugins/window/windows/window_style.cpp

用途：native-ui：WindowCornerPreference, SystemBackdropType, AccentState。复用：`packages/platform/vendor/window/windows/window_style.cpp`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L56](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L56)|`using SetWindowCompositionAttributeFn =`|
|rendering|[L59](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L59)|`SetWindowCompositionAttributeFn GetSetWindowCompositionAttribute() {`|
|rendering|[L60](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L60)|`static const SetWindowCompositionAttributeFn function = [] {`|
|rendering|[L64](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L64)|`: reinterpret_cast<SetWindowCompositionAttributeFn>(`|
|rendering|[L66](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L66)|`"SetWindowCompositionAttribute"));`|
|rendering|[L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L96)|`// SetWindowCompositionAttribute takes its color as ABGR.`|
|rendering|[L132](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L132)|`// The accent effects need the undocumented SetWindowCompositionAttribute,`|
|rendering|[L135](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L135)|`const bool has_accent = GetSetWindowCompositionAttribute() != nullptr;`|
|rendering|[L217](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L217)|`::DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE,`|
|rendering|[L222](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L222)|`::DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop_type,`|
|rendering|[L226](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L226)|`::DwmSetWindowAttribute(hwnd, DWMWA_MICA_EFFECT, &mica, sizeof(mica));`|
|rendering|[L236](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L236)|`::DwmSetWindowAttribute(hwnd, attribute, &dark, sizeof(dark));`|
|rendering|[L250](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L250)|`GetSetWindowCompositionAttribute();`|
|platform|[L217](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L217)|`::DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE,`|
|platform|[L222](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L222)|`::DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop_type,`|
|platform|[L226](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L226)|`::DwmSetWindowAttribute(hwnd, DWMWA_MICA_EFFECT, &mica, sizeof(mica));`|
|platform|[L236](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.cpp#L236)|`::DwmSetWindowAttribute(hwnd, attribute, &dark, sizeof(dark));`|

### FlClash/plugins/window/windows/window_style.h

用途：native-ui：class, class。复用：`packages/platform/vendor/window/windows/window_style.h`。状态：原样独立插件；各平台验证状态见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L48](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.h#L48)|`// Only place calling the Dwm*/SetWindowCompositionAttribute APIs.`|
|interaction|[L55](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/window/windows/window_style.h#L55)|`// strip, one physical pixel tall, that WM_NCCALCSIZE leaves. Zero while an accent effect is on,`|

### FlClash/site/assets/app.js

用途：website：t, el, svg, animate, locale, formatAgo, formatSize, goArch, buildsFor, resolveBuilds, detectDevice, guessMacArch, loadData, applyStaticText, renderReleaseMeta, starFormat, countUp, renderCta, moveInk, selectTab, wireTabs, fileRow, commandBlock, tip, extrasFor, renderPanel, setPlatform, setArch, matchVersion, stageReveal, appendReleases, renderTimeline, updateMore, showMore, revealHash, copyText, effectiveTheme, syncShot, laneWipe, toggleTheme, rememberLang, anchorAtTop, carryView, takeCarriedView, setLang, wireGlyph, splitWordmark, wireHoverInk, wireMagnet, layoutBox, taglineBox, wireField, followScroll, wireEvents, start。复用：`source/upstream/FlClash/site；Canvas 效果与 token 已另行提取`。状态：营销页业务组合参考；独立交互待拆分。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L14)|`const springEasing = CSS.supports('transition-timing-function', 'linear(0, 1)')`|
|motion|[L280](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L280)|`requestAnimationFrame(step);`|
|motion|[L708](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L708)|`requestAnimationFrame(() => document.getElementById(tag)?.scrollIntoView());`|
|motion|[L792](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L792)|`root.animate({ clipPath: frames }, { duration: 820, easing: 'linear', pseudoElement: '::view-transition-new(root)' });`|
|motion|[L1023](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1023)|`resizeFrame = requestAnimationFrame(() => {`|
|rendering|[L173](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L173)|`const gl = document.createElement('canvas').getContext('webgl');`|
|interaction|[L47](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L47)|`else if (key.startsWith('on')) node.addEventListener(key.slice(2), value);`|
|interaction|[L340](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L340)|`seg.addEventListener('click', (event) => {`|
|interaction|[L344](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L344)|`seg.addEventListener('keydown', (event) => {`|
|interaction|[L852](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L852)|`glyph.addEventListener('animationend', (event) => {`|
|interaction|[L855](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L855)|`$('.brand').addEventListener('mouseenter', () => {`|
|interaction|[L878](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L878)|`group.addEventListener('pointerover', (event) => {`|
|interaction|[L891](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L891)|`group.addEventListener('pointerleave', () => ink.classList.remove('on'));`|
|interaction|[L896](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L896)|`button.addEventListener('pointermove', (event) => {`|
|interaction|[L904](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L904)|`button.addEventListener('pointerleave', () => {`|
|interaction|[L938](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L938)|`matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => field?.refresh());`|
|interaction|[L963](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L963)|`$('#reel').addEventListener('click', () => {`|
|interaction|[L968](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L968)|`$('#reel-track').addEventListener('transitionend', (event) => {`|
|interaction|[L973](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L973)|`$('#cta').addEventListener('click', () => field?.surge());`|
|interaction|[L975](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L975)|`$('#theme-toggle').addEventListener('click', toggleTheme);`|
|interaction|[L976](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L976)|`$('#lang-toggle').addEventListener('click', (event) => {`|
|interaction|[L987](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L987)|`$('#cl-search').addEventListener('input', (event) => {`|
|interaction|[L994](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L994)|`$('#cl-search').addEventListener('keydown', (event) => {`|
|interaction|[L1001](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1001)|`document.addEventListener('keydown', (event) => {`|
|interaction|[L1008](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1008)|`$('#cl-more').addEventListener('click', showMore);`|
|interaction|[L1009](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1009)|`addEventListener('hashchange', revealHash);`|
|interaction|[L1016](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1016)|`addEventListener('scroll', onScroll, { passive: true });`|
|interaction|[L1021](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/app.js#L1021)|`addEventListener('resize', () => {`|

### FlClash/site/assets/field.js

用途：Canvas 胶囊场：避让、弹簧伸缩、鼠标唤起、滚动加速、可见性暂停、明暗调色。复用：`packages/web/field.js`。状态：完整 Canvas 效果；新增显式 dispose；保留原参数与绘制。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L305](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L305)|`frame = requestAnimationFrame(tick);`|
|motion|[L323](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L323)|`frame = requestAnimationFrame(tick);`|
|rendering|[L21](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L21)|`const ctx = canvas.getContext('2d');`|
|interaction|[L388](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L388)|`document.addEventListener('visibilitychange', sync);`|
|interaction|[L389](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L389)|`addEventListener(`|
|interaction|[L396](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/field.js#L396)|`addEventListener(`|

### FlClash/site/assets/style.css

用途：Dashboard 颜色、CSS blur 到 Flutter sigma 的阴影换算、排版。复用：`packages/web/tokens.css`。状态：部分提取：原始明暗颜色、字体名与 spring CSS token；营销页布局未提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L62](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L62)|`@supports (transition-timing-function: linear(0, 1)) {`|
|motion|[L249](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L249)|`transition: top 0.2s var(--ease-out);`|
|motion|[L262](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L262)|`transition: border-color 0.3s, background-color 0.3s;`|
|motion|[L349](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L349)|`transition: color 0.2s;`|
|motion|[L373](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L373)|`transition: transform 0.45s var(--spring), width 0.45s var(--spring), scale 0.5s var(--spring-pop), opacity 0.2s;`|
|motion|[L387](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L387)|`transition: transform 0.7s var(--spring-pop);`|
|motion|[L427](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L427)|`transition: color 0.2s, border-color 0.2s, background-color 0.2s;`|
|motion|[L437](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L437)|`transition: transform 0.5s var(--spring-pop);`|
|motion|[L539](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L539)|`transition: width 0.7s var(--spring);`|
|motion|[L567](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L567)|`transition: opacity 0.25s, transform 0.6s var(--spring);`|
|motion|[L602](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L602)|`transition: transform 0.6s var(--spring), background-color 0.2s, color 0.2s;`|
|motion|[L607](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L607)|`transition-duration: 0.12s;`|
|motion|[L616](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L616)|`transition: transform 0.6s var(--spring), translate 0.6s var(--spring), background-color 0.2s;`|
|motion|[L659](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L659)|`transition: transform 0.5s var(--spring);`|
|motion|[L720](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L720)|`transition: width 0.6s var(--spring-pop);`|
|motion|[L830](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L830)|`transition: color 0.2s, text-decoration-color 0.2s;`|
|motion|[L862](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L862)|`transition: color 0.25s, transform 0.5s var(--spring);`|
|motion|[L872](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L872)|`transition-duration: 0.12s;`|
|motion|[L883](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L883)|`transition: left 0.5s var(--spring), right 0.5s var(--spring);`|
|motion|[L888](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L888)|`transition-duration: 0.66s, 0.4s;`|
|motion|[L892](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L892)|`transition-duration: 0.4s, 0.66s;`|
|motion|[L940](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L940)|`transition: background-position 0.55s var(--ease-out);`|
|motion|[L951](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L951)|`transition: opacity 0.2s;`|
|motion|[L980](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L980)|`transition: transform 0.6s var(--spring-pop);`|
|motion|[L1062](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1062)|`transition: color 0.2s, background-color 0.2s;`|
|motion|[L1084](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1084)|`transition: background-color 0.25s, color 0.25s, border-color 0.25s, scale 0.6s var(--spring-pop);`|
|motion|[L1177](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1177)|`transition: color 0.2s, background-color 0.2s, transform 0.5s var(--spring);`|
|motion|[L1187](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1187)|`transition-duration: 0.12s;`|
|motion|[L1192](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1192)|`transition: opacity 0.2s, transform 0.5s var(--spring-pop);`|
|motion|[L1225](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1225)|`transition: border-color 0.2s, box-shadow 0.2s;`|
|motion|[L1266](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1266)|`transition: opacity 0.2s, scale 0.4s var(--spring-pop);`|
|motion|[L1354](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1354)|`transition: color 0.2s;`|
|motion|[L1379](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1379)|`transition: color 0.2s;`|
|motion|[L1407](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1407)|`transition: width 0.6s var(--spring-pop), background-color 0.2s;`|
|motion|[L1480](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1480)|`transition: background-color 0.15s;`|
|motion|[L1507](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1507)|`transition: translate 0.5s var(--spring);`|
|motion|[L1525](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1525)|`transition: background-color 0.15s;`|
|motion|[L1538](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1538)|`transition: color 0.15s;`|
|motion|[L1566](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1566)|`transition: background-position 0.55s var(--ease-out), border-color 0.2s, transform 0.6s var(--spring);`|
|motion|[L1576](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1576)|`transition-duration: 0.12s;`|
|motion|[L1645](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1645)|`transition: color 0.2s;`|
|motion|[L1650](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1650)|`animation: rise 0.8s var(--spring) 0.05s backwards;`|
|motion|[L1654](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1654)|`animation: inch 2.6s cubic-bezier(0.65, 0, 0.35, 1) 1.2s infinite alternate;`|
|motion|[L1659](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1659)|`animation: line-up 0.9s var(--spring) 0.1s backwards;`|
|motion|[L1663](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1663)|`animation-delay: 0.4s;`|
|motion|[L1667](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1667)|`animation: letter-up 0.95s var(--spring-pop) calc(0.1s + var(--i) * 50ms) backwards;`|
|motion|[L1668](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1668)|`transition: transform 0.7s var(--spring-pop);`|
|motion|[L1673](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1673)|`transition-duration: 0.18s;`|
|motion|[L1681](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1681)|`animation: rise 0.8s var(--spring) 0.52s backwards;`|
|motion|[L1686](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1686)|`animation: rise 0.8s var(--spring) 0.6s backwards;`|
|motion|[L1690](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1690)|`animation: shot-up 1.1s var(--spring) 0.5s backwards;`|
|motion|[L1695](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1695)|`animation: drop 0.8s both;`|
|motion|[L1700](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1700)|`animation: signal-in 0.8s var(--spring-pop) backwards;`|
|motion|[L1705](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1705)|`animation: signal-wave 0.7s var(--ease-out);`|
|motion|[L1711](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1711)|`animation-delay: 0.09s;`|
|motion|[L1717](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1717)|`animation-delay: 0.18s;`|
|motion|[L1730](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1730)|`animation: rise 0.8s var(--spring) calc(var(--n, 0) * 70ms) backwards;`|
|motion|[L1750](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1750)|`animation: slant-in 0.9s var(--ease-out) 0.08s backwards;`|
|motion|[L1755](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1755)|`animation: stretch 0.9s var(--spring-pop) calc(0.25s + var(--n, 0) * 70ms) backwards;`|
|motion|[L1760](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1760)|`animation: rise 0.9s var(--spring) 0.12s backwards;`|
|motion|[L1764](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1764)|`animation: slide-in 0.7s var(--spring) backwards;`|
|motion|[L1768](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1768)|`animation: node-in 0.9s var(--spring-pop) 0.1s backwards;`|
|motion|[L1772](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1772)|`animation: lane-in 0.65s var(--spring) calc(60ms + var(--i, 0) * 26ms) backwards;`|
|motion|[L1776](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1776)|`animation: mark-in 0.7s var(--spring-pop) 0.2s backwards;`|
|motion|[L1780](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1780)|`@keyframes rise {`|
|motion|[L1787](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1787)|`@keyframes line-up {`|
|motion|[L1794](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1794)|`@keyframes letter-up {`|
|motion|[L1800](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1800)|`@keyframes shot-up {`|
|motion|[L1807](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1807)|`@keyframes inch {`|
|motion|[L1822](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1822)|`@keyframes drop {`|
|motion|[L1825](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1825)|`animation-timing-function: cubic-bezier(0.5, 0, 0.9, 0.4);`|
|motion|[L1832](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1832)|`animation-timing-function: var(--spring-pop);`|
|motion|[L1839](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1839)|`@keyframes slant-in {`|
|motion|[L1850](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1850)|`@keyframes stretch {`|
|motion|[L1856](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1856)|`@keyframes slide-in {`|
|motion|[L1863](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1863)|`@keyframes lane-in {`|
|motion|[L1870](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1870)|`@keyframes node-in {`|
|motion|[L1879](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1879)|`@keyframes mark-in {`|
|motion|[L1886](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1886)|`@keyframes signal-in {`|
|motion|[L1893](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1893)|`@keyframes signal-wave {`|
|motion|[L1899](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1899)|`::view-transition-old(root),`|
|motion|[L1900](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1900)|`::view-transition-new(root) {`|
|motion|[L1901](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1901)|`animation: none;`|
|motion|[L1912](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1912)|`:root:active-view-transition-type(lang)::view-transition-old(root) {`|
|motion|[L1913](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1913)|`animation: lang-out 220ms ease-in forwards;`|
|motion|[L1916](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1916)|`:root:active-view-transition-type(lang)::view-transition-new(root) {`|
|motion|[L1917](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1917)|`animation: lang-in 520ms cubic-bezier(0.22, 1, 0.36, 1) 80ms backwards;`|
|motion|[L1920](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1920)|`@keyframes lang-out {`|
|motion|[L1927](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1927)|`@keyframes lang-in {`|
|motion|[L1938](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1938)|`animation-duration: 0.01ms !important;`|
|motion|[L1939](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1939)|`animation-iteration-count: 1 !important;`|
|motion|[L1940](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/style.css#L1940)|`transition-duration: 0.01ms !important;`|

### FlClash/windows/runner/win32_window.cpp

用途：platform-host：WindowClassRegistrar。复用：`source/upstream/FlClash/windows`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L285](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/runner/win32_window.cpp#L285)|`DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,`|
|interaction|[L161](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/runner/win32_window.cpp#L161)|`if (message == WM_NCCREATE) {`|
|platform|[L285](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/runner/win32_window.cpp#L285)|`DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,`|

### FlClash/windows/runner/win32_window.h

用途：platform-host：Win32Window。复用：`source/upstream/FlClash/windows`。状态：平台源码参考；尚未独立验证。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L77](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/runner/win32_window.h#L77)|`// OS callback called by message pump. Handles the WM_NCCREATE message which`|

### prism_ui/lib/animated_entries.dart

用途：design-system：EntryTransitions, EntryTransition, AnimatedEntries。复用：`packages/flutter/vendor/prism_ui/lib/animated_entries.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L14](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L14)|`final TickerProvider vsync;`|
|motion|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L20)|`final _controllers = <K, AnimationController>{};`|
|motion|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L85)|`AnimationController _create(K key, double value) {`|
|motion|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L86)|`final controller = AnimationController(vsync: vsync, value: value);`|
|motion|[L133](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L133)|`static final _fade = CurveTween(curve: const Interval(0.5, 1));`|
|motion|[L134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L134)|`static final _size = CurveTween(curve: Curves.easeInOutCubic);`|
|motion|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L178)|`with TickerProviderStateMixin {`|
|motion|[L192](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L192)|`context.motionDuration(commonDuration),`|
|motion|[L224](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L224)|`animation: _transitions.animationOf(entry.key),`|
|interaction|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L87)|`controller.addStatusListener((status) {`|
|lifecycle|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L93)|`controller.dispose();`|
|lifecycle|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L101)|`void dispose() {`|
|lifecycle|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L103)|`controller.dispose();`|
|lifecycle|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L186)|`void didUpdateWidget(covariant AnimatedEntries oldWidget) {`|
|lifecycle|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L187)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L197)|`void dispose() {`|
|lifecycle|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L198)|`_transitions.dispose();`|
|lifecycle|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_entries.dart#L199)|`super.dispose();`|

### prism_ui/lib/animated_visibility.dart

用途：design-system：AnimatedVisibility。复用：`packages/flutter/vendor/prism_ui/lib/animated_visibility.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L6)|`const _transitionDuration = Duration(milliseconds: 300);`|
|motion|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L54)|`with SingleTickerProviderStateMixin {`|
|motion|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L55)|`late final AnimationController _controller;`|
|motion|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L65)|`_controller = AnimationController(`|
|motion|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L124)|`animation: _animation,`|
|motion|[L143](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L143)|`Tween(begin: motion.hiddenOffset, end: Offset.zero),`|
|interaction|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L70)|`)..addStatusListener(_handleAnimationStatus);`|
|interaction|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L113)|`_controller.removeStatusListener(_handleAnimationStatus);`|
|lifecycle|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L61)|`void initState() {`|
|lifecycle|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L62)|`super.initState();`|
|lifecycle|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L79)|`void didUpdateWidget(covariant AnimatedVisibility oldWidget) {`|
|lifecycle|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L80)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L112](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L112)|`void dispose() {`|
|lifecycle|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L114)|`_animation.dispose();`|
|lifecycle|[L115](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L115)|`_controller.dispose();`|
|lifecycle|[L116](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/animated_visibility.dart#L116)|`super.dispose();`|

### prism_ui/lib/app.dart

用途：design-system：PrismApp。复用：`packages/flutter/vendor/prism_ui/lib/app.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L101)|`MediaQuery.platformBrightnessOf(context) == Brightness.dark,`|
|platform|[L205](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L205)|`MediaQuery.textScalerOf(context);`|
|platform|[L224](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L224)|`return MediaQuery(`|
|platform|[L225](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L225)|`data: MediaQuery.of(`|
|lifecycle|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L91)|`void dispose() {`|
|lifecycle|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L92)|`_heroController.dispose();`|
|lifecycle|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/app.dart#L93)|`super.dispose();`|

### prism_ui/lib/banner.dart

用途：design-system：BannerLevel, BannerHost, BannerHostState。复用：`packages/flutter/vendor/prism_ui/lib/banner.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L17)|`const _actionMinDuration = Duration(seconds: 6);`|
|motion|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L18)|`const _queuedHold = Duration(milliseconds: 3150);`|
|motion|[L25](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L25)|`const _dropSpring = SpringDescription(mass: 1, stiffness: 256, damping: 27.2);`|
|motion|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L26)|`const _exitDuration = Duration(milliseconds: 170);`|
|motion|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L39)|`info  /  /  success => const Duration(seconds: 3),`|
|motion|[L40](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L40)|`warning => const Duration(seconds: 5),`|
|motion|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L41)|`error => const Duration(seconds: 6),`|
|motion|[L438](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L438)|`class _BannerState extends State<_Banner> with TickerProviderStateMixin {`|
|motion|[L439](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L439)|`late final AnimationController _drop;`|
|motion|[L440](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L440)|`late final AnimationController _drag;`|
|motion|[L441](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L441)|`late final AnimationController _fade;`|
|motion|[L449](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L449)|`_drop = AnimationController.unbounded(vsync: this);`|
|motion|[L450](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L450)|`_drag = AnimationController.unbounded(vsync: this);`|
|motion|[L451](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L451)|`_fade = AnimationController(value: 1, duration: _exitDuration, vsync: this);`|
|motion|[L474](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L474)|`AnimationController controller, {`|
|motion|[L480](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L480)|`.animateWith(SpringSimulation(_dropSpring, from, to, velocity))`|
|motion|[L491](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L491)|`_fade.animateBack(0, curve: Curves.easeIn);`|
|motion|[L494](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L494)|`.animateTo(0, duration: _exitDuration, curve: Curves.easeIn)`|
|motion|[L567](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L567)|`animation: _motion,`|
|motion|[L588](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L588)|`animation: _motion,`|
|interaction|[L66](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L66)|`required this.onTap,`|
|interaction|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L72)|`final VoidCallback? onTap;`|
|interaction|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L76)|`if (onTap == null  /  /  duration >= _actionMinDuration) {`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L135)|`/// A banner with [onTap] runs it when tapped, as an iOS notification`|
|interaction|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L140)|`VoidCallback? onTap,`|
|interaction|[L149](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L149)|`onTap: onTap,`|
|interaction|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L170)|`onTap: message.onTap,`|
|interaction|[L201](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L201)|`if (_held.contains(oldest.id) && oldest.message.onTap == null) {`|
|interaction|[L319](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L319)|`final onTap = message.onTap;`|
|interaction|[L330](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L330)|`onTap: onTap == null`|
|interaction|[L334](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L334)|`onTap();`|
|interaction|[L417](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L417)|`required this.onTap,`|
|interaction|[L430](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L430)|`final VoidCallback? onTap;`|
|interaction|[L551](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L551)|`child: GestureDetector(`|
|interaction|[L553](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L553)|`onTap: widget.onTap,`|
|platform|[L344](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L344)|`MediaQuery.viewPaddingOf(context).top + widget.topInset,`|
|platform|[L353](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L353)|`builder: (_, entries, _) => LayoutBuilder(`|
|lifecycle|[L123](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L123)|`void dispose() {`|
|lifecycle|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L126)|`_entriesNotifier.dispose();`|
|lifecycle|[L127](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L127)|`super.dispose();`|
|lifecycle|[L447](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L447)|`void initState() {`|
|lifecycle|[L448](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L448)|`super.initState();`|
|lifecycle|[L465](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L465)|`void didUpdateWidget(covariant _Banner oldWidget) {`|
|lifecycle|[L466](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L466)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L540](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L540)|`void dispose() {`|
|lifecycle|[L541](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L541)|`_drop.dispose();`|
|lifecycle|[L542](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L542)|`_drag.dispose();`|
|lifecycle|[L543](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L543)|`_fade.dispose();`|
|lifecycle|[L544](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/banner.dart#L544)|`super.dispose();`|

### prism_ui/lib/bar_item_presence.dart

用途：导航栏标题、按钮、底栏跨路由位置与显隐衔接。复用：`packages/flutter/vendor/prism_ui/lib/bar_item_presence.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L17)|`final _presenceSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L18)|`duration: const Duration(milliseconds: 416),`|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L29)|`final _titleSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L30)|`duration: const Duration(milliseconds: 330),`|
|motion|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L34)|`final _pulseUp = SpringSimulation(`|
|motion|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L35)|`SpringDescription.withDurationAndBounce(`|
|motion|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L36)|`duration: const Duration(milliseconds: 292),`|
|motion|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L43)|`final _pulseDownAcross = SpringSimulation(`|
|motion|[L44](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L44)|`SpringDescription.withDurationAndBounce(`|
|motion|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L45)|`duration: const Duration(milliseconds: 416),`|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L52)|`final _pulseDownDown = SpringSimulation(`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L53)|`SpringDescription.withDurationAndBounce(`|
|motion|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L54)|`duration: const Duration(milliseconds: 416),`|
|motion|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L64)|`const _pulseLength = Duration(milliseconds: 900);`|
|motion|[L66](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L66)|`double _springAt(Simulation spring, double time) =>`|
|motion|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L128)|`with TickerProviderStateMixin {`|
|motion|[L134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L134)|`late final _presence = AnimationController.unbounded(vsync: this)`|
|motion|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L136)|`late final _swap = AnimationController.unbounded(vsync: this, value: 1)`|
|motion|[L138](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L138)|`late final _pulse = AnimationController(vsync: this, duration: _pulseLength)`|
|motion|[L301](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L301)|`_presence.animateWith(`|
|motion|[L302](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L302)|`SpringSimulation(`|
|motion|[L371](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L371)|`_swap.animateWith(`|
|motion|[L372](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L372)|`SpringSimulation(_presenceSpring, from, 1, 0, snapToEnd: true),`|
|motion|[L863](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L863)|`animation: scope.presence,`|
|motion|[L869](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L869)|`animation: scope.swap,`|
|rendering|[L1](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1)|`import 'dart:ui' show ImageFilter;`|
|rendering|[L456](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L456)|`final box = context.findRenderObject() as RenderBox?;`|
|rendering|[L497](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L497)|`: (context.findRenderObject()! as RenderBox).size;`|
|rendering|[L622](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L622)|`class _RenderSlotProbe extends RenderProxyBox {`|
|rendering|[L681](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L681)|`class _RenderLiftedItem extends RenderProxyBox {`|
|rendering|[L806](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L806)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|rendering|[L884](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L884)|`return ImageFiltered(`|
|rendering|[L886](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L886)|`imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),`|
|rendering|[L941](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L941)|`class _RenderPresence extends RenderProxyBox {`|
|rendering|[L1076](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1076)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L135)|`..addStatusListener(_handlePresenceStatus);`|
|interaction|[L137](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L137)|`..addStatusListener(_handleSwapStatus);`|
|interaction|[L139](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L139)|`..addStatusListener(_handlePresenceStatus);`|
|interaction|[L210](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L210)|`_motion?.removeListener(_handleMotion);`|
|interaction|[L211](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L211)|`_covering?.removeListener(_handleMotion);`|
|interaction|[L222](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L222)|`_motion = route?.barItems?..addListener(_handleMotion);`|
|interaction|[L224](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L224)|`_covering = route?.secondaryAnimation?..addListener(_handleMotion);`|
|interaction|[L245](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L245)|`_motion?.removeListener(_handleMotion);`|
|interaction|[L246](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L246)|`_covering?.removeListener(_handleMotion);`|
|interaction|[L712](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L712)|`_follow?.removeListener(markNeedsPaint);`|
|interaction|[L713](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L713)|`value?.addListener(markNeedsPaint);`|
|interaction|[L734](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L734)|`_follow?.addListener(markNeedsPaint);`|
|interaction|[L739](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L739)|`_follow?.removeListener(markNeedsPaint);`|
|interaction|[L959](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L959)|`_presence.removeListener(_handlePresence);`|
|interaction|[L960](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L960)|`value.addListener(_handlePresence);`|
|interaction|[L972](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L972)|`_pulse.removeListener(_handlePresence);`|
|interaction|[L973](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L973)|`value.addListener(_handlePresence);`|
|interaction|[L1021](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1021)|`_presence.addListener(_handlePresence);`|
|interaction|[L1022](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1022)|`_pulse.addListener(_handlePresence);`|
|interaction|[L1028](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1028)|`_presence.removeListener(_handlePresence);`|
|interaction|[L1029](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1029)|`_pulse.removeListener(_handlePresence);`|
|lifecycle|[L191](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L191)|`void initState() {`|
|lifecycle|[L192](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L192)|`super.initState();`|
|lifecycle|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L197)|`void didChangeDependencies() {`|
|lifecycle|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L198)|`super.didChangeDependencies();`|
|lifecycle|[L235](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L235)|`void didUpdateWidget(BarItemPresence oldWidget) {`|
|lifecycle|[L236](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L236)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L243](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L243)|`void dispose() {`|
|lifecycle|[L247](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L247)|`_filled.dispose();`|
|lifecycle|[L248](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L248)|`_presence.dispose();`|
|lifecycle|[L249](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L249)|`_swap.dispose();`|
|lifecycle|[L250](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L250)|`_pulse.dispose();`|
|lifecycle|[L251](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L251)|`super.dispose();`|
|lifecycle|[L744](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L744)|`void dispose() {`|
|lifecycle|[L746](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L746)|`super.dispose();`|
|lifecycle|[L1034](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1034)|`void dispose() {`|
|lifecycle|[L1036](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/bar_item_presence.dart#L1036)|`super.dispose();`|

### prism_ui/lib/builder.dart

用途：design-system：WidthWidgetBuilder, WidthBuilder, MemoBuilder。复用：`packages/flutter/vendor/prism_ui/lib/builder.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L8](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L8)|`/// where a [LayoutBuilder] would rebuild every row below it on every frame.`|
|platform|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L23)|`return LayoutBuilder(`|
|lifecycle|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L64)|`void didChangeDependencies() {`|
|lifecycle|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L65)|`super.didChangeDependencies();`|
|lifecycle|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L70)|`void didUpdateWidget(MemoBuilder oldWidget) {`|
|lifecycle|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/builder.dart#L71)|`super.didUpdateWidget(oldWidget);`|

### prism_ui/lib/button.dart

用途：design-system：MoreActionButton, TonalButtonSize, TonalButtonGroup, TonalButton, TonalButtonTheme。复用：`packages/flutter/vendor/prism_ui/lib/button.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L67](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L67)|`final _markSlide = SpringDescription.withDampingRatio(`|
|motion|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L72)|`final _markFade = SpringDescription.withDurationAndBounce(`|
|motion|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L73)|`duration: const Duration(milliseconds: 380),`|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L93)|`with TickerProviderStateMixin {`|
|motion|[L159](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L159)|`_HoverMark(TickerProvider vsync)`|
|motion|[L160](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L160)|`: _travel = AnimationController.unbounded(vsync: vsync, value: 1),`|
|motion|[L161](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L161)|`_shown = AnimationController.unbounded(vsync: vsync);`|
|motion|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L163)|`final AnimationController _travel;`|
|motion|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L164)|`final AnimationController _shown;`|
|motion|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L197)|`AnimationController controller,`|
|motion|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L199)|`SpringDescription spring,`|
|motion|[L201](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L201)|`controller.animateWith(`|
|motion|[L202](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L202)|`SpringSimulation(spring, controller.value, target, controller.velocity),`|
|rendering|[L168](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L168)|`RenderBox? _box;`|
|rendering|[L174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L174)|`void enter(Object slot, RenderBox box) {`|
|rendering|[L211](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L211)|`if (box == null  /  /  !box.attached  /  /  area is! RenderBox) {`|
|rendering|[L269](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L269)|`class _HoverMarkPainter extends CustomPainter {`|
|rendering|[L282](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L282)|`canvas.drawPath(`|
|rendering|[L326](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L326)|`widget.mark.enter(this, context.findRenderObject()! as RenderBox);`|
|interaction|[L133](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L133)|`? Listener(`|
|interaction|[L134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L134)|`onPointerDown: _handlePointerDown,`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L135)|`onPointerUp: _handlePointerEnd,`|
|interaction|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L136)|`onPointerCancel: _handlePointerEnd,`|
|interaction|[L348](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L348)|`return MouseRegion(`|
|interaction|[L461](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L461)|`final iconPane = goo`|
|interaction|[L485](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L485)|`backgroundBuilder: feedback(iconPane),`|
|lifecycle|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L98)|`void dispose() {`|
|lifecycle|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L99)|`_pointer.dispose();`|
|lifecycle|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L100)|`_mark?.dispose();`|
|lifecycle|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L101)|`super.dispose();`|
|lifecycle|[L263](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L263)|`void dispose() {`|
|lifecycle|[L264](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L264)|`_travel.dispose();`|
|lifecycle|[L265](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L265)|`_shown.dispose();`|
|lifecycle|[L333](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L333)|`void didUpdateWidget(_HoverSlot oldWidget) {`|
|lifecycle|[L334](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L334)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L341](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L341)|`void dispose() {`|
|lifecycle|[L343](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/button.dart#L343)|`super.dispose();`|

### prism_ui/lib/card.dart

用途：design-system：Info, InfoHeader, Card, SkipTraversalFocusNode。复用：`packages/flutter/vendor/prism_ui/lib/card.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L218](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card.dart#L218)|`onKeyEvent: enterActionsOnRight ? _enterActionOnRight : null,`|
|interaction|[L234](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card.dart#L234)|`static KeyEventResult _enterActionOnRight(FocusNode _, KeyEvent event) {`|
|interaction|[L236](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card.dart#L236)|`event.logicalKey != LogicalKeyboardKey.arrowRight) {`|
|interaction|[L263](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card.dart#L263)|`class SkipTraversalFocusNode extends FocusNode {`|

### prism_ui/lib/card_surface.dart

用途：design-system：PressLook, CardSurface, RenderCardSurface。复用：`packages/flutter/vendor/prism_ui/lib/card_surface.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L93)|`transition: transition,`|
|rendering|[L496](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L496)|`Size Function(RenderBox child, BoxConstraints constraints) layoutChild,`|
|rendering|[L563](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L563)|`double Function(RenderBox child, double extent) measure,`|
|rendering|[L704](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L704)|`canvas.drawPath(`|
|interaction|[L44](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L44)|`this.onTap,`|
|interaction|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L45)|`this.onPointerDown,`|
|interaction|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L46)|`this.onPointerEnd,`|
|interaction|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L47)|`this.onHover,`|
|interaction|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L80)|`final VoidCallback? onTap;`|
|interaction|[L81](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L81)|`final ValueChanged<PointerDownEvent>? onPointerDown;`|
|interaction|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L82)|`final ValueChanged<PointerEvent>? onPointerEnd;`|
|interaction|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L83)|`final ValueChanged<bool>? onHover;`|
|interaction|[L109](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L109)|`..onTap = onTap`|
|interaction|[L110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L110)|`..onPointerDown = onPointerDown`|
|interaction|[L111](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L111)|`..onPointerEnd = onPointerEnd`|
|interaction|[L112](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L112)|`..onHover = onHover;`|
|interaction|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L140)|`..onTap = onTap`|
|interaction|[L141](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L141)|`..onPointerDown = onPointerDown`|
|interaction|[L142](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L142)|`..onPointerEnd = onPointerEnd`|
|interaction|[L143](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L143)|`..onHover = onHover;`|
|interaction|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L198)|`VoidCallback? onTap;`|
|interaction|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L199)|`ValueChanged<PointerDownEvent>? onPointerDown;`|
|interaction|[L200](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L200)|`ValueChanged<PointerEvent>? onPointerEnd;`|
|interaction|[L201](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L201)|`ValueChanged<bool>? onHover;`|
|interaction|[L266](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L266)|`_transition.removeListener(markNeedsPaint);`|
|interaction|[L267](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L267)|`value.addListener(markNeedsPaint);`|
|interaction|[L280](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L280)|`_pressed.removeListener(_handlePress);`|
|interaction|[L281](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L281)|`value.addListener(_handlePress);`|
|interaction|[L308](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L308)|`_sparkles?.removeListener(markNeedsPaint);`|
|interaction|[L309](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L309)|`value?.addListener(markNeedsPaint);`|
|interaction|[L450](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L450)|`onHover?.call(hovered);`|
|interaction|[L473](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L473)|`_transition.addListener(markNeedsPaint);`|
|interaction|[L474](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L474)|`_pressed.addListener(_handlePress);`|
|interaction|[L475](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L475)|`_sparkles?.addListener(markNeedsPaint);`|
|interaction|[L481](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L481)|`_transition.removeListener(markNeedsPaint);`|
|interaction|[L482](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L482)|`_pressed.removeListener(_handlePress);`|
|interaction|[L483](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L483)|`_sparkles?.removeListener(markNeedsPaint);`|
|interaction|[L614](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L614)|`RenderSemanticsGestureHandler(:final onTap) => onTap != null,`|
|interaction|[L615](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L615)|`SemanticsAnnotationsMixin(:final properties) => properties.onTap != null,`|
|interaction|[L639](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L639)|`onPointerDown?.call(event);`|
|interaction|[L642](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L642)|`onPointerEnd?.call(event);`|
|interaction|[L755](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L755)|`if (_interactive && onTap != null) {`|
|interaction|[L756](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L756)|`config.onTap = onTap;`|
|lifecycle|[L489](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L489)|`void dispose() {`|
|lifecycle|[L491](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/card_surface.dart#L491)|`super.dispose();`|

### prism_ui/lib/checkbox.dart

用途：design-system：Checkbox。复用：`packages/flutter/vendor/prism_ui/lib/checkbox.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L21)|`static const _duration = Duration(milliseconds: 150);`|
|motion|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L51)|`tween: Tween(end: checked ? 1 : 0),`|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L52)|`duration: context.motionDuration(_duration),`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L53)|`curve: Curves.easeOut,`|
|rendering|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L77)|`class _CheckPainter extends CustomPainter {`|
|rendering|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L98)|`canvas.drawPath(`|
|rendering|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L124)|`canvas.drawPath(`|
|interaction|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/checkbox.dart#L46)|`onTap: enabled ? () => onChanged(value != true) : null,`|

### prism_ui/lib/chip.dart

用途：design-system：Chip, TonalChip, MetaChip。复用：`packages/flutter/vendor/prism_ui/lib/chip.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/chip.dart#L136)|`MediaQuery.textScalerOf(context).scale(fontSize) * _capHeightPerEm;`|

### prism_ui/lib/collapsible_section.dart

用途：design-system：SliverCollapsibleSection, CollapsibleGroup, SliverCollapsibleGroups, CollapsibleHeader, UnfoldEntryTransition。复用：`packages/flutter/vendor/prism_ui/lib/collapsible_section.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L95)|`with TickerProviderStateMixin {`|
|motion|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L101)|`final _controllers = <Object, AnimationController>{};`|
|motion|[L107](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L107)|`final controller = _controllers[key] ??= AnimationController(`|
|motion|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L187)|`animation: animation,`|
|motion|[L280](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L280)|`static final _turns = Tween<double>(begin: -0.25, end: 0);`|
|motion|[L370](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L370)|`static const duration = Duration(milliseconds: 240);`|
|motion|[L386](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L386)|`static CurvedAnimation curveOf(AnimationController controller) =>`|
|motion|[L389](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L389)|`curve: Curves.easeOutCubic,`|
|motion|[L390](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L390)|`reverseCurve: Curves.easeInCubic,`|
|motion|[L400](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L400)|`Tween(begin: Offset(0, -index - 0.5), end: Offset.zero),`|
|motion|[L404](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L404)|`CurveTween(curve: Interval(start, start + _fade)),`|
|interaction|[L111](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L111)|`)..addStatusListener((status) => _settle(key, status));`|
|interaction|[L304](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L304)|`child: GestureDetector(`|
|interaction|[L306](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L306)|`onTap: widget.onToggle,`|
|platform|[L173](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L173)|`final height = MediaQuery.sizeOf(context).height;`|
|lifecycle|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L125)|`_motions.remove(key)!.dispose();`|
|lifecycle|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L126)|`controller.dispose();`|
|lifecycle|[L139](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L139)|`void didUpdateWidget(SliverCollapsibleGroups oldWidget) {`|
|lifecycle|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L140)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L153](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L153)|`void dispose() {`|
|lifecycle|[L155](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L155)|`motion.dispose();`|
|lifecycle|[L158](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L158)|`controller.dispose();`|
|lifecycle|[L160](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/collapsible_section.dart#L160)|`super.dispose();`|

### prism_ui/lib/common_button.dart

用途：design-system：ButtonLayerBuilder, ButtonStyle, ButtonThemeData, ButtonTheme, IconButton, TextButton, FilledButton, OutlinedButton。复用：`packages/flutter/vendor/prism_ui/lib/common_button.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L595](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L595)|`_states.addListener(_handleStates);`|
|platform|[L355](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L355)|`MediaQuery.textScalerOf(context).scale(textStyle.fontSize ?? 14) / 14;`|
|platform|[L380](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L380)|`MediaQuery.textScalerOf(`|
|lifecycle|[L592](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L592)|`void initState() {`|
|lifecycle|[L593](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L593)|`super.initState();`|
|lifecycle|[L599](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L599)|`void didUpdateWidget(_StyledButton oldWidget) {`|
|lifecycle|[L600](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L600)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L605](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L605)|`void dispose() {`|
|lifecycle|[L606](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L606)|`_states.dispose();`|
|lifecycle|[L607](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/common_button.dart#L607)|`super.dispose();`|

### prism_ui/lib/context.dart

用途：design-system：BuildContextExtension。复用：`packages/flutter/vendor/prism_ui/lib/context.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context.dart#L52)|`Duration motionDuration(Duration duration) =>`|
|platform|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context.dart#L12)|`bool get isMobileView => ViewScope.isMobileOf(this, listen: false);`|
|platform|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context.dart#L30)|`: MediaQuery.paddingOf(this).top + pageToolbarHeight);`|
|platform|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context.dart#L46)|`BottomInsetScope.of(this) + MediaQuery.paddingOf(this).bottom;`|
|platform|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context.dart#L50)|`bool get disableAnimations => MediaQuery.disableAnimationsOf(this);`|

### prism_ui/lib/context_menu.dart

用途：design-system：ContextMenuRegion。复用：`packages/flutter/vendor/prism_ui/lib/context_menu.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L96)|`navigatorBox is! RenderBox  /  / `|
|rendering|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L97)|`box is! RenderBox  /  / `|
|rendering|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L125)|`if (box is! RenderBox  /  /  !box.hasSize) {`|
|interaction|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L34)|`LogicalKeyboardKey? _heldKey;`|
|interaction|[L177](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L177)|`if (key == LogicalKeyboardKey.contextMenu  /  / `|
|interaction|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L178)|`(key == LogicalKeyboardKey.f10 &&`|
|interaction|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L198)|`onKeyEvent: enabled ? (_, event) => _handleKey(event) : null,`|
|interaction|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L199)|`child: RawGestureDetector(`|
|lifecycle|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L45)|`void didChangeDependencies() {`|
|lifecycle|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L46)|`super.didChangeDependencies();`|
|lifecycle|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L51)|`void didUpdateWidget(ContextMenuRegion oldWidget) {`|
|lifecycle|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L52)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L57)|`void dispose() {`|
|lifecycle|[L60](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/context_menu.dart#L60)|`super.dispose();`|

### prism_ui/lib/deferred_push.dart

用途：等待首屏布局稳定后开始转场。复用：`packages/flutter/vendor/prism_ui/lib/deferred_push.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L8](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L8)|`const arrivalHoldLimit = Duration(milliseconds: 200);`|
|motion|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L18)|`AnimationController createAnimationController() {`|
|motion|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L20)|`return AnimationController(`|
|motion|[L123](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L123)|`class _TickerCapture implements TickerProvider {`|
|lifecycle|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L74)|`void didChangeDependencies() {`|
|lifecycle|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L75)|`super.didChangeDependencies();`|
|lifecycle|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L98)|`void didUpdateWidget(ArrivalHold oldWidget) {`|
|lifecycle|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L99)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L106](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L106)|`void dispose() {`|
|lifecycle|[L108](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/deferred_push.dart#L108)|`super.dispose();`|

### prism_ui/lib/dialog.dart

用途：design-system：AlertHostRoute, AlertMotionRouteMixin, AlertDialog, AlertActions。复用：`packages/flutter/vendor/prism_ui/lib/dialog.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L35)|`const _alertDuration = Duration(milliseconds: 404);`|
|motion|[L38](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L38)|`SpringDescription.withDurationAndBounce(`|
|motion|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L39)|`duration: const Duration(milliseconds: 275),`|
|motion|[L130](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L130)|`ColorTween(begin: barrierColor.withValues(alpha: 0), end: barrierColor),`|
|motion|[L143](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L143)|`return _AlertTransition(animation: _spring, child: child);`|
|motion|[L200](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L200)|`animation: widget.animation,`|
|rendering|[L217](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L217)|`Rect _surfaceRectIn(RenderBox box) {`|
|rendering|[L258](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L258)|`class _RenderAlertGlass extends RenderProxyBox {`|
|rendering|[L539](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L539)|`class _RenderCenteredTitle extends RenderBox`|
|rendering|[L541](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L541)|`ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,`|
|rendering|[L542](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L542)|`RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {`|
|rendering|[L556](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L556)|`RenderBox get _title => firstChild!;`|
|rendering|[L558](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L558)|`RenderBox get _trailing => lastChild!;`|
|rendering|[L561](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L561)|`void setupParentData(RenderBox child) {`|
|rendering|[L755](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L755)|`class _AlertActionsParentData extends ContainerBoxParentData<RenderBox> {}`|
|rendering|[L757](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L757)|`class _RenderAlertActions extends RenderBox`|
|rendering|[L759](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L759)|`ContainerRenderObjectMixin<RenderBox, _AlertActionsParentData>,`|
|rendering|[L760](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L760)|`RenderBoxContainerDefaultsMixin<RenderBox, _AlertActionsParentData> {`|
|rendering|[L774](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L774)|`void setupParentData(RenderBox child) {`|
|rendering|[L780](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L780)|`bool _sideBySide(List<RenderBox> children, double width) =>`|
|rendering|[L791](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L791)|`double _widest(double Function(RenderBox child) widthOf) =>`|
|rendering|[L796](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L796)|`double Function(RenderBox child, double width) heightOf,`|
|interaction|[L173](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L173)|`widget.animation.addStatusListener(_handleStatus);`|
|interaction|[L180](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L180)|`oldWidget.animation.removeStatusListener(_handleStatus);`|
|interaction|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L181)|`widget.animation.addStatusListener(_handleStatus);`|
|interaction|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L187)|`widget.animation.removeStatusListener(_handleStatus);`|
|platform|[L335](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L335)|`padding: MediaQuery.viewInsetsOf(context) + _inset,`|
|platform|[L337](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L337)|`child: MediaQuery.removeViewInsets(`|
|lifecycle|[L147](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L147)|`void dispose() {`|
|lifecycle|[L148](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L148)|`_sprung?.dispose();`|
|lifecycle|[L149](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L149)|`super.dispose();`|
|lifecycle|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L171)|`void initState() {`|
|lifecycle|[L172](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L172)|`super.initState();`|
|lifecycle|[L177](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L177)|`void didUpdateWidget(_AlertTransition oldWidget) {`|
|lifecycle|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L178)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L186)|`void dispose() {`|
|lifecycle|[L188](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L188)|`super.dispose();`|
|lifecycle|[L294](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L294)|`void dispose() {`|
|lifecycle|[L295](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L295)|`_pane.dispose();`|
|lifecycle|[L296](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/dialog.dart#L296)|`super.dispose();`|

### prism_ui/lib/drag_back.dart

用途：design-system：DragBackRouteMixin。复用：`packages/flutter/vendor/prism_ui/lib/drag_back.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L16)|`final _followSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L17)|`duration: const Duration(milliseconds: 80),`|
|motion|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L20)|`final _releaseSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L21)|`duration: const Duration(milliseconds: 300),`|
|motion|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L34)|`final Animatable<Offset> _slideTween = Tween<Offset>(`|
|motion|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L73)|`AnimationController get dragBackController => controller!;`|
|motion|[L112](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L112)|`SpringDescription dragBackFollowSpring({required bool first}) =>`|
|motion|[L162](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L162)|`ArrivingSimulation(`|
|motion|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L163)|`SpringSimulation(_releaseSpring, controller.value, target, -speed),`|
|motion|[L180](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L180)|`Future<void>? followDragBackTo(Offset target, SpringDescription spring) {`|
|motion|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L186)|`Future<void>? whenStopped(AnimationController controller) {`|
|motion|[L545](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L545)|`SpringSimulation? _x;`|
|motion|[L546](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L546)|`SpringSimulation? _y;`|
|motion|[L564](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L564)|`SpringDescription spring, {`|
|motion|[L570](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L570)|`_x = SpringSimulation(`|
|motion|[L577](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L577)|`_y = SpringSimulation(`|
|interaction|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L51)|`FocusNode? _focusBeforeDragBack;`|
|interaction|[L195](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L195)|`controller.removeStatusListener(handleStatus);`|
|interaction|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L199)|`controller.addStatusListener(handleStatus);`|
|interaction|[L203](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L203)|`FocusScopeNode? get _focusScope {`|
|interaction|[L207](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L207)|`: FocusScope.of(context, createDependency: false);`|
|interaction|[L354](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L354)|`late final DragGestureRecognizer _recognizer;`|
|interaction|[L362](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L362)|`final DragGestureRecognizer recognizer;`|
|interaction|[L436](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L436)|`return Listener(`|
|interaction|[L437](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L437)|`onPointerDown: _handlePointerDown,`|
|interaction|[L451](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L451)|`class _DragBackGestureRecognizer extends HorizontalDragGestureRecognizer`|
|platform|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L84)|`return switch (defaultTargetPlatform) {`|
|platform|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L85)|`TargetPlatform.linux  /  / `|
|platform|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L86)|`TargetPlatform.macOS  /  / `|
|platform|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L87)|`TargetPlatform.windows => computePanSlop(kind, settings),`|
|lifecycle|[L238](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L238)|`void dispose() {`|
|lifecycle|[L241](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L241)|`follower?.dispose();`|
|lifecycle|[L242](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L242)|`_dragBackOverdrag.dispose();`|
|lifecycle|[L243](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L243)|`super.dispose();`|
|lifecycle|[L359](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L359)|`void initState() {`|
|lifecycle|[L360](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L360)|`super.initState();`|
|lifecycle|[L380](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L380)|`void dispose() {`|
|lifecycle|[L381](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L381)|`_recognizer.dispose();`|
|lifecycle|[L385](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L385)|`super.dispose();`|
|lifecycle|[L635](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L635)|`void dispose() {`|
|lifecycle|[L636](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/drag_back.dart#L636)|`_ticker.dispose();`|

### prism_ui/lib/edit_menu.dart

用途：design-system：EditMenuRoute。复用：`packages/flutter/vendor/prism_ui/lib/edit_menu.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L41)|`const SpringDescription(mass: 1, stiffness: 522.9, damping: 38.87),`|
|motion|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L46)|`const SpringDescription(mass: 1, stiffness: 300, damping: 30),`|
|motion|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L82)|`Duration get transitionDuration => const Duration(milliseconds: 405);`|
|motion|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L85)|`Duration get reverseTransitionDuration => const Duration(milliseconds: 150);`|
|motion|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L96)|`final menu = _EditMenu(route: this, animation: animation);`|
|motion|[L118](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L118)|`with SingleTickerProviderStateMixin {`|
|motion|[L119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L119)|`late final AnimationController _unfold = AnimationController(`|
|motion|[L121](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L121)|`duration: const Duration(milliseconds: 450),`|
|motion|[L127](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L127)|`reverseCurve: Curves.easeIn,`|
|motion|[L420](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L420)|`animation: Listenable.merge([_opened, _unfolded]),`|
|interaction|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L140)|`widget.route.items.addListener(_foldOnNewItems);`|
|interaction|[L147](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L147)|`widget.route.items.removeListener(_foldOnNewItems);`|
|interaction|[L217](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L217)|`GestureDetector(`|
|interaction|[L220](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L220)|`onTap: () => items[i].onPressed?.call(),`|
|interaction|[L231](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L231)|`onTap: () => items[i].onPressed?.call(),`|
|interaction|[L257](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L257)|`onTap: _unfold.forward,`|
|interaction|[L285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L285)|`onTap: () => item.onPressed?.call(),`|
|interaction|[L495](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L495)|`child: Listener(`|
|interaction|[L497](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L497)|`onPointerDown: (_) => route._dismiss(),`|
|interaction|[L498](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L498)|`onPointerPanZoomStart: (_) => route._dismiss(),`|
|interaction|[L499](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L499)|`onPointerSignal: (_) => route._dismiss(),`|
|platform|[L157](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L157)|`textScaler: MediaQuery.textScalerOf(context),`|
|platform|[L359](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L359)|`final padding = MediaQuery.paddingOf(context);`|
|platform|[L360](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L360)|`final inset = MediaQuery.viewInsetsOf(context);`|
|platform|[L507](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L507)|`child: LayoutBuilder(`|
|lifecycle|[L138](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L138)|`void initState() {`|
|lifecycle|[L139](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L139)|`super.initState();`|
|lifecycle|[L146](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L146)|`void dispose() {`|
|lifecycle|[L148](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L148)|`_opened.dispose();`|
|lifecycle|[L149](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L149)|`_unfolded.dispose();`|
|lifecycle|[L150](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L150)|`_unfold.dispose();`|
|lifecycle|[L151](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L151)|`super.dispose();`|
|lifecycle|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/edit_menu.dart#L170)|`painter.dispose();`|

### prism_ui/lib/effect.dart

用途：design-system：ExpandIcon。复用：`packages/flutter/vendor/prism_ui/lib/effect.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L19)|`with SingleTickerProviderStateMixin {`|
|motion|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L20)|`late AnimationController _animationController;`|
|motion|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L23)|`static final Animatable<double> _iconTurnTween = Tween<double>(`|
|motion|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L26)|`).chain(CurveTween(curve: Curves.fastOutSlowIn));`|
|motion|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L31)|`_animationController = AnimationController(`|
|motion|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L32)|`duration: const Duration(milliseconds: 200),`|
|motion|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L62)|`animation: _animationController.view,`|
|motion|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L77)|`animation: animation,`|
|motion|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L79)|`final double animValue = Curves.easeInOut.transform(animation.value);`|
|lifecycle|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L29)|`void initState() {`|
|lifecycle|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L30)|`super.initState();`|
|lifecycle|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L42)|`void didUpdateWidget(covariant ExpandIcon oldWidget) {`|
|lifecycle|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L43)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L54)|`void dispose() {`|
|lifecycle|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L55)|`_animationController.dispose();`|
|lifecycle|[L56](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/effect.dart#L56)|`super.dispose();`|

### prism_ui/lib/fade_box.dart

用途：design-system：FadeBox, FadeThroughBox, FadeScaleBox, FadeScaleEnterBox, FadeSlideEnterTransition, FadeScaleEnterTransition。复用：`packages/flutter/vendor/prism_ui/lib/fade_box.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L18)|`switchInCurve: Curves.easeOut,`|
|motion|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L19)|`switchOutCurve: Curves.easeIn,`|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L29)|`animation: animation,`|
|motion|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L33)|`duration: context.motionDuration(commonDuration),`|
|motion|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L49)|`duration: context.motionDuration(commonDuration),`|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L52)|`animation: animation,`|
|motion|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L77)|`switchOutCurve: Curves.easeOutBack,`|
|motion|[L78](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L78)|`switchInCurve: Curves.easeInBack,`|
|motion|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L83)|`scale: animation.drive(Tween(begin: 0.4, end: 1.0)),`|
|motion|[L110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L110)|`with SingleTickerProviderStateMixin, _EnterAnimation {`|
|motion|[L112](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L112)|`late final AnimationController _controller;`|
|motion|[L119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L119)|`_controller = AnimationController(vsync: this, duration: commonDuration);`|
|motion|[L120](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L120)|`_curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);`|
|motion|[L121](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L121)|`_animation = Tween<double>(begin: 0, end: 1).animate(_curve);`|
|motion|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L136)|`return FadeScaleEnterTransition(animation: _animation, child: widget.child);`|
|motion|[L141](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L141)|`AnimationController get _controller;`|
|motion|[L175](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L175)|`static final Animatable<double> _fadeInTransition = CurveTween(`|
|motion|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L178)|`static final Animatable<double> _slideInCurve = CurveTween(`|
|motion|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L187)|`final slide = Tween<Offset>(`|
|motion|[L194](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L194)|`animation: slide,`|
|motion|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L213)|`static final Animatable<double> _fadeInTransition = CurveTween(`|
|motion|[L216](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L216)|`static final Animatable<double> _scaleInTransition = Tween<double>(`|
|motion|[L219](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L219)|`).chain(CurveTween(curve: Easing.legacyDecelerate));`|
|lifecycle|[L117](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L117)|`void initState() {`|
|lifecycle|[L118](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L118)|`super.initState();`|
|lifecycle|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L125)|`void dispose() {`|
|lifecycle|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L126)|`_curve.dispose();`|
|lifecycle|[L127](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L127)|`_controller.dispose();`|
|lifecycle|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L128)|`super.dispose();`|
|lifecycle|[L145](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L145)|`void didChangeDependencies() {`|
|lifecycle|[L146](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_box.dart#L146)|`super.didChangeDependencies();`|

### prism_ui/lib/fade_through.dart

用途：design-system：PageTransitionSwitcherLayoutBuilder, PageTransitionSwitcherTransitionBuilder, PageTransitionSwitcher, FadeThroughTransition。复用：`packages/flutter/vendor/prism_ui/lib/fade_through.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L12)|`final AnimationController primaryController;`|
|motion|[L14](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L14)|`final AnimationController secondaryController;`|
|motion|[L44](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L44)|`this.duration = const Duration(milliseconds: 300),`|
|motion|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L70)|`with TickerProviderStateMixin {`|
|motion|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L125)|`final primaryController = AnimationController(`|
|motion|[L129](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L129)|`final secondaryController = AnimationController(`|
|motion|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L163)|`required AnimationController primaryController,`|
|motion|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L164)|`required AnimationController secondaryController,`|
|motion|[L173](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L173)|`transition: KeyedSubtree.wrap(transition, _childNumber),`|
|motion|[L247](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L247)|`animation: animation,`|
|motion|[L249](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L249)|`animation: ReverseAnimation(secondaryAnimation),`|
|motion|[L265](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L265)|`animation: animation,`|
|motion|[L268](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L268)|`return _ZoomedFadeIn(animation: animation, child: child);`|
|motion|[L272](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L272)|`return _FadeOut(animation: animation, child: child);`|
|motion|[L285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L285)|`static final CurveTween _inCurve = CurveTween(`|
|motion|[L286](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L286)|`curve: const Cubic(0.0, 0.0, 0.2, 1.0),`|
|motion|[L291](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L291)|`tween: ConstantTween<double>(0.92),`|
|motion|[L295](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L295)|`tween: Tween<double>(begin: 0.92, end: 1.0).chain(_inCurve),`|
|motion|[L302](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L302)|`tween: ConstantTween<double>(0.0),`|
|motion|[L306](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L306)|`tween: Tween<double>(begin: 0.0, end: 1.0).chain(_inCurve),`|
|motion|[L326](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L326)|`static final CurveTween _outCurve = CurveTween(`|
|motion|[L327](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L327)|`curve: const Cubic(0.4, 0.0, 1.0, 1.0),`|
|motion|[L332](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L332)|`tween: Tween<double>(begin: 1.0, end: 0.0).chain(_outCurve),`|
|motion|[L336](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L336)|`tween: ConstantTween<double>(0.0),`|
|interaction|[L177](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L177)|`secondaryController.addStatusListener((AnimationStatus status) {`|
|interaction|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L187)|`primaryController.addStatusListener((AnimationStatus status) {`|
|platform|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L31)|`typedef PageTransitionSwitcherLayoutBuilder =`|
|platform|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L47)|`this.layoutBuilder = defaultLayoutBuilder,`|
|platform|[L59](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L59)|`final PageTransitionSwitcherLayoutBuilder layoutBuilder;`|
|platform|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L61)|`static Widget defaultLayoutBuilder(List<Widget> entries) {`|
|lifecycle|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L20)|`void dispose() {`|
|lifecycle|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L21)|`primaryController.dispose();`|
|lifecycle|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L22)|`secondaryController.dispose();`|
|lifecycle|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L76)|`void initState() {`|
|lifecycle|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L77)|`super.initState();`|
|lifecycle|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L82)|`void didUpdateWidget(PageTransitionSwitcher oldWidget) {`|
|lifecycle|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L83)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L183](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L183)|`entry.dispose();`|
|lifecycle|[L193](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L193)|`entry.dispose();`|
|lifecycle|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L213)|`void dispose() {`|
|lifecycle|[L215](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L215)|`entry.dispose();`|
|lifecycle|[L217](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/fade_through.dart#L217)|`super.dispose();`|

### prism_ui/lib/focus.dart

用途：design-system：PageFocusScope, RemoteFocusAdapter。复用：`packages/flutter/vendor/prism_ui/lib/focus.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L17)|`class PageFocusScope extends StatefulWidget {`|
|interaction|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L20)|`const PageFocusScope({super.key, required this.child});`|
|interaction|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L23)|`State<PageFocusScope> createState() => _PageFocusScopeState();`|
|interaction|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L26)|`class _PageFocusScopeState extends State<PageFocusScope> {`|
|interaction|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L27)|`final FocusScopeNode _node = FocusScopeNode()`|
|interaction|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L39)|`return FocusScope.withExternalFocusNode(`|
|interaction|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L47)|`LogicalKeyboardKey.select,`|
|interaction|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L48)|`LogicalKeyboardKey.enter,`|
|interaction|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L49)|`LogicalKeyboardKey.numpadEnter,`|
|interaction|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L50)|`LogicalKeyboardKey.gameButtonA,`|
|interaction|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L100)|`child: FocusTraversalGroup(`|
|lifecycle|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L32)|`void dispose() {`|
|lifecycle|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L33)|`_node.dispose();`|
|lifecycle|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L34)|`super.dispose();`|
|lifecycle|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L79)|`void initState() {`|
|lifecycle|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L80)|`super.initState();`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L85)|`void dispose() {`|
|lifecycle|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus.dart#L87)|`super.dispose();`|

### prism_ui/lib/focus_arrow_keys.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/focus_arrow_keys.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L71)|`final duration = context.motionDuration(commonDuration);`|
|motion|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L75)|`position.animateTo(`|
|motion|[L78](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L78)|`curve: Curves.easeOutCubic,`|
|interaction|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L16)|`KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {`|
|interaction|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L21)|`LogicalKeyboardKey.arrowUp => TraversalDirection.up,`|
|interaction|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L22)|`LogicalKeyboardKey.arrowDown => TraversalDirection.down,`|
|interaction|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L23)|`LogicalKeyboardKey.arrowLeft => TraversalDirection.left,`|
|interaction|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L24)|`LogicalKeyboardKey.arrowRight => TraversalDirection.right,`|
|interaction|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L48)|`void _scrollIfFocusStays(FocusNode focus, TraversalDirection direction) {`|
|interaction|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L131)|`FocusTraversalGroup.maybeOf(context) ==`|
|interaction|[L132](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L132)|`FocusTraversalGroup.maybeOf(position.context.storageContext);`|
|interaction|[L166](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_arrow_keys.dart#L166)|`onKeyEvent: _handleKeyEvent,`|

### prism_ui/lib/focus_keyboard.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/focus_keyboard.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L19)|`FocusNode? _outgoing;`|
|interaction|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L26)|`widget.floatingKeyboard?.addListener(_handleFloatingKeyboard);`|
|interaction|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L27)|`FocusManager.instance.addListener(_handleFocusChange);`|
|interaction|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L35)|`oldWidget.floatingKeyboard?.removeListener(_handleFloatingKeyboard);`|
|interaction|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L36)|`widget.floatingKeyboard?.addListener(_handleFloatingKeyboard);`|
|interaction|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L42)|`widget.floatingKeyboard?.removeListener(_handleFloatingKeyboard);`|
|interaction|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L43)|`FocusManager.instance.removeListener(_handleFocusChange);`|
|interaction|[L56](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L56)|`void _watchOutgoing(FocusNode? node) {`|
|interaction|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L57)|`_outgoing?.removeListener(_holdKeyboard);`|
|interaction|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L58)|`_outgoing = node?..addListener(_holdKeyboard);`|
|interaction|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L124)|`static EditableTextState? _editableOf(FocusNode? focus) {`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L135)|`KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {`|
|interaction|[L157](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L157)|`return Listener(`|
|interaction|[L158](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L158)|`onPointerDown: (_) => _usingRemote = false,`|
|interaction|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L163)|`onKeyEvent: _handleKeyEvent,`|
|platform|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L86)|`(View.maybeOf(context)?.viewInsets.bottom ?? 0) > 0;`|
|platform|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L113)|`MediaQueryData _withFloatingKeyboard(MediaQueryData data) {`|
|platform|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L114)|`if (!_keyboardFloating  /  /  data.viewInsets.bottom > 0) {`|
|platform|[L118](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L118)|`viewInsets: data.viewInsets.copyWith(`|
|platform|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L164)|`child: MediaQuery(`|
|platform|[L165](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L165)|`data: _withFloatingKeyboard(MediaQuery.of(context)),`|
|lifecycle|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L24)|`void initState() {`|
|lifecycle|[L25](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L25)|`super.initState();`|
|lifecycle|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L32)|`void didUpdateWidget(_RemoteKeyboard oldWidget) {`|
|lifecycle|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L33)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L41)|`void dispose() {`|
|lifecycle|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_keyboard.dart#L45)|`super.dispose();`|

### prism_ui/lib/focus_landing.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/focus_landing.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L18)|`FocusManager.instance.addListener(_handleFocusChange);`|
|interaction|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L23)|`FocusManager.instance.removeListener(_handleFocusChange);`|
|interaction|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L36)|`if (focus is FocusScopeNode && focus.focusedChild == null) {`|
|interaction|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L43)|`static NavigatorState? _navigatorOfCoveredRoute(FocusNode focus) {`|
|interaction|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L46)|`if (node is FocusScopeNode &&`|
|interaction|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L55)|`static FocusScopeNode? _topRouteScope(NavigatorState navigator) {`|
|interaction|[L56](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L56)|`Iterable<FocusScopeNode> childScopes(FocusNode node) sync* {`|
|interaction|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L58)|`if (child is FocusScopeNode) {`|
|lifecycle|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L16)|`void initState() {`|
|lifecycle|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L17)|`super.initState();`|
|lifecycle|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L22)|`void dispose() {`|
|lifecycle|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_landing.dart#L24)|`super.dispose();`|

### prism_ui/lib/focus_moved_by_key.dart

用途：design-system：FocusMovedByKey。复用：`packages/flutter/vendor/prism_ui/lib/focus_moved_by_key.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_moved_by_key.dart#L10)|`LogicalKeyboardKey.arrowUp,`|
|interaction|[L11](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_moved_by_key.dart#L11)|`LogicalKeyboardKey.arrowDown,`|
|interaction|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_moved_by_key.dart#L12)|`LogicalKeyboardKey.arrowLeft,`|
|interaction|[L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_moved_by_key.dart#L13)|`LogicalKeyboardKey.arrowRight,`|
|interaction|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_moved_by_key.dart#L57)|`if (key == LogicalKeyboardKey.tab  /  / `|

### prism_ui/lib/focus_traversal.dart

用途：design-system：PageTraversalPolicy。复用：`packages/flutter/vendor/prism_ui/lib/focus_traversal.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L189](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L189)|`if (box is RenderBox &&`|
|interaction|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L10)|`bool inDirection(FocusNode currentNode, TraversalDirection direction) {`|
|interaction|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L31)|`FocusScopeNode scope,`|
|interaction|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L48)|`FocusNode? _findOutside(`|
|interaction|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L49)|`FocusScopeNode scope,`|
|interaction|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L72)|`FocusNode node,`|
|interaction|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L73)|`FocusScopeNode scope,`|
|interaction|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L74)|`FocusScopeNode level,`|
|interaction|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L87)|`bool inDirection(FocusNode currentNode, TraversalDirection direction) {`|
|interaction|[L94](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L94)|`final own = <FocusNode>[];`|
|interaction|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L95)|`final other = <FocusNode>[];`|
|interaction|[L102](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L102)|`if (FocusTraversalGroup.maybeOfNode(node) == this) {`|
|interaction|[L104](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L104)|`} else if (node is! FocusScopeNode && _isOnScreen(node)) {`|
|interaction|[L123](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L123)|`mixin _CrossScopeFocus on FocusTraversalPolicy {`|
|interaction|[L127](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L127)|`FocusScopeNode from,`|
|interaction|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L128)|`FocusNode target,`|
|interaction|[L134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L134)|`FocusTraversalGroup.maybeOfNode(target)?.invalidateScopeData(targetScope);`|
|interaction|[L148](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L148)|`bool _isRemote(FocusNode node) =>`|
|interaction|[L169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L169)|`bool _isUncovered(FocusNode node, FocusScopeNode scope) {`|
|interaction|[L174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L174)|`if (ancestor is FocusScopeNode && ancestor.skipTraversal) {`|
|interaction|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L181)|`bool _isOnScreen(FocusNode node) {`|
|interaction|[L203](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L203)|`FocusNode? _nearestInDirection(`|
|interaction|[L205](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/focus_traversal.dart#L205)|`Iterable<FocusNode> nodes,`|

### prism_ui/lib/font.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/font.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L8](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/font.dart#L8)|`const _hanFamilies = <TargetPlatform, Map<_HanVariant, List<String>>>{`|
|platform|[L9](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/font.dart#L9)|`TargetPlatform.windows: {`|
|platform|[L15](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/font.dart#L15)|`TargetPlatform.macOS: {`|
|platform|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/font.dart#L21)|`TargetPlatform.linux: {`|
|platform|[L69](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/font.dart#L69)|`required TargetPlatform platform,`|

### prism_ui/lib/form_sheet.dart

用途：design-system：FormSheetRoute。复用：`packages/flutter/vendor/prism_ui/lib/form_sheet.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/form_sheet.dart#L91)|`final keyboard = MediaQuery.viewInsetsOf(context).bottom;`|
|platform|[L116](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/form_sheet.dart#L116)|`builder: (context) => MediaQuery.removeViewInsets(`|
|lifecycle|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/form_sheet.dart#L71)|`void dispose() {`|
|lifecycle|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/form_sheet.dart#L72)|`_dismissHandler.dispose();`|
|lifecycle|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/form_sheet.dart#L73)|`super.dispose();`|

### prism_ui/lib/goo.dart

用途：相邻液滴融合、轮廓及自定义 RenderObject 绘制。复用：`packages/flutter/vendor/prism_ui/lib/goo.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L76)|`class _RenderGooPane extends RenderProxyBox {`|
|rendering|[L141](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L141)|`class _RenderGooSurface extends RenderProxyBox {`|
|rendering|[L235](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L235)|`canvas.drawPath(path.shift(offset), Paint()..color = _color);`|
|rendering|[L312](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L312)|`canvas.drawPath(path.shift(shadow.offset), shadow.toPaint());`|
|rendering|[L324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L324)|`outline.addRSuperellipse(`|
|rendering|[L350](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L350)|`..addRSuperellipse(`|
|rendering|[L355](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L355)|`..addRSuperellipse(`|
|lifecycle|[L196](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L196)|`void dispose() {`|
|lifecycle|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L197)|`_pane.dispose();`|
|lifecycle|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/goo.dart#L198)|`super.dispose();`|

### prism_ui/lib/icons/animated_glyph.dart

用途：design-system：AnimatedGlyph。复用：`packages/flutter/vendor/prism_ui/lib/icons/animated_glyph.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L7)|`const _fillDuration = Duration(milliseconds: 350);`|
|motion|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L21)|`with TickerProviderStateMixin {`|
|motion|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L22)|`late final AnimationController _controller = AnimationController(`|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L29)|`curve: Curves.easeInOutCubic,`|
|motion|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L31)|`late final AnimationController _pop = AnimationController(`|
|motion|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L64)|`animation: _animation,`|
|lifecycle|[L38](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L38)|`void didUpdateWidget(covariant AnimatedGlyph oldWidget) {`|
|lifecycle|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L39)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L54)|`void dispose() {`|
|lifecycle|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L55)|`_fill.dispose();`|
|lifecycle|[L56](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L56)|`_controller.dispose();`|
|lifecycle|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L57)|`_pop.dispose();`|
|lifecycle|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/animated_glyph.dart#L58)|`super.dispose();`|

### prism_ui/lib/icons/caption_icon.dart

用途：design-system：CaptionGlyph, CaptionIcon。复用：`packages/flutter/vendor/prism_ui/lib/icons/caption_icon.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/caption_icon.dart#L27)|`class _CaptionGlyphPainter extends CustomPainter {`|
|rendering|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/caption_icon.dart#L49)|`canvas.drawRSuperellipse(`|
|rendering|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/caption_icon.dart#L62)|`canvas.drawRSuperellipse(`|
|rendering|[L68](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/caption_icon.dart#L68)|`canvas.drawRSuperellipse(`|

### prism_ui/lib/icons/glyph.dart

用途：design-system：GlyphRole, Glyph, GlyphShape, GlyphBox, GlyphCircle, GlyphOval, GlyphArc, GlyphLink, GlyphPath, GlyphVertex, GlyphPolyline。复用：`packages/flutter/vendor/prism_ui/lib/icons/glyph.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph.dart#L45)|`..addRSuperellipse(`|

### prism_ui/lib/icons/glyph_painter.dart

用途：design-system：GlyphPainter。复用：`packages/flutter/vendor/prism_ui/lib/icons/glyph_painter.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L17)|`class GlyphPainter extends CustomPainter {`|
|rendering|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L54)|`canvas.saveLayer(`|
|rendering|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L77)|`canvas.drawPath(shape.path, paintFor(shape));`|
|rendering|[L89](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L89)|`canvas.drawPath(body, Paint()..color = color);`|
|rendering|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L96)|`canvas.drawPath(body, _stroke(color, reach * 2));`|
|rendering|[L109](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L109)|`canvas.drawPath(`|
|rendering|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyph_painter.dart#L131)|`canvas.drawPath(path, paint);`|

### prism_ui/lib/icons/glyphs.dart

用途：design-system：Glyphs。复用：`packages/flutter/vendor/prism_ui/lib/icons/glyphs.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyphs.dart#L4)|`import 'package:flutter/foundation.dart' show kIsWeb;`|
|platform|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyphs.dart#L284)|`static Glyph backFor(TargetPlatform platform) {`|
|platform|[L285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyphs.dart#L285)|`if (kIsWeb) {`|
|platform|[L289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/icons/glyphs.dart#L289)|`TargetPlatform.iOS  /  /  TargetPlatform.macOS => chevronBack,`|

### prism_ui/lib/inherited.dart

用途：design-system：PageActivityScope, BottomInsetScope, TopInsetScope, FloatingBarScope, ItemPositionProvider, ProxyDecoratorProvider, SheetProvider, SheetOverhangScope, SheetDismissHandler, SheetDismissScope, SheetScrollScope, SheetScrollControllerFactory。复用：`packages/flutter/vendor/prism_ui/lib/inherited.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/inherited.dart#L7)|`class PageActivityScope extends InheritedWidget {`|
|lifecycle|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/inherited.dart#L10)|`const PageActivityScope({`|
|lifecycle|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/inherited.dart#L18)|`.dependOnInheritedWidgetOfExactType<PageActivityScope>()`|
|lifecycle|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/inherited.dart#L24)|`bool updateShouldNotify(PageActivityScope oldWidget) {`|

### prism_ui/lib/input.dart

用途：design-system：SecretTextFormField, InputDialog, FilledInputTheme。复用：`packages/flutter/vendor/prism_ui/lib/input.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L16)|`final FocusNode? focusNode;`|
|lifecycle|[L138](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L138)|`void initState() {`|
|lifecycle|[L139](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L139)|`super.initState();`|
|lifecycle|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L163)|`void dispose() {`|
|lifecycle|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L164)|`_textController.dispose();`|
|lifecycle|[L165](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/input.dart#L165)|`super.dispose();`|

### prism_ui/lib/keyboard.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/keyboard.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard.dart#L6)|`SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {`|
|platform|[L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard.dart#L7)|`final control = Platform.isMacOS ? false : true;`|

### prism_ui/lib/keyboard_inset_hold.dart

用途：design-system：KeyboardInsetHold。复用：`packages/flutter/vendor/prism_ui/lib/keyboard_inset_hold.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L23)|`FocusNode? _enclosingFocus;`|
|interaction|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L28)|`FocusManager.instance.addListener(_handleFocusChange);`|
|interaction|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L33)|`FocusManager.instance.removeListener(_handleFocusChange);`|
|interaction|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L48)|`focus is! FocusScopeNode &&`|
|platform|[L69](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L69)|`final data = MediaQuery.of(context);`|
|platform|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L71)|`viewInset: data.viewInsets.bottom,`|
|platform|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L76)|`return MediaQuery(`|
|platform|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L80)|`viewInsets: data.viewInsets.copyWith(bottom: held.viewInset),`|
|lifecycle|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L26)|`void initState() {`|
|lifecycle|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L27)|`super.initState();`|
|lifecycle|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L32)|`void dispose() {`|
|lifecycle|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L34)|`super.dispose();`|
|lifecycle|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyboard_inset_hold.dart#L58)|`PageActivityScope.isActiveOf(context);`|

### prism_ui/lib/keyed_animated_list.dart

用途：design-system：KeyedAnimatedList。复用：`packages/flutter/vendor/prism_ui/lib/keyed_animated_list.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L6)|`const _defaultDuration = Duration(milliseconds: 300);`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L53)|`with SingleTickerProviderStateMixin {`|
|motion|[L59](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L59)|`late final AnimationController _transition =`|
|motion|[L60](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L60)|`AnimationController(vsync: this, duration: widget.duration)`|
|motion|[L68](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L68)|`curve: Curves.easeOutCubic,`|
|motion|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L72)|`curve: Curves.easeInCubic,`|
|motion|[L182](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L182)|`child: _RowPresence(animation: animation, child: row),`|
|motion|[L216](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L216)|`animation: shown,`|
|motion|[L248](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L248)|`with SingleTickerProviderStateMixin {`|
|motion|[L249](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L249)|`late final AnimationController _controller = AnimationController(`|
|motion|[L278](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L278)|`final AnimationController controller;`|
|motion|[L309](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L309)|`AnimationController _controller;`|
|motion|[L317](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L317)|`required AnimationController controller,`|
|motion|[L321](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L321)|`set controller(AnimationController value) {`|
|motion|[L388](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L388)|`return _delta * (1 - Curves.easeOutCubic.transform(_controller.value));`|
|rendering|[L307](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L307)|`class _RenderSlideOnMove extends RenderProxyBox {`|
|rendering|[L410](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L410)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|interaction|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L61)|`..addStatusListener((status) {`|
|interaction|[L325](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L325)|`_controller.removeListener(markNeedsPaint);`|
|interaction|[L326](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L326)|`_controller = value..addListener(markNeedsPaint);`|
|interaction|[L351](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L351)|`_controller.removeListener(markNeedsPaint);`|
|interaction|[L358](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L358)|`_controller.addListener(markNeedsPaint);`|
|lifecycle|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L76)|`void initState() {`|
|lifecycle|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L77)|`super.initState();`|
|lifecycle|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L84)|`void didUpdateWidget(covariant KeyedAnimatedList<T> oldWidget) {`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L85)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L93)|`void dispose() {`|
|lifecycle|[L94](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L94)|`_entering.dispose();`|
|lifecycle|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L95)|`_leaving.dispose();`|
|lifecycle|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L96)|`_transition.dispose();`|
|lifecycle|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L97)|`super.dispose();`|
|lifecycle|[L255](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L255)|`void didUpdateWidget(covariant _SlideOnMove oldWidget) {`|
|lifecycle|[L256](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L256)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L261](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L261)|`void dispose() {`|
|lifecycle|[L262](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L262)|`_controller.dispose();`|
|lifecycle|[L263](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/keyed_animated_list.dart#L263)|`super.dispose();`|

### prism_ui/lib/line_chart.dart

用途：design-system：LineChart。复用：`packages/flutter/vendor/prism_ui/lib/line_chart.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L140)|`class _LineChartPainter extends CustomPainter {`|
|rendering|[L207](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L207)|`..drawPath(area, fillPaint)`|
|rendering|[L208](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L208)|`..drawPath(line, _strokePaint)`|
|lifecycle|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L41)|`void initState() {`|
|lifecycle|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L42)|`super.initState();`|
|lifecycle|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L49)|`void didUpdateWidget(LineChart oldWidget) {`|
|lifecycle|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/line_chart.dart#L50)|`super.didUpdateWidget(oldWidget);`|

### prism_ui/lib/linear_progress.dart

用途：design-system：LinearProgressIndicator。复用：`packages/flutter/vendor/prism_ui/lib/linear_progress.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L25](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L25)|`with SingleTickerProviderStateMixin {`|
|motion|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L26)|`static const _indeterminate = Duration(milliseconds: 1800);`|
|motion|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L28)|`late final _controller = AnimationController(`|
|motion|[L108](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L108)|`curve: Cubic(0.2, 0, 0.8, 1),`|
|motion|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L113)|`curve: Cubic(0.4, 0, 1, 1),`|
|motion|[L118](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L118)|`curve: Cubic(0, 0, 0.65, 1),`|
|motion|[L123](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L123)|`curve: Cubic(0.1, 0, 0.45, 1),`|
|rendering|[L89](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L89)|`class _LinearProgressPainter extends CustomPainter {`|
|rendering|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L131)|`canvas.drawRSuperellipse(`|
|lifecycle|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L34)|`void initState() {`|
|lifecycle|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L35)|`super.initState();`|
|lifecycle|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L42)|`void didUpdateWidget(LinearProgressIndicator oldWidget) {`|
|lifecycle|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L43)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L52)|`void dispose() {`|
|lifecycle|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L53)|`_controller.dispose();`|
|lifecycle|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/linear_progress.dart#L54)|`super.dispose();`|

### prism_ui/lib/liquid_glass.dart

用途：折射、色散、雾化、边缘高光及统一背后图层捕获；保留 shader uniform 顺序。复用：`packages/flutter/vendor/prism_ui/lib/liquid_glass.dart`。状态：已提取并修复 Web 编译；见 verification.md。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L16)|`const _glowIn = Duration(milliseconds: 120);`|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L17)|`const _glowOut = Duration(milliseconds: 360);`|
|motion|[L799](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L799)|`tween: Tween(end: pressed ? 1 : 0),`|
|motion|[L800](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L800)|`duration: context.motionDuration(pressed ? _glowIn : _glowOut),`|
|motion|[L801](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L801)|`curve: Curves.easeOut,`|
|rendering|[L580](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L580)|`canvas.drawRSuperellipse(`|
|rendering|[L623](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L623)|`canvas.drawPath(`|
|rendering|[L626](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L626)|`..addRSuperellipse(shape.deflate(band.depth))`|
|rendering|[L627](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L627)|`..addRSuperellipse(shape.deflate(band.depth + band.width)),`|
|rendering|[L881](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L881)|`class _RenderLiquidGlass extends RenderProxyBox {`|
|rendering|[L1280](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1280)|`canvas.drawRSuperellipse(`|
|rendering|[L1292](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1292)|`static ui.FragmentProgram? _program;`|
|rendering|[L1300](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1300)|`static ui.FragmentProgram? request(VoidCallback onLoaded) {`|
|rendering|[L1303](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1303)|`!ui.ImageFilter.isShaderFilterSupported) {`|
|rendering|[L1333](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1333)|`static Future<ui.FragmentProgram> _load() =>`|
|rendering|[L1334](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1334)|`ui.FragmentProgram.fromAsset(_shaderAsset);`|
|rendering|[L1341](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1341)|`ui.FragmentProgram? program;`|
|rendering|[L1362](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1362)|`ui.FragmentShader? _captureShader;`|
|rendering|[L1363](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1363)|`(ui.Image, Path?, BlendMode, ui.FragmentProgram?, List<double>)? _captureKey;`|
|rendering|[L1496](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1496)|`canvas.drawPath(outline, paint);`|
|rendering|[L1498](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1498)|`canvas.drawRSuperellipse(corners.toRSuperellipse(rect), paint);`|
|rendering|[L1612](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1612)|`..drawPath(outline, fill)`|
|rendering|[L1613](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1613)|`..drawPath(outline, stroke..strokeWidth = style.rimWidth * 2)`|
|rendering|[L1614](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1614)|`..drawPath(outline, hairline..strokeWidth = _hairlineWidth * 2);`|
|rendering|[L1618](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1618)|`..drawRSuperellipse(shape, fill)`|
|rendering|[L1619](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1619)|`..drawRSuperellipse(shape.deflate(style.rimWidth / 2), stroke)`|
|rendering|[L1620](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1620)|`..drawRSuperellipse(`|
|interaction|[L958](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L958)|`old?.removeListener(_reclip);`|
|interaction|[L959](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L959)|`value?.addListener(_reclip);`|
|interaction|[L1039](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1039)|`_clipper?.addListener(_reclip);`|
|interaction|[L1044](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1044)|`_clipper?.removeListener(_reclip);`|
|lifecycle|[L1049](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1049)|`void dispose() {`|
|lifecycle|[L1050](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1050)|`_pane.dispose();`|
|lifecycle|[L1051](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1051)|`super.dispose();`|
|lifecycle|[L1252](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1252)|`void dispose() {`|
|lifecycle|[L1369](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1369)|`void dispose() {`|
|lifecycle|[L1370](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1370)|`_frost?.dispose();`|
|lifecycle|[L1372](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1372)|`super.dispose();`|
|lifecycle|[L1438](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1438)|`_frost?.dispose();`|
|lifecycle|[L1565](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1565)|`_captureShader?.dispose();`|
|lifecycle|[L1573](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass.dart#L1573)|`_captured?.dispose();`|

### prism_ui/lib/liquid_glass_capture.dart

用途：design-system：LiquidGlassCapture, LiquidGlassHost, LiquidGlassFade, LiquidGlassVeil。复用：`packages/flutter/vendor/prism_ui/lib/liquid_glass_capture.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L113)|`class _RenderLiquidGlassFade extends RenderProxyBox {`|
|rendering|[L210](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L210)|`class _RenderLiquidGlassVeil extends RenderProxyBox {`|
|rendering|[L308](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L308)|`class _RenderLiquidGlassHost extends RenderProxyBox {`|
|rendering|[L724](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L724)|`ui.ImageFilter.isShaderFilterSupported;`|
|rendering|[L749](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L749)|`canvas.saveLayer(`|
|rendering|[L752](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L752)|`..imageFilter = ui.ImageFilter.blur(`|
|rendering|[L938](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L938)|`ImageFilterLayer()  /  / `|
|rendering|[L940](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L940)|`BackdropFilterLayer() => true,`|
|rendering|[L1089](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L1089)|`canvas.saveLayer(null, paint);`|
|rendering|[L1110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L1110)|`ImageFilterLayer(:final imageFilter?) => (`|
|interaction|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L124)|`_opacity.removeListener(_handleOpacity);`|
|interaction|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L125)|`value.addListener(_handleOpacity);`|
|interaction|[L151](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L151)|`_opacity.addListener(_handleOpacity);`|
|interaction|[L157](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L157)|`_opacity.removeListener(_handleOpacity);`|
|interaction|[L221](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L221)|`_color.removeListener(markNeedsPaint);`|
|interaction|[L222](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L222)|`value.addListener(markNeedsPaint);`|
|interaction|[L234](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L234)|`_color.addListener(markNeedsPaint);`|
|interaction|[L239](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L239)|`_color.removeListener(markNeedsPaint);`|
|platform|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L72)|`devicePixelRatio: MediaQuery.devicePixelRatioOf(context),`|
|lifecycle|[L162](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L162)|`void dispose() {`|
|lifecycle|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L164)|`super.dispose();`|
|lifecycle|[L244](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L244)|`void dispose() {`|
|lifecycle|[L246](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L246)|`super.dispose();`|
|lifecycle|[L374](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L374)|`void dispose() {`|
|lifecycle|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L376)|`super.dispose();`|
|lifecycle|[L411](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L411)|`void dispose() {`|
|lifecycle|[L417](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L417)|`atlas.image.dispose();`|
|lifecycle|[L420](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L420)|`super.dispose();`|
|lifecycle|[L482](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L482)|`_atlases.removeLast().image.dispose();`|
|lifecycle|[L716](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L716)|`picture.dispose();`|
|lifecycle|[L771](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L771)|`picture.dispose();`|
|lifecycle|[L775](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L775)|`picture.dispose();`|
|lifecycle|[L779](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/liquid_glass_capture.dart#L779)|`previous.image.dispose();`|

### prism_ui/lib/list_row.dart

用途：design-system：ListRowAlignment, ListRow。复用：`packages/flutter/vendor/prism_ui/lib/list_row.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L105](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L105)|`extends SlottedMultiChildRenderObjectWidget<_Slot, RenderBox> {`|
|rendering|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L178)|`class _RenderListRow extends RenderBox`|
|rendering|[L179](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L179)|`with SlottedContainerRenderObjectMixin<_Slot, RenderBox> {`|
|rendering|[L206](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L206)|`RenderBox? get _leading => childForSlot(_Slot.leading);`|
|rendering|[L207](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L207)|`RenderBox get _title => childForSlot(_Slot.title)!;`|
|rendering|[L208](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L208)|`RenderBox? get _subtitle => childForSlot(_Slot.subtitle);`|
|rendering|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L209)|`RenderBox? get _trailing => childForSlot(_Slot.trailing);`|
|rendering|[L212](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L212)|`Iterable<RenderBox> get children => [`|
|rendering|[L320](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L320)|`double Function(RenderBox box, double height) measure,`|
|rendering|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L376)|`void Function(RenderBox child, Offset offset)? position,`|
|platform|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row.dart#L47)|`final safe = MediaQuery.paddingOf(context);`|

### prism_ui/lib/list_row_separator.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/list_row_separator.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L66](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L66)|`class _RenderListRowSeparatorStart extends RenderProxyBox {`|
|rendering|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L90)|`class _RenderListRowSeparator extends RenderProxyBox {`|
|interaction|[L146](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L146)|`_states.removeListener(_updateHighlighted);`|
|interaction|[L147](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L147)|`value.addListener(_updateHighlighted);`|
|interaction|[L266](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L266)|`_states.addListener(_updateHighlighted);`|
|interaction|[L267](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L267)|`FocusMovedByKey.instance.addListener(_updateHighlighted);`|
|interaction|[L275](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L275)|`_states.removeListener(_updateHighlighted);`|
|interaction|[L276](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L276)|`FocusMovedByKey.instance.removeListener(_updateHighlighted);`|
|platform|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L33)|`devicePixelRatio: MediaQuery.devicePixelRatioOf(context),`|
|platform|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_row_separator.dart#L49)|`..devicePixelRatio = MediaQuery.devicePixelRatioOf(context);`|

### prism_ui/lib/list_selected.dart

用途：design-system：DecorationListItem, SelectedDecorationListItem。复用：`packages/flutter/vendor/prism_ui/lib/list_selected.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_selected.dart#L75)|`child: LayoutBuilder(`|
|lifecycle|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_selected.dart#L49)|`void dispose() {`|
|lifecycle|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_selected.dart#L50)|`_states.dispose();`|
|lifecycle|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/list_selected.dart#L51)|`super.dispose();`|

### prism_ui/lib/loading.dart

用途：design-system：ActivityPresence, ActivityIndicator, LoadingBar。复用：`packages/flutter/vendor/prism_ui/lib/loading.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L52)|`with SingleTickerProviderStateMixin {`|
|motion|[L59](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L59)|`late final AnimationController _progress = AnimationController(`|
|motion|[L119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L119)|`static const _duration = Duration(milliseconds: 240);`|
|motion|[L137](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L137)|`return Curves.easeOutCubic.transform(elapsed / _duration.inMilliseconds);`|
|motion|[L151](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L151)|`static const loop = Duration(milliseconds: 3200);`|
|motion|[L227](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L227)|`static const loop = Duration(milliseconds: 1200);`|
|motion|[L236](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L236)|`static const _hopCurve = Cubic(0.3, 0, 0.3, 1);`|
|motion|[L349](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L349)|`class _LoadingBarState extends State<LoadingBar> with TickerProviderStateMixin {`|
|motion|[L350](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L350)|`late final AnimationController _presence = AnimationController(`|
|motion|[L352](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L352)|`duration: const Duration(milliseconds: 240),`|
|motion|[L353](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L353)|`reverseDuration: const Duration(milliseconds: 200),`|
|motion|[L358](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L358)|`curve: Curves.easeOutCubic,`|
|motion|[L359](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L359)|`reverseCurve: Curves.easeInOut,`|
|motion|[L361](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L361)|`late final AnimationController _loop = AnimationController(`|
|motion|[L363](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L363)|`duration: const Duration(milliseconds: 1800),`|
|motion|[L434](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L434)|`static const _leadCurve = Cubic(0.65, 0.8, 0.35, 0.95);`|
|motion|[L435](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L435)|`static const _trailCurve = Cubic(0.15, 0.55, 0.5, 1);`|
|rendering|[L144](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L144)|`class _ArcPainter extends CustomPainter {`|
|rendering|[L218](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L218)|`class _RelayPainter extends CustomPainter {`|
|rendering|[L299](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L299)|`canvas.drawRSuperellipse(`|
|rendering|[L317](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L317)|`canvas.drawPath(_shapes[i], solid);`|
|rendering|[L424](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L424)|`class _LoadingBarPainter extends CustomPainter {`|
|rendering|[L498](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L498)|`canvas.drawRSuperellipse(`|
|interaction|[L355](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L355)|`)..addStatusListener(_handlePresence);`|
|lifecycle|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L72)|`void dispose() {`|
|lifecycle|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L73)|`_progress.dispose();`|
|lifecycle|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L74)|`super.dispose();`|
|lifecycle|[L367](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L367)|`void initState() {`|
|lifecycle|[L368](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L368)|`super.initState();`|
|lifecycle|[L375](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L375)|`void didUpdateWidget(LoadingBar oldWidget) {`|
|lifecycle|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L376)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L396](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L396)|`void dispose() {`|
|lifecycle|[L397](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L397)|`_height.dispose();`|
|lifecycle|[L398](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L398)|`_presence.dispose();`|
|lifecycle|[L399](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L399)|`_loop.dispose();`|
|lifecycle|[L400](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/loading.dart#L400)|`super.dispose();`|

### prism_ui/lib/measure.dart

用途：design-system：Measure, MeasureScope。复用：`packages/flutter/vendor/prism_ui/lib/measure.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/measure.dart#L39)|`textPainter.dispose();`|

### prism_ui/lib/metrics.dart

用途：design-system：AdaptiveSizeExt。复用：`packages/flutter/vendor/prism_ui/lib/metrics.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/metrics.dart#L31)|`const midDuration = Duration(milliseconds: 200);`|
|motion|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/metrics.dart#L32)|`const commonDuration = Duration(milliseconds: 300);`|
|platform|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/metrics.dart#L12)|`1 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 0.5;`|

### prism_ui/lib/motion.dart

用途：design-system：SpringCurve, ArrivingSimulation。复用：`packages/flutter/vendor/prism_ui/lib/motion.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L6)|`const fadeTabDuration = Duration(milliseconds: 220);`|
|motion|[L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L7)|`const fadeTabCurve = Curves.easeInOut;`|
|motion|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L12)|`SpringCurve(SpringDescription spring, {required this.seconds})`|
|motion|[L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L13)|`: _simulation = SpringSimulation(spring, 0, 1, 0);`|
|motion|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L16)|`final SpringSimulation _simulation;`|
|motion|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L28)|`? Duration(microseconds: Duration.microsecondsPerSecond ~/ rate)`|
|motion|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L33)|`class ArrivingSimulation extends Simulation {`|
|motion|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L34)|`ArrivingSimulation(this.simulation, {required this.end})`|
|motion|[L38](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L38)|`final Simulation simulation;`|
|motion|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/motion.dart#L54)|`final dropletSpring = SpringDescription.withDampingRatio(`|

### prism_ui/lib/navigation_bar.dart

用途：design-system：NavigationDestination, NavigationBar。复用：`packages/flutter/vendor/prism_ui/lib/navigation_bar.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L68](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L68)|`static const _motion = Duration(milliseconds: 500);`|
|motion|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L90)|`tween: Tween(end: selected ? 1 : 0),`|
|motion|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L91)|`duration: context.motionDuration(_motion),`|
|motion|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L92)|`curve: Curves.easeInOutCubicEmphasized,`|
|interaction|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L45)|`onTap: () => onDestinationSelected(index),`|
|interaction|[L60](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L60)|`required this.onTap,`|
|interaction|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L65)|`final VoidCallback onTap;`|
|interaction|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_bar.dart#L79)|`onTap: onTap,`|

### prism_ui/lib/navigation_dock.dart

用途：液滴选中、弹性按压、悬停、浮动导航及原始物理参数。复用：`packages/flutter/vendor/prism_ui/lib/navigation_dock.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L62)|`const _flingProjection = Duration(milliseconds: 100);`|
|motion|[L63](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L63)|`final _trackSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L64)|`duration: const Duration(milliseconds: 120),`|
|motion|[L66](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L66)|`final _pressSpring = SpringDescription.withDampingRatio(`|
|motion|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L71)|`final _followSpring = SpringDescription.withDampingRatio(`|
|motion|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L76)|`final _liftSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L77)|`duration: const Duration(milliseconds: 250),`|
|motion|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L79)|`final _travelSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L80)|`duration: const Duration(milliseconds: 400),`|
|motion|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L83)|`final _jellySpring = SpringDescription.withDampingRatio(`|
|motion|[L88](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L88)|`final _settleSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L89](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L89)|`duration: const Duration(milliseconds: 500),`|
|motion|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L92)|`final _hoverSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L93)|`duration: const Duration(milliseconds: 260),`|
|motion|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L96)|`final _fadeSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L97)|`duration: const Duration(milliseconds: 200),`|
|motion|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L99)|`final _glowInSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L100)|`duration: const Duration(milliseconds: 100),`|
|motion|[L102](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L102)|`final _glowOutSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L103)|`duration: const Duration(milliseconds: 500),`|
|motion|[L153](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L153)|`/// [AnimationController.animateWith] restarts its ticker, whose first frame`|
|motion|[L157](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L157)|`_Spring(TickerProvider vsync, this._value, {this.rest = 1e-3}) {`|
|motion|[L166](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L166)|`SpringSimulation? _simulation;`|
|motion|[L167](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L167)|`SpringDescription? _spring;`|
|motion|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L187)|`void springTo(double target, SpringDescription spring) {`|
|motion|[L188](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L188)|`_simulation = SpringSimulation(`|
|motion|[L515](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L515)|`with TickerProviderStateMixin`|
|motion|[L644](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L644)|`animation: _motion,`|
|motion|[L891](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L891)|`with TickerProviderStateMixin {`|
|motion|[L1097](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1097)|`void _settleSwell(SpringDescription spring) {`|
|motion|[L1351](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1351)|`animation: _motion,`|
|motion|[L1360](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1360)|`animation: _hoverMotion,`|
|motion|[L1372](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1372)|`animation: _motion,`|
|motion|[L1379](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1379)|`animation: _motion,`|
|motion|[L1399](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1399)|`animation: _barMotion,`|
|rendering|[L393](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L393)|`class _RenderHitSlop extends RenderProxyBox {`|
|rendering|[L442](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L442)|`final Rect Function(RenderBox box)? panelOf;`|
|rendering|[L454](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L454)|`static Rect paintBoundsOf(RenderBox box) {`|
|rendering|[L490](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L490)|`static double liftOf(RenderBox box) {`|
|rendering|[L573](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L573)|`final box = context.findRenderObject()! as RenderBox;`|
|rendering|[L613](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L613)|`(context.findRenderObject()! as RenderBox).globalToLocal(position);`|
|rendering|[L748](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L748)|`final Rect Function(RenderBox box)? panelOf;`|
|rendering|[L771](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L771)|`class _RenderPressTransform extends RenderProxyBox {`|
|rendering|[L784](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L784)|`Rect Function(RenderBox box)? panelOf;`|
|rendering|[L1808](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1808)|`class _RenderLensTint extends RenderProxyBox {`|
|rendering|[L1994](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1994)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|rendering|[L2108](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L2108)|`..saveLayer(lensBounds.shift(offset), Paint()..colorFilter = filter);`|
|interaction|[L535](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L535)|`_lift.addListener(_settle);`|
|interaction|[L653](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L653)|`child: Listener(`|
|interaction|[L654](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L654)|`onPointerDown: _handlePointerDown,`|
|interaction|[L655](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L655)|`onPointerMove: _handlePointerMove,`|
|interaction|[L656](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L656)|`onPointerUp: _handlePointerEnd,`|
|interaction|[L657](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L657)|`onPointerCancel: _handlePointerEnd,`|
|interaction|[L700](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L700)|`return MouseRegion(`|
|interaction|[L932](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L932)|`..addListener(_wobble)`|
|interaction|[L933](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L933)|`..addListener(_dropLift);`|
|interaction|[L935](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L935)|`..addListener(_dropLift)`|
|interaction|[L936](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L936)|`..addListener(_noteLift);`|
|interaction|[L937](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L937)|`_glow.addListener(_shine);`|
|interaction|[L938](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L938)|`_glowSpread.addListener(_shine);`|
|interaction|[L939](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L939)|`_hoverAt.addListener(_leanContent);`|
|interaction|[L1203](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1203)|`HapticFeedback.selectionClick();`|
|interaction|[L1228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1228)|`HapticFeedback.selectionClick();`|
|interaction|[L1283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1283)|`child: Listener(`|
|interaction|[L1285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1285)|`onPointerDown: _handlePointerDown,`|
|interaction|[L1286](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1286)|`onPointerMove: _handlePointerMove,`|
|interaction|[L1287](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1287)|`onPointerUp: _handlePointerEnd,`|
|interaction|[L1288](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1288)|`onPointerCancel: _handlePointerEnd,`|
|interaction|[L1289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1289)|`child: MouseRegion(`|
|interaction|[L1290](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1290)|`onHover: _handleHover,`|
|interaction|[L1731](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1731)|`onTap: widget.onActivate,`|
|interaction|[L1850](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1850)|`_lens.removeListener(markNeedsPaint);`|
|interaction|[L1851](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1851)|`value.addListener(markNeedsPaint);`|
|interaction|[L1872](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1872)|`_jelly.removeListener(markNeedsPaint);`|
|interaction|[L1873](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1873)|`value.addListener(markNeedsPaint);`|
|interaction|[L1885](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1885)|`_lift.removeListener(markNeedsPaint);`|
|interaction|[L1886](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1886)|`value.addListener(markNeedsPaint);`|
|interaction|[L1898](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1898)|`_parallax.removeListener(markNeedsPaint);`|
|interaction|[L1899](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1899)|`value.addListener(markNeedsPaint);`|
|interaction|[L1935](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1935)|`_lens.addListener(markNeedsPaint);`|
|interaction|[L1936](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1936)|`_jelly.addListener(markNeedsPaint);`|
|interaction|[L1937](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1937)|`_lift.addListener(markNeedsPaint);`|
|interaction|[L1938](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1938)|`_parallax.addListener(markNeedsPaint);`|
|interaction|[L1943](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1943)|`_lens.removeListener(markNeedsPaint);`|
|interaction|[L1944](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1944)|`_jelly.removeListener(markNeedsPaint);`|
|interaction|[L1945](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1945)|`_lift.removeListener(markNeedsPaint);`|
|interaction|[L1946](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1946)|`_parallax.removeListener(markNeedsPaint);`|
|platform|[L295](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L295)|`textScaler: MediaQuery.textScalerOf(context),`|
|platform|[L325](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L325)|`MediaQuery.textScalerOf(context).scale(_labelSize) -`|
|platform|[L330](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L330)|`math.max(_edgeMargin, MediaQuery.paddingOf(context).bottom);`|
|platform|[L380](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L380)|`child: RepaintBoundary(child: LayoutBuilder(builder: (_, _) => dock)),`|
|platform|[L1294](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1294)|`// Above the LayoutBuilder: rebuilding anything under one relays`|
|platform|[L1297](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1297)|`child: LayoutBuilder(`|
|lifecycle|[L230](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L230)|`void dispose() {`|
|lifecycle|[L231](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L231)|`_ticker.dispose();`|
|lifecycle|[L232](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L232)|`super.dispose();`|
|lifecycle|[L300](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L300)|`painter.dispose();`|
|lifecycle|[L533](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L533)|`void initState() {`|
|lifecycle|[L534](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L534)|`super.initState();`|
|lifecycle|[L539](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L539)|`void dispose() {`|
|lifecycle|[L540](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L540)|`_lift.dispose();`|
|lifecycle|[L541](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L541)|`_hover.dispose();`|
|lifecycle|[L542](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L542)|`_pullX.dispose();`|
|lifecycle|[L543](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L543)|`_pullY.dispose();`|
|lifecycle|[L544](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L544)|`super.dispose();`|
|lifecycle|[L693](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L693)|`void dispose() {`|
|lifecycle|[L695](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L695)|`super.dispose();`|
|lifecycle|[L929](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L929)|`void initState() {`|
|lifecycle|[L930](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L930)|`super.initState();`|
|lifecycle|[L944](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L944)|`void didUpdateWidget(covariant FloatingNavigationBar oldWidget) {`|
|lifecycle|[L945](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L945)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L955](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L955)|`void dispose() {`|
|lifecycle|[L957](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L957)|`parallax.dispose();`|
|lifecycle|[L959](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L959)|`_lens.dispose();`|
|lifecycle|[L960](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L960)|`_lift.dispose();`|
|lifecycle|[L961](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L961)|`_hover.dispose();`|
|lifecycle|[L962](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L962)|`_hoverShow.dispose();`|
|lifecycle|[L963](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L963)|`_swell.dispose();`|
|lifecycle|[L964](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L964)|`_stretch.dispose();`|
|lifecycle|[L965](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L965)|`_jelly.dispose();`|
|lifecycle|[L966](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L966)|`_glow.dispose();`|
|lifecycle|[L967](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L967)|`_glowSpread.dispose();`|
|lifecycle|[L968](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L968)|`_touchGlow.dispose();`|
|lifecycle|[L969](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L969)|`_hoverAt.dispose();`|
|lifecycle|[L970](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L970)|`super.dispose();`|
|lifecycle|[L999](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L999)|`_parallax.removeLast().dispose();`|
|lifecycle|[L1951](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1951)|`void dispose() {`|
|lifecycle|[L1957](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigation_dock.dart#L1957)|`super.dispose();`|

### prism_ui/lib/navigator.dart

用途：design-system：BaseNavigator, RootPage, FadePageRoute, CardPageRoute。复用：`packages/flutter/vendor/prism_ui/lib/navigator.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L228)|`Duration get transitionDuration => const Duration(milliseconds: 200);`|
|motion|[L231](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L231)|`Duration get reverseTransitionDuration => const Duration(milliseconds: 200);`|
|interaction|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L131)|`animation.removeStatusListener(handleStatus);`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L135)|`animation.addStatusListener(handleStatus);`|
|platform|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L16)|`if (!context.isMobileView) {`|
|platform|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L26)|`if (context.isMobileView) {`|
|lifecycle|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L65)|`void dispose() {`|
|lifecycle|[L67](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator.dart#L67)|`super.dispose();`|

### prism_ui/lib/navigator_resizable.dart

用途：design-system：NavigatorResizable, ResizableNavigatorRouteMixin。复用：`packages/flutter/vendor/prism_ui/lib/navigator_resizable.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L228)|`_LazySizeTween(`|
|motion|[L296](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L296)|`? _LazySizeTween(start: () => _contentSizes[route], end: () => from)`|
|motion|[L297](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L297)|`// Popped mid-transition: run from where the size is now.`|
|motion|[L298](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L298)|`: _LazySizeTween(`|
|motion|[L324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L324)|`_LazySizeTween(`|
|motion|[L363](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L363)|`_LazySizeTween({required this.start, required this.end});`|
|interaction|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L170)|`_interpolation?.removeListener(notifyListeners);`|
|interaction|[L175](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L175)|`_interpolation?.removeListener(notifyListeners);`|
|interaction|[L176](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L176)|`_interpolation = interpolation..addListener(notifyListeners);`|
|interaction|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L181)|`_interpolation?.removeListener(notifyListeners);`|
|interaction|[L237](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L237)|`animation.removeStatusListener(handleStatus);`|
|interaction|[L242](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L242)|`animation.removeStatusListener(handleStatus);`|
|interaction|[L247](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L247)|`animation.addStatusListener(handleStatus);`|
|interaction|[L308](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L308)|`animation.removeStatusListener(handleStatus);`|
|interaction|[L314](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L314)|`animation.addStatusListener(handleStatus);`|
|interaction|[L414](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L414)|`_preferredSize.addListener(_handlePreferredSizeChange);`|
|interaction|[L425](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L425)|`_preferredSize.removeListener(_handlePreferredSizeChange);`|
|interaction|[L426](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L426)|`_preferredSize = value..addListener(_handlePreferredSizeChange);`|
|interaction|[L447](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L447)|`_preferredSize.removeListener(_handlePreferredSizeChange);`|
|lifecycle|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L49)|`void dispose() {`|
|lifecycle|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L50)|`_sizes.dispose();`|
|lifecycle|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L51)|`super.dispose();`|
|lifecycle|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L92)|`void dispose() {`|
|lifecycle|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L95)|`super.dispose();`|
|lifecycle|[L169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L169)|`void dispose() {`|
|lifecycle|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L171)|`super.dispose();`|
|lifecycle|[L446](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L446)|`void dispose() {`|
|lifecycle|[L449](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L449)|`super.dispose();`|

### prism_ui/lib/null_status.dart

用途：design-system：Illustration, NullStatusSwitcher, NullStatus, EmptyIllustration。复用：`packages/flutter/vendor/prism_ui/lib/null_status.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L73)|`static const _exitDuration = Duration(milliseconds: 150);`|
|motion|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L74)|`static const _loadingStatusDelay = Duration(milliseconds: 400);`|
|motion|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L125)|`duration: context.motionDuration(commonDuration),`|
|motion|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L126)|`reverseDuration: context.motionDuration(_exitDuration),`|
|motion|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L128)|`switchOutCurve: Curves.easeIn,`|
|motion|[L138](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L138)|`animation: animation,`|
|motion|[L142](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L142)|`scale: animation.drive(Tween(begin: 0.92, end: 1.0)),`|
|motion|[L266](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L266)|`const _staggerStep = Duration(milliseconds: 60);`|
|motion|[L283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L283)|`with SingleTickerProviderStateMixin {`|
|motion|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L284)|`late final AnimationController _controller;`|
|motion|[L290](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L290)|`_controller = AnimationController(`|
|motion|[L324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L324)|`: _controller.drive(CurveTween(curve: Interval(start, 1)));`|
|motion|[L326](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L326)|`animation: animation,`|
|motion|[L352](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L352)|`with SingleTickerProviderStateMixin {`|
|motion|[L355](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L355)|`late final AnimationController _controller = AnimationController(`|
|motion|[L357](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L357)|`duration: const Duration(milliseconds: 900),`|
|motion|[L594](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L594)|`spun(_phase(t, 0, 0.65, Curves.easeOutBack)),`|
|motion|[L597](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L597)|`lerpDouble(0.5, 1, _phase(t, 0.1, 0.55, Curves.easeOutBack))! +`|
|motion|[L600](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L600)|`fill: _phase(t, 0.2, 0.6, Curves.easeInOutCubic),`|
|motion|[L606](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L606)|`final morph = _phase(t, begin, end, Curves.easeInOutCubic);`|
|motion|[L611](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L611)|`_phase(t, begin, begin + 0.5, Curves.easeOutBack),`|
|motion|[L617](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L617)|`final rise = _phase(t, 0.2, 0.6, Curves.easeOutBack);`|
|motion|[L623](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L623)|`fill: _phase(t, 0.3, 0.7, Curves.easeInOutCubic),`|
|motion|[L641](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L641)|`fill: _phase(t, 0.3, 0.7, Curves.easeInOutCubic),`|
|motion|[L652](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L652)|`final enter = _phase(t, begin, begin + 0.35, Curves.easeOutBack);`|
|motion|[L661](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L661)|`final enter = _phase(t, begin, begin + 0.3, Curves.easeOutBack);`|
|motion|[L670](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L670)|`final travel = _phase(t, begin, begin + 0.4, Curves.easeOutCubic);`|
|motion|[L672](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L672)|`scale: _phase(t, begin, begin + 0.3, Curves.easeOutBack),`|
|motion|[L684](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L684)|`Curve curve = Curves.linear,`|
|rendering|[L478](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L478)|`class _IllustrationPainter extends CustomPainter {`|
|rendering|[L563](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L563)|`canvas.drawRSuperellipse(`|
|rendering|[L581](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L581)|`canvas.drawPath(_wave, stroke(soft, 0.2));`|
|rendering|[L716](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L716)|`canvas.drawPath(path, Paint()..color = color);`|
|platform|[L202](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L202)|`final compact = MediaQuery.sizeOf(context).height < _compactHeight;`|
|platform|[L345](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L345)|`MediaQuery.sizeOf(context).height < _compactHeight ? 120 : 160;`|
|lifecycle|[L81](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L81)|`void initState() {`|
|lifecycle|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L82)|`super.initState();`|
|lifecycle|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L92)|`void didUpdateWidget(covariant NullStatusSwitcher oldWidget) {`|
|lifecycle|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L93)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L101)|`void dispose() {`|
|lifecycle|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L103)|`super.dispose();`|
|lifecycle|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L187)|`void initState() {`|
|lifecycle|[L188](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L188)|`super.initState();`|
|lifecycle|[L193](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L193)|`void dispose() {`|
|lifecycle|[L194](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L194)|`_controller.dispose();`|
|lifecycle|[L195](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L195)|`super.dispose();`|
|lifecycle|[L288](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L288)|`void initState() {`|
|lifecycle|[L289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L289)|`super.initState();`|
|lifecycle|[L297](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L297)|`void didChangeDependencies() {`|
|lifecycle|[L298](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L298)|`super.didChangeDependencies();`|
|lifecycle|[L309](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L309)|`void dispose() {`|
|lifecycle|[L310](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L310)|`_controller.dispose();`|
|lifecycle|[L311](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L311)|`super.dispose();`|
|lifecycle|[L366](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L366)|`void didChangeDependencies() {`|
|lifecycle|[L367](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L367)|`super.didChangeDependencies();`|
|lifecycle|[L378](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L378)|`void dispose() {`|
|lifecycle|[L379](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L379)|`_controller.dispose();`|
|lifecycle|[L380](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/null_status.dart#L380)|`super.dispose();`|

### prism_ui/lib/open_container.dart

用途：从现有元素几何打开页面、push/zoom、拖动关闭与回传值。复用：`packages/flutter/vendor/prism_ui/lib/open_container.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L166](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L166)|`final _openSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L167](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L167)|`duration: const Duration(milliseconds: 340),`|
|motion|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L170)|`final _closeSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L171)|`duration: const Duration(milliseconds: 340),`|
|motion|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L199)|`final _firstFollowSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L200](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L200)|`duration: const Duration(milliseconds: 200),`|
|motion|[L202](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L202)|`final _morphSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L203](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L203)|`duration: const Duration(milliseconds: 400),`|
|motion|[L205](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L205)|`final _chaseScaleSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L206](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L206)|`duration: const Duration(milliseconds: 420),`|
|motion|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L209)|`final _chasePlaceSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L210](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L210)|`duration: const Duration(milliseconds: 450),`|
|motion|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L213)|`final _returnSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L214](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L214)|`duration: const Duration(milliseconds: 250),`|
|motion|[L236](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L236)|`SpringDescription get openSpring => _openSpring;`|
|motion|[L239](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L239)|`SpringDescription get closeSpring => _closeSpring;`|
|motion|[L458](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L458)|`SpringDescription dragBackFollowSpring({required bool first}) =>`|
|motion|[L500](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L500)|`morph: SpringSimulation(_morphSpring, controller!.value, 0, 0),`|
|motion|[L1352](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1352)|`class _DragDismiss extends Simulation {`|
|motion|[L1364](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1364)|`final SpringSimulation morph;`|
|motion|[L1372](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1372)|`static double _pull(SpringDescription spring, double offset, double speed) =>`|
|rendering|[L620](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L620)|`final navigator = navigatorState.context.findRenderObject()! as RenderBox;`|
|rendering|[L653](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L653)|`Rect _getRect(GlobalKey key, RenderBox ancestor) {`|
|rendering|[L656](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L656)|`final RenderBox render =`|
|rendering|[L657](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L657)|`key.currentContext!.findRenderObject()! as RenderBox;`|
|rendering|[L729](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L729)|`extends SlottedMultiChildRenderObjectWidget<_Slot, RenderBox> {`|
|rendering|[L783](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L783)|`class _RenderContainerTransition extends RenderBox`|
|rendering|[L784](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L784)|`with SlottedContainerRenderObjectMixin<_Slot, RenderBox> {`|
|rendering|[L860](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L860)|`RenderBox? get _closed => childForSlot(_Slot.closed);`|
|rendering|[L861](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L861)|`RenderBox? get _open => childForSlot(_Slot.open);`|
|rendering|[L1174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1174)|`..addRSuperellipse(radius.toRSuperellipse(rect)),`|
|rendering|[L1176](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1176)|`..drawRSuperellipse(`|
|rendering|[L1265](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L1265)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|interaction|[L519](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L519)|`_dragged.addListener(_updateOpenSnapshot);`|
|interaction|[L520](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L520)|`animation!.addStatusListener(_handleOpenStatus);`|
|interaction|[L530](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L530)|`animation!.addStatusListener((AnimationStatus status) {`|
|interaction|[L591](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L591)|`..removeListener(updateBarItems)`|
|interaction|[L592](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L592)|`..removeStatusListener(_handleOpenStatus);`|
|interaction|[L889](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L889)|`..addListener(_handleChange)`|
|interaction|[L890](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L890)|`..addStatusListener(_handleStatus);`|
|interaction|[L891](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L891)|`_route._dragged.addListener(_handleChange);`|
|interaction|[L896](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L896)|`..removeListener(_handleChange)`|
|interaction|[L897](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L897)|`..removeStatusListener(_handleStatus);`|
|interaction|[L898](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L898)|`_route._dragged.removeListener(_handleChange);`|
|lifecycle|[L580](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L580)|`void dispose() {`|
|lifecycle|[L589](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L589)|`super.dispose();`|
|lifecycle|[L593](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L593)|`_dragged.dispose();`|
|lifecycle|[L594](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L594)|`_openSnapshot.dispose();`|
|lifecycle|[L595](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L595)|`_closedSnapshot.dispose();`|
|lifecycle|[L596](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L596)|`_closedRect.dispose();`|
|lifecycle|[L597](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L597)|`_hostsClosed.dispose();`|
|lifecycle|[L598](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L598)|`_closedThemes.dispose();`|
|lifecycle|[L914](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L914)|`void dispose() {`|
|lifecycle|[L920](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/open_container.dart#L920)|`super.dispose();`|

### prism_ui/lib/page_transition.dart

用途：卡片转场、被覆盖页面变换及导航元素衔接。复用：`packages/flutter/vendor/prism_ui/lib/page_transition.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L16)|`final _pushSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L17)|`duration: const Duration(milliseconds: 300),`|
|motion|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L23)|`Duration _settlingTimeOf(SpringDescription spring, double launchSpeed) {`|
|motion|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L24)|`final simulation = SpringSimulation(`|
|motion|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L35)|`return Duration(milliseconds: milliseconds);`|
|motion|[L121](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L121)|`SpringDescription get openSpring => _pushSpring;`|
|motion|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L124)|`SpringDescription get closeSpring => _pushSpring;`|
|motion|[L329](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L329)|`final simulation = SpringSimulation(`|
|motion|[L338](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L338)|`final settle = ArrivingSimulation(simulation, end: target);`|
|motion|[L340](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L340)|`? controller.animateWith(settle)`|
|motion|[L377](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L377)|`animation: kAlwaysCompleteAnimation,`|
|motion|[L396](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L396)|`animation: animation,`|
|motion|[L464](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L464)|`animation: animation,`|
|rendering|[L501](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L501)|`class _RenderCardTransition extends RenderProxyBox {`|
|rendering|[L871](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L871)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|interaction|[L259](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L259)|`_nextOverdrag?.removeListener(_copyOverdrag);`|
|interaction|[L264](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L264)|`_nextOverdrag?.addListener(_copyOverdrag);`|
|interaction|[L283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L283)|`..addListener(updateBarItems)`|
|interaction|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L284)|`..addStatusListener(_handleStatus);`|
|interaction|[L286](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L286)|`..addListener(updateBarItems)`|
|interaction|[L287](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L287)|`..addStatusListener(_handleStatus);`|
|interaction|[L289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L289)|`..addListener(_updateMotionSnapshot)`|
|interaction|[L290](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L290)|`..addListener(updateBarItems);`|
|interaction|[L296](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L296)|`..removeListener(updateBarItems)`|
|interaction|[L297](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L297)|`..removeStatusListener(_handleStatus);`|
|interaction|[L299](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L299)|`..removeListener(updateBarItems)`|
|interaction|[L300](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L300)|`..removeStatusListener(_handleStatus);`|
|interaction|[L301](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L301)|`_nextOverdrag?.removeListener(_copyOverdrag);`|
|interaction|[L564](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L564)|`_overdrag.removeListener(markNeedsPaint);`|
|interaction|[L565](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L565)|`value.addListener(markNeedsPaint);`|
|interaction|[L577](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L577)|`_coveringOverdrag.removeListener(markNeedsPaint);`|
|interaction|[L578](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L578)|`value.addListener(markNeedsPaint);`|
|interaction|[L608](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L608)|`_receding.removeListener(markNeedsPaint);`|
|interaction|[L609](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L609)|`value.addListener(markNeedsPaint);`|
|interaction|[L699](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L699)|`..addListener(markNeedsPaint)`|
|interaction|[L700](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L700)|`..addStatusListener(_handleStatus);`|
|interaction|[L702](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L702)|`_receding.addListener(markNeedsPaint);`|
|interaction|[L703](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L703)|`_overdrag.addListener(markNeedsPaint);`|
|interaction|[L704](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L704)|`_coveringOverdrag.addListener(markNeedsPaint);`|
|interaction|[L710](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L710)|`..removeListener(markNeedsPaint)`|
|interaction|[L711](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L711)|`..removeStatusListener(_handleStatus);`|
|interaction|[L713](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L713)|`_receding.removeListener(markNeedsPaint);`|
|interaction|[L714](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L714)|`_overdrag.removeListener(markNeedsPaint);`|
|interaction|[L715](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L715)|`_coveringOverdrag.removeListener(markNeedsPaint);`|
|platform|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L100)|`MediaQuery.displayCornerRadiiOf(context) ?? BorderRadius.zero;`|
|platform|[L475](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L475)|`devicePixelRatio: MediaQuery.devicePixelRatioOf(context),`|
|platform|[L497](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L497)|`..devicePixelRatio = MediaQuery.devicePixelRatioOf(context);`|
|lifecycle|[L294](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L294)|`void dispose() {`|
|lifecycle|[L302](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L302)|`_coveringOverdrag.dispose();`|
|lifecycle|[L303](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L303)|`_coveredByZoom.dispose();`|
|lifecycle|[L304](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L304)|`_barItems.dispose();`|
|lifecycle|[L305](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L305)|`_motionSnapshot.dispose();`|
|lifecycle|[L306](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L306)|`super.dispose();`|
|lifecycle|[L731](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L731)|`void dispose() {`|
|lifecycle|[L734](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/page_transition.dart#L734)|`super.dispose();`|

### prism_ui/lib/paged_sheet.dart

用途：design-system：PagedSheetRoute, PagedSheet, NestedPagedSheet。复用：`packages/flutter/vendor/prism_ui/lib/paged_sheet.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L243](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L243)|`child: GestureDetector(`|
|interaction|[L244](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L244)|`onTap: () => unawaited(_handleDismiss()),`|
|interaction|[L251](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L251)|`child: GestureDetector(`|
|platform|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L84)|`automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),`|
|lifecycle|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L34)|`void dispose() {`|
|lifecycle|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L35)|`_sheetScroll?.dispose();`|
|lifecycle|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L36)|`super.dispose();`|
|lifecycle|[L169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L169)|`void didChangeDependencies() {`|
|lifecycle|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L170)|`super.didChangeDependencies();`|
|lifecycle|[L180](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L180)|`void dispose() {`|
|lifecycle|[L182](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/paged_sheet.dart#L182)|`super.dispose();`|

### prism_ui/lib/pop_scope.dart

用途：design-system：PopGuard, BackLayerScope。复用：`packages/flutter/vendor/prism_ui/lib/pop_scope.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/pop_scope.dart#L83)|`void didChangeDependencies() {`|
|lifecycle|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/pop_scope.dart#L84)|`super.didChangeDependencies();`|
|lifecycle|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/pop_scope.dart#L86)|`final isPageActive = PageActivityScope.isActiveOf(context);`|
|lifecycle|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/pop_scope.dart#L136)|`void dispose() {`|
|lifecycle|[L140](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/pop_scope.dart#L140)|`super.dispose();`|

### prism_ui/lib/popup.dart

用途：design-system：PopupAnchorResolver, PopupOpen, PopupPlacement, AnchoredPopupRoute, PopupAnchor, PopupValueText, PopupMenuItem, PopupMenuSection, PopupMenu, PopupMenuCard。复用：`packages/flutter/vendor/prism_ui/lib/popup.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L8](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L8)|`import 'package:flutter/physics.dart' show SpringSimulation;`|
|motion|[L68](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L68)|`const _openDuration = Duration(milliseconds: 450);`|
|motion|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L70)|`const _dismissDuration = Duration(milliseconds: 500);`|
|motion|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L72)|`const _shrinkDuration = Duration(milliseconds: 200);`|
|motion|[L89](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L89)|`final _droplet = SpringSimulation(dropletSpring, 0, 1, 0);`|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L93)|`const _dropletGlyphCurve = Cubic(0.25, 0.1, 0.25, 1);`|
|motion|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L97)|`const _dropletAbsorbed = Interval(0.6, 0.9, curve: Curves.easeInOut);`|
|motion|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L101)|`final _open = SpringSimulation(`|
|motion|[L102](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L102)|`SpringDescription.withDampingRatio(mass: 1, stiffness: 400, ratio: 0.754),`|
|motion|[L107](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L107)|`final _corners = SpringSimulation(`|
|motion|[L108](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L108)|`SpringDescription.withDampingRatio(mass: 1, stiffness: 324, ratio: 0.75),`|
|motion|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L135)|`const _dwellDuration = Duration(milliseconds: 400);`|
|motion|[L137](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L137)|`final _unfoldSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L138](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L138)|`duration: const Duration(milliseconds: 420),`|
|motion|[L142](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L142)|`final _foldSpring = SpringDescription.withDurationAndBounce(`|
|motion|[L143](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L143)|`duration: const Duration(milliseconds: 340),`|
|motion|[L352](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L352)|`animation: animation,`|
|motion|[L471](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L471)|`animation: animation,`|
|motion|[L741](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L741)|`final shrink = Curves.easeOut.transform(dismissal);`|
|motion|[L979](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L979)|`1 - Curves.easeIn.transform(((time - 0.4) / 0.1).clamp(0.0, 1.0));`|
|motion|[L1032](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1032)|`Curves.easeOut.transform(`|
|motion|[L1660](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1660)|`animation: animation,`|
|motion|[L1676](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1676)|`final duration = context.motionDuration(commonDuration);`|
|motion|[L1679](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1679)|`curve: Curves.easeOutCubic,`|
|motion|[L1684](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1684)|`switchInCurve: const Interval(0.3, 1, curve: Curves.easeOut),`|
|motion|[L1685](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1685)|`switchOutCurve: const Interval(0.6, 1, curve: Curves.easeIn),`|
|motion|[L1921](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1921)|`with SingleTickerProviderStateMixin {`|
|motion|[L1933](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1933)|`).chain(Tween(begin: 0.0, end: 0.25));`|
|motion|[L1938](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1938)|`late final _unfold = AnimationController.unbounded(vsync: this, value: 1);`|
|motion|[L2185](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2185)|`TickerFuture _springTo(double target, SpringDescription spring) {`|
|motion|[L2186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2186)|`return _unfold.animateWith(`|
|motion|[L2187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2187)|`SpringSimulation(spring, _unfold.value, target, _unfold.velocity),`|
|motion|[L2608](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2608)|`animation: _motion,`|
|rendering|[L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L4)|`import 'dart:ui' show ImageFilter, lerpDouble;`|
|rendering|[L410](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L410)|`Rect? Function(RenderBox popup)? rectIn;`|
|rendering|[L515](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L515)|`class _RenderPopupMorph extends RenderProxyBox {`|
|rendering|[L913](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L913)|`context.canvas.drawPath(path, Paint()..color = fill);`|
|rendering|[L1085](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1085)|`context.canvas.drawPath(path, Paint()..color = fill);`|
|rendering|[L1134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1134)|`canvas.drawRSuperellipse(`|
|rendering|[L1161](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1161)|`? ImageFilter.blur(sigmaX: blur, sigmaY: blur)`|
|rendering|[L1186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1186)|`ImageFilterLayer(`|
|rendering|[L1187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1187)|`imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),`|
|rendering|[L1432](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1432)|`final renderBox = context.findRenderObject() as RenderBox?;`|
|rendering|[L1437](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1437)|`Navigator.maybeOf(context)?.context.findRenderObject() as RenderBox?;`|
|rendering|[L1663](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1663)|`return ImageFiltered(`|
|rendering|[L1665](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1665)|`imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),`|
|rendering|[L2145](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2145)|`Rect? _topCardIn(RenderBox popup) {`|
|rendering|[L2158](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2158)|`final itemBox = itemContext.findRenderObject() as RenderBox?;`|
|rendering|[L2159](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2159)|`final stackBox = context.findRenderObject() as RenderBox?;`|
|rendering|[L2257](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2257)|`if (box is! RenderBox  /  /  !box.hasSize  /  /  box.size.isEmpty) {`|
|rendering|[L2908](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2908)|`class _RenderPopupMenuCard extends RenderProxyBox {`|
|rendering|[L3062](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3062)|`canvas.drawRSuperellipse(`|
|rendering|[L3067](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3067)|`canvas.drawPath(surface, Paint()..color = _fill);`|
|rendering|[L3090](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3090)|`context.canvas.drawPath(shape.shift(offset), Paint()..color = _dim);`|
|interaction|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L10)|`import 'package:flutter/services.dart' show HapticFeedback;`|
|interaction|[L228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L228)|`..addListener(_updatePlatter)`|
|interaction|[L229](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L229)|`..addStatusListener(_handleStatusChanged);`|
|interaction|[L230](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L230)|`_unfolded.addListener(_updatePlatter);`|
|interaction|[L251](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L251)|`?..removeListener(_updatePlatter)`|
|interaction|[L252](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L252)|`..removeStatusListener(_handleStatusChanged);`|
|interaction|[L281](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L281)|`return GestureDetector(`|
|interaction|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L284)|`onTap: _handleDismiss,`|
|interaction|[L287](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L287)|`return Listener(`|
|interaction|[L289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L289)|`onPointerDown: (_) => _handleDismiss(),`|
|interaction|[L290](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L290)|`onPointerPanZoomStart: (_) => _handleDismiss(),`|
|interaction|[L291](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L291)|`onPointerSignal: (_) => _handleDismiss(),`|
|interaction|[L560](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L560)|`..removeListener(markNeedsPaint)`|
|interaction|[L561](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L561)|`..removeStatusListener(_handleStatusChanged);`|
|interaction|[L563](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L563)|`..addListener(markNeedsPaint)`|
|interaction|[L564](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L564)|`..addStatusListener(_handleStatusChanged);`|
|interaction|[L598](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L598)|`_platter.removeListener(markNeedsPaint);`|
|interaction|[L599](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L599)|`value.addListener(markNeedsPaint);`|
|interaction|[L622](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L622)|`_sourceImage?.removeListener(markNeedsPaint);`|
|interaction|[L623](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L623)|`value?.addListener(markNeedsPaint);`|
|interaction|[L663](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L663)|`..addListener(markNeedsPaint)`|
|interaction|[L664](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L664)|`..addStatusListener(_handleStatusChanged);`|
|interaction|[L665](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L665)|`_platter.addListener(markNeedsPaint);`|
|interaction|[L666](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L666)|`_sourceImage?.addListener(markNeedsPaint);`|
|interaction|[L672](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L672)|`..removeListener(markNeedsPaint)`|
|interaction|[L673](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L673)|`..removeStatusListener(_handleStatusChanged);`|
|interaction|[L674](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L674)|`_platter.removeListener(markNeedsPaint);`|
|interaction|[L675](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L675)|`_sourceImage?.removeListener(markNeedsPaint);`|
|interaction|[L1501](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1501)|`enabled = region.onTap != null;`|
|interaction|[L1531](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1531)|`listener.onPointerCancel?.call(PointerCancelEvent(pointer: pointer));`|
|interaction|[L1592](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1592)|`route.animation!.addStatusListener((status) {`|
|interaction|[L1614](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1614)|`return RawGestureDetector(`|
|interaction|[L2289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2289)|`final index = row?.onTap == null ? null : row!.index;`|
|interaction|[L2294](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2294)|`HapticFeedback.selectionClick();`|
|interaction|[L2302](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2302)|`final onTap = row?.onTap;`|
|interaction|[L2303](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2303)|`final index = onTap == null ? null : row!.index;`|
|interaction|[L2305](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2305)|`if (onTap == null  /  /  !row!.togglesSubMenu) {`|
|interaction|[L2312](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2312)|`onTap();`|
|interaction|[L2313](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2313)|`HapticFeedback.selectionClick();`|
|interaction|[L2322](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2322)|`final onTap = _landed ? null : _rowAt(position)?.onTap;`|
|interaction|[L2324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2324)|`onTap?.call();`|
|interaction|[L2369](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2369)|`required VoidCallback? onTap,`|
|interaction|[L2374](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2374)|`final enabled = onTap != null;`|
|interaction|[L2398](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2398)|`onTap: onTap,`|
|interaction|[L2456](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2456)|`onTap,`|
|interaction|[L2484](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2484)|`onTap: () => _push(itemContext, index),`|
|interaction|[L2494](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2494)|`onTap: switch (onPressed) {`|
|interaction|[L2561](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2561)|`onTap: _toggleTop,`|
|interaction|[L2599](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2599)|`return GestureDetector(`|
|interaction|[L2601](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2601)|`onTap: receding ? _pop : null,`|
|interaction|[L2715](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2715)|`child: RawGestureDetector(`|
|interaction|[L2755](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2755)|`const _MenuRow(this.index, this.onTap, {required this.togglesSubMenu});`|
|interaction|[L2758](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2758)|`final VoidCallback? onTap;`|
|platform|[L1258](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1258)|`final mediaQuery = MediaQuery.of(context);`|
|platform|[L1264](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1264)|`mediaQuery.padding + mediaQuery.viewInsets,`|
|platform|[L1482](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1482)|`final pixelRatio = MediaQuery.devicePixelRatioOf(context);`|
|platform|[L1543](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1543)|`MediaQuery.maybeGestureSettingsOf(context),`|
|platform|[L2030](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2030)|`MediaQuery.textScalerOf(context).scale(AppTextStyle.subheadline.leading);`|
|platform|[L2048](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2048)|`final textScaler = MediaQuery.textScalerOf(context);`|
|platform|[L2049](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2049)|`final boldText = MediaQuery.boldTextOf(context);`|
|lifecycle|[L249](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L249)|`void dispose() {`|
|lifecycle|[L253](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L253)|`_unfolded.dispose();`|
|lifecycle|[L254](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L254)|`_platter.dispose();`|
|lifecycle|[L255](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L255)|`super.dispose();`|
|lifecycle|[L680](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L680)|`void dispose() {`|
|lifecycle|[L681](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L681)|`_pane.dispose();`|
|lifecycle|[L682](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L682)|`super.dispose();`|
|lifecycle|[L1231](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1231)|`void didChangeDependencies() {`|
|lifecycle|[L1232](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1232)|`super.didChangeDependencies();`|
|lifecycle|[L1423](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1423)|`void dispose() {`|
|lifecycle|[L1424](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1424)|`_sourceHidden.dispose();`|
|lifecycle|[L1425](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1425)|`super.dispose();`|
|lifecycle|[L1602](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1602)|`snapshot.value?.dispose();`|
|lifecycle|[L1603](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1603)|`snapshot.dispose();`|
|lifecycle|[L1812](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1812)|`void dispose() {`|
|lifecycle|[L1814](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1814)|`super.dispose();`|
|lifecycle|[L1968](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1968)|`void initState() {`|
|lifecycle|[L1969](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1969)|`super.initState();`|
|lifecycle|[L1974](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1974)|`void didChangeDependencies() {`|
|lifecycle|[L1975](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1975)|`super.didChangeDependencies();`|
|lifecycle|[L1991](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1991)|`void dispose() {`|
|lifecycle|[L1998](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1998)|`_unfold.dispose();`|
|lifecycle|[L1999](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L1999)|`_lazyController?.dispose();`|
|lifecycle|[L2000](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L2000)|`super.dispose();`|
|lifecycle|[L3039](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3039)|`void dispose() {`|
|lifecycle|[L3040](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3040)|`_pane.dispose();`|
|lifecycle|[L3042](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/popup.dart#L3042)|`super.dispose();`|

### prism_ui/lib/press_region.dart

用途：design-system：PressRegion。复用：`packages/flutter/vendor/prism_ui/lib/press_region.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L83)|`static const _overlayFade = Duration(milliseconds: 50);`|
|motion|[L148](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L148)|`tween: ColorTween(end: _overlayColor(context) ?? const Color(0x00000000)),`|
|rendering|[L195](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L195)|`class _OverlayPainter extends CustomPainter {`|
|interaction|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L10)|`this.onTap,`|
|interaction|[L11](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L11)|`this.onHover,`|
|interaction|[L25](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L25)|`final VoidCallback? onTap;`|
|interaction|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L26)|`final ValueChanged<bool>? onHover;`|
|interaction|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L39)|`/// Defaults to a click cursor while [onTap] is set.`|
|interaction|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L95)|`bool get _enabled => widget.onTap != null;`|
|interaction|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L101)|`widget.onTap?.call();`|
|interaction|[L176](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L176)|`widget.onHover?.call(hovered);`|
|interaction|[L178](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L178)|`child: GestureDetector(`|
|interaction|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L181)|`onTapDown: _enabled ? (_) => _setPressed(true) : null,`|
|interaction|[L182](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L182)|`onTapUp: _enabled ? (_) => _setPressed(false) : null,`|
|interaction|[L183](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L183)|`onTapCancel: _enabled ? () => _setPressed(false) : null,`|
|interaction|[L184](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L184)|`onTap: _enabled ? _activate : null,`|
|interaction|[L189](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_region.dart#L189)|`onTap: widget.excludeFromSemantics  /  /  !_enabled ? null : _activate,`|

### prism_ui/lib/press_sparkle.dart

用途：design-system：PressSparkles。复用：`packages/flutter/vendor/prism_ui/lib/press_sparkle.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L20)|`required TickerProvider vsync,`|
|motion|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L98)|`required TickerProvider vsync,`|
|motion|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L101)|`}) : _motion = AnimationController(vsync: vsync, duration: duration) {`|
|motion|[L105](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L105)|`static const duration = Duration(milliseconds: 617);`|
|motion|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L113)|`tween: CurveTween(curve: Curves.fastOutSlowIn),`|
|motion|[L116](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L116)|`TweenSequenceItem(tween: ConstantTween(1), weight: 25),`|
|motion|[L119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L119)|`TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 13),`|
|motion|[L120](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L120)|`TweenSequenceItem(tween: ConstantTween(1), weight: 27),`|
|motion|[L121](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L121)|`TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 60),`|
|motion|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L124)|`TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 13),`|
|motion|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L125)|`TweenSequenceItem(tween: ConstantTween(1), weight: 27),`|
|motion|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L126)|`TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 50),`|
|motion|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L131)|`final AnimationController _motion;`|
|rendering|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L10)|`static ui.FragmentProgram? _program;`|
|rendering|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L23)|`_loading ??= ui.FragmentProgram.fromAsset(_shaderAsset).then(`|
|rendering|[L132](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L132)|`ui.FragmentShader? _shader;`|
|rendering|[L146](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L146)|`ui.FragmentProgram program,`|
|interaction|[L102](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L102)|`_motion.addListener(onChanged);`|
|interaction|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L136)|`..addStatusListener((status) {`|
|lifecycle|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L49)|`sparkle.dispose();`|
|lifecycle|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L57)|`sparkle.dispose();`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L85)|`void dispose() {`|
|lifecycle|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L87)|`sparkle.dispose();`|
|lifecycle|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L90)|`super.dispose();`|
|lifecycle|[L204](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L204)|`void dispose() {`|
|lifecycle|[L205](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L205)|`_motion.dispose();`|
|lifecycle|[L206](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_sparkle.dart#L206)|`_shader?.dispose();`|

### prism_ui/lib/press_surface.dart

用途：design-system：PressSurface。复用：`packages/flutter/vendor/prism_ui/lib/press_surface.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L88](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L88)|`with TickerProviderStateMixin {`|
|motion|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L90)|`static const _revealDelay = Duration(milliseconds: 150);`|
|motion|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L91)|`static const _lookDuration = Duration(milliseconds: 200);`|
|motion|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L92)|`static const _tintRelease = Duration(milliseconds: 250);`|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L93)|`static const _inkFade = Duration(milliseconds: 200);`|
|motion|[L110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L110)|`AnimationController? _press;`|
|motion|[L111](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L111)|`AnimationController? _lookMotion;`|
|motion|[L242](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L242)|`setState(() => _press = AnimationController(vsync: this));`|
|motion|[L244](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L244)|`_press!.animateTo(1, duration: context.motionDuration(_inkFade));`|
|motion|[L278](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L278)|`setState(() => _press = AnimationController(vsync: this, value: 1));`|
|motion|[L301](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L301)|`.animateTo(`|
|motion|[L303](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L303)|`duration: context.motionDuration(ink ? _inkFade : _tintRelease),`|
|motion|[L304](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L304)|`curve: ink ? Curves.linear : Curves.easeInOut,`|
|motion|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L376)|`final motion = _lookMotion ??= AnimationController(vsync: this);`|
|motion|[L377](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L377)|`_lookCurve ??= CurvedAnimation(parent: motion, curve: Curves.fastOutSlowIn);`|
|motion|[L379](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L379)|`..duration = context.motionDuration(_lookDuration)`|
|motion|[L411](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L411)|`transition: transition,`|
|interaction|[L38](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L38)|`this.onKeyEvent,`|
|interaction|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L76)|`final FocusOnKeyEventCallback? onKeyEvent;`|
|interaction|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L96)|`..onTapDown = _handleTapDown`|
|interaction|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L97)|`..onTap = _handleTap`|
|interaction|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L135)|`_tickerMode?.removeListener(_dropSparklesWhenHidden);`|
|interaction|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L136)|`_tickerMode = tickerMode..addListener(_dropSparklesWhenHidden);`|
|interaction|[L166](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L166)|`_tickerMode?.removeListener(_dropSparklesWhenHidden);`|
|interaction|[L327](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L327)|`FocusMovedByKey.instance.addListener(_handleKeyFocus);`|
|interaction|[L343](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L343)|`FocusMovedByKey.instance.removeListener(_handleKeyFocus);`|
|interaction|[L428](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L428)|`onTap: _activate,`|
|interaction|[L429](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L429)|`onPointerDown: _enabled ? _handlePointerDown : null,`|
|interaction|[L430](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L430)|`onPointerEnd: _handlePointerEnd,`|
|interaction|[L431](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L431)|`onHover: widget.reportsHover ? _handleHover : null,`|
|interaction|[L437](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L437)|`onKeyEvent: widget.onKeyEvent,`|
|platform|[L234](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L234)|`bool get _sparkling => Theme.of(context).platform == TargetPlatform.android;`|
|platform|[L391](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L391)|`MediaQuery.maybeNavigationModeOf(context) == NavigationMode.directional;`|
|platform|[L396](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L396)|`_tap.gestureSettings = MediaQuery.maybeGestureSettingsOf(context);`|
|lifecycle|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L125)|`void initState() {`|
|lifecycle|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L126)|`super.initState();`|
|lifecycle|[L131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L131)|`void didChangeDependencies() {`|
|lifecycle|[L132](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L132)|`super.didChangeDependencies();`|
|lifecycle|[L148](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L148)|`void didUpdateWidget(PressSurface oldWidget) {`|
|lifecycle|[L149](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L149)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L163)|`void dispose() {`|
|lifecycle|[L169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L169)|`..dispose();`|
|lifecycle|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L170)|`_sparkles.dispose();`|
|lifecycle|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L171)|`_press?.dispose();`|
|lifecycle|[L172](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L172)|`_lookCurve?.dispose();`|
|lifecycle|[L173](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L173)|`_lookMotion?.dispose();`|
|lifecycle|[L174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/press_surface.dart#L174)|`super.dispose();`|

### prism_ui/lib/route_motion_hold.dart

用途：转场期间保持路由数据及缓存范围，避免移动中触发重工作。复用：`packages/flutter/vendor/prism_ui/lib/route_motion_hold.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L232](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L232)|`const _stillnessLimit = Duration(milliseconds: 500);`|
|interaction|[L37](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L37)|`void addListener(AnimationStatusListener onStatus, VoidCallback onGesture) {`|
|interaction|[L39](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L39)|`animation.addStatusListener(onStatus);`|
|interaction|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L42)|`gesture.addListener(onGesture);`|
|interaction|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L46)|`void removeListener(`|
|interaction|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L51)|`animation.removeStatusListener(onStatus);`|
|interaction|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L54)|`gesture.removeListener(onGesture);`|
|interaction|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L99)|`_motion = _RouteMotion(context)..addListener(_handleStatus, _releaseHeld);`|
|interaction|[L110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L110)|`_motion?.removeListener(_handleStatus, _releaseHeld);`|
|lifecycle|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L64)|`mixin RouteMotionHoldMixin<T extends StatefulWidget> on State<T> {`|
|lifecycle|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L91)|`void didChangeDependencies() {`|
|lifecycle|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L92)|`super.didChangeDependencies();`|
|lifecycle|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L103)|`void dispose() {`|
|lifecycle|[L106](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L106)|`super.dispose();`|
|lifecycle|[L167](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L167)|`void didChangeDependencies() {`|
|lifecycle|[L168](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L168)|`super.didChangeDependencies();`|
|lifecycle|[L211](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L211)|`void didChangeDependencies() {`|
|lifecycle|[L212](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/route_motion_hold.dart#L212)|`super.didChangeDependencies();`|

### prism_ui/lib/scaffold.dart

用途：design-system：ScaffoldSurface, PrismScaffold, ScaffoldBar, AppBarClearance, AppBarActionButton, AppBarActionEdge, ActionEdgeGap, AppBar。复用：`packages/flutter/vendor/prism_ui/lib/scaffold.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L312](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L312)|`class _RenderBodyBoundary extends RenderProxyBox {`|
|rendering|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L376)|`body is! RenderBox  /  / `|
|rendering|[L377](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L377)|`target is! RenderBox  /  / `|
|rendering|[L378](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L378)|`viewport is! RenderBox) {`|
|interaction|[L344](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L344)|`FocusManager.instance.addListener(_handleFocusChange);`|
|interaction|[L349](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L349)|`FocusManager.instance.removeListener(_handleFocusChange);`|
|interaction|[L438](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L438)|`const double _iconButtonTapPadding = 4;`|
|interaction|[L473](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L473)|`? _iconButtonTapPadding`|
|platform|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L93)|`// its MediaQuery top padding.`|
|platform|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L103)|`final barInset = MediaQuery.paddingOf(context).top;`|
|platform|[L121](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L121)|`child: MediaQuery.removePadding(`|
|platform|[L236](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L236)|`final top = MediaQuery.paddingOf(context).top;`|
|platform|[L283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L283)|`child: MediaQuery.removePadding(`|
|platform|[L300](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L300)|`return _BodyBoundary(child: LayoutBuilder(builder: (_, _) => child));`|
|platform|[L444](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L444)|`double _iconActionInset(bool isMobileView) => isMobileView ? 4 : 8;`|
|platform|[L450](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L450)|`bool isCompactBar(BuildContext context, bool isMobileView) {`|
|platform|[L452](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L452)|`return isMobileView  /  /  (sheet != null && sheet != SheetType.page);`|
|platform|[L459](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L459)|`double spaceOf(BuildContext context, bool isMobileView) => switch (this) {`|
|platform|[L460](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L460)|`icon => _iconActionInset(isMobileView) - _tapPaddingOf(context),`|
|platform|[L461](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L461)|`container => appBarActionInset(isCompactBar(context, isMobileView)),`|
|platform|[L494](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L494)|`width: edge.spaceOf(context, ViewScope.isMobileOf(context)),`|
|platform|[L516](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L516)|`final mediaQuery = MediaQuery.of(context);`|
|platform|[L539](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L539)|`bottom: resize ? mediaQuery.viewInsets.bottom : 0,`|
|platform|[L542](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L542)|`child: MediaQuery(data: bodyData, child: body),`|
|platform|[L552](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L552)|`child: MediaQuery(`|
|platform|[L612](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L612)|`final compact = isCompactBar(context, ViewScope.isMobileOf(context));`|
|platform|[L616](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L616)|`title = MediaQuery.withClampedTextScaling(`|
|platform|[L627](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L627)|`namesRoute: switch (defaultTargetPlatform) {`|
|platform|[L628](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L628)|`TargetPlatform.iOS  /  /  TargetPlatform.macOS => null,`|
|platform|[L802](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L802)|`final mediaQuery = MediaQuery.of(context);`|
|platform|[L804](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L804)|`return MediaQuery(`|
|lifecycle|[L342](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L342)|`void initState() {`|
|lifecycle|[L343](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L343)|`super.initState();`|
|lifecycle|[L348](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L348)|`void dispose() {`|
|lifecycle|[L350](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scaffold.dart#L350)|`super.dispose();`|

### prism_ui/lib/scroll.dart

用途：design-system：Scrollbar, FloatingScrollbar, ScrollToEndBox。复用：`packages/flutter/vendor/prism_ui/lib/scroll.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L181)|`fadeDuration: const Duration(milliseconds: 250),`|
|motion|[L183](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L183)|`timeToFade: const Duration(milliseconds: 1200),`|
|motion|[L191](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L191)|`late final AnimationController _emphasis;`|
|motion|[L193](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L193)|`late final AnimationController _presence;`|
|motion|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L209)|`_emphasis = AnimationController(`|
|motion|[L211](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L211)|`duration: const Duration(milliseconds: 120),`|
|motion|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L213)|`_emphasisCurve = CurvedAnimation(parent: _emphasis, curve: Curves.easeOut);`|
|motion|[L214](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L214)|`_presence = AnimationController(`|
|motion|[L505](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L505)|`_hideTimer = Timer(const Duration(milliseconds: 500), () {`|
|motion|[L604](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L604)|`duration: const Duration(milliseconds: 150),`|
|rendering|[L700](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L700)|`class _MeasureSizeRenderObject extends RenderProxyBox {`|
|interaction|[L137](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L137)|`Set<LogicalKeyboardKey> get pointerAxisModifiers =>`|
|interaction|[L212](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L212)|`)..addListener(updateScrollbarPainter);`|
|interaction|[L218](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L218)|`)..addListener(updateScrollbarPainter);`|
|interaction|[L239](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L239)|`_sheetOpen?.removeListener(_syncSheet);`|
|interaction|[L261](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L261)|`_sheetOpen?.removeListener(_syncSheet);`|
|interaction|[L262](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L262)|`_sheetOpen = sheetOpen?..addListener(_syncSheet);`|
|interaction|[L343](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L343)|`HapticFeedback.selectionClick();`|
|interaction|[L459](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L459)|`widget.controller.addListener(_syncPosition);`|
|interaction|[L466](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L466)|`oldWidget.controller.removeListener(_syncPosition);`|
|interaction|[L467](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L467)|`widget.controller.addListener(_syncPosition);`|
|interaction|[L474](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L474)|`widget.controller.removeListener(_syncPosition);`|
|platform|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L83)|`// Scrollbar insets its track by MediaQuery padding, so the inset reaches it`|
|platform|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L84)|`// through a MediaQuery of its own and the child keeps the original one.`|
|platform|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L85)|`final mediaQuery = MediaQuery.of(context);`|
|platform|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L86)|`return MediaQuery(`|
|platform|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L90)|`MediaQuery(data: mediaQuery, child: child),`|
|platform|[L96](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L96)|`/// What of the floating bar over the scroll view MediaQuery padding leaves to`|
|platform|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L100)|`return max(0.0, overlap - MediaQuery.paddingOf(context).top);`|
|platform|[L145](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L145)|`TargetPlatform getPlatform(BuildContext context) =>`|
|platform|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L197)|`late TargetPlatform _platform;`|
|platform|[L555](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L555)|`return LayoutBuilder(`|
|platform|[L578](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L578)|`MediaQuery.paddingOf(context) +`|
|lifecycle|[L207](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L207)|`void initState() {`|
|lifecycle|[L208](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L208)|`super.initState();`|
|lifecycle|[L222](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L222)|`void didChangeDependencies() {`|
|lifecycle|[L226](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L226)|`super.didChangeDependencies();`|
|lifecycle|[L231](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L231)|`void didUpdateWidget(_AppScrollbar oldWidget) {`|
|lifecycle|[L232](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L232)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L237](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L237)|`void dispose() {`|
|lifecycle|[L240](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L240)|`_presence.dispose();`|
|lifecycle|[L241](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L241)|`_emphasisCurve.dispose();`|
|lifecycle|[L242](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L242)|`_emphasis.dispose();`|
|lifecycle|[L243](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L243)|`super.dispose();`|
|lifecycle|[L455](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L455)|`void initState() {`|
|lifecycle|[L456](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L456)|`super.initState();`|
|lifecycle|[L463](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L463)|`void didUpdateWidget(FloatingScrollbar oldWidget) {`|
|lifecycle|[L464](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L464)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L472](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L472)|`void dispose() {`|
|lifecycle|[L475](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L475)|`super.dispose();`|
|lifecycle|[L740](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L740)|`void didUpdateWidget(ScrollToEndBox oldWidget) {`|
|lifecycle|[L741](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll.dart#L741)|`super.didUpdateWidget(oldWidget);`|

### prism_ui/lib/scroll_behavior.dart

用途：design-system：BaseScrollBehavior, HiddenBarScrollBehavior, ShowBarScrollBehavior, NextClampingScrollPhysics, FollowEndScrollPhysics, ScrubbableScrollPosition, InitialPixelsInRange, SheetScrollController。复用：`packages/flutter/vendor/prism_ui/lib/scroll_behavior.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L114)|`Simulation? createBallisticSimulation(`|
|motion|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L128)|`return ScrollSpringSimulation(`|
|motion|[L145](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L145)|`return ClampingScrollSimulation(`|
|platform|[L9](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L9)|`bool isTouchPlatform(TargetPlatform platform) => switch (platform) {`|
|platform|[L10](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L10)|`TargetPlatform.android  /  / `|
|platform|[L11](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L11)|`TargetPlatform.iOS  /  / `|
|platform|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L12)|`TargetPlatform.fuchsia => true,`|
|platform|[L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L13)|`TargetPlatform.linux  /  / `|
|platform|[L14](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L14)|`TargetPlatform.macOS  /  / `|
|platform|[L15](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L15)|`TargetPlatform.windows => false,`|
|platform|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L24)|`TargetPlatform getPlatform(BuildContext context) =>`|
|platform|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L64)|`TargetPlatform.android => StretchingOverscrollIndicator(`|
|platform|[L69](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L69)|`TargetPlatform.fuchsia => GlowingOverscrollIndicator(`|
|platform|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L74)|`TargetPlatform.iOS  /  / `|
|platform|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L75)|`TargetPlatform.linux  /  / `|
|platform|[L76](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L76)|`TargetPlatform.macOS  /  / `|
|platform|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/scroll_behavior.dart#L77)|`TargetPlatform.windows => child,`|

### prism_ui/lib/search_field.dart

用途：design-system：SearchField。复用：`packages/flutter/vendor/prism_ui/lib/search_field.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/search_field.dart#L29)|`final FocusNode? focusNode;`|
|lifecycle|[L63](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/search_field.dart#L63)|`void dispose() {`|
|lifecycle|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/search_field.dart#L64)|`_ownedController?.dispose();`|
|lifecycle|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/search_field.dart#L65)|`super.dispose();`|

### prism_ui/lib/segmented_control.dart

用途：design-system：SegmentedControl。复用：`packages/flutter/vendor/prism_ui/lib/segmented_control.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L40](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/segmented_control.dart#L40)|`duration: const Duration(milliseconds: 250),`|
|motion|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/segmented_control.dart#L41)|`curve: Curves.easeOutCubic,`|
|motion|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/segmented_control.dart#L74)|`duration: const Duration(milliseconds: 200),`|

### prism_ui/lib/selectable_text.dart

用途：design-system：SelectionArea, SelectableText。复用：`packages/flutter/vendor/prism_ui/lib/selectable_text.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L19)|`final FocusNode? focusNode;`|
|interaction|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L73)|`final _focusNode = FocusNode(skipTraversal: true);`|
|platform|[L1](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L1)|`import 'package:flutter/foundation.dart' show defaultTargetPlatform;`|
|platform|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L27)|`selectionControls: textSelectionControlsFor(defaultTargetPlatform),`|
|lifecycle|[L78](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L78)|`void didUpdateWidget(SelectableText oldWidget) {`|
|lifecycle|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L79)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L87)|`void dispose() {`|
|lifecycle|[L88](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L88)|`_controller.dispose();`|
|lifecycle|[L89](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L89)|`_focusNode.dispose();`|
|lifecycle|[L90](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/selectable_text.dart#L90)|`super.dispose();`|

### prism_ui/lib/shapes/cubic.dart

用途：design-system：Cubic。复用：`packages/flutter/vendor/prism_ui/lib/shapes/cubic.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L4)|`Cubic(`|
|motion|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L80)|`return Cubic(`|
|motion|[L234](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L234)|`Cubic(`|
|motion|[L244](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L244)|`Cubic(`|
|motion|[L257](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L257)|`Cubic reverse() => Cubic(`|
|motion|[L277](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L277)|`final newCubic = _MutableCubic();`|
|motion|[L287](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/cubic.dart#L287)|`_MutableCubic() : super._raw(List.filled(8, 0));`|

### prism_ui/lib/shapes/morph.dart

用途：design-system：Morph。复用：`packages/flutter/vendor/prism_ui/lib/shapes/morph.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/morph.dart#L91)|`Cubic(`|

### prism_ui/lib/shapes/polygon_measure.dart

用途：design-system：MeasuredPolygon, MeasuredCubic, Measurer, LengthMeasurer。复用：`packages/flutter/vendor/prism_ui/lib/shapes/polygon_measure.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L28)|`MeasuredCubic(`|
|motion|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L74)|`final measure = measurer.measureCubic(cubics[i]);`|
|motion|[L189](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L189)|`MeasuredCubic({`|
|motion|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L209)|`measuredSize = measurer.measureCubic(cubic);`|
|motion|[L264](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L264)|`MeasuredCubic(`|
|motion|[L270](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L270)|`MeasuredCubic(`|
|motion|[L283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L283)|`double measureCubic(Cubic c);`|
|motion|[L294](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/polygon_measure.dart#L294)|`double measureCubic(Cubic c) {`|

### prism_ui/lib/shapes/rounded_polygon.dart

用途：design-system：RoundedPolygon。复用：`packages/flutter/vendor/prism_ui/lib/shapes/rounded_polygon.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L343](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/rounded_polygon.dart#L343)|`Cubic(`|
|motion|[L356](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/rounded_polygon.dart#L356)|`Cubic(`|

### prism_ui/lib/sheet.dart

用途：design-system：SheetProps, ExtendProps, SheetType, SheetCornersScope。复用：`packages/flutter/vendor/prism_ui/lib/sheet.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L77)|`floatingSheetRadius(MediaQuery.displayCornerRadiiOf(context), 0);`|
|platform|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L98)|`if (context.isMobileView) {`|
|platform|[L115](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L115)|`if (context.isMobileView) {`|
|platform|[L169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L169)|`final isMobile = context.isMobileView;`|
|platform|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L170)|`return switch (isMobile  /  /  props.forceFull) {`|
|platform|[L193](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L193)|`void open({required bool isMobile}) {`|
|platform|[L205](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L205)|`open(isMobile: context.isMobileView);`|
|platform|[L214](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L214)|`isMobile: isMobile,`|
|platform|[L224](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L224)|`open(isMobile: !isMobile);`|
|platform|[L233](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L233)|`if (isMobile) {`|
|platform|[L259](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L259)|`open(isMobile: context.isMobileView);`|
|platform|[L265](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L265)|`required this.isMobile,`|
|platform|[L271](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L271)|`final bool isMobile;`|
|platform|[L289](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L289)|`if (ViewScope.isMobileOf(context) != widget.isMobile) {`|
|lifecycle|[L282](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L282)|`void dispose() {`|
|lifecycle|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet.dart#L284)|`super.dispose();`|

### prism_ui/lib/sheet_header.dart

用途：design-system：SheetDragHandle, SheetToolBar, FloatingHeader, FloatingHeaderBody, SheetOverhangLift。复用：`packages/flutter/vendor/prism_ui/lib/sheet_header.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L97)|`alpha: _alpha * (1 - Curves.easeInOut.transform(t)),`|
|interaction|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L64)|`? GestureDetector(behavior: HitTestBehavior.opaque, child: bar)`|
|interaction|[L204](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L204)|`_overhang?.addListener(_syncTransform);`|
|interaction|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L213)|`_overhang?.removeListener(_syncTransform);`|
|interaction|[L215](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L215)|`_overhang?.addListener(_syncTransform);`|
|interaction|[L227](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L227)|`_overhang?.removeListener(_syncTransform);`|
|platform|[L120](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L120)|`child: LayoutBuilder(`|
|lifecycle|[L226](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L226)|`void dispose() {`|
|lifecycle|[L228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_header.dart#L228)|`super.dispose();`|

### prism_ui/lib/sheet_navigator.dart

用途：design-system：SheetPagesNavigator, SheetCoverRouteMixin。复用：`packages/flutter/vendor/prism_ui/lib/sheet_navigator.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|lifecycle|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_navigator.dart#L48)|`void dispose() {`|
|lifecycle|[L50](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sheet_navigator.dart#L50)|`super.dispose();`|

### prism_ui/lib/side_sheet.dart

用途：design-system：SideSheet, ModalSideSheetRoute。复用：`packages/flutter/vendor/prism_ui/lib/side_sheet.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L13)|`const Duration _sideSheetEnterDuration = Duration(milliseconds: 300);`|
|motion|[L14](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L14)|`const Duration _sideSheetExitDuration = Duration(milliseconds: 200);`|
|motion|[L35](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L35)|`static AnimationController createAnimationController(TickerProvider vsync) {`|
|motion|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L36)|`return AnimationController(`|
|motion|[L276](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L276)|`animation: route.animation!,`|
|motion|[L284](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L284)|`final curve = route.isDragBackActive ? Curves.linear : _sideSheetCurve;`|
|motion|[L360](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L360)|`AnimationController createAnimationController() {`|
|motion|[L361](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L361)|`return SideSheet.createAnimationController(navigator!);`|
|motion|[L391](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L391)|`ColorTween(`|
|motion|[L394](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L394)|`).chain(CurveTween(curve: barrierCurve)),`|
|rendering|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L99)|`RenderBox? child,`|
|interaction|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L64)|`const _SideSheetLayoutWithSizeListener({`|
|interaction|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L79)|`return _RenderSideSheetLayoutWithSizeListener(`|
|interaction|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L98)|`_RenderSideSheetLayoutWithSizeListener({`|
|interaction|[L292](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L292)|`child: _SideSheetLayoutWithSizeListener(`|
|platform|[L252](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L252)|`case TargetPlatform.iOS:`|
|platform|[L253](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L253)|`case TargetPlatform.macOS:`|
|platform|[L255](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L255)|`case TargetPlatform.android:`|
|platform|[L256](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L256)|`case TargetPlatform.fuchsia:`|
|platform|[L257](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L257)|`case TargetPlatform.linux:`|
|platform|[L258](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L258)|`case TargetPlatform.windows:`|
|platform|[L269](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L269)|`assert(debugCheckHasMediaQuery(context));`|
|platform|[L272](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L272)|`final width = _widthFor(MediaQuery.sizeOf(context).width);`|
|platform|[L422](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L422)|`assert(debugCheckHasMediaQuery(context));`|
|lifecycle|[L331](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L331)|`void dispose() {`|
|lifecycle|[L332](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L332)|`_clipDetailsNotifier.dispose();`|
|lifecycle|[L333](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/side_sheet.dart#L333)|`super.dispose();`|

### prism_ui/lib/sidebar.dart

用途：design-system：SidebarDestination, NavigationSidebar。复用：`packages/flutter/vendor/prism_ui/lib/sidebar.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L29)|`const _expandDuration = Duration(milliseconds: 250);`|
|motion|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L30)|`const _indicatorDuration = Duration(milliseconds: 320);`|
|motion|[L68](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L68)|`with SingleTickerProviderStateMixin {`|
|motion|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L70)|`late final AnimationController _overlayExpansion = AnimationController(`|
|motion|[L150](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L150)|`tween: Tween(end: widget.expanded ? 1.0 : 0.0),`|
|motion|[L223](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L223)|`animation: progress,`|
|motion|[L515](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L515)|`with SingleTickerProviderStateMixin {`|
|motion|[L516](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L516)|`late final AnimationController _controller = AnimationController(`|
|motion|[L544](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L544)|`animation: _controller,`|
|motion|[L549](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L549)|`final lead = Curves.easeOutCubic.transform(math.min(1, t / 0.6));`|
|motion|[L550](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L550)|`final trail = Curves.easeInOutCubic.transform(`|
|interaction|[L190](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L190)|`child: GestureDetector(`|
|interaction|[L192](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L192)|`onTap: onDismiss,`|
|interaction|[L200](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L200)|`child: Shortcuts(`|
|interaction|[L202](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L202)|`SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),`|
|interaction|[L213](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L213)|`child: FocusScope(`|
|interaction|[L313](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L313)|`onTap: onToggle,`|
|interaction|[L338](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L338)|`onTap: () => onSelected(index),`|
|interaction|[L376](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L376)|`required this.onTap,`|
|interaction|[L388](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L388)|`final VoidCallback onTap;`|
|interaction|[L405](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L405)|`onTap: onTap,`|
|platform|[L119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L119)|`final safePadding = MediaQuery.paddingOf(context);`|
|platform|[L120](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L120)|`return OverlayPortal.overlayChildLayoutBuilder(`|
|platform|[L285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L285)|`_itemSize + MediaQuery.textScalerOf(context).scale(fontSize) - fontSize;`|
|platform|[L435](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L435)|`textScaler: MediaQuery.textScalerOf(context),`|
|lifecycle|[L80](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L80)|`void didUpdateWidget(covariant NavigationSidebar oldWidget) {`|
|lifecycle|[L81](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L81)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L111](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L111)|`void dispose() {`|
|lifecycle|[L112](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L112)|`_overlayProgress.dispose();`|
|lifecycle|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L113)|`_overlayExpansion.dispose();`|
|lifecycle|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L114)|`super.dispose();`|
|lifecycle|[L439](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L439)|`painter.dispose();`|
|lifecycle|[L524](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L524)|`void didUpdateWidget(covariant _SelectionIndicator oldWidget) {`|
|lifecycle|[L525](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L525)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L533](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L533)|`void dispose() {`|
|lifecycle|[L534](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L534)|`_controller.dispose();`|
|lifecycle|[L535](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sidebar.dart#L535)|`super.dispose();`|

### prism_ui/lib/skeleton.dart

用途：design-system：SkeletonText, SkeletonPill。复用：`packages/flutter/vendor/prism_ui/lib/skeleton.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L52)|`with SingleTickerProviderStateMixin {`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L53)|`static const _period = Duration(milliseconds: 1600);`|
|motion|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L55)|`late final AnimationController _controller;`|
|motion|[L63](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L63)|`_controller = AnimationController(`|
|platform|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L27)|`height: MediaQuery.textScalerOf(`|
|lifecycle|[L59](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L59)|`void initState() {`|
|lifecycle|[L60](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L60)|`super.initState();`|
|lifecycle|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L74)|`void didChangeDependencies() {`|
|lifecycle|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L75)|`super.didChangeDependencies();`|
|lifecycle|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L84)|`void dispose() {`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L85)|`_controller.dispose();`|
|lifecycle|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/skeleton.dart#L86)|`super.dispose();`|

### prism_ui/lib/slider.dart

用途：design-system：SliderShape, Slider。复用：`packages/flutter/vendor/prism_ui/lib/slider.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L61)|`class _SliderState extends State<Slider> with SingleTickerProviderStateMixin {`|
|motion|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L62)|`static const _activationDuration = Duration(milliseconds: 100);`|
|motion|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L64)|`late final _activation = AnimationController(`|
|rendering|[L230](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L230)|`class _SliderPainter extends CustomPainter {`|
|rendering|[L293](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L293)|`canvas.drawRSuperellipse(`|
|rendering|[L350](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L350)|`canvas.drawRSuperellipse(`|
|rendering|[L421](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L421)|`canvas.drawRSuperellipse(`|
|interaction|[L161](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L161)|`const SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustIntent(`|
|interaction|[L164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L164)|`const SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustIntent(`|
|interaction|[L175](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L175)|`return GestureDetector(`|
|interaction|[L189](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L189)|`onTapDown: _enabled`|
|interaction|[L192](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L192)|`onTapUp: _enabled ? (_) => _end() : null,`|
|interaction|[L193](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L193)|`onTapCancel: _enabled ? _end : null,`|
|platform|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L171)|`child: LayoutBuilder(`|
|platform|[L210](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L210)|`textScaler: MediaQuery.textScalerOf(context),`|
|lifecycle|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L83)|`void dispose() {`|
|lifecycle|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L84)|`_activation.dispose();`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L85)|`super.dispose();`|
|lifecycle|[L305](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/slider.dart#L305)|`painter.dispose();`|

### prism_ui/lib/sliver_list/layout_pass.dart

用途：design-system：SliverLayoutState, LayoutPass, RenderSliverLayoutPass。复用：`packages/flutter/vendor/prism_ui/lib/sliver_list/layout_pass.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L71)|`extension RenderSliverLayoutPass on RenderSliver {`|
|rendering|[L91](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L91)|`if (child is RenderSliver) {`|

### prism_ui/lib/sliver_list/render_object.dart

用途：design-system：RenderSuperSliverList。复用：`packages/flutter/vendor/prism_ui/lib/sliver_list/render_object.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L62)|`class RenderSuperSliverList extends RenderSliverMultiBoxAdaptor {`|
|rendering|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L103)|`final index = indexOf(child as RenderBox);`|
|rendering|[L130](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L130)|`if (child is! RenderSliver) {`|
|rendering|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L187)|`void _shiftLayoutOffsets(RenderBox? child, double delta) {`|
|rendering|[L198](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L198)|`RenderBox child,`|
|rendering|[L200](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L200)|`RenderBox? lastChildWithScrollOffset,`|
|rendering|[L306](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L306)|`RenderBox? lastChildWithScrollOffset;`|
|rendering|[L313](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L313)|`RenderBox? previousChild;`|
|rendering|[L606](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L606)|`RenderBox? _firstWholeVisibleChild() {`|
|rendering|[L607](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L607)|`RenderBox? child = firstChild;`|
|rendering|[L638](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L638)|`RenderBox? insertAndLayoutLeadingChild(`|
|rendering|[L675](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L675)|`class _FakeRenderObject extends RenderBox {`|

### prism_ui/lib/sliver_list/sliver_extensions.dart

用途：design-system：ChildObstructionExtent, SliverGeometryChildObstruction, RenderObjectChildObstuctionExtent, OffsetToRevealContext, RenderViewportExt。复用：`packages/flutter/vendor/prism_ui/lib/sliver_list/sliver_extensions.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L67](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/sliver_extensions.dart#L67)|`if (parent is RenderSliver) {`|

### prism_ui/lib/sliver_list/super_sliver_list.dart

用途：design-system：ListController, ExtentEstimationProvider, SuperSliverList。复用：`packages/flutter/vendor/prism_ui/lib/sliver_list/super_sliver_list.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L93)|`RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {`|
|lifecycle|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L55)|`void dispose() {`|

### prism_ui/lib/snap_sheet.dart

用途：9/16、0.9 吸附点，投掷速度投影、橡皮筋、键盘和滚轮协调。复用：`packages/flutter/vendor/prism_ui/lib/snap_sheet.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L55)|`const _wheelTurnGap = Duration(milliseconds: 500);`|
|motion|[L129](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L129)|`controller!.animateWith(_presentation(1, velocity));`|
|motion|[L154](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L154)|`Simulation createSimulation({required bool forward}) {`|
|motion|[L174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L174)|`ColorTween(begin: color.withValues(alpha: 0), end: color),`|
|motion|[L191](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L191)|`Duration get transitionDuration => const Duration(milliseconds: 500);`|
|motion|[L253](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L253)|`/// SpringSimulation picks its solution by the sign of a discriminant that a`|
|motion|[L255](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L255)|`class _SheetSpring extends Simulation {`|
|motion|[L282](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L282)|`/// Lands exactly on [to], which an AnimationController would otherwise`|
|motion|[L338](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L338)|`_SheetModel({required this.route, required TickerProvider vsync})`|
|motion|[L856](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L856)|`with SingleTickerProviderStateMixin {`|
|rendering|[L1056](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1056)|`class _RenderSheetViewport extends RenderBox`|
|rendering|[L1057](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1057)|`with RenderObjectWithChildMixin<RenderBox> {`|
|rendering|[L1298](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1298)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|rendering|[L1323](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1323)|`class _RenderSheetContent extends RenderProxyBox {`|
|interaction|[L342](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L342)|`route.animation!.addListener(_syncLift);`|
|interaction|[L836](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L836)|`route.animation!.removeListener(_syncLift);`|
|interaction|[L868](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L868)|`widget.route.animation!.addStatusListener(_handleRouteStatus);`|
|interaction|[L879](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L879)|`widget.route.animation!.removeStatusListener(_handleRouteStatus);`|
|interaction|[L922](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L922)|`final sheet = Listener(`|
|interaction|[L923](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L923)|`onPointerDown: (_) => _model.fingerDown(),`|
|interaction|[L924](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L924)|`onPointerPanZoomStart: (_) => _model.fingerDown(),`|
|interaction|[L925](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L925)|`onPointerSignal: _handlePointerSignal,`|
|interaction|[L926](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L926)|`child: GestureDetector(`|
|interaction|[L1090](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1090)|`_model.removeListener(markNeedsLayout);`|
|interaction|[L1091](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1091)|`value.addListener(markNeedsLayout);`|
|interaction|[L1119](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1119)|`_presentation.removeListener(markNeedsPaint);`|
|interaction|[L1120](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1120)|`value.addListener(markNeedsPaint);`|
|interaction|[L1131](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1131)|`_cover.removeListener(markNeedsPaint);`|
|interaction|[L1132](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1132)|`value.addListener(markNeedsPaint);`|
|interaction|[L1143](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1143)|`_coverReach.removeListener(markNeedsPaint);`|
|interaction|[L1144](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1144)|`value.addListener(markNeedsPaint);`|
|interaction|[L1153](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1153)|`_model.addListener(markNeedsLayout);`|
|interaction|[L1154](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1154)|`_presentation.addListener(markNeedsPaint);`|
|interaction|[L1155](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1155)|`_cover.addListener(markNeedsPaint);`|
|interaction|[L1156](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1156)|`_coverReach.addListener(markNeedsPaint);`|
|interaction|[L1161](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1161)|`_model.removeListener(markNeedsLayout);`|
|interaction|[L1162](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1162)|`_presentation.removeListener(markNeedsPaint);`|
|interaction|[L1163](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1163)|`_cover.removeListener(markNeedsPaint);`|
|interaction|[L1164](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1164)|`_coverReach.removeListener(markNeedsPaint);`|
|interaction|[L1430](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1430)|`model.settling.addListener(_followSettling);`|
|interaction|[L1524](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1524)|`model.settling.removeListener(_followSettling);`|
|platform|[L918](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L918)|`automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),`|
|platform|[L981](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L981)|`return MediaQuery(`|
|platform|[L982](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L982)|`data: MediaQuery.of(context).removeViewInsets(removeBottom: true),`|
|platform|[L999](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L999)|`keyboard: MediaQuery.viewInsetsOf(context).bottom,`|
|platform|[L1000](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1000)|`display: MediaQuery.displayCornerRadiiOf(context),`|
|lifecycle|[L184](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L184)|`void dispose() {`|
|lifecycle|[L185](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L185)|`_dismissHandler.dispose();`|
|lifecycle|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L186)|`_coverReach.dispose();`|
|lifecycle|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L187)|`super.dispose();`|
|lifecycle|[L834](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L834)|`void dispose() {`|
|lifecycle|[L837](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L837)|`_ticker.dispose();`|
|lifecycle|[L838](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L838)|`settling.dispose();`|
|lifecycle|[L839](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L839)|`open.dispose();`|
|lifecycle|[L840](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L840)|`lift.dispose();`|
|lifecycle|[L841](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L841)|`corners.dispose();`|
|lifecycle|[L842](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L842)|`super.dispose();`|
|lifecycle|[L866](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L866)|`void initState() {`|
|lifecycle|[L867](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L867)|`super.initState();`|
|lifecycle|[L878](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L878)|`void dispose() {`|
|lifecycle|[L880](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L880)|`_scrollController.dispose();`|
|lifecycle|[L881](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L881)|`_model.dispose();`|
|lifecycle|[L882](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L882)|`super.dispose();`|
|lifecycle|[L1169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1169)|`void dispose() {`|
|lifecycle|[L1172](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1172)|`super.dispose();`|
|lifecycle|[L1515](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1515)|`newActivity!.dispose();`|
|lifecycle|[L1523](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1523)|`void dispose() {`|
|lifecycle|[L1525](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/snap_sheet.dart#L1525)|`super.dispose();`|

### prism_ui/lib/sortable.dart

用途：design-system：ReorderDragStartListener, SortModeScope, SortableItemData, SortableItem, DisclosureIndicator, DetailButton, SortHandle, SortableTrailing。复用：`packages/flutter/vendor/prism_ui/lib/sortable.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L186)|`duration: context.motionDuration(kThemeAnimationDuration),`|
|motion|[L253](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L253)|`duration: context.motionDuration(kThemeAnimationDuration),`|
|motion|[L282](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L282)|`const _enterDuration = Duration(milliseconds: 650);`|
|motion|[L283](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L283)|`const _exitDuration = Duration(milliseconds: 420);`|
|motion|[L287](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L287)|`SpringDescription.withDurationAndBounce(`|
|motion|[L288](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L288)|`duration: const Duration(milliseconds: 350),`|
|motion|[L311](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L311)|`with SingleTickerProviderStateMixin {`|
|motion|[L312](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L312)|`late final AnimationController _controller = AnimationController(`|
|motion|[L324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L324)|`_controller.animateTo(`|
|motion|[L326](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L326)|`duration: context.motionDuration(`|
|motion|[L349](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L349)|`animation: _controller,`|
|motion|[L380](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L380)|`animation: animation,`|
|motion|[L453](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L453)|`? const Interval(0, 0.5, curve: Curves.easeOutCubic).transform(value)`|
|motion|[L458](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L458)|`curve: Curves.easeInOutCubic,`|
|motion|[L466](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L466)|`: const Interval(0.55, 1, curve: Curves.easeOut).transform(value);`|
|motion|[L472](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L472)|`? 1 - const Interval(0, 0.2, curve: Curves.easeIn).transform(value)`|
|motion|[L476](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L476)|`curve: Curves.easeOutBack,`|
|rendering|[L397](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L397)|`class _SlotParentData extends ContainerBoxParentData<RenderBox> {}`|
|rendering|[L399](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L399)|`class _RenderSortableSlot extends RenderBox`|
|rendering|[L401](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L401)|`ContainerRenderObjectMixin<RenderBox, _SlotParentData>,`|
|rendering|[L402](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L402)|`RenderBoxContainerDefaultsMixin<RenderBox, _SlotParentData> {`|
|rendering|[L446](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L446)|`RenderBox get _trailing => firstChild!;`|
|rendering|[L448](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L448)|`RenderBox? get _handle => childAfter(firstChild!);`|
|rendering|[L492](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L492)|`void setupParentData(RenderBox child) {`|
|rendering|[L578](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L578)|`Matrix4 _transformOf(RenderBox child) {`|
|rendering|[L603](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L603)|`RenderBox child,`|
|rendering|[L627](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L627)|`RenderBox child,`|
|rendering|[L646](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L646)|`void applyPaintTransform(RenderBox child, Matrix4 transform) {`|
|interaction|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L23)|`const ReorderDragStartListener({`|
|interaction|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L36)|`? VerticalMultiDragGestureRecognizer(debugOwner: this)`|
|interaction|[L37](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L37)|`: DelayedMultiDragGestureRecognizer(debugOwner: this);`|
|interaction|[L48](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L48)|`return Listener(`|
|interaction|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L49)|`onPointerDown: enabled`|
|interaction|[L94](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L94)|`child: ReorderDragStartListener(`|
|interaction|[L199](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L199)|`KeyEventResult _handleKey(FocusNode _, KeyEvent event) {`|
|interaction|[L201](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L201)|`if (remoteSelectKeys.contains(key)  /  /  key == LogicalKeyboardKey.space) {`|
|interaction|[L212](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L212)|`if (key == LogicalKeyboardKey.escape) {`|
|interaction|[L219](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L219)|`LogicalKeyboardKey.arrowUp => -1,`|
|interaction|[L220](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L220)|`LogicalKeyboardKey.arrowDown => 1,`|
|interaction|[L221](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L221)|`LogicalKeyboardKey.arrowLeft  /  /  LogicalKeyboardKey.arrowRight => 0,`|
|interaction|[L244](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L244)|`onKeyEvent: _handleKey,`|
|interaction|[L245](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L245)|`child: MouseRegion(`|
|interaction|[L315](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L315)|`)..addStatusListener(_handleStatus);`|
|interaction|[L423](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L423)|`_animation.removeListener(_handleTick);`|
|interaction|[L424](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L424)|`value.addListener(_handleTick);`|
|interaction|[L501](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L501)|`_animation.addListener(_handleTick);`|
|interaction|[L506](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L506)|`_animation.removeListener(_handleTick);`|
|platform|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L42)|`..gestureSettings = MediaQuery.maybeGestureSettingsOf(context),`|
|platform|[L298](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L298)|`/// since a rebuild here would relayout the row from its [LayoutBuilder] and a`|
|lifecycle|[L173](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L173)|`void didUpdateWidget(SortHandle oldWidget) {`|
|lifecycle|[L174](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L174)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L318](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L318)|`void didUpdateWidget(SortableTrailing oldWidget) {`|
|lifecycle|[L319](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L319)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L333](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L333)|`void dispose() {`|
|lifecycle|[L334](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L334)|`_controller.dispose();`|
|lifecycle|[L335](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L335)|`super.dispose();`|
|lifecycle|[L511](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L511)|`void dispose() {`|
|lifecycle|[L514](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sortable.dart#L514)|`super.dispose();`|

### prism_ui/lib/surface.dart

用途：design-system：SurfaceLevel, SurfaceScope, SurfaceContext, ChromeSurfaceExt, ElevatedSurfaceExt, ElevatedSurfaceTheme, AppSurfaceThemeExt, FocusRing, Surface。复用：`packages/flutter/vendor/prism_ui/lib/surface.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/surface.dart#L285)|`class _RenderHitAbsorber extends RenderProxyBox {`|
|rendering|[L290](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/surface.dart#L290)|`class _ShapeSidePainter extends CustomPainter {`|

### prism_ui/lib/switch.dart

用途：design-system：Switch。复用：`packages/flutter/vendor/prism_ui/lib/switch.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L34)|`class _SwitchState extends State<Switch> with TickerProviderStateMixin {`|
|motion|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L41)|`static const _toggleDuration = Duration(milliseconds: 300);`|
|motion|[L42](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L42)|`static const _pressDuration = Duration(milliseconds: 150);`|
|motion|[L43](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L43)|`static const _tapLift = Duration(milliseconds: 200);`|
|motion|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L45)|`late final _toggle = AnimationController(`|
|motion|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L52)|`curve: Curves.easeOutBack,`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L53)|`reverseCurve: Curves.easeOutBack.flipped,`|
|motion|[L55](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L55)|`late final _pressController = AnimationController(`|
|motion|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L61)|`curve: Curves.easeOutCubic,`|
|motion|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L72)|`_toggle.duration = context.motionDuration(_toggleDuration);`|
|motion|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L73)|`_pressController.duration = context.motionDuration(_pressDuration);`|
|motion|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L82)|`..curve = Curves.easeOutBack`|
|motion|[L83](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L83)|`..reverseCurve = Curves.easeOutBack.flipped;`|
|motion|[L116](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L116)|`context.motionDuration(_tapLift),`|
|motion|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L125)|`..curve = Curves.linear`|
|motion|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L126)|`..reverseCurve = Curves.linear;`|
|motion|[L306](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L306)|`animation: _motion,`|
|interaction|[L282](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L282)|`onTap: enabled ? _flip : null,`|
|interaction|[L292](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L292)|`child: GestureDetector(`|
|interaction|[L320](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L320)|`return GestureDetector(`|
|interaction|[L322](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L322)|`onTapDown: (_) => _handlePress(),`|
|interaction|[L323](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L323)|`onTap: _handleRelease,`|
|interaction|[L324](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L324)|`onTapCancel: _handleCancel,`|
|lifecycle|[L70](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L70)|`void didChangeDependencies() {`|
|lifecycle|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L71)|`super.didChangeDependencies();`|
|lifecycle|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L77)|`void didUpdateWidget(Switch oldWidget) {`|
|lifecycle|[L78](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L78)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L95)|`void dispose() {`|
|lifecycle|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L97)|`_position.dispose();`|
|lifecycle|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L98)|`_press.dispose();`|
|lifecycle|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L99)|`_toggle.dispose();`|
|lifecycle|[L100](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L100)|`_pressController.dispose();`|
|lifecycle|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/switch.dart#L101)|`super.dispose();`|

### prism_ui/lib/tab_view.dart

用途：design-system：TabController, TabBarView。复用：`packages/flutter/vendor/prism_ui/lib/tab_view.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L6)|`const kTabScrollDuration = Duration(milliseconds: 300);`|
|motion|[L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L13)|`required TickerProvider vsync,`|
|motion|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L19)|`_animationController = AnimationController.unbounded(`|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L29)|`AnimationController? _animationController;`|
|motion|[L49](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L49)|`.animateTo(_index.toDouble(), duration: duration, curve: curve!)`|
|motion|[L77](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L77)|`void animateTo(int value, {Duration? duration, Curve curve = Curves.ease}) {`|
|motion|[L165](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L165)|`Future<void> _animateToPage(`|
|motion|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L171)|`await _pageController!.animateToPage(`|
|motion|[L270](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L270)|`await _animateToPage(`|
|motion|[L273](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L273)|`curve: Curves.ease,`|
|motion|[L311](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L311)|`await _animateToPage(`|
|motion|[L314](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L314)|`curve: Curves.ease,`|
|rendering|[L295](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L295)|`// Needed for RenderSliverMultiBoxAdaptor.move and kept alive children.`|
|interaction|[L151](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L151)|`_controller!.animation!.removeListener(_handleTabControllerAnimationTick);`|
|interaction|[L155](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L155)|`_controller!.animation!.addListener(_handleTabControllerAnimationTick);`|
|interaction|[L225](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L225)|`_controller!.animation!.removeListener(_handleTabControllerAnimationTick);`|
|lifecycle|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L92)|`void dispose() {`|
|lifecycle|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L93)|`_animationController?.dispose();`|
|lifecycle|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L95)|`super.dispose();`|
|lifecycle|[L180](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L180)|`void initState() {`|
|lifecycle|[L181](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L181)|`super.initState();`|
|lifecycle|[L186](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L186)|`void didChangeDependencies() {`|
|lifecycle|[L187](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L187)|`super.didChangeDependencies();`|
|lifecycle|[L201](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L201)|`void didUpdateWidget(TabBarView oldWidget) {`|
|lifecycle|[L202](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L202)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L209)|`_pageController?.dispose();`|
|lifecycle|[L223](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L223)|`void dispose() {`|
|lifecycle|[L228](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L228)|`_pageController?.dispose();`|
|lifecycle|[L230](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tab_view.dart#L230)|`super.dispose();`|

### prism_ui/lib/table_layout.dart

用途：design-system：TableColumn, TableCells, TableColumnResizer。复用：`packages/flutter/vendor/prism_ui/lib/table_layout.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|interaction|[L215](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/table_layout.dart#L215)|`return MouseRegion(`|
|interaction|[L219](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/table_layout.dart#L219)|`child: GestureDetector(`|

### prism_ui/lib/text.dart

用途：design-system：TooltipText, HoverTooltip, TooltipLabel, EmojiFont, EmojiText。复用：`packages/flutter/vendor/prism_ui/lib/text.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L69](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L69)|`class _RenderCutReporter extends RenderProxyBox {`|
|rendering|[L79](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L79)|`while (node is RenderProxyBox) {`|
|interaction|[L110](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L110)|`return MouseRegion(`|
|platform|[L210](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L210)|`style: MediaQuery.boldTextOf(context)`|
|platform|[L216](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L216)|`textScaler: MediaQuery.textScalerOf(context),`|
|lifecycle|[L223](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text.dart#L223)|`painter.dispose();`|

### prism_ui/lib/text_field.dart

用途：输入布局、验证、IME、光标、选择菜单与移动端放大镜。复用：`packages/flutter/vendor/prism_ui/lib/text_field.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L22)|`const _borderDuration = Duration(milliseconds: 167);`|
|motion|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L23)|`const _hintFade = Duration(milliseconds: 20);`|
|motion|[L436](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L436)|`curve: Curves.fastOutSlowIn,`|
|motion|[L721](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L721)|`tween: Tween(begin: 0, end: 1),`|
|motion|[L722](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L722)|`duration: context.motionDuration(_borderDuration),`|
|motion|[L723](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L723)|`curve: Curves.fastOutSlowIn,`|
|motion|[L736](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L736)|`class _BorderTween extends Tween<ShapeBorder?> {`|
|motion|[L737](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L737)|`_BorderTween({super.end});`|
|motion|[L759](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L759)|`tween: _BorderTween(end: border),`|
|motion|[L760](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L760)|`duration: context.motionDuration(_borderDuration),`|
|motion|[L761](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L761)|`curve: Curves.fastOutSlowIn,`|
|motion|[L1285](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1285)|`animation: Listenable.merge([focusNode, controller]),`|
|motion|[L1318](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1318)|`animation: controller,`|
|rendering|[L776](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L776)|`class _ContainerPainter extends CustomPainter {`|
|interaction|[L408](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L408)|`child: MouseRegion(`|
|interaction|[L813](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L813)|`class _SelectionGestures extends TextSelectionGestureDetectorBuilder {`|
|interaction|[L819](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L819)|`bool get onUserTapAlwaysCalled => _state.widget.onTapAlwaysCalled;`|
|interaction|[L822](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L822)|`void onUserTap() => _state.widget.onTap?.call();`|
|interaction|[L874](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L874)|`this.onTap,`|
|interaction|[L875](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L875)|`this.onTapAlwaysCalled = false,`|
|interaction|[L876](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L876)|`this.onTapOutside,`|
|interaction|[L889](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L889)|`final FocusNode? focusNode;`|
|interaction|[L927](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L927)|`final GestureTapCallback? onTap;`|
|interaction|[L928](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L928)|`final bool onTapAlwaysCalled;`|
|interaction|[L929](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L929)|`final TapRegionCallback? onTapOutside;`|
|interaction|[L945](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L945)|`implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {`|
|interaction|[L947](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L947)|`FocusNode? _focusNode;`|
|interaction|[L964](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L964)|`FocusNode get _effectiveFocusNode =>`|
|interaction|[L965](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L965)|`widget.focusNode ?? (_focusNode ??= FocusNode());`|
|interaction|[L1012](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1012)|`_effectiveFocusNode.canRequestFocus = widget.canRequestFocus && _isEnabled;`|
|interaction|[L1013](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1013)|`_effectiveFocusNode.addListener(_handleFocusChanged);`|
|interaction|[L1019](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1019)|`_effectiveFocusNode.canRequestFocus = _canRequestFocus;`|
|interaction|[L1034](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1034)|`(oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);`|
|interaction|[L1035](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1035)|`(widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);`|
|interaction|[L1037](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1037)|`_effectiveFocusNode.canRequestFocus = _canRequestFocus;`|
|interaction|[L1038](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1038)|`if (_effectiveFocusNode.hasFocus &&`|
|interaction|[L1048](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1048)|`_effectiveFocusNode.removeListener(_handleFocusChanged);`|
|interaction|[L1130](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1130)|`final isFocused = _effectiveFocusNode.hasFocus;`|
|interaction|[L1183](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1183)|`final focusNode = _effectiveFocusNode;`|
|interaction|[L1232](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1232)|`onTapOutside: widget.onTapOutside,`|
|interaction|[L1308](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1308)|`return MouseRegion(`|
|interaction|[L1323](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1323)|`onTap: widget.readOnly`|
|interaction|[L1346](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1346)|`child: _gestures.buildGestureDetector(`|
|interaction|[L1374](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1374)|`FocusNode? focusNode,`|
|interaction|[L1399](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1399)|`GestureTapCallback? onTap,`|
|interaction|[L1400](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1400)|`bool onTapAlwaysCalled = false,`|
|interaction|[L1401](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1401)|`TapRegionCallback? onTapOutside,`|
|interaction|[L1482](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1482)|`onTap: onTap,`|
|interaction|[L1483](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1483)|`onTapAlwaysCalled: onTapAlwaysCalled,`|
|interaction|[L1484](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1484)|`onTapOutside: onTapOutside,`|
|interaction|[L1532](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1532)|`controller.addListener(_handleControllerChanged);`|
|interaction|[L1544](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1544)|`oldWidget.controller?.removeListener(_handleControllerChanged);`|
|interaction|[L1545](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1545)|`controller?.addListener(_handleControllerChanged);`|
|interaction|[L1562](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1562)|`_textFormField.controller?.removeListener(_handleControllerChanged);`|
|platform|[L1](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1)|`import 'package:flutter/foundation.dart' show defaultTargetPlatform;`|
|platform|[L953](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L953)|`defaultTargetPlatform == TargetPlatform.android &&`|
|platform|[L996](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L996)|`defaultTargetPlatform,`|
|platform|[L1000](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1000)|`switch (MediaQuery.maybeNavigationModeOf(context) ??`|
|platform|[L1080](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1080)|`if (cause == SelectionChangedCause.drag && isDesktopPlatform) {`|
|platform|[L1169](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1169)|`final platform = defaultTargetPlatform;`|
|platform|[L1171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1171)|`platform == TargetPlatform.iOS  /  /  platform == TargetPlatform.macOS;`|
|platform|[L1172](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1172)|`forcePressEnabled = platform == TargetPlatform.iOS;`|
|platform|[L1188](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1188)|`if (isDesktopPlatform) {`|
|platform|[L1251](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1251)|`cursorOpacityAnimates: !isDesktopPlatform,`|
|platform|[L1254](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1254)|`_appleCursorOffset / MediaQuery.devicePixelRatioOf(context),`|
|platform|[L1268](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1268)|`autocorrectionTextRectColor: platform == TargetPlatform.iOS`|
|lifecycle|[L1007](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1007)|`void initState() {`|
|lifecycle|[L1008](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1008)|`super.initState();`|
|lifecycle|[L1017](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1017)|`void didChangeDependencies() {`|
|lifecycle|[L1018](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1018)|`super.didChangeDependencies();`|
|lifecycle|[L1023](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1023)|`void didUpdateWidget(TextField oldWidget) {`|
|lifecycle|[L1024](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1024)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L1030](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1030)|`_controller?.dispose();`|
|lifecycle|[L1047](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1047)|`void dispose() {`|
|lifecycle|[L1049](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1049)|`_focusNode?.dispose();`|
|lifecycle|[L1050](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1050)|`_controller?.dispose();`|
|lifecycle|[L1051](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1051)|`super.dispose();`|
|lifecycle|[L1526](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1526)|`void initState() {`|
|lifecycle|[L1527](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1527)|`super.initState();`|
|lifecycle|[L1538](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1538)|`void didUpdateWidget(TextFormField oldWidget) {`|
|lifecycle|[L1539](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1539)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L1554](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1554)|`_controller?.dispose();`|
|lifecycle|[L1561](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1561)|`void dispose() {`|
|lifecycle|[L1563](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1563)|`_controller?.dispose();`|
|lifecycle|[L1564](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_field.dart#L1564)|`super.dispose();`|

### prism_ui/lib/text_loupe.dart

用途：design-system：TextLoupe。复用：`packages/flutter/vendor/prism_ui/lib/text_loupe.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L4)|`import 'package:flutter/physics.dart' show SpringDescription, SpringSimulation;`|
|motion|[L15](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L15)|`const _loupeOutDuration = Duration(milliseconds: 276);`|
|motion|[L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L16)|`const _loupeGrowSpring = SpringDescription(mass: 1, stiffness: 70, damping: 10);`|
|motion|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L17)|`const _loupeFollowSpring = SpringDescription(`|
|motion|[L45](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L45)|`class _TextLoupeState extends State<TextLoupe> with TickerProviderStateMixin {`|
|motion|[L46](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L46)|`late final AnimationController _grow;`|
|motion|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L47)|`late final AnimationController _x;`|
|motion|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L53)|`_grow = AnimationController(`|
|motion|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L58)|`_x = AnimationController.unbounded(vsync: this);`|
|motion|[L92](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L92)|`_grow.animateWith(`|
|motion|[L93](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L93)|`SpringSimulation(_loupeGrowSpring, _grow.value, 1, _grow.velocity),`|
|motion|[L113](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L113)|`_x.animateWith(`|
|motion|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L114)|`SpringSimulation(_loupeFollowSpring, _x.value, target, _x.velocity),`|
|motion|[L125](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L125)|`animation: Listenable.merge([_grow, _x]),`|
|interaction|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L61)|`widget.magnifierInfo.addListener(_onInfoChanged);`|
|interaction|[L74](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L74)|`oldWidget.magnifierInfo.removeListener(_onInfoChanged);`|
|interaction|[L75](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L75)|`widget.magnifierInfo.addListener(_onInfoChanged);`|
|interaction|[L82](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L82)|`widget.magnifierInfo.removeListener(_onInfoChanged);`|
|platform|[L24](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L24)|`magnifierBuilder: (context, controller, magnifierInfo) => isDesktopPlatform`|
|platform|[L106](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L106)|`final screenWidth = MediaQuery.sizeOf(context).width;`|
|lifecycle|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L51)|`void initState() {`|
|lifecycle|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L52)|`super.initState();`|
|lifecycle|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L65)|`void didChangeDependencies() {`|
|lifecycle|[L66](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L66)|`super.didChangeDependencies();`|
|lifecycle|[L71](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L71)|`void didUpdateWidget(TextLoupe oldWidget) {`|
|lifecycle|[L72](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L72)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L81](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L81)|`void dispose() {`|
|lifecycle|[L86](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L86)|`_x.dispose();`|
|lifecycle|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L87)|`_grow.dispose();`|
|lifecycle|[L88](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_loupe.dart#L88)|`super.dispose();`|

### prism_ui/lib/text_selection_controls.dart

用途：design-system：。复用：`packages/flutter/vendor/prism_ui/lib/text_selection_controls.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L105](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L105)|`class _HandlePainter extends CustomPainter {`|
|interaction|[L54](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L54)|`VoidCallback? onTap,`|
|interaction|[L73](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L73)|`VoidCallback? onTap,`|
|platform|[L17](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L17)|`bool get isDesktopPlatform => switch (defaultTargetPlatform) {`|
|platform|[L18](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L18)|`TargetPlatform.macOS  /  / `|
|platform|[L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L19)|`TargetPlatform.linux  /  / `|
|platform|[L20](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L20)|`TargetPlatform.windows => true,`|
|platform|[L21](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L21)|`TargetPlatform.android  /  / `|
|platform|[L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L22)|`TargetPlatform.iOS  /  / `|
|platform|[L23](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L23)|`TargetPlatform.fuchsia => false,`|
|platform|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L26)|`TextSelectionControls textSelectionControlsFor(TargetPlatform platform) =>`|
|platform|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L28)|`TargetPlatform.android  /  / `|
|platform|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L29)|`TargetPlatform.iOS  /  / `|
|platform|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L30)|`TargetPlatform.fuchsia => _touchTextSelectionControls,`|
|platform|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L31)|`TargetPlatform.macOS  /  / `|
|platform|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L32)|`TargetPlatform.linux  /  / `|
|platform|[L33](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_controls.dart#L33)|`TargetPlatform.windows => _pointerTextSelectionControls,`|

### prism_ui/lib/text_selection_menu.dart

用途：design-system：TextSelectionMenu。复用：`packages/flutter/vendor/prism_ui/lib/text_selection_menu.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|rendering|[L223](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L223)|`if (items.isEmpty  /  /  navigator == null  /  /  navigatorBox is! RenderBox) {`|
|rendering|[L233](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L233)|`RenderBox navigatorBox,`|
|rendering|[L248](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L248)|`if (box is! RenderBox  /  /  !box.attached) {`|
|rendering|[L259](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L259)|`RenderBox navigatorBox,`|
|platform|[L41](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L41)|`if (!isDesktopPlatform &&`|
|platform|[L226](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L226)|`final route = _route = isDesktopPlatform`|
|lifecycle|[L97](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L97)|`void initState() {`|
|lifecycle|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L98)|`super.initState();`|
|lifecycle|[L103](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L103)|`void didUpdateWidget(TextSelectionMenu oldWidget) {`|
|lifecycle|[L104](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L104)|`super.didUpdateWidget(oldWidget);`|
|lifecycle|[L130](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L130)|`void dispose() {`|
|lifecycle|[L133](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L133)|`_selection.dispose();`|
|lifecycle|[L134](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L134)|`_items.dispose();`|
|lifecycle|[L136](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/text_selection_menu.dart#L136)|`super.dispose();`|

### prism_ui/lib/theme_cross_fade.dart

用途：design-system：ThemeCrossFade。复用：`packages/flutter/vendor/prism_ui/lib/theme_cross_fade.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L25](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L25)|`with SingleTickerProviderStateMixin {`|
|motion|[L26](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L26)|`late final _controller = AnimationController(`|
|rendering|[L135](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L135)|`class _RenderThemeCrossFade extends RenderProxyBox {`|
|interaction|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L29)|`)..addStatusListener(_handleStatus);`|
|interaction|[L170](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L170)|`_progress.removeListener(markNeedsPaint);`|
|interaction|[L171](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L171)|`value.addListener(markNeedsPaint);`|
|interaction|[L192](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L192)|`_progress.addListener(markNeedsPaint);`|
|interaction|[L197](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L197)|`_progress.removeListener(markNeedsPaint);`|
|platform|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L61)|`final image = fade.capture(MediaQuery.devicePixelRatioOf(context));`|
|lifecycle|[L36](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L36)|`void didChangeDependencies() {`|
|lifecycle|[L37](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L37)|`super.didChangeDependencies();`|
|lifecycle|[L51](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L51)|`case AppLifecycleState.hidden  /  / `|
|lifecycle|[L52](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L52)|`AppLifecycleState.paused  /  / `|
|lifecycle|[L53](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L53)|`AppLifecycleState.detached:`|
|lifecycle|[L65](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L65)|`_snapshot?.dispose();`|
|lifecycle|[L78](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L78)|`_snapshot?.dispose();`|
|lifecycle|[L84](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L84)|`void dispose() {`|
|lifecycle|[L85](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L85)|`_controller.dispose();`|
|lifecycle|[L87](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_cross_fade.dart#L87)|`super.dispose();`|

### prism_ui/lib/theme_data.dart

用途：design-system：ThemeMode, TapTargetSize, Colors, Easing, VisualDensity, ThemeData, Theme。复用：`packages/flutter/vendor/prism_ui/lib/theme_data.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|motion|[L12](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L12)|`const kThemeAnimationDuration = Duration(milliseconds: 200);`|
|motion|[L27](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L27)|`static const emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);`|
|motion|[L28](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L28)|`static const legacyDecelerate = Cubic(0, 0, 0.2, 1);`|
|motion|[L29](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L29)|`static const standard = Cubic(0.2, 0, 0, 1);`|
|motion|[L30](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L30)|`static const standardAccelerate = Cubic(0.3, 0, 1, 1);`|
|motion|[L31](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L31)|`static const standardDecelerate = Cubic(0, 0, 0, 1);`|
|platform|[L3](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L3)|`import 'package:flutter/foundation.dart' show defaultTargetPlatform, immutable;`|
|platform|[L95](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L95)|`TargetPlatform platform, {`|
|platform|[L98](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L98)|`TargetPlatform.android  /  / `|
|platform|[L99](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L99)|`TargetPlatform.fuchsia => (family: 'Roboto', fallback: null),`|
|platform|[L101](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L101)|`TargetPlatform.iOS => (`|
|platform|[L105](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L105)|`TargetPlatform.macOS => (family: '.AppleSystemUIFont', fallback: null),`|
|platform|[L106](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L106)|`TargetPlatform.windows => (family: 'Segoe UI', fallback: null),`|
|platform|[L107](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L107)|`TargetPlatform.linux => (family: 'Roboto', fallback: _linuxFallback),`|
|platform|[L114](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L114)|`TargetPlatform? platform,`|
|platform|[L124](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L124)|`final effectivePlatform = platform ?? defaultTargetPlatform;`|
|platform|[L126](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L126)|`TargetPlatform.macOS  /  / `|
|platform|[L127](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L127)|`TargetPlatform.windows  /  / `|
|platform|[L128](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L128)|`TargetPlatform.linux => true,`|
|platform|[L159](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L159)|`static final _fallbacks = <TargetPlatform, ThemeData>{};`|
|platform|[L162](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L162)|`final TargetPlatform platform;`|
|platform|[L209](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L209)|`TargetPlatform? platform,`|
|platform|[L241](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/theme_data.dart#L241)|`ThemeData._fallbacks.putIfAbsent(defaultTargetPlatform, ThemeData.new);`|

### prism_ui/lib/tooltip.dart

用途：design-system：Tooltip。复用：`packages/flutter/vendor/prism_ui/lib/tooltip.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L58](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L58)|`final desktop = switch (defaultTargetPlatform) {`|
|platform|[L59](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L59)|`TargetPlatform.macOS  /  / `|
|platform|[L60](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L60)|`TargetPlatform.linux  /  / `|
|platform|[L61](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L61)|`TargetPlatform.windows => true,`|
|platform|[L62](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L62)|`TargetPlatform.android  /  / `|
|platform|[L63](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L63)|`TargetPlatform.fuchsia  /  / `|
|platform|[L64](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/tooltip.dart#L64)|`TargetPlatform.iOS => false,`|

### prism_ui/lib/view_scope.dart

用途：design-system：ViewScopeAspect, ViewScope。复用：`packages/flutter/vendor/prism_ui/lib/view_scope.dart`。状态：已原样提取。依赖边见 source-index.json。

|类别|源码位置|证据|
|---|---|---|
|platform|[L3](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L3)|`enum ViewScopeAspect { size, isMobile, windowControls }`|
|platform|[L9](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L9)|`required this.isMobile,`|
|platform|[L15](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L15)|`final bool isMobile;`|
|platform|[L32](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L32)|`static bool isMobileOf(BuildContext context, {bool listen = true}) {`|
|platform|[L34](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L34)|`return _of(context, ViewScopeAspect.isMobile).isMobile;`|
|platform|[L38](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L38)|`return scope!.isMobile;`|
|platform|[L47](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L47)|`isMobile != oldWidget.isMobile  /  / `|
|platform|[L57](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/view_scope.dart#L57)|`ViewScopeAspect.isMobile => isMobile != oldWidget.isMobile,`|
