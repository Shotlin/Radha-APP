import 'package:json_annotation/json_annotation.dart';

import 'staff_dto.dart';

part 'task_dto.g.dart';

/// Task type. Values match the backend's `TASK_TYPES` enum exactly
/// (`tasks.dto.ts`) — the app previously used a completely different,
/// unvalidated vocabulary (`ean_audit`, `display_verification`, ...) that
/// failed every create request's Zod validation.
const List<String> kTaskTypes = [
  'expiry-check',
  'shelf-audit',
  'inventory-count',
  'price-update',
  'cleaning',
  'restock',
  'training',
  'maintenance',
  'other',
];

String taskTypeLabel(String type) {
  switch (type) {
    case 'expiry-check':
      return 'Expiry check';
    case 'shelf-audit':
      return 'Shelf audit';
    case 'inventory-count':
      return 'Inventory count';
    case 'price-update':
      return 'Price update';
    case 'cleaning':
      return 'Cleaning';
    case 'restock':
      return 'Restock';
    case 'training':
      return 'Training';
    case 'maintenance':
      return 'Maintenance';
    default:
      return 'Other';
  }
}

/// `POST /api/v1/tasks` request body. Mirrors `CreateTaskSchema`
/// (`tasks.dto.ts`) for the fields the Create Task screen actually
/// collects — `assigneeIds` is a required, non-empty array (the backend
/// has no concept of an unassigned task at creation time), not the
/// singular free-text `assigneeId` this used to send.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateTaskDto {
  const CreateTaskDto({
    required this.title,
    required this.type,
    required this.storeId,
    required this.assigneeIds,
    this.description,
    this.priority,
    this.dueDate,
    this.requiresPhoto,
    this.minimumEvidenceCount,
  });

  final String title;
  final String? description;

  /// One of [kTaskTypes].
  final String type;
  final String? priority;
  final String storeId;

  /// At least one real user id — see `GET /stores/{id}/access` /
  /// `staffMembersProvider`.
  final List<String> assigneeIds;

  /// ISO-8601 date string.
  final String? dueDate;

  final bool? requiresPhoto;

  /// Backend requires >= 1 when [requiresPhoto] is true.
  final int? minimumEvidenceCount;

  Map<String, dynamic> toJson() => _$CreateTaskDtoToJson(this);
}

/// `PATCH /api/v1/tasks/{id}` request body. Mirrors `UpdateTaskSchema` —
/// note there is deliberately no `status`/`assigneeId`/`evidenceUrl`
/// field here; the backend schema never accepted them (they were
/// silently stripped), which is exactly why the old Complete button
/// looked like it worked but never actually changed anything. Status
/// changes go through [ApiClient.startTask]/[ApiClient.completeTask].
@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateTaskDto {
  const UpdateTaskDto({this.title, this.description, this.priority, this.dueDate});

  final String? title;
  final String? description;
  final String? priority;
  final String? dueDate;

  Map<String, dynamic> toJson() => _$UpdateTaskDtoToJson(this);
}

/// `POST /api/v1/tasks/{id}/complete` request body. `notes` is the only
/// field the app currently collects — `evidence`/`scanSessionId` are
/// backend-supported but not yet surfaced in the UI.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CompleteTaskDto {
  const CompleteTaskDto({this.notes});

  final String? notes;

  Map<String, dynamic> toJson() => _$CompleteTaskDtoToJson(this);
}

/// `GET /api/v1/tasks` / `GET /api/v1/tasks/{id}` response. Field names
/// match the backend's `tasks` row exactly (camelCase, same as the
/// wire JSON) — see `db/schema/tasks.ts` and `TaskListItem`/
/// `TaskWithDetails` in `task.types.ts`.
class TaskResponse {
  const TaskResponse({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.priority,
    required this.status,
    this.storeId,
    this.assigneeIds,
    this.dueDate,
    this.startedAt,
    this.completedAt,
    this.createdBy,
    this.createdAt,
    this.requiresPhoto,
    this.minimumEvidenceCount,
    this.evidenceCount,
  });

  final String id;
  final String title;
  final String? description;
  final String type;
  final String priority;
  final String status;
  final String? storeId;

  /// Active primary assignees. Resolve display names via a staff-list
  /// lookup (`staffMembersProvider`) — the backend only ever returns ids.
  final List<String>? assigneeIds;

  final String? dueDate;
  final String? startedAt;
  final String? completedAt;
  final String? createdBy;
  final String? createdAt;
  final bool? requiresPhoto;
  final int? minimumEvidenceCount;

  /// Denormalised count of attached `task_evidence` rows (photos/scans/
  /// notes/videos). Present on both list and detail responses — it's a
  /// plain column on `tasks` itself, not derived from a join.
  final int? evidenceCount;

  /// Accepts BOTH shapes the server returns:
  ///   - `GET /tasks` list rows (`TaskListItem`): a flat `assigneeIds: string[]`.
  ///   - `GET /tasks/{id}` detail (`TaskWithDetails`): a richer
  ///     `assignments: [{assigneeId, role, revokedAt, ...}]` array with
  ///     no top-level `assigneeIds` at all — derived here by filtering
  ///     to active (`revokedAt == null`) primary assignments.
  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    List<String>? assigneeIds;
    final flat = json['assigneeIds'];
    if (flat is List) {
      assigneeIds = flat.whereType<String>().toList(growable: false);
    } else {
      final assignments = json['assignments'];
      if (assignments is List) {
        assigneeIds = assignments
            .whereType<Map<String, dynamic>>()
            .where((a) => a['role'] == 'primary' && a['revokedAt'] == null)
            .map((a) => a['assigneeId'] as String?)
            .whereType<String>()
            .toList(growable: false);
      }
    }
    return TaskResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      storeId: json['storeId'] as String?,
      assigneeIds: assigneeIds,
      dueDate: json['dueDate'] as String?,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String?,
      requiresPhoto: json['requiresPhoto'] as bool?,
      minimumEvidenceCount: (json['minimumEvidenceCount'] as num?)?.toInt(),
      evidenceCount: (json['evidenceCount'] as num?)?.toInt(),
    );
  }
}

/// Resolves assignee ids into display names via the store's staff list —
/// the backend never returns a name on the task itself, only ids (see
/// [TaskResponse.assigneeIds]'s doc comment). Returns null rather than a
/// raw UUID while the staff list is still loading or a match isn't found.
String? resolveTaskAssigneeLabel(
  List<String>? assigneeIds,
  List<StaffMemberResponse>? staff,
) {
  if (assigneeIds == null || assigneeIds.isEmpty || staff == null) return null;
  final names = assigneeIds
      .map((id) {
        for (final member in staff) {
          if (member.userId == id) {
            return (member.name?.isNotEmpty ?? false)
                ? member.name!
                : member.email ?? member.mobile;
          }
        }
        return null;
      })
      .whereType<String>()
      .toList(growable: false);
  return names.isEmpty ? null : names.join(', ');
}
