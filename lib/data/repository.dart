import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/define.dart';
import '../utils/flutter_background_helper.dart';
import '../utils/local_push_notification_helper.dart';

abstract class Repository {
  Future<List<List>> loadingCsvData();

  Future<List<List>?> pickCSVFile();

  Future<void> clearTemporaryFiles();

  Future<void> showNotification(List<dynamic> word);

  Future<void> cancelNotifications();

  Future<bool> checkBackgroundPermission();

  Future<bool> enableBackgroundExecution();

  Future<bool> disableBackgroundExecution();
}

@LazySingleton(as: Repository)
class RepositoryImpl extends Repository {
  final SharedPreferences _preferences;
  final LocalPushNotificationHelper _localPushNotificationHelper;
  final FlutterBackgroundHelper _flutterBackgroundHelper;

  RepositoryImpl(
    this._preferences,
    this._localPushNotificationHelper,
    this._flutterBackgroundHelper,
  );

  Future<List<List>> _openCsvFile(String path) async {
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

  @override
  Future<List<List>> loadingCsvData() async {
    final path = _preferences.getString(Define.tagSpfCsvFilePath);
    if (path == null) {
      return [];
    }
    return await _openCsvFile(path);
  }

  @override
  Future<List<List>?> pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      final path = result?.files.first.path;
      if (path == null) return [];
      await _preferences.setString(Define.tagSpfCsvFilePath, path);
      return await _openCsvFile(path);
    } on PlatformException {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        return null;
      }
    }
    return [];
  }

  @override
  Future<void> clearTemporaryFiles() async => await Future.wait([
        FilePicker.platform.clearTemporaryFiles(),
        _preferences.remove(Define.tagSpfCsvFilePath),
      ]);

  @override
  Future<void> showNotification(List word) async =>
      await _localPushNotificationHelper.showNotification(word);

  @override
  Future<void> cancelNotifications() async =>
      await _localPushNotificationHelper.cancelAllNotification();

  @override
  Future<bool> checkBackgroundPermission() async =>
      await _flutterBackgroundHelper.initialize();

  @override
  Future<bool> disableBackgroundExecution() async =>
      await _flutterBackgroundHelper.disableBackgroundExecution();

  @override
  Future<bool> enableBackgroundExecution() async =>
      await _flutterBackgroundHelper.enableBackgroundExecution();
}
