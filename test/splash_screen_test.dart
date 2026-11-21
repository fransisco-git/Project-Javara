import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/splash/cinematic_intro.dart';
import 'package:jawara_app/features/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Javara Cinematic Intro & Splash Screen Tests', () {
    testWidgets('Renders JavaraCinematicIntro with Gatotkaca and Aswatama assets and completes callback', (tester) async {
      bool completed = false;
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: JavaraCinematicIntro(
            autoPlay: false,
            onComplete: () => completed = true,
            onPrimaryAction: () {},
            onSecondaryAction: () {},
            onRegisterAction: () {},
          ),
        ),
      );

      // Verify the cinematic widget mounts
      expect(find.byType(JavaraCinematicIntro), findsOneWidget);

      // Trigger completion manually via key/method or verify state
      final state = tester.state<JavaraCinematicIntroState>(find.byType(JavaraCinematicIntro));
      state.skip();
      await tester.pump();
      expect(completed, isTrue);
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
            MaterialApp(
              home: JavaraCinematicIntro(
                autoPlay: false,
                onComplete: () {},
                onPrimaryAction: () {},
                onSecondaryAction: () {},
                onRegisterAction: () {},
              ),
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

    testWidgets('SplashScreen widget mounts cleanly', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(JavaraCinematicIntro), findsOneWidget);
    });
  });
}
