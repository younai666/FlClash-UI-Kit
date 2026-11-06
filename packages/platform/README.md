# FlClash native integrations

Use this complete package and the sibling `../flutter`. It exports the original window, tray and dynamic_color plugin APIs plus WindowCaptionController. Window/tray cover Windows/macOS/Linux; dynamic color also supports Android. The Flutter base kit can be used without this package.

Call `desktopWindow.ensureInitialized()` before desktop operations. Build WindowHeaderBar/WindowHeaderActions from the base kit and connect their callbacks to the native methods and caption controller. Dispose the controller; maximized/fullscreen state follows native events. Tray APIs accept host-owned TraySpec, menu and authorized artwork. DynamicColorPlugin queries can return null on unsupported systems.

The repository's showcase/lib/platform.dart contains actual calls and distinguishes callback presentation from native queries. Linux tray compilation needs ayatana-appindicator3-0.1 or appindicator3-0.1. Material support varies by OS; query isEffectSupported before selecting a WindowEffect.

Retain LICENSE, NOTICE.md and each vendor license. Platform source support is separate from verified runtime support; see the repository verification record for tested hosts.
