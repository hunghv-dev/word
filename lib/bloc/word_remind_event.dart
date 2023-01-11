part of 'word_remind_bloc.dart';

@immutable
abstract class WordRemindEvent {}

class PickCSVFileEvent extends WordRemindEvent {}

class LoadCSVFileEvent extends WordRemindEvent {}

class ClearCSVFileEvent extends WordRemindEvent {}

class TurnWordRemindEvent extends WordRemindEvent {}

class UpdateWordRemindEvent extends WordRemindEvent {}

class ChangeTimerPeriodEvent extends WordRemindEvent {}

class ChangeStartTimeEvent extends WordRemindEvent {
  final bool isIncrease;

  ChangeStartTimeEvent(this.isIncrease);
}

class ChangeEndTimeEvent extends WordRemindEvent {
  final bool isIncrease;

  ChangeEndTimeEvent(this.isIncrease);
}
