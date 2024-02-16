part of 'word_remind_bloc.dart';

@freezed
class WordRemindState with _$WordRemindState, MessageState<WordRemindMessage> {
  const WordRemindState._();

  const factory WordRemindState({
    @Default([]) List<List<dynamic>> wordList,
    @Default(false) bool isWordRemind,
    int? wordRemindIndex,
    @Default(MinuteTimer.oneMinute) MinuteTimer minuteTimerPeriod,
    @Default(Define.startDay) int startTime,
    @Default(Define.endDay) int endTime,
    @Default(true) bool isLoading,
    @override WordRemindMessage? message,
    @override bool? resetMessage,
  }) = _WordRemindState;

  bool isFocusWord(int index) => isWordRemind && wordRemindIndex == index;

  String get startTimeLabel => '${startTime}h';

  String get endTimeLabel => '${endTime}h';

  @override
  MessageState<WordRemindMessage> copyMessage(WordRemindMessage? message) =>
      copyWith(message: message);
}
