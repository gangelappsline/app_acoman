import 'package:flutter/material.dart';

class SizedContainer extends StatefulWidget {
  final Widget? childWidget;
  final Color? color;

  const SizedContainer({super.key, @required this.childWidget, this.color});

  @override
  _SizedContainerState createState() => _SizedContainerState();
}

class _SizedContainerState extends State<SizedContainer> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      decoration: BoxDecoration(color: widget.color),
      child: widget.childWidget,
    );
  }
}
