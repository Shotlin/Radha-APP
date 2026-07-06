// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateTaskDtoToJson(CreateTaskDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'priority': instance.priority,
      'storeId': instance.storeId,
      'assigneeId': instance.assigneeId,
      'dueDate': instance.dueDate,
      'requiresEvidence': instance.requiresEvidence,
    };

Map<String, dynamic> _$UpdateTaskDtoToJson(UpdateTaskDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'status': instance.status,
      'assigneeId': instance.assigneeId,
      'evidenceUrl': instance.evidenceUrl,
    };

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) => TaskResponse(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  type: json['type'] as String?,
  priority: json['priority'] as String?,
  status: json['status'] as String?,
  assigneeId: json['assigneeId'] as String?,
  assigneeName: json['assigneeName'] as String?,
  dueDate: json['dueDate'] as String?,
  requiresEvidence: json['requiresEvidence'] as bool?,
  evidenceUrls: (json['evidenceUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdBy: json['createdBy'] as String?,
  createdAt: json['createdAt'] as String?,
);
