import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/notifications/push_service.dart';
import '../../core/router/app_router.dart';

/// Everything that needs to happen right after ANY successful login —
/// posting a pending pre-auth onboarding segment, registering the FCM push
/// token, and routing to business-activation or home. Extracted (Phase 13)
/// from `otp_verify_screen.dart` so the OTP path and the new
/// `google_sign_in_screen.dart`/`legacy_account_link_screen.dart` paths can
/// never drift on what "just logged in" actually does.
///
/// Callers must read [segment]/[cameFromBusinessOnboarding] from
/// `SessionStorage.readPendingOnboardingSegment()` themselves, and do so
/// BEFORE calling the login method — reading it after would race the
/// router's `refreshListenable` redirect, which fires the instant the
/// session becomes non-null (see the original `otp_verify_screen.dart`
/// comment this preserves the ordering of).
Future<void> runPostLoginFlow({
  required WidgetRef ref,
  required BuildContext context,
  required GoRouter router,
  required OnboardingSegmentDto? segment,
  required bool cameFromBusinessOnboarding,
}) async {
  final storage = ref.read(sessionStorageProvider);
  final api = ref.read(apiClientProvider);

  OnboardingNextScreenDto? nextScreen;
  if (segment != null) {
    try {
      final response = await api.selectOnboardingSegment(
        SelectSegmentRequestDto(segment: segment),
      );
      await storage.setPendingOnboardingSegment(null);
      nextScreen = response.nextScreen;
    } catch (_) {
      // Segment post failure is non-fatal; fall through to routing logic.
    }
  }

  // Fire-and-forget — failure is non-fatal, push just won't work this session.
  PushService.instance.registerToken(api).ignore();

  await Future<void>.delayed(const Duration(milliseconds: 300));

  // Route to business activation when:
  //   a) The backend explicitly requested it, OR
  //   b) The user chose the business onboarding path AND their account has
  //      no store yet — this covers demo/new accounts where the segment
  //      endpoint is unavailable or doesn't upgrade the role automatically.
  final freshSession = ref.read(authControllerProvider).valueOrNull;
  final needsBusinessActivation =
      nextScreen == OnboardingNextScreenDto.businessActivationFlow ||
      (cameFromBusinessOnboarding &&
          (freshSession == null || freshSession.stores.isEmpty));

  if (needsBusinessActivation) {
    router.go(AppRoute.businessActivation);
  } else if (context.mounted) {
    context.go(AppRoute.home);
  }
  // else: GoRouter already navigated to home via redirect — nothing to do.
}
