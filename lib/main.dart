// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/router/app_router.dart';

void main() {
  runApp(
    // ProviderScope ile uygulamayı sarmalıyoruz
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter provider'ını doğrudan dinle
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Antrenman Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      // routerConfig ile GoRouter'ı bağla
      routerConfig: router,
      // Debug banner'ı kaldır
      debugShowCheckedModeBanner: false,
    );
  }
}
