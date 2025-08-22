import 'dart:convert';

import 'package:acoman/api/firebase_api.dart';
import 'package:acoman/api/push_notification.dart';
import 'package:acoman/pages/toll/ManeuversPage.dart';
import 'package:acoman/pages/toll/settings.dart';
import 'package:acoman/services/http_service.dart';
import 'package:acoman/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/web.dart';
import 'package:overlay_support/overlay_support.dart';

class TabContainerTollPage extends StatefulWidget {
  const TabContainerTollPage({super.key});

  @override
  State<TabContainerTollPage> createState() =>
      _TabContainerTollPageState();
}

class _TabContainerTollPageState
    extends State<TabContainerTollPage> {
  HttpService httpService = HttpService();
  var logger = Logger();
  PushNotification? _notificationInfo;
  late final FirebaseMessaging _messaging;

  Future<void> _init() async {
    registerNotification();
    checkForInitialMessage();
    /*String token = await FirebaseApi().getFCMToken();

    Map<String, dynamic> data = {
      "firebase_token": token,
    };

    Response response = await httpService.postDataHttp("/me", data);
    final j = json.decode(response.body);
    logger.d(j);

    switch (response.statusCode) {
      case 200:
        break;
      case 422:
        break;
      default:
    }*/
  }

  checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
        dataImage: initialMessage.data['image'],
        dataRoute: initialMessage.data['route'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  void registerNotification() async {
    await FirebaseApi().initialize();
    _messaging = FirebaseMessaging.instance;
    logger.d(_messaging);

    _messaging.getToken().then((token) async {
      print("This is your token");
      print(token);
      Map<String, dynamic> data = {
        "firebase_token": token,
      };

      Response response = await httpService.postDataHttp("/me", data);
      final j = json.decode(response.body);
      print(j);

      switch (response.statusCode) {
        case 200:
          break;
        case 422:
          break;
        default:
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
        dataImage: message.data['image'],
        dataRoute: message.data['route'],
      );

      setState(() {
        _notificationInfo = notification;
      });

      if (_notificationInfo != null) {
        //playLocalAsset();
        // For displaying the notification as an overlay
        /*showSimpleNotification(
          GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(notification.dataRoute);
              },
              child: Text(
                _notificationInfo!.title!,
                style: TextStyle(
                    color: ColorConstants.kPrimaryColorBlue,
                    fontWeight: FontWeight.w400),
              )),
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: OctoImage(
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                image: NetworkImage(_notificationInfo!.dataImage),
                progressIndicatorBuilder: (context, progress) {
                  double? value;
                  var expectedBytes = progress?.expectedTotalBytes;
                  if (progress != null && expectedBytes != null) {
                    value = progress.cumulativeBytesLoaded / expectedBytes;
                  }
                  return const SizedBox(
                    height: 15.0,
                    width: 15.0,
                    child: Center(
                      child: CustomProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stacktrace) =>
                    const Icon(Icons.error),
              ) /*Image.network(
                _notificationInfo!.dataImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )*/
              ), //NotificationBadge(totalNotifications: 1),
          subtitle: Text(_notificationInfo!.body!,
              style: TextStyle(color: ColorConstants.kPrimaryColorBlue)),
          background: Colors.white,
          duration: const Duration(seconds: 5),
        );*/
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['route'] != null) {
        //_navigateToRoute(message.data, context);
      }
    });

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logger.d(message);
        //print('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        //notificationUtils.createLocalInstantNotification(message.data);

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          /*dataTitle: message.data['title'],
          dataBody: message.data['body'],
          dataImage: message.data['image'],
          dataRoute: message.data['route'],*/
        );

        setState(() {
          _notificationInfo = notification;
        });

        if (_notificationInfo != null) {
          showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                  onTap: () {
                    OverlaySupportEntry.of(context)?.dismiss();
                    String? route = message.data['route'];
                    print(route);
                    /*Navigator.of(context).pushNamed(notification.dataRoute,
                      arguments: message.data);*/
                  },
                  child: SafeArea(
                    child: ListTile(
                      leading: SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: ClipOval(
                            child: Image.asset(
                  'assets/images/logo_acoman_small.jpg', // Replace with your image asset
                  width: 200,
                  height: 200,
                ),
                          )),
                      title: Text(
                        _notificationInfo!.title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.kPrimaryColorBlueDark),
                      ),
                      subtitle: Text(
                        _notificationInfo!.body!,
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context)?.dismiss();
                          }),
                    ),
                  )),
            );
          }, duration: Duration(milliseconds: 4000));
          // For displaying the notification as an overlay
          /*showSimpleNotification(
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  String? route = message.data['route'];
                  if (route != null) {
                    switch (route) {
                      case "/conversation":
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ConversationPage(
                                  conversationId:
                                      message.data["conversationId"],
                                  userId: message.data["userId"],
                                )));
                        break;
                      default:
                    }
                  }
                  /*Navigator.of(context).pushNamed(notification.dataRoute,
                      arguments: message.data);*/
                },
                onTapCancel: () => {},
                child: Text(
                  _notificationInfo!.title!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.kPrimaryColorBlue),
                )),
            subtitle: Text(
              _notificationInfo!.body!,
              style: TextStyle(color: Colors.black),
            ),
            contentPadding: EdgeInsetsDirectional.all(10.0),
            background: Colors.white,
            duration: const Duration(seconds: 10),
          );*/
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    // Initialize any necessary data or state here
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                //ExplorePage(),
                const ManeuversTollPage(),
                const SettingsTollPage(),
              ],
            ),
            bottomNavigationBar: TabBar(
                labelStyle: const TextStyle(fontSize: 9.0),
                labelColor: Theme.of(context).colorScheme.primary,
                indicatorColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Color.fromRGBO(184, 184, 184, 1),
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  const Tab(
                    icon: Icon(Icons.local_shipping, size: 25.0),
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                    text: "Maniobras",
                  ),
                  const Tab(
                    icon: Icon(Icons.settings, size: 25.0),
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                    text: "Configuración",
                  ),
                ])));
  }
}
