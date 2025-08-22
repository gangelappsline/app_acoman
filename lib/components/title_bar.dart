import 'package:flutter/material.dart';
import 'package:acoman/utils/constants.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;

  const TitleBar({super.key, required this.title})
      : preferredSize = const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => {Navigator.of(context).pop()},
          child: Icon(
            Icons.arrow_back_outlined,
            color: ColorConstants.kPrimaryColorBlueDark,
          ),
        ),
        title: Text(title,
            style: TextStyle(color: ColorConstants.kPrimaryColorBlueDark)));
  }
}
