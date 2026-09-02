import 'package:flutter_riverpod/legacy.dart';
import 'package:kairos/features/training_plans/model/training_plan.dart';

class TrainingPlansNotifier extends StateNotifier<List<TrainingPlan>> {
  TrainingPlansNotifier() : super([]);

  void addPlan(TrainingPlan plan) {
    state = [...state, plan];
  }

  void removePlan(String id) {
    state = state.where((plan) => plan.id != id).toList();
  }
}

final trainingPlansProvider =
    StateNotifierProvider<TrainingPlansNotifier, List<TrainingPlan>>(
  (ref) => TrainingPlansNotifier(),
);
