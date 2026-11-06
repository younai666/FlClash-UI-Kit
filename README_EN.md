# FlClash-UI-Kit

[English](README_EN.md) · [简体中文](README.md)

[![Version](https://img.shields.io/badge/version-v0.1.0--preview-blue.svg)](docs/audit/verification.md)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.47.2-02569B.svg?logo=flutter)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/decoupled-100%25%20core%20free-brightgreen.svg)](docs/components/presentation.md)

A native, high-fidelity Flutter UI & design system suite, physics animations, and reusable views extracted completely from [FlClash](https://github.com/chen08209/FlClash) and [prism_ui](https://github.com/chen08209/prism_ui), accompanied by a universal AI Agent Skill.

Frontend visuals, interactions, and physics motions are thoroughly decoupled from the original Clash proxy core (Clash.Meta), global state management (Riverpod), and low-level proxy services. Any standard Flutter application can directly reuse its adaptive shell, refined dashboard, system color palettes, smooth gestures, and production-grade components without inheriting any proxy business baggage.

---

## Table of Contents

- [Core Features](#core-features)
- [AI Agent Integration & Prompts](#ai-agent-integration--prompts)
  - [Option 1: One-Shot UI/UX Strict Constraint (Zero Install)](#option-1-one-shot-uiux-strict-constraint-zero-install)
  - [Option 2: Project-Level Persistent Skill Installation (Long-Term Reuse)](#option-2-project-level-persistent-skill-installation-long-term-reuse)
- [Quick Start](#quick-start)
- [Key Components & Code Examples](#key-components--code-examples)
  - [1. Base Application Environment (KitApp)](#1-base-application-environment-kitapp)
  - [2. Adaptive App Shell & Navigation (HomePage)](#2-adaptive-app-shell--navigation-homepage)
  - [3. Dashboard & Performance Cards (Dashboard)](#3-dashboard--performance-cards-dashboard)
  - [4. Theme Settings & Font Previews (ThemeView)](#4-theme-settings--font-previews-themeview)
  - [5. Legal Terms & Repeat-to-Agree Flow (DisclaimerView)](#5-legal-terms--repeat-to-agree-flow-disclaimerview)
  - [6. Form Editor & Multi-Dimensional Records (Form & Records)](#6-form-editor--multi-dimensional-records-form--records)
- [Optional Native & Web Extensions](#optional-native--web-extensions)
- [Showcase Interactive Gallery & Running](#showcase-interactive-gallery--running)
- [Known Limitations & Decoupling Boundaries](#known-limitations--decoupling-boundaries)
- [Project Architecture & Tech Stack](#project-architecture--tech-stack)
- [Open-Source Compliance & Licensing](#open-source-compliance--licensing)

---

## Core Features

- **Complete Design System**: Built on `prism_ui` modern design language, featuring Liquid Glass rendering, superellipse shapes, spring-damper physics, smooth touch overscroll bounce, and a comprehensive semantic typography hierarchy.
- **Pure Frontend Decoupling**: The core package (`packages/flutter`) has zero imports of `dart:io`, `dart:ffi`, or `dart:isolate`, completely eliminates Riverpod and global singletons, and is 100% Web-safe across all platforms.
- **Out-of-the-Box Complete Views**: Adaptive desktop/mobile shell (`HomePage`), full-featured dashboard (`DashboardView`), node selector and latency speed cards (`ProxiesView`), profile manager (`ProfilesView`), network/DNS/log monitors (`RequestsView`, `LogsView`), theme and font personalizer (`ThemeView`, `FontFamilyView`), global hotkey recorder (`HotKeyView`), and legal consent flow (`AboutView`, `DisclaimerView`).
- **Optional Native Enhancements & Web Effects**: Optional high-performance code editor (`packages/editor`, powered by Rust CodeForge & FRB 2.13.0), desktop native window/tray control (`packages/platform`), and official FlClash website canvas capsule flow field animation (`packages/web`).
- **Universal Agent Enablement**: Built-in [`SKILL.md`](SKILL.md) following Open Agent Skill standards, empowering AI programming assistants to quickly discover, comprehend, and reuse the entire UI kit.

---

## AI Agent Integration & Prompts

Two standalone options are available depending on your workflow:

### Option 1: One-Shot UI/UX Strict Constraint Prompt (Zero Install)

> [!NOTE]
> **Best For**: One-off tasks, single-turn prompts, or environments where you do not want to alter configs or install skills. Copy and send directly to your AI Agent:

```text
For this task only, use FlClash-UI-Kit (https://github.com/younai666/FlClash-UI-Kit) as the sole UI/UX and motion implementation standard. Do not install any Skill, and do not modify environment configs or persistent memory:

1. Single Standard: Inspect the repository (prefer an existing local checkout; otherwise clone or fetch remotely). Visual styling, layouts, adaptive shells, palettes, and spring motion physics must strictly follow the real source in `packages/flutter` (including `vendor/prism_ui`).
2. Real Component Reuse: Do not import unrelated UI libraries or invent phantom widget APIs. Prioritize directly reusing extracted production components (e.g., KitApp, HomePage, Dashboard cards, ThemeView, showSnapSheet, superellipse shapes).
3. Tech Stack Rules: In Flutter, depend directly on `packages/flutter`. For other stacks (React, Vue, SwiftUI, Compose, etc.), inspect the actual Dart/Shader sources and token contracts to port geometry and motion, explicitly documenting fidelity boundaries.
4. Safety & Licensing: Derivative code complies with GNU GPL-3.0, JetBrains Mono font under OFL-1.1, and service icons under CC0 1.0 (no trademark rights granted); do not import quarantined assets (emoji fonts, avatars, brand logos).
```

### Option 2: Project-Level Persistent Skill Installation Prompt (Long-Term Reuse)

> [!TIP]
> **Best For**: Long-term project development and repeated UI tasks. Copy and send to your AI Agent for automatic project-level mounting:

```text
Please install FlClash-UI-Kit (https://github.com/younai666/FlClash-UI-Kit) as a persistent project-level UI/UX Skill for the current project:

1. Agent Detection: Identify your current Agent runtime (e.g. Google Antigravity, Codex CLI, Claude Code, Cursor) and its native project-level Skill discovery mechanism (e.g. project skills folder, configuration, or instruction index). Do not modify global user configs.
2. Full Acquisition: Prefer reusing an existing local checkout; if cloning remotely, clone with submodules (`git clone --recurse-submodules https://github.com/younai666/FlClash-UI-Kit.git`), using HTTPS for all submodules.
3. Project-Level Mounting: Mount at project scope using directory symlinks, project skill directories, or recording the resource root in agent instructions. Do NOT copy `SKILL.md` in isolation; the entire root containing `packages/` (with vendors, fonts, shaders), `showcase/`, `docs/`, `NOTICE.md`, and `LICENSE` must remain accessible via relative paths.
4. Genuine Verification: Verify that your discovery mechanism detects `flclash-ui-kit`. Test reading component source code (e.g., locating `Palette` and `showSnapSheet` implementations). If your environment cannot detect or install it, explain why and provide manual steps; do not report false success.
5. Reuse Standard: Once installed, prioritize this Skill for subsequent UI/UX, responsive layout, and physics animation requests. Strictly adhere to GNU GPL-3.0 and third-party terms (OFL-1.1, CC0 1.0, quarantined unconfirmed assets).
```

---

## Quick Start

### 1. Clone Repository (Including Submodules)

```bash
git clone --recurse-submodules https://github.com/younai666/FlClash-UI-Kit.git
```

### 2. Add Dependency to Your Flutter App

In your `pubspec.yaml`, reference the path to the core package:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flclash_ui_kit:
    path: /path/to/FlClash-UI-Kit/packages/flutter
```

---

## Key Components & Code Examples

### 1. Base Application Environment (KitApp)

`KitApp` sets up dual-mode light/dark themes, adaptive text scaling (`MeasureScope`), viewport size breakpoints (`ViewScope`), liquid glass renderers, and bilingual localization delegates:

```dart
import 'package:flutter/widgets.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  runApp(const KitApp(
    locale: Locale('en'),
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

### 2. Adaptive App Shell & Navigation (HomePage)

`HomePage` provides desktop sidebar expansion/floating toggle, mobile bottom navigation (`NavigationDock`), long-distance page transition snapshot protection, and active page event dispatching:

```dart
Widget buildAppShell(BuildContext context) {
  final shellController = HomeShellController(
    initialLabel: 'dashboard',
  );

  final items = [
    NavigationItem(
      label: 'dashboard',
      glyph: AppGlyphs.dashboard,
      titleOf: (context) => 'Dashboard',
      builder: (context) => const DashboardView(),
    ),
    NavigationItem(
      label: 'tools',
      glyph: AppGlyphs.wrench,
      titleOf: (context) => 'Tools',
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

### 3. Dashboard & Performance Cards (Dashboard)

Supports standalone network state cards, bounded real-time traffic line graphs, memory monitoring, and status polling:

```dart
// Real-time outbound status card
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

// Real-time traffic history graph
final trafficHistory = FixedList<Traffic>(capacity: 60);
// Add sample on incoming speed ticks: trafficHistory.add(Traffic(up: 1024, down: 2048));
SpeedCard(
  traffic: trafficHistory,
  totalTraffic: '12.4 GB',
);
```

### 4. Theme Settings & Font Previews (ThemeView)

Comprehensive color scheme generation (dynamic palette, monochrome, ambiance, soft pastel styles), pure OLED black mode, floating navigation toggle, and smooth font list previews:

```dart
Widget buildThemeSettings(BuildContext context) {
  final themeController = ThemeController();

  return ThemeScope(
    controller: themeController,
    child: const ThemeView(),
  );
}
```

### 5. Legal Terms & Repeat-to-Agree Flow (DisclaimerView)

Ready-to-use compliance disclaimer view and interactive repeat-to-agree modal dialog with IME composition state protection:

```dart
// 1. Open as a full page
BaseNavigator.push(context, const DisclaimerView());

// 2. Open as an interactive consent modal
Future<void> requireConsent(BuildContext context) async {
  final agreed = await requestDisclaimerConsent(context);
  if (agreed) {
    print('User successfully typed agreement phrase and consented');
  }
}
```

### 6. Form Editor & Multi-Dimensional Records (Form & Records)

Provides nested draft forms with discard confirmation and undo capabilities, alongside multi-dimensional data grouping and keyword filtering:

```dart
// Open nested draft sheet
showNestedFormSheet<String>(
  context: context,
  currentValue: () => 'Current draft content',
  formBuilder: (context) => MyCustomFormEditor(),
);

// Multi-dimensional record classifier and filter
final filterController = RecordFilterController<ConnectionRecord>(
  facets: [RecordFacet(RecordFacetKind.network, (r) => [r.network])],
  groupers: [RecordGrouper(RecordGrouping.host, (r) => r.host)],
);
```

---

## Optional Native & Web Extensions

| Module Path | Description | Requirements & Platforms |
|---|---|---|
| [`packages/flutter`](packages/flutter) | **Core Component Package** (includes `vendor/prism_ui`, JetBrains Mono fonts, and shader assets) | Any Flutter 3.47.2+ platform (Pure Web-safe, no native bindings) |
| [`packages/editor`](packages/editor) | **Native Code Editor** (Original CodeForge, Rust document backend & FRB 2.13.0) | Native platforms only; requires Rust 1.99.0 & C++ build tools |
| [`packages/platform`](packages/platform) | **System Capability Bridges** (Window controls, system tray, dynamic desktop accent, DirectWrite font enumeration) | Desktop platforms (Windows / macOS / Linux) |
| [`packages/web`](packages/web) | **Native JavaScript Animation** (FlClash official website canvas capsule flow field) | Modern browser native JS environments; runs independently without Flutter |

For detailed native build and initialization instructions, see [Native and Platform Integration](docs/usage/native.md).

---

## Showcase Interactive Gallery & Running

The [`showcase`](showcase) directory is a full verification and interactive gallery application integrating all decoupled views alongside 17 category-specific component demonstrations:

```bash
cd showcase
flutter pub get

# Run on Desktop (Windows)
flutter run -d windows

# Run on Web
flutter run -d chrome
```

Within the interactive showcase:
- The Home page showcases the adaptive app shell and dashboard widgets.
- Navigate to **"Tools → Disclaimer"** to browse terms or tap **"Apply"** to experience the repeat-to-agree modal.
- Navigate to **"Tools → Component Catalog"** to interactively test all buttons, form sheets, visual effects, charts, color palettes, and 230+ vector glyphs across 17 categories.

---

## Known Limitations & Decoupling Boundaries

To ensure the component library remains versatile, lightweight, and non-intrusive, domain-specific proxy capabilities remain reference implementations and are not forced into the general UI kit:

1. **Clash Core & Configuration Generators**: `views/config/*` (YAML/JS parser, rule-routing engine bindings) are domain-specific proxy logic.
2. **Low-Level Network Services & Privileges**: VPN network driver routing, Android accessibility service (`access.dart`), WebDAV cloud backup, and root certificate injection (`mitm`) must be provided by the host application.
3. **Platform Build & Rendering Verification Scope**:
   - Windows x64 Release and Web Release have passed pixel-level interactive verification.
   - Android Release APK (62.4 MB) builds cleanly; tests pass under Skia rendering in emulator environments, whereas default Impeller on the test host encountered host-driver GLES shader link errors.
   - macOS / Linux / iOS have not undergone native build verification in this Windows host environment; the optional CodeForge editor currently lacks an iOS Rust target.

For detailed file-by-file categorization, see the [Extraction Matrix](docs/audit/extraction-matrix.md) and [Review Findings](docs/audit/review-findings.md).

---

## Project Architecture & Tech Stack

```text
FlClash-UI-Kit/
├── packages/
│   ├── flutter/          # Core cross-platform UI package (includes vendor/prism_ui, shaders & fonts)
│   ├── editor/           # Optional Rust CodeForge native code editor
│   ├── platform/         # Optional native window, tray, and DirectWrite font enumeration
│   └── web/              # Native JavaScript Canvas flow field animation
├── showcase/             # Interactive gallery and verification demo app
├── examples/
│   └── standalone/       # Zero-business-dependency standalone consumer reference
├── docs/                 # Architecture designs, complete file index, component catalog, guides
│   ├── audit/            # Traceability ledgers, space audits, and test evidence
│   └── components/       # Component catalog and standalone invocation contracts
├── source/upstream/      # Frozen upstream Git submodules (FlClash & prism_ui)
├── tools/                # Automated extraction, contract checkers, slimming & consumer tests
├── LICENSE               # GNU GPL-3.0 License
├── NOTICE.md             # Upstream copyright attribution & third-party licenses
└── SKILL.md              # Open AI Agent Skill definition
```

---

## Open-Source Compliance & Licensing

- Derivative code in this project is licensed under the **[GNU General Public License v3.0 (GPL-3.0)](LICENSE)**.
- Original copyrights belong to **chen08209** and upstream contributors.
- Embedded third-party assets maintain their respective licenses:
  - **JetBrains Mono** font: SIL Open Font License 1.1 ([OFL-1.1](docs/audit/font-evidence.json)).
  - **Service Vector Glyphs**: Simple Icons 13.0.0 ([CC0 1.0](docs/audit/license-inventory.md)) and FlClash custom vectors.
  - **Third-party Dart / Rust Libraries**: Complete Apache-2.0, MIT, and BSD-3-Clause notices are preserved in [`NOTICE.md`](NOTICE.md) and [`licenses/`](licenses).
- Third-party emoji fonts, avatar images, and application branding assets without explicit redistributable authorization have been **strictly isolated** and are not bundled into runtime libraries.

---

*Build beautiful Flutter applications with FlClash-UI-Kit!*
