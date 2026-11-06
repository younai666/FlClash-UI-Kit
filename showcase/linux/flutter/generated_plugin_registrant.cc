//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dynamic_color/dynamic_color_plugin.h>
#include <screen_retriever_linux/screen_retriever_linux_plugin.h>
#include <tray/tray_plugin.h>
#include <window/window_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) dynamic_color_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DynamicColorPlugin");
  dynamic_color_plugin_register_with_registrar(dynamic_color_registrar);
  g_autoptr(FlPluginRegistrar) screen_retriever_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenRetrieverLinuxPlugin");
  screen_retriever_linux_plugin_register_with_registrar(screen_retriever_linux_registrar);
  g_autoptr(FlPluginRegistrar) tray_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TrayPlugin");
  tray_plugin_register_with_registrar(tray_registrar);
  g_autoptr(FlPluginRegistrar) window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowPlugin");
  window_plugin_register_with_registrar(window_registrar);
}
