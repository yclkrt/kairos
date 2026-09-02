import 'dart:convert';
import 'dart:typed_data';
import 'package:xxh3/xxh3.dart';

void main() {
  xxh3(Uint8List.fromList(utf8.encode('TrainingPlanCollection')));
  xxh3(Uint8List.fromList(utf8.encode('planId')));
}
