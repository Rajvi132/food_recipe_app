import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/SavedRecipesPage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final String dish; // Firestore document ID

  RecipeDetailScreen({required this.dish});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  YoutubePlayerController? _youtubeController;
  Map<String, dynamic>? dishData;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadDishDetails();
  }

  Future<void> _loadDishDetails() async {
    try {
      DocumentSnapshot dishSnapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .doc(widget.dish)
          .get();

      if (dishSnapshot.exists && dishSnapshot.data() != null) {
        final data = dishSnapshot.data() as Map<String, dynamic>;
        _initializeYoutubeController(data["videoUrl"]?.toString());
        setState(() => dishData = data);
        _checkIfSaved(data);
      } else {
        throw Exception('Dish not found.');
      }
    } catch (e) {
      print("Error loading dish: $e");
    }
  }

  void _initializeYoutubeController(String? videoUrl) {
    if (videoUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  Future<void> _checkIfSaved(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('savedRecipes') ?? [];
    final encoded = jsonEncode({'id': widget.dish, ...data});
    setState(() => isSaved = saved.contains(encoded));
  }

  Future<void> _toggleSaveRecipe() async {
    if (dishData == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('savedRecipes') ?? [];
    final encoded = jsonEncode({'id': widget.dish, ...dishData!});

    setState(() {
      if (isSaved) {
        saved.remove(encoded);
        isSaved = false;
      } else {
        saved.add(encoded);
        isSaved = true;
      }
      prefs.setStringList('savedRecipes', saved);
    });
  }

  void _navigateToSavedRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedRecipePage()),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        backgroundColor: Color.fromRGBO(210, 13, 0, 1),
        actions: [
          if (dishData != null)
            IconButton(
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: _toggleSaveRecipe,
            ),
          IconButton(
            icon: Icon(Icons.bookmarks),
            onPressed: _navigateToSavedRecipes, // Navigate to Saved Recipe Page
          ),
        ],
      ),
      body: dishData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_youtubeController != null)
                    YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                    )
                  else if (dishData!["image"] != null)
                    Image.asset(
                      'assets/${dishData!["image"]}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),

                  // Recipe Info
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dishData!["name"] ?? "Recipe",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),

                        Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (dishData!["ingredients"] != null)
                          ...List<String>.from(dishData!["ingredients"]).map(_buildChip).toList(),

                        SizedBox(height: 10),

                        Text("Directions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(dishData!["directions"] ?? "No directions available."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Chip(
        label: Text(label, style: TextStyle(color: Color.fromRGBO(210, 13, 0, 1))),
        backgroundColor: Colors.white,
        shape: StadiumBorder(side: BorderSide(color: Color.fromRGBO(210, 13, 0, 1))),
      ),
    );
  }
}
