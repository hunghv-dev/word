part of 'word_remind_bloc.dart';

class WordRemindState {
  final List<List<dynamic>> wordList;
  final bool readFilePermission;
  final bool isWordRemind;
  final int wordRemindIndex;

  WordRemindState.initial()
      : wordList = [],
        readFilePermission = true,
        isWordRemind = false,
        wordRemindIndex = 0;

  WordRemindState(this.wordList, this.readFilePermission, this.isWordRemind,
      this.wordRemindIndex);

  WordRemindState copyWith(
          {List<List<dynamic>>? wordList,
          bool? readFilePermission,
          bool? isWordRemind,
          int? wordRemindIndex}) =>
      WordRemindState(
        wordList ?? this.wordList,
        readFilePermission ?? this.readFilePermission,
        isWordRemind ?? this.isWordRemind,
        wordRemindIndex ?? this.wordRemindIndex,
      );
}
