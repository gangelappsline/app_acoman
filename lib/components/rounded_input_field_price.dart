import 'package:flutter/material.dart';

class RoundedInputFieldPrice extends StatefulWidget {
  final String? hintText;
  final int maxLines;
  final int maxLength;
  final TextAlign textAlign;
  final TextEditingController? controller;
  const RoundedInputFieldPrice({
    super.key,
    required this.hintText,
    this.controller,
    this.maxLines = 1,
    this.maxLength = 1000,
    this.textAlign = TextAlign.start,
  });

  @override
  _RoundedInputFieldPriceState createState() => _RoundedInputFieldPriceState();
}

class _RoundedInputFieldPriceState extends State<RoundedInputFieldPrice> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      controller: widget.controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.attach_money_outlined),
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
