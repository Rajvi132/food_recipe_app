import 'package:flutter/material.dart';
import 'package:food_recipe_app/admin/screeens/Dashboard.dart';


class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<Map<String, String>> users = [
    {"id": "1", "name": "abc", "email": "abc@gmail.com"},
    {"id": "2", "name": "xyz", "email": "xyz@gmail.com"},
    {"id": "3", "name": "def", "email": "def@gmail.com"},
  ];

  void _editUser(int index) {
    TextEditingController nameController = TextEditingController(text: users[index]['name']);
    TextEditingController emailController = TextEditingController(text: users[index]['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  users[index]['name'] = nameController.text;
                  users[index]['email'] = emailController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ],
        );
      },
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete User"),
          content: Text("Are you sure you want to delete ${users[index]['name']}?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  users.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ],
        );
      },
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
          title: Text("All Users", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateColor.resolveWith((states) => Colors.grey[300]!),
                        columns: [
                          DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(
                          users.length,
                          (index) => DataRow(
                            cells: [
                              DataCell(Text(users[index]["id"]!)),
                              DataCell(Text(users[index]["name"]!)),
                              DataCell(Text(users[index]["email"]!)),
                              DataCell(
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _editUser(index),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      child: Text("Edit"),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _deleteUser(index),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
