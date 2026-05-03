import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:period_tracker_app/main.dart';

void main() {
  testWidgets('opens LunaCycle today screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainShell(
          state: AppState.sample(),
          onChanged: (_) {},
          onClearData: () async {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('today quick actions open daily log and cancel returns home', (
    WidgetTester tester,
  ) async {
    var state = AppState.sample();

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return MainShell(
              state: state,
              onChanged: (next) => setState(() => state = next),
              onClearData: () async {
                setState(() => state = AppState.sample());
              },
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Log flow'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Record Daily Health'), findsOneWidget);
    expect(find.text('Menstrual Flow'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -1200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Cancel Changes'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('Good'), findsOneWidget);
  });
}
