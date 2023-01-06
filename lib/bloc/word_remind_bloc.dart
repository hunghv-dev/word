import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word/app.dart';
import 'package:word/enum.dart';
import 'package:word/utils/string_utils.dart';

part 'word_remind_event.dart';

part 'word_remind_state.dart';

class WordRemindBloc extends Bloc<WordRemindEvent, WordRemindState> {
  WordRemindBloc() : super(WordRemindState.initial()) {
    on<LoadCSVFileEvent>(_onLoadCSVFileEvent);
    on<PickCSVFileEvent>(_onPickCSVFileEvent);
    on<ClearCSVFileEvent>(_onClearCSVFileEvent);
    on<TurnWordRemindEvent>(_onTurnWordRemindEvent);
    on<UpdateWordRemindEvent>(_onUpdateWordRemindEvent);
    on<ChangeTimerPeriodEvent>(_onChangeTimerPeriodEvent);
  }

  int _id = 0;
  Timer? _timer;

  List<dynamic> get _randomWord {
    final randomIndex = Random().nextInt(state.wordList.length);
    return state.wordList[randomIndex];
  }

  void _onLoadCSVFileEvent(event, emit) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final path = sharedPreferences.getString(StringUtils.tagSpfCsvFilePath);
    if (path == null) return;
    List<List<dynamic>> listData = await _loadingCsvData(path);
    emit(state.copyWith(wordList: listData));
  }

  void _onPickCSVFileEvent(event, emit) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      final path = result?.files.first.path;
      if (path == null) return;
      await _savePathToSharedPreferences(path);
      List<List<dynamic>> listData = await _loadingCsvData(path);
      emit(state.copyWith(wordList: listData));
    } on PlatformException {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        emit(state.copyWith(readFilePermission: false));
      }
    }
  }

  void _onClearCSVFileEvent(event, emit) async {
    _timer?.cancel();
    await FilePicker.platform.clearTemporaryFiles();
    await _clearPathToSharedPreferences();
    await _cancelNotifications();
    emit(state.clearWordList());
  }

  void _onTurnWordRemindEvent(event, emit) async {
    _timer?.cancel();
    if (!state.isWordRemind) {
      emit(state.copyWith(isWordRemind: true));
      _timer = Timer.periodic(Duration(minutes: state.minuteTimerPeriod.minute),
          (_) {
        add(UpdateWordRemindEvent());
      });
    } else {
      emit(state.turnOffWordRemind());
      await _cancelNotifications();
    }
  }

  void _onUpdateWordRemindEvent(event, emit) async {
    final randomWord = _randomWord;
    await Future.wait([
      _cancelNotifications(),
      _showNotification(randomWord),
    ]).whenComplete(() => emit(
        state.copyWith(wordRemindIndex: state.wordList.indexOf(randomWord))));
  }

  void _onChangeTimerPeriodEvent(event, emit) async {
    emit(state.copyWith(minuteTimerPeriod: state.minuteTimerPeriod.increase));
  }

  Future _savePathToSharedPreferences(String path) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(StringUtils.tagSpfCsvFilePath, path);
  }

  Future _clearPathToSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(StringUtils.tagSpfCsvFilePath);
  }

  Future<List<List<dynamic>>> _loadingCsvData(String path) async {
    final file = File(path);
    final isFileExists = await file.exists();
    if (!isFileExists) {
      return [];
    }
    final csvFile = file.openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          const CsvToListConverter(),
        )
        .toList();
  }

  Future<void> _showNotification(List<dynamic> word) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      StringUtils.channelIdNotification,
      StringUtils.channelNameNotification,
      channelDescription: StringUtils.channelDescriptionNotification,
      importance: Importance.max,
      priority: Priority.max,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      _id++,
      word[0],
      word[1],
      notificationDetails,
    );
  }

  Future<void> _cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void dispose() {
    _timer?.cancel();
    _cancelNotifications();
  }
}
