import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme.dart';
import '../models/javanese_clothing_models.dart';
import '../models/realistic_fashion_model.dart';
import 'realistic_fashion_model_stage.dart';

/// Controller Penghubung Antara Flutter dan Mesin Three.js WebGL 3D
class ThreeJsWardrobeBridge {
  WebViewController? _webViewController;
  bool _isSceneReady = false;

  bool get isReady => _isSceneReady;

  void attachController(WebViewController controller) {
    _webViewController = controller;
  }

  void markReady() {
    _isSceneReady = true;
  }

  Future<void> sendCommand(String method, [dynamic arg]) async {
    if (_webViewController == null || !_isSceneReady) return;
    try {
      final script = arg != null
          ? 'window.ThreeJsBridge && window.ThreeJsBridge.$method(${jsonEncode(arg)});'
          : 'window.ThreeJsBridge && window.ThreeJsBridge.$method();';
      await _webViewController!.runJavaScript(script);
    } catch (e) {
      debugPrint('ThreeJsBridge call error ($method): $e');
    }
  }

  Future<void> setGender(GenderTarget gender) async {
    await sendCommand('initializeScene', gender == GenderTarget.pria ? 'pria' : 'wanita');
  }

  Future<void> changeUpper(String id) async {
    await sendCommand('changeUpperClothing', id);
  }

  Future<void> changeLower(String id) async {
    await sendCommand('changeLowerClothing', id);
  }

  Future<void> changeHeadwear(String id) async {
    await sendCommand('changeHeadwear', id);
  }

  Future<void> changeOutfit(String id) async {
    await sendCommand('changeOutfit', id);
  }

  Future<void> rotate(double radians) async {
    await sendCommand('rotateAvatar', radians);
  }

  Future<void> resetCamera() async {
    await sendCommand('resetCamera');
  }

  Future<void> toggleAutoRotate() async {
    await sendCommand('toggleAutoRotate');
  }
}

/// Widget Studio Real-Time 3D Virtual Wardrobe
///
/// Merender modul Three.js PBR WebGL melalui Flutter WebView dengan komunikasi
/// dua arah (bidirectional bridge) serta fallback otomatis ke mesin kanvas turntable
/// asli JAVARA jika WebGL tidak didukung pada hardware perangkat tertentu.
class ThreeJsWardrobeWebView extends StatefulWidget {
  const ThreeJsWardrobeWebView({
    super.key,
    required this.currentModel,
    this.bridge,
    this.onSelectModel,
  });

  final RealisticFashionModel currentModel;
  final ThreeJsWardrobeBridge? bridge;
  final ValueChanged<RealisticFashionModel>? onSelectModel;

  @override
  State<ThreeJsWardrobeWebView> createState() => _ThreeJsWardrobeWebViewState();
}

class _ThreeJsWardrobeWebViewState extends State<ThreeJsWardrobeWebView> {
  late final ThreeJsWardrobeBridge _bridge;
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isAutoRotating = false;

  @override
  void initState() {
    super.initState();
    _bridge = widget.bridge ?? ThreeJsWardrobeBridge();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint('Three.js WebView resource error: ${error.description}');
              if (mounted) setState(() => _hasError = true);
            },
          ),
        )
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage msg) {
            _handleJsMessage(msg.message);
          },
        );

      await controller.loadFlutterAsset('assets/web_3d/index.html');
      _bridge.attachController(controller);
      _webViewController = controller;
    } catch (e) {
      debugPrint('WebView initialization fallback: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _handleJsMessage(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'sceneReady') {
        _bridge.markReady();
        _bridge.setGender(widget.currentModel.gender);
      }
    } catch (e) {
      debugPrint('JS message parse error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika WebView/WebGL mengalami kendala hardware, gunakan Fallback Engine
    if (_hasError) {
      return RealisticFashionModelStage(
        currentModel: widget.currentModel,
        onSelectModel: widget.onSelectModel ?? (_) {},
        isEmbeddedMode: true,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF140F0C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x55DFB76C), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. TAMPILAN THREE.JS WEBGL CANVAS
          if (_webViewController != null)
            WebViewWidget(controller: _webViewController!),

          // 2. INDIKATOR MEMUAT SHADER
          if (_isLoading)
            Container(
              color: const Color(0xFF140F0C),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFFDFB76C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Memuat PBR Shader & 3D Geometry...',
                      style: JText.serif(12.5, color: const Color(0xFFE4C590)),
                    ),
                  ],
                ),
              ),
            ),

          // 3. KONTROL SUDUT KAMERA & ROTASI ORBITAL 360°
          Positioned(
            right: 14,
            top: 14,
            child: Column(
              children: [
                _buildCircleToolButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Reset Sudut Pandang',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _bridge.resetCamera();
                  },
                ),
                const SizedBox(height: 8),
                _buildCircleToolButton(
                  icon: _isAutoRotating ? Icons.pause_rounded : Icons.rotate_right_rounded,
                  tooltip: 'Putar Otomatis 360°',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isAutoRotating = !_isAutoRotating);
                    _bridge.toggleAutoRotate();
                  },
                ),
              ],
            ),
          ),

          // 4. PRESET SUDUT PANDANG EDITORIAL (DEPAN, BELAKANG, SAMPING)
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCameraAngleChip('Tampak Depan', 0.0),
                const SizedBox(width: 8),
                _buildCameraAngleChip('Samping', 1.57),
                const SizedBox(width: 8),
                _buildCameraAngleChip('Punggung Keris', 3.14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xCC1A1410),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x55DFB76C), width: 1.0),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 6),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFDFB76C), size: 18),
        ),
      ),
    );
  }

  Widget _buildCameraAngleChip(String label, double radians) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _bridge.rotate(radians);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xCC1E1712),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFAF6F0),
          ),
        ),
      ),
    );
  }
}
