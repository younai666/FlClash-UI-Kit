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
- [AI Agent Skill Installation](#ai-agent-skill-installation)
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

## AI Agent Skill Installation

Install this repository as a skill in your AI Agent (e.g. Google Antigravity, Codex CLI, Claude Code, Cursor) so your AI assistant can directly invoke and reuse original components, eliminating reinvented wheels.

> [!TIP]
> **Prompt to install this repository into your AI Agent:**
> ```text
> Please install the provided FlClash-UI-Kit repository as an available UI/UX Skill for the current project.
> 
> 1. Identify which Agent you are running as, inspect current project conventions, and check your actual Skill discovery/installation mechanism; do not assume all Agents use the same directory.
> 2. Fetch the entire contents of the repository, reading the root README.md and SKILL.md. Prefer reusing an existing local checkout. When cloning, preserve submodules; if upstream submodules use SSH URLs, rewrite them to HTTPS for this command without altering global Git config.
> 3. Perform a project-level installation according to your supported mechanism. You may use supported directories, directory symlinks, or record the resource root in agent instructions; do not merely copy SKILL.md, and do not modify global configuration or overwrite existing skills.
> 4. Ensure that relative to the resource root, the entire packages directory (including respective vendor, fonts, shaders, and license assets), showcase, docs, source/upstream, licenses, LICENSE, and NOTICE.md are accessible. Record the actual resource root path in installation notes.
> 5. Verify that flclash-ui-kit is recognized via your discovery mechanism; inspect the component directory pointed to by the Skill, locating actual source code and usage examples for Palette and showSnapSheet. If a Flutter environment is available, verify with a temporary project referencing packages/flutter by running flutter pub get and flutter analyze. Do not consider reading only the frontmatter as successful Skill execution.
> 6. Report the installation path, usage instructions, and completed verification checks. If the current Agent cannot automatically install or confirm discovery, state so clearly and provide the simplest project-level manual steps; do not claim success prematurely. Do not install complex adapters, alter global configs, or publish the project without explicit instructions.
> 
> Whenever I request FlClash visuals or interactions in the future, first retrieve and reuse real implementations per this Skill. Call directly in Flutter; for other tech stacks, inspect source code before porting and clarify fidelity boundaries.
> ```

---

## Quick Start

### 1. Clone Repository (Including Submodules)

```bash
git clone --recurse-submodules https://github.com/YOUR_REPO/FlClash-UI-Kit.git
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
