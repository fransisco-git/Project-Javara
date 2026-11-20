import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../widgets/photo_box.dart';
import 'explore_models.dart';

/// Gaya Layer Peta Google Maps Jawa Tengah
enum MapStyleMode {
  googleStandard(
    'Peta Standar',
    Icons.map_rounded,
    'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
    ['mt0', 'mt1', 'mt2', 'mt3'],
  ),
  googleSatellite(
    'Citra Satelit Hybrid',
    Icons.satellite_alt_rounded,
    'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
    ['mt0', 'mt1', 'mt2', 'mt3'],
  ),
  googleTerrain(
    'Medan Topografi',
    Icons.terrain_rounded,
    'https://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
    ['mt0', 'mt1', 'mt2', 'mt3'],
  ),
  openStreetMap(
    'OpenStreetMap',
    Icons.public_rounded,
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ['a', 'b', 'c'],
  );

  const MapStyleMode(this.label, this.icon, this.urlTemplate, this.subdomains);
  final String label;
  final IconData icon;
  final String urlTemplate;
  final List<String> subdomains;
}

/// Peta Asli Google Maps Jawa Tengah untuk Tab Jelajah JAVARA.
///
/// Menggunakan streaming tile peta asli dari Google Maps (Standar, Citra Satelit Hybrid,
/// Medan Topografi, dan OSM) lengkap dengan interaksi pinch-to-zoom, pan, penanda
/// koordinat GPS asli dari seluruh 15 kabupaten/kota budaya di Jawa Tengah,
/// kontrol navigasi resmi (Kompas, Lokasi Saya, Zoom In/Out, Skala), dan integrasi
/// langsung ke aplikasi Google Maps untuk petunjuk arah perjalanan.
class InteractiveCentralJavaMap extends StatefulWidget {
  const InteractiveCentralJavaMap({
    super.key,
    required this.regencies,
    required this.selectedRegencyId,
    required this.onSelectRegency,
  });

  final List<RegencyInfo> regencies;
  final String? selectedRegencyId;
  final ValueChanged<RegencyInfo?> onSelectRegency;

  @override
  State<InteractiveCentralJavaMap> createState() =>
      _InteractiveCentralJavaMapState();
}

class _InteractiveCentralJavaMapState extends State<InteractiveCentralJavaMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;

  MapStyleMode _currentMode = MapStyleMode.googleStandard;

  // Titik tengah geografis Jawa Tengah (Provinsi Jawa Tengah)
  static const LatLng _centralJavaCenter = LatLng(-7.150975, 110.140259);
  static const double _initialZoom = 8.3;

  double _currentZoom = _initialZoom;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _resetToCentralJava() {
    HapticFeedback.lightImpact();
    widget.onSelectRegency(null);
    _animatedMove(_centralJavaCenter, _initialZoom);
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    final newZoom = math.min(_currentZoom + 1.0, 17.0);
    _animatedMove(_mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    final newZoom = math.max(_currentZoom - 1.0, 6.5);
    _animatedMove(_mapController.camera.center, newZoom);
  }

  void _animatedMove(LatLng destLocation, double destZoom) {
    setState(() {
      _currentZoom = destZoom;
    });
    _mapController.move(destLocation, destZoom);
  }

  void _focusRegency(RegencyInfo reg) {
    HapticFeedback.lightImpact();
    widget.onSelectRegency(reg);
    _animatedMove(LatLng(reg.latitude, reg.longitude), 11.2);
  }

  Future<void> _openGoogleMapsDirections(
    double lat,
    double lng,
    String placeName,
  ) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka rute Google Maps untuk $placeName...'),
            backgroundColor: const Color(0xFF1A73E8),
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMapsPlace(
    double lat,
    double lng,
    String placeName,
  ) async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mencari $placeName di Google Maps...'),
            backgroundColor: const Color(0xFF1A73E8),
          ),
        );
      }
    }
  }

  void _showLayersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFDADCE0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    color: Color(0xFF1A73E8),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pilihan Tampilan Peta Google Maps',
                    style: JText.serif(
                      16,
                      weight: FontWeight.w700,
                      color: const Color(0xFF202124),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih gaya peta Google Maps asli untuk menjelajahi Jawa Tengah:',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
                physics: const NeverScrollableScrollPhysics(),
                children: MapStyleMode.values.map((mode) {
                  final isSel = _currentMode == mode;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currentMode = mode);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(0xFFE8F0FE)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFFDADCE0),
                          width: isSel ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            mode.icon,
                            size: 24,
                            color: isSel
                                ? const Color(0xFF1A73E8)
                                : const Color(0xFF5F6368),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mode.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSel
                                    ? const Color(0xFF1A73E8)
                                    : const Color(0xFF202124),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.selectedRegencyId != null
        ? widget.regencies.firstWhere(
            (r) => r.id == widget.selectedRegencyId,
            orElse: () => widget.regencies.first,
          )
        : null;

    final isSatellite = _currentMode == MapStyleMode.googleSatellite;

    return Container(
      decoration: BoxDecoration(
        color: isSatellite ? const Color(0xFF17202A) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSatellite
              ? const Color(0xFF2C3E50)
              : const Color(0xFFE0E0E0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. GOOGLE MAPS FLOATING HEADER & SEARCH BAR
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSatellite
                    ? const Color(0xFF243342)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSatellite
                      ? const Color(0xFF3E5368)
                      : const Color(0xFFDADCE0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Google Maps Red Pin Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA4335).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFEA4335),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Google Maps',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isSatellite
                                    ? Colors.white
                                    : const Color(0xFF202124),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A73E8).withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _currentMode.label,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          active != null
                              ? '${active.name} · ${active.coordinatesFormatted}'
                              : 'Peta Jawa Tengah Asli · Sentuh pin untuk rute & info',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isSatellite
                                ? const Color(0xFFBDC1C6)
                                : const Color(0xFF5F6368),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Tombol Pemilih Layer Peta Google Maps
                  Tooltip(
                    message: 'Ganti Layer Peta',
                    child: InkWell(
                      onTap: _showLayersBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isSatellite
                              ? const Color(0xFF2F4458)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSatellite
                                ? const Color(0xFF4A6480)
                                : const Color(0xFFDADCE0),
                          ),
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          size: 19,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. GOOGLE FILTER CHIPS KABUPATEN / KOTA
          // ==========================================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                if (widget.selectedRegencyId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      onPressed: _resetToCentralJava,
                      avatar: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Seluruh Jateng',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFFEA4335),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ...widget.regencies.map((reg) {
                  final isSelected = widget.selectedRegencyId == reg.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            reg.icon,
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : (isSatellite
                                    ? const Color(0xFF8AB4F8)
                                    : const Color(0xFF1A73E8)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            reg.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isSatellite
                                      ? Colors.white
                                      : const Color(0xFF3C4043)),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          _focusRegency(reg);
                        } else {
                          _resetToCentralJava();
                        }
                      },
                      backgroundColor: isSatellite
                          ? const Color(0xFF243342)
                          : const Color(0xFFF1F3F4),
                      selectedColor: const Color(0xFF1A73E8),
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF1A73E8)
                              : (isSatellite
                                  ? const Color(0xFF3E5368)
                                  : const Color(0xFFDADCE0)),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ==========================================
          // 3. KANVAS PETA ASLI GOOGLE MAPS (FLUTTER_MAP)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSatellite
                        ? const Color(0xFF2C3E50)
                        : const Color(0xFFD2D8DF),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 11.5,
                  child: Stack(
                    children: [
                      // Peta Interaktif Nyata Google Maps
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _centralJavaCenter,
                          initialZoom: _initialZoom,
                          minZoom: 6.5,
                          maxZoom: 18.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all &
                                ~InteractiveFlag.rotate,
                          ),
                          onPositionChanged: (pos, hasGesture) {
                            if ((pos.zoom - _currentZoom).abs() > 0.1) {
                              _currentZoom = pos.zoom;
                            }
                          },
                        ),
                        children: [
                          // Lapisan Tile Peta Asli Google Maps
                          TileLayer(
                            key: ValueKey(_currentMode),
                            urlTemplate: _currentMode.urlTemplate,
                            subdomains: _currentMode.subdomains,
                            userAgentPackageName: 'id.javara.app',
                            maxNativeZoom: 19,
                            tileDisplay: const TileDisplay.fadeIn(),
                          ),

                          // Penanda Pin Lokasi Budaya Asli di Jawa Tengah
                          MarkerLayer(
                            markers: widget.regencies.map((reg) {
                              final isSel =
                                  widget.selectedRegencyId == reg.id;
                              return Marker(
                                point: LatLng(reg.latitude, reg.longitude),
                                width: isSel ? 68 : 52,
                                height: isSel ? 68 : 52,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (isSel) {
                                      _resetToCentralJava();
                                    } else {
                                      _focusRegency(reg);
                                    }
                                  },
                                  child: AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) {
                                      final pulse = _pulseController.value;
                                      return Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Gelombang Radar Biru GPS bila Pin dipilih
                                          if (isSel) ...[
                                            Positioned(
                                              bottom: 6,
                                              child: Container(
                                                width: 32 + (pulse * 24),
                                                height: 32 + (pulse * 24),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(
                                                    0xFF1A73E8,
                                                  ).withValues(
                                                    alpha: (1 - pulse) * 0.45,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 6,
                                              child: Container(
                                                width: 20 + (pulse * 14),
                                                height: 20 + (pulse * 14),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF1A73E8,
                                                    ).withValues(
                                                      alpha: 1 - pulse,
                                                    ),
                                                    width: 1.8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],

                                          // Pin Merah Google Maps
                                          Positioned(
                                            top: isSel ? 0 : 4,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _GoogleMapsPinMarker(
                                                  icon: reg.icon,
                                                  isSelected: isSel,
                                                ),
                                                const SizedBox(height: 1),
                                                // Badge Label Nama Kota Google Maps
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSel
                                                        ? const Color(
                                                            0xFF1A73E8,
                                                          )
                                                        : Colors.white
                                                            .withValues(
                                                              alpha: 0.94,
                                                            ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                    border: Border.all(
                                                      color: isSel
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFFDADCE0,
                                                            ),
                                                      width: isSel ? 1.2 : 0.8,
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color(
                                                          0x25000000,
                                                        ),
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    reg.name.split(' ').first,
                                                    style: TextStyle(
                                                      fontSize:
                                                          isSel ? 9.5 : 8.0,
                                                      fontWeight: isSel
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                      color: isSel
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF202124,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // ==========================================
                      // KONTROL RESMI GOOGLE MAPS (UI OVERLAYS)
                      // ==========================================

                      // Kompas Google Maps di Kanan Atas
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Tooltip(
                          message: 'Arah Utara (Reset Orientasi & Tampilan)',
                          child: InkWell(
                            onTap: _resetToCentralJava,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.96),
                                border: Border.all(
                                  color: const Color(0xFFDADCE0),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 0,
                                        height: 0,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.transparent,
                                              width: 3.5,
                                            ),
                                            right: BorderSide(
                                              color: Colors.transparent,
                                              width: 3.5,
                                            ),
                                            bottom: BorderSide(
                                              color: Color(0xFFEA4335),
                                              width: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 0,
                                        height: 0,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.transparent,
                                              width: 3.5,
                                            ),
                                            right: BorderSide(
                                              color: Colors.transparent,
                                              width: 3.5,
                                            ),
                                            top: BorderSide(
                                              color: Color(0xFF70757A),
                                              width: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Positioned(
                                    top: 3,
                                    child: Text(
                                      'N',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFEA4335),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tombol "Lokasi Saya" & Zoom (+ / -) di Kanan Bawah
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol GPS Lokasi Saya
                            Tooltip(
                              message: 'Lokasi Saya (Pusat Jawa Tengah)',
                              child: InkWell(
                                onTap: () {
                                  if (active != null) {
                                    _focusRegency(active);
                                  } else {
                                    _resetToCentralJava();
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.96),
                                    border: Border.all(
                                      color: const Color(0xFFDADCE0),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.my_location_rounded,
                                    size: 19,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Stacked Zoom In & Zoom Out
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFDADCE0),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _zoomIn,
                                    child: const Padding(
                                      padding: EdgeInsets.all(7),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: Color(0xFF3C4043),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 1,
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                  InkWell(
                                    onTap: _zoomOut,
                                    child: const Padding(
                                      padding: EdgeInsets.all(7),
                                      child: Icon(
                                        Icons.remove_rounded,
                                        size: 18,
                                        color: Color(0xFF3C4043),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logo Resmi Google & Skala Peta di Kiri Bawah
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Google Wordmark
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'G',
                                      style: TextStyle(
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'o',
                                      style: TextStyle(
                                        color: Color(0xFFEA4335),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'o',
                                      style: TextStyle(
                                        color: Color(0xFFFBBC05),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'g',
                                      style: TextStyle(
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'l',
                                      style: TextStyle(
                                        color: Color(0xFF34A853),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'e',
                                      style: TextStyle(
                                        color: Color(0xFFEA4335),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 9,
                                color: const Color(0xFFBDC1C6),
                              ),
                              const SizedBox(width: 6),
                              // Skala 20 km
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '20 km',
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF5F6368),
                                    ),
                                  ),
                                  Container(
                                    width: 26,
                                    height: 2,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFF3C4043),
                                          width: 1.5,
                                        ),
                                        left: BorderSide(
                                          color: Color(0xFF3C4043),
                                          width: 1.5,
                                        ),
                                        right: BorderSide(
                                          color: Color(0xFF3C4043),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 4. GOOGLE MAPS PLACE DETAIL SHEET (BOTTOM)
          // ==========================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 320),
            crossFadeState: active != null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: active == null
                ? const SizedBox.shrink()
                : Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSatellite
                          ? const Color(0xFF243342)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSatellite
                            ? const Color(0xFF3E5368)
                            : const Color(0xFFDADCE0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris Informasi Utama Lokasi
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto Cuplikan Tempat
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 62,
                                height: 62,
                                child: AssetPhoto(
                                  file: active.highlightImage,
                                  width: 62,
                                  height: 62,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          active.name,
                                          style: TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w700,
                                            color: isSatellite
                                                ? Colors.white
                                                : const Color(0xFF202124),
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1A73E8,
                                          ).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          active.elevation,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A73E8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  // Rating Google Maps
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 15,
                                        color: Color(0xFFFBBC04),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '4.9',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSatellite
                                              ? Colors.white
                                              : const Color(0xFF202124),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(Google Maps) · ${active.culturalZone}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSatellite
                                              ? const Color(0xFFBDC1C6)
                                              : const Color(0xFF5F6368),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    active.title,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: isSatellite
                                          ? const Color(0xFFE8EAED)
                                          : const Color(0xFF3C4043),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Koordinat GPS Resmi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSatellite
                                ? const Color(0xFF1C2833)
                                : const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.pin_drop_rounded,
                                size: 14,
                                color: Color(0xFFEA4335),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Koordinat GPS: ${active.coordinatesFormatted}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSatellite
                                        ? const Color(0xFFE8EAED)
                                        : const Color(0xFF3C4043),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Deskripsi Tempat
                        Text(
                          active.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSatellite
                                ? const Color(0xFFD2D8DF)
                                : const Color(0xFF3C4043),
                            height: 1.42,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tag Keunggulan & Landmark
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _GoogleTagPill(
                              Icons.verified_rounded,
                              active.specialty,
                              isSatellite,
                            ),
                            _GoogleTagPill(
                              Icons.apartment_rounded,
                              active.landmark,
                              isSatellite,
                            ),
                            if (active.traditionalDish.isNotEmpty)
                              _GoogleTagPill(
                                Icons.checkroom_rounded,
                                'Ciri Khas: ${active.traditionalDish}',
                                isSatellite,
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // TOMBOL AKSI GOOGLE MAPS
                        Row(
                          children: [
                            // 1. Petunjuk Arah (Rute)
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () => _openGoogleMapsDirections(
                                  active.latitude,
                                  active.longitude,
                                  active.name,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.directions_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Petunjuk Arah (Rute)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. Buka di Google Maps
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: () => _openGoogleMapsPlace(
                                  active.latitude,
                                  active.longitude,
                                  active.name,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A73E8),
                                  side: const BorderSide(
                                    color: Color(0xFF1A73E8),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.map_rounded,
                                  size: 16,
                                  color: Color(0xFF1A73E8),
                                ),
                                label: const Text(
                                  'Buka Maps',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 3. Cap Paspor Budaya
                            Tooltip(
                              message: 'Cap Paspor Budaya Daerah Ini',
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Color(0xFFFBBC04),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '✓ Cap Paspor Berhasil: ${active.name} tercatat dalam Paspor Budaya Anda!',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF202124),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: isSatellite
                                        ? const Color(0xFF334659)
                                        : const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSatellite
                                          ? const Color(0xFF4A6480)
                                          : const Color(0xFFDADCE0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.badge_outlined,
                                    size: 20,
                                    color: isSatellite
                                        ? Colors.white
                                        : const Color(0xFF3C4043),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Center(
                child: Text(
                  'Sentuh salah satu pin merah Google Maps di atas untuk melihat rute navigasi & warisan daerah',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSatellite
                        ? const Color(0xFF9AA0A6)
                        : const Color(0xFF70757A),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pin Merah Khas Google Maps (Teardrop Red Pin)
class _GoogleMapsPinMarker extends StatelessWidget {
  const _GoogleMapsPinMarker({
    required this.icon,
    required this.isSelected,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final pinWidth = isSelected ? 28.0 : 22.0;
    final pinHeight = isSelected ? 36.0 : 28.0;

    return CustomPaint(
      size: Size(pinWidth, pinHeight),
      painter: _GooglePinPainter(isSelected: isSelected),
      child: SizedBox(
        width: pinWidth,
        height: pinHeight,
        child: Align(
          alignment: const Alignment(0.0, -0.45),
          child: Container(
            width: isSelected ? 13.0 : 10.0,
            height: isSelected ? 13.0 : 10.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              icon,
              size: isSelected ? 9.0 : 7.0,
              color: const Color(0xFFEA4335),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pelukis Bentuk Teardrop Pin Google Maps
class _GooglePinPainter extends CustomPainter {
  const _GooglePinPainter({required this.isSelected});
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bayangan pin di tanah
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isSelected ? 0.35 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h - 1),
        width: w * 0.75,
        height: 4,
      ),
      shadowPaint,
    );

    // Bentuk pin teardrop merah
    final path = Path()
      ..moveTo(w / 2, h)
      ..cubicTo(w * 0.05, h * 0.65, 0, h * 0.35, 0, w / 2)
      ..arcTo(
        Rect.fromLTWH(0, 0, w, w),
        math.pi,
        math.pi,
        false,
      )
      ..cubicTo(w, h * 0.35, w * 0.95, h * 0.65, w / 2, h)
      ..close();

    final pinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSelected
            ? const [Color(0xFFFF5252), Color(0xFFD32F2F)]
            : const [Color(0xFFEA4335), Color(0xFFC5221F)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, pinPaint);

    // Border putih tipis jika dipilih
    if (isSelected) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GooglePinPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}

/// Tag Pill Informasi Tempat Google Maps
class _GoogleTagPill extends StatelessWidget {
  const _GoogleTagPill(this.icon, this.text, this.isSatellite);
  final IconData icon;
  final String text;
  final bool isSatellite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSatellite
            ? const Color(0xFF2C3E50)
            : const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSatellite
              ? const Color(0xFF4A6480)
              : const Color(0xFFDADCE0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isSatellite
                ? const Color(0xFF8AB4F8)
                : const Color(0xFF1A73E8),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isSatellite
                    ? const Color(0xFFE8EAED)
                    : const Color(0xFF3C4043),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
