import 'package:flutter/material.dart';

class RoundedFillButton extends StatefulWidget {
  final Color? backgroundColor;
  final Widget? child;
  final double? width;
  final Color borderColor;
  const RoundedFillButton(
      {super.key,
      this.backgroundColor,
      this.child,
      this.borderColor = Colors.transparent,
      this.width = double.infinity});

  @override
  _RoundedFillButtonState createState() => _RoundedFillButtonState();
}

class _RoundedFillButtonState extends State<RoundedFillButton> {
  @override
  Widget build(BuildContext context) {

    return Container(
        width: widget.width,
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: widget.child);
  }
}
