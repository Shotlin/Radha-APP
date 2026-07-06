import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/radha_status_chip.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, Widget chip) {
    return tester.pumpWidget(
      MaterialApp(
        theme: radhaLightTheme(),
        home: Scaffold(body: Center(child: chip)),
      ),
    );
  }

  testWidgets('renders the localized label text', (tester) async {
    await pumpChip(
      tester,
      const RadhaStatusChip(label: 'Posted', tone: RadhaStatusTone.success),
    );
    expect(find.text('Posted'), findsOneWidget);
  });

  testWidgets('each tone maps to its functional token colour', (tester) async {
    const cases = {
      RadhaStatusTone.success: RadhaColors.success,
      RadhaStatusTone.warning: RadhaColors.warning,
      RadhaStatusTone.danger: RadhaColors.danger,
      RadhaStatusTone.info: RadhaColors.complement,
      RadhaStatusTone.neutral: RadhaColors.inkMuted,
    };
    for (final entry in cases.entries) {
      await pumpChip(tester, RadhaStatusChip(label: 'X', tone: entry.key));
      final text = tester.widget<Text>(find.text('X'));
      expect(text.style!.color, entry.value, reason: '${entry.key}');
    }
  });

  testWidgets('renders an optional leading glyph (not colour-alone)', (
    tester,
  ) async {
    await pumpChip(
      tester,
      const RadhaStatusChip(
        label: 'Urgent',
        tone: RadhaStatusTone.danger,
        icon: Icons.warning_amber_rounded,
      ),
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
  });
}
