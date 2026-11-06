# Sources and modifications

FlClash-UI-Kit includes code derived from:

- chen08209/FlClash, commit `be84736605527034689c95bf27828ff27d912c5e`, GPL-3.0. Original source: https://github.com/chen08209/FlClash
- chen08209/prism_ui, commit `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185`, GPL-3.0. Original source: https://github.com/chen08209/prism_ui

Original copyright holders retain their rights. This project does not claim authorship of upstream implementations. Unmodified snapshots are Git submodules under `source/upstream`. Derived files include source paths, commit and modification dates. The main, editor, platform and web extraction ledgers under docs/audit and their tools/extract*.py generators identify precise adaptations and source commits.

The runtime prism_ui copy is in `packages/flutter/vendor/prism_ui`. Its only runtime implementation change is the explicitly supplied `Clip.antiAlias` argument to `SceneBuilder.pushClipRSuperellipse` for Flutter 3.47.9 Web compilation. Application adaptations remove service/provider/singleton access in favor of localization, scoped measurement, presentation data and callbacks. The complete outbound card, traffic, memory, services, network controls, profile summaries/details, form/filter/preview and scan presentation are adapted with host-owned data and callbacks. Partial-page boundaries remain explicit in the extraction ledgers. Some regression suites were adapted by changing imports and test hosts. New KitApp, localization, documentation, tooling and Showcase composition are GPL-3.0-only.

Third-party notices retained from prism_ui:

- `lib/hct/`: material_color_utilities, Copyright 2021 Google LLC, Apache-2.0.
- `lib/shapes/`: material_new_shapes, Copyright (c) 2025 Agbama Gifted, MIT.
- `lib/sliver_list/`: super_sliver_list, Copyright (c) 2024 Matej Knopp, Superlist and contributors, MIT.
- `lib/navigator_resizable.dart`: navigator_resizable, Copyright (c) 2024 Daichi Fujita, MIT.
- `shaders/ink_sparkle.frag`: Flutter, Copyright 2013 The Flutter Authors, BSD-3-Clause.
- FlClash `lib/ui/qr_matrix.dart`: Copyright 2014, the Dart QR project authors, BSD-3-Clause; its full notice remains in the derived file.

The optional packages/editor retains complete code_forge and the Rust document backend under their MIT notice (Copyright 2025 FlClash and Athul A S), integrated through an editor-only GPL crate and regenerated FRB 2.13.0 bindings. packages/platform retains unchanged window/tray/dynamic-color plugins plus an adapted GPL caption controller; its initial query cannot overwrite newer native events. packages/web extracts the native Canvas field and tokens from the FlClash site, with explicit lifecycle cleanup. See `docs/audit/license-inventory.md` and `licenses/dependencies` for dependency license texts. Generated Flutter host projects are derived from Flutter templates under the Flutter Authors' BSD-3-Clause license.

Unmodified JetBrains Mono 2.304 is bundled under OFL-1.1 with its complete notice, after byte comparison to the official release. Service SVGs retain their upstream Simple Icons 13.0.0/CC0 and FlClash artwork notice. The original emoji font, avatars, app/tray logos and GeoIP databases remain outside runtime packages. Their source-tree presence records upstream history and is not a grant of additional rights. System font family names refer to fonts installed by the host OS. Service artwork preserves its own notice; no trademark rights are granted. Full retained third-party notices are also bundled inside packages/flutter and packages/editor and registered with Flutter LicenseRegistry. Dart and Cargo dependency inventories are under licenses/dependencies and licenses/rust.
