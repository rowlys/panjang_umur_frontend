import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: PanjangUmurApp()));
}

class PanjangUmurApp extends ConsumerWidget {
  const PanjangUmurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Panjang Umur',
      theme: AppTheme.lightTheme, // Inject the theme here
      routerConfig: router,
    );
  }
}