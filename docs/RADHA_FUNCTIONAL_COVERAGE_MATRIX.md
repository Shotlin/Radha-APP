# RADHA — Functional Coverage Matrix (Wave 1)

Maps each feature surface to its route, provider, API method, backend endpoint and a
**client-truth** status. Source-of-truth: `app_router.dart`, `api_client.dart` (82 declared
endpoints), and the feature screens.

## Methodology & honesty note
There is **no backend in this repo** (Git: `server/**` = 0 files). Therefore **no endpoint
can be verified end-to-end against a live server here**. Two distinct columns:

- **Client status** — verifiable *here* by reading code / mocked tests:
  `VERIFIED` (read + tested this work), `WIRED` (screen calls the method and has
  loading/empty/error handling, confirmed by reading), `DECLARED` (route + endpoint exist;
  client wiring to be confirmed in that feature's wave), `DEAD` (button with no handler),
  `NOT-IMPL` (advertised, no code).
- **Live** — end-to-end against a running backend: **UNVERIFIED (no backend)** for every
  row in this checkout. Do not read any row as "working in production."

No row is marked WORKING; that word is reserved for live-verified behavior, which this
checkout cannot establish.

## Endpoint inventory (declared in ApiClient)
82 methods across: auth(6), products(5), catalog(2), scan-sessions(5), ean-lists(6),
expiry(5), tasks(5), inventory(3), grn(3), subscription(2), payments(2), onboarding(1),
allergens(3), recalls(2), ingredients(2), alternatives(2), saved-products(4), referrals(4),
user(1), sync(2), ocr(1), shopping-list(4), public-product(1), weekly-digest(1),
reports(9), dashboard/OHS(1).

## Coverage

| Feature / journey | Route | API method(s) | Client status | Live | Notes |
|---|---|---|---|---|---|
| OTP request | /auth/otp | requestOtp | DECLARED | UNVERIFIED | +91 validation in screen (Wave 6). |
| OTP verify | /auth/otp/verify | verifyOtp, refreshToken | DECLARED | UNVERIFIED | Pinput/cooldown/requestId (Wave 6). |
| Session/me | (bootstrap) | me, logout | DECLARED | UNVERIFIED | auth_controller; redirect guard verified in router. |
| Onboarding segment | /onboarding | selectOnboardingSegment | DECLARED | UNVERIFIED | Deferred submit; 6 segments (Wave 6). |
| Store selection | /select-store | (session.stores) | DECLARED | UNVERIFIED | Real stores only (Wave 6). |
| Home (consumer/business) | /home | getDashboardSummary, featured/catalog | DECLARED | UNVERIFIED | Mode-aware; KPI honesty (Wave 7). |
| **Catalog category browse** | /catalog/:category | getCatalogCategories, getCatalogProducts | **VERIFIED** | UNVERIFIED | **This wave**: explicit live/offline/unavailable source + retry + structured log + 5 mocked tests. Offline-first bundled fallback preserved. |
| **Catalog featured rail** | /home | getCatalogProducts(sort=health) | **VERIFIED** | UNVERIFIED | Failures now logged (`radha.catalog`); launch fallback preserved. |
| **Catalog search** | /catalog/search | getCatalogProducts(q) | **VERIFIED** | UNVERIFIED | Failures logged; launch matches fallback; debounced. |
| Product detail (catalog) | /catalog/product/:key | getProductLookup | DECLARED | UNVERIFIED | **Next (Priority 1)**: ensure lookup 404/500 show explicit state, not empty widget; free basic nutrition ungated. (Wave 9) |
| Scan (barcode) | /scan | createScanSession, recordScanItem | DECLARED | UNVERIFIED | MobileScanner; batch/zoom/torch (Wave 8). |
| Scan result | /scan/result/:ean | getProductByEan/lookup, validateEan | DECLARED | UNVERIFIED | Assessment-pending honesty (Wave 8/9). |
| Label OCR | /scan/label | ocrFallback / ai label | DECLARED | UNVERIFIED | Premium-gated AI (Wave 8). |
| EAN audit | /scan/audit | validateEanBatch, ean-lists | DECLARED | UNVERIFIED | `_StatusChip` → migrate to RadhaStatusChip (Wave 8). |
| Expiry list | /expiry | getExpiries | DECLARED | UNVERIFIED | Status tabs, pagination (Wave 10). |
| Add expiry | /expiry/new | createExpiry | DECLARED | UNVERIFIED | OCR prefill; mfg<exp (Wave 10). |
| Expiry calendar | /expiry-calendar | getExpiryCalendar | DECLARED | UNVERIFIED | Needs legend + Indic scale (Wave 10). |
| Tasks list | /tasks | getTasks | DECLARED | UNVERIFIED | Cursor pagination (Wave 10). |
| Task create | /tasks/create | createTask | DECLARED | UNVERIFIED | Role-gated (Wave 10). |
| Task detail | /tasks/:id | getTask, updateTask, deleteTask | DECLARED | UNVERIFIED | `_StatusPill` → RadhaStatusChip; priority≠status (Wave 10). |
| Inventory | /inventory (ent: inventory) | getInventory, getInventoryItem | DECLARED | UNVERIFIED | Load-more error preserve (Wave 11). |
| Stock movement | /inventory/stock-movement | adjustStock | DECLARED | UNVERIFIED | Negative guard; In/Out/Adjust (Wave 11). |
| Low-stock alerts | /inventory/low-stock-alerts | getInventory(filter) | DECLARED | UNVERIFIED | (Wave 11). |
| GRN list | /grn (ent: grn) | getGrns | DECLARED | UNVERIFIED | `_StatusPill` → RadhaStatusChip (Wave 11). |
| GRN create | /grn/create | createGrn | DECLARED | UNVERIFIED | mfg<exp; manager role (Wave 11). |
| GRN items/post | /grn/:id, /grn/:id/items | getGrn, sync enqueue POST items/post | DECLARED | UNVERIFIED | Items persisted via sync queue (prior work). |
| Subscription | /subscription | getSubscription, createSubscription | DECLARED | UNVERIFIED | Plan ids reconcile (Wave 12 / Priority 2). |
| Payments | (checkout sheet) | createCheckout, verifyPayment | DECLARED | UNVERIFIED | Razorpay; no live creds here (Priority 2 — blocked live). |
| Allergen profile | /allergens (ent) | getAllergenProfile, updateAllergenProfile | DECLARED | UNVERIFIED | Mor guard (Wave 9). |
| Recall alerts | /recall-alerts (ent) | getRecalls, getProductRecalls | DECLARED | UNVERIFIED | Warning priority (Wave 9). |
| Ingredient explainer | /ingredients/:slug (ent) | getIngredientExplanation | WIRED (l10n ✓) | UNVERIFIED | Uses AppLocalizations (Wave 9). |
| Healthy alternatives | /alternatives/:ean (ent) | getHealthierAlternatives | WIRED (l10n ✓) | UNVERIFIED | Affiliate secondary (Wave 9). |
| Saved products | /saved-products | getSavedProducts, createSavedProduct, deleteSavedProduct, syncSavedProducts | DECLARED | UNVERIFIED | (Wave 9). |
| Shopping list | /shopping-list | getShoppingList, add/update/delete item | DECLARED | UNVERIFIED | (Wave 9). |
| Weekly digest | /digest, /digest/:weekIso | getWeeklyDigest | WIRED (l10n ✓) | UNVERIFIED | (Wave 9). |
| Referrals | /referrals | createReferral, getReferrals, getReferralStats, redeemReferral | DECLARED | UNVERIFIED | No fake reward progress (Wave 9). |
| Profile | /profile | me/session | DECLARED | UNVERIFIED | No raw UUID identity (Wave 12). |
| Settings | /settings | (prefs) | DECLARED | UNVERIFIED | theme/textscale/notif (Wave 12). |
| Language | /settings/language | updateUserLanguage | DECLARED | UNVERIFIED | (Wave 12). |
| Support | /support | (links) | DECLARED | UNVERIFIED | Verify external link handling (Wave 12). |
| Reports | /reports (ent: advancedReports) | getReports, generate, export, download, scheduled CRUD | DECLARED | UNVERIFIED | `_StatusChip` → RadhaStatusChip; completion honesty (Wave 13). |
| OHS dashboard | /ohs (ent: advancedReports) | getDashboardSummary | DECLARED | UNVERIFIED | Score hierarchy; client-derived label (Wave 13). |

## Advertised / planned surfaces — reconciliation (mandate Priority 3)
| Surface | Backend(API client) | Verdict | Action |
|---|---|---|---|
| Public product profile | getPublicProduct (declared) | B (client method exists, no routed UI) | Add surface or leave as deep-link target (Wave 4). |
| Notifications inbox | none | D/F | No endpoint → backlog; nav badge wired only when a real provider exists. |
| Family sharing | none | F | Backlog (no API). |
| Business activation | none | F | Backlog. |
| Verified badge | none | F | Backlog. |
| Community barcode contribution | none | F | Backlog. |
| Supplier directory | none | F | Backlog — do NOT build a supplier screen (no contract). |
| Standalone checkout route | payments via sheet | C-handled | Keep checkout as sheet; no standalone route. |
| Voice capabilities | none | F | Backlog. |

**Dead-button scan:** to be completed per wave (each migrated screen audited for handler
presence). No new dead buttons introduced this work.
