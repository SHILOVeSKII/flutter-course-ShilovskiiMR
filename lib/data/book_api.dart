import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/book.dart';

class BookApi {
  CollectionReference<Map<String, dynamic>> get _books =>
      FirebaseFirestore.instance.collection('books');

  Stream<List<Book>> watchBooks() => _books.snapshots().map(
    (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
  );

  Future<void> createBook(Book book) async {
    await _books.add(book.toJson());
  }
}
