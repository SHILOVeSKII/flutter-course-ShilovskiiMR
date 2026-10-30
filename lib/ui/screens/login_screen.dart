import 'package:firebase_auth/firebase_auth.dart';
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
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({bool register = false}) async {
    if (_busy) return;
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
      final auth = FirebaseAuth.instance;
      if (register) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: _password.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.code);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Вход в каталог')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _email,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                enabled: !_busy,
                obscureText: true,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, semanticsLabel: 'Ошибка: $_error'),
                ),
              const SizedBox(height: 12),
              if (_busy) const Center(child: CircularProgressIndicator()),
              FilledButton(
                onPressed: _busy ? null : () => _submit(),
                child: const Text('Войти'),
              ),
              TextButton(
                onPressed: _busy ? null : () => _submit(register: true),
                child: const Text('Зарегистрироваться'),
              ),
              const Text(
                'Для регистрации используйте test1@test.com (или test2@test.com).',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
