// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateTaskDtoToJson(
  CreateTaskDto instance,
) => <String, dynamic>{
  'title': instance.title,
  if (instance.description case final value?) 'description': value,
  if (instance.type case final value?) 'type': value,
  if (instance.priority case final value?) 'priority': value,
  if (instance.storeId case final value?) 'storeId': value,
  if (instance.assigneeId case final value?) 'assigneeId': value,
  if (instance.dueDate case final value?) 'dueDate': value,
  if (instance.requiresEvidence case final value?) 'requiresEvidence': value,
};

Map<String, dynamic> _$UpdateTaskDtoToJson(UpdateTaskDto instance) =>
    <String, dynamic>{
      if (instance.title case final value?) 'title': value,
      if (instance.status case final value?) 'status': value,
      if (instance.assigneeId case final value?) 'assigneeId': value,
      if (instance.evidenceUrl case final value?) 'evidenceUrl': value,
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
