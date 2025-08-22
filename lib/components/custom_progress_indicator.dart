import 'package:flutter/material.dart';
import 'package:acoman/utils/constants.dart';

class CustomProgressIndicator extends StatefulWidget {
  final double strokeWidth;
  const CustomProgressIndicator({super.key, this.strokeWidth = 4.0});

  @override
  _CustomProgressIndicatorState createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: widget.strokeWidth,
      valueColor: animationController.drive(ColorTween(
          begin: ColorConstants.kPrimaryColorBlueLight,
          end: ColorConstants.kPrimaryColorBlueDark)),
    );
  }
}
