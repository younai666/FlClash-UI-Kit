/// Browsers cannot enumerate native system fonts through the FFI adapter.
Future<List<String>> loadNativeFontFamilies() async => const [];
