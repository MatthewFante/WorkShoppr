import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workshoppr/pages/feed_page.dart';
import 'package:workshoppr/pages/classes_page.dart';
import 'package:workshoppr/pages/equipment_page.dart';
import 'package:workshoppr/pages/login_page.dart';
import 'package:workshoppr/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const FeedPage(),
    const ClassesPage(),
    const EquipmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final username = getCurrentUser()?.displayName ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
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
            label: 'Equipment',
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
              title: const Text('Equipment'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
            SizedBox(
              height: 400,
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
                child: Text(username)),
            SizedBox(
              width: 10,
              child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: Text('Sign out')),
            )
          ],
        ),
      ),
    );
  }
}
