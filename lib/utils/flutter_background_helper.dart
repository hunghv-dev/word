import 'package:flutter_background/flutter_background.dart';
import 'package:injectable/injectable.dart';

import 'define.dart';

@LazySingleton()
class FlutterBackgroundHelper {
  Future<bool> initialize() async {
    return await FlutterBackground.initialize(
      androidConfig: const FlutterBackgroundAndroidConfig(
        notificationTitle: Define.appTitle,
        notificationText: Define.titleRunningApp,
        notificationImportance: AndroidNotificationImportance.Default,
        enableWifiLock: false,
      ),
    );
  }

  Future<bool> enableBackgroundExecution() async {
    return await FlutterBackground.enableBackgroundExecution();
  }

  Future<bool> disableBackgroundExecution() async {
    return await FlutterBackground.disableBackgroundExecution();
  }
}
