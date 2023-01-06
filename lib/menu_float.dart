import 'package:flutter/material.dart';
import 'package:word/utils/color_utils.dart';

class MenuFloat extends StatefulWidget {
  final Icon firstIcon;
  final Icon secondIcon;
  final Icon thirdIcon;
  final Color firstColor;
  final Color secondColor;
  final Color thirdColor;
  final VoidCallback firstTap;
  final VoidCallback secondTap;
  final VoidCallback thirdTap;
  final String periodLabel;

  const MenuFloat({
    super.key,
    required this.firstIcon,
    required this.secondIcon,
    required this.thirdIcon,
    required this.firstColor,
    required this.secondColor,
    required this.thirdColor,
    required this.firstTap,
    required this.secondTap,
    required this.thirdTap,
    required this.periodLabel,
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
    translateAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.elasticOut));
    iconAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        IgnorePointer(
          child: Container(
            color: Colors.transparent,
            height: 150.0,
            width: 150.0,
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(270), translateAnimation.value * 100),
          child: FloatingActionButton(
            backgroundColor: widget.firstColor,
            onPressed: widget.firstTap,
            elevation: 0,
            child: widget.firstIcon,
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(225), translateAnimation.value * 100),
          child: Transform(
            transform: Matrix4.identity()..scale(translateAnimation.value),
            alignment: Alignment.center,
            child: FloatingActionButton.extended(
                backgroundColor: widget.secondColor,
                onPressed: widget.secondTap,
                elevation: 0,
                label: Text(widget.periodLabel),
                icon: widget.secondIcon),
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadiansFromDegree(180), translateAnimation.value * 100),
          child: FloatingActionButton(
              backgroundColor: widget.thirdColor,
              onPressed: widget.thirdTap,
              elevation: 0,
              child: widget.thirdIcon),
        ),
        FloatingActionButton(
          backgroundColor: ColorUtils.blue,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: iconAnimation,
          ),
          onPressed: () {
            if (animationController.isCompleted) {
              animationController.reverse();
            } else {
              animationController.forward();
            }
          },
        )
      ],
    );
  }
}
