import 'package:flutter/material.dart';

class RoundedPasswordField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;

  const RoundedPasswordField({
    super.key,
    @required this.hintText,
    this.controller,
  });

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool hiddenPassword = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: hiddenPassword,
      controller: widget.controller,
      decoration: InputDecoration(
          suffixIcon: GestureDetector(
              onTap: () => {
                    setState(() {hiddenPassword = !hiddenPassword;})
                  },
              child: Icon(hiddenPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined)),
          hintText: widget.hintText,
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
class RoundedPasswordField extends StatelessWidget {
  const RoundedPasswordField({Key? key}) : super(key: key);

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
