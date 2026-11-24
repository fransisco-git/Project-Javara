import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/auth/login_screen.dart';
import 'package:jawara_app/features/auth/signup_screen.dart';
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
      await tester.pump(const Duration(milliseconds: 600));

      // Verify WelcomeScreen mounts
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Editorial UI and buttons exist immediately
      expect(find.text('Mengenal warisan.\nMemahami makna.'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi Budaya'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
      expect(find.text(' · '), findsNothing); // Separated by dot character '·'
      expect(find.text('·'), findsOneWidget);

      // Aksara Jawa element above headline is commented out (hidden)
      expect(find.textContaining('ꦗ ꦮ ꦫ'), findsNothing);
    });

    testWidgets('Zero RenderFlex overflow across various mobile screen sizes and text scale 1.3', (tester) async {
      final testCases = [
        const Size(320.0, 600.0),
        const Size(360.0, 640.0),
        const Size(360.0, 800.0),
        const Size(390.0, 844.0),
        const Size(412.0, 915.0),
        const Size(600.0, 900.0),
      ];

      final errors = <FlutterErrorDetails>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        for (final size in testCases) {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;

          // Test standard text scale and large text scale 1.3
          for (final scale in [1.0, 1.3]) {
            await tester.pumpWidget(
              MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                    padding: const EdgeInsets.only(top: 24, bottom: 34),
                    viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
                  ),
                  child: const WelcomeScreen(),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 200));

            // Verify essential interactive elements are present and mounted
            expect(find.text('Mulai Eksplorasi Budaya'), findsOneWidget);
            expect(find.text('Masuk'), findsOneWidget);
            expect(find.text('Daftar'), findsOneWidget);
          }
        }

        final overflows = errors.where((e) => e.toString().contains('overflowed')).toList();
        expect(overflows, isEmpty, reason: 'Detected overflow errors: $overflows');
      } finally {
        FlutterError.onError = prevOnError;
        tester.view.resetPhysicalSize();
      }
    });

    testWidgets('Top header icons (search, inventory, audio) and logo are not rendered for serene aesthetic', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Header is kept clean and serene without top wordmark or action icons
      expect(find.text('J A V A R A'), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
      expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      expect(find.byIcon(Icons.volume_off_rounded), findsNothing);
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
      await tester.pump(const Duration(milliseconds: 600));

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

    testWidgets('Tapping Masuk navigates to LoginScreen and Daftar navigates to SignUpScreen', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Verify Masuk TextButton has minimum 48x48 tap target
      final masukFinder = find.widgetWithText(TextButton, 'Masuk');
      expect(masukFinder, findsOneWidget);
      final masukButton = tester.widget<TextButton>(masukFinder);
      expect(masukButton.style?.minimumSize?.resolve({}), const Size(48, 48));
      expect(tester.getSize(masukFinder).height, greaterThanOrEqualTo(48.0));

      // Verify Daftar TextButton has minimum 48x48 tap target
      final daftarFinder = find.widgetWithText(TextButton, 'Daftar');
      expect(daftarFinder, findsOneWidget);
      final daftarButton = tester.widget<TextButton>(daftarFinder);
      expect(daftarButton.style?.minimumSize?.resolve({}), const Size(48, 48));
      expect(tester.getSize(daftarFinder).height, greaterThanOrEqualTo(48.0));

      // Tap Masuk and verify navigation to LoginScreen
      await tester.tap(masukFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LoginScreen), findsOneWidget);

      // Pop back to WelcomeScreen
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Tap Daftar and verify navigation to SignUpScreen
      await tester.tap(daftarFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('Responsive headline font size scales to 28sp when height < 700dp', (tester) async {
      // Test height < 700dp
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final headlineFinder = find.text('Mengenal warisan.\nMemahami makna.');
      expect(headlineFinder, findsOneWidget);
      final textWidgetSmall = tester.widget<Text>(headlineFinder);
      expect(textWidgetSmall.style?.fontSize, 28);

      // Test height >= 700dp
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final textWidgetLarge = tester.widget<Text>(headlineFinder);
      expect(textWidgetLarge.style?.fontSize, 34);
    });

    testWidgets('Respects MediaQuery.disableAnimations', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              disableAnimations: true,
            ),
            child: WelcomeScreen(),
          ),
        ),
      );

      // Frame renders immediately
      await tester.pump();

      expect(find.text('Mengenal warisan.\nMemahami makna.'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi Budaya'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });
  });
}
