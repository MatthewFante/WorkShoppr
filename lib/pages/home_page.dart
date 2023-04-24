// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this class descibes the navigation framework for the app.
// it contains the bottom navigation bar and the pages that are navigated to when the user clicks on a navigation item
// it also determines whether the user is an admin and displays the add class button on the classes page if
// the user is an admin

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workshoppr/pages/feed_page.dart';
import 'package:workshoppr/pages/classes_page.dart';
import 'package:workshoppr/pages/equipment_page.dart';
import 'package:workshoppr/pages/login_page.dart';
import 'package:workshoppr/pages/profile_page.dart';
import 'package:workshoppr/widgets/new_class_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // set the initial state of the page to the feed page
  int _currentIndex = 0;
  bool showAddClassButton = false;

  // create a list to hold the uids of admins
  List<String> admins = [];

  // get the uids of admins from the database
  Future<void> getAdmins() async {
    final CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection('admins');

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collectionReference.get();
    final List<String> ids = snapshot.docs.map((doc) => doc.id).toList();
    admins = ids;
  }

  // create a list of the pages that are navigated to when the user clicks on a navigation item
  final List<Widget> _pages = [
    const FeedPage(),
    const ClassesPage(),
    const EquipmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // get the current user
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    // get the name and uid of the current user
    final currentUserName = getCurrentUser()?.displayName ?? 'Unknown';
    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

    // check if the current user is an admin
    bool userIsAdmin(String uid) {
      getAdmins();
      return admins.contains(uid);
    }

    // if the user is an admin, show the add class button on the classes page
    bool adminView = userIsAdmin(currentUserId);

    _currentIndex == 1 && adminView
        ? showAddClassButton = true
        : showAddClassButton = false;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Visibility(
            visible: showAddClassButton,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const NewClassDialog();
                  },
                );
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
        title: const Text('WorkShoppr',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Reservations',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 70,
              child: DrawerHeader(
                  child: Text('WorkShoppr',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ))),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Feed'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Classes'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.handyman),
              title: const Text('Reservations'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
            const SizedBox(
              height: 450,
            ),
            TextButton(
                onPressed: () async {
                  if (getCurrentUser() != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(user: getCurrentUser()!)),
                    );
                  } else {
                    null;
                  }
                },
                child: Text(currentUserName)),
            TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text('Sign out')),
          ],
        ),
      ),
    );
  }
}
