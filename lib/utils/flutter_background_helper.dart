import 'package:flutter_background/flutter_background.dart';
import 'package:injectable/injectable.dart';

import 'define.dart';

@LazySingleton()
class FlutterBackgroundHelper {
  Future<bool> initialize() => FlutterBackground.initialize(
        androidConfig: const FlutterBackgroundAndroidConfig(
          notificationTitle: Define.appTitle,
          notificationText: Define.titleRunningApp,
          notificationImportance: AndroidNotificationImportance.Default,
          enableWifiLock: false,
        ),
      );

  Future<bool> enableBackgroundExecution() =>
      FlutterBackground.enableBackgroundExecution();

  Future<bool> disableBackgroundExecution() =>
      FlutterBackground.disableBackgroundExecution();
}
