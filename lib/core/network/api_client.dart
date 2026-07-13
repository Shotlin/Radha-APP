/// Retrofit-based API client for the RADHA backend.
///
/// Auth DTOs are re-exported here so existing imports remain stable.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import 'package:radha_app/core/network/dio_provider.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';
import 'package:radha_app/core/network/dto/notification_dto.dart';
import 'package:radha_app/core/network/dto/allergen_profile_dto.dart';
import 'package:radha_app/core/network/dto/auth_dto.dart';
import 'package:radha_app/core/network/dto/catalog_dto.dart';
import 'package:radha_app/core/network/dto/ean_dto.dart';
import 'package:radha_app/core/network/dto/batch_dates_dto.dart';
import 'package:radha_app/core/network/dto/expiry_dto.dart';
import 'package:radha_app/core/network/dto/grn_dto.dart';
import 'package:radha_app/core/network/dto/health_assessment_dto.dart';
import 'package:radha_app/core/network/dto/inventory_dto.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/core/network/dto/onboarding_dto.dart';
import 'package:radha_app/core/network/dto/payment_dto.dart';
import 'package:radha_app/core/network/dto/product_dto.dart';
import 'package:radha_app/core/network/dto/product_lookup_dto.dart';
import 'package:radha_app/core/network/dto/product_submission_dto.dart';
import 'package:radha_app/core/network/dto/reports_dto.dart';
import 'package:radha_app/core/network/dto/saved_product_dto.dart';
import 'package:radha_app/core/network/dto/scan_dto.dart';
import 'package:radha_app/core/network/dto/subscription_dto.dart';
import 'package:radha_app/core/network/dto/task_dto.dart';

// Re-export auth DTOs so existing imports from this file keep working.
export 'package:radha_app/core/network/dto/auth_dto.dart';
export 'package:radha_app/core/network/dto/notification_dto.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ─── Auth ───────────────────────────────────────────────────────────────
  @POST('/api/v1/auth/otp/request')
  Future<OtpRequestResponse> requestOtp(@Body() OtpRequestRequestDto body);

  @POST('/api/v1/auth/otp/verify')
  Future<LoginResponse> verifyOtp(@Body() VerifyOtpRequestDto body);

  @POST('/api/v1/auth/admin/login')
  Future<LoginResponse> adminLogin(@Body() AdminLoginRequestDto body);

  @POST('/api/v1/auth/refresh')
  Future<LoginResponse> refreshToken(@Body() RefreshTokenRequestDto body);

  @POST('/api/v1/auth/logout')
  Future<void> logout();

  @GET('/api/v1/auth/me')
  Future<MeResponse> me();

  // ─── Products ───────────────────────────────────────────────────────────
  @GET('/api/v1/products')
  Future<PaginatedProducts> getProducts({
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @GET('/api/v1/products/{id}')
  Future<ProductResponse> getProduct(@Path('id') String id);

  @POST('/api/v1/products')
  Future<ProductResponse> createProduct(@Body() CreateProductDto body);

  /// Rich lookup with real nutrition (drives the catalog product detail).
  /// Also the only real EAN-keyed product route — `/products/ean/{ean}`
  /// (formerly a separate client method here) was never implemented on the
  /// backend and 404'd unconditionally; every call site now goes through
  /// this lookup instead.
  @GET('/api/v1/products/lookup/{ean}')
  Future<ProductLookupResult> getProductLookup(
    @Path('ean') String ean, {
    @Query('includeNutrition') bool includeNutrition = true,
  });

  /// Resolves up to 50 EANs to catalog products in one round trip — used by
  /// the expiry CSV bulk import to avoid a lookup call per row. Local
  /// catalog only, no external-provider fallback for misses (unlike
  /// [getProductLookup]).
  @POST('/api/v1/products/lookup/batch')
  Future<Map<String, ProductLookupResult>> lookupProductsBatch(
    @Body() ProductLookupBatchDto body,
  );

  /// BE-12 Health Scoring — grade, score, warnings/positives, child-safety.
  /// Computes on demand if nothing is cached yet, so this never 404s for a
  /// resolvable product id.
  @GET('/api/v1/products/{productId}/health')
  Future<HealthAssessmentDto> getProductHealth(@Path('productId') String productId);

  // ─── Community product submission (BE-56 v2) ───────────────────────────
  /// Presign a submission photo upload. Response's `uploadUrl` +
  /// `uploadFields` are posted straight to S3 by
  /// `ProductSubmissionRepository` — not through this client, since the
  /// upload target is S3 itself, not the RADHA API.
  @POST('/api/v1/products/learn/presign')
  Future<SubmissionPresignResponseDto> presignSubmissionPhoto(
    @Body() SubmissionPresignRequestDto body,
  );

  @POST('/api/v1/products/learn/media/{mediaId}/confirm')
  Future<ConfirmedMediaDto> confirmSubmissionPhoto(@Path('mediaId') String mediaId);

  @POST('/api/v1/products/learn')
  Future<SubmissionResponseDto> submitProduct(@Body() SubmitProductRequestDto body);

  // ─── Consumer catalog (browse-without-scan) ──────────────────────────────
  @GET('/api/v1/catalog/categories')
  Future<List<CatalogCategory>> getCatalogCategories();

  @GET('/api/v1/catalog/products')
  Future<CatalogBrowsePage> getCatalogProducts({
    @Query('category') String? category,
    @Query('q') String? q,
    @Query('sort') String? sort,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  // ─── Scan sessions ────────────────────────────────────────────────────────
  @POST('/api/v1/scan-sessions')
  Future<ScanSessionResponse> createScanSession(
    @Body() CreateScanSessionDto body,
  );

  @GET('/api/v1/scan-sessions/active')
  Future<ScanSessionResponse> getActiveScanSession(
    @Query('storeId') String storeId,
  );

  @GET('/api/v1/scan-sessions/{id}/summary')
  Future<ScanSessionSummary> getScanSessionSummary(@Path('id') String id);

  @POST('/api/v1/scan-sessions/{id}/items')
  Future<ScanItemResultResponse> recordScanItem(
    @Path('id') String id,
    @Body() RecordScanItemDto body,
  );

  @POST('/api/v1/scan-sessions/{id}/end')
  Future<ScanSessionResponse> endScanSession(
    @Path('id') String id,
    @Body() EndScanSessionDto body,
  );

  // ─── EAN approved lists ─────────────────────────────────────────────────
  @POST('/api/v1/ean-lists/validate')
  Future<EanValidationResult> validateEan(@Body() ValidateEanDto body);

  @POST('/api/v1/ean-lists/validate/batch')
  Future<Map<String, EanValidationResult>> validateEanBatch(
    @Body() ValidateEanBatchDto body,
  );

  @GET('/api/v1/ean-lists')
  Future<List<EanListSummary>> getEanLists({
    @Query('storeId') String? storeId,
    @Query('status') String? status,
    @Query('limit') int? limit,
  });

  @POST('/api/v1/ean-lists')
  Future<EanListSummary> createEanList(@Body() CreateEanListDto body);

  @POST('/api/v1/ean-lists/{id}/import')
  Future<EanImportInitResponse> importEanListInline(
    @Path('id') String id,
    @Body() ImportEanInlineDto body,
  );

  @GET('/api/v1/ean-lists/imports/{batchId}')
  Future<EanImportStatusResponse> getEanImportStatus(
    @Path('batchId') String batchId,
  );

  // ─── Expiry ─────────────────────────────────────────────────────────────
  @POST('/api/v1/expiry-records')
  Future<ExpiryResponse> createExpiry(
    @Body() CreateExpiryDto body, {
    // Sent by the outbox on replay so duplicate network-retry writes are
    // de-duplicated server-side (Phase 8 idempotency_records table).
    @Header('Idempotency-Key') String? idempotencyKey,
  });

  @GET('/api/v1/expiry-records')
  Future<List<ExpiryResponse>> getExpiryRecords({
    @Query('limit') int? limit,
    @Query('status') String? status,
    @Query('storeId') String? storeId,
    @Query('productId') String? productId,
  });

  @GET('/api/v1/expiry-records/{id}')
  Future<ExpiryResponse> getExpiry(@Path('id') String id);

  @DELETE('/api/v1/expiry-records/{id}')
  Future<void> deleteExpiry(@Path('id') String id);

  // ─── Batch Dates (Feature B — crowd-sourced expiry by batch code) ────────
  @GET('/api/v1/products/{ean}/batches')
  Future<BatchListResponse> getProductBatches(@Path('ean') String ean);

  @GET('/api/v1/products/{ean}/batches/{batchCode}/dates')
  Future<BatchDatesResponse> getBatchDates(
    @Path('ean') String ean,
    @Path('batchCode') String batchCode,
  );

  @POST('/api/v1/products/{ean}/batches/{batchCode}/observations')
  Future<ObservationResponse> postBatchObservation(
    @Path('ean') String ean,
    @Path('batchCode') String batchCode,
    @Body() CreateObservationDto body,
  );

  // ─── Tasks ──────────────────────────────────────────────────────────────
  @POST('/api/v1/tasks')
  Future<TaskResponse> createTask(@Body() CreateTaskDto body);

  // The live `GET /tasks` route returns a bare `Task[]` — `TasksService.list`
  // has no cursor pagination, only a `limit` cap — so this is declared as a
  // flat list rather than a `{items, total, cursor}` envelope. A previous
  // `PaginatedTasks` wrapper here silently broke every Tasks-tab load: Dio
  // decodes the array, then the wrapper's `Map<String, dynamic>` cast threw
  // before the screen ever saw the data.
  @GET('/api/v1/tasks')
  Future<List<TaskResponse>> getTasks({
    @Query('limit') int? limit,
    @Query('status') String? status,
  });

  @GET('/api/v1/tasks/{id}')
  Future<TaskResponse> getTask(@Path('id') String id);

  @PATCH('/api/v1/tasks/{id}')
  Future<TaskResponse> updateTask(
    @Path('id') String id,
    @Body() UpdateTaskDto body,
  );

  @DELETE('/api/v1/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  // ─── Inventory ──────────────────────────────────────────────────────────
  @GET('/api/v1/inventory/counts')
  Future<PaginatedInventory> getInventory({
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
    @Query('storeId') String? storeId,
  });

  /// Store inventory roll-up — single cheap call returning headline counters
  /// (low-stock, expiring-soon, totals). Backs the dashboard + home KPIs.
  @GET('/api/v1/inventory/summary')
  Future<InventorySummaryResponse> getInventorySummary(
    @Query('storeId') String storeId,
  );

  @POST('/api/v1/inventory/adjust')
  Future<InventoryItemResponse> adjustStock(@Body() StockAdjustmentDto body);

  @GET('/api/v1/inventory/items/{id}')
  Future<InventoryItemResponse> getInventoryItem(@Path('id') String id);

  // ─── GRN ────────────────────────────────────────────────────────────────
  @POST('/api/v1/grn')
  Future<GrnResponse> createGrn(@Body() CreateGrnDto body);

  @GET('/api/v1/grn')
  Future<PaginatedGrns> getGrns({
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  @GET('/api/v1/grn/{id}')
  Future<GrnResponse> getGrn(@Path('id') String id);

  // ─── Store Access / Staff Management (BE-10) ──────────────────────────
  /// `POST /api/v1/stores/{storeId}/access` — invite a user to the store.
  /// Body: { mobile: string, role: 'manager' | 'staff' | 'auditor' }
  @POST('/api/v1/stores/{storeId}/access')
  Future<void> grantStoreAccess(
    @Path('storeId') String storeId,
    @Body() Map<String, dynamic> body,
  );

  /// `DELETE /api/v1/stores/{storeId}/access/{userId}` — remove a user.
  @DELETE('/api/v1/stores/{storeId}/access/{userId}')
  Future<void> revokeStoreAccess(
    @Path('storeId') String storeId,
    @Path('userId') String userId,
  );

  // ─── Subscription ──────────────────────────────────────────────────────
  /// Public plan catalogue — the only source of the real plan UUIDs that
  /// `CreateCheckoutDto.planId` requires. See `SubscriptionPlanCatalogEntry`.
  @GET('/api/v1/subscriptions/plans')
  Future<List<SubscriptionPlanCatalogEntry>> getSubscriptionPlans();

  @GET('/api/v1/subscriptions/status')
  Future<SubscriptionResponse> getSubscription();

  @POST('/api/v1/subscriptions/upgrade')
  Future<SubscriptionResponse> createSubscription(
    @Body() CreateSubscriptionDto body,
  );

  // ─── Payments (Razorpay) ───────────────────────────────────────────────
  @POST('/api/v1/payments/checkout')
  Future<CheckoutResponse> createCheckout(@Body() CreateCheckoutDto body);

  @POST('/api/v1/payments/verify')
  Future<VerifyPaymentResponse> verifyPayment(@Body() VerifyPaymentDto body);

  // ─── Onboarding (BE-34) ────────────────────────────────────────────────
  // Backend exposes a single endpoint: POST /onboarding/segment that records
  // the user's self-selected segment and returns a routing decision. The
  // earlier `/onboarding/status` and `/onboarding/complete` routes never
  // existed on the server — they've been removed from this client.
  @POST('/api/v1/onboarding/segment')
  Future<OnboardingRoutingResponse> selectOnboardingSegment(
    @Body() SelectSegmentRequestDto body,
  );

  @POST('/api/v1/account/activate-business')
  Future<void> activateBusiness(
    @Body() ActivateBusinessRequest body,
  );

  // ─── Allergens ─────────────────────────────────────────────────────────
  @GET('/api/v1/allergens/product/{productId}')
  Future<List<AllergenResponse>> getProductAllergens(
    @Path('productId') String productId,
  );

  @GET('/api/v1/allergens/profile/{userId}')
  Future<AllergenProfileResponse> getAllergenProfile(
    @Path('userId') String userId,
  );

  @PUT('/api/v1/allergens/profile/{userId}')
  Future<AllergenProfileResponse> updateAllergenProfile(
    @Path('userId') String userId,
    @Body() UpdateAllergenProfileDto body,
  );

  // ─── Recall ────────────────────────────────────────────────────────────
  @GET('/api/v1/recalls')
  Future<List<RecallResponse>> getRecalls();

  @GET('/api/v1/recalls/product/{productId}')
  Future<List<RecallResponse>> getProductRecalls(
    @Path('productId') String productId,
  );

  // ─── Ingredient Explainer ──────────────────────────────────────────────
  @POST('/api/v1/ingredients/explain')
  Future<IngredientExplainerResponse> explainIngredients(
    @Body() Map<String, dynamic> body,
  );

  /// BE-40 — `GET /api/v1/ingredients/:slug/explanation?locale=...`.
  ///
  /// Per-slug explanation surface used by the dedicated full-screen
  /// explainer (FE-19). Distinct from `explainIngredients` (which posts a
  /// list and returns a different shape) so the inline product-detail
  /// blurb keeps working unchanged.
  @GET('/api/v1/ingredients/{slug}/explanation')
  Future<IngredientExplanation> getIngredientExplanation(
    @Path('slug') String slug, {
    @Query('locale') String? locale,
  });

  // ─── Healthy Alternatives ──────────────────────────────────────────────
  @GET('/api/v1/healthy-alternatives/{productId}')
  Future<HealthyAlternativesResponse> getHealthyAlternatives(
    @Path('productId') String productId,
  );

  /// BE-41 — `GET /api/v1/products/:ean/alternatives`.
  ///
  /// Returns up to three healthier candidates for a source EAN. The
  /// canonical path the server actually exposes (and the one FE-22 reads
  /// from). Returns a bare list — the screen wraps it in a
  /// `HealthyAlternativesResult` once it knows the source EAN.
  @GET('/api/v1/products/{ean}/alternatives')
  Future<List<HealthyAlternative>> getHealthierAlternatives(
    @Path('ean') String ean,
  );

  // ─── Saved Products (FE-16) ────────────────────────────────────────────
  /// `GET /api/v1/saved-products?cursor=&limit=` — cursor-paginated list of
  /// the signed-in user's saved products. Returns the canonical envelope
  /// `{ items, nextCursor }` so the client can lazy-load further pages.
  @GET('/api/v1/saved-products')
  Future<ListSavedProductsResponse> getSavedProducts({
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  });

  /// `POST /api/v1/saved-products` — bookmark a new product. Returns the
  /// freshly created row with server-assigned `id`/timestamps.
  @POST('/api/v1/saved-products')
  Future<SavedProductDto> createSavedProduct(
    @Body() CreateSavedProductDto body,
  );

  /// `DELETE /api/v1/saved-products/:id` — remove a saved product.
  /// Returns 204 No Content; the typed return is `void`.
  @DELETE('/api/v1/saved-products/{id}')
  Future<void> deleteSavedProduct(@Path('id') String id);

  /// BE-37 — `POST /api/v1/sync/saved-products`.
  ///
  /// Idempotent batch upsert. The mobile sync queue is the canonical
  /// pattern; the saved-products screen re-uses it for "save" and
  /// "unsave" mutations. There is currently no GET counterpart — see
  /// the FE-16 open-question summary.
  @POST('/api/v1/sync/saved-products')
  Future<void> syncSavedProducts(@Body() Map<String, dynamic> body);

  // ─── Family Sharing (BE-36) ────────────────────────────────────────────
  /// `GET /api/v1/family/members` — list the caller's family members.
  @GET('/api/v1/family/members')
  Future<List<FamilyMemberDto>> getFamilyMembers();

  /// `POST /api/v1/family/invite` — invite a family member by mobile.
  /// Body: { mobile: string }
  @POST('/api/v1/family/invite')
  Future<void> inviteFamilyMember(@Body() Map<String, dynamic> body);

  /// `DELETE /api/v1/family/members/{id}` — remove a family member.
  @DELETE('/api/v1/family/members/{id}')
  Future<void> removeFamilyMember(@Path('id') String id);

  // ─── Referrals ─────────────────────────────────────────────────────────
  @POST('/api/v1/referrals')
  Future<ReferralResponse> createReferral(@Body() CreateReferralDto body);

  @GET('/api/v1/referrals')
  Future<List<ReferralResponse>> getReferrals();

  @GET('/api/v1/referrals/me')
  Future<ReferralStatsResponse> getReferralStats();

  @POST('/api/v1/referrals/redeem')
  Future<void> redeemReferral(@Body() RedeemReferralDto body);

  // ─── User preferences ─────────────────────────────────────────────────
  @PUT('/api/v1/user/language')
  Future<void> updateUserLanguage(@Body() UpdateLanguageDto body);

  // ─── Sync ──────────────────────────────────────────────────────────────
  @POST('/api/v1/sync/push')
  Future<void> syncPush(@Body() SyncPushDto body);

  @GET('/api/v1/sync/pull')
  Future<SyncPullResponse> syncPull({@Query('since') String? since});

  // ─── FCM device tokens ─────────────────────────────────────────────
  @POST('/api/v1/notifications/fcm-token')
  Future<void> registerFcmToken(@Body() RegisterFcmTokenDto body);

  @DELETE('/api/v1/notifications/fcm-token')
  Future<void> unregisterFcmToken(@Query('token') String token);

  // ─── Shopping List ─────────────────────────────────────────────────────
  // Backend: /api/v1/shopping-lists (multi-list per user)
  @GET('/api/v1/shopping-lists')
  Future<List<ShoppingListSummary>> getShoppingLists();

  @POST('/api/v1/shopping-lists')
  Future<ShoppingListSummary> createShoppingList(
    @Body() CreateShoppingListDto body,
  );

  @GET('/api/v1/shopping-lists/{listId}')
  Future<ShoppingListDetail> getShoppingListDetail(
    @Path('listId') String listId,
  );

  @POST('/api/v1/shopping-lists/{listId}/items')
  Future<ShoppingListItemResponse> addShoppingListItem(
    @Path('listId') String listId,
    @Body() ShoppingListItemDto body,
  );

  @PATCH('/api/v1/shopping-lists/{listId}/items/{itemId}')
  Future<ShoppingListItemResponse> updateShoppingListItem(
    @Path('listId') String listId,
    @Path('itemId') String itemId,
    @Body() UpdateShoppingListItemDto body,
  );

  @DELETE('/api/v1/shopping-lists/{listId}/items/{itemId}')
  Future<void> deleteShoppingListItem(
    @Path('listId') String listId,
    @Path('itemId') String itemId,
  );

  // ─── Public Product ────────────────────────────────────────────────────
  @GET('/api/v1/public/products/{ean}')
  Future<PublicProductResponse> getPublicProduct(@Path('ean') String ean);

  // ─── Weekly Digest ─────────────────────────────────────────────────────
  @GET('/api/v1/weekly-digest')
  Future<WeeklyDigestResponse> getWeeklyDigest();

  // ─── Reports / Exports (FE-30) ─────────────────────────────────────────
  // BE-20 / BE-21 surface. Static `/reports/scheduled` and
  // `/reports/aggregate` paths sit before `/reports/:id` server-side
  // so Nest's resolver doesn't collide them; the Retrofit method order
  // below is irrelevant to that — what matters is the request path.

  /// `GET /api/v1/reports` — recent reports for the tenant. The server
  /// returns a bare JSON array today; an envelope wrapper can be added
  /// later by replacing this method's return type without changing
  /// callers (they typically project to a `List<ReportSummary>` anyway).
  @GET('/api/v1/reports')
  Future<List<ReportSummary>> getReports({
    @Query('status') String? status,
    @Query('type') String? type,
    @Query('limit') int? limit,
  });

  /// `POST /api/v1/reports/generate` — kick off an async report job.
  @POST('/api/v1/reports/generate')
  Future<GenerateReportResponseDto> generateReport(
    @Body() GenerateReportRequestDto body,
  );

  /// `POST /api/v1/reports/:id/export` — re-export an existing report
  /// in one or more formats. Returns presigned download URLs implicitly
  /// via [ExportFile.fileName] + the per-format download endpoint below.
  @POST('/api/v1/reports/{id}/export')
  Future<ExportResponseDto> exportReport(
    @Path('id') String reportId,
    @Body() ExportRequestDto body,
  );

  /// `GET /api/v1/reports/:id/download/:format` — presigned download URL
  /// for a specific format. Mobile leans on this to hand a URL to the
  /// platform browser (`url_launcher`).
  @GET('/api/v1/reports/{id}/download/{format}')
  Future<ReportDownloadUrlResponse> getReportDownloadUrl(
    @Path('id') String reportId,
    @Path('format') String format,
  );

  /// `GET /api/v1/reports/scheduled` — list of recurring report
  /// schedules visible to the tenant.
  @GET('/api/v1/reports/scheduled')
  Future<List<ScheduledReport>> getScheduledReports();

  /// `POST /api/v1/reports/schedule` — create a new recurring schedule.
  /// The server validates the nested `parameters` against the same
  /// schema as the generate endpoint.
  @POST('/api/v1/reports/schedule')
  Future<ScheduledReport> createScheduledReport(
    @Body() CreateScheduleRequestDto body,
  );

  /// `POST /api/v1/reports/scheduled/:id/pause` — temporarily stop firing.
  @POST('/api/v1/reports/scheduled/{id}/pause')
  Future<ScheduledReport> pauseScheduledReport(@Path('id') String id);

  /// `POST /api/v1/reports/scheduled/:id/resume` — resume after a pause.
  @POST('/api/v1/reports/scheduled/{id}/resume')
  Future<ScheduledReport> resumeScheduledReport(@Path('id') String id);

  /// `DELETE /api/v1/reports/scheduled/:id` — cancel a schedule.
  @DELETE('/api/v1/reports/scheduled/{id}')
  Future<void> deleteScheduledReport(@Path('id') String id);

  // ─── Dashboard / OHS (FE-26) ───────────────────────────────────────────
  /// `GET /api/v1/dashboard/summary` — live operational rollup for the
  /// caller's currently-active store. The mobile app derives the OHS
  /// headline + breakdowns from this DTO via [OhsSnapshot.fromDashboard].
  @GET('/api/v1/dashboard/summary')
  Future<DashboardSummaryResponse> getDashboardSummary(
    @Query('storeId') String storeId, {
    @Query('daysAhead') int? daysAhead,
  });
}

/// Provides the generated Retrofit [ApiClient] backed by the configured Dio.
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

/// Wraps the new bare-list expiry-records endpoint in the paginated envelope
/// that existing screens and providers expect. No cursor pagination needed
/// since the backend returns all matching records (bounded by `limit`).
extension ExpiryApiClientCompat on ApiClient {
  Future<PaginatedExpiries> getExpiries({
    String? cursor,
    int? limit,
    String? status,
    String? storeId,
  }) async {
    final items = await getExpiryRecords(
      limit: limit,
      status: status,
      storeId: storeId,
    );
    return PaginatedExpiries(items: items, total: items.length);
  }
}
