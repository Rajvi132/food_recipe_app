import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedRecipePage extends StatefulWidget {
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
    final saved = prefs.getStringList('savedRecipes') ?? [];
    setState(() {
      savedRecipes = saved
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Recipes'),
        backgroundColor: Color.fromRGBO(210, 13, 0, 1),
      ),
      body: savedRecipes.isEmpty
          ? Center(child: Text("No saved recipes"))
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return ListTile(
                  title: Text(recipe['name'] ?? "Unknown recipe"),
                  subtitle: Text(recipe['ingredients']?.join(', ') ?? 'No ingredients'),
                  onTap: () {
                    // You can navigate to the recipe detail screen
                  },
                );
              },
            ),
    );
  }
}
