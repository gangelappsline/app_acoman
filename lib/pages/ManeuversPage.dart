import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';

class ManeuversPage extends StatefulWidget {
  const ManeuversPage({super.key});

  @override
  State<ManeuversPage> createState() => _ManeuversPageState();
}

class _ManeuversPageState extends State<ManeuversPage> {
  bool pageLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return pageLoading
        ? const Center(child: CustomProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "Maniobras",
                style: TextStyle(color: ColorConstants.kPrimaryColorBlueDark),
              ),
            ),
            body: Container(
                child: Column(children: [
              Container(
                padding: EdgeInsets.all(
                  16.0,
                ),
                child: Text(
                    "Lorem  ajsdasgyudyuasgyudgyuasasgyudgyuasdasdasdasdyuasdasdytuasfytdfytasfytdfytasdfytasfytdfytasfytdfytasfytdfytasdfytasfytdsa"),
              )
            ])));
  }
}
