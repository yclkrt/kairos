import 'package:isar/isar.dart';

part 'training_plan_collection.g.dart';

@Collection()
class TrainingPlanCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? planId;

  String? name;

  String? type;

  String? description;

  int? durationMinutes;

  DateTime? createdAt;
}
