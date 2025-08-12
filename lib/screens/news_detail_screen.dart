import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () => _launchUrl(article.url),
            icon: Icon(Icons.open_in_browser, color: Colors.blue[600]),
            tooltip: 'เปิดในเบราว์เซอร์',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              Image.network(
                article.urlToImage,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.source, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        article.sourceName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.author,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(article.url),
                      icon: Icon(Icons.open_in_browser),
                      label: Text('อ่านต่อในเว็บไซต์ต้นฉบับ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} วันที่แล้ว';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ชั่วโมงที่แล้ว';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      } else {
        return 'เมื่อสักครู่';
      }
    } catch (e) {
      return 'ไม่ระบุเวลา';
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}