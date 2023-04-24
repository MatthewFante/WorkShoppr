// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workshoppr/pages/login_page.dart';
import 'package:workshoppr/pages/home_page.dart';
import 'package:workshoppr/assets/palette.dart';

Future<void> main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Determine the starting page
  User? user = FirebaseAuth.instance.currentUser;
  Widget startPage = const LoginPage();

  // If the user is already logged in, go to the home page
  if (user != null) {
    startPage = const HomePage();
  }

  // Run the app
  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkShoppr',
      theme: ThemeData(
        // Using a custom color palette defined in assets/palette.dart
        primarySwatch: Palette.crimson,
      ),
      home: startPage,
    );
  }
}
