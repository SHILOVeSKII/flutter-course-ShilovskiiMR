import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/book_api.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

class CatalogScreen extends StatefulWidget {
  final BookApi? api;

  const CatalogScreen({super.key, this.api});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final BookApi _api;
  final _titleController = TextEditingController();
  final Set<String> _likedIds = <String>{};
  late Stream<List<Book>> _booksStream;
  bool _onlyLiked = false;
  bool _sending = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? BookApi();
    _booksStream = _api.watchBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _loadBooks() => setState(() => _booksStream = _api.watchBooks());

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  Future<void> _sendBook() async {
    if (_sending) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Введите название книги');
      return;
    }
    setState(() {
      _sending = true;
      _titleError = null;
    });
    try {
      await _api.createBook(
        Book(
          id: '',
          title: title,
          author: 'Неизвестный автор',
          category: 'Без категории',
          year: DateTime.now().year,
          coverColor: '#467A55',
        ),
      );
      if (!mounted) return;
      setState(() {
        _onlyLiked = false;
        _titleController.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось подтвердить добавление. Проверьте каталог перед повторной отправкой.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _toggleLike(String id) {
    setState(() {
      if (!_likedIds.remove(id)) _likedIds.add(id);
    });
  }

  Widget _buildCatalog(AsyncSnapshot<List<Book>> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final visibleBooks = snapshot.data!
        .where((book) => !_onlyLiked || _likedIds.contains(book.id))
        .toList();
    if (visibleBooks.isEmpty) {
      return Center(
        child: Text(
          _onlyLiked
              ? 'В избранном пока нет книг'
              : 'Книг пока нет. Добавьте первую.',
        ),
      );
    }
    return ListView.separated(
      itemCount: visibleBooks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final book = visibleBooks[index];
        return BookCard(
          key: ValueKey(book.id),
          book: book,
          isLiked: _likedIds.contains(book.id),
          onLikeTap: () => _toggleLike(book.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Обновить каталог',
            onPressed: _sending ? null : _loadBooks,
            icon: const Icon(Icons.refresh),
          ),
          TextButton(
            onPressed: _sending ? null : _signOut,
            child: const Text('Выйти'),
          ),
        ],
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                enabled: !_sending,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendBook(),
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
                decoration: InputDecoration(
                  labelText: 'Название книги',
                  errorText: _titleError,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _sending ? null : _sendBook,
                  child: Text(_sending ? 'Отправка…' : 'Отправить'),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Только избранные'),
                  selected: _onlyLiked,
                  avatar: const Icon(Icons.favorite, size: 18),
                  onSelected: (value) => setState(() => _onlyLiked = value),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Book>>(
                  stream: _booksStream,
                  builder: (context, snapshot) => _buildCatalog(snapshot),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
