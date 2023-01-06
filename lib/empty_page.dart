import 'package:flutter/material.dart';
import 'package:word/usecase_stepper.dart';
import 'package:word/utils/string_utils.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage>
    with SingleTickerProviderStateMixin {
  bool _isShowStepper = false;
  late final Animation<double> _rotationAnimation;
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward()
          ..repeat(reverse: true);
    _rotationAnimation =
        Tween(begin: -0.05, end: 0.05).animate(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Center(
                  child: IconButton(
                    onPressed: () =>
                        setState(() => _isShowStepper = !_isShowStepper),
                    icon: const Icon(Icons.info),
                    iconSize: 40,
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isShowStepper ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: _isShowStepper
                      ? const UseCaseStepper()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
