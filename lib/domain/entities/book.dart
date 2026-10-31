import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final int year;
  final String description;

  /// Opaque cover color in #RRGGBB format.
  final String coverColor;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    this.description = '',
    required this.coverColor,
  });

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Book.fromJson({...doc.data()!, 'id': doc.id});

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    category: json['category'] as String,
    year: (json['year'] as num).toInt(),
    description: json['description'] as String? ?? '',
    coverColor: json['coverColor'] as String,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'category': category,
    'year': year,
    'description': description,
    'coverColor': coverColor,
  };

  int get coverArgb {
    final hex = coverColor.replaceFirst(RegExp(r'^#'), '');
    return 0xFF000000 |
        (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)
            ? int.parse(hex, radix: 16)
            : 0x467A55);
  }

  String get letter =>
      title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();
}
