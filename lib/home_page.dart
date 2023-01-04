import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:word/bloc/word_remind_bloc.dart';
import 'package:word/received_notification.dart';
import 'package:word/second_page.dart';

import 'app.dart';

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
  late WordRemindBloc _bloc;

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<WordRemindBloc>()..add(LoadCSVFileEvent());
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
  Widget build(BuildContext context) =>
      BlocListener<WordRemindBloc, WordRemindState>(
        listener: (context, state) {
          if (!state.readFilePermission) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Please allow Files and media permission for pick files')));
          }
        },
        child: Scaffold(
          body: BlocBuilder<WordRemindBloc, WordRemindState>(
            builder: (context, state) {
              final wordList = state.wordList;
              if (wordList.isEmpty) {
                return Center(
                  child: FloatingActionButton.large(
                    onPressed: () => _bloc.add(PickCSVFileEvent()),
                    backgroundColor: Colors.grey.shade400,
                    child: const Icon(
                      Icons.add,
                      size: 50,
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  ListView.builder(
                    itemCount: wordList.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: wordList[index]
                              .map(
                                (word) => Expanded(
                                  child: Text(
                                    word.toString(),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: BlocBuilder<WordRemindBloc, WordRemindState>(
                      builder: (context, state) {
                        return FloatingActionButton(
                          onPressed: () => _bloc.add(TurnWordRemindEvent()),
                          backgroundColor: state.isWordRemind
                              ? Colors.green
                              : Colors.grey.shade400,
                          child: const Icon(Icons.add_alert_outlined, size: 30),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: BlocBuilder<WordRemindBloc, WordRemindState>(
            builder: (context, state) {
              if (state.wordList.isEmpty) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.small(
                  onPressed: () => _bloc.add(ClearCSVFileEvent()),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete_forever));
            },
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
}
