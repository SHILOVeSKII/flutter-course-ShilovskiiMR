class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final int year;

  /// Opaque cover color in #RRGGBB format.
  final String coverColor;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.coverColor,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    category: json['category'] as String,
    year: (json['year'] as num).toInt(),
    coverColor: json['coverColor'] as String,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'category': category,
    'year': year,
    'coverColor': coverColor,
  };

  String get letter =>
      title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();
}
