import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/entitlements/entitlement_provider.dart';
import 'package:radha_app/core/mode/app_mode_provider.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/subscription_dto.dart';

class _FakeApi implements ApiClient {
  _FakeApi(this._respond);
  final Future<SubscriptionResponse> Function() _respond;

  @override
  Future<SubscriptionResponse> getSubscription() => _respond();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SubscriptionResponse _sub(String code, {required bool active, String? status}) =>
    SubscriptionResponse(
      isActive: active,
      status: status ?? (active ? 'active' : 'expired'),
      plan: SubscriptionPlanInfo(code: code, name: code),
    );

Future<EntitlementState> _entitlement(Future<SubscriptionResponse> Function() respond) async {
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(_FakeApi(respond))],
  );
  addTearDown(container.dispose);
  return container.read(entitlementProvider.future);
}

void main() {
  group('single module: resolveMode', () {
    CurrentUser user(List<String> roles, {String? store}) =>
        CurrentUser(userId: 'u', roles: roles, selectedStoreId: store);

    test('everyone gets the business shell, whatever their role', () {
      expect(resolveMode(null), AppMode.business);
      expect(resolveMode(user(['consumer'])), AppMode.business);
      expect(resolveMode(user(['owner'], store: 's1')), AppMode.business);
      expect(resolveMode(user(['staff'], store: 's1')), AppMode.business);
    });

    test('only an auditor with a store gets the restricted shell', () {
      expect(resolveMode(user(['auditor'], store: 's1')), AppMode.auditor);
      expect(resolveMode(user(['auditor'])), AppMode.business);
    });
  });

  group('plans: free vs paid', () {
    test('free plan unlocks none of the gated features', () async {
      final s = await _entitlement(() async => _sub('free', active: true));
      expect(s.planId, 'free');
      expect(s.features, isEmpty);
    });

    test('pro unlocks inventory, GRN and reports', () async {
      final s = await _entitlement(() async => _sub('pro', active: true));
      expect(
        s.features,
        containsAll([Feature.inventory, Feature.grn, Feature.advancedReports]),
      );
    });

    test('starter unlocks inventory only', () async {
      final s = await _entitlement(() async => _sub('starter', active: true));
      expect(s.features, {Feature.inventory});
    });

    test('an expired subscription falls back to free features', () async {
      final s = await _entitlement(() async => _sub('pro', active: false));
      expect(s.features, isEmpty);
    });

    test('a 404 (no subscription row yet) is the free plan, not an error', () async {
      final s = await _entitlement(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/subscriptions/status'),
          response: Response(
            requestOptions: RequestOptions(path: '/subscriptions/status'),
            statusCode: 404,
          ),
        ),
      );
      expect(s.planId, 'free');
      expect(s.features, isEmpty);
    });
  });
}
