import 'package:apitest/screen/news_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewsListScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
    );
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String sourceName;
  final String author;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    required this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'ไม่มีหัวข้อ',
      description: json['description'] ?? 'ไม่มีรายละเอียด',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']?['name'] ?? 'ไม่ระบุแหล่งที่มา',
      author: json['author'] ?? 'ไม่ระบุผู้เขียน',
    );
  }
}

class NewsService {
  static const String apiKey = 'ba3a012e582d4e96aad11077a48ca6e1';
  static const String baseUrl = 'https://newsapi.org/v2';

  // เปลี่ยนจาก fetchThailandNews เป็น fetchTeslaNews
  static Future<List<NewsArticle>> fetchTeslaNews() async {
    // สร้างวันที่ 30 วันที่ผ่านมาในรูปแบบ YYYY-MM-DD
    final DateTime now = DateTime.now();
    final DateTime fromDate = now.subtract(Duration(days: 30));
    final String fromDateStr =
        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';

    // ใช้ everything endpoint แทน top-headlines
    final url =
        '$baseUrl/everything?q=tesla&from=$fromDateStr&sortBy=publishedAt&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => NewsArticle.fromJson(json))
              .where(
                (article) => article.title != '[Removed]',
              ) // กรองข่าวที่ถูกลบ
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
