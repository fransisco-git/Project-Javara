import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Javara Splash Screen Tests', () {
    testWidgets('Renders elegant splash brand logo, Aksara Jawa, and loading steps', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify Aksara Jawa logo text is displayed (both in logo and subtitle)
      expect(find.text('ꦗ ꦮ ꦫ'), findsWidgets);

      // Verify subtitle text
      expect(find.text('WARISAN BUSANA JAWA TENGAH'), findsOneWidget);

      // Verify skip (Lewati) button is removed
      expect(find.text('Lewati'), findsNothing);

      // Pump a short duration to verify loading step
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Busana Adat Jawa'), findsOneWidget);
    });

    testWidgets('Zero RenderFlex overflow across various mobile screen widths', (tester) async {
      final widths = [320.0, 360.0, 390.0, 412.0];
      final errors = <FlutterErrorDetails>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        for (final w in widths) {
          tester.view.physicalSize = Size(w * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: SplashScreen(),
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
  });
}
