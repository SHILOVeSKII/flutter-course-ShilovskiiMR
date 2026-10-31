import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/catalog_cubit.dart';
import '../../domain/entities/book.dart';
import '../app_theme.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppStyle.muted)),
        const SizedBox(width: 24),
        Expanded(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) {
      final current = state.books.firstWhere(
        (item) => item.id == book.id,
        orElse: () => book,
      );
      final liked = state.likedIds.contains(book.id);
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 96,
          leadingWidth: 72,
          leading: Center(
            child: RoundIconButton(
              icon: Icons.arrow_back,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: RoundIconButton(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                tooltip: liked ? 'Убрать из избранного' : 'В избранное',
                color: liked ? AppStyle.danger : AppStyle.muted,
                onPressed: state.pendingLikes.contains(book.id)
                    ? null
                    : () => context.read<CatalogCubit>().toggleLike(book.id),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(current.coverArgb),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      current.letter,
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  current.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${current.author} · ${current.year}',
                  style: const TextStyle(color: AppStyle.muted),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryLabel(current.category),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row('Автор', current.author),
                      const Divider(height: 1, color: AppStyle.line),
                      _row('Год', current.year.toString()),
                      const Divider(height: 1, color: AppStyle.line),
                      _row('Категория', current.category),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Описание',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  current.description.isEmpty
                      ? 'Описание пока не добавлено.'
                      : current.description,
                  style: const TextStyle(color: AppStyle.muted),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
