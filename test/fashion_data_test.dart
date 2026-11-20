import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/fashion/data/javanese_clothing_data.dart';
import 'package:jawara_app/features/fashion/models/javanese_clothing_models.dart';

void main() {
  group('Javanese Traditional Fashion Data Architecture Tests', () {
    test('Headwear collection has valid historical items', () {
      expect(JavaneseClothingData.headwearItems, isNotEmpty);
      final blangkonSolo = JavaneseClothingData.getItemById('blangkon_surakarta_parang');
      expect(blangkonSolo, isNotNull);
      expect(blangkonSolo!.name, contains('Surakarta'));
      expect(blangkonSolo.category, equals(ClothingCategory.headwear));
      expect(blangkonSolo.gender, equals(GenderTarget.pria));
    });

    test('Upper body collection has valid Beskap and Kebaya', () {
      expect(JavaneseClothingData.upperBodyItems, isNotEmpty);
      final beskap = JavaneseClothingData.getItemById('beskap_landhung_solo');
      expect(beskap, isNotNull);
      expect(beskap!.category, equals(ClothingCategory.upperBody));

      final kebaya = JavaneseClothingData.getItemById('kebaya_kartini_beludru_jepara');
      expect(kebaya, isNotNull);
      expect(kebaya!.gender, equals(GenderTarget.wanita));
      expect(kebaya.region, equals(TraditionRegion.jepara));
    });

    test('Lower body collection has valid Batik Jarik items', () {
      expect(JavaneseClothingData.lowerBodyItems, isNotEmpty);
      final jarik = JavaneseClothingData.getItemById('jarik_batik_parang_barong_solo');
      expect(jarik, isNotNull);
      expect(jarik!.category, equals(ClothingCategory.lowerBody));
    });

    test('Curated outfits collection contains authentic combinations', () {
      expect(JavaneseClothingData.curatedOutfits, isNotEmpty);
      final jawiJangkep = JavaneseClothingData.curatedOutfits.first;
      expect(jawiJangkep.title, contains('Jawi Jangkep'));
      expect(jawiJangkep.headwearId, equals('blangkon_surakarta_parang'));
      expect(jawiJangkep.upperBodyId, equals('beskap_landhung_solo'));
    });

    test('Batik motifs collection contains documented heritage and larangan status', () {
      expect(JavaneseClothingData.batikMotifs, isNotEmpty);
      final parangBarong = JavaneseClothingData.batikMotifs.firstWhere(
        (m) => m.id == 'motif_parang_barong',
      );
      expect(parangBarong.isLarangan, isTrue);
    });

    test('Fashion quizzes have verified options and correct answer indices', () {
      expect(JavaneseClothingData.fashionQuizzes, isNotEmpty);
      for (final quiz in JavaneseClothingData.fashionQuizzes) {
        expect(quiz.options.length, greaterThanOrEqualTo(2));
        expect(quiz.correctOptionIndex, inInclusiveRange(0, quiz.options.length - 1));
        expect(quiz.historicalExplanation, isNotEmpty);
      }
    });
  });
}

