import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/tokens.dart';

void main() {
  testWidgets('light theme is Material 3 and uses the brand primary orange', (
    tester,
  ) async {
    final theme = radhaLightTheme();
    await tester.pumpWidget(MaterialApp(theme: theme, home: const SizedBox()));

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, RadhaColors.primary);
    expect(theme.scaffoldBackgroundColor, RadhaColors.paper);
  });

  testWidgets('dark theme keeps the brand primary and switches surface to ink', (
    tester,
  ) async {
    final theme = radhaDarkTheme();
    await tester.pumpWidget(MaterialApp(theme: theme, home: const SizedBox()));

    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, RadhaColors.primary);
    expect(theme.colorScheme.surface, RadhaColors.ink);
  });

  testWidgets('mono helper applies tabular figures for numeric contexts', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final style = radhaMonoStyle();
    expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
  });
}
