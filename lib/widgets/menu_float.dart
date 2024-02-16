import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word/bloc/word_remind_bloc.dart';

import 'hour_button.dart';

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
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: DurationDefine.ms50)
          ..addListener(() => setState(() {}));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MenuFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWordRemind == false && widget.isWordRemind == true) {
      _toggleMenu();
    }
  }

  void _toggleMenu() => _animationController.isCompleted
      ? _animationController.reverse()
      : _animationController.forward();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.bottomRight,
        children: [
          IgnorePointer(
            child: Container(
              color: Colors.transparent,
              height: 180.0,
              width: 180.0,
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(270.0.radian!, _animation.value * 100),
            child: Transform(
              transform: Matrix4.identity()..scale(_animation.value),
              child: FloatingActionButton(
                backgroundColor: (widget.isWordRemind
                        ? ColorsDefine.green()
                        : ColorsDefine.blue())
                    .of(context),
                onPressed: widget.firstTap,
                elevation: 0,
                child: widget.firstIcon,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(225.0.radian!, _animation.value * 100),
            child: Transform(
              transform: Matrix4.identity()..scale(_animation.value),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HourButton(
                        touchChange: (isScrollUp) => context
                            .read<WordRemindBloc>()
                            .add(WordRemindEvent.changeStartTime(isScrollUp)),
                        text: BlocBuilder<WordRemindBloc, WordRemindState>(
                          builder: (context, state) =>
                              Text(state.startTimeLabel),
                        ),
                        isWordRemind: widget.isWordRemind,
                      ),
                      HourButton(
                        touchChange: (isScrollUp) => context
                            .read<WordRemindBloc>()
                            .add(WordRemindEvent.changeEndTime(isScrollUp)),
                        text: BlocBuilder<WordRemindBloc, WordRemindState>(
                          builder: (context, state) => Text(state.endTimeLabel),
                        ),
                        isWordRemind: widget.isWordRemind,
                      ),
                    ],
                  ),
                  FloatingActionButton.extended(
                      backgroundColor: (widget.isWordRemind
                              ? ColorsDefine.grey()
                              : ColorsDefine.blue())
                          .of(context),
                      onPressed: widget.isWordRemind ? null : widget.secondTap,
                      elevation: 0,
                      label: Text(widget.periodLabel),
                      icon: widget.secondIcon),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(180.0.radian!, _animation.value * 100),
            child: Transform(
              transform: Matrix4.identity()..scale(_animation.value),
              child: FloatingActionButton(
                  backgroundColor: (widget.isWordRemind
                          ? ColorsDefine.grey()
                          : ColorsDefine.red())
                      .of(context),
                  onPressed: widget.isWordRemind ? null : widget.thirdTap,
                  elevation: 0,
                  child: widget.thirdIcon),
            ),
          ),
          FloatingActionButton(
            backgroundColor: (widget.isWordRemind
                    ? ColorsDefine.green()
                    : ColorsDefine.blue())
                .of(context),
            onPressed: _toggleMenu,
            child: widget.isWordRemind
                ? widget.firstIcon
                : AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animation,
                  ),
          )
        ],
      );
}
