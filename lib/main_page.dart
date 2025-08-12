import 'package:flutter/material.dart';
import 'package:apitest/screen/news_list_screen.dart';
import 'package:apitest/screen/news_detail_screen.dart';
import 'package:apitest/screen/general_news_screen.dart';
import 'package:apitest/screen/favorites_screen.dart';
import 'package:apitest/main.dart';
import 'package:apitest/news_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    NewsListScreen(), // หน้า 0
    GeneralNewsScreen(), // หน้า 1
    FavoritesScreen(favoriteNews: [],), // หน้า 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.electric_car),
            label: "Tesla",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "ทั่วไป"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorite"),
        ],
      ),
    );
  }
}
