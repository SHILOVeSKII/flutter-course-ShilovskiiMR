import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final List<Map<String, dynamic>> books = const [
    {'title': 'Мастер и Маргарита', 'author': 'Михаил Булгаков', 'year': '1967', 'tags': ['Роман', 'Классика'], 'color': Color(0xFFB53A2D), 'isFavorite': true},
    {'title': 'Пикник на обочине', 'author': 'Аркадий и Борис Стругацкие', 'year': '1972', 'tags': ['Фантастика'], 'color': Color(0xFF266B6E), 'isFavorite': false},
    {'title': '1984', 'author': 'Джордж Оруэлл', 'year': '1949', 'tags': ['Антиутопия', 'Классика'], 'color': Color(0xFF2D4A7A), 'isFavorite': false},
    {'title': 'Маленький принц', 'author': 'Антуан де Сент-Экзюпери', 'year': '1943', 'tags': ['Сказка'], 'color': Color(0xFFC58F26), 'isFavorite': true},
    {'title': 'Над пропастью во ржи', 'author': 'Джером Сэлинджер', 'year': '1951', 'tags': ['Роман'], 'color': Color(0xFF67437C), 'isFavorite': false},
    {'title': 'Преступление и наказание', 'author': 'Федор Достоевский', 'year': '1866', 'tags': ['Роман', 'Классика'], 'color': Color(0xFF3B5E40), 'isFavorite': true},
    {'title': 'Три товарища', 'author': 'Эрих Мария Ремарк', 'year': '1936', 'tags': ['Роман'], 'color': Color(0xFF8C4A4A), 'isFavorite': false},
    {'title': 'Дюна', 'author': 'Фрэнк Герберт', 'year': '1965', 'tags': ['Фантастика', 'Приключения'], 'color': Color(0xFFB8860B), 'isFavorite': true},
    {'title': 'Шантарам', 'author': 'Грегори Дэвид Робертс', 'year': '2003', 'tags': ['Роман', 'Приключения'], 'color': Color(0xFF1E4D6B), 'isFavorite': false},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Каталог книг',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return _buildCard(books[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 80,
              height: 110,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: book['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Center(
                    child: Text(
                      book['title'].substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: book['isFavorite'] ? Colors.red : Colors.grey[400],
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book['author']} · ${book['year']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (book['tags'] as List<String>)
                        .map((tag) => _buildTag(tag))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E8EC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4A6572),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}