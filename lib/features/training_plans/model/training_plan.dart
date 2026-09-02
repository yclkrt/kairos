enum TrainingPlanType {
  group,
  personal,
}

extension TrainingPlanTypeExtension on TrainingPlanType {
  String get displayName {
    switch (this) {
      case TrainingPlanType.group:
        return 'Grup Dersi';
      case TrainingPlanType.personal:
        return 'Özel Ders';
    }
  }
}

class TrainingPlan {
  final String id;
  final String name;
  final TrainingPlanType type;
  final String description;
  final int durationMinutes;
  final DateTime createdAt;

  const TrainingPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.durationMinutes,
    required this.createdAt,
  });

  TrainingPlan copyWith({
    String? id,
    String? name,
    TrainingPlanType? type,
    String? description,
    int? durationMinutes,
    DateTime? createdAt,
  }) {
    return TrainingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
