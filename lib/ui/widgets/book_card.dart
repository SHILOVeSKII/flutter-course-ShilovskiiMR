import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const BookCard({
    super.key,
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    final hex = book.coverColor.replaceFirst(RegExp(r'^#'), '');
    final colorValue = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)
        ? int.parse(hex, radix: 16)
        : 0x467A55;
    final coverColor = Color(0xFF000000 | colorValue);
    final categoryIcon = switch (book.category) {
      'Роман' => Icons.menu_book,
      'Фантастика' => Icons.auto_awesome,
      'Антиутопия' => Icons.visibility,
      'Сказка' => Icons.public,
      'Фэнтези' => Icons.auto_fix_high,
      'Пример' => Icons.text_fields,
      _ => Icons.menu_book,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              height: 108,
              child: Stack(
                children: [
                  Container(
                    width: 78,
                    height: 108,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: coverColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.letter,
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: onLikeTap,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(categoryIcon, size: 18, color: coverColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${book.author} • ${book.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: coverColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(color: coverColor, fontSize: 12),
                    ),
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
