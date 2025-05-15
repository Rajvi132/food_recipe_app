import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/dishes/Noodles.dart';
import 'package:food_recipe_app/screens/FavoritesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class SouthIndianPage extends StatefulWidget {
  const SouthIndianPage({super.key});

  @override
  _SouthIndianPageState createState() => _SouthIndianPageState();
}

class _SouthIndianPageState extends State<SouthIndianPage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> favoriteDishes = [];
  final Color brandColor = const Color.fromRGBO(210, 13, 0, 1);

  @override
  void initState() {
    super.initState();
    fetchSouthIndianDishes();
    loadFavorites();
  }

  void fetchSouthIndianDishes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('dishes')
        .where('category', isEqualTo: 'SouthIndian')
        .get();

    final List<Map<String, dynamic>> loadedDishes = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'time': doc['time'],
        'image': doc['image'],
        'videoUrl': doc['videoUrl'],
        'ingredients': doc['ingredients'],
        'directions': doc['directions'],
      };
    }).toList();

    setState(() {
      dishes = loadedDishes;
    });
  }

  void toggleFavorite(Map<String, dynamic> dish) {
    final exists = favoriteDishes.any((d) => d['id'] == dish['id']);
    setState(() {
      if (exists) {
        favoriteDishes.removeWhere((d) => d['id'] == dish['id']);
      } else {
        favoriteDishes.add(dish);
      }
      saveFavorites();
    });
  }

  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encoded = favoriteDishes.map((d) => json.encode(d)).toList();
    await prefs.setStringList('favoriteDishes', encoded);
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList('favoriteDishes');
    if (encoded != null) {
      setState(() {
        favoriteDishes =
            encoded.map((s) => Map<String, dynamic>.from(json.decode(s))).toList();
      });
    }
  }

  bool isFavorite(Map<String, dynamic> dish) {
    return favoriteDishes.any((d) => d['id'] == dish['id']);
  }

  void shareOnWhatsApp(Map<String, dynamic> dish) async {
    final name = dish["name"];
    final time = dish["time"];
    final videoUrl = dish["videoUrl"] ?? "https://www.foodrecipeapp.example.com";

    final text = "🍛 *Check out this South Indian recipe!*\n\n"
        "*Dish:* $name\n"
        "*Time:* $time\n\n"
        "📺 Watch: $videoUrl";

    final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(favoriteDishes: favoriteDishes),
      ),
    );
  }

  void navigateToRecipeDetail(String dishId) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("South-Indian Dishes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: navigateToFavorites,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: dishes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  final favorite = isFavorite(dish);

                  return GestureDetector(
                    onTap: () => navigateToRecipeDetail(dish['id']),
                    child: Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/${dish["image"]}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => shareOnWhatsApp(dish),
                                child: const Icon(
                                  Icons.share,
                                  color: Colors.green,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                                  BorderRadius.vertical(bottom: Radius.circular(10)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dish["name"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: brandColor, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    dish["time"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

