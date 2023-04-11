import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:workshoppr/feed_page.dart';
import 'package:workshoppr/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkShoppr',
      theme: ThemeData(
        primarySwatch: Palette.crimson,
      ),
      home: HomePage(),
    );
  }
}

class Palette {
  static MaterialColor crimson = const MaterialColor(
    0xff990000, // 100% shade
    <int, Color>{
      50: Color(0xffc8645f), // 10%
      100: Color(0xffb24c3e), // 20%
      200: Color(0xff9f4639), // 30%
      300: Color(0xff8b402f), // 40%
      400: Color(0xff773a25), // 50%
      500: Color(0xff64341b), // 60%
      600: Color(0xff502e11), // 70%
      700: Color(0xff3d2807), // 80%
      800: Color(0xff291f00), // 90%
      900: Color(0xff000000), // 100%
    },
  );
}
