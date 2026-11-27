import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/fashion/data/javanese_clothing_data.dart';
import 'package:jawara_app/features/fashion/screens/clothing_detail_screen.dart';

void main() {
  group('ClothingDetailScreen Virtual Try-On Removal & Layout Tests', () {
    testWidgets(
      'ClothingDetailScreen omits Virtual Try-On / AI Studio button and keeps Cari Tempat Membeli',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final sampleItem = JavaneseClothingData.clothingItems.first;

        await tester.pumpWidget(
          MaterialApp(
            home: ClothingDetailScreen(item: sampleItem),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Coba Virtual Try-On (AI Studio)'), findsNothing);
        expect(find.textContaining('Virtual Try-On'), findsNothing);
        expect(find.textContaining('AI Studio'), findsNothing);
        expect(find.text('Coba di Studio Busana 3D'), findsNothing);
        expect(find.text('Cari Tempat Membeli'), findsOneWidget);
      },
    );

    testWidgets(
      'ClothingDetailScreen has zero RenderFlex overflow at 360 dp and 1.3 text scale',
      (tester) async {
        tester.view.physicalSize = const Size(720, 1600);
        tester.view.devicePixelRatio = 2.0; // 360 x 800 logical dp
        addTearDown(tester.view.reset);

        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
        };

        final sampleItem = JavaneseClothingData.clothingItems.first;

        try {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              ),
              home: ClothingDetailScreen(item: sampleItem),
            ),
          );
          await tester.pumpAndSettle();

          // Scroll down to verify lower cards & compatible garments without overflow
          await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = prevOnError;
        }

        expect(find.text('Cari Tempat Membeli'), findsOneWidget);
        expect(find.textContaining('Virtual Try-On'), findsNothing);
        expect(find.textContaining('AI Studio'), findsNothing);

        final overflowErrors = errors
            .where((e) => e.exceptionAsString().contains('overflowed'))
            .toList();
        expect(
          overflowErrors,
          isEmpty,
          reason: 'Expected zero RenderFlex overflow at 360dp / 1.3x text scale',
        );
      },
    );
  });
}
