import 'package:flutter/material.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final int year;
  final Color coverColor;
  final IconData categoryIcon;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.coverColor,
    required this.categoryIcon,
  });

  String get letter => title.substring(0, 1).toUpperCase();
}

const books = <Book>[
  Book(id: 1, title: 'Мастер и Маргарита', author: 'Михаил Булгаков', category: 'Роман', year: 1967, coverColor: Color(0xFF9E3B2B), categoryIcon: Icons.menu_book),
  Book(id: 2, title: 'Пикник на обочине', author: 'Аркадий и Борис Стругацкие', category: 'Фантастика', year: 1972, coverColor: Color(0xFF317F82), categoryIcon: Icons.auto_awesome),
  Book(id: 3, title: '1984', author: 'Джордж Оруэлл', category: 'Антиутопия', year: 1949, coverColor: Color(0xFF456A9E), categoryIcon: Icons.visibility),
  Book(id: 4, title: 'Маленький принц', author: 'Антуан де Сент-Экзюпери', category: 'Сказка', year: 1943, coverColor: Color(0xFFC58A26), categoryIcon: Icons.public),
  Book(id: 5, title: 'Над пропастью во ржи', author: 'Джером Сэлинджер', category: 'Роман', year: 1951, coverColor: Color(0xFF725A7D), categoryIcon: Icons.menu_book),
  Book(id: 6, title: 'Три товарища', author: 'Эрих Мария Ремарк', category: 'Роман', year: 1936, coverColor: Color(0xFF7B4B3A), categoryIcon: Icons.groups),
  Book(id: 7, title: 'Гарри Поттер и философский камень', author: 'Дж. К. Роулинг', category: 'Фэнтези', year: 1997, coverColor: Color(0xFF5B4D8B), categoryIcon: Icons.auto_fix_high),
  Book(id: 8, title: 'Алиса в Стране чудес', author: 'Льюис Кэрролл', category: 'Сказка', year: 1865, coverColor: Color(0xFFB64A66), categoryIcon: Icons.explore),
  Book(id: 9, title: 'Очень длинное название книги для проверки переполнения текста', author: 'Учебный пример', category: 'Пример', year: 2026, coverColor: Color(0xFF467A55), categoryIcon: Icons.text_fields),
];
