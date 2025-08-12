import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<NewsArticle>> _newsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _currentCategory = 'breaking';
  bool _isSearching = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'breaking', 'name': 'ด่วน', 'icon': Icons.flash_on},
    {'key': 'technology', 'name': 'เทคโนโลยี', 'icon': Icons.computer},
    {'key': 'business', 'name': 'ธุรกิจ', 'icon': Icons.business},
    {'key': 'health', 'name': 'สุขภาพ', 'icon': Icons.health_and_safety},
    {'key': 'science', 'name': 'วิทยาศาสตร์', 'icon': Icons.science},
    {'key': 'sports', 'name': 'กีฬา', 'icon': Icons.sports_soccer},
    {'key': 'entertainment', 'name': 'บันเทิง', 'icon': Icons.movie},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _newsFuture = NewsService.fetchNewsByCategory(_currentCategory);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshNews() {
    setState(() {
      if (_isSearching && _searchController.text.isNotEmpty) {
        _newsFuture = NewsService.searchNews(_searchController.text);
      } else {
        _newsFuture = NewsService.fetchNewsByCategory(_currentCategory);
      }
    });
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _currentCategory = _categories[index]['key'];
      _isSearching = false;
      _searchController.clear();
      _newsFuture = NewsService.fetchNewsByCategory(_currentCategory);
    });
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
        _newsFuture = NewsService.searchNews(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาข่าว...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(color: Colors.black87, fontSize: 16),
                onSubmitted: _onSearch,
              )
            : Row(
                children: [
                  Icon(Icons.public, color: Colors.blue[600], size: 28),
                  SizedBox(width: 8),
                  Text(
                    'KrunchieNews',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _newsFuture = NewsService.fetchNewsByCategory(_currentCategory);
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.blue[600],
            ),
          ),
          IconButton(
            onPressed: _refreshNews,
            icon: Icon(Icons.refresh, color: Colors.blue[600]),
            tooltip: 'รีเฟรชข่าว',
          ),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: _onCategoryChanged,
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[600],
                tabs: _categories
                    .map((cat) => Tab(
                          icon: Icon(cat['icon'], size: 20),
                          text: cat['name'],
                        ))
                    .toList(),
              ),
      ),
      body: Column(
        children: [
          if (_isSearching)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                  SizedBox(width: 8),
                  Text(
                    'กด Enter เพื่อค้นหา',
                    style: TextStyle(color: Colors.blue[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'กำลังโหลดข่าว...',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text(
                          'เกิดข้อผิดพลาด',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '${snapshot.error}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshNews,
                          icon: Icon(Icons.refresh),
                          label: Text('ลองใหม่'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _isSearching ? 'ไม่พบข่าวที่ค้นหา' : 'ไม่พบข่าวในขณะนี้',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isSearching ? 'ลองค้นหาด้วยคำอื่น' : 'กรุณาลองใหม่ภายหลัง',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshNews,
                          icon: Icon(Icons.refresh),
                          label: Text('รีเฟรช'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshNews();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return NewsCard(
                        article: article,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailScreen(article: article),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}