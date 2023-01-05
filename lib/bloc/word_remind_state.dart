part of 'word_remind_bloc.dart';

class WordRemindState {
  final List<List<dynamic>> wordList;
  final bool readFilePermission;
  final bool isWordRemind;
  final int? wordRemindIndex;
  final MinuteTimerPeriod minuteTimerPeriod;

  WordRemindState.initial()
      : wordList = [],
        readFilePermission = true,
        isWordRemind = false,
        wordRemindIndex = null,
        minuteTimerPeriod = MinuteTimerPeriod.oneMinute;

  WordRemindState(this.wordList, this.readFilePermission, this.isWordRemind,
      this.wordRemindIndex, this.minuteTimerPeriod);

  bool get isWordReminding => isWordRemind && wordRemindIndex != null;

  WordRemindState copyWith(
          {List<List<dynamic>>? wordList,
          bool? readFilePermission,
          bool? isWordRemind,
          int? wordRemindIndex,
          MinuteTimerPeriod? minuteTimerPeriod}) =>
      WordRemindState(
        wordList ?? this.wordList,
        readFilePermission ?? this.readFilePermission,
        isWordRemind ?? this.isWordRemind,
        wordRemindIndex ?? this.wordRemindIndex,
        minuteTimerPeriod ?? this.minuteTimerPeriod,
      );

  WordRemindState turnOffWordRemind() => WordRemindState(
        wordList,
        readFilePermission,
        false,
        null,
        minuteTimerPeriod,
      );

  WordRemindState clearWordList() => turnOffWordRemind().copyWith(wordList: []);
}
