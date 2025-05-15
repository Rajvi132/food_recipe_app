import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_recipe_app/screens/HomePage.dart';
import 'package:food_recipe_app/screens/SavedRecipesPage.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String dish;

  const RecipeDetailScreen({Key? key, required this.dish}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? dishData;

  @override
  void initState() {
    super.initState();
    _loadDishDetails();
  }

  Future<void> _loadDishDetails() async {
    try {
      final dishSnapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .doc(widget.dish)
          .get();

      if (dishSnapshot.exists && dishSnapshot.data() != null) {
        setState(() {
          dishData = dishSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        throw Exception("Dish not found");
      }
    } catch (e) {
      print("Error fetching dish details: $e");
    }
  }

  Future<void> _saveRecipe() async {
    if (dishData == null) return;

    final prefs = await SharedPreferences.getInstance();
    final savedRecipes = prefs.getStringList('saved_recipes') ?? [];

    final newRecipe = jsonEncode({
      "name": dishData!["name"],
      "ingredients": dishData!["ingredients"],
      "directions": dishData!["directions"],
      "image": dishData!["image"],
    });

    if (!savedRecipes.contains(newRecipe)) {
      savedRecipes.add(newRecipe);
      await prefs.setStringList('saved_recipes', savedRecipes);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedRecipePage()),
    );
  }

  void _navigateToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _navigateToSavedRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedRecipePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recipe Details"),
          backgroundColor: const Color.fromRGBO(210, 13, 0, 1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToHomePage,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmarks),
              onPressed: _navigateToSavedRecipes,
            ),
          ],
        ),
        body: dishData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        dishData!["name"] ?? "Recipe",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(210, 13, 0, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.asset(
                          dishData!["image"] ,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 40),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Ingredients",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    if (dishData!["ingredients"] != null)
                      ...List<String>.from(dishData!["ingredients"])
                          .map((ing) => _buildChip(ing)),
                    const SizedBox(height: 16),
                    const Text(
                      "Directions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    if (dishData!["directions"] is List)
                      ...List<String>.from(dishData!["directions"])
                          .map((step) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text("• $step"),
                              ))
                    else if (dishData!["directions"] is String)
                      Text(dishData!["directions"])
                    else
                      const Text("No directions available."),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(210, 13, 0, 1),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Save Recipe",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Chip(
        label: Text(label, style: const TextStyle(color: Color.fromRGBO(210, 13, 0, 1))),
        backgroundColor: Colors.white,
        shape: const StadiumBorder(
          side: BorderSide(color: Color.fromRGBO(210, 13, 0, 1)),
        ),
      ),
    );
  }
}

// Would you also like a similar update for the Chinese Dishes page?

