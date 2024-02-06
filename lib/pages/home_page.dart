import 'package:auto_route/auto_route.dart';
import 'package:base_define/base_define.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:word/bloc/word_remind_bloc.dart';
import 'package:word/pages/empty_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:word/widgets/item_direction.dart';

import '../di.dart';
import '../widgets/menu_float.dart';
import 'loading_page.dart';

@RoutePage()
class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => getIt<WordRemindBloc>(), child: this);
}

class _HomePageState extends State<HomePage> {
  bool isTurnOnNotification = false;
  late ScrollController _scrollController;
  late final _bloc = context.read<WordRemindBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const WordRemindEvent.loadCSVFile());
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context).readPermissionRemind)));
            }
            if (state.isWordReminding) {
              _scrollController.animateTo(state.wordRemindIndex! * 50,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear);
            }
          },
          child: Scaffold(
            body: BlocBuilder<WordRemindBloc, WordRemindState>(
              builder: (context, state) {
                final wordList = state.wordList;
                if (state.isLoading) {
                  return const LoadingPage();
                }
                if (wordList.isEmpty) {
                  return const EmptyPage();
                }
                return CustomScrollView(
                  slivers: [
                    const ItemDirection(icon: Icons.arrow_drop_up),
                    SliverFixedExtentList(
                      delegate: SliverChildBuilderDelegate(
                        (_, index) {
                          final isFocusWord = state.isFocusWord(index);
                          return Container(
                            height: 50,
                            padding: EdgeInsets.zero.vertical10.horizontal20,
                            decoration: isFocusWord
                                ? BoxDecoration(
                                    border: Border.all(
                                        width: 0.1,
                                        color: ColorsDefine.grey().color),
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.05),
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
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
                        childCount: wordList.length,
                      ),
                      itemExtent: 50,
                    ),
                    const ItemDirection(
                        icon: Icons.arrow_drop_down, isTop: false),
                  ],
                  controller: _scrollController,
                );
              },
            ),
            floatingActionButton: BlocBuilder<WordRemindBloc, WordRemindState>(
              builder: (context, state) {
                if (state.wordList.isEmpty) {
                  return FloatingActionButton(
                    onPressed: () =>
                        _bloc.add(const WordRemindEvent.pickCSVFile()),
                    backgroundColor: ColorsDefine.blue().color,
                    child: const Icon(
                      Icons.add,
                    ),
                  );
                }
                return MenuFloat(
                  firstIcon: const Icon(Icons.add_alert_outlined),
                  firstTap: () =>
                      _bloc.add(const WordRemindEvent.turnWordRemind()),
                  secondIcon: const Icon(Icons.timer_outlined),
                  secondTap: () =>
                      _bloc.add(const WordRemindEvent.changeTimerPeriod()),
                  thirdIcon: const Icon(Icons.delete_forever_outlined),
                  thirdTap: () =>
                      _bloc.add(const WordRemindEvent.clearCSVFile()),
                  periodLabel: state.minuteTimerPeriod.label,
                  isWordRemind: state.isWordRemind,
                );
              },
            ),
          ),
        ),
      );
}
