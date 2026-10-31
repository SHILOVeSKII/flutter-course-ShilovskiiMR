import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/catalog_cubit.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<CatalogCubit>();
    if (cubit.state.saving || !_form.currentState!.validate()) return;
    setState(() => _error = null);
    final saved = await cubit.addBook(_title.text, _description.text);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = cubit.state.notice);
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) => PopScope(
      canPop: !state.saving,
      child: AlertDialog(
        title: const Text('Добавить книгу'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _title,
                    enabled: !state.saving,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Введите название книги'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Название книги',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    enabled: !state.saving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: state.saving ? null : _submit,
            child: Text(state.saving ? 'Отправка…' : 'Отправить'),
          ),
        ],
      ),
    ),
  );
}
