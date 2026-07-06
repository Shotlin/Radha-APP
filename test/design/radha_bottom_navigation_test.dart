import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/widgets/radha_bottom_navigation.dart';

void main() {
  const destinations = <RadhaNavDestination>[
    RadhaNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    RadhaNavDestination(
      icon: Icons.qr_code_scanner_rounded,
      selectedIcon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
      emphasized: true,
    ),
    RadhaNavDestination(
      icon: Icons.event_outlined,
      selectedIcon: Icons.event_rounded,
      label: 'Expiry',
    ),
    RadhaNavDestination(
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist_rounded,
      label: 'Tasks',
    ),
    RadhaNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  Future<void> pumpNav(
    WidgetTester tester, {
    int currentIndex = 0,
    required ValueChanged<int> onTap,
    List<RadhaNavDestination> items = destinations,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: radhaLightTheme(),
        home: Scaffold(
          bottomNavigationBar: RadhaBottomNavigation(
            currentIndex: currentIndex,
            destinations: items,
            onDestinationSelected: onTap,
          ),
        ),
      ),
    );
  }

  testWidgets('renders all five destination labels', (tester) async {
    await pumpNav(tester, onTap: (_) {});
    for (final label in ['Home', 'Scan', 'Expiry', 'Tasks', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('reports the tapped destination index', (tester) async {
    int? tapped;
    await pumpNav(tester, onTap: (i) => tapped = i);
    await tester.tap(find.text('Tasks'));
    await tester.pump();
    expect(tapped, 3);
  });

  testWidgets('the active tab is announced as a selected button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpNav(tester, currentIndex: 2, onTap: (_) {});

    expect(
      tester.getSemantics(find.bySemanticsLabel('Expiry')),
      isSemantics(isButton: true, isSelected: true),
    );

    // A non-active tab is not flagged selected.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      isSemantics(isButton: true, isSelected: false),
    );

    handle.dispose();
  });

  testWidgets('renders a badge only for a positive count', (tester) async {
    const items = <RadhaNavDestination>[
      RadhaNavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
        badgeCount: 3,
      ),
      RadhaNavDestination(
        icon: Icons.event_outlined,
        selectedIcon: Icons.event_rounded,
        label: 'Expiry',
        badgeCount: 0,
      ),
    ];
    await pumpNav(tester, onTap: (_) {}, items: items);

    // Positive count is shown; a zero count never renders a fabricated badge.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
