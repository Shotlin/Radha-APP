// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateTaskDtoToJson(CreateTaskDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'type': instance.type,
      if (instance.priority case final value?) 'priority': value,
      'storeId': instance.storeId,
      'assigneeIds': instance.assigneeIds,
      if (instance.dueDate case final value?) 'dueDate': value,
      if (instance.requiresPhoto case final value?) 'requiresPhoto': value,
      if (instance.minimumEvidenceCount case final value?)
        'minimumEvidenceCount': value,
    };

Map<String, dynamic> _$UpdateTaskDtoToJson(UpdateTaskDto instance) =>
    <String, dynamic>{
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      if (instance.priority case final value?) 'priority': value,
      if (instance.dueDate case final value?) 'dueDate': value,
    };

Map<String, dynamic> _$CompleteTaskDtoToJson(CompleteTaskDto instance) =>
    <String, dynamic>{if (instance.notes case final value?) 'notes': value};
