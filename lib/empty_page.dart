import 'package:flutter/material.dart';
import 'package:word/item_stepper.dart';
import 'package:word/utils/string_utils.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _rotationAnimation;
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward()
          ..repeat(reverse: true);
    _rotationAnimation = Tween(begin: -0.02, end: 0.02).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.elasticInOut));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          RotationTransition(
            turns: _rotationAnimation,
            child: const Icon(Icons.access_alarm_outlined, size: 100),
          ),
          const SizedBox(height: 20),
          const Text(
            StringUtils.appTitle,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 20),
          const ItemStepper(
              index: StringUtils.textStep1,
              title: StringUtils.textUseCaseStep1),
          const ItemStepper(
              index: StringUtils.textStep2,
              title: StringUtils.textUseCaseStep2),
          const ItemStepper(
              index: StringUtils.textStep3,
              title: StringUtils.textUseCaseStep3),
        ],
      ),
    );
  }
}
