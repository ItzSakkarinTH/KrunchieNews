import 'package:flutter/foundation.dart';
import 'models/news_item.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  final List<NewsItem> _favoriteNews = [];

  List<NewsItem> get favoriteNews => List.unmodifiable(_favoriteNews);

  bool isFavorite(NewsItem article) {
    return _favoriteNews.any((fav) => fav.url == article.url);
  }

  void toggleFavorite(NewsItem article) {
    final index = _favoriteNews.indexWhere((fav) => fav.url == article.url);
    
    if (index != -1) {
      _favoriteNews.removeAt(index);
    } else {
      _favoriteNews.add(article);
    }
    
    notifyListeners();
  }

  void addFavorite(NewsItem article) {
    if (!isFavorite(article)) {
      _favoriteNews.add(article);
      notifyListeners();
    }
  }

  void removeFavorite(NewsItem article) {
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