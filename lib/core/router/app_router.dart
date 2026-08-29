import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/features/dashboard/presentation/dashboard_page.dart';
import 'package:kairos/features/stopwatch/presentation/stopwatch_page.dart';
import 'package:kairos/features/training_plans/presentation/training_plans.dart';

class Routes {
  static const String stopwatch = '/stopwatch';
  static const String trainingPlans = '/training-plans';
  static const String dashboard = '/dashboard';

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
    initialLocation: Routes.dashboard,
    routes: [
      GoRoute(
        path: Routes.stopwatch,
        name: 'stopwatch',
        builder: (context, state) => const StopwatchPage(),
      ),
      GoRoute(
        path: Routes.trainingPlans,
        name: 'training-plans',
        builder: (context, state) => const TrainingPlans(),
      ),
      GoRoute(
        path: Routes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  ),
);
