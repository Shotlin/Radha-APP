# RADHA — UI v2 Route Coverage Matrix

Living document. One row per registered route. Updated at every phase boundary.
Columns abbreviated: **Mode** (C=consumer, B=business, A=all), **Ent** (entitlement
gate), **L10n** / **A11y** / **States** (loading-empty-error-offline) = ✅ done /
◑ partial / ☐ not-yet-verified, **Mig** = v2 migration status.

Status legend for **Mig**: `pending` · `in-progress` · `done`.
Most rows are `pending` because the migration has just begun; the source already
*functions* — these flags track the *coherent-design-system* migration, not whether the
happy path works.

| Route | Screen class | Mode | Role/Ent | L10n | A11y | States | Mig | Notes |
|-------|--------------|------|----------|------|------|--------|-----|-------|
| /splash | SplashScreen | A | — | ☐ | ☐ | n/a | pending | Phase 2. Uses `morSceneSplash`. |
| /onboarding | OnboardingScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 2. 6 segments, deferred submit. |
| /auth/otp | OtpRequestScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 2. +91 validation. |
| /auth/otp/verify | OtpVerifyScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 2. Pinput, cooldown, requestId. |
| /select-store | SelectStoreScreen | B | — | ☐ | ☐ | ☐ | pending | Phase 2. Real stores only. |
| /home | HomeScreen (1814 L) | A | mode-aware | ◑ | ☐ | ☐ | pending | Phase 3. Consumer/business variants. |
| /scan | ScanScreen (898 L) | A | — | ☐ | ☐ | ☐ | pending | Phase 4. MobileScanner, batch, zoom, torch. |
| /scan/result/:ean | ScanResultScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 4. Assessment-pending honesty. |
| /scan/audit | EanAuditScreen | B | — | ☐ | ☐ | ☐ | pending | Phase 4. EAN verification. |
| /scan/label | LabelScanScreen | A | ingredientExplainer (partial) | ☐ | ☐ | ☐ | pending | Phase 4. OCR → Gemini text analysis. |
| /expiry | ExpiryListScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 5. Segmented tabs. |
| /expiry/new | ExpiryCreateScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 5. OCR date prefill. |
| /expiry-calendar | ExpiryCalendarScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 5. Needs legend + Indic scale. |
| /tasks | TasksListScreen (651 L) | B | — | ☐ | ☐ | ☐ | pending | Phase 5. Cursor-paginated. |
| /tasks/create | TaskCreateScreen | B | role-gated create | ☐ | ☐ | ☐ | pending | Phase 5. |
| /tasks/:id | TaskDetailScreen (624 L) | B | role-gated actions | ☐ | ☐ | ☐ | pending | Phase 5. priority≠status. |
| /inventory | InventoryListScreen (635 L) | B | **inventory** | ☐ | ☐ | ☐ | pending | Phase 6. Load-more error preserve. |
| /inventory/stock-movement | StockMovementScreen (540 L) | B | inventory | ☐ | ☐ | ☐ | pending | Phase 6. In/Out/Adjust distinct. |
| /inventory/low-stock-alerts | LowStockAlertsScreen (218 L) | B | inventory | ☐ | ☐ | ☐ | pending | Phase 6. |
| /grn | GrnListScreen (474 L) | B | **grn** | ☐ | ☐ | ☐ | pending | Phase 6. |
| /grn/create | GrnCreateScreen (223 L) | B | grn (manager) | ☐ | ☐ | ☐ | pending | Phase 6. mfg<exp validation. |
| /grn/:id, /grn/:id/items | GrnItemsScreen (684 L) | B | grn | ☐ | ☐ | ☐ | pending | Phase 6. Persisted items, post flow. |
| /profile | ProfileScreen (539 L) | A | — | ☐ | ☐ | ☐ | pending | Phase 8. No raw UUID identity. |
| /settings | SettingsScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 8. Theme/textscale/notif. |
| /settings/language | LanguagePickerScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 8. |
| /support | SupportScreen | A | — | ☐ | ☐ | ☐ | pending | Phase 8. |
| /subscription | SubscriptionScreen (530 L) | A | — | ☐ | ☐ | ☐ | pending | Phase 8. Razorpay, plan ids, paywallHero. |
| /shopping-list | ShoppingListScreen | C | — | ☐ | ☐ | ☐ | pending | Phase 7. |
| /recall-alerts | RecallAlertsScreen | C | **recallAlerts** | ☐ | ☐ | ☐ | pending | Phase 7. Warning priority. |
| /allergens | AllergenProfileScreen | C | **allergenProfile** | ☐ | ☐ | ☐ | pending | Phase 7. Mor guard. |
| /referrals | ReferralsScreen | C | — | ☐ | ☐ | ☐ | pending | Phase 7. No fake reward progress. |
| /ingredients/:slug | IngredientExplainerScreen | C | ingredientExplainer | ✅ | ☐ | ☐ | pending | Phase 7. Uses AppLocalizations. |
| /alternatives/:ean | HealthyAlternativesScreen | C | healthyAlternatives | ✅ | ☐ | ☐ | pending | Phase 7. Affiliate secondary. |
| /saved-products | SavedProductsScreen | C | — | ☐ | ☐ | ☐ | pending | Phase 7. |
| /catalog/search | CatalogSearchScreen | C | — | ☐ | ☐ | ☐ | pending | Phase 4. Debounced, morSceneSearch. |
| /catalog/:category | ProductBrowseScreen | C | — | ☐ | ☐ | ☐ | pending | Phase 4. Infinite scroll, sort/filter. |
| /catalog/product/:key | CatalogProductDetailScreen | C | Plus (partial) | ☐ | ☐ | ☐ | pending | Phase 4. Real health gauge. |
| /digest, /digest/:weekIso | WeeklyDigestScreen | C | weeklyDigest | ✅ | ☐ | ☐ | pending | Phase 7. |
| /reports | ReportsScreen | B | **advancedReports** | ◑ | ☐ | ☐ | pending | Phase 9. CSV/PDF/XLSX export. |
| /ohs | OhsDashboardScreen (881 L) | B | **advancedReports** | ☐ | ☐ | ☐ | pending | Phase 9. Score hierarchy. |
| (shell) | RootShell + RadhaBottomNavigation | A | — | ✅ | ◑ | n/a | **in-progress** | **Phase 1 batch-1: nav grammar migrated, localized; tests added.** |
| (errors) | NotFoundScreen | A | — | ☐ | ☐ | n/a | pending | Phase 1/10. |

## Per-route detail to fill during each phase
For each route, when its phase runs, verify and record: exact providers consumed, API
endpoints hit, visual assets used, all four state designs, l10n completeness, a11y
(48dp/semantics/contrast/focus/textScale 2.0/reduced-motion), tests added, remaining
issues. No route is "done" on happy-path alone.
