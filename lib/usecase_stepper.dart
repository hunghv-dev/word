import 'package:flutter/material.dart';
import 'package:word/utils/string_utils.dart';

class UseCaseStepper extends StatefulWidget {
  const UseCaseStepper({Key? key}) : super(key: key);

  @override
  _UseCaseStepperState createState() => _UseCaseStepperState();
}

class _UseCaseStepperState extends State<UseCaseStepper> {
  int _currentStep = 0;

  bool getIsActive(int currentIndex, int index) {
    if (currentIndex <= index) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controlsBuilder: (context, controller) {
        return const SizedBox.shrink();
      },
      currentStep: _currentStep,
      onStepTapped: (int index) {
        setState(() {
          _currentStep = index;
        });
      },
      steps: <Step>[
        Step(
          title: const Text(StringUtils.textStep1),
          content: Container(
            alignment: Alignment.topLeft,
            child: const Text(StringUtils.textUseCaseStep1),
          ),
          isActive: getIsActive(0, _currentStep),
        ),
        Step(
          title: const Text(StringUtils.textStep2),
          content: Container(
            alignment: Alignment.topLeft,
            child: const Text(StringUtils.textUseCaseStep2),
          ),
          isActive: getIsActive(1, _currentStep),
        ),
        Step(
          title: const Text(StringUtils.textStep3),
          content: Container(
            alignment: Alignment.topLeft,
            child: const Text(StringUtils.textUseCaseStep3),
          ),
          isActive: getIsActive(2, _currentStep),
        ),
      ],
    );
  }
}
