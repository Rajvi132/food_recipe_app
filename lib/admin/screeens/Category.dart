import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/admin/screeens/Dashboard.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<void> _addCategory() async {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Category"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _categoriesCollection.add({"name": controller.text});
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
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

  Future<void> _editCategory(DocumentSnapshot document) async {
    TextEditingController controller =
        TextEditingController(text: document['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Category"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _categoriesCollection
                      .doc(document.id)
                      .update({"name": controller.text});
                  Navigator.pop(context);
                }
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

  Future<void> _deleteCategory(DocumentSnapshot document) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Category"),
          content: Text("Are you sure you want to delete ${document['name']}?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _categoriesCollection.doc(document.id).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashboardScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("All Categories", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => DashboardScreen()));
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _addCategory,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Add New Category", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _categoriesCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final categories = snapshot.data!.docs;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowColor: WidgetStateColor.resolveWith(
                                (states) => Colors.grey[300]!),
                            columns: [
                              DataColumn(
                                  label: Text("ID",
                                      style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Name",
                                      style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Action",
                                      style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(
                              categories.length,
                              (index) {
                                final category = categories[index];

                                return DataRow(
                                  cells: [
                                    DataCell(Text((index + 1).toString())),
                                    DataCell(Text(category['name'])),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editCategory(category),
                                          ),
                                          SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteCategory(category),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
