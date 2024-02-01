part of 'word_remind_bloc.dart';

@freezed
class WordRemindState with _$WordRemindState {
  const WordRemindState._();

  const factory WordRemindState({
    @Default([]) List<List<dynamic>> wordList,
    @Default(true) bool readFilePermission,
    @Default(false) bool isWordRemind,
    int? wordRemindIndex,
    @Default(MinuteTimer.oneMinute) MinuteTimer minuteTimerPeriod,
    @Default(0) int startTime,
    @Default(24) int endTime,
    @Default(true) bool isLoading,
  }) = _WordRemindState;

  bool get isWordReminding => isWordRemind && wordRemindIndex != null;

  bool isFocusWord(int index) => isWordReminding && wordRemindIndex == index;

  String get startTimeLabel => '${startTime}h';

  String get endTimeLabel => '${endTime}h';

  WordRemindState turnOff() =>
      copyWith(isWordRemind: false, wordRemindIndex: null, isLoading: false);

  WordRemindState clearWordList() => turnOff().copyWith(wordList: []);
}
