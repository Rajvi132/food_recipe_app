import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/dishes/Noodles.dart';
import 'package:food_recipe_app/screens/FavoritesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ItalianPage extends StatefulWidget {
  @override
  _ItalianPageState createState() => _ItalianPageState();
}

class _ItalianPageState extends State<ItalianPage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> favoriteDishes = [];
  final Color brandColor = Color.fromRGBO(210, 13, 0, 1);

  @override
  void initState() {
    super.initState();
    fetchItalianDishes();
    loadFavorites();
  }

  // Fetch Italian dishes from Firestore
  void fetchItalianDishes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('dishes')
        .where('categories', isEqualTo: 'Italian')
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

  // Toggle favorite status
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

  // Save favorites to SharedPreferences
  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encoded = favoriteDishes.map((d) => json.encode(d)).toList();
    await prefs.setStringList('favoriteDishes', encoded);
  }

  // Load favorites from SharedPreferences
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

  // Check if favorite
  bool isFavorite(Map<String, dynamic> dish) {
    return favoriteDishes.any((d) => d['id'] == dish['id']);
  }

  // Share dish on WhatsApp
  void shareOnWhatsApp(Map<String, dynamic> dish) async {
    final name = dish["name"];
    final time = dish["time"];
    final videoUrl = dish["videoUrl"] ?? "https://www.foodrecipeapp.example.com";

    final text = "🍕 *Check out this Italian recipe!*\n\n"
        "*Dish:* $name\n"
        "*Time to cook:* $time\n\n"
        "📺 Watch here: $videoUrl";

    final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch WhatsApp")),
      );
    }
  }

  // Navigate to Favorites page
  void navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(favoriteDishes: favoriteDishes),
      ),
    );
  }

  // Navigate to recipe detail (use your detail screen here)
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Italian Dishes", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: navigateToFavorites,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: dishes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                  favorite ? Icons.favorite : Icons.favorite_border,
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
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dish["name"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: brandColor, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    dish["time"],
                                    style: TextStyle(
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
