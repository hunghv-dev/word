part of 'word_remind_bloc.dart';

@freezed
class WordRemindEvent with _$WordRemindEvent {
  const factory WordRemindEvent.pickCSVFile() = _PickCSVFile;

  const factory WordRemindEvent.loadCSVFile() = _LoadCSVFile;

  const factory WordRemindEvent.clearCSVFile() = _ClearCSVFile;

  const factory WordRemindEvent.turnWordRemind() = _TurnWordRemind;

  const factory WordRemindEvent.updateWordRemind() = _UpdateWordRemind;

  const factory WordRemindEvent.changeTimerPeriod() = _ChangeTimerPeriod;

  const factory WordRemindEvent.changeStartTime(bool isIncrease) =
      _ChangeStartTime;

  const factory WordRemindEvent.changeEndTime(bool isIncrease) = _ChangeEndTime;
}
