import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/dishes/Noodles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'FavoritesPage.dart';     // External favorites page with full logic

class GujaratiDishesPage extends StatefulWidget {
  @override
  _GujaratiDishesPageState createState() => _GujaratiDishesPageState();
}

class _GujaratiDishesPageState extends State<GujaratiDishesPage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> favoriteDishes = [];
  Set<String> favoriteDishIds = {};
  final Color brandColor = Color.fromRGBO(210, 13, 0, 1);
  bool isLoadingDishes = true;

  @override
  void initState() {
    super.initState();
    fetchGujaratiDishes();
    loadFavorites();
  }

  void fetchGujaratiDishes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .where('category', isEqualTo: 'Gujarati') // Fixed category spelling
          .get();

      final List<Map<String, dynamic>> loadedDishes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          'time': doc['time'] ?? '',
          'image': doc['image'] ?? '',
          'videoUrl': doc['videoURL'] ?? '',
          'ingredients': doc['ingredients'] ?? [],
          'directions': doc['directions'] ?? '',
        };
      }).toList();

      setState(() {
        dishes = loadedDishes;
        isLoadingDishes = false;
      });
    } catch (e) {
      print('Error fetching dishes: $e');
      setState(() {
        dishes = [];
        isLoadingDishes = false;
      });
    }
  }

  void toggleFavorite(Map<String, dynamic> dish) {
    setState(() {
      if (favoriteDishIds.contains(dish['id'])) {
        favoriteDishIds.remove(dish['id']);
        favoriteDishes.removeWhere((d) => d['id'] == dish['id']);
      } else {
        favoriteDishIds.add(dish['id']);
        favoriteDishes.add(dish);
      }
      saveFavorites();
    });
  }

  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encoded = favoriteDishes.map((d) => json.encode(d)).toList();
    await prefs.setStringList('favoriteGujaratiDishes', encoded);
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList('favoriteGujaratiDishes');
    if (encoded != null) {
      setState(() {
        favoriteDishes =
            encoded.map((s) => Map<String, dynamic>.from(json.decode(s))).toList();
        favoriteDishIds =
            favoriteDishes.map((dish) => dish['id'] as String).toSet();
      });
    }
  }

  bool isFavorite(Map<String, dynamic> dish) {
    return favoriteDishIds.contains(dish['id']);
  }

  void shareOnWhatsApp(Map<String, dynamic> dish) async {
    final name = dish["name"];
    final time = dish["time"];
    final videoUrl = dish["videoUrl"] ?? "https://www.foodrecipeapp.example.com";

    final text = "🍛 *Check out this Gujarati recipe!*\n\n"
        "*Dish:* $name\n"
        "*Time:* $time\n\n"
        "📺 Watch here: $videoUrl";

    final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void openRecipeDetails(String dishId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(dish: dishId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandColor,
        title: Text("Gujarati Dishes"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(favoriteDishes: favoriteDishes),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoadingDishes
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: dishes.isEmpty
                  ? Center(child: Text("No dishes found."))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        final favorite = isFavorite(dish);

                        return GestureDetector(
                          onTap: () => openRecipeDetails(dish['id']),
                          child: Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    dish["image"],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error,
                                          size: 50, color: Colors.red);
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => toggleFavorite(dish),
                                      child: Icon(
                                        favorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.redAccent,
                                        size: 26,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => shareOnWhatsApp(dish),
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.green,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
