---
name: flclash-ui-kit
description: Reuse FlClash and prism_ui visuals, native Flutter widgets, motion, responsive layouts and interactions when building or adapting software in the FlClash style. For other stacks, derive a port from the original implementation and document fidelity limits.
---

# FlClash UI Kit

Treat this directory as the resource root. Keep the entire repository accessible; copying this file alone loses the component code, shaders, examples, provenance and licenses.

## Find the implementation

1. Read [README.md](README.md) for installation and the current delivery boundary, then [docs/components/catalog.md](docs/components/catalog.md) to locate the component family.
2. Read the matching actual widget constructor and its callers. Search `packages/flutter/lib/src` for extracted application widgets and `packages/flutter/vendor/prism_ui/lib` for the complete design system. `showcase/lib` contains compiled, interactive calls; `packages/flutter/test` and `source/upstream/prism_ui/test` contain regression examples.
3. For a page or unfamiliar effect, search [docs/audit/ui-inventory.md](docs/audit/ui-inventory.md), [motion-inventory.md](docs/audit/motion-inventory.md) and [source-index.json](docs/audit/source-index.json). The JSON records every tracked source file, declarations, imports, reverse callers, assets and line evidence. Follow imports and `part` files down to render objects, gestures, physics and shaders.
4. Check [extraction-matrix.md](docs/audit/extraction-matrix.md). Reference-only and partially extracted pages are not ready-to-call library APIs. The unmodified upstream sources and exact versions live under `source/upstream` and [upstream-lock.json](source/upstream-lock.json).
5. Read [review-findings.md](docs/audit/review-findings.md) for omissions found outside the initial inventory, partial-file boundaries, font evidence and remaining work. A generated census is not evidence of complete semantic or visual acceptance.

## Flutter

Read [docs/usage/flutter.md](docs/usage/flutter.md) and the relevant example in `showcase/lib` before composing a screen.

- Depend on the complete `packages/flutter` directory. Its `vendor/prism_ui` is a required local path dependency; retain that directory and its shaders. The common import is `package:flclash_ui_kit/flclash_ui_kit.dart`; icon and polygon entrypoints are `icons.dart` and `shapes.dart`. Use an import prefix when also importing Material/Cupertino or polygon `Cubic`.
- Start with `KitApp`. It supplies PrismApp, both theme brightnesses, UiLocalizations, MeasureScope, ViewScope and the single glass capture host. Advanced hosts may use PrismApp directly but must provide its documented scopes and localization delegates. English and Chinese are supplied; add other strings/locales explicitly.
- Preserve the upstream defaults in `KitApp`: vivid color style, blue seed, optional glass, platform/locale font fallback and elevated dark surfaces. Keep system font references distinct from bundled JetBrains Mono. Custom Prism hosts register `KitLocalizations.delegate`, `KitLocalizations.stringsDelegate` and `registerKitLicenses()`; the separate strings delegate permits a host-owned UiLocalizations implementation.
- Keep state ownership explicit. Pass values, `ValueNotifier`s and callbacks. Dispose the controllers you create. `DashboardEditor` consumes `DashboardItem`s and reports the shown order through `onChanged`; it performs no persistence. `RecordTableFrame` reports column widths through its required callback; store them in the host as needed.
- Use `showSnapSheet`'s supplied scroll controller for the sheet body. Give floating navigation and charts finite height. Keep stable row keys and stable Dashboard GlobalKeys across editing. Read [docs/components/contracts.md](docs/components/contracts.md) for these integration constraints.
- Use the existing `SurfaceLevel`, `AppTextStyle`, `AppShape` and seed-based `ColorScheme` rather than guessing colors or replacing superellipses with ordinary round rectangles. Preserve the original spring, gesture velocity, state transition and accessibility behavior. Changing the reduced-motion behavior is a separate, verified change.

## Optional native and JavaScript implementations

Read [docs/usage/native.md](docs/usage/native.md) before adding the optional packages.

- `packages/editor` contains the complete vendored CodeForge renderer, editor-only Rust API and generated bridge. Depend on the complete package plus its sibling `packages/flutter`; call `WidgetsFlutterBinding.ensureInitialized()` then `await initializeEditor()` before constructing CodeForge controllers. `NativeCodeEditor` accepts those controllers and explicit language/font/wrap/read-only/completion inputs. Use `showcase/lib/editor_native.dart` and `packages/editor/test/native_surface_test.dart` as actual calls. This package is native-only; Web uses a truthful unavailable state.
- `packages/platform` contains original window/tray/dynamic-color plugins and the event-driven `WindowCaptionController`. Initialize only capabilities the host needs, remove listeners/dispose controllers, and let native maximize/fullscreen events update caption state. Closing behavior, persistence, service ownership and tray icon choice belong to the host. `showcase/lib/platform.dart` distinguishes presentation callbacks from actual native capability reads.
- `packages/web` is the native JavaScript Canvas field discovered in the upstream site. Read its [README](packages/web/README.md), use `mountField(canvas, options)` and call `dispose()` on unmount. Its demo is `showcase/web-field.html`. It does not make the Flutter widget library callable from JavaScript.

For application components, inspect [presentation.md](docs/components/presentation.md): full outbound card, traffic history, memory reader/release callbacks, service states, record filtering, drafts and scan painters. Do not replace host-owned services with hidden networking or a simulated success path.

## Other stacks and missing pieces

Read [docs/usage/porting.md](docs/usage/porting.md). Flutter widgets, RenderObjects, SceneBuilder and fragment programs are not directly callable from React, SwiftUI, Compose or CSS. Port the data contract, shape geometry, physical model, lifecycle, focus and input semantics from the actual implementation; validate both the settled frame and intermediate motion. State which effects are approximate or unavailable on that renderer.

When a component is absent, inspect the extraction matrix and upstream callers first. Prefer finishing a known decoupling over drawing a replacement from a screenshot. Separate service/data access from presentation with explicit inputs and callbacks. Match nearby tokens and interaction contracts, add a real Showcase call and tests for the changed boundary, and update the catalog and extraction record. Do not claim a TextField is the Rust-backed CodeForge editor.

## Source, licensing and verification

Read [NOTICE.md](NOTICE.md) and [docs/audit/license-inventory.md](docs/audit/license-inventory.md) before copying code or assets. Preserve GPL and third-party headers. Optional fonts, avatars and logos are quarantined from the runtime package where authorization remains unconfirmed. System font names do not grant redistribution rights.

Use [docs/usage/maintenance.md](docs/usage/maintenance.md) for updates. Upstream snapshots stay unmodified. Explicit adaptations are reproduced and checked by `tools/extract.py`; do not edit a vendored file without updating its recipe and provenance. Test evidence and actual limitations belong in [docs/audit/verification.md](docs/audit/verification.md). Build or run only the UI library/Showcase for normal reuse; the upstream proxy application's bootstrap has networking and system-service effects.
