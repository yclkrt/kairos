import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Stopwatch Page")));
  }
}
