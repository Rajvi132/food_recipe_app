import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/FavoritesPage.dart' as fav;
import 'package:food_recipe_app/screens/NotificationPage.dart';
import 'package:food_recipe_app/screens/SearchPage.dart';
import 'package:food_recipe_app/screens/GujaratiDishesPage.dart';
import 'package:food_recipe_app/screens/SouthIndianPage.dart';
import 'package:food_recipe_app/screens/ChinesePage.dart';
import 'package:food_recipe_app/screens/PunjabiPage.dart';
import 'package:food_recipe_app/screens/MexicanPage.dart';
import 'package:food_recipe_app/screens/ItalianPage.dart';
import 'package:food_recipe_app/screens/FastFoodPage.dart';
import 'package:food_recipe_app/screens/ProfilePage.dart';
import 'package:food_recipe_app/screens/SavedRecipesPage.dart'; // Import the SavedRecipesPage

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> ingredients = [
    {"title": "Gujarati Dishes", "image": "assets/gujartimenu.jpeg"},
    {"title": "South Indian", "image": "assets/southindianmenu.png"},
    {"title": "Chinese", "image": "assets/chienesemenu.png"},
    {"title": "Punjabi", "image": "assets/punjabimenu.jpeg"},
    {"title": "Mexican", "image": "assets/mexicanmenu.png"},
    {"title": "Italian", "image": "assets/italianmenu.png"},
    {"title": "Fast Food", "image": "assets/fastfoodmenu.png"},
  ];

  Widget getMenuPage(String menu) {
    switch (menu) {
      case "Gujarati Dishes":
        return GujaratiDishesPage();
      case "South Indian":
        return SouthIndianPage();
      case "Chinese":
        return ChinesePage();
      case "Punjabi":
        return PunjabiPage();
      case "Mexican":
        return MexicanPage();
      case "Italian":
        return ItalianPage();
      case "Fast Food":
        return FastFoodPage();
      default:
        return Scaffold(body: Center(child: Text("Page Not Found")));
    }
  }

  final List<Widget> _pages = [
    HomeScreen(),
    fav.FavoritesPage(favoriteDishes: []),
    SavedRecipePage(), 
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(210, 13, 0, 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/logo.png', height: 50),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotificationScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/foodyheader.jpg',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  "Choose Your Dishes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Let's find the best dish you can cook"),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => getMenuPage(item["title"]!),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(item["image"]!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      item["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => _pages[index]),
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorites"),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: "Saved Recipes"), // Add saved recipes icon
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ],
      ),
    );
  }
}
