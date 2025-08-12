import 'package:flutter/material.dart';
import '../models/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพข่าว
              if (article.urlToImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      article.urlToImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[400]!,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // เนื้อหาข่าว
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // แหล่งข่าวและวันที่
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.sourceName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // หัวข้อข่าว
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // รายละเอียดข่าว
                    if (article.description.isNotEmpty)
                      Text(
                        article.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 12),

                    // ผู้เขียน
                    if (article.author.isNotEmpty &&
                        article.author != 'ไม่ระบุผู้เขียน')
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              article.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
}