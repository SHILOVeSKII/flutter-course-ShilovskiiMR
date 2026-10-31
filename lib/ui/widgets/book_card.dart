import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import '../app_theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D302B21),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(book.coverArgb),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        book.letter,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.48),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        tooltip: isLiked
                            ? 'Убрать из избранного'
                            : 'В избранное',
                        onPressed: onLikeTap,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(30, 30),
                          maximumSize: const Size(30, 30),
                        ),
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLiked ? AppStyle.danger : AppStyle.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${book.author} · ${book.year}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppStyle.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CategoryLabel(book.category),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
