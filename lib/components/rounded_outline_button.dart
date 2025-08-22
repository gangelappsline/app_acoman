import 'package:flutter/material.dart';

class RoundedOutlineButton extends StatefulWidget {
  final Color? backgroundColor;
  final Widget? child;
  final double? width;
  final Color borderColor;
  const RoundedOutlineButton(
      {super.key,
      this.backgroundColor,
      this.child,
      this.borderColor = Colors.transparent,
      this.width = double.infinity});

  @override
  _RoundedOutlineButtonState createState() => _RoundedOutlineButtonState();
}

class _RoundedOutlineButtonState extends State<RoundedOutlineButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: 40,
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 1),
            borderRadius: BorderRadius.circular(30)),
        child: widget.child);
  }
}
