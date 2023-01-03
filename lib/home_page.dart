import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isTurnOnNotification = false;
  List<List<dynamic>> _data = [];

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  @override
  void initState() {
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    _loadPathFromSharedPreferences();
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

  void _loadCsv() async {
    final path = await _loadCsvFromStorage();
    if (path == null) return;
    await _savePathToSharedPreferences(path);
    List<List<dynamic>> listData = await _loadingCsvData(path);
    setState(() {
      _data = listData;
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
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isTurnOnNotification ? 'Notification On' : 'Notification Off',
              ),
              Switch(
                value: isTurnOnNotification,
                onChanged: (isTurnOn) async {
                  if (isTurnOn) {
                    // await _showNotification();
                  }
                  setState(() => isTurnOnNotification = isTurnOn);
                },
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 17,
            color: isTurnOnNotification ? Colors.blue : Colors.grey,
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _data[index][0],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              _data[index][1],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: CircleAvatar(
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _loadCsv,
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

  Future<List<List<dynamic>>> _loadingCsvData(String path) async {
    final csvFile = File(path).openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          const CsvToListConverter(),
        )
        .toList();
  }

  Future<String?> _loadCsvFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );
    return result?.files.first.path;
  }

  Future _loadPathFromSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final path = sharedPreferences.getString('path');
    if (path == null) return;
    List<List<dynamic>> listData = await _loadingCsvData(path);
    setState(() {
      _data = listData;
    });
  }

  Future _savePathToSharedPreferences(String path) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('path', path);
  }
}
