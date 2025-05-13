import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/ChangePassword.dart';
import 'package:food_recipe_app/screens/HomePage.dart';
import 'package:food_recipe_app/screens/Login.dart';
import 'package:food_recipe_app/screens/NotificationPage.dart';
import 'package:food_recipe_app/screens/TermsAndPrivacyPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.currentUser?.delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.poppins(color: Colors.red)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFFFEBEE),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/avatar.png'), // Make sure this exists in your pubspec.yaml
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Rajvi Padhiyar",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "@rajvipadhiyar",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildProfileOption(Icons.lock_outline, "Change Password", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage()));
                }),
                _buildProfileOption(Icons.notifications, "Notifications", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
                }),
                _buildProfileOption(Icons.article_outlined, "Terms & Conditions", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TermsAndPrivacyPage()));
                }),
                _buildProfileOption(Icons.logout, "Logout", () => _logout(context)),
                _buildProfileOption(Icons.delete_forever, "Delete Account", () => _deleteAccount(context)),
                _buildProfileOption(Icons.home, "Go to Home", () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.red)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: onTap,
      ),
    );
  }
}
