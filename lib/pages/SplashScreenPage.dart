import 'package:acoman/pages/auth/LoginPage.dart';
import 'package:acoman/pages/supervisor/tab_container.dart';
import 'package:acoman/pages/toll/tab_container.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:acoman/pages/tab_container.dart';
import 'package:acoman/services/http_service.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  var logger = Logger();
  HttpService httpService = HttpService();

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of one flip
    )..repeat(); // Start the animation and repeat infinitely
    _navigateToLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _validateUserToken() async {
    Response response = await httpService.getDataHttp("/user");

    final j = json.decode(response.body);
    switch (response.statusCode) {
      case 200:
        await storage.write(key: "acoman-user", value: json.encode(j['data']));
        return true;
      case 401:
        return false;
      case 404:
        return false;
        break;
      default:
        return true;
    }
  }

  Future<void> _navigateToLogin() async {
    var storageUser = await storage.read(key: "acoman-user");
    var user = jsonDecode(storageUser.toString());

    await Future.delayed(const Duration(seconds: 2), () async {
      try {
        if (user != null) {
          if (await _validateUserToken()) {
            switch (user['role']) {
              case "administrador":
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const TabContainerPage()),
                    (Route<dynamic> route) => false);
                return true;
              case "supervisor":
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const TabContainerSupervisorPage()),
                    (Route<dynamic> route) => false);
                return false;
              case "caseta":
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const TabContainerTollPage()),
                    (Route<dynamic> route) => false);
                return false;
              case 404:
                return false;
                break;
              default:
                return true;
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      } catch (e) {
        //AlertDialog(title: const Text("Error"), content: Text(e.toString()));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Center(
                child: Image.asset(
                  'assets/images/logo_acoman_small.jpg', // Replace with your image asset
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
