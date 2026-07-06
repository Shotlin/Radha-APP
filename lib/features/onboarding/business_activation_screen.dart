import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/router/app_router.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';

class BusinessActivationScreen extends ConsumerStatefulWidget {
  const BusinessActivationScreen({super.key, this.preset});

  final BusinessActivationPresetDto? preset;

  @override
  ConsumerState<BusinessActivationScreen> createState() =>
      _BusinessActivationScreenState();
}

class _BusinessActivationScreenState
    extends ConsumerState<BusinessActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  bool _storeNameEdited = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _storeNameCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _onBusinessNameChanged(String v) {
    if (!_storeNameEdited) {
      _storeNameCtrl.text = v;
      _storeNameCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _storeNameCtrl.text.length),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      await api.activateBusiness(ActivateBusinessRequest(
        businessName: _businessNameCtrl.text.trim(),
        storeName: _storeNameCtrl.text.trim(),
        storeCity: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        storePincode:
            _pincodeCtrl.text.trim().isEmpty ? null : _pincodeCtrl.text.trim(),
        acceptTrialPro: true,
        preset: widget.preset,
      ));
      // Refresh the session so the new tenant + store are picked up.
      await ref.read(authControllerProvider.notifier).refreshSession();
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.go(AppRoute.home);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      // DioException wraps ApiException in .error; unwrap for a real message.
      final inner = (e as dynamic)?.error;
      final msg = inner is ApiException
          ? inner.message
          : 'Something went wrong. Please try again.';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.storefront_outlined,
                      color: cs.primary, size: 26),
                ),
                const SizedBox(height: 20),
                Text(
                  'Set up your business',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A few quick details and your store is ready to go.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // Business name
                _Label('Business name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: _onBusinessNameChanged,
                  decoration: _inputDecoration(cs, hint: 'e.g. Sharma General Store'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Store name
                _Label('Store / branch name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _storeNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _storeNameEdited = true,
                  decoration: _inputDecoration(cs, hint: 'e.g. Main Road Branch'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // City + Pincode in a row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('City (optional)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityCtrl,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(cs, hint: 'e.g. Mumbai'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Pincode'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pincodeCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _inputDecoration(cs, hint: '400001'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trial note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          color: cs.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Includes 14-day Pro trial — no card needed.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: cs.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.error),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Get started',
                  onPressed: _loading ? null : _submit,
                  loading: _loading,
                  expand: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme cs, {required String hint}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: cs.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      );
}
