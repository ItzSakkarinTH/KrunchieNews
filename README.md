# KrunchieNews 📰

แอปพลิเคชัน Flutter สำหรับอ่านข่าวสารแบบ real-time พร้วมระบบการจัดการข่าวที่ทันสมัยและใช้งานง่าย

## หลักการทำงาน

แอป KrunchieNews ใช้ **การจัดการ State แบบ modern** ร่วมกับ ** API Integration** สำหรับดึงข้อมูลข่าวสารจากแหล่งต่างๆ และนำเสนอในรูปแบบที่อ่านง่าย พร้อมฟีเจอร์การจัดหมวดหมู่และการค้นหา

### การจัดการสถานะ (State Management)

แอปจัดการ 5 สถานะหลัก:
1. **Initial State** - สถานะเริ่มต้นของแอป
2. **Loading State** - แสดง indicators ขณะโหลดข่าว
3. **Success State** - แสดงรายการข่าวเมื่อโหลดสำเร็จ
4. **Error State** - แสดงข้อความ error เมื่อเกิดปัญหา
5. **Empty State** - แสดงข้อความเมื่อไม่มีข่าวสาร

## อธิบายการทำงานของโค้ด

### 1. News Model
```dart
class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String sourceUrl;
  final String author;
  final String source;
  final DateTime publishedAt;
  final String category;
  final List<String> tags;
  final int readTime;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceUrl: json['url'] ?? '',
      author: json['author'] ?? 'Unknown',
      source: json['source']?['name'] ?? 'Unknown Source',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? 'General',
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      readTime: json['readTime'] ?? 5,
    );
  }
}
```
- สร้างโมเดลข้อมูลข่าวสำหรับจัดเก็บข้อมูลจาก News API
- ใช้ `factory NewsArticle.fromJson()` แปลง JSON response เป็น NewsArticle object
- จัดการ **Date Parsing** สำหรับ publishedAt field
- จัดการ **Nested Objects** สำหรับ source information
- ใช้ null safety operators สำหรับข้อมูลที่อาจเป็น null

### 2. NewsService - การเรียกใช้ News API
```dart
class NewsService {
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = 'YOUR_API_KEY_HERE';

  static Future<List<NewsArticle>> fetchNews({
    String category = 'general',
    String country = 'th',
    int page = 1,
  }) async {
    final url = '$baseUrl/top-headlines?'
        'country=$country&'
        'category=$category&'
        'page=$page&'
        'apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> articles = data['articles'] ?? [];
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }

  static Future<List<NewsArticle>> searchNews(String query) async {
    final url = '$baseUrl/everything?'
        'q=$query&'
        'language=th&'
        'sortBy=publishedAt&'
        'apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> articles = data['articles'] ?? [];
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search news: ${response.statusCode}');
    }
  }
}
```

**ขั้นตอนการเรียก News API:**
1. **API Configuration** - ตั้งค่า base URL และ API key
2. **Query Building** - สร้าง query parameters สำหรับ category และ country
3. **HTTP Request** - ส่ง GET request ไปยัง News API
4. **Response Validation** - ตรวจสอบ HTTP status code
5. **Data Extraction** - ดึงข้อมูล articles array จาก response
6. **Object Mapping** - แปลงข้อมูลเป็น NewsArticle objects
7. **Error Handling** - จัดการ network และ API errors

### 3. News State Management
```dart
class NewsProvider extends ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'general';

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchNews({String category = 'general'}) async {
    _isLoading = true;
    _error = '';
    _selectedCategory = category;
    notifyListeners();

    try {
      _articles = await NewsService.fetchNews(category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNews(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _articles = await NewsService.searchNews(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
```

**การจัดการ State ด้วย Provider Pattern:**
- **ChangeNotifier** - แจ้งเตือน UI เมื่อข้อมูลเปลี่ยนแปลง
- **Loading Management** - จัดการสถานะกำลังโหลด
- **Error Handling** - จัดเก็บและจัดการ error messages
- **Category Selection** - จัดการหมวดหมู่ข่าวที่เลือก

### 4. NewsCard Widget - Modern Design
```dart
class NewsCard extends StatelessWidget {
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.article,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            // News Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(article.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
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
                  const SizedBox(height: 12),
                  // Meta Information
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(article.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTime} นาที',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
    );
  }
}
```

**คุณสมบัติของ News Card:**
- **Modern Card Design** - rounded corners พร้อม subtle shadow
- **Aspect Ratio Image** - รูปภาพ 16:9 ที่สวยงาม
- **Category Badge** - แสดงหมวดหมู่ด้วยสีที่แตกต่างกัน
- **Typography Hierarchy** - จัดลำดับความสำคัญของข้อความ
- **Meta Information** - แสดงเวลาและระยะเวลาอ่าน
- **Overflow Handling** - จัดการข้อความยาวด้วย ellipsis

### 5. Category Filter System
```dart
class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'ทั่วไป', 'value': 'general', 'icon': Icons.public},
    {'name': 'ธุรกิจ', 'value': 'business', 'icon': Icons.business},
    {'name': 'บันเทิง', 'value': 'entertainment', 'icon': Icons.movie},
    {'name': 'สุขภาพ', 'value': 'health', 'icon': Icons.favorite},
    {'name': 'วิทยาศาสตร์', 'value': 'science', 'icon': Icons.science},
    {'name': 'กีฬา', 'value': 'sports', 'icon': Icons.sports_football},
    {'name': 'เทคโนโลยี', 'value': 'technology', 'icon': Icons.computer},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['value'];
          
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onCategorySelected(category['value']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.blue : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 6. Search Functionality
```dart
class NewsSearchDelegate extends SearchDelegate<NewsArticle?> {
  final NewsProvider newsProvider;

  NewsSearchDelegate(this.newsProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('กรุณาใส่คำค้นหา'),
      );
    }

    return FutureBuilder(
      future: newsProvider.searchNews(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.articles.isEmpty) {
              return const Center(
                child: Text('ไม่พบข่าวที่ค้นหา'),
              );
            }

            return ListView.builder(
              itemCount: provider.articles.length,
              itemBuilder: (context, index) {
                return NewsCard(article: provider.articles[index]);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'การเมือง',
      'เศรษฐกิจ',
      'โควิด',
      'การศึกษา',
      'สิ่งแวดล้อม',
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
```

## Flow การทำงาน

1. **App Launch** → KrunchieNews เริ่มต้นพร้อม Provider setup
2. **Provider Initialize** → NewsProvider เตรียมพร้อมจัดการ state
3. **Home Screen Load** → โหลดข่าวหมวดหมู่ 'general' เป็นค่าเริ่มต้น
4. **API Request** → NewsService ส่ง request ไปยัง News API
5. **Data Processing** → แปลง JSON response เป็น NewsArticle objects
6. **State Update** → Provider อัปเดต state และแจ้งเตือน UI
7. **UI Rebuild** → Consumer widgets rebuild ตาม state ใหม่
8. **News Display** → แสดง NewsCard รายการสำหรับแต่ละข่าว
9. **User Interaction** → รองรับการเปลี่ยนหมวดหมู่และค้นหา
10. **Navigation** → เปิดข่าวแบบเต็มหรือลิงก์ภายนอก

## วิธีการเรียกใช้ News API

### API Endpoint
```
GET https://newsapi.org/v2/top-headlines
GET https://newsapi.org/v2/everything
```

### Request Parameters
```
Top Headlines:
- country: รหัสประเทศ (th, us, etc.)
- category: หมวดหมู่ข่าว
- page: หน้าที่ต้องการ
- apiKey: API key จาก NewsAPI

Everything (Search):
- q: คำค้นหา
- language: ภาษา (th, en, etc.)
- sortBy: การเรียงลำดับ
- apiKey: API key
```

### Response Structure
```json
{
  "status": "ok",
  "totalResults": 38,
  "articles": [
    {
      "source": {
        "id": null,
        "name": "BBC News"
      },
      "author": "BBC News",
      "title": "ข่าวสารวันนี้",
      "description": "รายละเอียดข่าว...",
      "url": "https://www.bbc.com/news/...",
      "urlToImage": "https://ichef.bbci.co.uk/news/...",
      "publishedAt": "2023-12-10T10:30:00Z",
      "content": "เนื้อหาข่าวฉบับเต็ม..."
    }
  ]
}
```

## ข้อกำหนดระบบ

- Flutter SDK (3.0+)
- HTTP package: `http: ^1.1.0`
- Provider package: `provider: ^6.0.0`
- NewsAPI Account & API Key
- Internet permission (Android/iOS)

## คุณสมบัติเด่น

✅ **Real-time News** - ข่าวสารอัปเดตแบบ real-time จาก NewsAPI  
✅ **Category Filter** - กรองข่าวตามหมวดหมู่ที่สนใจ  
✅ **Advanced Search** - ค้นหาข่าวด้วยคำสำคัญ  
✅ **Modern UI/UX** - การออกแบบที่ทันสมัยและใช้งานง่าย  
✅ **State Management** - Provider pattern สำหรับจัดการ state  
✅ **Error Handling** - จัดการ network และ API errors  
✅ **Image Optimization** - โหลดรูปภาพพร้อม fallback  
✅ **Responsive Design** - รองรับหน้าจอขนาดต่างๆ  
✅ **Thai Localization** - รองรับภาษาไทยเต็มรูปแบบ  
✅ **Pull to Refresh** - รีเฟรชข่าวด้วยการดึงลง  
✅ **Infinite Scroll** - โหลดข่าวเพิ่มเติมแบบอัตโนมัติ  
✅ **Offline Support** - แคชข่าวสำหรับใช้งาน offline  

## การจัดการ State

แอปใช้ **Provider Pattern** ซึ่งเหมาะสำหรับ:
- การจัดการ state แบบ reactive
- การแชร์ข้อมูลระหว่าง widgets
- การจัดการ API calls และ loading states
- การจัดการ error states อย่างมีระบบ

Provider ช่วยให้การจัดการ state เป็นระเบียบและง่ายต่อการบำรุงรักษา

## การแก้ปัญหาที่พบบ่อย

### API Key Configuration
```dart
// ❌ ปัญหา: API key ไม่ถูกต้องหรือหมดอายุ
HTTP 401: Unauthorized

// ✅ วิธีแก้: ตรวจสอบ API key ที่ NewsAPI
static const String apiKey = 'your-valid-api-key';
```

### Network Error Handling
```dart
// รองรับการจัดการ network errors
try {
  final articles = await NewsService.fetchNews();
  return articles;
} on SocketException {
  throw Exception('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
} on FormatException {
  throw Exception('ข้อมูลจาก API ไม่ถูกต้อง');
} catch (e) {
  throw Exception('เกิดข้อผิดพลาด: $e');
}
```

### Image Loading Performance
```dart
// ปรับปรุงการโหลดรูปภาพสำหรับประสิทธิภาพที่ดีขึ้น
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const CircularProgressIndicator();
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.article),
    );
  },
)
```

