import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/dishes/Noodles.dart';
import 'package:food_recipe_app/screens/FavoritesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ChinesePage extends StatefulWidget {
  const ChinesePage({super.key});

  @override
  _ChinesePageState createState() => _ChinesePageState();
}

class _ChinesePageState extends State<ChinesePage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> favoriteDishes = [];
  Set<String> favoriteDishIds = {};
  final Color brandColor = Color.fromRGBO(210, 13, 0, 1);
  bool isLoadingDishes = true;

  @override
  void initState() {
    super.initState();
    fetchChineseDishes();
    loadFavorites();
  }

  void fetchChineseDishes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .where('category', isEqualTo: 'Chieneseee') 
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

  void toggleFavorite(Map<String, dynamic> dish) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favoriteDishIds.contains(dish['id'])) {
        favoriteDishIds.remove(dish['id']);
        favoriteDishes.removeWhere((d) => d['id'] == dish['id']);
      } else {
        favoriteDishIds.add(dish['id']);
        favoriteDishes.add(dish);
      }
    });

    List<String> encoded = favoriteDishes.map((d) => json.encode(d)).toList();
    await prefs.setStringList('allFavoriteDishes', encoded);
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList('allFavoriteDishes');
    if (encoded != null) {
      final allFavorites = encoded
          .map((s) => Map<String, dynamic>.from(json.decode(s)))
          .toList();
      setState(() {
        favoriteDishes = allFavorites;
        favoriteDishIds =
            allFavorites.map((dish) => dish['id'] as String).toSet();
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

    final text = "🍜 *Check out this Chinese recipe!*\n\n"
        "*Dish:* $name\n"
        "*Time:* $time\n\n"
        "📺 Watch here: $videoUrl";

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
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Chinese Dishes"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: navigateToFavorites,
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
                        final isFav = isFavorite(dish);

                        return GestureDetector(
                          onTap: () => navigateToRecipeDetail(dish['id']),
                          child: Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: brandColor, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        dish["image"],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(Icons.broken_image,
                                                color: Colors.grey, size: 40),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          color: Colors.black.withOpacity(0.6),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dish["name"],
                                                style: TextStyle(
                                                    color: Colors.white, fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "⏱ ${dish["time"]}",
                                                style: TextStyle(
                                                    color: Colors.white70, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                        isFav ? Icons.favorite : Icons.favorite_border,
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
