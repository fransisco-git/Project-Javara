import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WelcomeScreen Heritage Borobudur Tests', () {
    testWidgets('Renders heritage background and shows editorial UI and CTAs immediately', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Pump enough to let the frame render
      await tester.pump(const Duration(milliseconds: 100));

      // Verify WelcomeScreen mounts
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Editorial UI and buttons exist immediately without opening delays
      expect(find.text('Mengenal warisan.\nMemahami makna.'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi Budaya'), findsOneWidget);
      expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
      expect(find.text('Daftar Akun Baru'), findsOneWidget);
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
              home: WelcomeScreen(),
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

    testWidgets('Audio toggle button can be tapped cleanly', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Look for audio toggle or foley badge
      final audioToggleFinder = find.byType(InkWell);
      expect(audioToggleFinder, findsWidgets);

      await tester.tap(audioToggleFinder.first);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('Tapping Mulai Eksplorasi Budaya signs in as guest automatically', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final exploreFinder = find.text('Mulai Eksplorasi Budaya');
      expect(exploreFinder, findsOneWidget);

      await tester.tap(exploreFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('javara_is_guest'), isTrue);
      expect(prefs.getString('javara_profile_name'), 'Tamu JAVARA');
      expect(prefs.getString('javara_profile_email'), 'tamu.budaya@javara.id');
    });
  });
}
