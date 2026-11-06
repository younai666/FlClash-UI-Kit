# 许可证与分发边界
固定源码的静态调查，日期：2026-11-05。文件枚举、全文特征扫描和 import/export/part 反向关系由 `python tools/audit.py --write` 生成；人工分析聚焦入口、组件、绘制、动效及服务耦合。枚举覆盖不等于逐行人工语义审查或逐组件运行验收。

独立复查与边界见 [review-findings.md](review-findings.md)。完整逐文件证据（包括所有依赖边、反向调用者、行号、平台、生命周期和许可证头）见 [source-index.json](source-index.json)。使用 `python tools/audit.py --check` 检查清单是否仍与锁定源码一致。

此表记录源码证据与分发决定；未知内容保持未知。根 LICENSE 使用 GPL-3.0 文本，衍生代码按 GPL-3.0-only 处理，上游已有更具体的授权头保持原样。完整源码和版本随 Git 子模块可获取。

|内容|源码证据|授权/版权|分发决定|
|---|---|---|---|
|FlClash、prism_ui|各根 LICENSE，README|GPL-3.0；原作者 chen08209/贡献者|保留完整来源和许可；修改逐文件标记|
|prism_ui/hct|每个文件 Apache 头；NOTICE|Google LLC 2021，Apache-2.0|保留原头和 NOTICE|
|prism_ui/shapes|shapes.dart 完整 MIT；NOTICE|Agbama Gifted 2025，MIT|保留完整许可|
|prism_ui/sliver_list|每个文件完整 MIT；NOTICE|Matej Knopp、Superlist 及贡献者 2024，MIT|保留完整许可|
|navigator_resizable|文件头完整 MIT|Daichi Fujita 2024，MIT|保留完整许可|
|ink_sparkle shader|shader 头及 NOTICE|Flutter Authors 2013，BSD-3-Clause|保留版权并补齐许可文本|
|QrMatrix|lib/ui/qr_matrix.dart 完整 BSD 头|Dart QR project authors 2014，BSD-3-Clause|保留完整许可|
|code_forge 与 Rust editor|plugins/code_forge/LICENSE；Rust editor/mod.rs|FlClash、Athul A S 2025，MIT；适配集成 GPL-3.0|独立原生可选包，保持 MIT 原文及生成桥接来源|
|window、tray、wifi_ssid|各插件 LICENSE|MIT；window 含 LiJianying 版权|保留，平台注册仍由宿主负责|
|dynamic_color|插件 LICENSE|Apache-2.0|保留|
|服务图标|assets/images/services/LICENSE.md；完整 CC0 文本已保留|Simple Icons 13.0 CC0；Claude/Disney 中性标记由 FlClash 自绘|已原样纳入服务组件；不授予商标权|
|JetBrainsMono-Regular.ttf|name 表为 2.304；与 JetBrains 官方 v2.304 字节一致；完整 OFL 在包内|OFL-1.1；2020 JetBrains Mono Project Authors|已原样注册；字体包名命名空间已适配|
|Twemoji.Mozilla.ttf|内部 family 实为 Twemoji COLRv0；与 Emoji-COLRv0 项目字体字节一致|具体来源已定位，项目表格 BY-SA 与正文 BY 授权描述冲突；见 review-findings|继续隔离，未注册到运行时；不以 Mozilla 文件名推断授权|
|avatar/arue.jpg、june2.jpg，应用/托盘 Logo|未见独立资源授权|未明确|隔离：不纳入组件库资源、不声称可自由使用|
|GeoIP/ASN/geosite/CA|assets/data；core 子模块|业务数据/证书各自授权，UI 无需使用|不纳入组件包|

## 已发现的所有版权/许可头

|源文件|证据|
|---|---|
|[FlClash/.agents/rules.md:L136](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/rules.md#L136)|directives (`// ignore:`, `// ignore_for_file:`, `// coverage:ignore`), license and copyright headers,|
|[FlClash/README.md:L39](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/README.md#L39)|- **Open source and ad-free**, licensed under GPL-3.0.|
|[FlClash/assets_source/images/icon/status_4.svg:L2](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/assets_source/images/icon/status_4.svg#L2)|<!-- Glyph: Material Symbols "bug_report" (Rounded, filled), Apache License 2.0 -->|
|[FlClash/lib/ui/qr_matrix.dart:L2](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_matrix.dart#L2)|Copyright 2014, the Dart QR project authors. All rights reserved.|
|[FlClash/lib/ui/qr_matrix.dart:L7](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_matrix.dart#L7)|* Redistributions of source code must retain the above copyright|
|[FlClash/lib/ui/qr_matrix.dart:L10](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_matrix.dart#L10)|copyright notice, this list of conditions and the following|
|[FlClash/lib/ui/qr_matrix.dart:L17](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_matrix.dart#L17)|THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS|
|[FlClash/lib/ui/qr_matrix.dart:L20](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/ui/qr_matrix.dart#L20)|A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT|
|[FlClash/macos/Runner/Configs/AppInfo.xcconfig:L13](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/macos/Runner/Configs/AppInfo.xcconfig#L13)|// The copyright displayed in application information|
|[FlClash/macos/Runner/Configs/AppInfo.xcconfig:L14](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/macos/Runner/Configs/AppInfo.xcconfig#L14)|PRODUCT_COPYRIGHT = Copyright © 2023 com.follow. All rights reserved.|
|[FlClash/macos/Runner/Info.plist:L40](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/macos/Runner/Info.plist#L40)|<key>NSHumanReadableCopyright</key>|
|[FlClash/macos/Runner/Info.plist:L41](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/macos/Runner/Info.plist#L41)|<string>$(PRODUCT_COPYRIGHT)</string>|
|[FlClash/plugins/code_forge/README.md:L6](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/code_forge/README.md#L6)|the `chen08209/code_forge` fork, and keeps upstream's MIT license (see `LICENSE`).|
|[FlClash/plugins/dynamic_color/macos/dynamic_color.podspec:L4](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/dynamic_color/macos/dynamic_color.podspec#L4)|s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }|
|[FlClash/plugins/rust_api/rust/src/editor/mod.rs:L2](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/plugins/rust_api/rust/src/editor/mod.rs#L2)|//! (https://github.com/heckmon/code_forge), MIT License, Copyright (c) 2025|
|[FlClash/site/assets/shared.js:L46](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/assets/shared.js#L46)|fact4: 'Licensed under GPL-3.0, with no ads.',|
|[FlClash/site/index.html:L124](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/site/index.html#L124)|<li><b data-i18n="fact4Title">Open source</b><span data-i18n="fact4">Licensed under GPL-3.0, with no ads.</span></li>|
|[FlClash/tool/hooks/comment_density_test.sh:L105](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/tool/hooks/comment_density_test.sh#L105)|for i in $(seq 1 8); do echo '// Copyright 2026 The FlClash Authors.'; done|
|[FlClash/windows/packaging/exe/ChineseSimplified.isl:L35](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/packaging/exe/ChineseSimplified.isl#L35)|;CopyrightFontName=Arial|
|[FlClash/windows/packaging/exe/ChineseSimplified.isl:L36](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/packaging/exe/ChineseSimplified.isl#L36)|;CopyrightFontSize=8|
|[FlClash/windows/runner/Runner.rc:L96](https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/windows/runner/Runner.rc#L96)|VALUE "LegalCopyright", "Copyright (C) 2025 com.follow. All rights reserved." "\0"|
|[prism_ui/NOTICE:L3](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/NOTICE#L3)|- lib/hct/: material_color_utilities, Copyright 2021 Google LLC, Apache License 2.0|
|[prism_ui/NOTICE:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/NOTICE#L4)|- lib/shapes/: material_new_shapes, Copyright (c) 2025 Agbama Gifted, MIT License|
|[prism_ui/NOTICE:L5](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/NOTICE#L5)|- lib/sliver_list/: super_sliver_list, Copyright (c) 2024 Matej Knopp, Superlist and the contributors, MIT License|
|[prism_ui/NOTICE:L6](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/NOTICE#L6)|- lib/navigator_resizable.dart: navigator_resizable, Copyright (c) 2024 Daichi Fujita, MIT License|
|[prism_ui/NOTICE:L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/NOTICE#L7)|- shaders/ink_sparkle.frag: Flutter, Copyright 2013 The Flutter Authors, BSD 3-Clause License|
|[prism_ui/lib/hct/color_math.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/color_math.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/color_math.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/color_math.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/dynamic_color.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/dynamic_color.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/dynamic_color.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/dynamic_color.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/dynamic_scheme.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/dynamic_scheme.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/dynamic_scheme.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/dynamic_scheme.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/hct.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/hct.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/hct.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/hct.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/hct_solver.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/hct_solver.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/hct_solver.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/hct_solver.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/material_dynamic_colors.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/material_dynamic_colors.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/material_dynamic_colors.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/material_dynamic_colors.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/tonal_palette.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/tonal_palette.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/tonal_palette.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/tonal_palette.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/hct/viewing_conditions.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/viewing_conditions.dart#L2)|Copyright 2021 Google LLC|
|[prism_ui/lib/hct/viewing_conditions.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/hct/viewing_conditions.dart#L4)|Licensed under the Apache License, Version 2.0 (the "License");|
|[prism_ui/lib/navigator_resizable.dart:L5](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L5)|The MIT License (MIT)|
|[prism_ui/lib/navigator_resizable.dart:L7](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L7)|Copyright (c) 2024 Daichi Fujita|
|[prism_ui/lib/navigator_resizable.dart:L16](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L16)|The above copyright notice and this permission notice shall be included in|
|[prism_ui/lib/navigator_resizable.dart:L22](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/navigator_resizable.dart#L22)|AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER|
|[prism_ui/lib/shapes/shapes.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/shapes.dart#L2)|MIT License|
|[prism_ui/lib/shapes/shapes.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/shapes.dart#L4)|Copyright (c) 2025 Agbama Gifted|
|[prism_ui/lib/shapes/shapes.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/shapes.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/shapes/shapes.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/shapes/shapes.dart#L19)|AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER|
|[prism_ui/lib/sliver_list/element.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/element.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/element.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/element.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/element.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/element.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/element.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/element.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/extent_list.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_list.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/extent_list.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_list.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/extent_list.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_list.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/extent_list.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_list.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/extent_manager.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_manager.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/extent_manager.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_manager.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/extent_manager.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_manager.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/extent_manager.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/extent_manager.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/fenwick_tree.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/fenwick_tree.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/fenwick_tree.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/fenwick_tree.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/fenwick_tree.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/fenwick_tree.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/fenwick_tree.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/fenwick_tree.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/layout_pass.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/layout_pass.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/layout_pass.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/layout_pass.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/layout_pass.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/render_object.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/render_object.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/render_object.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/render_object.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/render_object.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/sliver_extensions.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/sliver_extensions.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/sliver_extensions.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/sliver_extensions.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/sliver_extensions.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/sliver_extensions.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/sliver_extensions.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/sliver_extensions.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/lib/sliver_list/super_sliver_list.dart:L2](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L2)|Copyright (c) 2024 Matej Knopp, Superlist and the contributors|
|[prism_ui/lib/sliver_list/super_sliver_list.dart:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L4)|MIT LICENSE|
|[prism_ui/lib/sliver_list/super_sliver_list.dart:L13](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L13)|The above copyright notice and this permission notice shall be included in all|
|[prism_ui/lib/sliver_list/super_sliver_list.dart:L19](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/lib/sliver_list/super_sliver_list.dart#L19)|OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,|
|[prism_ui/shaders/ink_sparkle.frag:L3](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/shaders/ink_sparkle.frag#L3)|// Copyright 2013 The Flutter Authors|
|[prism_ui/shaders/ink_sparkle.frag:L4](https://github.com/chen08209/prism_ui/blob/63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185/shaders/ink_sparkle.frag#L4)|// Use of this source code is governed by a BSD-style license that can be|

五个实际消费包（含 standalone 示例）的 Dart 依赖完整许可见 ../../licenses/dependencies/index.json；Rust Cargo.lock 全图见 ../../licenses/rust/index.json。tools/dependency_licenses.py、rust_licenses.py 与 bundled_notices.py 保存完整许可证并将必要原文装入运行时包；许可证缺失或字体授权未清之前，不发布含这些内容的二进制/资产包。法律条文以各原始许可证为准。
