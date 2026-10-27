import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entities/book.dart';

class BookApi {
  static final _booksUri = Uri.parse(
    'https://6adf80838e42963c8d5e0e95.mockapi.io/books',
  );
  final http.Client _client;

  BookApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Book>> fetchBooks() async {
    final response = await _client
        .get(_booksUri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки: статус ${response.statusCode}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Book> createBook(Book book) async {
    final response = await _client
        .post(
          _booksUri,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(book.toJson()),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 201) {
      throw Exception('Ошибка добавления: статус ${response.statusCode}');
    }
    return Book.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void close() => _client.close();
}
