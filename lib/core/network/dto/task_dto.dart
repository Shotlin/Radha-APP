import 'package:json_annotation/json_annotation.dart';

part 'task_dto.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateTaskDto {
  const CreateTaskDto({
    required this.title,
    this.description,
    this.type,
    this.priority,
    this.storeId,
    this.assigneeId,
    this.dueDate,
    this.requiresEvidence,
  });

  final String title;
  final String? description;
  final String? type;
  final String? priority;
  final String? storeId;
  final String? assigneeId;
  final String? dueDate;
  final bool? requiresEvidence;

  Map<String, dynamic> toJson() => _$CreateTaskDtoToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateTaskDto {
  const UpdateTaskDto({
    this.title,
    this.status,
    this.assigneeId,
    this.evidenceUrl,
  });

  final String? title;
  final String? status;
  final String? assigneeId;
  final String? evidenceUrl;

  Map<String, dynamic> toJson() => _$UpdateTaskDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class TaskResponse {
  const TaskResponse({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.priority,
    this.status,
    this.assigneeId,
    this.assigneeName,
    this.dueDate,
    this.requiresEvidence,
    this.evidenceUrls,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? type;
  final String? priority;
  final String? status;
  final String? assigneeId;
  final String? assigneeName;
  final String? dueDate;
  final bool? requiresEvidence;
  final List<String>? evidenceUrls;
  final String? createdBy;
  final String? createdAt;

  factory TaskResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseFromJson(json);
}
