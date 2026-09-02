import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kairos/features/training_plans/data/training_plan_collection.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TrainingPlanCollectionSchema], // Schemaları doğrudan ver
      directory: dir.path,
      name: 'kairos_training_plans',
    );
    return _isar!;
  }

  // ===== CRUD Operations =====

  static Future<List<TrainingPlanCollection>> getAllPlans() async {
    final isar = await instance;
    return await isar.txn(() async {
      return await isar.trainingPlanCollections
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    });
  }

  static Future<TrainingPlanCollection?> getPlanById(String planId) async {
    final isar = await instance;
    return await isar.txn(() async {
      return await isar.trainingPlanCollections
          .filter()
          .planIdEqualTo(planId)
          .findFirst();
    });
  }

  static Future<void> addPlan(TrainingPlanCollection plan) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.trainingPlanCollections.put(plan);
    });
  }

  static Future<void> deletePlan(String planId) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      final plan = await isar.trainingPlanCollections
          .filter()
          .planIdEqualTo(planId)
          .findFirst();
      if (plan != null) {
        await isar.trainingPlanCollections.delete(plan.id);
      }
    });
  }

  static Future<void> clearAll() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.trainingPlanCollections.clear();
    });
  }
}

// ===== Riverpod Provider =====
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());
