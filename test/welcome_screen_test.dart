import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/welcome/welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WelcomeScreen Cinematic Candi Bentar Gate Tests', () {
    testWidgets('Renders opened gate and shows editorial UI and CTAs', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(playGateOpen: false),
        ),
      );

      // Pump enough to let the frame render
      await tester.pump(const Duration(milliseconds: 100));

      // Verify WelcomeScreen mounts
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // In playGateOpen: false (immediately opened), editorial UI and buttons exist
      expect(find.text('Mengenal warisan.\nMemahami makna.'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi Budaya'), findsOneWidget);
      expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
      expect(find.textContaining('ꦗ ꦮ ꦫ'), findsWidgets);
    });

    testWidgets('Zero RenderFlex overflow across various mobile screen widths', (tester) async {
      final widths = [320.0, 360.0, 390.0, 412.0, 600.0];
      final errors = <FlutterErrorDetails>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        for (final w in widths) {
          tester.view.physicalSize = Size(w * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: WelcomeScreen(playGateOpen: false),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }

        final overflows = errors.where((e) => e.toString().contains('overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Detected overflow errors: $overflows');
      } finally {
        FlutterError.onError = prevOnError;
        tester.view.resetPhysicalSize();
      }
    });

    testWidgets('Tapping anywhere triggers skipToOpen cleanly', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(playGateOpen: true),
        ),
      );

      // Initially closed / opening
      await tester.pump(const Duration(milliseconds: 50));

      // Tap screen to skipToOpen
      await tester.tap(find.byType(GestureDetector).first);
      // Pump with fixed duration (not pumpAndSettle, since ambient animation loops infinitely)
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });
}
