// Support / Feedback screen (FE-37).
//
// Mounted at `/support`. Three sections:
//
//   1. Contact us — Email and Call buttons. Email composes a mailto: that
//      pre-fills the subject and a body with diagnostic context (app
//      version, platform, user id). Call launches a tel: with a
//      placeholder number until the support number is provisioned.
//   2. Report a bug — multi-line description, optional screenshot, submit.
//      The api_client has no `/api/v1/support/feedback` endpoint today
//      (open question), so submission falls back to a mailto with the
//      report inlined.
//   3. FAQ — five hardcoded entries rendered as ExpansionTiles.
//
// Visual rules:
//   * One orange accent (#EA580C) — the "Send report" CTA. Other CTAs use the
//     neutral outlined treatment so the surface stays calm.
//   * 44pt+ touch targets on every interactive element.
//   * No emoji icons; no centered hero; no purple/blue gradients.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Placeholder support number until the real one is provisioned.
/// TODO (FE-37): swap for the production support line once provisioned.
const String _supportPhone = '+918001234567';

/// Support email address.
const String _supportEmail = 'support@radha.app';

/// Cached `PackageInfo` for diagnostic context in the email body.
final _supportPackageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Image-picker provider — overridden in tests so no platform channel is
/// touched.
final supportImagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

/// Top-level support / feedback screen.
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bugController = TextEditingController();

  XFile? _screenshot;
  bool _submitting = false;

  @override
  void dispose() {
    _bugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.supportTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(RadhaSpacing.space24),
          children: [
            _StaggerIn(
              index: 0,
              reduceMotion: reduceMotion,
              child: _ContactSection(
                onEmail: _composeContactEmail,
                onCall: _callSupport,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space24),
            _StaggerIn(
              index: 1,
              reduceMotion: reduceMotion,
              child: _ReportBugSection(
                formKey: _formKey,
                bugController: _bugController,
                screenshot: _screenshot,
                submitting: _submitting,
                onPickScreenshot: _pickScreenshot,
                onRemoveScreenshot: () => setState(() => _screenshot = null),
                onSubmit: _submitBug,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space24),
            _StaggerIn(
              index: 2,
              reduceMotion: reduceMotion,
              child: const _FaqSection(),
            ),
            const SizedBox(height: RadhaSpacing.space32),
          ],
        ),
      ),
    );
  }

  // ── Contact actions ─────────────────────────────────────────────────────

  Future<void> _composeContactEmail() async {
    final l10n = AppLocalizations.of(context);
    final pkg = await ref.read(_supportPackageInfoProvider.future);
    final user = ref.read(currentUserProvider);
    final body = _buildEmailBody(
      pkg: pkg,
      userId: user?.userId,
      bugDescription: null,
    );
    final uri = _buildMailto(
      subject: 'Feedback from RADHA mobile',
      body: body,
    );
    if (!await _safeLaunch(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsLinkOpenFailed)),
      );
    }
  }

  Future<void> _callSupport() async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri(scheme: 'tel', path: _supportPhone);
    if (!await _safeLaunch(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsLinkOpenFailed)),
      );
    }
  }

  // ── Bug report flow ─────────────────────────────────────────────────────

  Future<void> _pickScreenshot() async {
    final picker = ref.read(supportImagePickerProvider);
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      setState(() => _screenshot = picked);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _submitBug() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    try {
      // The api_client has no `/api/v1/support/feedback` endpoint today
      // (see file-level note + FE-37 open question). Fall back to a
      // mailto: that pre-fills the diagnostic context inline so the
      // user's report still reaches the team.
      final pkg = await ref.read(_supportPackageInfoProvider.future);
      final user = ref.read(currentUserProvider);
      final body = _buildEmailBody(
        pkg: pkg,
        userId: user?.userId,
        bugDescription: _bugController.text.trim(),
        screenshotName: _screenshot?.name,
      );
      final uri = _buildMailto(
        subject: 'Bug report — RADHA mobile',
        body: body,
      );
      final ok = await _safeLaunch(uri);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.supportSubmitted)),
        );
        _bugController.clear();
        setState(() => _screenshot = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.supportSubmitFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Future<bool> _safeLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Builds a mailto URI. `Uri(scheme: 'mailto', path: …, queryParameters: …)`
  /// is the canonical way; we encode the body manually because `mailto:`
  /// expects plain percent-encoding and `Uri.queryParameters` uses
  /// form-encoding (turns `+` into a literal `+` which mail clients
  /// interpret as a space).
  Uri _buildMailto({required String subject, required String body}) {
    return Uri.parse(
      'mailto:$_supportEmail'
      '?subject=${Uri.encodeQueryComponent(subject)}'
      '&body=${Uri.encodeQueryComponent(body)}',
    );
  }

  /// Composes the email body with diagnostic context. We only include
  /// non-PII fields: app version, platform, build, and user id. Email,
  /// mobile number and other personal identifiers are intentionally
  /// excluded.
  String _buildEmailBody({
    required PackageInfo pkg,
    required String? userId,
    String? bugDescription,
    String? screenshotName,
  }) {
    final platform = defaultTargetPlatform.name;
    final buffer = StringBuffer();
    if (bugDescription != null && bugDescription.isNotEmpty) {
      buffer.writeln('What happened:');
      buffer.writeln(bugDescription);
      buffer.writeln();
    }
    buffer.writeln('---');
    buffer.writeln('App: ${pkg.appName} ${pkg.version} (${pkg.buildNumber})');
    buffer.writeln('Platform: $platform');
    if (userId != null && userId.isNotEmpty) {
      buffer.writeln('User: $userId');
    }
    if (screenshotName != null && screenshotName.isNotEmpty) {
      buffer.writeln('Screenshot attached locally: $screenshotName');
      buffer.writeln('(please attach the file to this email manually)');
    }
    return buffer.toString();
  }
}

// ─── Contact section ─────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.onEmail, required this.onCall});

  final VoidCallback onEmail;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.supportContactUs,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            _ContactTile(
              icon: Icons.mail_outline_rounded,
              label: l10n.supportEmailUs,
              hint: l10n.supportEmailUsHint,
              onTap: onEmail,
            ),
            const SizedBox(height: RadhaSpacing.space12),
            _ContactTile(
              icon: Icons.call_outlined,
              label: l10n.supportCallUs,
              hint: l10n.supportCallUsHint,
              onTap: onCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space12,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: scheme.onSurface),
            const SizedBox(width: RadhaSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bug report section ──────────────────────────────────────────────────

class _ReportBugSection extends StatelessWidget {
  const _ReportBugSection({
    required this.formKey,
    required this.bugController,
    required this.screenshot,
    required this.submitting,
    required this.onPickScreenshot,
    required this.onRemoveScreenshot,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController bugController;
  final XFile? screenshot;
  final bool submitting;
  final VoidCallback onPickScreenshot;
  final VoidCallback onRemoveScreenshot;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.supportReportBug,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: RadhaSpacing.space16),
              TextFormField(
                controller: bugController,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.supportBugDescription,
                  hintText: l10n.supportBugDescriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return l10n.supportBugDescriptionRequired;
                  return null;
                },
              ),
              const SizedBox(height: RadhaSpacing.space16),
              if (screenshot == null)
                _AttachScreenshotButton(onTap: onPickScreenshot)
              else
                _AttachedScreenshotChip(
                  screenshot: screenshot!,
                  onRemove: onRemoveScreenshot,
                ),
              const SizedBox(height: RadhaSpacing.space24),
              PrimaryButton(
                label: l10n.supportSubmit,
                icon: Icons.send_outlined,
                expand: true,
                loading: submitting,
                onPressed: submitting ? null : onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachScreenshotButton extends StatelessWidget {
  const _AttachScreenshotButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: kMinTouchTarget,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.image_outlined, size: 18),
        label: Text(l10n.supportAttachScreenshot),
      ),
    );
  }
}

class _AttachedScreenshotChip extends StatelessWidget {
  const _AttachedScreenshotChip({
    required this.screenshot,
    required this.onRemove,
  });

  final XFile screenshot;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Text(
              screenshot.name.isEmpty
                  ? l10n.supportScreenshotAttached
                  : screenshot.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text(l10n.supportRemoveScreenshot),
          ),
        ],
      ),
    );
  }
}

// ─── FAQ section ─────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final faqs = <(String, String)>[
      (l10n.supportFaqQ1, l10n.supportFaqA1),
      (l10n.supportFaqQ2, l10n.supportFaqA2),
      (l10n.supportFaqQ3, l10n.supportFaqA3),
      (l10n.supportFaqQ4, l10n.supportFaqA4),
      (l10n.supportFaqQ5, l10n.supportFaqA5),
    ];

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space8,
          vertical: RadhaSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space16,
              ),
              child: Text(
                l10n.supportFaq,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            // Strip the default ExpansionTile divider — we want the
            // sections to read as a single grouped surface.
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (final (question, answer) in faqs)
                    _FaqTile(question: question, answer: answer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space4,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        0,
        RadhaSpacing.space16,
        RadhaSpacing.space16,
      ),
      title: Text(
        question,
        style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurface),
      ),
      iconColor: scheme.onSurfaceVariant,
      collapsedIconColor: scheme.onSurfaceVariant,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Entrance ──────────────────────────────────────────────────────────────

/// Staggered fade + rise used for the screen's three sections. Honours the
/// platform reduce-motion flag by rendering the child immediately.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({
    required this.index,
    required this.reduceMotion,
    required this.child,
  });

  final int index;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    // Interval-based stagger (no dangling Timer) so the delay is part of the
    // animation curve. Keeps widget tests that pump a single frame clean.
    final start = (widget.index * 0.12).clamp(0.0, 0.6);
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: RadhaMotion.easeOut),
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curve);
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
