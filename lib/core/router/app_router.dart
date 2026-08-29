import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/features/home/presentation/home_page.dart';
import 'package:kairos/features/stopwatch/presentation/stopwatch_page.dart';

class Routes {
  static const String home = '/';
  static const String stopwatch = '/stopwatch';

  /*
  // Dinamik route'lar için yardımcı metodlar
  static String productDetailWithId(String id) => '/product/$id';
  static String orderDetailWithId(String id) => '/orders/$id';
  
  // Query parameter ile arama
  static String searchWithQuery(String query) => '/search?q=$query';
  */
}

final appRouterProvider = StateProvider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.stopwatch,
        name: 'stopwatch',
        builder: (context, state) => const StopwatchPage(),
      ),
    ],
  ),
);
