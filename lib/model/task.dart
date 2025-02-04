import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task(
      {int? id,
      required String title,
      required String description,
      required int isDone,
      String? date,
      String? startTime,
      String? endTime,
      int? color,
      int? remind,
      String? repeat,
      String? completedAt,
      String? createdAt,
      String? updatedAt}) = _Task;

  factory Task.fromJson(Map<String, Object?> json) => _$TaskFromJson(json);
}
