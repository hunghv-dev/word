import 'package:base_define/base_define.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word/bloc/word_remind_bloc.dart';
import 'package:word/widgets/item_time_range.dart';

class MenuFloat extends StatefulWidget {
  final Icon firstIcon;
  final Icon secondIcon;
  final Icon thirdIcon;
  final VoidCallback firstTap;
  final VoidCallback? secondTap;
  final VoidCallback? thirdTap;
  final String periodLabel;
  final bool isWordRemind;

  const MenuFloat({
    super.key,
    required this.firstIcon,
    required this.secondIcon,
    required this.thirdIcon,
    required this.firstTap,
    required this.secondTap,
    required this.thirdTap,
    required this.periodLabel,
    required this.isWordRemind,
  });

  @override
  State<MenuFloat> createState() => _MenuFloatState();
}

class _MenuFloatState extends State<MenuFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> translateAnimation, iconAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    translateAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.elasticOut));
    iconAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant MenuFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWordRemind == false && widget.isWordRemind == true) {
      _toggleMenu();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        IgnorePointer(
          child: Container(
            color: Colors.transparent,
            height: 180.0,
            width: 180.0,
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(270), translateAnimation.value * 100),
          child: Transform(
            transform: Matrix4.identity()..scale(translateAnimation.value),
            child: FloatingActionButton(
              backgroundColor: (widget.isWordRemind
                      ? ColorsDefine.green()
                      : ColorsDefine.blue())
                  .color,
              onPressed: widget.firstTap,
              elevation: 0,
              child: widget.firstIcon,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(225), translateAnimation.value * 100),
          child: Transform(
            transform: Matrix4.identity()..scale(translateAnimation.value),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ItemTimeRange(
                      touchChange: (isScrollUp) => context
                          .read<WordRemindBloc>()
                          .add(WordRemindEvent.changeStartTime(isScrollUp)),
                      text: BlocBuilder<WordRemindBloc, WordRemindState>(
                        builder: (context, state) {
                          return Text(
                            state.startTimeLabel,
                            style: const TextStyle(color: Colors.black),
                          );
                        },
                      ),
                      isWordRemind: widget.isWordRemind,
                    ),
                    ItemTimeRange(
                      touchChange: (isScrollUp) => context
                          .read<WordRemindBloc>()
                          .add(WordRemindEvent.changeEndTime(isScrollUp)),
                      text: BlocBuilder<WordRemindBloc, WordRemindState>(
                        builder: (context, state) {
                          return Text(
                            state.endTimeLabel,
                            style: const TextStyle(color: Colors.black),
                          );
                        },
                      ),
                      isWordRemind: widget.isWordRemind,
                    ),
                  ],
                ),
                FloatingActionButton.extended(
                    backgroundColor: (widget.isWordRemind
                            ? ColorsDefine.grey()
                            : ColorsDefine.blue())
                        .color,
                    onPressed: widget.isWordRemind ? null : widget.secondTap,
                    elevation: 0,
                    label: Text(widget.periodLabel),
                    icon: widget.secondIcon),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(180), translateAnimation.value * 100),
          child: Transform(
            transform: Matrix4.identity()..scale(translateAnimation.value),
            child: FloatingActionButton(
                backgroundColor: (widget.isWordRemind
                        ? ColorsDefine.grey()
                        : ColorsDefine.red())
                    .color,
                onPressed: widget.isWordRemind ? null : widget.thirdTap,
                elevation: 0,
                child: widget.thirdIcon),
          ),
        ),
        FloatingActionButton(
          backgroundColor:
              (widget.isWordRemind ? ColorsDefine.green() : ColorsDefine.blue())
                  .color,
          onPressed: _toggleMenu,
          child: widget.isWordRemind
              ? widget.firstIcon
              : AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: iconAnimation,
                ),
        )
      ],
    );
  }
}
