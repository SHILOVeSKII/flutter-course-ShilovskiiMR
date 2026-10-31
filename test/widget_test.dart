import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/data/book_api.dart';
import 'package:flutter_application_1/domain/catalog_cubit.dart';
import 'package:flutter_application_1/domain/entities/book.dart';
import 'package:flutter_application_1/ui/screens/catalog_screen.dart';
import 'package:flutter_application_1/ui/app_theme.dart';
import 'package:flutter_application_1/ui/screens/login_screen.dart';

Book book(String id, String title) => Book(
  id: id,
  title: title,
  author: 'Автор',
  category: 'Роман',
  year: 2000,
  coverColor: '#9E3B2B',
  description: 'Полное описание',
);

class FakeBookApi extends BookApi {
  final updates = StreamController<List<Book>>.broadcast();
  final favorites = <String, StreamController<Set<String>>>{};
  final savedFavorites = <String, Set<String>>{};
  Future<void> Function(Book)? save;
  Object? likeError;
  int likeWrites = 0;
  final created = <Book>[];

  @override
  Stream<List<Book>> watchBooks() => updates.stream;
  @override
  Stream<Set<String>> watchFavorites(String uid) {
    return favorites.putIfAbsent(uid, () {
      late final StreamController<Set<String>> controller;
      controller = StreamController<Set<String>>.broadcast(
        onListen: () {
          scheduleMicrotask(() => controller.add({...?savedFavorites[uid]}));
        },
      );
      return controller;
    }).stream;
  }

  @override
  Future<void> setLiked(String uid, String bookId, bool liked) async {
    likeWrites++;
    if (likeError != null) throw likeError!;
    final ids = {...?savedFavorites[uid]};
    liked ? ids.add(bookId) : ids.remove(bookId);
    savedFavorites[uid] = ids;
    favorites[uid]?.add(ids);
  }

  @override
  Future<void> createBook(Book value) async {
    created.add(value);
    await save?.call(value);
  }

  @override
  Future<void> signIn(String email, String password) async =>
      throw FirebaseAuthException(code: 'invalid-credential');
  @override
  Future<void> register(String email, String password) async =>
      throw FirebaseAuthException(
        code: password.length < 6 ? 'weak-password' : 'email-already-in-use',
      );

  Future<void> dispose() async {
    await updates.close();
    for (final controller in favorites.values) {
      await controller.close();
    }
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

Future<CatalogCubit> mount(WidgetTester tester, FakeBookApi api) async {
  final cubit = CatalogCubit(api, 'user1');
  await cubit.load();
  addTearDown(() async {
    await cubit.close();
    await api.dispose();
  });
  await tester.pumpWidget(
    RepositoryProvider<BookApi>.value(
      value: api,
      child: MaterialApp(
        theme: AppStyle.theme,
        builder: AppStyle.frame,
        home: BlocProvider.value(value: cubit, child: const CatalogScreen()),
      ),
    ),
  );
  return cubit;
}

void main() {
  test(
    'Old documents remain compatible; description round-trips without id',
    () {
      final json = book('42', 'Книга').toJson();
      expect(json.containsKey('id'), isFalse);
      expect(
        Book.fromJson({...json, 'id': '42'}).description,
        'Полное описание',
      );
      expect(
        Book.fromJson({...json, 'id': '42'}..remove('description')).description,
        '',
      );
      expect(
        Book.fromJson({...json, 'id': '42', 'coverColor': 'bad'}).coverArgb,
        0xFF467A55,
      );
    },
  );

  test(
    'Cubit streams updates; favorites survive a new session and are per user',
    () async {
      final api = FakeBookApi();
      var cubit = CatalogCubit(api, 'user1');
      await cubit.load();
      expect(cubit.state.status, CatalogStatus.loading);
      api.updates.add([book('1', 'Книга')]);
      await flush();
      expect(cubit.state.status, CatalogStatus.ready);
      api.updates.add([book('1', 'Книга'), book('2', 'Другая')]);
      await flush();
      expect(cubit.state.books.length, 2);
      cubit.toggleFilter();
      expect(cubit.state.visibleBooks, isEmpty);
      await cubit.toggleLike('1');
      await flush();
      expect(cubit.state.visibleBooks.single.id, '1');
      await cubit.close();
      expect(api.updates.hasListener, isFalse);
      cubit = CatalogCubit(api, 'user1');
      await cubit.load();
      await flush();
      expect(cubit.state.likedIds, {'1'});
      await cubit.close();
      cubit = CatalogCubit(api, 'user2');
      await cubit.load();
      await flush();
      expect(cubit.state.likedIds, isEmpty);
      await cubit.close();
      await api.dispose();
    },
  );

  test(
    'Failed favorite write reports error without changing saved likes',
    () async {
      final api = FakeBookApi()
        ..likeError = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
      final cubit = CatalogCubit(api, 'user1');
      await cubit.load();
      await cubit.toggleLike('1');
      expect(cubit.state.notice, contains('Нет доступа'));
      expect(cubit.state.likedIds, isEmpty);
      expect(cubit.state.pendingLikes, isEmpty);
      await cubit.close();
      await api.dispose();
    },
  );

  testWidgets('Loading, friendly error, reload and empty filter', (
    tester,
  ) async {
    final api = FakeBookApi();
    final cubit = await mount(tester, api);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    api.updates.addError(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Проверьте интернет'), findsOneWidget);
    await tester.tap(find.text('Обновить'));
    await tester.runAsync(flush);
    await tester.pump();
    expect(cubit.state.status, CatalogStatus.loading);
    expect(api.updates.hasListener, isTrue);
    api.updates.add([book('1', 'Книга')]);
    await tester.pumpAndSettle();
    expect(find.text('Книга'), findsOneWidget);
    await tester.tap(find.text('Только избранные'));
    await tester.pumpAndSettle();
    expect(find.text('В избранном пока пусто'), findsOneWidget);
  });

  testWidgets('Detail and list share the same favorite state', (tester) async {
    final api = FakeBookApi();
    await mount(tester, api);
    api.updates.add([book('1', 'Книга')]);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('В избранное'));
    await tester.pumpAndSettle();
    expect(find.textContaining('В избранном: 1'), findsOneWidget);
    expect(find.text('О книге'), findsNothing);
    await tester.tap(find.text('Книга'));
    await tester.pumpAndSettle();
    expect(find.text('Полное описание'), findsOneWidget);
    await tester.tap(find.byTooltip('Убрать из избранного'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('В избранном: 0'), findsOneWidget);
  });

  testWidgets(
    'Add dialog validates, prevents duplicate sends, and awaits stream',
    (tester) async {
      final api = FakeBookApi();
      final pending = Completer<void>();
      api.save = (_) => pending.future;
      await mount(tester, api);
      api.updates.add([]);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Добавить книгу'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отправить'));
      await tester.pumpAndSettle();
      expect(find.text('Введите название книги'), findsOneWidget);
      expect(api.created, isEmpty);
      await tester.enterText(
        find.byType(TextFormField).first,
        '  Новая книга  ',
      );
      await tester.enterText(find.byType(TextFormField).last, 'Описание');
      await tester.tap(find.text('Отправить'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      pending.complete();
      await tester.pumpAndSettle();
      expect(api.created.single.title, 'Новая книга');
      expect(api.created.single.description, 'Описание');
      expect(find.text('Новая книга'), findsNothing);
      api.updates.add([book('99', 'Новая книга')]);
      await tester.pumpAndSettle();
      expect(find.text('Новая книга'), findsOneWidget);
    },
  );

  testWidgets('Failed add keeps the dialog and title for retry', (
    tester,
  ) async {
    final api = FakeBookApi()
      ..save = (_) async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
    await mount(tester, api);
    api.updates.add([]);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Добавить книгу'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Сохранить название',
    );
    await tester.tap(find.text('Отправить'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Сохранить название'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'Login and registration show clear messages and original error codes',
    (tester) async {
      final api = FakeBookApi();
      addTearDown(api.dispose);
      await tester.pumpWidget(
        RepositoryProvider<BookApi>.value(
          value: api,
          child: MaterialApp(
            theme: AppStyle.theme,
            builder: AppStyle.frame,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'test1@test.com');
      await tester.enterText(find.byType(TextField).last, '123');
      await tester.ensureVisible(find.text('Зарегистрироваться'));
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Пароль слишком короткий'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'valid-password');
      await tester.ensureVisible(find.text('Зарегистрироваться'));
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();
      expect(find.textContaining('email-already-in-use'), findsOneWidget);
      await tester.ensureVisible(find.text('Уже есть аккаунт? Войти'));
      await tester.tap(find.text('Уже есть аккаунт? Войти'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Войти'));
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Неверный email или пароль'), findsOneWidget);
      expect(find.textContaining('invalid-credential'), findsOneWidget);
    },
  );
}
