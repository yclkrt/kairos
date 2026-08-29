import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';

class TrainingPlans extends ConsumerStatefulWidget {
  const TrainingPlans({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrainingPlansState();
}

class _TrainingPlansState extends ConsumerState<TrainingPlans> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppBar(title: const Text("Antrenman Planları")),
      body: const Center(child: Text("Training Plans Page")),
    );
  }
}
