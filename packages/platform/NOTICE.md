This optional integration package derives from chen08209/FlClash commit be84736605527034689c95bf27828ff27d912c5e: https://github.com/chen08209/FlClash.

The standalone window, tray and dynamic_color plugins are copied unchanged under vendor, with their original LICENSE files and source headers: MIT for window/tray, Apache-2.0 for dynamic_color. Window code retains original contributor copyrights. WindowCaptionController is an excerpt from lib/manager/window_manager.dart with independent imports; its GPL-3.0 notice and this package's GPL LICENSE are retained. Pure caption rendering lives in the sibling base kit.

Host applications own initialization, window/close policies, menu actions, tray artwork and system capability choices. No app/tray logo is redistributed here.
