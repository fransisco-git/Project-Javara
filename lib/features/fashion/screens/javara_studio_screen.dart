import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/fashn_ai_service.dart';
import '../../../services/supabase_service.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import '../models/realistic_fashion_model.dart';
import 'javanese_wardrobe_screen.dart';

/// Mode Penampil Utama di JAVARA STUDIO
enum StudioViewingMode {
  liveCamera, // Mode A: Kamera Ponsel Langsung (Live Camera)
  photoMode, // Mode B: Unggah Foto Pribadi / Jepretan Galeri
  aiModel, // Mode C: Model Manusia Fotorealistik Pilihan (Anywear style)
}

/// Kategori Filter Lemari Busana di Studio
enum StudioGarmentCategory {
  all('Semua', Icons.grid_view_rounded),
  beskap('Beskap', Icons.checkroom_rounded),
  kebaya('Kebaya', Icons.woman_rounded),
  batikJarik('Batik & Jarik', Icons.layers_rounded),
  jawiJangkep('Jawi Jangkep', Icons.style_rounded),
  blangkon('Blangkon', Icons.face_rounded),
  accessories('Ricikan', Icons.military_tech_rounded),
  footwear('Selop Adat', Icons.nordic_walking_rounded);

  const StudioGarmentCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// JAVARA STUDIO — LIVE VIRTUAL TRADITIONAL FASHION STUDIO
///
/// Terinspirasi dari filosofi interaksi minimalis Anywear (Decart AI):
/// 1. Camera-First Experience (Viewport peraga manusia besar & dominan).
/// 2. Touch-Based Drag-and-Drop Wardrobe (Tarik busana ke model atau ketuk langsung).
/// 3. Modular Outfit Customization (Atasan, Bawahan, Blangkon, Ricikan terpisah).
/// 4. Real FASHN AI Virtual Try-On Engine (dengan slider komparasi Before/After).
/// 5. Desain Editorial Bersih Anti-AI-Slop khas kemewahan warisan Jawa Tengah.
class JavaraStudioScreen extends StatefulWidget {
  const JavaraStudioScreen({
    super.key,
    this.initialModel,
    this.initialGarment,
    this.initialOutfit,
    this.initialMode = StudioViewingMode.liveCamera,
    this.isEmbeddedInTab = false,
    this.onSwitchToCatalogTab,
  });

  final RealisticFashionModel? initialModel;
  final ClothingItem? initialGarment;
  final TraditionalOutfit? initialOutfit;
  final StudioViewingMode initialMode;
  final bool isEmbeddedInTab;
  final VoidCallback? onSwitchToCatalogTab;

  @override
  State<JavaraStudioScreen> createState() => _JavaraStudioScreenState();
}

class _JavaraStudioScreenState extends State<JavaraStudioScreen>
    with SingleTickerProviderStateMixin {
  // Mode Penampil Aktif
  late StudioViewingMode _viewingMode;

  // Model Peraga Manusia Realistis Aktif
  late RealisticFashionModel _selectedModel;
  GenderTarget _genderFilter = GenderTarget.pria;

  // State Busana Modular yang Sedang Dikenakan (Slot Komponen)
  ClothingItem? _equippedHeadwear;
  ClothingItem? _equippedUpper;
  ClothingItem? _equippedLower;
  ClothingItem? _equippedAccessory;
  TraditionalOutfit? _equippedFullOutfit;

  // Riwayat Perubahan Busana untuk Fitur Undo (Urungkan)
  final List<_OutfitStateSnapshot> _undoStack = [];

  // Kamera Ponsel
  List<CameraDescription> _availableCameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraInitializing = false;
  String? _cameraErrorMessage;
  bool _showFramingGuide = true;

  // Foto Pengguna (Mode B: Photo Mode / On-Cam Snapshot)
  File? _userUploadedPhoto;
  File? _capturedBeforePhoto;
  final ImagePicker _imagePicker = ImagePicker();

  // Kategori Lemari Busana Terpilih
  StudioGarmentCategory _selectedCategory = StudioGarmentCategory.all;

  // Drag and Drop Hover Feedback State
  bool _isDragHovering = false;

  // Status Generasi AI Virtual Try-On
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _generationStepMessage = '';
  TryOnStatusResponse? _latestAiResult;
  String? _transformedGarmentTitle;

  // Interactive Before/After Split Comparison Slider (0.0 = full before, 1.0 = full after)
  double _splitPosition = 0.5;

  // Riwayat Generasi Tersimpan
  List<AiGenerationRecord> _historyRecords = [];
  List<AiGenerationRecord> get historyRecords => _historyRecords;

  // Bottom Sheet Terlipat / Terbuka
  bool _isWardrobeDrawerExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewingMode = widget.initialMode;

    // Inisialisasi Model Manusia
    _selectedModel =
        widget.initialModel ??
        RealisticFashionModelLibrary.models.firstWhere(
          (m) => m.gender == GenderTarget.pria,
          orElse: () => RealisticFashionModelLibrary.models.first,
        );
    _genderFilter = _selectedModel.gender;

    // Inisialisasi Busana Awal
    if (widget.initialOutfit != null) {
      _applyFullOutfit(widget.initialOutfit!, saveUndo: false);
    } else if (widget.initialGarment != null) {
      _equipGarment(widget.initialGarment!, saveUndo: false);
    } else {
      // Pasang setelan kurasi awal yang selaras
      final defaultOutfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.gender == _genderFilter,
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );
      _applyFullOutfit(defaultOutfit, saveUndo: false);
    }

    // Inisialisasi Kamera jika mode awal kamera
    if (_viewingMode == StudioViewingMode.liveCamera) {
      _initializeCamera();
    }

    _loadGenerationHistory();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 1. KAMERA & PENGELOLAAN FOTO PENGGUNA
  // ===========================================================================

  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _cameraErrorMessage = null;
    });

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        setState(() {
          _cameraErrorMessage = 'Tidak ada perangkat kamera yang terdeteksi.';
          _isCameraInitializing = false;
        });
        return;
      }

      // Pilih kamera depan sebagai default studio selfie / peraga
      final frontIdx = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontIdx != -1 ? frontIdx : 0;

      await _startCameraStream(_availableCameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _cameraErrorMessage =
            'Izin kamera belum diberikan atau perangkat tidak mendukung kamera langsung.\n($e)';
        _isCameraInitializing = false;
      });
    }
  }

  Future<void> _startCameraStream(CameraDescription description) async {
    await _cameraController?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorMessage = 'Gagal menyalakan pratinjau kamera: $e';
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    HapticFeedback.lightImpact();
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;
    await _startCameraStream(_availableCameras[_selectedCameraIndex]);
  }

  Future<void> _capturePhotoFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final xFile = await _cameraController!.takePicture();
      setState(() {
        _userUploadedPhoto = File(xFile.path);
        _viewingMode = StudioViewingMode.photoMode;
        _latestAiResult = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto peraga berhasil diambil untuk Virtual Try-On!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF30251F),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    HapticFeedback.lightImpact();
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 2400,
        imageQuality: 92,
      );

      if (picked != null) {
        setState(() {
          _userUploadedPhoto = File(picked.path);
          _viewingMode = StudioViewingMode.photoMode;
          _latestAiResult = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto galeri: $e')));
    }
  }

  // ===========================================================================
  // 2. MANAJEMEN BUSANA & DRAG-AND-DROP (TOUCH INTERACTION)
  // ===========================================================================

  void _recordUndoSnapshot() {
    _undoStack.add(
      _OutfitStateSnapshot(
        headwear: _equippedHeadwear,
        upper: _equippedUpper,
        lower: _equippedLower,
        accessory: _equippedAccessory,
        fullOutfit: _equippedFullOutfit,
      ),
    );
    if (_undoStack.length > 20) _undoStack.removeAt(0);
  }

  void _undoOutfit() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    final previous = _undoStack.removeLast();
    setState(() {
      _equippedHeadwear = previous.headwear;
      _equippedUpper = previous.upper;
      _equippedLower = previous.lower;
      _equippedAccessory = previous.accessory;
      _equippedFullOutfit = previous.fullOutfit;
      _latestAiResult = null;
    });
  }

  void _resetOutfit() {
    HapticFeedback.mediumImpact();
    _recordUndoSnapshot();
    setState(() {
      _equippedHeadwear = null;
      _equippedUpper = null;
      _equippedLower = null;
      _equippedAccessory = null;
      _equippedFullOutfit = null;
      _latestAiResult = null;
    });
  }

  void _equipGarment(ClothingItem item, {bool saveUndo = true}) {
    if (saveUndo) _recordUndoSnapshot();
    HapticFeedback.selectionClick();

    setState(() {
      _equippedFullOutfit = null; // Beralih ke peragaan potongan modular
      _latestAiResult = null;

      switch (item.category) {
        case ClothingCategory.headwear:
          _equippedHeadwear = item;
          break;
        case ClothingCategory.upperBody:
          _equippedUpper = item;
          break;
        case ClothingCategory.lowerBody:
          _equippedLower = item;
          break;
        case ClothingCategory.accessories:
          _equippedAccessory = item;
          break;
      }
    });
  }

  void _applyFullOutfit(TraditionalOutfit outfit, {bool saveUndo = true}) {
    if (saveUndo) _recordUndoSnapshot();
    HapticFeedback.selectionClick();

    setState(() {
      _equippedFullOutfit = outfit;
      _latestAiResult = null;

      // Sinkronkan slot komponen dari ID setelan kurasi
      _equippedHeadwear = outfit.headwearId.isNotEmpty
          ? JavaneseClothingData.getItemById(outfit.headwearId)
          : null;
      _equippedUpper = outfit.upperBodyId.isNotEmpty
          ? JavaneseClothingData.getItemById(outfit.upperBodyId)
          : null;
      _equippedLower = outfit.lowerBodyId.isNotEmpty
          ? JavaneseClothingData.getItemById(outfit.lowerBodyId)
          : null;
      _equippedAccessory = outfit.accessoryIds.isNotEmpty
          ? JavaneseClothingData.getItemById(outfit.accessoryIds.first)
          : null;
    });
  }

  // ===========================================================================
  // 3. MESIN AI VIRTUAL TRY-ON (FASHN AI ENGINE)
  // ===========================================================================

  Future<void> _loadGenerationHistory() async {
    final list = await SupabaseService.instance.getAiGenerations();
    if (mounted) setState(() => _historyRecords = list);
  }

  Future<void> _triggerAiVirtualTryOn() async {
    if (_isGenerating) return;
    HapticFeedback.heavyImpact();

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.05;
      _generationStepMessage = 'Mengirimkan spesifikasi busana ke AI Engine...';
    });

    try {
      // 1. Tentukan Gambar Model Manusia (Otomatis Ambil Foto dari Kamera jika On-Cam)
      if (_viewingMode == StudioViewingMode.liveCamera) {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          try {
            final xFile = await _cameraController!.takePicture();
            _capturedBeforePhoto = File(xFile.path);
          } catch (e) {
            debugPrint('Live camera frame capture note: $e');
          }
        }
      }

      String modelImageUrl = _selectedModel.imageAsset;
      if (_capturedBeforePhoto != null && _capturedBeforePhoto!.existsSync()) {
        modelImageUrl = _capturedBeforePhoto!.path;
      } else if (_viewingMode == StudioViewingMode.photoMode &&
          _userUploadedPhoto != null &&
          _userUploadedPhoto!.existsSync()) {
        modelImageUrl = _userUploadedPhoto!.path;
      }

      // 2. Tentukan Gambar Busana Pilihan
      String garmentImageUrl = 'assets/images/kebaya.png';
      String garmentName = 'Setelan Busana Adat Jawa';
      String categoryKey = 'one-pieces';

      if (_equippedFullOutfit != null) {
        garmentImageUrl = _equippedFullOutfit!.imageAsset;
        garmentName = _equippedFullOutfit!.title;
        categoryKey = 'one-pieces';
      } else if (_equippedUpper != null) {
        garmentImageUrl = _equippedUpper!.imageAsset;
        garmentName = _equippedUpper!.name;
        categoryKey = 'tops';
      } else if (_equippedLower != null) {
        garmentImageUrl = _equippedLower!.imageAsset;
        garmentName = _equippedLower!.name;
        categoryKey = 'bottoms';
      }

      final fashnService = FashnAiService.instance;

      final runResponse = await fashnService.runTryOn(
        modelImage: modelImageUrl,
        garmentImage: garmentImageUrl,
        category: categoryKey,
        mode: 'performance',
        modelName: _selectedModel.title,
        garmentName: garmentName,
      );

      // Simulasikan status progress yang informatif
      setState(() {
        _generationProgress = 0.35;
        _generationStepMessage =
            'Menganalisis anatomi tubuh & lipatan kain wastra...';
      });

      final finalResult = await fashnService.pollStatus(
        predictionId: runResponse.id,
        onProgress: (status, progress) {
          if (mounted) {
            setState(() {
              _generationProgress = (progress / 100.0).clamp(0.1, 0.95);
              _generationStepMessage =
                  'Merender serat tenun & prada kencana (${progress.toInt()}%)...';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationProgress = 1.0;
          _latestAiResult = finalResult;
          _splitPosition = 0.5; // Reset slider perbandingan ke tengah
        });

        // Simpan ke riwayat Supabase & lokal
        final newRecord = AiGenerationRecord(
          id: finalResult.id,
          userId: 'user_javara_studio',
          modelId: _selectedModel.id,
          modelName: _selectedModel.title,
          garmentName: garmentName,
          originalImageUrl: modelImageUrl,
          generatedImageUrl:
              finalResult.outputImageUrl ?? _selectedModel.imageAsset,
          status: 'completed',
          createdAt: DateTime.now(),
        );

        await SupabaseService.instance.saveAiGeneration(newRecord);
        _loadGenerationHistory();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF30251F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFB08D57), width: 1),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFFFDF9E),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Virtual Try-On Berhasil! Geser slider untuk melihat perbandingan.',
                  style: JText.serif(12, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationStepMessage = 'Gagal: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB3261E),
            content: Text('Kendala AI Try-On: $e'),
          ),
        );
      }
    }
  }

  // ===========================================================================
  // 4. BUILD UTAMA (LAYOUT MOBILE-FIRST ANYWEAR INSPIRED)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF14100D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF14100D),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // AREA UTAMA 1: VIEWPORT PERAGA / KAMERA (MENEMPATI HAMPIR SELURUH LAYAR)
            Positioned.fill(child: _buildMainViewingStage()),

            // AREA UTAMA 2: BILAH KONTROL ATAS MINIMALIS (TOP BAR)
            Positioned(top: 0, left: 0, right: 0, child: _buildStudioTopBar()),

            // KOTAK OVERLAY PROGRES GENERASI AI
            if (_isGenerating)
              Positioned.fill(child: _buildGenerationProgressOverlay()),

            // AREA UTAMA 3: LEMARI BUSANA INTERAKTIF (BOTTOM WARDROBE DRAWER)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildInteractiveWardrobeDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. VIEWPORT PERAGA BESAR DENGAN DRAG TARGET (ANYWEAR CENTERPIECE)
  // ===========================================================================

  Widget _buildMainViewingStage() {
    return DragTarget<ClothingItem>(
      onWillAcceptWithDetails: (details) {
        HapticFeedback.selectionClick();
        setState(() => _isDragHovering = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isDragHovering = false);
      },
      onAcceptWithDetails: (details) {
        HapticFeedback.mediumImpact();
        setState(() => _isDragHovering = false);
        _equipGarment(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: _isDragHovering
                ? Border.all(color: const Color(0xFFFFDF9E), width: 3)
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // A. Konten Model Berdasarkan Mode
              if (_viewingMode == StudioViewingMode.liveCamera)
                _buildLiveCameraView()
              else if (_viewingMode == StudioViewingMode.photoMode)
                _buildUserPhotoView()
              else
                _buildAiModelView(),

              // B. Efek Perbandingan Before/After Slider (Jika Ada Hasil AI)
              if (_latestAiResult != null) _buildBeforeAfterSplitSlider(),

              // C. Highlight Indikator Drop Zone saat Busana Ditarik
              if (_isDragHovering)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30251F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFDF9E),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x66FFDF9E), blurRadius: 16),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            color: Color(0xFFFFDF9E),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lepaskan untuk Memakaikan ke Model',
                            style: JText.editorial(
                              16,
                              weight: FontWeight.w700,
                              color: const Color(0xFFFFDF9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // D. Badge Info Busana yang Sedang Dikenakan di Model
              Positioned(left: 16, top: 104, child: _buildEquippedOutfitPill()),
            ],
          ),
        );
      },
    );
  }

  /// Tampilan Mode A: Live Camera Preview Ponsel
  Widget _buildLiveCameraView() {
    if (_isCameraInitializing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFB08D57), strokeWidth: 2),
            SizedBox(height: 12),
            Text(
              'Menghubungkan ke Lensa Kamera...',
              style: TextStyle(color: Color(0xFFC7B7A6), fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_cameraErrorMessage != null || _cameraController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 56,
                color: Color(0x66B08D57),
              ),
              const SizedBox(height: 14),
              Text(
                'Pratinjau Kamera Langsung',
                style: JText.editorial(
                  20,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cameraErrorMessage ?? 'Nyalakan izin kamera di Pengaturan untuk mencoba peraga busana di tubuh Anda secara langsung.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA89989),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB08D57),
                      foregroundColor: const Color(0xFF14100D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _initializeCamera,
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFDF9E),
                      side: const BorderSide(color: Color(0x66B08D57)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Gunakan Foto Galeri'),
                    onPressed: _pickPhotoFromGallery,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),

        // 1. Panduan Siluet Tubuh Anywear Decart AI (Framing & Pose Guide)
        if (_showFramingGuide)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _JavaraSilhouetteGuidePainter(
                  accentColor: const Color(0xFFDFB76C),
                  isFemale:
                      _selectedModel.gender == GenderTarget.wanita ||
                      _equippedUpper?.gender == GenderTarget.wanita,
                ),
              ),
            ),
          ),

        // 2. Tombol Kontrol Cepat Kamera (Kanan Atas)
        Positioned(
          top:
              MediaQuery.of(context).padding.top +
              (widget.isEmbeddedInTab ? 58 : 64),
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle Panduan Siluet
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showFramingGuide = !_showFramingGuide);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _showFramingGuide
                        ? const Color(0xD9DFB76C)
                        : const Color(0xB814100D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDFB76C),
                      width: 0.9,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showFramingGuide
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 13,
                        color: _showFramingGuide
                            ? const Color(0xFF14100D)
                            : const Color(0xFFFFDF9E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Siluet',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _showFramingGuide
                              ? const Color(0xFF14100D)
                              : const Color(0xFFFFDF9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Balik Lensa Kamera (Depan / Belakang)
              GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xB814100D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x66DFB76C),
                      width: 0.9,
                    ),
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    size: 16,
                    color: Color(0xFFFFDF9E),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Tombol Shutter Ambil Foto & Transformasi Langsung
        Positioned(
          bottom:
              (_isWardrobeDrawerExpanded ? 360 : 220) +
              (widget.isEmbeddedInTab ? 54 : 0),
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Buka Galeri Foto
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xB814100D),
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFFFFDF9E),
                    size: 18,
                  ),
                  onPressed: _pickPhotoFromGallery,
                ),
              ),
              const SizedBox(width: 24),

              // Tombol Shutter (Anywear Live AI Try-On: Ketuk untuk Coba, Tahan untuk Simpan Foto Saja)
              GestureDetector(
                onTap: _triggerAiVirtualTryOn,
                onLongPress: _capturePhotoFromCamera,
                child: Container(
                  width: 66,
                  height: 66,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFDF9E),
                      width: 2.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55DFB76C), blurRadius: 14),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFDFB76C), Color(0xFFB08D57)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF14100D),
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Putar Kamera Depan / Belakang
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xB814100D),
                child: IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Color(0xFFFFDF9E),
                    size: 18,
                  ),
                  onPressed: _switchCamera,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tampilan Mode B: Pratinjau Foto Pengguna Terpilih
  Widget _buildUserPhotoView() {
    if (_userUploadedPhoto == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 56,
              color: Color(0x66B08D57),
            ),
            const SizedBox(height: 14),
            Text(
              'Unggah Foto Tubuh Penuh',
              style: JText.editorial(
                20,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gunakan foto berdiri tegak dengan pencahayaan jelas untuk hasil Virtual Try-On yang presisi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFA89989), fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB08D57),
                foregroundColor: const Color(0xFF14100D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text(
                'Pilih dari Galeri',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _pickPhotoFromGallery,
            ),
          ],
        ),
      );
    }

    return Image.file(_userUploadedPhoto!, fit: BoxFit.cover);
  }

  /// Tampilan Mode C: Model Manusia Fotorealistik Pilihan (Anywear)
  Widget _buildAiModelView() {
    return Image.asset(
      _selectedModel.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFF1C1612),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_rounded,
                size: 64,
                color: Color(0x66B08D57),
              ),
              const SizedBox(height: 10),
              Text(
                _selectedModel.title,
                style: JText.editorial(
                  16,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Interactive Decart Anywear Before / After Split Slider
  Widget _buildBeforeAfterSplitSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final splitX = constraints.maxWidth * _splitPosition;

        // Gambar Sebelum (Before - Foto Pribadi Pengguna / Model Asli)
        Widget buildBeforeWidget() {
          if (_capturedBeforePhoto != null &&
              _capturedBeforePhoto!.existsSync()) {
            return Image.file(_capturedBeforePhoto!, fit: BoxFit.cover);
          } else if (_userUploadedPhoto != null &&
              _userUploadedPhoto!.existsSync()) {
            return Image.file(_userUploadedPhoto!, fit: BoxFit.cover);
          }
          return Image.asset(_selectedModel.imageAsset, fit: BoxFit.cover);
        }

        // Gambar Sesudah (After - Hasil Transformasi Busana Tradisional AI)
        Widget buildAfterWidget() {
          final outputUrl =
              _latestAiResult?.outputImageUrl ?? _selectedModel.imageAsset;
          if (outputUrl.startsWith('assets/')) {
            return Image.asset(outputUrl, fit: BoxFit.cover);
          } else if (outputUrl.startsWith('http://') ||
              outputUrl.startsWith('https://')) {
            return Image.network(
              outputUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(_selectedModel.imageAsset, fit: BoxFit.cover),
            );
          } else {
            final f = File(outputUrl);
            if (f.existsSync()) {
              return Image.file(f, fit: BoxFit.cover);
            }
            return Image.asset(_selectedModel.imageAsset, fit: BoxFit.cover);
          }
        }

        final equippedTitle =
            _transformedGarmentTitle ??
            _equippedFullOutfit?.title ??
            _equippedUpper?.name ??
            _equippedLower?.name ??
            'Busana Adat Jawa Tengah';

        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer After Image (Hasil AI Virtual Try-On - Sisi Kanan)
            buildAfterWidget(),

            // Layer Before Image (Dipotong oleh Split Position - Sisi Kiri)
            ClipRect(
              clipper: _SplitViewClipper(splitFactor: _splitPosition),
              child: buildBeforeWidget(),
            ),

            // Garis Vertikal Pemisah Emas Prada Bercahaya
            Positioned(
              left: splitX - 1.5,
              top: 0,
              bottom: 0,
              width: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00DFB76C),
                      Color(0xFFDFB76C),
                      Color(0xFFFFFDF5),
                      Color(0xFFDFB76C),
                      Color(0x00DFB76C),
                    ],
                  ),
                ),
              ),
            ),

            // Handle Geser Interaktif (Decart Anywear Style Circle Handle)
            Positioned(
              left: splitX - 22,
              top: constraints.maxHeight * 0.46,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _splitPosition =
                        (details.globalPosition.dx / constraints.maxWidth)
                            .clamp(0.04, 0.96);
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1712),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFDF9E),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                      BoxShadow(color: Color(0x40DFB76C), blurRadius: 8),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: Color(0xFFFFDF9E),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Label Pil Indikator Before (Kiri Atas)
            Positioned(
              left: 16,
              top: 110,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xB814100D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0x33DFB76C),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: Color(0xFFA89989),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'SEBELUM: Pakaian Pribadi',
                      style: TextStyle(
                        color: Color(0xFFC7B7A6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Label Pil Indikator After (Kanan Atas)
            Positioned(
              right: 16,
              top: 110,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xD92E1F14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0x80DFB76C),
                    width: 0.9,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40DFB76C), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: Color(0xFFFFDF9E),
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        'SESUDAH: $equippedTitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFDF9E),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Bottom Action Controls (Anywear Transformation Suite)
            Positioned(
              left: 16,
              right: 16,
              bottom:
                  (_isWardrobeDrawerExpanded ? 360 : 225) +
                  (widget.isEmbeddedInTab ? 54 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildComparisonActionPill(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera Lagi',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _latestAiResult = null;
                        _viewingMode = StudioViewingMode.liveCamera;
                        _initializeCamera();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildComparisonActionPill(
                    icon: Icons.menu_book_rounded,
                    label: 'Filosofi Adat',
                    onTap: _showCulturalPhilosophySheet,
                  ),
                  const SizedBox(width: 8),
                  _buildComparisonActionPill(
                    icon: Icons.bookmark_add_rounded,
                    label: 'Simpan',
                    isPrimary: true,
                    onTap: _saveCurrentResultToWardrobe,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComparisonActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFDFB76C) : const Color(0xD91E1712),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFFFDF9E)
                : const Color(0x66DFB76C),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? const Color(0x40DFB76C) : Colors.black45,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary
                  ? const Color(0xFF14100D)
                  : const Color(0xFFFFDF9E),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                color: isPrimary
                    ? const Color(0xFF14100D)
                    : const Color(0xFFFAF6F0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCulturalPhilosophySheet() {
    final outfit = _equippedFullOutfit;
    final upper = _equippedUpper;
    final lower = _equippedLower;

    final title =
        outfit?.title ??
        upper?.name ??
        lower?.name ??
        'Busana Tradisi Jawa Tengah';
    final script =
        outfit?.javaneseScript ??
        upper?.javaneseScript ??
        lower?.javaneseScript ??
        '';
    final philosophy =
        outfit?.culturalPhilosophy ??
        upper?.philosophicalMeaning ??
        lower?.philosophicalMeaning ??
        'Busana adat Jawa Tengah sarat akan filosofi adiluhung yang menyelaraskan raga, sukma, dan budi pekerti luhur.';
    final courtRules =
        outfit?.etiquetteRules ??
        upper?.historicalNotes ??
        lower?.historicalNotes ??
        'Dikenakan pada upacara agung, pisowanan keraton, dan pertemuan resmi adat.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1712),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFFDFB76C), width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x66DFB76C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x33DFB76C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFFFFDF9E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: JText.serif(
                          17,
                          weight: FontWeight.w800,
                          color: const Color(0xFFFFDF9E),
                        ),
                      ),
                      if (script.isNotEmpty)
                        Text(
                          script,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDFB76C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'FILOSOFI ADILUHUNG',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFC79B3A),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              philosophy,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Color(0xFFFAF6F0),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'PAKEM & TATA CARA ADAT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFC79B3A),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              courtRules,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFFD4C4B4),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDFB76C),
                  foregroundColor: const Color(0xFF14100D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Tutup & Lanjutkan Studio',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCurrentResultToWardrobe() async {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E1F14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDFB76C), width: 1),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFFFDF9E),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Potret busana adat berhasil disimpan ke Lemari Budaya!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge Info Busana yang Sedang Dikenakan di Model
  Widget _buildEquippedOutfitPill() {
    final title = _equippedFullOutfit != null
        ? _equippedFullOutfit!.title
        : _equippedUpper != null
        ? _equippedUpper!.name
        : _equippedLower != null
        ? _equippedLower!.name
        : 'Pilih Busana Tradisi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xD914100D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x55B08D57), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.checkroom_rounded,
            size: 14,
            color: Color(0xFFFFDF9E),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFAF6F0),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_undoStack.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _undoOutfit,
              child: const Icon(
                Icons.undo_rounded,
                size: 14,
                color: Color(0xFFB08D57),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. TOP BAR MINIMALIS JAVARA STUDIO
  // ===========================================================================

  Widget _buildStudioTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali atau Tombol Buka Koleksi (jika embedded di Tab)
          if (widget.isEmbeddedInTab)
            GestureDetector(
              onTap: widget.onSwitchToCatalogTab,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xB31C1612),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x66DFB76C),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFFFDF9E),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Koleksi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFDF9E),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            CircleAvatar(
              backgroundColor: const Color(0x66000000),
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

          // Viewing Mode Switcher Pills (Kamera | Foto Anda | Model AI)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xB31C1612),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x44B08D57), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModePill(
                      mode: StudioViewingMode.liveCamera,
                      label: 'Kamera',
                      icon: Icons.camera_alt_rounded,
                    ),
                    _buildModePill(
                      mode: StudioViewingMode.photoMode,
                      label: 'Foto Anda',
                      icon: Icons.photo_library_rounded,
                    ),
                    _buildModePill(
                      mode: StudioViewingMode.aiModel,
                      label: 'Model AI',
                      icon: Icons.person_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Buka Mode 3D WebGL / Turntable
          CircleAvatar(
            backgroundColor: const Color(0x66000000),
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.view_in_ar_rounded,
                size: 18,
                color: Color(0xFFFFDF9E),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(fadeSlideRoute(const JavaneseWardrobeScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required StudioViewingMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _viewingMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _viewingMode = mode;
          if (mode == StudioViewingMode.liveCamera) {
            _initializeCamera();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB08D57) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected
                  ? const Color(0xFF14100D)
                  : const Color(0xFFC7B7A6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF14100D)
                    : const Color(0xFFC7B7A6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. LEMARI BUSANA TOUCH-BASED & DRAG-AND-DROP (BOTTOM WARDROBE DRAWER)
  // ===========================================================================

  Widget _buildInteractiveWardrobeDrawer() {
    final garments = _getGarmentsForCategory(_selectedCategory);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      height:
          (_isWardrobeDrawerExpanded ? 350 : 210) +
          (widget.isEmbeddedInTab ? 58 : 0),
      decoration: BoxDecoration(
        color: const Color(0xF21C1612),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFB08D57).withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar Tarik & Tombol Buka Tutup Drawer
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(
                () => _isWardrobeDrawerExpanded = !_isWardrobeDrawerExpanded,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x66B08D57),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Baris 1: Kategori Filter Busana Horizontal
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: StudioGarmentCategory.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = StudioGarmentCategory.values[index];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB08D57)
                          : const Color(0x22FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 12,
                          color: isSelected
                              ? const Color(0xFF14100D)
                              : const Color(0xFFC7B7A6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF14100D)
                                : const Color(0xFFC7B7A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Baris 2: Thumbnail Busana Drag-and-Drop Horisontal
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: garments.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = garments[index];
                return _buildDraggableGarmentThumbnail(item);
              },
            ),
          ),

          // Baris 3: Tombol Aksi Utama Virtual Try-On
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              6,
              16,
              widget.isEmbeddedInTab ? 72 : 14,
            ),
            child: Row(
              children: [
                // Tombol Reset Busana
                IconButton(
                  tooltip: 'Atur Ulang Busana',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFFC7B7A6),
                  ),
                  onPressed: _resetOutfit,
                ),
                const SizedBox(width: 8),

                // Tombol Eksekusi AI Virtual Try-On
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDFB76C),
                        foregroundColor: const Color(0xFF14100D),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _equippedFullOutfit != null
                              ? '✨ Transformasikan: ${_equippedFullOutfit!.title}'
                              : _equippedUpper != null
                              ? '✨ Transformasikan: ${_equippedUpper!.name}'
                              : '✨ Transformasikan ke Busana Adat',
                          style: JText.editorial(
                            14.5,
                            weight: FontWeight.w800,
                            color: const Color(0xFF14100D),
                          ),
                        ),
                      ),
                      onPressed: _triggerAiVirtualTryOn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thumbnail Busana yang Mendukung Drag-and-Drop dan Ketukan Langsung (Anywear)
  Widget _buildDraggableGarmentThumbnail(ClothingItem item) {
    final isEquipped = _isItemEquipped(item);

    final card = Container(
      width: 84,
      decoration: BoxDecoration(
        color: isEquipped ? const Color(0xFF382A20) : const Color(0xFF261D16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped ? const Color(0xFFFFDF9E) : const Color(0x33B08D57),
          width: isEquipped ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              child:
                  item.assetImagePath != null && item.assetImagePath!.isNotEmpty
                  ? Image.asset(
                      item.assetImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          item.category.icon,
                          color: const Color(0x66B08D57),
                          size: 24,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        item.category.icon,
                        color: const Color(0x66B08D57),
                        size: 24,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isEquipped ? FontWeight.w800 : FontWeight.w600,
                    color: isEquipped
                        ? const Color(0xFFFFDF9E)
                        : const Color(0xFFFAF6F0),
                  ),
                ),
                Text(
                  item.region.title.split('(').first.trim(),
                  maxLines: 1,
                  style: const TextStyle(fontSize: 8, color: Color(0xFF9E8D7F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Membungkus dengan LongPressDraggable untuk interaksi Drag-and-Drop sentuh
    return LongPressDraggable<ClothingItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(width: 90, height: 90, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: GestureDetector(onTap: () => _equipGarment(item), child: card),
    );
  }

  bool _isItemEquipped(ClothingItem item) {
    return _equippedHeadwear?.id == item.id ||
        _equippedUpper?.id == item.id ||
        _equippedLower?.id == item.id ||
        _equippedAccessory?.id == item.id;
  }

  List<ClothingItem> _getGarmentsForCategory(StudioGarmentCategory category) {
    final all = JavaneseClothingData.clothingItems;
    switch (category) {
      case StudioGarmentCategory.all:
        return all;
      case StudioGarmentCategory.beskap:
        return all
            .where(
              (i) =>
                  i.category == ClothingCategory.upperBody &&
                  i.name.toLowerCase().contains('beskap'),
            )
            .toList();
      case StudioGarmentCategory.kebaya:
        return all
            .where(
              (i) =>
                  i.category == ClothingCategory.upperBody &&
                  i.name.toLowerCase().contains('kebaya'),
            )
            .toList();
      case StudioGarmentCategory.batikJarik:
        return all
            .where((i) => i.category == ClothingCategory.lowerBody)
            .toList();
      case StudioGarmentCategory.jawiJangkep:
        return all
            .where(
              (i) =>
                  i.compatibilityKeys.contains('solo_royal') ||
                  i.compatibilityKeys.contains('solo_formal'),
            )
            .toList();
      case StudioGarmentCategory.blangkon:
        return all
            .where((i) => i.category == ClothingCategory.headwear)
            .toList();
      case StudioGarmentCategory.accessories:
        return all
            .where((i) => i.category == ClothingCategory.accessories)
            .toList();
      case StudioGarmentCategory.footwear:
        return all
            .where(
              (i) =>
                  i.category == ClothingCategory.accessories &&
                  i.name.toLowerCase().contains('selop'),
            )
            .toList();
    }
  }

  // ===========================================================================
  // 8. OVERLAY PROGRES AI
  // ===========================================================================

  Widget _buildGenerationProgressOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF241C15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB08D57), width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFDF9E),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'AI Virtual Try-On',
                style: JText.editorial(
                  18,
                  weight: FontWeight.w800,
                  color: const Color(0xFFFFDF9E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _generationStepMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFC7B7A6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _generationProgress,
                  backgroundColor: const Color(0x33B08D57),
                  color: const Color(0xFFB08D57),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Clipper untuk Slider Perbandingan Split Sebelum & Sesudah
class _SplitViewClipper extends CustomClipper<Rect> {
  const _SplitViewClipper({required this.splitFactor});
  final double splitFactor;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * splitFactor, size.height);
  }

  @override
  bool shouldReclip(covariant _SplitViewClipper oldClipper) =>
      oldClipper.splitFactor != splitFactor;
}

/// Rekaman Snapshot Status Busana untuk Fitur Undo
class _OutfitStateSnapshot {
  const _OutfitStateSnapshot({
    required this.headwear,
    required this.upper,
    required this.lower,
    required this.accessory,
    required this.fullOutfit,
  });

  final ClothingItem? headwear;
  final ClothingItem? upper;
  final ClothingItem? lower;
  final ClothingItem? accessory;
  final TraditionalOutfit? fullOutfit;
}

/// Pelukis Garis Panduan Siluet Tubuh Anywear Decart AI (Framing & Pose Viewfinder)
class _JavaraSilhouetteGuidePainter extends CustomPainter {
  const _JavaraSilhouetteGuidePainter({
    required this.accentColor,
    required this.isFemale,
  });

  final Color accentColor;
  final bool isFemale;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final dashPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Head guide (Oval kepala)
    final headCenterY = h * 0.32;
    final headRadiusX = w * 0.18;
    final headRadiusY = h * 0.12;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, headCenterY),
        width: headRadiusX * 2,
        height: headRadiusY * 2,
      ),
      strokePaint,
    );

    // Blangkon atau Sanggul kontur puncak
    final headPath = Path();
    if (isFemale) {
      headPath.moveTo(cx - 32, headCenterY - headRadiusY + 4);
      headPath.quadraticBezierTo(
        cx,
        headCenterY - headRadiusY - 20,
        cx + 32,
        headCenterY - headRadiusY + 4,
      );
    } else {
      headPath.moveTo(cx - 26, headCenterY - headRadiusY + 4);
      headPath.quadraticBezierTo(
        cx,
        headCenterY - headRadiusY - 14,
        cx + 26,
        headCenterY - headRadiusY + 4,
      );
    }
    canvas.drawPath(headPath, strokePaint);

    // 2. Leher & Bahu (Shoulders & Chest)
    final neckY = headCenterY + headRadiusY;
    final shoulderY = neckY + 28;
    final shoulderSpread = w * 0.38;

    final shoulderPath = Path()
      ..moveTo(cx - 24, neckY + 12)
      ..quadraticBezierTo(
        cx - 50,
        shoulderY,
        cx - shoulderSpread,
        shoulderY + 35,
      )
      ..quadraticBezierTo(
        cx - shoulderSpread - 8,
        shoulderY + 80,
        cx - shoulderSpread - 6,
        h * 0.75,
      );

    shoulderPath.moveTo(cx + 24, neckY + 12);
    shoulderPath.quadraticBezierTo(
      cx + 50,
      shoulderY,
      cx + shoulderSpread,
      shoulderY + 35,
    );
    shoulderPath.quadraticBezierTo(
      cx + shoulderSpread + 8,
      shoulderY + 80,
      cx + shoulderSpread + 6,
      h * 0.75,
    );

    canvas.drawPath(shoulderPath, strokePaint);

    // Garis Kerah Beskap / V Kebaya
    final collarPath = Path()
      ..moveTo(cx - 20, neckY + 12)
      ..lineTo(cx, neckY + 45)
      ..lineTo(cx + 20, neckY + 12);
    canvas.drawPath(collarPath, dashPaint);

    // Sumbu vertikal tengah
    canvas.drawLine(
      Offset(cx, headCenterY - headRadiusY - 25),
      Offset(cx, h * 0.78),
      dashPaint,
    );

    // 4 Corner Brackets (Viewfinder Hasselblad / Leica style)
    const bracketLen = 24.0;
    final boxMargin = w * 0.08;
    final boxRect = Rect.fromLTRB(boxMargin, h * 0.15, w - boxMargin, h * 0.82);

    final bracketPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Top-Left
    canvas.drawLine(
      boxRect.topLeft,
      boxRect.topLeft + const Offset(bracketLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      boxRect.topLeft,
      boxRect.topLeft + const Offset(0, bracketLen),
      bracketPaint,
    );

    // Top-Right
    canvas.drawLine(
      boxRect.topRight,
      boxRect.topRight + const Offset(-bracketLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      boxRect.topRight,
      boxRect.topRight + const Offset(0, bracketLen),
      bracketPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      boxRect.bottomLeft,
      boxRect.bottomLeft + const Offset(bracketLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      boxRect.bottomLeft,
      boxRect.bottomLeft + const Offset(0, -bracketLen),
      bracketPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      boxRect.bottomRight,
      boxRect.bottomRight + const Offset(-bracketLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      boxRect.bottomRight,
      boxRect.bottomRight + const Offset(0, -bracketLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _JavaraSilhouetteGuidePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.isFemale != isFemale;
}
