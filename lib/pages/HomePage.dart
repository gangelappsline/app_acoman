import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool pageLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return pageLoading
        ? const Center(child: CustomProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Bienvenido",
                      style: TextStyle(
                          color: ColorConstants.kPrimaryColorBlueDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
            ),
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [],
                      ))
                ])));
  }
}
