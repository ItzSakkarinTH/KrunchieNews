import 'package:flutter/material.dart';
import 'screen/news_screen.dart';
import 'screen/general_news_screen.dart';
import 'screen/favorites_screen.dart';
import 'screen/app_screen.dart';
import 'models/news_item.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GeneralNewsScreen(),
    const NewsScreen(),
    const FavoritesScreen(),
    const AppScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'ข่าวทั่วไป',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'ข่าวเทคโนโลยี',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'รายการโปรด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'แอป',
          ),
        ],
      ),
    );
  }
}