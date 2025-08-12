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