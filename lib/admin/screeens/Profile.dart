import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:food_recipe_app/admin/Alogin.dart';
import 'package:food_recipe_app/admin/screeens/Dashboard.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> user = {};
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await Firebase.initializeApp();
    final docRef = FirebaseFirestore.instance.collection('admin_profiles').doc('admin1');
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      setState(() {
        user = {
          "name": snapshot['name'],
          "dob": snapshot['dob'],
          "email": snapshot['email'],
          "phone": snapshot['phone'],
          "password": snapshot['password'],
        };
        imageUrl = snapshot['imageUrl'];
      });
    } else {
      setState(() {
        user = {};
        imageUrl = "";
      });
    }
  }

  void _addProfile() {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _dobController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, "Full Name"),
                _buildTextField(_dobController, "Date of Birth"),
                _buildTextField(_emailController, "Email"),
                _buildTextField(_phoneController, "Phone Number"),
                _buildTextField(_passwordController, "Password", isPassword: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('admin_profiles').doc('admin1').set({
                  "name": _nameController.text,
                  "dob": _dobController.text,
                  "email": _emailController.text,
                  "phone": _phoneController.text,
                  "password": _passwordController.text,
                  "imageUrl": ""
                });

                setState(() {
                  user = {
                    "name": _nameController.text,
                    "dob": _dobController.text,
                    "email": _emailController.text,
                    "phone": _phoneController.text,
                    "password": _passwordController.text,
                  };
                  imageUrl = "";
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile created")));
              },
              child: Text("Create"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _editProfile() {
    TextEditingController _nameController = TextEditingController(text: user["name"]);
    TextEditingController _dobController = TextEditingController(text: user["dob"]);
    TextEditingController _emailController = TextEditingController(text: user["email"]);
    TextEditingController _phoneController = TextEditingController(text: user["phone"]);
    TextEditingController _passwordController = TextEditingController(text: user["password"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, "Full Name"),
                _buildTextField(_dobController, "Date of Birth"),
                _buildTextField(_emailController, "Email"),
                _buildTextField(_phoneController, "Phone Number"),
                _buildTextField(_passwordController, "Password", isPassword: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('admin_profiles').doc('admin1').update({
                  "name": _nameController.text,
                  "dob": _dobController.text,
                  "email": _emailController.text,
                  "phone": _phoneController.text,
                  "password": _passwordController.text,
                });

                setState(() {
                  user["name"] = _nameController.text;
                  user["dob"] = _dobController.text;
                  user["email"] = _emailController.text;
                  user["phone"] = _phoneController.text;
                  user["password"] = _passwordController.text;
                });

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfile() async {
    await FirebaseFirestore.instance.collection('admin_profiles').doc('admin1').delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile deleted")));
    _logout();
  }

  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminLogin()));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = path.basename(imageFile.path);
      final ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('admin_profiles').doc('admin1').update({
        "imageUrl": downloadUrl,
      });

      setState(() {
        imageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile picture updated.")));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Text("$title: $value", style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl != null && imageUrl != ""
                      ? NetworkImage(imageUrl!)
                      : AssetImage("assets/profile.jpg") as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(user["name"]!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Programmer", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              _buildProfileDetail(Icons.person, "Full Name", user["name"]!),
              _buildProfileDetail(Icons.calendar_today, "Date of Birth", user["dob"]!),
              _buildProfileDetail(Icons.email, "Email", user["email"]!),
              _buildProfileDetail(Icons.phone, "Phone Number", user["phone"]!),
              _buildProfileDetail(Icons.lock, "Password", user["password"]!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editProfile,
                child: Text("Edit Profile"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _logout,
                child: Text("Logout"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteProfile,
                child: Text("Delete Profile"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
            },
          ),
        ),
        body: user.isEmpty
            ? Center(
                child: ElevatedButton(
                  onPressed: _addProfile,
                  child: Text("Create Admin Profile"),
                ),
              )
            : _buildProfileView(),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
} 
