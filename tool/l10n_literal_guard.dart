// Visible-literal guard (D10/D12).
//
// Fails CI when a likely *user-facing* string literal is hard-coded in a
// production widget instead of being routed through `AppLocalizations`.
//
// Usage:
//   dart run tool/l10n_literal_guard.dart            # scan, exit 1 on findings
//   dart run tool/l10n_literal_guard.dart --report   # list findings, exit 0
//
// Suppression (use sparingly, only for genuinely non-translatable copy):
//   * Put `// l10n-ignore` on the same line as the literal, OR
//   * Add the exact literal to tool/l10n_allowlist.txt (one per line, '#' comments).
//
// Heuristic, not a parser: it targets the constructors/params that almost
// always carry visible copy (Text, SnackBar, AppBar title, labelText, hintText,
// tooltip, semanticLabel, helperText, errorText, and `label:`/`title:`/
// `subtitle:`/`message:` string args). It deliberately errs toward flagging;
// triage false positives with the allowlist or an inline ignore.

import 'dart:io';

/// Directories under lib/ that never contain shippable UI copy.
const _excludedDirs = <String>{
  'l10n/generated',
};

/// Param names / call shapes whose string argument is almost always visible.
final _patterns = <RegExp>[
  RegExp(r'''\bText\(\s*(['"])(.*?)\1'''),
  RegExp(r'''\b(?:labelText|hintText|helperText|errorText|tooltip|semanticLabel|label|title|subtitle|message|content|heading|placeholder)\s*:\s*(['"])(.*?)\1'''),
];

/// Literals that are never user copy even if they match a pattern above.
bool _isObviouslyNonCopy(String s) {
  final t = s.trim();
  if (t.isEmpty) return true;
  // Strip Dart string interpolations (`${expr}` and `$ident`) so a value-only
  // template like "${score}/100" reads as having no real copy.
  final stripped = t
      .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '')
      .trim();
  if (stripped.isEmpty) return true;
  // No letters at all (symbols, numbers, separators like " · ").
  if (!RegExp(r'[A-Za-z]').hasMatch(stripped)) return true;
  // Asset paths, URLs, package refs, route paths.
  if (RegExp(r'^(assets/|https?:|package:|/|mailto:|tel:)').hasMatch(t)) {
    return true;
  }
  // Single token in SCREAMING_SNAKE or snake_case or kebab — likely an
  // enum/key/route constant, not a sentence.
  if (RegExp(r'^[a-z0-9]+([_-][a-z0-9]+)+$').hasMatch(t)) return true;
  if (RegExp(r'^[A-Z0-9]+(_[A-Z0-9]+)*$').hasMatch(t)) return true;
  // A lone short token with no spaces and not Capitalized-word (e.g. "px",
  // "ID"). Capitalized single words (e.g. "Save") are still flagged.
  if (!t.contains(' ') && t.length <= 2) return true;
  return false;
}

/// Brand / proper-noun allowlist that is fine to leave verbatim everywhere.
const _brandAllow = <String>{
  'RADHA',
  'Mor',
  'EAN',
  'UPC',
  'GTIN',
  'GRN',
  'OHS',
  'OCR',
  'Razorpay',
  'Gemini',
};

void main(List<String> args) {
  final reportOnly = args.contains('--report');
  final root = Directory('lib');
  if (!root.existsSync()) {
    stderr.writeln('l10n-guard: run from the radha_app/ package root.');
    exit(2);
  }

  final allowlist = _loadAllowlist();
  final findings = <_Finding>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final rel = entity.path.replaceAll(r'\', '/');
    if (_excludedDirs.any((d) => rel.contains('/$d/'))) continue;
    if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('l10n-ignore')) continue;
      for (final pat in _patterns) {
        for (final m in pat.allMatches(line)) {
          final literal = m.group(2) ?? '';
          if (_isObviouslyNonCopy(literal)) continue;
          if (_brandAllow.contains(literal.trim())) continue;
          if (allowlist.contains(literal.trim())) continue;
          findings.add(_Finding(rel, i + 1, literal.trim()));
        }
      }
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('l10n-guard: OK — no hard-coded user-facing literals found.');
    exit(0);
  }

  final byFile = <String, List<_Finding>>{};
  for (final f in findings) {
    byFile.putIfAbsent(f.file, () => []).add(f);
  }
  stdout.writeln(
    'l10n-guard: ${findings.length} likely hard-coded literal(s) in '
    '${byFile.length} file(s):\n',
  );
  for (final entry in byFile.entries) {
    stdout.writeln(entry.key);
    for (final f in entry.value) {
      stdout.writeln('  ${f.line}: "${f.literal}"');
    }
    stdout.writeln('');
  }
  stdout.writeln(
    'Route these through AppLocalizations, or suppress with `// l10n-ignore` '
    '/ tool/l10n_allowlist.txt if genuinely non-translatable.',
  );
  exit(reportOnly ? 0 : 1);
}

Set<String> _loadAllowlist() {
  final f = File('tool/l10n_allowlist.txt');
  if (!f.existsSync()) return <String>{};
  return f
      .readAsLinesSync()
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .toSet();
}

class _Finding {
  _Finding(this.file, this.line, this.literal);
  final String file;
  final int line;
  final String literal;
}
