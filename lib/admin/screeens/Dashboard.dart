import 'package:flutter/material.dart';
import 'package:food_recipe_app/admin/screeens/Category.dart';
import 'package:food_recipe_app/admin/screeens/Dishes.dart';
import 'package:food_recipe_app/admin/screeens/Profile.dart';
import 'package:food_recipe_app/admin/screeens/Users.dart';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [DashboardScreen(), DishScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SafeArea(
              child: Center(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(12.0),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildDashboardItem(context, "Dishes", Icons.fastfood, DishScreen()),
                _buildDashboardItem(context, "Category", Icons.category, CategoryScreen()),
                _buildDashboardItem(context, "Users", Icons.people, UserScreen()),
                _buildDashboardItem(context, "Profile", Icons.person, ProfileScreen()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Dishes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Card(
        elevation: 4,
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.grey[800]),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

