import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:workshoppr/authentication/fire_auth.dart';
import 'package:workshoppr/pages/home_page.dart';
import 'package:workshoppr/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Name: ${_currentUser.displayName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Email: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Verification: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                _currentUser.emailVerified
                    ? Text(
                        'Email verified',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.green),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          await _currentUser.sendEmailVerification();
                        },
                        child: const Text('Verify email'),
                      ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    User? user = await FireAuth.refreshUser(_currentUser);
                    if (user != null) {
                      setState(() {
                        _currentUser = user;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 200),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text('Sign out'))

            // Add widgets for verifying email
            // and, signing out the user
          ],
        ),
      ),
    );
  }
}
