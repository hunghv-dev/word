import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:word/bloc/word_remind_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

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
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: BlocListener<WordRemindBloc, WordRemindState>(
          listener: (context, state) {
            if (!state.readFilePermission) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Please allow Files and media permission for pick files')));
            }
            if (state.isWordRemind) {
              _scrollController.animateTo(state.wordRemindIndex * 50,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut);
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: BlocBuilder<WordRemindBloc, WordRemindState>(
                builder: (context, state) {
                  final wordList = state.wordList;
                  if (wordList.isEmpty) {
                    return Center(
                      child: FloatingActionButton.large(
                        onPressed: () => _bloc.add(PickCSVFileEvent()),
                        backgroundColor: Colors.grey.shade400,
                        child: const Icon(
                          Icons.add,
                          size: 50,
                        ),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      ListView.builder(
                        itemCount: wordList.length,
                        itemBuilder: (_, index) {
                          return Container(
                            height: 50,
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: wordList[index]
                                  .map(
                                    (word) => Expanded(
                                      child: Text(
                                        word.toString(),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                        controller: _scrollController,
                      ),
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: BlocBuilder<WordRemindBloc, WordRemindState>(
                          builder: (context, state) {
                            return FloatingActionButton(
                              onPressed: () => _bloc.add(TurnWordRemindEvent()),
                              backgroundColor: state.isWordRemind
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              child: const Icon(Icons.add_alert_outlined,
                                  size: 30),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: BlocBuilder<WordRemindBloc, WordRemindState>(
              builder: (context, state) {
                if (state.wordList.isEmpty) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton.small(
                    onPressed: () => _bloc.add(ClearCSVFileEvent()),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.delete_forever));
              },
            ),
          ),
        ),
      );
}
