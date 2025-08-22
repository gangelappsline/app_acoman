import 'package:acoman/pages/SplashScreenPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await NotificationUtils().configuration();
  //runApp(const MyApp());

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  // mergeWith optional, you can include Platform.environment for Mobile/Desktop app
  runApp(OverlaySupport.global(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        primary:  Color(0xFF284573),
        seedColor: Color(0xFF01a0dc),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 18),
      ),
    );

    return MaterialApp(
      title: 'Kigadu',

      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      //darkTheme: ThemeData.dark(),
      //themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        // Add more routes as needed
      },
      //home: const SplashScreen(), //MyHomePage(title: 'Flutter Demo Home Page'),
      builder: EasyLoading.init(),
    );
  }
}
