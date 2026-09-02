// Real `/store-details` screen — Profile > "Store details".
//
// Previously mis-wired to the store-picker (SelectStoreScreen), which just
// shows a list to choose from and redirects to /home — there was no actual
// details/edit surface. This screen fetches the current store's address,
// GSTIN, and business hours (GET /stores/{id}, already built for the
// Profile header's short-code chip) and lets the owner edit + save them
// (PATCH /stores/{id}, owner/admin only per the backend's @Roles()).
// Non-owner roles (manager/staff/auditor) see the same data read-only.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/store/store_providers.dart';
import '../../design/tokens.dart';
import '../../design/widgets/error_state.dart';
import '../../design/widgets/primary_button.dart';

const Map<String, String> _kDayLabels = {
  'monday': 'Monday',
  'tuesday': 'Tuesday',
  'wednesday': 'Wednesday',
  'thursday': 'Thursday',
  'friday': 'Friday',
  'saturday': 'Saturday',
  'sunday': 'Sunday',
};

class StoreDetailsScreen extends ConsumerStatefulWidget {
  const StoreDetailsScreen({super.key});

  @override
  ConsumerState<StoreDetailsScreen> createState() =>
      _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstinController = TextEditingController();

  /// Keyed by lowercase day name. Populated from the fetched store on
  /// first load, then edited locally until Save.
  Map<String, DayHours> _hours = {
    for (final day in kBusinessHoursDays) day: const DayHours(open: false),
  };

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _populateFrom(StoreResponse store) {
    _nameController.text = store.name;
    _addressController.text = store.addressLine1 ?? '';
    _cityController.text = store.city ?? '';
    _stateController.text = store.state ?? '';
    _pincodeController.text = store.pincode ?? '';
    _gstinController.text = store.gstin ?? '';
    final saved = store.businessHours;
    if (saved != null) {
      _hours = {
        for (final day in kBusinessHoursDays)
          day: saved[day] ?? const DayHours(open: false),
      };
    }
    _initialized = true;
  }

  Future<void> _pickTime(String day, {required bool isOpening}) async {
    final current = _hours[day]!;
    final initial = _parseTime(isOpening ? current.opensAt : current.closesAt) ??
        TimeOfDay(hour: isOpening ? 9 : 21, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      _hours[day] = isOpening
          ? current.copyWith(opensAt: formatted)
          : current.copyWith(closesAt: formatted);
    });
  }

  TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _save(String storeId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Any day left "open" without both times set defaults to a sensible
    // 9-to-9 rather than silently failing the backend's own requirement.
    final hours = {
      for (final entry in _hours.entries)
        entry.key: entry.value.open &&
                (entry.value.opensAt == null || entry.value.closesAt == null)
            ? entry.value.copyWith(
                opensAt: entry.value.opensAt ?? '09:00',
                closesAt: entry.value.closesAt ?? '21:00',
              )
            : entry.value,
    };

    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.updateStore(
        storeId,
        UpdateStoreDto(
          name: _nameController.text.trim(),
          addressLine1: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          gstin: _gstinController.text.trim().isEmpty
              ? null
              : _gstinController.text.trim().toUpperCase(),
          businessHours: hours,
        ),
      );
      ref.invalidate(storeDetailsProvider(storeId));
      // The Profile/Home store name is also sourced from this same
      // provider, so invalidating it here is enough to refresh both.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store details saved')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final storeId = user?.selectedStoreId;
    final isOwner = user?.roles.contains('owner') ?? false;

    if (storeId == null) {
      return const Scaffold(
        appBar: _StoreDetailsAppBar(),
        body: Center(child: Text('No store selected.')),
      );
    }

    final storeAsync = ref.watch(storeDetailsProvider(storeId));

    return Scaffold(
      appBar: const _StoreDetailsAppBar(),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(
          title: 'Could not load store details',
          onRetry: () => ref.invalidate(storeDetailsProvider(storeId)),
        ),
        data: (store) {
          if (!_initialized) _populateFrom(store);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RadhaSpacing.space16,
                RadhaSpacing.space16,
                RadhaSpacing.space16,
                RadhaSpacing.space32,
              ),
              children: [
                if (!isOwner)
                  Padding(
                    padding: const EdgeInsets.only(bottom: RadhaSpacing.space16),
                    child: Text(
                      'Only the store owner can edit these details.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                _SectionLabel('STORE NAME'),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _nameController,
                  enabled: isOwner && !_saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Store name is required' : null,
                  decoration: const InputDecoration(hintText: 'e.g. Sharma General Store'),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                _SectionLabel('ADDRESS'),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _addressController,
                  enabled: isOwner && !_saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  decoration: const InputDecoration(hintText: 'Full address'),
                ),
                const SizedBox(height: RadhaSpacing.space12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        enabled: isOwner && !_saving,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'City is required' : null,
                        decoration: const InputDecoration(hintText: 'City'),
                      ),
                    ),
                    const SizedBox(width: RadhaSpacing.space12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        enabled: isOwner && !_saving,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'State is required' : null,
                        decoration: const InputDecoration(hintText: 'State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RadhaSpacing.space12),
                TextFormField(
                  controller: _pincodeController,
                  enabled: isOwner && !_saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().length < 4) ? 'PIN code is required' : null,
                  decoration: const InputDecoration(hintText: 'PIN code'),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                _SectionLabel('GSTIN (OPTIONAL)'),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _gstinController,
                  enabled: isOwner && !_saving,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: '15-character GSTIN'),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                _SectionLabel('BUSINESS HOURS'),
                const SizedBox(height: RadhaSpacing.space8),
                ..._kDayLabels.entries.map(
                  (e) => _DayHoursRow(
                    label: e.value,
                    hours: _hours[e.key]!,
                    enabled: isOwner && !_saving,
                    onToggle: (open) =>
                        setState(() => _hours[e.key] = _hours[e.key]!.copyWith(open: open)),
                    onPickOpen: () => _pickTime(e.key, isOpening: true),
                    onPickClose: () => _pickTime(e.key, isOpening: false),
                  ),
                ),

                if (isOwner) ...[
                  const SizedBox(height: RadhaSpacing.space24),
                  PrimaryButton(
                    label: 'Save',
                    loading: _saving,
                    onPressed: _saving ? null : () => _save(storeId),
                    expand: true,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoreDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StoreDetailsAppBar();

  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Store details'));

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _DayHoursRow extends StatelessWidget {
  const _DayHoursRow({
    required this.label,
    required this.hours,
    required this.enabled,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  final String label;
  final DayHours hours;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Switch(value: hours.open, onChanged: enabled ? onToggle : null),
          const SizedBox(width: RadhaSpacing.space8),
          if (hours.open)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _TimeChip(
                      label: hours.opensAt ?? 'Opens',
                      onTap: enabled ? onPickOpen : null,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space8),
                  Text('–', style: theme.textTheme.bodySmall),
                  const SizedBox(width: RadhaSpacing.space8),
                  Expanded(
                    child: _TimeChip(
                      label: hours.closesAt ?? 'Closes',
                      onTap: enabled ? onPickClose : null,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Text(
                'Closed',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space12,
          vertical: RadhaSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        ),
        child: Text(label, style: theme.textTheme.labelMedium),
      ),
    );
  }
}
