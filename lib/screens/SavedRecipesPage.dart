import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_recipe_app/screens/HomePage.dart';

class SavedRecipePage extends StatefulWidget {
  const SavedRecipePage({Key? key}) : super(key: key);

  @override
  _SavedRecipePageState createState() => _SavedRecipePageState();
}

class _SavedRecipePageState extends State<SavedRecipePage> {
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_recipes') ?? [];
    setState(() {
      savedRecipes = saved
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _removeRecipe(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedRecipes.removeAt(index);
    });
    final updated = savedRecipes.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('saved_recipes', updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Recipes'),
        backgroundColor: Color.fromRGBO(210, 13, 0, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: savedRecipes.isEmpty
          ? Center(child: Text("No saved recipes"))
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe['image'] != null &&
                          recipe['image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.asset(
                            recipe['image'],
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey)),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(recipe['name'] ?? 'Unnamed Recipe',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            SizedBox(height: 8),
                            Text("Ingredients:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                            SizedBox(height: 4),
                            Text(
                              (recipe['ingredients'] as List<dynamic>?)
                                      ?.join(', ') ??
                                  'No ingredients listed',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            if (recipe['directions'] != null)
                              Text(
                                "Directions: " +
                                    ((recipe['directions'] is List)
                                        ? (recipe['directions'] as List)
                                            .take(2)
                                            .join('. ') +
                                            '...'
                                        : recipe['directions']),
                                style: TextStyle(color: Colors.black54),
                              ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeRecipe(index),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
