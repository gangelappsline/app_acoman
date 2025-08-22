import 'package:flutter/material.dart';

class RoundedInputField extends StatefulWidget {
  final String? hintText;
  final int maxLines;
  final int maxLength;
  final TextAlign textAlign;
  final TextInputType textInputType;
  final TextEditingController? controller;

  const RoundedInputField(
      {super.key,
      @required this.hintText,
      this.controller,
      this.maxLines = 1,
      this.maxLength = 1000,
      this.textAlign = TextAlign.start,
      this.textInputType = TextInputType.text});

  @override
  _RoundedInputFieldState createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.textInputType,
      controller: widget.controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: widget.hintText,
          counterText: "",
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFF3E9C8B), width: 5.0),
              borderRadius: BorderRadius.circular(10))),
      onChanged: (value) {
        // do something
      },
    );
  }
}
