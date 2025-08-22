import 'package:flutter/material.dart';

class RoundedNumberField extends StatefulWidget {
  final String? hintText;
  final double borderRadius;
  final double fontSize;
  final dynamic Function(String) onChangeFx;
  final TextEditingController? controller;

  const RoundedNumberField({
    super.key,
    required this.hintText,
    this.borderRadius = 15,
    this.fontSize = 25,
    this.controller,
    required this.onChangeFx,
  });

  @override
  _RoundedNumberFieldState createState() => _RoundedNumberFieldState();
}

class _RoundedNumberFieldState extends State<RoundedNumberField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: widget.fontSize),
        maxLength: 1,
        onChanged: widget.onChangeFx,
        decoration: InputDecoration(
            hintText: widget.hintText,
            counterText: "",
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF3E9C8B), width: 5.0),
                borderRadius: BorderRadius.circular(10))));
  }
} 
