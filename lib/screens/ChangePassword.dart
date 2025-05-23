import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password"), backgroundColor: Colors.red),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Change password logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
