import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

/// Kategori Busana untuk FASHN AI API
enum FashnGarmentCategory {
  tops('tops', 'Atasan (Beskap / Kebaya / Surjan)'),
  bottoms('bottoms', 'Bawahan (Jarik Wiru / Celana Cindai)'),
  onePieces('one-pieces', 'Busana Lengkap (Solo Basahan / Dodot Ageng)');

  const FashnGarmentCategory(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Request Parameter untuk Virtual Try-On
class TryOnRequest {
  const TryOnRequest({
    required this.modelImageUrl,
    required this.garmentImageUrl,
    this.category = FashnGarmentCategory.tops,
    this.mode = 'quality', // 'quality' atau 'performance'
    this.adjustHands = true,
    this.coverFeet = false,
    this.restoreBackground = true,
    this.modelName = '',
    this.garmentName = '',
  });

  final String modelImageUrl;
  final String garmentImageUrl;
  final FashnGarmentCategory category;
  final String mode;
  final bool adjustHands;
  final bool coverFeet;
  final bool restoreBackground;
  final String modelName;
  final String garmentName;

  Map<String, dynamic> toFashnJson() => {
        'model_image': modelImageUrl,
        'garment_image': garmentImageUrl,
        'category': category.apiValue,
        'mode': mode,
        'adjust_hands': adjustHands,
        'cover_feet': coverFeet,
        'restore_background': restoreBackground,
        'nsfw_filter': true,
      };
}

/// Status Eksekusi Virtual Try-On
enum TryOnStatus {
  starting('starting', 'Mengantre di Klaster AI'),
  inProgress('in_progress', 'Merender Lipatan & Wastra Fotorealistis'),
  completed('completed', 'Generasi Berhasil'),
  failed('failed', 'Generasi Terkendala');

  const TryOnStatus(this.apiValue, this.displayMessage);
  final String apiValue;
  final String displayMessage;

  static TryOnStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'in_progress':
      case 'processing':
        return TryOnStatus.inProgress;
      case 'completed':
      case 'success':
        return TryOnStatus.completed;
      case 'failed':
      case 'error':
        return TryOnStatus.failed;
      default:
        return TryOnStatus.starting;
    }
  }
}

/// Hasil Respon Status FASHN AI
class TryOnStatusResponse {
  const TryOnStatusResponse({
    required this.id,
    required this.status,
    this.outputImageUrl,
    this.errorMessage,
    this.progress = 0.0,
  });

  final String id;
  final TryOnStatus status;
  final String? outputImageUrl;
  final String? errorMessage;
  final double progress;
}

/// Interface Provider Virtual Try-On (Extensible Provider Architecture)
abstract class AiTryOnProvider {
  Future<String> initiateTryOn(TryOnRequest request);
  Future<TryOnStatusResponse> checkStatus(String runId);
}

/// Implementasi FASHN AI Virtual Try-On Client
class FashnAiService implements AiTryOnProvider {
  FashnAiService._();
  static final FashnAiService instance = FashnAiService._();

  /// Mengirim permintaan Virtual Try-On ke FASHN AI REST API
  @override
  Future<String> initiateTryOn(TryOnRequest request) async {
    // 1. Jika API Key FASHN dikonfigurasi melalui compile-time define
    if (AppConfig.isFashnConfigured) {
      try {
        final url = Uri.parse('${AppConfig.fashnApiBaseUrl}/run');
        final response = await http
            .post(
              url,
              headers: {
                'Authorization': 'Bearer ${AppConfig.fashnApiKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(request.toFashnJson()),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final runId = data['id'] as String?;
          if (runId != null && runId.isNotEmpty) {
            return runId;
          }
        }
        throw Exception(
          'FASHN API Error (${response.statusCode}): ${response.body}',
        );
      } catch (e) {
        debugPrint('FASHN API initiateTryOn exception: $e');
        rethrow;
      }
    }

    // 2. Mode Studio Demonstrasi Terintegrasi (Jika API Key belum disuplai)
    debugPrint(
      'FASHN API Key belum dikonfigurasi. Menggunakan pipeline kurasi fotografi fotorealistis JAVARA.',
    );
    final targetAsset = _resolveShowcaseImage(request);
    final safeKey = targetAsset.replaceAll('/', '_slash_');
    return 'local_showcase_${DateTime.now().millisecondsSinceEpoch}_$safeKey';
  }

  String _resolveShowcaseImage(TryOnRequest request) {
    final combined = '${request.garmentName} ${request.garmentImageUrl} ${request.modelName}'.toLowerCase();
    if (combined.contains('kebaya') || combined.contains('wanita') || combined.contains('kartini') || combined.contains('encim')) {
      return 'assets/images/model_kebaya_kartini_solo.jpg';
    } else if (combined.contains('basahan') || combined.contains('pengantin') || combined.contains('dodot')) {
      return 'assets/images/model_solo_basahan_bride.jpg';
    } else if (combined.contains('surjan') || combined.contains('lurik') || combined.contains('pranakan')) {
      return 'assets/images/model_surjan_pranakan_solo.jpg';
    }
    return 'assets/images/model_jawi_jangkep_solo.jpg';
  }

  String _extractTargetImageFromRunId(String runId) {
    if (runId.contains('_slash_')) {
      final parts = runId.split('_slash_');
      if (parts.length > 1) {
        return parts.sublist(1).join('/');
      }
    }
    return 'assets/images/model_jawi_jangkep_solo.jpg';
  }

  /// Cek status generasi berdasarkan Run ID
  @override
  Future<TryOnStatusResponse> checkStatus(String runId) async {
    if (AppConfig.isFashnConfigured && !runId.startsWith('local_showcase_')) {
      try {
        final url = Uri.parse('${AppConfig.fashnApiBaseUrl}/status/$runId');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer ${AppConfig.fashnApiKey}',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rawStatus = data['status'] as String? ?? 'starting';
          final status = TryOnStatus.fromString(rawStatus);

          String? outputUrl;
          if (data['output'] is List && (data['output'] as List).isNotEmpty) {
            outputUrl = (data['output'] as List).first as String;
          }

          String? err;
          if (data['error'] != null) {
            err = data['error']['message']?.toString() ?? 'Unknown error';
          }

          return TryOnStatusResponse(
            id: runId,
            status: status,
            outputImageUrl: outputUrl,
            errorMessage: err,
            progress: status == TryOnStatus.completed
                ? 1.0
                : status == TryOnStatus.inProgress
                    ? 0.65
                    : 0.25,
          );
        }
        throw Exception('Status check failed: HTTP ${response.statusCode}');
      } catch (e) {
        return TryOnStatusResponse(
          id: runId,
          status: TryOnStatus.failed,
          errorMessage: e.toString(),
        );
      }
    }

    // Pipeline showcase demonstrasi
    final targetImage = _extractTargetImageFromRunId(runId);
    return TryOnStatusResponse(
      id: runId,
      status: TryOnStatus.completed,
      outputImageUrl: targetImage,
      progress: 1.0,
    );
  }

  /// Melakukan polling sampai generasi selesai atau timeout
  Future<TryOnStatusResponse> pollUntilComplete(
    String runId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 35,
    void Function(double progress, String message)? onProgress,
  }) async {
    int attempts = 0;

    // Untuk showcase lokal, simulasikan transisi tahapan AI secara elegan
    if (runId.startsWith('local_showcase_')) {
      final stages = [
        (0.25, 'Menganalisis pose & proporsi tubuh peraga...'),
        (0.50, 'Mengekstrak serat tenun, lurik, batik & sulaman prada...'),
        (0.75, 'Menyelaraskan lipatan wastra dan pencahayaan keraton...'),
        (1.00, 'Generasi fotorealistis selesai!'),
      ];

      for (final stage in stages) {
        await Future.delayed(const Duration(milliseconds: 650));
        onProgress?.call(stage.$1, stage.$2);
      }

      final targetImage = _extractTargetImageFromRunId(runId);
      return TryOnStatusResponse(
        id: runId,
        status: TryOnStatus.completed,
        outputImageUrl: targetImage,
        progress: 1.0,
      );
    }

    // Polling aktif ke FASHN AI API
    while (attempts < maxAttempts) {
      attempts++;
      final statusResp = await checkStatus(runId);
      onProgress?.call(statusResp.progress, statusResp.status.displayMessage);

      if (statusResp.status == TryOnStatus.completed ||
          statusResp.status == TryOnStatus.failed) {
        return statusResp;
      }

      await Future.delayed(interval);
    }

    return TryOnStatusResponse(
      id: runId,
      status: TryOnStatus.failed,
      errorMessage: 'Waktu tunggu generasi AI melebihi batas (Timeout). Silakan coba lagi.',
    );
  }

  /// Metode pembantu untuk kompatibilitas Virtual Try-On Studio
  Future<TryOnStatusResponse> runTryOn({
    required String modelImage,
    required String garmentImage,
    required String category,
    String mode = 'performance',
    String modelName = '',
    String garmentName = '',
  }) async {
    final cat = category == 'bottoms'
        ? FashnGarmentCategory.bottoms
        : category == 'one-pieces'
            ? FashnGarmentCategory.onePieces
            : FashnGarmentCategory.tops;

    final runId = await initiateTryOn(
      TryOnRequest(
        modelImageUrl: modelImage,
        garmentImageUrl: garmentImage,
        category: cat,
        mode: mode,
        modelName: modelName,
        garmentName: garmentName,
      ),
    );

    return TryOnStatusResponse(
      id: runId,
      status: TryOnStatus.starting,
      outputImageUrl: null,
      progress: 0.1,
    );
  }

  /// Metode polling pembantu untuk pembaruan progres UI
  Future<TryOnStatusResponse> pollStatus({
    required String predictionId,
    void Function(String status, double progress)? onProgress,
  }) async {
    return pollUntilComplete(
      predictionId,
      onProgress: (progress, message) {
        onProgress?.call(message, progress * 100.0);
      },
    );
  }
}
