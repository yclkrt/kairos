// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_easy/lingo_easy.dart';
import 'package:sporlab/core/providers/theme_provider.dart';
import 'package:sporlab/core/router/app_router.dart';
import 'package:sporlab/core/services/notification_service.dart';
import 'package:sporlab/core/theme/app_theme.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for notifications
  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Antrenman Uygulaması',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return LingoWrapper(
          defaultLocale: 'tr',
          supportedLocales: const ['en', 'tr'],
          assetsPath: 'assets/lang',
          loadingWidget: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
