import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/book_api.dart';
import 'domain/catalog_cubit.dart';
import 'firebase_options.dart';
import 'ui/app_theme.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/catalog_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final repository = BookApi();
  final authChanges = repository.authChanges;
  runApp(
    RepositoryProvider.value(
      value: repository,
      child: StreamBuilder(
        stream: authChanges,
        builder: (context, snapshot) => MaterialApp(
          key: ValueKey(snapshot.data?.uid),
          debugShowCheckedModeBanner: false,
          theme: AppStyle.theme,
          builder: AppStyle.frame,
          home: snapshot.hasError
              ? Scaffold(
                  body: Center(child: Text(BookApi.errorText(snapshot.error!))),
                )
              : snapshot.connectionState == ConnectionState.waiting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : snapshot.hasData
              ? BlocProvider(
                  create: (_) =>
                      CatalogCubit(repository, snapshot.data!.uid)..load(),
                  child: const CatalogScreen(),
                )
              : const LoginScreen(),
        ),
      ),
    ),
  );
}
