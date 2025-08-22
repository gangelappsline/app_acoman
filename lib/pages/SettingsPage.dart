import 'dart:convert';

import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/pages/auth/LoginPage.dart';
import 'package:acoman/services/http_service.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  HttpService httpService = HttpService();
  bool pageLoading = false;
  var logger = Logger();

  _logout() async {
    EasyLoading.show(status: 'Saliendo de tu perfil...');
    Response response = await httpService.postDataHttp("/logout", {});
    final j = json.decode(response.body);
    logger.d(j);

    switch (response.statusCode) {
      case 200:
        await storage.deleteAll();
        /*await storage.delete(key: 'kuidare-jwt');
        await storage.delete(key: 'kuidare-user');
        await storage.delete(key: 'kuidare-having');*/
        EasyLoading.dismiss();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
        break;
      case 422:
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return pageLoading
        ? const Center(child: CustomProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "Configuración",
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
              ),
              GestureDetector(
                  onTap: () => {_logout()},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: Icon(
                          Icons.logout_outlined,
                          color: Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text("Cerrar sesión",
                          style: TextStyle(color: Colors.red.shade800)),
                    ],
                  ))
            ])));
  }
}
