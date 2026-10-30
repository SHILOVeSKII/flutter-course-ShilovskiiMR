import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/data/book_api.dart';
import 'package:flutter_application_1/domain/entities/book.dart';
import 'package:flutter_application_1/ui/screens/catalog_screen.dart';

Map<String, dynamic> bookJson(String id, String title) => {
  'id': id,
  'title': title,
  'author': 'Автор',
  'category': 'Роман',
  'year': 2000,
  'coverColor': '#9E3B2B',
};

class FakeBookApi extends BookApi {
  final updates = StreamController<List<Book>>.broadcast();
  final Future<void> Function(Book)? save;
  FakeBookApi({this.save});
  @override
  Stream<List<Book>> watchBooks() => updates.stream;
  @override
  Future<void> createBook(Book book) async => save?.call(book);
}

void main() {
  test('Book serializes all data except server-generated id', () {
    final book = Book.fromJson(bookJson('42', 'Книга'));
    expect(book.id, '42');
    expect(book.toJson(), {...bookJson('42', 'Книга')}..remove('id'));
  });

  testWidgets('Loading, retry, likes, and filter work with server data', (
    tester,
  ) async {
    final api = FakeBookApi();
    addTearDown(api.updates.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    api.updates.addError(Exception('permission-denied'));
    await tester.pumpAndSettle();
    expect(find.textContaining('permission-denied'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    api.updates.add([
      Book.fromJson(bookJson('42', 'Книга')),
      Book.fromJson(bookJson('43', 'Другая книга')..['coverColor'] = 'invalid'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Книга'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Только избранные'));
    await tester.pumpAndSettle();
    expect(find.text('Книга'), findsOneWidget);
    expect(find.text('Другая книга'), findsNothing);
    expect(find.text('В избранном: 1'), findsOneWidget);
  });

  testWidgets('Empty titles are blocked and add waits for stream update', (
    tester,
  ) async {
    final pending = Completer<void>();
    var posts = 0;
    final api = FakeBookApi(
      save: (book) async {
        posts++;
        expect(book.toJson().containsKey('id'), isFalse);
        expect(book.title, 'Новая книга');
        await pending.future;
      },
    );
    addTearDown(api.updates.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
    api.updates.add([Book.fromJson(bookJson('1', 'Старая книга'))]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отправить'));
    await tester.pump();
    expect(find.text('Введите название книги'), findsOneWidget);
    expect(posts, 0);
    await tester.enterText(find.byType(TextField), '  Новая книга  ');
    await tester.tap(find.text('Отправить'));
    await tester.pump();
    expect(find.text('Отправка…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle();
    expect(posts, 1);
    expect(find.text('Новая книга'), findsNothing);
    api.updates.add([
      Book.fromJson(bookJson('99', 'Новая книга')),
      Book.fromJson(bookJson('1', 'Старая книга')),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Новая книга'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.getTopLeft(find.text('Новая книга')).dy,
      lessThan(tester.getTopLeft(find.text('Старая книга')).dy),
    );
  });

  testWidgets('Failed add keeps title and allows retry', (tester) async {
    final api = FakeBookApi(
      save: (_) async => throw Exception('permission-denied'),
    );
    addTearDown(api.updates.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
    api.updates.add([]);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Сохранить название');
    await tester.tap(find.text('Отправить'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Сохранить название',
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
