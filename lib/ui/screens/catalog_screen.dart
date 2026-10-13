import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = <int>{};
  bool _onlyLiked = false;

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleBooks = books
        .where((book) => !_onlyLiked || _likedIds.contains(book.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Каталог книг'),
            Text(
              'В избранном: ${_likedIds.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Только избранные'),
                selected: _onlyLiked,
                avatar: const Icon(Icons.favorite, size: 18),
                onSelected: (value) {
                  setState(() {
                    _onlyLiked = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visibleBooks.isEmpty
                  ? const Center(child: Text('Ничего не нашлось'))
                  : ListView.separated(
                      itemCount: visibleBooks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final book = visibleBooks[index];
                        return BookCard(
                          book: book,
                          isLiked: _likedIds.contains(book.id),
                          onLikeTap: () => _toggleLike(book.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
