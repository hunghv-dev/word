part of 'word_remind_bloc.dart';

class WordRemindState {
  final List<List<dynamic>> wordList;
  final bool readFilePermission;
  final bool isWordRemind;

  WordRemindState.initial()
      : wordList = [],
        readFilePermission = true,
        isWordRemind = false;

  WordRemindState(this.wordList, this.readFilePermission, this.isWordRemind);

  WordRemindState copyWith(
          {List<List<dynamic>>? wordList,
          bool? readFilePermission,
          bool? isWordRemind}) =>
      WordRemindState(
          wordList ?? this.wordList,
          readFilePermission ?? this.readFilePermission,
          isWordRemind ?? this.isWordRemind);
}
