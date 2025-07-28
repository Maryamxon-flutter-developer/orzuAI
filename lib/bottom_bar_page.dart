import 'package:flutter/material.dart';
import 'package:orzulab/pages/shopping_page.dart';
import 'package:orzulab/pages/favorite.dart';
import 'package:orzulab/pages/home_page.dart';
import 'package:orzulab/pages/profile_page.dart';
import 'package:orzulab/pages/search_page.dart';



class BottomNavBarpage extends StatefulWidget {
  const BottomNavBarpage({super.key});

  @override
  State<BottomNavBarpage> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBarpage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    ShoppingPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  // TO'G'RILANDI: * o'rniga _
      
      bottomNavigationBar: Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 193, 194, 195), 
                width: 1
              ),
              color: Colors.white,
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home), 
                  label: "Home"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search), 
                  label: "Search"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag), 
                  label: "Cart"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), 
                  label: "Favorite"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person), 
                  label: "Profile"
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}