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
  WordRemindBloc(this.repository) : super(const WordRemindState()) {
    on<_LoadCSVFile>(_onLoadCSVFileEvent);
    on<_PickCSVFile>(_onPickCSVFileEvent);
    on<_ClearCSVFile>(_onClearCSVFileEvent);
    on<_TurnWordRemind>(_onTurnWordRemindEvent);
    on<_UpdateWordRemind>(_onUpdateWordRemindEvent);
    on<_ChangeTimerPeriod>(_onChangeTimerPeriodEvent);
    on<_ChangeStartTime>(_onChangeStartTimeEvent);
    on<_ChangeEndTime>(_onChangeEndTimeEvent);
  }

  final Repository repository;
  Timer? _timer;

  void _onLoadCSVFileEvent(_, emit) async {
    final listData = await repository.loadingCsvData();
    emit(state.copyWith(wordList: listData, isLoading: false));
  }

  void _onPickCSVFileEvent(_, emit) async {
    emit(state.copyWith(isLoading: true));
    final wordList = await repository.pickCSVFile();
    if (wordList == null) {
      state.sendMessage(emit, WordRemindMessage.requiredReadPermission());
    } else {
      emit(state.copyWith(wordList: wordList));
    }
    emit(state.copyWith(isLoading: false));
  }

  void _onClearCSVFileEvent(_, emit) async {
    _timer?.cancel();
    await Future.wait([
      repository.clearTemporaryFiles(),
      repository.cancelNotifications(),
    ]);
    emit(state.copyWith(isWordRemind: false, wordList: []));
  }

  Future<void> _onTurnWordRemindEvent(_, emit) async {
    final hasPermission = await repository.checkBackgroundPermission();
    if (!hasPermission) return;
    _timer?.cancel();
    if (state.isWordRemind) {
      final isDisable = await repository.disableBackgroundExecution();
      if (!isDisable) return;
      emit(state.copyWith(isWordRemind: false));
      return await repository.cancelNotifications();
    }
    final isEnable = await repository.enableBackgroundExecution();
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
      repository.cancelNotifications(),
      repository.showNotification(randomWord),
    ]).whenComplete(() {
      final wordRemindIndex = state.wordList.indexOf(randomWord);
      state.sendMessage(emit,
          WordRemindMessage.scrollTo(wordRemindIndex * Define.wordItemHeight));
      emit(state.copyWith(wordRemindIndex: wordRemindIndex));
    });
  }

  void _onChangeTimerPeriodEvent(_, emit) async {
    emit(state.copyWith(minuteTimerPeriod: state.minuteTimerPeriod.increase));
  }

  void _onChangeStartTimeEvent(_ChangeStartTime event, emit) async {
    final newStartTime = state.startTime + (event.isIncrease ? 1 : -1);
    emit(state.copyWith(
        startTime: newStartTime.clamp(Define.startDay, state.endTime)));
  }

  void _onChangeEndTimeEvent(_ChangeEndTime event, emit) async {
    final newEndTime = state.endTime + (event.isIncrease ? 1 : -1);
    emit(state.copyWith(
        endTime: newEndTime.clamp(state.startTime, Define.endDay)));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    repository.cancelNotifications();
    return super.close();
  }
}
