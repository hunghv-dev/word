part of 'word_remind_bloc.dart';

@immutable
abstract class WordRemindEvent {}

class PickCSVFileEvent extends WordRemindEvent {}

class LoadCSVFileEvent extends WordRemindEvent {}

class ClearCSVFileEvent extends WordRemindEvent {}

class TurnWordRemindEvent extends WordRemindEvent {}

class UpdateWordRemindEvent extends WordRemindEvent {}