import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'define.dart';

@lazySingleton
class LocalPushNotificationHelper {
  static const _androidDefaultIcon = 'app_icon';
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  LocalPushNotificationHelper(this._flutterLocalNotificationsPlugin);

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    /// Change icon at android\app\src\main\res\drawable\app_icon.png
    const androidInit = AndroidInitializationSettings(_androidDefaultIcon);

    /// don't request permission here
    /// we use firebase_messaging package to request permission instead
    const iOSInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const init = InitializationSettings(android: androidInit, iOS: iOSInit);

    /// init local notification
    await Future.wait([
      FlutterLocalNotificationsPlugin().initialize(init),
    ]);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          Define.channelId,
          Define.channelName,
          description: Define.channelName,
          importance: Importance.high,
        ));
  }

  Future<void> showNotification(List<dynamic> word) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Define.channelId,
      Define.channelName,
      channelDescription: Define.channelName,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      autoCancel: true,
      enableVibration: true,
      playSound: true,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin
        .show(
          Define.localNotificationsId,
          word[0],
          word[1],
          platformChannelSpecifics,
        )
        .onError((error, stackTrace) =>
            log('Can not show notification cause $error'));
  }

  Future<void> cancelAllNotification() =>
      _flutterLocalNotificationsPlugin.cancelAll();
}
