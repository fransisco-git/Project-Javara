import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/fashion/data/javanese_clothing_data.dart';
import 'package:jawara_app/features/fashion/screens/ai_fashion_studio_screen.dart';
import 'package:jawara_app/features/fashion/screens/clothing_detail_screen.dart';
import 'package:jawara_app/features/fashion/screens/javara_studio_screen.dart';

void main() {
  group('JAVARA Fashion Studio & Virtual Try-On Widget Tests', () {
    testWidgets('JavaraStudioScreen initializes properly in AI Model Mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: JavaraStudioScreen(
            initialMode: StudioViewingMode.aiModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Viewing Mode selector buttons
      expect(find.byType(JavaraStudioScreen), findsOneWidget);
      expect(find.text('Model AI'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
      expect(find.text('Foto Anda'), findsOneWidget);
    });

    testWidgets('AiFashionStudioScreen forwards seamlessly to JavaraStudioScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: AiFashionStudioScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(JavaraStudioScreen), findsOneWidget);
      expect(find.text('Model AI'), findsOneWidget);
    });

    testWidgets('ClothingDetailScreen provides both Virtual Try-On and 3D buttons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final sampleItem = JavaneseClothingData.clothingItems.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ClothingDetailScreen(item: sampleItem),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coba Virtual Try-On (AI Studio)'), findsOneWidget);
      expect(find.text('Coba di Studio Busana 3D'), findsOneWidget);
    });
  });
}
