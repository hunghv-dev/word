import 'dart:async';

import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../data/repository.dart';
import '../entities/minute_timer.dart';
import '../utils/define.dart';
import 'word_remind_message.dart';

part 'word_remind_bloc.freezed.dart';

part 'word_remind_event.dart';

part 'word_remind_state.dart';

@injectable
class WordRemindBloc extends Bloc<WordRemindEvent, WordRemindState> {
  WordRemindBloc(this._repository) : super(const WordRemindState()) {
    on<_LoadCSVFile>(_onLoadCSVFile);
    on<_PickCSVFile>(_onPickCSVFile);
    on<_ClearCSVFile>(_onClearCSVFile);
    on<_ToggleTimer>(_onToggleTimer);
    on<_UpdateWordRemind>(_onUpdateWordRemind);
    on<_ChangeTimerPeriod>(_onChangeTimerPeriod);
    on<_ChangeStartTime>(_onChangeStartTime);
    on<_ChangeEndTime>(_onChangeEndTime);
  }

  final Repository _repository;
  Timer? _timer;

  void _onLoadCSVFile(_, emit) async {
    final listData = await _repository.loadingCsvData();
    emit(state.copyWith(wordList: listData, isLoading: false));
  }

  void _onPickCSVFile(_, emit) async {
    emit(state.copyWith(isLoading: true));
    final wordList = await _repository.pickCSVFile();
    if (wordList == null) {
      state.sendMessage(emit, WordRemindMessage.requiredReadPermission());
    } else {
      emit(state.copyWith(wordList: wordList));
    }
    emit(state.copyWith(isLoading: false));
  }

  void _onClearCSVFile(_, emit) async {
    _timer?.cancel();
    await Future.wait([
      _repository.clearTemporaryFiles(),
      _repository.cancelNotifications(),
    ]);
    emit(state.copyWith(isWordRemind: false, wordList: []));
  }

  Future<void> _turnOnTimer(emit) async {
    final isEnable = await _repository.enableBackgroundExecution();
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

  Future<void> _turnOffTimer(emit) async {
    final isDisable = await _repository.disableBackgroundExecution();
    if (!isDisable) return;
    emit(state.copyWith(isWordRemind: false));
    await _repository.cancelNotifications();
  }

  Future<void> _onToggleTimer(_, emit) async {
    final hasPermission = await _repository.checkBackgroundPermission();
    if (!hasPermission) return;
    _timer?.cancel();
    if (state.isWordRemind) {
      await _turnOffTimer(emit);
    } else {
      await _turnOnTimer(emit);
    }
  }

  void _onUpdateWordRemind(event, emit) async {
    final randomWord = state.wordList.randomItem;
    await Future.wait([
      _repository.cancelNotifications(),
      _repository.showNotification(randomWord),
    ]).whenComplete(() {
      final wordRemindIndex = state.wordList.indexOf(randomWord);
      state.sendMessage(emit,
          WordRemindMessage.scrollTo(wordRemindIndex * Define.wordItemHeight));
      emit(state.copyWith(wordRemindIndex: wordRemindIndex));
    });
  }

  void _onChangeTimerPeriod(_, emit) {
    emit(state.copyWith(minuteTimerPeriod: state.minuteTimerPeriod.increase));
  }

  void _onChangeStartTime(_ChangeStartTime event, emit) {
    final newStartTime = state.startTime + (event.isIncrease ? 1 : -1);
    emit(state.copyWith(
        startTime: newStartTime.clamp(Define.startDay, state.endTime)));
  }

  void _onChangeEndTime(_ChangeEndTime event, emit) {
    final newEndTime = state.endTime + (event.isIncrease ? 1 : -1);
    emit(state.copyWith(
        endTime: newEndTime.clamp(state.startTime, Define.endDay)));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _repository.cancelNotifications();
    return super.close();
  }
}
