import 'package:acoman/classes/user.dart';
import 'package:acoman/components/custom_progress_indicator.dart';
import 'package:acoman/pages/auth/LoginPage.dart';
import 'package:acoman/services/http_service.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:logger/logger.dart';

class SettingsTollPage extends  StatefulWidget {
  const SettingsTollPage({super.key});

  @override
  State<SettingsTollPage> createState() => _SettingsTollPageState();
}

class _SettingsTollPageState extends State<SettingsTollPage> {
  final storage = FlutterSecureStorage();
  HttpService httpService = HttpService();
  bool isLoading = true;
  bool notification = true;
  late User user;
  var logger = Logger();

  Future<void> getUser() async {
    final storageUser = await storage.read(key: "acoman-user");
    if (storageUser == null) {
      logger.e("No user found in secure storage.");
      // Optionally handle missing user, e.g., redirect to login
      return;
    }
    try {
      final tmpUser = jsonDecode(storageUser);
      setState(() {
        user = User(
          id: tmpUser["id"]?.toString() ?? '',
          name: tmpUser["name"] ?? '',
          email: tmpUser["email"] ?? '',
          role: tmpUser["role"] ?? '',
        );
      });
    } catch (e, stack) {
      logger.e("Failed to decode user data: $e", error: e, stackTrace: stack);
      // Optionally handle error, e.g., show error message or logout
    }
  }

  _logout() async {
    EasyLoading.show(status: 'Saliendo de tu perfil...');
    Response response = await httpService.postDataHttp("/logout", {});

    switch (response.statusCode) {
      case 200:
        await storage.deleteAll();
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

  void _init() async {
    await Future.any([getUser()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      notification = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: isLoading
            ? Center(child: CustomProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                            width: double.infinity,
                            height: size.height * 0.25,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              ColorConstants.kPrimaryColorBlueDark,
                              ColorConstants.kPrimaryColorBlueLight
                            ])),
                            child: Text("")),
                        Positioned(
                            bottom: -50,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  'https://ui-avatars.com/api/?name=${user.name}'),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        spacing: size.height * 0.02,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.alternate_email,
                                color: Colors.grey.shade500,
                              ),
                              Text(user.email)
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.assignment_ind_outlined,
                                color: Colors.grey.shade500,
                              ),
                              Text(user.role)
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(children: [Icon(
                                Icons.notifications_outlined,
                                color: Colors.grey.shade500,
                              ),
                              Text("Recibir notificaciones"),],)
                              ),
                              Switch(
                                  value: notification,
                                  onChanged: (bool value){
                                    _toggleNotification(value);
                                  })
                            ],
                          ),
                          Divider(),
                          MaterialButton(
                            onPressed: _logout,
                            height: 50,
                            // margin: EdgeInsets.symmetric(horizontal: 50),
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            // decoration: BoxDecoration(
                            // ),
                            child: Center(
                              child: Text(
                                "Salir de mi sesión",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
        );
  }
}