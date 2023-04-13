import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workshoppr/pages/login_page.dart';
import 'package:workshoppr/pages/home_page.dart';
import 'package:workshoppr/assets/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;
  Widget startPage = LoginPage();
  if (user != null) {
    startPage = HomePage();
  }

  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkShoppr',
      theme: ThemeData(
        primarySwatch: Palette.crimson,
      ),
      home: startPage,
    );
  }
}
