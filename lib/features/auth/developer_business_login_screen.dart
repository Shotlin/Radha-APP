import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_exception.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import 'post_login_flow.dart';

/// Development-only entry point for the server-created RADHA business owner.
/// The credentials are entered here and sent only to the existing backend
/// admin-login route; Firebase/Google configuration is deliberately not part
/// of this path.
class DeveloperBusinessLoginScreen extends ConsumerStatefulWidget {
  const DeveloperBusinessLoginScreen({super.key});

  @override
  ConsumerState<DeveloperBusinessLoginScreen> createState() =>
      _DeveloperBusinessLoginScreenState();
}

class _DeveloperBusinessLoginScreenState
    extends ConsumerState<DeveloperBusinessLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter the developer email and password.');
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final storage = ref.read(sessionStorageProvider);
      final pending = await storage.readPendingOnboardingSegment();
      await ref
          .read(authControllerProvider.notifier)
          .adminLogin(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      await runPostLoginFlow(
        ref: ref,
        context: context,
        router: GoRouter.of(context),
        segment: null,
        cameFromBusinessOnboarding: pending == 'business_owner',
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Developer login failed. Check the backend account.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Developer business login')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RadhaSpacing.space24),
          children: [
            Icon(Icons.storefront_rounded, size: 44, color: scheme.primary),
            const SizedBox(height: RadhaSpacing.space16),
            Text(
              'Open the RADHA business workspace',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              'Use the developer owner account created on the backend. This shortcut is for development testing only.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space32),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Developer email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: RadhaSpacing.space16),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: RadhaSpacing.space32),
            PrimaryButton(
              label: 'Open business account',
              expand: true,
              loading: _loading,
              onPressed: _loading ? null : _login,
            ),
            const SizedBox(height: RadhaSpacing.space12),
            TextButton(
              onPressed: _loading ? null : () => context.pop(),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
