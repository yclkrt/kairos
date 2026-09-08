import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/features/dashboard/presentation/dashboard_page.dart';
import 'package:kairos/features/stopwatch/presentation/stopwatch_page.dart';
import 'package:kairos/features/taekwondo_scoreboard/presentation/taekwondo_scoreboard_page.dart';
import 'package:kairos/features/training_plans/presentation/training_plan_detail.dart';
import 'package:kairos/features/training_plans/presentation/training_plans.dart';
import 'package:kairos/features/training_schedule/presentation/training_schedule.dart';
import 'package:kairos/features/boxing_round/presentation/boxing_round_page.dart';

class Routes {
  static const String stopwatch = '/stopwatch';
  static const String trainingPlans = '/training-plans';
  static const String dashboard = '/dashboard';
  static const String trainingPlanDetail = '/training-plan-detail';
  static const String trainingSchedule = '/training-schedule';
  static const String taekwondoScoreboard = '/taekwondo-scoreboard';
  static const String boxingRound = '/boxing-round';

  static String trainingPlanDetailWithId(String id) =>
      '/training-plan-detail/$id';
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
      GoRoute(
        path: Routes.trainingSchedule,
        name: 'training-schedule',
        builder: (context, state) => const TrainingSchedule(),
      ),
      GoRoute(
        path: Routes.taekwondoScoreboard,
        name: 'taekwondo-scoreboard',
        builder: (context, state) => const TaekwondoScoreboardPage(),
      ),
      GoRoute(
        path: Routes.boxingRound,
        name: 'boxing-round',
        builder: (context, state) => const BoxingRoundPage(),
      ),
    ],
  ),
);
