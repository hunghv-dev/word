import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:word/widgets/item_stepper.dart';

import '../utils/define.dart';
import '../widgets/floating_circle.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: DurationDefine.s1)
          ..forward()
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            Box.h50,
            RotationTransition(
              turns: Tween(
                begin: Define.rotationStartTween,
                end: Define.rotationEndTween,
              ).animate(
                CurvedAnimation(
                    parent: _animationController, curve: Curves.elasticInOut),
              ),
              child: const Icon(Icons.access_alarm_outlined, size: 100),
            ),
            Box.h20,
            Text(Define.appTitle, style: const TextStyle().s30.w700),
            const Divider(),
            Box.h10,
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
                  Box.w5,
                  FloatingActionButton.extended(
                      backgroundColor: ColorsDefine.blue().of(context),
                      onPressed: null,
                      elevation: 0,
                      label: Text(AppLocalizations.of(context).textTime1M),
                      icon: const Icon(Icons.timer_outlined)),
                  Box.w5,
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
                      FloatingCircle(
                          child: Text(AppLocalizations.of(context).textTime0H)),
                      FloatingCircle(
                          child:
                              Text(AppLocalizations.of(context).textTime24H)),
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
                  const FloatingCircle(child: Icon(Icons.add_alert_outlined)),
                  Text(AppLocalizations.of(context).textUseCaseStep5),
                ],
              ),
            ),
          ],
        ),
      );
}
