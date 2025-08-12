class NewsItem {
  final String title;
  final String description;
  final String source;
  final String imageUrl;
  final String publishedAt;
  final String url;

  NewsItem({
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? 'ไม่มีหัวข้อ',
      description: json['description'] ?? 'ไม่มีรายละเอียด',
      source: json['source']?['name'] ?? 'ไม่ระบุแหล่งที่มา',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }
}