import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:word/bloc/word_remind_bloc.dart';
import 'package:word/enum.dart';
import 'package:word/utils/color_utils.dart';
import 'package:word/utils/string_utils.dart';

import 'menu_float.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTurnOnNotification = false;
  late WordRemindBloc _bloc;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<WordRemindBloc>()..add(LoadCSVFileEvent());
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: BlocListener<WordRemindBloc, WordRemindState>(
          listener: (context, state) {
            if (!state.readFilePermission) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(StringUtils.permissionRemind)));
            }
            if (state.isWordReminding) {
              _scrollController.animateTo(state.wordRemindIndex! * 50,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear);
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: BlocBuilder<WordRemindBloc, WordRemindState>(
                builder: (context, state) {
                  final wordList = state.wordList;
                  return Stack(
                    children: [
                      ListView.builder(
                        itemCount: wordList.length,
                        itemBuilder: (_, index) {
                          final isFocusWord = state.isFocusWord(index);
                          return Container(
                            height: 50,
                            padding: const EdgeInsets.all(10.0),
                            decoration: isFocusWord
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: ColorUtils.darkGreen,
                                  )
                                : null,
                            child: Row(
                              children: wordList[index]
                                  .map(
                                    (word) => Expanded(
                                      flex: wordList[index].indexOf(word) == 0
                                          ? 2
                                          : 3,
                                      child: Text(
                                        word.toString(),
                                        style: TextStyle(
                                            fontSize: isFocusWord ? 20 : 15),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                        controller: _scrollController,
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: BlocBuilder<WordRemindBloc, WordRemindState>(
              builder: (context, state) {
                if (state.wordList.isEmpty) {
                  return FloatingActionButton(
                    onPressed: () => _bloc.add(PickCSVFileEvent()),
                    backgroundColor: ColorUtils.blue,
                    child: const Icon(
                      Icons.add,
                    ),
                  );
                }
                return MenuFloat(
                  firstIcon: const Icon(Icons.add_alert_outlined),
                  firstColor:
                      state.isWordRemind ? ColorUtils.green : ColorUtils.grey,
                  firstTap: () => _bloc.add(TurnWordRemindEvent()),
                  secondIcon: const Icon(Icons.timer_outlined),
                  secondColor:
                      state.isWordRemind ? ColorUtils.green : ColorUtils.grey,
                  secondTap: state.isWordRemind
                      ? null
                      : () => _bloc.add(ChangeTimerPeriodEvent()),
                  periodLabel: state.minuteTimerPeriod.label,
                  thirdIcon: const Icon(Icons.delete_forever_outlined),
                  thirdColor: ColorUtils.red,
                  thirdTap: state.isWordRemind
                      ? null
                      : () => _bloc.add(ClearCSVFileEvent()),
                  backgroundColor: state.isWordRemind ? ColorUtils.green : ColorUtils.blue,
                );
              },
            ),
          ),
        ),
      );
}
