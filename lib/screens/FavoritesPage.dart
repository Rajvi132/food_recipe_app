import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteDishes;

  FavoritesPage({Key? key, required this.favoriteDishes}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Map<String, dynamic>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = widget.favoriteDishes;
    _saveToPrefs(); // Save initial favorites to SharedPreferences
  }

  /// Saves the current list of favorites to SharedPreferences
  void _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> encodedFavorites =
          _favorites.map((dish) => jsonEncode(dish)).toList();
      await prefs.setStringList('favorites', encodedFavorites);
    } catch (e) {
      print("Error saving to SharedPreferences: $e");
    }
  }

  /// Removes a dish from favorites and updates SharedPreferences
  void _removeFromPrefs(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _favorites.removeAt(index);
      });

      List<String> updatedFavorites =
          _favorites.map((dish) => jsonEncode(dish)).toList();
      await prefs.setStringList('favorites', updatedFavorites);

      // Display a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorite removed!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error removing from SharedPreferences: $e");
    }
  }

  /// Clears all favorites from SharedPreferences on user logout
  static Future<void> clearFavoritesOnLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorites');
    } catch (e) {
      print("Error clearing favorites: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.red.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/${dish["image"] ?? "default_image.png"}'),
                  ),
                  title: Text(dish["name"] ?? 'Unknown Dish'),
                  subtitle: Text("Time: ${dish["time"] ?? 'N/A'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeFromPrefs(index),
                  ),
                );
              },
            ),
    );
  }
}
