import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:word/notification.dart';
import 'package:word/received_notification.dart';
import 'package:word/second_page.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int id = 0;
  List<List<dynamic>> _data = [];

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  @override
  void initState() {
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((_) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => const SecondPage(),
      ));
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (_, index) {
                    return Card(
                      color: index == 0 ? Colors.blue : Colors.white,
                      elevation: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                _data[index][0].toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                _data[index][1],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                _data[index][2],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                child: const Text('Load csv file'),
                onPressed: () async {
                  final path = await loadCsvFromStorage();
                  if(path != null){
                    List<List<dynamic>> listData = await loadingCsvData(path);
                    setState(() {
                      _data = listData;
                    });
                  }
                },
              ),
              // TextButton(
              //   child: const Text('Show notification'),
              //   onPressed: () async {
              //     await _showNotification();
              //   },
              // ),
            ],
          ),
        ),
      );

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      id++,
      'plain title',
      'plain body',
      notificationDetails,
    );
  }

  Future<List<List<dynamic>>> loadingCsvData(String path) async {
    final csvFile = File(path).openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          const CsvToListConverter(),
        )
        .toList();
  }

  Future<String?> loadCsvFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );
    return result?.files.first.path;
  }
}
