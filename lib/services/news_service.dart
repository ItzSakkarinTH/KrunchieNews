import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_article.dart';

class NewsService {
  static const String apiKey = 'ba3a012e582d4e96aad11077a48ca6e1';
  static const String baseUrl = 'https://newsapi.org/v2';

  static Future<List<NewsArticle>> fetchNewsByCategory(String category) async {
    final DateTime now = DateTime.now();
    final DateTime fromDate = now.subtract(Duration(days: 7));
    final String fromDateStr =
        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';

    String url;
    if (category == 'breaking') {
      url = '$baseUrl/top-headlines?country=us&pageSize=50&apiKey=$apiKey';
    } else if (category == 'search') {
      final queries = ['AI', 'technology', 'science', 'health', 'climate'];
      final query = queries.join(' OR ');
      url = '$baseUrl/everything?q=($query)&from=$fromDateStr&sortBy=popularity&pageSize=50&apiKey=$apiKey';
    } else {
      url = '$baseUrl/top-headlines?category=$category&pageSize=50&apiKey=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => NewsArticle.fromJson(json))
              .where((article) => 
                article.title != '[Removed]' && 
                article.description.isNotEmpty &&
                article.urlToImage.isNotEmpty)
              .take(30)
              .toList();
        } else {
          throw Exception('API Error: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  static Future<List<NewsArticle>> searchNews(String query) async {
    final DateTime now = DateTime.now();
    final DateTime fromDate = now.subtract(Duration(days: 30));
    final String fromDateStr =
        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';

    final url = '$baseUrl/everything?q=$query&from=$fromDateStr&sortBy=relevancy&pageSize=50&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => NewsArticle.fromJson(json))
              .where((article) => article.title != '[Removed]')
              .take(30)
              .toList();
        } else {
          throw Exception('API Error: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}