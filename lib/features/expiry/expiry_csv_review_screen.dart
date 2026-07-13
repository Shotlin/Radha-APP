import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../core/network/dto/product_dto.dart';
import '../../core/network/dto/product_lookup_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../core/router/app_router.dart';
import '../../design/tokens.dart';
import 'expiry_csv_row.dart';

enum _RowOutcomeKind { synced, queuedOffline, failed }

class _RowOutcome {
  const _RowOutcome(this.kind, {this.message});
  final _RowOutcomeKind kind;
  final String? message;
}

/// Review + save screen for a parsed bulk expiry-import CSV. Reached from
/// `expiry_create_screen.dart`'s "Import from CSV" action with the parsed
/// [rows] passed via GoRouter `extra`.
///
/// Invalid rows (per `ExpiryCsvParser`) are shown but never saved — the
/// user fixes their CSV file and re-imports rather than editing in-app
/// (decided with the user: simpler, ships faster than inline row editing).
class ExpiryCsvReviewScreen extends ConsumerStatefulWidget {
  const ExpiryCsvReviewScreen({super.key, required this.rows});

  final List<ExpiryCsvRow> rows;

  @override
  ConsumerState<ExpiryCsvReviewScreen> createState() => _ExpiryCsvReviewScreenState();
}

class _ExpiryCsvReviewScreenState extends ConsumerState<ExpiryCsvReviewScreen> {
  bool _saving = false;
  int _savedCount = 0;
  Map<int, _RowOutcome>? _outcomes;

  List<ExpiryCsvRow> get _validRows => widget.rows.where((r) => r.isValid).toList();
  int get _invalidCount => widget.rows.length - _validRows.length;

  List<List<String>> _chunk(List<String> items, int size) {
    final out = <List<String>>[];
    for (var i = 0; i < items.length; i += size) {
      out.add(items.sublist(i, i + size > items.length ? items.length : i + size));
    }
    return out;
  }

  Future<void> _save() async {
    final validRows = _validRows;
    if (validRows.isEmpty || _saving) return;

    final storeId = ref.read(currentUserProvider)?.selectedStoreId ?? '';
    final api = ref.read(apiClientProvider);
    final eanToProductId = <String, String>{};
    final eanToError = <String, String>{};

    setState(() {
      _saving = true;
      _savedCount = 0;
    });

    // 1. Batch-resolve distinct EANs already in the catalog, chunked to the
    //    server's cap of 50 per call.
    final distinctEans = validRows.map((r) => r.ean).toSet().toList();
    for (final chunk in _chunk(distinctEans, 50)) {
      try {
        final result = await api.lookupProductsBatch(ProductLookupBatchDto(eans: chunk));
        for (final ean in chunk) {
          final hit = result[ean];
          if (hit != null && hit.found && hit.product != null) {
            eanToProductId[ean] = hit.product!.id;
          }
        }
      } catch (_) {
        // Best-effort — unresolved EANs fall through to the per-EAN
        // create-product step below, which will surface any real failure.
      }
    }

    // 2. Create a catalog stub for each EAN still unresolved — once per
    //    EAN, not once per row, since the same product commonly repeats
    //    across multiple batch/expiry rows in a real stock CSV.
    final unresolved = distinctEans.where((e) => !eanToProductId.containsKey(e));
    for (final ean in unresolved) {
      final row = validRows.firstWhere((r) => r.ean == ean);
      try {
        final created = await api.createProduct(
          CreateProductDto(name: row.productName, ean: ean),
        );
        eanToProductId[ean] = created.id;
      } on DioException catch (e) {
        // Retrofit rethrows a plain DioException — the typed ApiException
        // subclass ErrorInterceptor produced lives in e.error, not as the
        // caught exception's own runtime type, so it must be checked here
        // rather than via separate `on ForbiddenException`/`on
        // ConflictException` catch clauses (which would never match).
        final inner = e.error;
        if (inner is ForbiddenException) {
          eanToError[ean] = 'Product not in catalog — ask your manager to add it first.';
        } else if (inner is ConflictException) {
          // Raced with another creation of the same EAN between lookup and
          // create — resolve it via the single-EAN lookup instead of failing.
          try {
            final retry = await api.getProductLookup(ean, includeNutrition: false);
            if (retry.found && retry.product != null) {
              eanToProductId[ean] = retry.product!.id;
            } else {
              eanToError[ean] = 'Could not resolve this product — try again.';
            }
          } catch (_) {
            eanToError[ean] = 'Could not resolve this product — try again.';
          }
        } else {
          eanToError[ean] = inner is ApiException && inner.message.isNotEmpty
              ? inner.message
              : 'Failed to register product — try again.';
        }
      } catch (_) {
        eanToError[ean] = 'Failed to register product — try again.';
      }
    }

    // 3. Sequentially save each row via the same offline-first path the
    //    single-item wizard uses. Unlike that wizard, a failed row here
    //    does not abort the loop — every row gets its own outcome so one
    //    bad row can't discard the rest of a good import.
    final outcomes = <int, _RowOutcome>{};
    for (final row in validRows) {
      final productId = eanToProductId[row.ean];
      if (productId == null) {
        outcomes[row.rowNumber] = _RowOutcome(
          _RowOutcomeKind.failed,
          message: eanToError[row.ean] ?? 'Product could not be resolved.',
        );
      } else {
        try {
          final dto = CreateExpiryDto(
            productId: productId,
            storeId: storeId,
            expiryDate: row.expiryDate!.toIso8601String().split('T').first,
            manufactureDate: row.manufactureDate?.toIso8601String().split('T').first,
            batchNumber: row.batchNumber,
            quantity: row.quantity,
            shelfLocation: row.shelfLocation,
          );
          final result = await ref.read(syncServiceProvider).enqueue<void>(
                endpoint: '/api/v1/expiry-records',
                method: 'POST',
                body: dto.toJson(),
                idempotencyKey: const Uuid().v4(),
              );
          outcomes[row.rowNumber] = _RowOutcome(
            result.synced ? _RowOutcomeKind.synced : _RowOutcomeKind.queuedOffline,
          );
        } on DioException catch (e) {
          // Same reasoning as the create-product handling above: the typed
          // ApiException lives in e.error, not as the thrown type itself.
          final inner = e.error;
          outcomes[row.rowNumber] = _RowOutcome(
            _RowOutcomeKind.failed,
            message: inner is ApiException && inner.message.isNotEmpty
                ? inner.message
                : 'Failed to save.',
          );
        } catch (_) {
          outcomes[row.rowNumber] = _RowOutcome(_RowOutcomeKind.failed, message: 'Failed to save.');
        }
      }
      if (!mounted) return;
      setState(() => _savedCount++);
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _outcomes = outcomes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validCount = _validRows.length;
    final done = _outcomes != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Review Import',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (!done)
            TextButton(
              onPressed: (_saving || validCount == 0) ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save'),
            )
          else
            TextButton(
              onPressed: () => context.go(AppRoute.expiry),
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          _SummaryBanner(
            totalRows: widget.rows.length,
            validCount: validCount,
            invalidCount: _invalidCount,
          ),
          if (_saving || done)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space16,
                vertical: RadhaSpacing.space8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: validCount == 0 ? 0 : _savedCount / validCount,
                    color: RadhaColors.primary,
                  ),
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    done
                        ? _resultsSummary()
                        : 'Saving $_savedCount / $validCount…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RadhaSpacing.space16,
                RadhaSpacing.space8,
                RadhaSpacing.space16,
                RadhaSpacing.space24,
              ),
              itemCount: widget.rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space8),
              itemBuilder: (context, index) {
                final row = widget.rows[index];
                return _CsvRowTile(row: row, outcome: _outcomes?[row.rowNumber]);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _resultsSummary() {
    final outcomes = _outcomes!.values;
    final synced = outcomes.where((o) => o.kind == _RowOutcomeKind.synced).length;
    final queued = outcomes.where((o) => o.kind == _RowOutcomeKind.queuedOffline).length;
    final failed = outcomes.where((o) => o.kind == _RowOutcomeKind.failed).length;
    final parts = <String>[];
    if (synced > 0) parts.add('$synced saved');
    if (queued > 0) parts.add('$queued queued offline');
    if (failed > 0) parts.add('$failed failed');
    return parts.isEmpty ? 'Nothing to save.' : parts.join(' · ');
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalRows,
    required this.validCount,
    required this.invalidCount,
  });

  final int totalRows;
  final int validCount;
  final int invalidCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(RadhaSpacing.space16),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invalidCount == 0
                ? '$totalRows of $totalRows rows valid'
                : '$validCount of $totalRows rows valid — $invalidCount skipped',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (invalidCount > 0) ...[
            const SizedBox(height: RadhaSpacing.space4),
            Text(
              'Skipped rows are shown below in red with the reason. Fix your CSV file and re-import to include them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CsvRowTile extends StatelessWidget {
  const _CsvRowTile({required this.row, this.outcome});

  final ExpiryCsvRow row;
  final _RowOutcome? outcome;

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  (Color, IconData)? _outcomeVisual() {
    final o = outcome;
    if (o == null) return null;
    return switch (o.kind) {
      _RowOutcomeKind.synced => (RadhaColors.success, Icons.check_circle_outline),
      _RowOutcomeKind.queuedOffline => (RadhaColors.warning, Icons.cloud_queue_rounded),
      _RowOutcomeKind.failed => (RadhaColors.danger, Icons.error_outline_rounded),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invalid = !row.isValid;
    final visual = _outcomeVisual();

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: invalid
            ? RadhaColors.danger.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(
          color: invalid ? RadhaColors.danger.withValues(alpha: 0.4) : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.productName.isEmpty ? '(no name)' : row.productName,
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RadhaSpacing.space2),
                Text(
                  'EAN ${row.ean.isEmpty ? '—' : row.ean} · Exp ${_fmtDate(row.expiryDate)}'
                  '${row.shelfLocation != null ? ' · ${row.shelfLocation}' : ''}'
                  '${row.batchNumber != null ? ' · Batch ${row.batchNumber}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invalid && row.errorReason != null) ...[
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    row.errorReason!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RadhaColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (outcome?.message != null) ...[
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    outcome!.message!,
                    style: theme.textTheme.bodySmall?.copyWith(color: RadhaColors.danger),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          if (visual != null)
            Icon(visual.$2, color: visual.$1, size: 20)
          else if (invalid)
            const Icon(Icons.block_rounded, color: RadhaColors.danger, size: 20),
        ],
      ),
    );
  }
}
