part of 'word_remind_bloc.dart';

class WordRemindState {
  final List<List<dynamic>> wordList;
  final bool readFilePermission;
  final bool isWordRemind;
  final int? wordRemindIndex;
  final MinuteTimerPeriod minuteTimerPeriod;
  final int startTime;
  final int endTime;
  final bool isLoading;

  WordRemindState.initial()
      : wordList = [],
        readFilePermission = true,
        isWordRemind = false,
        wordRemindIndex = null,
        minuteTimerPeriod = MinuteTimerPeriod.oneMinute,
        startTime = 0,
        endTime = 24,
        isLoading = true;

  WordRemindState(
    this.wordList,
    this.readFilePermission,
    this.isWordRemind,
    this.wordRemindIndex,
    this.minuteTimerPeriod,
    this.startTime,
    this.endTime,
    this.isLoading,
  );

  bool get isWordReminding => isWordRemind && wordRemindIndex != null;

  bool isFocusWord(int index) => isWordReminding && wordRemindIndex == index;

  String get startTimeLabel => '${startTime}h';

  String get endTimeLabel => '${endTime}h';

  WordRemindState copyWith(
          {List<List<dynamic>>? wordList,
          bool? readFilePermission,
          bool? isWordRemind,
          int? wordRemindIndex,
          MinuteTimerPeriod? minuteTimerPeriod,
          int? startTime,
          int? endTime,
          bool? isLoading}) =>
      WordRemindState(
        wordList ?? this.wordList,
        readFilePermission ?? this.readFilePermission,
        isWordRemind ?? this.isWordRemind,
        wordRemindIndex ?? this.wordRemindIndex,
        minuteTimerPeriod ?? this.minuteTimerPeriod,
        startTime ?? this.startTime,
        endTime ?? this.endTime,
        isLoading ?? this.isLoading,
      );

  WordRemindState turnOffWordRemind() => WordRemindState(
        wordList,
        readFilePermission,
        false,
        null,
        minuteTimerPeriod,
        startTime,
        endTime,
        false,
      );

  WordRemindState clearWordList() => turnOffWordRemind().copyWith(wordList: []);
}
