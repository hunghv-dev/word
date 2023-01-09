part of 'word_remind_bloc.dart';

class WordRemindState {
  final List<List<dynamic>> wordList;
  final bool readFilePermission;
  final bool isWordRemind;
  final int? wordRemindIndex;
  final MinuteTimerPeriod minuteTimerPeriod;
  final bool isLoading;

  WordRemindState.initial()
      : wordList = [],
        readFilePermission = true,
        isWordRemind = false,
        wordRemindIndex = null,
        minuteTimerPeriod = MinuteTimerPeriod.oneMinute,
        isLoading = true;

  WordRemindState(this.wordList, this.readFilePermission, this.isWordRemind,
      this.wordRemindIndex, this.minuteTimerPeriod, this.isLoading);

  bool get isWordReminding => isWordRemind && wordRemindIndex != null;

  bool isFocusWord(int index) => isWordReminding && wordRemindIndex == index;

  WordRemindState copyWith(
          {List<List<dynamic>>? wordList,
          bool? readFilePermission,
          bool? isWordRemind,
          int? wordRemindIndex,
          MinuteTimerPeriod? minuteTimerPeriod,
          bool? isLoading}) =>
      WordRemindState(
        wordList ?? this.wordList,
        readFilePermission ?? this.readFilePermission,
        isWordRemind ?? this.isWordRemind,
        wordRemindIndex ?? this.wordRemindIndex,
        minuteTimerPeriod ?? this.minuteTimerPeriod,
        isLoading ?? this.isLoading,
      );

  WordRemindState turnOffWordRemind() => WordRemindState(
        wordList,
        readFilePermission,
        false,
        null,
        minuteTimerPeriod,
        false,
      );

  WordRemindState clearWordList() => turnOffWordRemind().copyWith(wordList: []);
}
