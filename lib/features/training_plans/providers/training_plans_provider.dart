import 'package:flutter_riverpod/legacy.dart';
import 'package:kairos/features/training_plans/data/isar_service.dart';
import 'package:kairos/features/training_plans/data/training_plan_collection.dart';
import 'package:kairos/features/training_plans/model/training_plan.dart';

class TrainingPlansNotifier extends StateNotifier<List<TrainingPlan>> {
  TrainingPlansNotifier() : super([]) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final plans = await IsarService.getAllPlans();
    state = plans.map(_collectionToModel).toList();
  }

  TrainingPlan _collectionToModel(TrainingPlanCollection c) {
    return TrainingPlan(
      id: c.planId ?? '',
      name: c.name ?? '',
      type: c.type == 'personal' ? TrainingPlanType.personal : TrainingPlanType.group,
      description: c.description ?? '',
      durationMinutes: c.durationMinutes ?? 0,
      createdAt: c.createdAt ?? DateTime.now(),
    );
  }

  Future<void> addPlan(TrainingPlan plan) async {
    final collection = TrainingPlanCollection()
      ..planId = plan.id
      ..name = plan.name
      ..type = plan.type == TrainingPlanType.personal ? 'personal' : 'group'
      ..description = plan.description
      ..durationMinutes = plan.durationMinutes
      ..createdAt = plan.createdAt;

    await IsarService.addPlan(collection);
    state = [...state, plan];
  }

  Future<void> removePlan(String id) async {
    await IsarService.deletePlan(id);
    state = state.where((plan) => plan.id != id).toList();
  }

  Future<TrainingPlan?> getPlanById(String id) async {
    final collection = await IsarService.getPlanById(id);
    if (collection == null) return null;
    return _collectionToModel(collection);
  }

  Future<void> refresh() async {
    await _loadPlans();
  }
}

final trainingPlansProvider =
    StateNotifierProvider<TrainingPlansNotifier, List<TrainingPlan>>(
  (ref) => TrainingPlansNotifier(),
);
