import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Android permissions the native alarm needs before it can be armed
abstract class AlarmPermissions {
  /// Asks for notifications and exact alarms when they are not granted yet
  ///
  /// Does nothing outside Android
  static Future<void> request() async {
    if (!Platform.isAndroid) {
      return;
    }

    await Permission.notification.request();
    final exact = await Permission.scheduleExactAlarm.status;
    if (!exact.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}
