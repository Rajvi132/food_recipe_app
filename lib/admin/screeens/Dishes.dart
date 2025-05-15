import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DishScreen extends StatefulWidget {
  const DishScreen({super.key});

  @override
  _DishScreenState createState() => _DishScreenState();
}

class _DishScreenState extends State<DishScreen> {
  final CollectionReference _dishesCollection = FirebaseFirestore.instance.collection('dishes');
  final CollectionReference _categoriesCollection = FirebaseFirestore.instance.collection('categories');

  void _addOrEditDish({DocumentSnapshot? document}) {
    TextEditingController nameController = TextEditingController(text: document?['name'] ?? '');
    TextEditingController timeController = TextEditingController(text: document?['time'] ?? '');
    TextEditingController ingredientsController = TextEditingController(
      text: document?.data().toString().contains('ingredients') == true
          ? (document!['ingredients'] as List).join(', ')
          : '',
    );
    TextEditingController directionsController = TextEditingController(
      text: document?.data().toString().contains('directions') == true
          ? (document!['directions'] as List).join(', ')
          : '',
    );
    TextEditingController imageController = TextEditingController(text: document?['image'] ?? '');
    TextEditingController videoURLController = TextEditingController(text: document?['videoURL'] ?? '');
    String selectedCategory = document?['category'] ?? 'Chinese';

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<QuerySnapshot>(
          future: _categoriesCollection.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            List<DropdownMenuItem<String>> categoryItems = snapshot.data!.docs.map((doc) {
              return DropdownMenuItem<String>(
                value: doc['name'],
                child: Text(doc['name']),
              );
            }).toList();

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(document != null ? "Edit Dish" : "Add Dish"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Dish Name'),
                        ),
                        TextField(
                          controller: timeController,
                          decoration: InputDecoration(labelText: 'Preparation Time'),
                        ),
                        TextField(
                          controller: ingredientsController,
                          decoration: InputDecoration(labelText: 'Ingredients (comma separated)'),
                        ),
                        TextField(
                          controller: directionsController,
                          decoration: InputDecoration(labelText: 'Directions (comma separated)'),
                        ),
                        TextField(
                          controller: imageController,
                          decoration: InputDecoration(labelText: 'Image (assets path)'),
                        ),
                        TextField(
                          controller: videoURLController,
                          decoration: InputDecoration(labelText: 'YouTube Video URL'),
                        ),
                        DropdownButtonFormField<String>(
                          value: categoryItems.any((item) => item.value == selectedCategory)
                              ? selectedCategory
                              : null,
                          items: categoryItems,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                          decoration: InputDecoration(labelText: "Category"),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        List<String> ingredientsList = ingredientsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                        List<String> directionsList = directionsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();

                        Map<String, dynamic> dishData = {
                          "name": nameController.text,
                          "category": selectedCategory,
                          "time": timeController.text,
                          "ingredients": ingredientsList,
                          "directions": directionsList,
                          "image": imageController.text,
                          "videoURL": videoURLController.text,
                        };

                        if (document != null) {
                          await _dishesCollection.doc(document.id).update(dishData);
                        } else {
                          await _dishesCollection.add(dishData);
                        }

                        Navigator.pop(context);
                      },
                      child: Text(document != null ? "Save" : "Add"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _deleteDish(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Dish"),
          content: Text("Are you sure you want to delete ${document['name']}?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _dishesCollection.doc(document.id).delete();
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
    return Scaffold(
      appBar: AppBar(title: Text("All Dishes")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: () => _addOrEditDish(),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add New Dish", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _dishesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final dishes = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Category")),
                        DataColumn(label: Text("Time")),
                        DataColumn(label: Text("Ingredients")),
                        DataColumn(label: Text("Directions")),
                        DataColumn(label: Text("Image")),
                        DataColumn(label: Text("Video")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: dishes.map((dish) {
                        final data = dish.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(Text(dish.id.substring(0, 5))),
                            DataCell(Text(data['name'] ?? '')),
                            DataCell(Text(data['category'] ?? '')),
                            DataCell(Text(data['time'] ?? '')),
                            DataCell(Text(data.containsKey('ingredients') ? (data['ingredients'] as List).join(', ') : '')),
                            DataCell(Text(data.containsKey('directions') ? (data['directions'] as List).join(', ') : '')),
                            DataCell(data['image'] != null && data['image'].isNotEmpty
                                ? Image.asset(data['image'], width: 50, height: 50)
                                : Text('No Image')),
                            DataCell(data['videoURL'] != null && data['videoURL'].isNotEmpty
                                ? InkWell(
                                    onTap: () => print("Open YouTube URL: ${data['videoURL']}"),
                                    child: Text(
                                      "View",
                                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                    ),
                                  )
                                : Text('No Video')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _addOrEditDish(document: dish),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteDish(dish),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
