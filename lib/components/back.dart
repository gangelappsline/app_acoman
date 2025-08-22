import 'package:flutter/material.dart';
import 'package:acoman/utils/constants.dart';

class Back extends StatefulWidget {
  const Back({super.key});

  @override
  _BackState createState() => _BackState();
}

class _BackState extends State<Back> {
  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;
    return Icon(
        platform == TargetPlatform.iOS
            ? Icons.arrow_back_ios_new_outlined
            : Icons.arrow_back,
        size: 20,
        color: ColorConstants.kPrimaryColorBlueDark);
  }
}
