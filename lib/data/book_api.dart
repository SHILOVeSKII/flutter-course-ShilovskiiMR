import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/book.dart';

/// Repository: all Firebase access stays here, outside widgets and Cubit.
class BookApi {
  CollectionReference<Map<String, dynamic>> get _books =>
      FirebaseFirestore.instance.collection('books');

  CollectionReference<Map<String, dynamic>> _favorites(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites');

  Stream<User?> get authChanges => FirebaseAuth.instance.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Stream<List<Book>> watchBooks() async* {
    // Refresh must report a network error instead of silently using an empty cache.
    final initial = await _books
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    yield initial.docs.map(Book.fromFirestore).toList();
    yield* _books.snapshots().map(
      (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
    );
  }

  Stream<Set<String>> watchFavorites(String uid) =>
      _favorites(uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());

  Future<void> setLiked(String uid, String bookId, bool liked) async {
    final doc = _favorites(uid).doc(bookId);
    if (liked) {
      await doc.set({'liked': true}).timeout(const Duration(seconds: 15));
    } else {
      await doc.delete().timeout(const Duration(seconds: 15));
    }
  }

  Future<void> createBook(Book book) async {
    await _books.add(book.toJson()).timeout(const Duration(seconds: 15));
  }

  static String errorText(Object error) {
    if (error is TimeoutException) {
      return 'Сервер не ответил. Проверьте интернет и обновите каталог перед повторной отправкой.';
    }
    if (error is FirebaseException) {
      final message = switch (error.code) {
        'invalid-email' => 'Введите корректный email.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'Неверный email или пароль.',
        'email-already-in-use' =>
          'Этот email уже зарегистрирован. Нажмите «Войти».',
        'weak-password' =>
          'Пароль слишком короткий. Используйте не менее 6 символов.',
        'too-many-requests' => 'Слишком много попыток. Попробуйте позже.',
        'network-request-failed' || 'unavailable' || 'deadline-exceeded' =>
          'Нет связи с сервером. Проверьте интернет и повторите попытку.',
        'permission-denied' ||
        'unauthenticated' => 'Нет доступа к данным. Выйдите и войдите снова.',
        'user-disabled' => 'Аккаунт отключён.',
        _ => 'Не удалось выполнить действие. Повторите попытку.',
      };
      return '$message (${error.code})';
    }
    return 'Не удалось выполнить действие. Проверьте подключение и повторите попытку.';
  }
}
