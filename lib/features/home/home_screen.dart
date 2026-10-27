import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../business/business_dashboard_screen.dart';

/// Home — the anchor screen.
///
/// RADHA has a single module (the business command center) for every user,
/// free or paid; the plan decides which tools are unlocked
/// (see `entitlementProvider` / `LockedFeature`). The product-discovery block
/// that used to belong to the separate personal home is embedded inside the
/// dashboard itself (`ProductDiscoverySection`). Rendered without its own
/// Scaffold so it sits inside the shell's bottom navigation.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SafeArea(bottom: false, child: BusinessDashboardScreen());
  }
}
