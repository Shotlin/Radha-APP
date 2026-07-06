// Sync DTOs — projection of `/sync/*` (BE-44, idempotent batch writes).

class PendingWriteDto {
  const PendingWriteDto({
    required this.idempotencyKey,
    required this.entity,
    required this.operation,
    required this.payload,
    this.clientCreatedAt,
  });

  /// Client-generated UUID; the backend uses it to dedupe replays.
  final String idempotencyKey;

  /// Logical entity, e.g. `expiry`, `scan_item`, `task_status`.
  final String entity;

  /// `create`, `update`, `delete`, `complete`, etc.
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime? clientCreatedAt;

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'entity': entity,
    'operation': operation,
    'payload': payload,
    if (clientCreatedAt != null)
      'clientCreatedAt': clientCreatedAt!.toIso8601String(),
  };
}

class SyncBatchRequest {
  const SyncBatchRequest({required this.writes});
  final List<PendingWriteDto> writes;
  Map<String, dynamic> toJson() => {
    'writes': writes.map((w) => w.toJson()).toList(),
  };
}

class SyncBatchResultDto {
  const SyncBatchResultDto({required this.results});

  final List<SyncWriteResultDto> results;

  factory SyncBatchResultDto.fromJson(Map<String, dynamic> json) =>
      SyncBatchResultDto(
        results:
            (json['results'] as List<dynamic>?)
                ?.map(
                  (e) => SyncWriteResultDto.fromJson(e as Map<String, dynamic>),
                )
                .toList(growable: false) ??
            const [],
      );

  Map<String, dynamic> toJson() => {
    'results': results.map((r) => r.toJson()).toList(),
  };
}

class SyncWriteResultDto {
  const SyncWriteResultDto({
    required this.idempotencyKey,
    required this.status,
    this.serverId,
    this.error,
  });

  final String idempotencyKey;

  /// `applied`, `duplicate`, `failed`.
  final String status;
  final String? serverId;
  final String? error;

  factory SyncWriteResultDto.fromJson(Map<String, dynamic> json) =>
      SyncWriteResultDto(
        idempotencyKey: json['idempotencyKey'] as String,
        status: json['status'] as String,
        serverId: json['serverId'] as String?,
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'status': status,
    if (serverId != null) 'serverId': serverId,
    if (error != null) 'error': error,
  };
}
