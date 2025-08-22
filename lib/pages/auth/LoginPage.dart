import 'package:acoman/pages/supervisor/tab_container.dart';
import 'package:acoman/pages/toll/tab_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:acoman/components/rounded_fill_button.dart';
import 'package:acoman/components/rounded_input_field.dart';
import 'package:acoman/components/rounded_password_field.dart';
import 'package:acoman/components/sized_container.dart';
import 'package:acoman/pages/tab_container.dart';
import 'package:acoman/services/http_service.dart';
import 'package:acoman/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  HttpService httpService = HttpService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool requestLoader = false;
  final GlobalKey _scaffold = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  var logger = Logger();
  bool hiddenPassword = true;

  _login() async {
    EasyLoading.show(status: 'Verificando credenciales...');

    setState(() {
      requestLoader = true;
    });

    Map<String, dynamic> data = {
      'email': emailController.text,
      'password': passwordController.text,
      //'firebase_token': _token
    };

    Response response = await httpService.postDataHttp("/login", data);
    EasyLoading.dismiss();
    final j = json.decode(response.body);
    logger.d(j);

    setState(() {
      requestLoader = false;
    });
    logger.d(response.statusCode);
    switch (response.statusCode) {
      case 200:
        await storage.write(key: "acoman-jwt", value: j['token']);
        await storage.write(key: "acoman-user", value: json.encode(j['user']));

        switch (j['user']['role']) {
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

        break;
      case 422:
        /*EasyLoading.showToast("Debe completar el formulario",
            duration: Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);*/
        final snackBar = SnackBar(
          content: const Text('Favor de completar el formulario'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Algo de código para ¡deshacer el cambio!
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        break;
      case 404:
        /*EasyLoading.showToast("Debe completar el formulario",
            duration: Duration(seconds: 2),
            toastPosition: EasyLoadingToastPosition.bottom);*/
        final snackBar = SnackBar(
          content: const Text('Email o contraseña incorrectos.'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Algo de código para ¡deshacer el cambio!
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        break;
      case 401:
        final snackBar = SnackBar(
          content: const Text('Email o contraseña incorrectos.'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Algo de código para ¡deshacer el cambio!
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        break;
      case 500:
        break;
      default:
    }
  }

  Future<void> _deleteStorage() async {
    await storage.delete(key: 'acoman-jwt');
    await storage.delete(key: 'acoman-user');
    await storage.delete(key: 'acoman-having');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              ColorConstants.kPrimaryColorBlueDark,
              ColorConstants.kPrimaryColorBlueLight,
            ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      FadeInUp(
                          duration: Duration(milliseconds: 1000),
                          child:
                              Image.asset('assets/images/logo_bordered.png', width: size.width * 0.6,)),
                      SizedBox(
                        height: 10,
                      ),
                      FadeInUp(
                          duration: Duration(milliseconds: 1300),
                          child: Text(
                            "Bienvenido",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: size.height * 0.04, fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 60,
                          ),
                          FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: ColorConstants
                                              .kPrimaryColorBlueDark
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: Offset(0, 10))
                                    ]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      Colors.grey.shade200))),
                                      child: TextField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                            hintText:
                                                "Correo Electrónico o Usuario",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      Colors.grey.shade200))),
                                      child: TextField(
                                        controller: passwordController,
                                        obscureText: hiddenPassword,
                                        decoration: InputDecoration(
                                            suffixIcon: GestureDetector(
                                                onTap: () => {
                                                      setState(() {
                                                        hiddenPassword =
                                                            !hiddenPassword;
                                                      })
                                                    },
                                                child: Icon(
                                                  hiddenPassword
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: const Color.fromARGB(
                                                      255, 184, 183, 183),
                                                )),
                                            hintText: "Contraseña",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(color: Colors.grey),
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                              duration: Duration(milliseconds: 1600),
                              child: MaterialButton(
                                onPressed: _login,
                                height: 50,
                                // margin: EdgeInsets.symmetric(horizontal: 50),
                                color: ColorConstants.kPrimaryColorBlueDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                // decoration: BoxDecoration(
                                // ),
                                child: Center(
                                  child: Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
