import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/book_api.dart';
import 'entities/book.dart';

enum CatalogStatus { loading, ready, error }

class CatalogState {
  final CatalogStatus status;
  final List<Book> books;
  final Set<String> likedIds;
  final Set<String> pendingLikes;
  final bool onlyLiked;
  final bool saving;
  final String error;
  final String notice;

  const CatalogState({
    this.status = CatalogStatus.loading,
    this.books = const [],
    this.likedIds = const {},
    this.pendingLikes = const {},
    this.onlyLiked = false,
    this.saving = false,
    this.error = '',
    this.notice = '',
  });

  List<Book> get visibleBooks =>
      books.where((b) => !onlyLiked || likedIds.contains(b.id)).toList();
  int get favoriteCount => books.where((b) => likedIds.contains(b.id)).length;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Book>? books,
    Set<String>? likedIds,
    Set<String>? pendingLikes,
    bool? onlyLiked,
    bool? saving,
    String? error,
    String? notice,
  }) => CatalogState(
    status: status ?? this.status,
    books: books ?? this.books,
    likedIds: likedIds ?? this.likedIds,
    pendingLikes: pendingLikes ?? this.pendingLikes,
    onlyLiked: onlyLiked ?? this.onlyLiked,
    saving: saving ?? this.saving,
    error: error ?? this.error,
    notice: notice ?? this.notice,
  );
}

class CatalogCubit extends Cubit<CatalogState> {
  final BookApi repository;
  final String uid;
  StreamSubscription<List<Book>>? _books;
  StreamSubscription<Set<String>>? _favorites;
  int _generation = 0;

  CatalogCubit(this.repository, this.uid) : super(const CatalogState());

  Future<void> load() async {
    final generation = ++_generation;
    await _books?.cancel();
    await _favorites?.cancel();
    if (isClosed || generation != _generation) return;
    emit(state.copyWith(status: CatalogStatus.loading, error: '', notice: ''));
    var booksReady = false;
    var favoritesReady = false;
    var failed = false;
    bool active() => !isClosed && generation == _generation;
    void publish(CatalogState next) {
      if (!active()) return;
      emit(
        next.copyWith(
          status: failed
              ? CatalogStatus.error
              : booksReady && favoritesReady
              ? CatalogStatus.ready
              : CatalogStatus.loading,
        ),
      );
    }

    void onError(Object error) {
      if (!active()) return;
      failed = true;
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          error: BookApi.errorText(error),
        ),
      );
    }

    _books = repository.watchBooks().listen((books) {
      if (!active()) return;
      booksReady = true;
      publish(state.copyWith(books: List.unmodifiable(books)));
    }, onError: onError);
    _favorites = repository.watchFavorites(uid).listen((ids) {
      if (!active()) return;
      favoritesReady = true;
      publish(state.copyWith(likedIds: Set.unmodifiable(ids)));
    }, onError: onError);
  }

  void toggleFilter() => emit(state.copyWith(onlyLiked: !state.onlyLiked));

  Future<void> toggleLike(String id) async {
    if (state.pendingLikes.contains(id)) return;
    emit(state.copyWith(pendingLikes: {...state.pendingLikes, id}, notice: ''));
    try {
      await repository.setLiked(uid, id, !state.likedIds.contains(id));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(notice: BookApi.errorText(error)));
    } finally {
      if (!isClosed) {
        emit(state.copyWith(pendingLikes: {...state.pendingLikes}..remove(id)));
      }
    }
  }

  Future<bool> addBook(String title, String description) async {
    if (state.saving || title.trim().isEmpty) return false;
    emit(state.copyWith(saving: true, notice: ''));
    try {
      await repository.createBook(
        Book(
          id: '',
          title: title.trim(),
          description: description.trim(),
          author: 'Неизвестный автор',
          category: 'Без категории',
          year: DateTime.now().year,
          coverColor: '#467A55',
        ),
      );
      if (!isClosed) emit(state.copyWith(onlyLiked: false));
      return true;
    } catch (error) {
      if (!isClosed) emit(state.copyWith(notice: BookApi.errorText(error)));
      return false;
    } finally {
      if (!isClosed) emit(state.copyWith(saving: false));
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    await _books?.cancel();
    await _favorites?.cancel();
    return super.close();
  }
}
