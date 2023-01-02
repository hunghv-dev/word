import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:word/home_page.dart';
import 'package:word/second_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      selectNotificationStream.add(notificationResponse.payload);
    },
  );
  runApp(
    MaterialApp(
      initialRoute: HomePage.routeName,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (_) => HomePage(notificationAppLaunchDetails),
        SecondPage.routeName: (_) => const SecondPage()
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}
