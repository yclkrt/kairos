import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kairos/features/training_plans/data/training_plan_collection.dart';

void main() {
  late Isar isar;
  late Directory tempDir;

  setUp(() async {
    await Isar.initializeIsarCore(download: true);
    tempDir = Directory.systemTemp.createTempSync();
    isar = await Isar.open(
      [TrainingPlanCollectionSchema],
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Isar CRUD test for TrainingPlanCollection', () async {
    // 1. Add
    final plan = TrainingPlanCollection()
      ..planId = 'test_plan_1'
      ..name = 'Full Body'
      ..type = 'group'
      ..description = 'Full body workout'
      ..durationMinutes = 60
      ..createdAt = DateTime(2026, 1, 1);

    await isar.writeTxn(() async {
      await isar.trainingPlanCollections.put(plan);
    });

    // 2. Query
    final plans = await isar.trainingPlanCollections
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    expect(plans.length, 1);
    expect(plans.first.name, 'Full Body');
    expect(plans.first.planId, 'test_plan_1');

    // 3. Filter
    final fetched = await isar.trainingPlanCollections
        .filter()
        .planIdEqualTo('test_plan_1')
        .findFirst();
    expect(fetched, isNotNull);
    expect(fetched!.durationMinutes, 60);

    // 4. Delete
    await isar.writeTxn(() async {
      await isar.trainingPlanCollections.delete(fetched.id);
    });

    final afterDelete = await isar.trainingPlanCollections.where().findAll();
    expect(afterDelete.isEmpty, true);
  });
}
