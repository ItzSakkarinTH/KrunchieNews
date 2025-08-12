import 'package:flutter/material.dart';
import 'package:apitest/news_article.dart';
import 'package:apitest/favorite_manager.dart';
import 'package:apitest/screen/news_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<NewsArticle> favoriteNews; // Keep for backward compatibility

  const FavoritesScreen({super.key, required this.favoriteNews});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteManager _favoriteManager = FavoriteManager();

  @override
  void initState() {
    super.initState();
    _favoriteManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteNews = _favoriteManager.favoriteNews;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red[400], size: 28),
            SizedBox(width: 8),
            Text(
              'ข่าวโปรด',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (favoriteNews.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red[400], size: 20),
                      SizedBox(width: 8),
                      Text('ลบทั้งหมด'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.more_vert, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
      body: favoriteNews.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(favoriteNews),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'ยังไม่มีข่าวโปรด',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'กดปุ่มหัวใจในข่าวที่ต้องการเพื่อบันทึกเป็นรายการโปรด',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'เคล็ดลับ: กดหัวใจที่มุมขวาบนของข่าว',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<NewsArticle> favoriteNews) {
    return Column(
      children: [
        // Header with count
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red[400],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข่าวที่บันทึกไว้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '${favoriteNews.length} ข่าว',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List of favorite news
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: favoriteNews.length,
            itemBuilder: (context, index) {
              final article = favoriteNews[index];
              return FavoriteNewsCard(
                article: article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(article: article),
                    ),
                  );
                },
                onRemove: () {
                  _showRemoveDialog(article);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRemoveDialog(NewsArticle article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[400]),
              SizedBox(width: 8),
              Text('ลบข่าวโปรด'),
            ],
          ),
          content: Text('ต้องการลบข่าวนี้ออกจากรายการโปรดหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                _favoriteManager.removeFavorite(article);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบข่าวออกจากรายการโปรดแล้ว'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.orange[400]),
              SizedBox(width: 8),
              Text('ลบทั้งหมด'),
            ],
          ),
          content: Text('ต้องการลบข่าวโปรดทั้งหมดหรือไม่? การกระทำนี้ไม่สามารถกู้คืนได้'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                _favoriteManager.clearAllFavorites();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบข่าวโปรดทั้งหมดแล้ว'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.white,
              ),
              child: Text('ลบทั้งหมด'),
            ),
          ],
        );
      },
    );
  }
}

class FavoriteNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteNewsCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                    article.imageUrl ?? 'https://via.placeholder.com/100x80?text=No+Image',
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      article.source ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Date
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(width: 8),
                        // Remove button
                        IconButton(
                          onPressed: onRemove,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red[400],
                            size: 20,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        // More than a week ago, show date in format yyyy-MM-dd
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else if (difference.inDays > 0) {
        // Less than a week ago, show relative time like "3 days ago"
        return '${difference.inDays} วันก่อน';
      } else if (difference.inHours > 0) {
        // Less than a day ago, show relative time like "5 hours ago"
        return '${difference.inHours} ชั่วโมงก่อน';
      } else {
        // Less than an hour ago, show relative time like "30 minutes ago"
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}