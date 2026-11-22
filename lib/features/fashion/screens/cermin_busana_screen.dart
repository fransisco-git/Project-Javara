import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme.dart';
import '../../../services/fashn_ai_service.dart';
import '../cermin/before_after_wipe_slider.dart';
import '../cermin/body_silhouette_painter.dart';
import '../cermin/garment_image_resolver.dart';
import 'clothing_detail_screen.dart';

/// Empat status (state) pada alur Cermin Busana.
enum CerminState {
  intro,
  liveCamera,
  processing,
  result,
}

/// Layar Cermin Busana (Virtual Try-On Budaya Jawa Tengah).
/// Menyediakan pengalaman visual intuitif, instan (<5 detik dipahami pengguna),
/// dan memberikan hasil yang jujur tanpa persentase palsu.
class CerminBusanaScreen extends StatefulWidget {
  const CerminBusanaScreen({
    super.key,
    this.onSwitchToCatalogTab,
    this.initialState = CerminState.intro,
    this.customResolver,
    this.overrideCameras,
    this.enableCameraAutoStart = false,
  });

  final VoidCallback? onSwitchToCatalogTab;
  final CerminState initialState;
  final GarmentImageResolver? customResolver;
  final List<CameraDescription>? overrideCameras;
  final bool enableCameraAutoStart;

  @override
  State<CerminBusanaScreen> createState() => _CerminBusanaScreenState();
}

class _CerminBusanaScreenState extends State<CerminBusanaScreen>
    with WidgetsBindingObserver {
  late CerminState _currentState;

  // Garment Resolver & Items
  late final GarmentImageResolver _resolver;
  List<GarmentRailEntry> _allGarments = [];
  bool _isLoadingGarments = true;
  GarmentRailCategory _selectedCategory = GarmentRailCategory.atasan;
  GarmentRailEntry? _selectedGarment;

  // Camera Management
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;
  bool _isCameraInitializing = false;
  String? _cameraErrorMessage;

  // Processing & Result State
  Uint8List? _capturedImageBytes;
  String? _resultImageUrl;
  bool _isCuratedShowcase = false;
  String _processingStatus = 'Menyiapkan busana adat...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentState = widget.initialState;
    _resolver = widget.customResolver ?? GarmentImageResolver();
    _isCuratedShowcase = !AppConfig.isFashnConfigured;

    _loadGarments();

    if (widget.enableCameraAutoStart && _currentState == CerminState.liveCamera) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed &&
        _currentState == CerminState.liveCamera) {
      _initCamera();
    }
  }

  Future<void> _loadGarments() async {
    try {
      final items = await _resolver.resolveAvailableGarments();
      if (!mounted) return;
      setState(() {
        _allGarments = items;
        _isLoadingGarments = false;
        final inCat = _filteredGarments;
        if (inCat.isNotEmpty) {
          _selectedGarment = inCat.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allGarments = [];
        _isLoadingGarments = false;
      });
    }
  }

  List<GarmentRailEntry> get _filteredGarments {
    return _allGarments
        .where((g) => g.category == _selectedCategory)
        .toList();
  }

  // --- CAMERA CONTROLLER LIFECYCLE ---

  Future<void> _initCamera() async {
    if (_isCameraInitializing) return;
    setState(() {
      _isCameraInitializing = true;
      _cameraErrorMessage = null;
    });

    try {
      final cameras = widget.overrideCameras ?? await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isCameraInitializing = false;
          _cameraErrorMessage =
              'Kamera tidak ditemukan pada perangkat ini.';
        });
        return;
      }

      _availableCameras = cameras;

      // Prioritaskan kamera depan (front camera) untuk cermin
      int frontIdx = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _currentCameraIndex = frontIdx != -1 ? frontIdx : 0;

      await _startCameraOnIndex(_currentCameraIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraInitializing = false;
        _cameraErrorMessage =
            'Akses kamera belum diizinkan. Mohon izinkan akses kamera di pengaturan perangkat.';
      });
    }
  }

  Future<void> _startCameraOnIndex(int index) async {
    final oldController = _cameraController;
    if (oldController != null) {
      _cameraController = null;
      await oldController.dispose();
    }

    final cameraDesc = _availableCameras[index];
    final controller = CameraController(
      cameraDesc,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _isCameraInitializing = false;
        _cameraErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraInitializing = false;
        _cameraErrorMessage =
            'Gagal membuka kamera: ${e.toString()}';
      });
    }
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2) return;
    HapticFeedback.selectionClick();
    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    await _startCameraOnIndex(_currentCameraIndex);
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  // --- TRY-ON EXECUTION ---

  Future<void> _triggerTryOn(GarmentRailEntry garment) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedGarment = garment;
      _currentState = CerminState.processing;
      _processingStatus = 'Menangkap siluet cermin...';
    });

    Uint8List? captured;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xfile = await _cameraController!.takePicture();
        captured = await xfile.readAsBytes();
      } catch (e) {
        debugPrint('Camera capture error: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _capturedImageBytes = captured;
      _processingStatus = 'Menyelaraskan proporsi busana adat...';
    });

    // Jalur FASHN AI Nyata jika terkonfigurasi
    if (AppConfig.isFashnConfigured && captured != null) {
      try {
        final modelBase64 = 'data:image/jpeg;base64,${base64Encode(captured)}';
        final garmentBytes = await rootBundle.load(garment.assetPath);
        final garmentBase64 =
            'data:image/png;base64,${base64Encode(garmentBytes.buffer.asUint8List())};';

        final tryOnResult = await FashnAiService.instance.runTryOn(
          modelImage: modelBase64,
          garmentImage: garmentBase64,
          category: garment.category.fashnCategory,
          garmentName: garment.name,
        );

        final finalStatus = await FashnAiService.instance.pollStatus(
          predictionId: tryOnResult.id,
          onProgress: (status, progress) {
            if (mounted) {
              setState(() => _processingStatus = status);
            }
          },
        );

        if (finalStatus.status == TryOnStatus.completed &&
            finalStatus.outputImageUrl != null) {
          if (!mounted) return;
          setState(() {
            _resultImageUrl = finalStatus.outputImageUrl;
            _isCuratedShowcase = false;
            _currentState = CerminState.result;
          });
          return;
        }
      } catch (e) {
        debugPrint('FASHN API Try-On failed: $e');
      }
    }

    // Mode Pembuktian Jujur (Fallback / Demo Showcase Kurasi)
    // Beri jeda tenang sejenak tanpa persentase palsu
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Ambil gambar kurasi fotorealistis sesuai busana
    final showcaseAsset = garment.clothingItem != null
        ? garment.clothingItem!.imageAsset
        : (garment.outfit != null
            ? garment.outfit!.imageAsset
            : garment.assetPath);

    setState(() {
      _resultImageUrl = showcaseAsset;
      _isCuratedShowcase = true; // Selalu beri label jujur
      _currentState = CerminState.result;
    });
  }

  // --- BUILD METHODS PER STATE ---

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF14100D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF14100D), // Permukaan gelap mewah
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentStateView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_currentState) {
      case CerminState.intro:
        return _buildIntroState();
      case CerminState.liveCamera:
        return _buildLiveCameraState();
      case CerminState.processing:
        return _buildProcessingState();
      case CerminState.result:
        return _buildResultState();
    }
  }

  // 1. STATE 1: INTRO (Tanpa kamera demi keamanan testing & privasi)
  Widget _buildIntroState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon cermin busana minimalis
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF261D17),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: JColors.antiqueGold.withAlpha(120),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: JColors.antiqueGold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 28),

              // Headline Cormorant Garamond
              Text(
                'Kenakan busana adat, langsung di cermin.',
                textAlign: TextAlign.center,
                style: JText.editorial(
                  28,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFAF6F0),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // One-line subtext
              Text(
                'Pilih busana warisan Jawa Tengah dan coba langsung melalui cermin interaktif.',
                textAlign: TextAlign.center,
                style: JText.sans(
                  14,
                  weight: FontWeight.w400,
                  color: const Color(0xFFD4C8B8),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),

              // Tombol Utama Emas "Nyalakan Kamera" (Min. 48dp)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _currentState = CerminState.liveCamera);
                    _initCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JColors.antiqueGold,
                    foregroundColor: JColors.deepJavaBrown,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Nyalakan Kamera',
                    style: JText.sans(
                      15,
                      weight: FontWeight.w700,
                      color: const Color(0xFF1E1712),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Teks "Lihat Koleksi"
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: widget.onSwitchToCatalogTab,
                  child: Text(
                    'Lihat Koleksi',
                    style: JText.sans(
                      14,
                      weight: FontWeight.w600,
                      color: JColors.antiqueGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. STATE 2: LIVE CAMERA & GARMENT RAIL
  Widget _buildLiveCameraState() {
    return DragTarget<GarmentRailEntry>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        _triggerTryOn(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isDragHovering = candidateData.isNotEmpty;

        return Stack(
          fit: StackFit.expand,
          children: [
            // A. Camera Preview / Error / Loading
            _buildCameraPreviewLayer(),

            // B. Faint Body Silhouette Guide
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: BodySilhouettePainter(
                    strokeColor: isDragHovering
                        ? Colors.white
                        : JColors.antiqueGold,
                    strokeWidth: isDragHovering ? 2.2 : 1.6,
                  ),
                ),
              ),
            ),

            // C. Subtle Top Scrim for Legibility
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xB314100D),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // D. Top Bar: Tip Chip & Flip Button
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Tip Chip
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC1E1712),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x33E4C590),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.accessibility_new_rounded,
                            color: JColors.antiqueGold,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Berdiri ±1,5 m, seluruh badan terlihat',
                              style: JText.sans(
                                12,
                                weight: FontWeight.w500,
                                color: const Color(0xFFF5F0E8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Flip Camera Button (if > 1 camera)
                  if (_availableCameras.length > 1) ...[
                    const SizedBox(width: 10),
                    Semantics(
                      button: true,
                      label: 'Ganti ke kamera lain',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xCC1E1712),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x33E4C590),
                            width: 0.8,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_ios_rounded,
                            color: JColors.antiqueGold,
                            size: 20,
                          ),
                          onPressed: _flipCamera,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // E. Subtle Bottom Scrim for Garment Rail
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 250,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xF014100D),
                        Color(0xB314100D),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // F. Bottom Section: Shutter Button + Horizontal Garment Rail
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Rana (Shutter)
                  Semantics(
                    button: true,
                    label: 'Ambil foto dan kenakan busana yang dipilih',
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: Material(
                        color: JColors.antiqueGold,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _selectedGarment != null
                              ? () => _triggerTryOn(_selectedGarment!)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pilih busana pada rel di bawah terlebih dahulu',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFF1E1712),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Garment Rail (Filter Chips + Horizontal List)
                  _buildGarmentRail(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCameraPreviewLayer() {
    if (_cameraErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                color: Color(0xFFC79B3A),
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                _cameraErrorMessage!,
                textAlign: TextAlign.center,
                style: JText.sans(
                  14,
                  weight: FontWeight.w500,
                  color: const Color(0xFFE8DED0),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _initCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JColors.antiqueGold,
                    foregroundColor: JColors.deepJavaBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCameraInitializing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(JColors.antiqueGold),
          strokeWidth: 2.2,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize?.height ??
                    constraints.maxWidth,
                height: _cameraController!.value.previewSize?.width ??
                    constraints.maxHeight,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGarmentRail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips (Atasan | Bawahan | Busana Lengkap)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: GarmentRailCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.label),
                    labelStyle: JText.sans(
                      12,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1E1712)
                          : const Color(0xFFD4C8B8),
                    ),
                    selected: isSelected,
                    selectedColor: JColors.antiqueGold,
                    backgroundColor: const Color(0xFF261D17),
                    side: BorderSide(
                      color: isSelected
                          ? JColors.antiqueGold
                          : const Color(0x33E4C590),
                      width: 1,
                    ),
                    onSelected: (val) {
                      if (!val) return;
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                        final items = _filteredGarments;
                        if (items.isNotEmpty) {
                          _selectedGarment = items.first;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Garment Thumbnails Horizontal Rail
        SizedBox(
          height: 122,
          child: _isLoadingGarments
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(JColors.antiqueGold),
                  ),
                )
              : _filteredGarments.isEmpty
                  ? Center(
                      child: Text(
                        'Busana sedang disiapkan',
                        style: JText.sans(
                          13,
                          weight: FontWeight.w500,
                          color: const Color(0xFFB0A290),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredGarments.length,
                      itemBuilder: (context, index) {
                        final garment = _filteredGarments[index];
                        final isSelected = _selectedGarment?.id == garment.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: LongPressDraggable<GarmentRailEntry>(
                            data: garment,
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF261D17),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: JColors.antiqueGold,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(160),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  garment.assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            child: Semantics(
                              button: true,
                              label:
                                  'Pilih busana ${garment.name}, tahan dan geser ke cermin atau ketuk',
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedGarment = garment);
                                },
                                child: SizedBox(
                                  width: 82,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Thumbnail Container (Min 72dp)
                                      Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF261D17),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? JColors.antiqueGold
                                                : const Color(0x33E4C590),
                                            width: isSelected ? 1.5 : 0.8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Image.asset(
                                          garment.assetPath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                            Icons.checkroom_rounded,
                                            color: JColors.antiqueGold,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Garment Name (Max 2 lines, Inter >= 12sp)
                                      Text(
                                        garment.name,
                                        style: JText.sans(
                                          12,
                                          weight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? JColors.antiqueGold
                                              : const Color(0xFFD4C8B8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // 3. STATE 3: PROCESSING (Calm overlay, one status line, no fake percentage)
  Widget _buildProcessingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: Captured image or dark canvas
        if (_capturedImageBytes != null)
          Image.memory(
            _capturedImageBytes!,
            fit: BoxFit.cover,
          )
        else
          Container(color: const Color(0xFF14100D)),

        // Calm Dark Overlay
        Container(color: const Color(0xCC14100D)),

        // Center Content: Spinner + One Honest Status Line
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(JColors.antiqueGold),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _processingStatus,
                  textAlign: TextAlign.center,
                  style: JText.sans(
                    15,
                    weight: FontWeight.w600,
                    color: const Color(0xFFFAF6F0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. STATE 4: RESULT (Honest result, before/after wipe slider, details)
  Widget _buildResultState() {
    final garment = _selectedGarment;

    return Column(
      children: [
        // Result Visual Area (Slider or Curated Showcase)
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isCuratedShowcase || _capturedImageBytes == null)
                // Mode Demonstrasi / Fallback: Tanpa slider wipe, tampilkan foto kurasi penuh
                Image.asset(
                  _resultImageUrl ??
                      (garment?.assetPath ?? 'assets/images/model_jawi_jangkep_solo.jpg'),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/model_jawi_jangkep_solo.jpg',
                    fit: BoxFit.cover,
                  ),
                )
              else
                // Mode FASHN AI Nyata: Tampilkan Sebelum / Sesudah Wipe Slider
                BeforeAfterWipeSlider(
                  beforeChild: Image.memory(
                    _capturedImageBytes!,
                    fit: BoxFit.cover,
                  ),
                  afterChild: _resultImageUrl != null &&
                          _resultImageUrl!.startsWith('http')
                      ? Image.network(
                          _resultImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.memory(
                            _capturedImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          _resultImageUrl ?? garment!.assetPath,
                          fit: BoxFit.cover,
                        ),
                ),

              // Chip Kejujuran: Muncul bila menggunakan foto kurasi (bukan foto asli pengguna)
              if (_isCuratedShowcase)
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE61E1712),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x66E4C590),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: JColors.antiqueGold,
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Pratinjau contoh, bukan foto Anda',
                              style: JText.sans(
                                12,
                                weight: FontWeight.w600,
                                color: const Color(0xFFF5F0E8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom Info Panel
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF181310),
            border: Border(
              top: BorderSide(
                color: Color(0x33E4C590),
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (garment != null) ...[
                // Garment Name (Cormorant Garamond, >= 20sp)
                Text(
                  garment.name,
                  style: JText.editorial(
                    22,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFAF6F0),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Region (Inter, >= 12sp)
                Text(
                  garment.regionTitle,
                  style: JText.sans(
                    12,
                    weight: FontWeight.w500,
                    color: JColors.antiqueGold,
                  ),
                ),
                const SizedBox(height: 8),

                // Philosophical Meaning (First Sentence Truncated)
                Text(
                  garment.firstSentenceMeaning,
                  style: JText.serif(
                    13,
                    weight: FontWeight.w400,
                    color: const Color(0xFFD4C8B8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons Row (Min height 48dp, touch targets safe)
              Row(
                children: [
                  // Button 1: "Coba busana lain" (Kembali ke State 2, kamera tetap hidup)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _currentState = CerminState.liveCamera;
                            _capturedImageBytes = null;
                            _resultImageUrl = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JColors.antiqueGold,
                          foregroundColor: const Color(0xFF1E1712),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Coba busana lain',
                          style: JText.sans(
                            13,
                            weight: FontWeight.w700,
                            color: const Color(0xFF1E1712),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Button 2: "Lihat detail" (Hanya untuk ClothingItem, disembunyikan untuk Outfit)
                  if (garment != null && garment.clothingItem != null) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClothingDetailScreen(
                                item: garment.clothingItem!,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: JColors.antiqueGold,
                            width: 1.2,
                          ),
                          foregroundColor: JColors.antiqueGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Lihat detail',
                          style: JText.sans(
                            13,
                            weight: FontWeight.w600,
                            color: JColors.antiqueGold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
