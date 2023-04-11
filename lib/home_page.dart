import 'package:flutter/material.dart';
import 'package:workshoppr/feed_page.dart';
import 'package:workshoppr/classes_page.dart';
import 'package:workshoppr/equipment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const FeedPage(),
    ClassesPage(),
    EquipmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 70,
              child: const DrawerHeader(
                child: Text('Menu'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('Feed'),
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
          ],
        ),
      ),
    );
  }
}
