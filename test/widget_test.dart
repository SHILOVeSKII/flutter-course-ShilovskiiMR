import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
http.Response jsonResponse(Object data, [int status = 200]) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('Book serializes all data except server-generated id', () {
    final book = Book.fromJson(bookJson('42', 'Книга'));
    expect(book.id, '42');
    expect(book.toJson(), {...bookJson('42', 'Книга')}..remove('id'));
  });

  testWidgets('Loading, retry, likes, and filter work with server data', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final api = BookApi(
      client: MockClient((_) async {
        calls++;
        if (calls == 1) return pending.future;
        return jsonResponse([
          bookJson('42', 'Книга'),
          bookJson('43', 'Другая книга')..['coverColor'] = 'invalid',
        ]);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(http.Response('error', 500));
    await tester.pumpAndSettle();
    expect(find.text('Обновить'), findsOneWidget);
    await tester.tap(find.text('Обновить'));
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

  testWidgets('Empty titles are blocked and POST uses server id', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var posts = 0;
    final api = BookApi(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return jsonResponse([bookJson('1', 'Старая книга')]);
        }
        posts++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.containsKey('id'), isFalse);
        expect(body['title'], 'Новая книга');
        expect(request.headers['content-type'], contains('application/json'));
        return pending.future;
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
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
    pending.complete(jsonResponse(bookJson('99', 'Новая книга'), 201));
    await tester.pumpAndSettle();
    expect(posts, 1);
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

  testWidgets('Failed POST keeps title and allows retry', (tester) async {
    final api = BookApi(
      client: MockClient(
        (request) async => request.method == 'GET'
            ? jsonResponse([])
            : http.Response('error', 500),
      ),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: CatalogScreen(api: api)));
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
