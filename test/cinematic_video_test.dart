import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/splash/cinematic_intro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Javara Cinematic Intro & Video Player Integration Tests', () {
    testWidgets('Renders cinematic intro with controls and handles skip action', (tester) async {
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

      // Verify header badge exists
      expect(find.textContaining('ꦗ ꦮ ꦫ'), findsWidgets);

      // Verify "Lewati / Masuk" button exists
      final skipButton = find.text('Lewati / Masuk');
      expect(skipButton, findsOneWidget);

      // Verify mute/unmute toggle exists
      final muteBtn = find.byIcon(Icons.volume_up_rounded);
      expect(muteBtn, findsOneWidget);

      // Tap mute button
      await tester.tap(muteBtn);
      await tester.pump();
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);

      // Tap skip button
      await tester.tap(skipButton);
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('Zero RenderFlex overflow across various phone screen widths', (tester) async {
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
  });
}
