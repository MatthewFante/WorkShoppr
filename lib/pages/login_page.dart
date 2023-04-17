import 'package:flutter/material.dart';
import 'package:workshoppr/authentication/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workshoppr/authentication/fire_auth.dart';
import 'package:workshoppr/pages/home_page.dart';
import 'package:workshoppr/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailTextController = TextEditingController();
    final passwordTextController = TextEditingController();
    final focusEmail = FocusNode();
    final focusPassword = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkShoppr',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 200.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                controller: emailTextController,
                focusNode: focusEmail,
                validator: (value) => Validator.validateEmail(email: value!),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                controller: passwordTextController,
                focusNode: focusPassword,
                obscureText: true,
                validator: (value) =>
                    Validator.validatePassword(password: value!),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    User? user = await FireAuth.signInUsingEmailPassword(
                      email: emailTextController.text,
                      password: passwordTextController.text,
                      context: context,
                    );
                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    }
                  }
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text("-  or  -"),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
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
