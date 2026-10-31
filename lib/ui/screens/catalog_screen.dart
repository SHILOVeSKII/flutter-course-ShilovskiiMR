import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/book_api.dart';
import '../../domain/catalog_cubit.dart';
import '../widgets/book_card.dart';
import '../app_theme.dart';
import 'add_book_dialog.dart';
import 'book_details_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await context.read<BookApi>().signOut();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(BookApi.errorText(error))));
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<CatalogCubit, CatalogState>(
    listenWhen: (before, after) =>
        before.notice != after.notice && after.notice.isNotEmpty,
    listener: (context, state) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.notice))),
    child: BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final cubit = context.read<CatalogCubit>();
        final busy = state.saving || state.pendingLikes.isNotEmpty;
        final books = state.visibleBooks;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Каталог книг',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  state.status == CatalogStatus.loading
                                      ? 'Загружаем...'
                                      : 'В каталоге: ${state.books.length} · В избранном: ${state.favoriteCount}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppStyle.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RoundIconButton(
                            icon: Icons.logout_outlined,
                            tooltip: 'Выйти',
                            onPressed: busy ? null : () => _signOut(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilterChip(
                        label: const Text('Только избранные'),
                        selected: state.onlyLiked,
                        showCheckmark: false,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: state.onlyLiked ? Colors.white : AppStyle.ink,
                        ),
                        avatar: Icon(
                          state.onlyLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 15,
                          color: state.onlyLiked
                              ? Colors.white
                              : AppStyle.muted,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppStyle.accent,
                        side: BorderSide(
                          color: state.onlyLiked
                              ? AppStyle.accent
                              : AppStyle.line,
                        ),
                        shape: const StadiumBorder(),
                        onSelected: (_) => cubit.toggleFilter(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    CatalogStatus.loading => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Загружаем каталог...',
                            style: TextStyle(color: AppStyle.muted),
                          ),
                        ],
                      ),
                    ),
                    CatalogStatus.error => Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 36,
                              color: AppStyle.muted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Не удалось загрузить каталог',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(state.error, textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: cubit.load,
                              child: const Text('Обновить'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CatalogStatus.ready =>
                      books.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 88,
                                      height: 88,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        state.onlyLiked
                                            ? Icons.favorite_border
                                            : Icons.menu_book_outlined,
                                        size: 34,
                                        color: AppStyle.muted.withValues(
                                          alpha: 0.65,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.onlyLiked
                                          ? 'В избранном пока пусто'
                                          : 'Книг пока нет',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      state.onlyLiked
                                          ? 'Нажмите на сердечко на карточке, чтобы сохранить книгу в избранное'
                                          : 'Добавьте первую книгу в каталог.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppStyle.muted,
                                      ),
                                    ),
                                    if (state.onlyLiked)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 28),
                                        child: OutlinedButton(
                                          onPressed: cubit.toggleFilter,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppStyle.ink,
                                            minimumSize: const Size(220, 52),
                                            side: const BorderSide(
                                              color: AppStyle.line,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Показать все книги',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: cubit.load,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  88,
                                ),
                                itemCount: books.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return BookCard(
                                    key: ValueKey(book.id),
                                    book: book,
                                    isLiked: state.likedIds.contains(book.id),
                                    onLikeTap: () => cubit.toggleLike(book.id),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => BlocProvider.value(
                                          value: cubit,
                                          child: BookDetailsScreen(book: book),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: state.status == CatalogStatus.loading
              ? null
              : FloatingActionButton(
                  onPressed: state.saving
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const AddBookDialog(),
                          ),
                        ),
                  tooltip: 'Добавить книгу',
                  child: const Icon(Icons.add, size: 28),
                ),
        );
      },
    ),
  );
}
