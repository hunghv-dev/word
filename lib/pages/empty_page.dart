import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:word/widgets/item_stepper.dart';

import '../utils/define.dart';

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
          Spacing.h50,
          RotationTransition(
            turns: _rotationAnimation,
            child: const Icon(Icons.access_alarm_outlined, size: 100),
          ),
          Spacing.h20,
          Text(Define.appTitle, style: const TextStyle().s30.w700),
          const Divider(),
          Spacing.h10,
          ItemStepper(
              index: AppLocalizations.of(context).textStep1,
              title: Text(AppLocalizations.of(context).textUseCaseStep1)),
          ItemStepper(
              index: AppLocalizations.of(context).textStep2,
              title: Text(AppLocalizations.of(context).textUseCaseStep2)),
          ItemStepper(
            index: AppLocalizations.of(context).textStep3,
            title: Row(
              children: [
                Text(AppLocalizations.of(context).textTap),
                Spacing.w5,
                FloatingActionButton.extended(
                    backgroundColor: ColorsDefine.blue().color,
                    onPressed: null,
                    elevation: 0,
                    label: Text(AppLocalizations.of(context).textTime1M),
                    icon: const Icon(Icons.timer_outlined)),
                Spacing.w5,
                Text(AppLocalizations.of(context).textUseCaseStep3),
              ],
            ),
          ),
          ItemStepper(
            index: AppLocalizations.of(context).textStep4,
            title: Row(
              children: [
                Text(AppLocalizations.of(context).textUseCaseStep4First),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                        backgroundColor: ColorsDefine.blue().color,
                        onPressed: null,
                        elevation: 0,
                        child: Text(AppLocalizations.of(context).textTime0H)),
                    FloatingActionButton(
                        backgroundColor: ColorsDefine.blue().color,
                        onPressed: null,
                        elevation: 0,
                        child: Text(AppLocalizations.of(context).textTime24H)),
                  ],
                ),
                Text(AppLocalizations.of(context).textUseCaseStep4Second),
              ],
            ),
          ),
          ItemStepper(
            index: AppLocalizations.of(context).textStep5,
            title: Row(
              children: [
                Text(AppLocalizations.of(context).textTap),
                FloatingActionButton(
                    backgroundColor: ColorsDefine.blue().color,
                    onPressed: null,
                    elevation: 0,
                    child: const Icon(Icons.add_alert_outlined)),
                Text(AppLocalizations.of(context).textUseCaseStep5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
