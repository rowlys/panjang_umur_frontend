import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables before initializing the app
  await dotenv.load(fileName: ".env");

  // Wrap the app in ProviderScope for state management
  runApp(const ProviderScope(child: PanjangUmurApp()));
}

class PanjangUmurApp extends StatelessWidget {
  const PanjangUmurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panjang Umur',
      theme: ThemeData.light(),
      // Temporarily point to a placeholder until Auth is built
      home: const Scaffold(
        body: Center(
          child: Text('Panjang Umur Initialized'),
        ),
      ),
    );
  }
}