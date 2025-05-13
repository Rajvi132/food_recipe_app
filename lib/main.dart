import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/SplashScreen.dart';
import 'package:food_recipe_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <- Proper initialization
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food-Recipe',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Splashscreen(),
    );
  }
}
