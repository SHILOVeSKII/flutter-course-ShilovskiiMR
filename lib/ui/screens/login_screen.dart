import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/book_api.dart';
import '../app_theme.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _registering = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final register = _registering;
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    if (register && !RegExp(r'^test\d+@test\.com$').hasMatch(email)) {
      setState(() => _error = 'Используйте тестовую почту: test1@test.com');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = context.read<BookApi>();
      if (register) {
        await repository.register(email, _password.text);
      } else {
        await repository.signIn(email, _password.text);
      }
    } catch (e) {
      if (mounted) setState(() => _error = BookApi.errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchMode() => setState(() {
    _registering = !_registering;
    _error = null;
  });

  Widget _field(
    String label,
    TextEditingController controller, {
    bool password = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppStyle.muted)),
      const SizedBox(height: 6),
      Semantics(
        label: label,
        child: TextField(
          controller: controller,
          enabled: !_busy,
          obscureText: password,
          keyboardType: password
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: password
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: password ? (_) => _submit() : null,
          decoration: InputDecoration(
            errorText: _error == null
                ? null
                : password && _error!.contains('weak-password')
                ? 'Минимум 6 символов'
                : !password && _error!.contains('email-already-in-use')
                ? 'Этот email уже зарегистрирован'
                : null,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            32,
            constraints.maxHeight < 650 ? 56 : 96,
            32,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppStyle.accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _registering ? 'Регистрация' : 'Вход',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _registering
                        ? 'Создайте аккаунт — избранное будет сохраняться за вами'
                        : 'Войдите, чтобы видеть каталог и своё избранное',
                    style: const TextStyle(color: AppStyle.muted),
                  ),
                  const SizedBox(height: 26),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: AppStyle.danger,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppStyle.errorInk,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _field('Email', _email),
                  const SizedBox(height: 20),
                  _field('Пароль', _password, password: true),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_registering ? 'Зарегистрироваться' : 'Войти'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _busy ? null : _switchMode,
                    child: Text(
                      _registering
                          ? 'Уже есть аккаунт? Войти'
                          : 'Нет аккаунта? Зарегистрироваться',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
