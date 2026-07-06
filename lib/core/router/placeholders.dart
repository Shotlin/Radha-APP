// Lightweight placeholder screens used by the router for routes whose real
// feature surfaces are owned by later tasks (Splash, Onboarding, OTP, Home,
// Scan, Expiry, Tasks, Inventory, GRN, Profile, Settings, Subscription, etc.).
//
// Each placeholder is intentionally minimal — a `Scaffold` with an `AppBar`
// and a centered label — so the router can be wired and exercised end-to-end
// before any feature work lands.

import 'package:flutter/material.dart';

/// Generic placeholder used by most routes in this skeleton router. Renders
/// the route title plus an optional subtitle so verification at a glance is
/// possible.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    this.subtitle,
    this.showAppBar = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Placeholder — feature implementation lands in a later task.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (!showAppBar) {
      return Scaffold(body: SafeArea(child: body));
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: body),
    );
  }
}
