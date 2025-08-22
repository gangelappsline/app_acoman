

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  var logger = Logger();


  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }   

    initPushNotifications();
  }

  Future getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
    return token;
  }

  void handleMessage(RemoteMessage? message) {
    logger.d(message);
    if (message == null) return;

    // Handle the message when the app is in the foreground
    print('Handling a message: ${message.notification?.title}');
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
