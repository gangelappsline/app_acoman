import 'package:flutter/material.dart';

class RoundedTimerField extends StatefulWidget {
  final String? hintText;
  final int? maxLines;
  final int? maxLength;
  final TextEditingController? controller;

  const RoundedTimerField({
    super.key,
    @required this.hintText,
    this.controller,
    int this.maxLines = 1,
    int this.maxLength = 1000,
  });

  @override
  _RoundedTimerFieldState createState() => _RoundedTimerFieldState();
}

class _RoundedTimerFieldState extends State<RoundedTimerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
          hintText: widget.hintText,
          counterText: "",
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFF3E9C8B), width: 5.0),
              borderRadius: BorderRadius.circular(30))),
      onChanged: (value) {
        // do something
      },
    );
  }
}/*
class RoundedTimerField extends StatelessWidget {
  const RoundedTimerField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          hintText: 'KindaCode.com',
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3E9C8B), width: 5.0),
              borderRadius: BorderRadius.circular(30))),
      onChanged: (value) {
        // do something
      },
    );
  }
}*/
