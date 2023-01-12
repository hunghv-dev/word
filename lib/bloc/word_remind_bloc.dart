import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word/enum.dart';
import 'package:word/utils/string_utils.dart';

import '../main.dart';

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
    on<ChangeStartTimeEvent>(_onChangeStartTimeEvent);
    on<ChangeEndTimeEvent>(_onChangeEndTimeEvent);
  }

  static const _id = 42;
  Timer? _timer;

  List<dynamic> get _randomWord {
    final randomIndex = Random().nextInt(state.wordList.length);
    return state.wordList[randomIndex];
  }

  void _onLoadCSVFileEvent(event, emit) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final path = sharedPreferences.getString(StringUtils.tagSpfCsvFilePath);
    if (path == null) {
      emit(state.copyWith(wordList: [], isLoading: false));
      return;
    }
    List<List<dynamic>> listData = await _loadingCsvData(path);
    emit(state.copyWith(wordList: listData, isLoading: false));
  }

  void _onPickCSVFileEvent(event, emit) async {
    emit(state.copyWith(isLoading: true));
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
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onClearCSVFileEvent(event, emit) async {
    _timer?.cancel();
    await FilePicker.platform.clearTemporaryFiles();
    await _clearPathToSharedPreferences();
    await _cancelNotifications();
    emit(state.clearWordList());
  }

  Future<bool> _checkBackgroundPermission(emit) async {
    final hasPermissions = await FlutterBackground.initialize(
      androidConfig: const FlutterBackgroundAndroidConfig(
        notificationTitle: StringUtils.appTitle,
        notificationText: StringUtils.titleRunningApp,
        notificationImportance: AndroidNotificationImportance.Default,
        enableWifiLock: false,
      ),
    );
    return hasPermissions;
  }

  void _onTurnWordRemindEvent(event, emit) async {
    final hasPermission = await _checkBackgroundPermission(emit);
    if (!hasPermission) return;

    _timer?.cancel();
    if (state.isWordRemind) {
      final isDisable = await FlutterBackground.disableBackgroundExecution();
      if (!isDisable) return;
      emit(state.turnOffWordRemind());
      await _cancelNotifications();
      return;
    }
    final isEnable = await FlutterBackground.enableBackgroundExecution();
    if (!isEnable) return;
    emit(state.copyWith(isWordRemind: true));
    _timer = Timer.periodic(
      Duration(minutes: state.minuteTimerPeriod.minute),
      (_) {
        final nowHour = DateTime.now().hour;
        if (nowHour < state.startTime || nowHour >= state.endTime) return;
        add(UpdateWordRemindEvent());
      },
    );
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
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      _id,
      word[0],
      word[1],
      notificationDetails,
    );
  }

  void _onChangeStartTimeEvent(ChangeStartTimeEvent event, emit) async {
    final newStartTime = state.startTime + (event.isIncrease ? 1 : -1);
    if (newStartTime < 0 || newStartTime >= state.endTime) return;
    emit(state.copyWith(startTime: newStartTime));
  }

  void _onChangeEndTimeEvent(ChangeEndTimeEvent event, emit) async {
    final newEndTime = state.endTime + (event.isIncrease ? 1 : -1);
    if (newEndTime <= state.startTime || newEndTime > 24) return;
    emit(state.copyWith(endTime: newEndTime));
  }

  Future<void> _cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void dispose() {
    _timer?.cancel();
    _cancelNotifications();
  }
}
