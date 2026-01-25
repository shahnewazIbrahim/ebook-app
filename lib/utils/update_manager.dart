import 'package:flutter/widgets.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateManager {
  static Future<void> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        await _performUpdate();
      }
    } catch (e) {
      debugPrint('In-app update skipped: $e');
    }
  }

  static Future<void> _performUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      debugPrint('Update failed: $e');
    }
  }
}
