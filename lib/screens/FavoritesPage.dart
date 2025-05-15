import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteDishes;

  const FavoritesPage({super.key, required this.favoriteDishes});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Map<String, dynamic>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = widget.favoriteDishes;
    _saveToPrefs();
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedFavorites = _favorites.map((dish) => jsonEncode(dish)).toList();
    await prefs.setStringList('favorites', encodedFavorites);
  }

  void _removeFromPrefs(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites.removeAt(index);
    });
    List<String> updatedFavorites = _favorites.map((dish) => jsonEncode(dish)).toList();
    await prefs.setStringList('favorites', updatedFavorites);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite removed!')),
    );
  }

  void _shareOnWhatsApp(Map<String, dynamic> dish) async {
    final name = dish["name"];
    final time = dish["time"];
    final videoUrl = dish["videoUrl"] ?? "https://example.com";

    final text = "🍛 Check out this recipe!\n\n"
        "Dish: $name\n"
        "Time: $time\n\n"
        "📺 Watch here: $videoUrl";

    final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildYouTubePlayer(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return const SizedBox();
    return YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      ),
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.red.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHome,
        ),
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final dish = _favorites[index];
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade700, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Image.asset(
                            dish["image"],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dish["name"] ?? 'Unknown Dish',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Time: ${dish["time"] ?? 'N/A'}"),
                      const SizedBox(height: 10),
                      if (dish["videoUrl"] != null && dish["videoUrl"].toString().isNotEmpty)
                        _buildYouTubePlayer(dish["videoUrl"]),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeFromPrefs(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.green),
                            onPressed: () => _shareOnWhatsApp(dish),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
