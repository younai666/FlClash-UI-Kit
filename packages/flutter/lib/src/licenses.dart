import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool _registered = false;

/// Register retained font, artwork, shader and embedded source notices.
/// KitApp calls this once. Custom PrismApp hosts can call it themselves.
void registerKitLicenses() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['flclash_ui_kit (retained third-party notices)'],
      await rootBundle.loadString('packages/flclash_ui_kit/assets/licenses/third-party.txt'));
  });
}
