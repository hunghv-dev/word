import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:base_define/base_define.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word/resources/string_utils.dart';

import '../entities/minute_timer.dart';
import '../main.dart';
import '../utils/define.dart';

part 'word_remind_bloc.freezed.dart';
part 'word_remind_event.dart';
part 'word_remind_state.dart';

@injectable
class WordRemindBloc extends Bloc<WordRemindEvent, WordRemindState> {
  WordRemindBloc() : super(const WordRemindState()) {
    on<_LoadCSVFile>(_onLoadCSVFileEvent);
    on<_PickCSVFile>(_onPickCSVFileEvent);
    on<_ClearCSVFile>(_onClearCSVFileEvent);
    on<_TurnWordRemind>(_onTurnWordRemindEvent);
    on<_UpdateWordRemind>(_onUpdateWordRemindEvent);
    on<_ChangeTimerPeriod>(_onChangeTimerPeriodEvent);
    on<_ChangeStartTime>(_onChangeStartTimeEvent);
    on<_ChangeEndTime>(_onChangeEndTimeEvent);
  }

  Timer? _timer;

  void _onLoadCSVFileEvent(_, emit) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final path = sharedPreferences.getString(StringUtils.tagSpfCsvFilePath);
    if (path == null) {
      emit(state.copyWith(wordList: [], isLoading: false));
      return;
    }
    List<List<dynamic>> listData = await _loadingCsvData(path);
    emit(state.copyWith(wordList: listData, isLoading: false));
  }

  void _onPickCSVFileEvent(_, emit) async {
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

  void _onClearCSVFileEvent(_, emit) async {
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

  void _onTurnWordRemindEvent(_, emit) async {
    final hasPermission = await _checkBackgroundPermission(emit);
    if (!hasPermission) return;

    _timer?.cancel();
    if (state.isWordRemind) {
      final isDisable = await FlutterBackground.disableBackgroundExecution();
      if (!isDisable) return;
      emit(state.turnOff());
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
        add(const WordRemindEvent.updateWordRemind());
      },
    );
  }

  void _onUpdateWordRemindEvent(event, emit) async {
    final randomWord = state.wordList.randomItem;
    await Future.wait([
      _cancelNotifications(),
      _showNotification(randomWord),
    ]).whenComplete(() => emit(
        state.copyWith(wordRemindIndex: state.wordList.indexOf(randomWord))));
  }

  void _onChangeTimerPeriodEvent(_, emit) async {
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
      Define.localNotificationsId,
      word[0],
      word[1],
      notificationDetails,
    );
  }

  void _onChangeStartTimeEvent(_ChangeStartTime event, emit) async {
    final newStartTime = state.startTime + (event.isIncrease ? 1 : -1);
    if (newStartTime < 0 || newStartTime >= state.endTime) return;
    emit(state.copyWith(startTime: newStartTime));
  }

  void _onChangeEndTimeEvent(_ChangeEndTime event, emit) async {
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
