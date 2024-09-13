import 'package:flutter/material.dart';
import '../services/glucose_entry.dart'; // Import GlucoseEntryPage từ thư mục services
import '../services/recipe_search_page.dart'; // Import RecipeSearchPage từ thư mục services
import '../pages/search_page.dart'; // Import SearchPage từ thư mục pages


class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  // Cập nhật danh sách _pages để bao gồm ReminderPage thay cho trang "Profile"
  static final List<Widget> _pages = <Widget>[
    const GlucoseEntryPage(),
    const RecipeSearchPage(),
    const Text('Profile Page', style: TextStyle(fontSize: 24)),
    const SearchPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Time',  // Thay thế "Profile" bằng "Time"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
