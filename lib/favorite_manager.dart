import 'package:flutter/foundation.dart';
import 'package:apitest/news_article.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  final List<NewsArticle> _favoriteNews = [];

  List<NewsArticle> get favoriteNews => List.unmodifiable(_favoriteNews);

  bool isFavorite(NewsArticle article) {
    return _favoriteNews.any((fav) => fav.url == article.url);
  }

  void toggleFavorite(NewsArticle article) {
    final index = _favoriteNews.indexWhere((fav) => fav.url == article.url);
    
    if (index != -1) {
      // ลบออกจากรายการโปรด
      _favoriteNews.removeAt(index);
    } else {
      // เพิ่มเข้ารายการโปรด
      _favoriteNews.add(article);
    }
    
    notifyListeners();
  }

  void addFavorite(NewsArticle article) {
    if (!isFavorite(article)) {
      _favoriteNews.add(article);
      notifyListeners();
    }
  }

  void removeFavorite(NewsArticle article) {
    final index = _favoriteNews.indexWhere((fav) => fav.url == article.url);
    if (index != -1) {
      _favoriteNews.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllFavorites() {
    _favoriteNews.clear();
    notifyListeners();
  }

  int get favoritesCount => _favoriteNews.length;
}