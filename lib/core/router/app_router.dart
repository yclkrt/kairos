import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/features/dashboard/presentation/dashboard_page.dart';
import 'package:kairos/features/stopwatch/presentation/stopwatch_page.dart';
import 'package:kairos/features/training_plans/presentation/training_plan_detail.dart';
import 'package:kairos/features/training_plans/presentation/training_plans.dart';

class Routes {
  static const String stopwatch = '/stopwatch';
  static const String trainingPlans = '/training-plans';
  static const String dashboard = '/dashboard';
  static const String trainingPlanDetail = '/training-plan-detail';

  static String trainingPlanDetailWithId(String id) => '/training-plan-detail/$id';
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
      GoRoute(
        path: '${Routes.trainingPlanDetail}/:id',
        name: 'training-plan-detail',
        builder: (context, state) {
          final planId = state.pathParameters['id']!;
          return TrainingPlanDetail(planId: planId);
        },
      ),
    ],
  ),
);
