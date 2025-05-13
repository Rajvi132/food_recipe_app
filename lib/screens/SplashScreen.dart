import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:food_recipe_app/screens/Login.dart';
import 'package:food_recipe_app/screens/Rolepage.dart';
 

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), navigateToLogin);
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Rolepage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigateToLogin, // Navigate to LoginScreen when tapped anywhere
      child: Scaffold(
        backgroundColor: Color.fromRGBO(210, 13, 0, 1), // Setting the background color to red
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Ensure the image is placed in assets and declared in pubspec.yaml
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
