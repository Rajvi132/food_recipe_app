import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String title;
  final String value;

  const EditProfilePage({super.key, required this.title, required this.value});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.title}"),
        backgroundColor: Color.fromRGBO(210, 13, 0, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: widget.title, border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text); // Pass new value back
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(210, 13, 0, 1)),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
