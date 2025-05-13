import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_recipe_app/screens/TermsAndPrivacyPage.dart';
import 'package:food_recipe_app/screens/ChangePassword.dart';
import 'package:food_recipe_app/screens/ProfilePage.dart';
import 'package:food_recipe_app/screens/Login.dart'; // Ensure this is your login screen

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            Text(
              "Account Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 10),
            _buildSettingsButton(context, "Change Password", ChangePasswordPage()),
            _buildSettingsButton(context, "Terms & Conditions", TermsAndPrivacyPage()),

            SizedBox(height: 20),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // Widget for settings options
  Widget _buildSettingsButton(BuildContext context, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }

  // Widget for logout button
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Logout", style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
            Icon(Icons.exit_to_app, size: 18, color: Colors.red),
          ],
        ),
      ),
    );
  }

  // Logout function with Firebase, Google, SharedPreferences
  Future<void> _logout(BuildContext context) async {
    try {
      // Google Sign-Out (if signed in)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Firebase Sign-Out
      await _auth.signOut();

      // Clear SharedPreferences login flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );

      // Show logout confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged out successfully")),
      );
    } catch (e) {
      print("Logout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout. Please try again.")),
      );
    }
  }
}
