import 'package:base_define/base_define.dart';
import 'package:flutter/material.dart';
import 'package:word/utils/string_utils.dart';
import 'package:word/widgets/item_stepper.dart';
import 'package:word/widgets/item_time_range.dart';

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
          const SizedBox(height: 10),
          const ItemStepper(
              index: StringUtils.textStep1,
              title: Text(StringUtils.textUseCaseStep1)),
          const ItemStepper(
              index: StringUtils.textStep2,
              title: Text(StringUtils.textUseCaseStep2)),
          ItemStepper(
            index: StringUtils.textStep3,
            title: Row(
              children: [
                const Text(StringUtils.textTap),
                SizedBox(width: 5),
                FloatingActionButton.extended(
                    backgroundColor: ColorsDefine.blue().color,
                    onPressed: null,
                    elevation: 0,
                    label: Text(StringUtils.textTime1M),
                    icon: Icon(Icons.timer_outlined)),
                SizedBox(width: 5),
                Text(StringUtils.textUseCaseStep3),
              ],
            ),
          ),
          ItemStepper(
            index: StringUtils.textStep4,
            title: Row(
              children: [
                const Text(StringUtils.textUseCaseStep4First),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    ItemTimeRange(
                        text: Text(StringUtils.textTime0H,
                            style: TextStyle(color: Colors.black)),
                        isWordRemind: false),
                    ItemTimeRange(
                        text: Text(StringUtils.textTime24H,
                            style: TextStyle(color: Colors.black)),
                        isWordRemind: false),
                  ],
                ),
                const Text(StringUtils.textUseCaseStep4Second),
              ],
            ),
          ),
          ItemStepper(
            index: StringUtils.textStep5,
            title: Row(
              children: [
                Text(StringUtils.textTap),
                FloatingActionButton(
                    backgroundColor: ColorsDefine.blue().color,
                    onPressed: null,
                    elevation: 0,
                    child: Icon(Icons.add_alert_outlined)),
                Text(StringUtils.textUseCaseStep5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
