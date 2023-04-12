import 'package:flutter/material.dart';
import 'package:workshoppr/authentication/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workshoppr/authentication/fire_auth.dart';
import 'package:workshoppr/pages/home_page.dart';
import 'package:workshoppr/pages/register_page.dart';
import 'package:workshoppr/pages/profile_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailTextController = TextEditingController();
    final _passwordTextController = TextEditingController();
    final _focusEmail = FocusNode();
    final _focusPassword = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 128.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Email address",
                ),
                controller: _emailTextController,
                focusNode: _focusEmail,
                validator: (value) => Validator.validateEmail(email: value!),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Password",
                ),
                controller: _passwordTextController,
                focusNode: _focusPassword,
                obscureText: true,
                validator: (value) =>
                    Validator.validatePassword(password: value!),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User? user = await FireAuth.signInUsingEmailPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                      context: context,
                    );
                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  }
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 8.0),
              Text("-  or  -"),
              SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
