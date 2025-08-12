import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/news_item.dart';

class NewsService {
  static const String apiKey = 'ba3a012e582d4e96aad11077a48ca6e1';
  static const String baseUrl = 'https://newsapi.org/v2';

  static Future<List<NewsItem>> fetchNewsByCategory(String category) async {
    final DateTime now = DateTime.now();
    final DateTime fromDate = now.subtract(Duration(days: 7));
    final String fromDateStr =
        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';

    String url;
    if (category == 'breaking') {
      // รวมข่าวจากหลายประเทศ
      url = '$baseUrl/top-headlines?sources=bbc-news,cnn,reuters,associated-press,the-guardian-uk&pageSize=50&apiKey=$apiKey';
    } else if (category == 'trending') {
      final queries = ['AI', 'technology', 'science', 'health', 'climate', 'space', 'เทคโนโลยี', 'วิทยาศาสตร์'];
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
              .map((json) => NewsItem.fromJson(json))
              .where((article) => 
                article.title != '[Removed]' && 
                article.description.isNotEmpty)
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

  static Future<List<NewsItem>> searchNews(String query) async {
    final DateTime now = DateTime.now();
    final DateTime fromDate = now.subtract(Duration(days: 30));
    final String fromDateStr =
        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';

    // แปลงคำภาษาไทยเป็นภาษาอังกฤษ
    String searchQuery = _translateThaiToEnglish(query);
    
    // รองรับการค้นหาภาษาไทยและอังกฤษ
    final encodedQuery = Uri.encodeComponent(searchQuery);
    final url = '$baseUrl/everything?q=$encodedQuery&from=$fromDateStr&sortBy=relevancy&pageSize=50&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => NewsItem.fromJson(json))
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

  static Future<List<NewsItem>> fetchTeslaNews() async {
    return fetchNewsByCategory('technology');
  }

  // แปลงคำภาษาไทยเป็นภาษาอังกฤษสำหรับการค้นหา
  static String _translateThaiToEnglish(String query) {
    final Map<String, String> thaiToEnglish = {
      'เทคโนโลยี': 'technology',
      'วิทยาศาสตร์': 'science',
      'สุขภาพ': 'health',
      'ธุรกิจ': 'business',
      'กีฬา': 'sports',
      'บันเทิง': 'entertainment',
      'การเมือง': 'politics',
      'เศรฐกิจ': 'economy',
      'สิ่งแวดล้อม': 'environment',
      'คอมพิวเตอร์': 'computer',
      'มือถือ': 'mobile phone smartphone',
      'อินเทอร์เน็ต': 'internet',
      'ปัญญาประดิษฐ์': 'artificial intelligence AI',
      'รถยนต์ไฟฟ้า': 'electric car EV',
      'อวกาศ': 'space',
      'โควิด': 'covid coronavirus',
      'วัคซีน': 'vaccine',
      'สภาพอากาศ': 'climate change weather',
    };
    
    String result = query.toLowerCase();
    
    // แทนที่คำภาษาไทยด้วยคำภาษาอังกฤษ
    thaiToEnglish.forEach((thai, english) {
      if (result.contains(thai)) {
        result = result.replaceAll(thai, english);
      }
    });
    
    return result;
  }
}