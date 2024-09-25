import 'package:flutter/material.dart';
// import 'package:frontend/constants/sizes.dart';

class StatusBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double width;
  final Color stepCompleteColor;
  final Color currentStepColor;
  final Color inactiveColor;
  final double lineWidth;

  const StatusBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.width,
    required this.stepCompleteColor,
    required this.currentStepColor,
    required this.inactiveColor,
    required this.lineWidth,
  }) : assert(currentStep > 0 == true && currentStep <= totalSteps + 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0),
      width: width,
      child: Row(
        children: _steps(),
      ),
    );
  }

  getCircleColor(i) {
    Color color;
    if (i + 1 < currentStep) {
      color = stepCompleteColor;
    } else if (i + 1 == currentStep)
      color = currentStepColor;
    else
      color = Colors.white;
    return color;
  }

  getBorderColor(i) {
    Color color;
    if (i + 1 < currentStep) {
      color = stepCompleteColor;
    } else if (i + 1 == currentStep)
      color = currentStepColor;
    else
      color = inactiveColor;

    return color;
  }

  getLineColor(i) {
    var color =
        currentStep > i + 1 ? Colors.blue.withOpacity(0.4) : Colors.grey[200];
    return color;
  }

  List<Widget> _steps() {
    var list = <Widget>[];
    for (int i = 0; i < totalSteps; i++) {
      //color according to state

      var circleColor = getCircleColor(i);
      var BorderColor = getBorderColor(i);
      var lineColor = getLineColor(i);

      // step cirbles
      list.add(Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: circleColor,
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          border: Border.all(
            color: BorderColor,
            width: 1.0,
          ),
        ),
        child: getInnerElementOfStepper(i),
      ));

      // line between step circles
      if (i != totalSteps - 1) {
        list.add(
          Expanded(
            child: Container(
              height: lineWidth,
              color: lineColor,
            ),
          ),
        );
      }
    }

    return list;
  }

  Widget getInnerElementOfStepper(index) {
    if (index + 1 < currentStep) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 16.0,
      );
    } else if (index + 1 == currentStep) {
      return Center(
        child: Text(
          '$currentStep',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else
      return Container();
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: List.generate(totalSteps, (index) {
//         return Expanded(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 4.0),
//             height: Sizes.size12,
//             decoration: BoxDecoration(
//               color: index < currentStep
//                   ? const Color.fromARGB(255, 0, 0, 0)
//                   : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
