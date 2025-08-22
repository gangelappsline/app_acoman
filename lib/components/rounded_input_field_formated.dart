import 'package:flutter/material.dart';

class RoundedInputFieldFormated extends StatefulWidget {
  final String? hintText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyType;
  final TextEditingController? controller;

  const RoundedInputFieldFormated({
    super.key,
    @required this.hintText,
    this.controller,
    this.keyType = TextInputType.text,
    int this.maxLines = 1,
    int this.maxLength = 1000,
  });

  @override
  _RoundedInputFieldFormatedState createState() =>
      _RoundedInputFieldFormatedState();
}

class _RoundedInputFieldFormatedState extends State<RoundedInputFieldFormated> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyType,
      textCapitalization: TextCapitalization.sentences,
      controller: widget.controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
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
}/*
class RoundedInputFieldFormated extends StatelessWidget {
  const RoundedInputFieldFormated({Key? key}) : super(key: key);

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
