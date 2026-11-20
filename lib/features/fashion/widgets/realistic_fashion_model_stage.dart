import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/javanese_clothing_models.dart';
import '../models/realistic_fashion_model.dart';

/// Panggung Peraga Busana Adat Realistis Jawa Tengah ("Panggung Peraga Busana JAVARA")
/// Menampilkan model manusia nyata berbalut busana adat hasil riset mendalam,
/// dilengkapi panggung putar 3D (3D Turntable), pin ricikan interaktif (Hotspots),
/// dan pemilih model busana adat.
class RealisticFashionModelStage extends StatefulWidget {
  const RealisticFashionModelStage({
    super.key,
    required this.currentModel,
    required this.onSelectModel,
    this.onHotspotSelected,
    this.isEmbeddedMode = false,
  });

  final RealisticFashionModel currentModel;
  final ValueChanged<RealisticFashionModel> onSelectModel;
  final ValueChanged<ModelHotspot>? onHotspotSelected;
  final bool isEmbeddedMode;

  @override
  State<RealisticFashionModelStage> createState() => _RealisticFashionModelStageState();
}

class _RealisticFashionModelStageState extends State<RealisticFashionModelStage>
    with SingleTickerProviderStateMixin {
  double _orbitAngle = 0.0;
  ModelHotspot? _selectedHotspot;
  bool _showHotspotPins = true;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showHotspotDetailSheet(ModelHotspot hotspot) {
    setState(() => _selectedHotspot = hotspot);
    if (widget.onHotspotSelected != null) {
      widget.onHotspotSelected!(hotspot);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _HotspotCulturalDetailSheet(
        hotspot: hotspot,
        model: widget.currentModel,
        onClose: () {
          Navigator.of(ctx).pop();
          setState(() => _selectedHotspot = null);
        },
      ),
    );
  }

  void _showFullCulturalModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FullPhilosophyModal(model: widget.currentModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.currentModel;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14100D),
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.1,
          colors: [
            Color(0xFF241B15),
            Color(0xFF16110D),
            Color(0xFF0E0B08),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // -------------------------------------------------------------------
          // 1. SOROT LAMPU AMBIENT (STAGE SPOTLIGHT & SHADOW)
          // -------------------------------------------------------------------
          Positioned(
            bottom: widget.isEmbeddedMode ? 30 : 60,
            child: Container(
              width: widget.isEmbeddedMode ? 260 : 320,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(widget.isEmbeddedMode ? 130 : 160, 24),
                ),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDFB76C).withValues(alpha: 0.35),
                    const Color(0x66DFB76C),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // 2. PODIUM KAYU JATI UKIR 3D DI BAWAH KAKI MODEL
          // -------------------------------------------------------------------
          Positioned(
            bottom: widget.isEmbeddedMode ? 35 : 70,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(1.15)
                ..rotateZ(_orbitAngle),
              alignment: Alignment.center,
              child: _CarvedTeakPodium(size: widget.isEmbeddedMode ? 200 : 250),
            ),
          ),

          // -------------------------------------------------------------------
          // 3. MODEL PERAGA BUSANA REALISTIS (3D TURNTABLE DRAG INTERACTION)
          // -------------------------------------------------------------------
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _orbitAngle += details.primaryDelta! * 0.015;
                });
              },
              child: Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_orbitAngle),
                  alignment: Alignment.center,
                  child: Hero(
                    tag: 'realistic_model_${model.id}',
                    child: Container(
                      width: widget.isEmbeddedMode ? 260 : 340,
                      height: widget.isEmbeddedMode ? 320 : 430,
                      margin: EdgeInsets.only(
                        top: widget.isEmbeddedMode ? 10 : 25,
                        bottom: widget.isEmbeddedMode ? 35 : 70,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Foto Model Peraga Realistis Berbusana Adat
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              model.imageAsset,
                              width: widget.isEmbeddedMode ? 260 : 340,
                              height: widget.isEmbeddedMode ? 320 : 430,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildModelPlaceholder(model);
                              },
                            ),
                          ),

                          // Pantulan Cahaya Turntable Halus
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment(math.cos(_orbitAngle), -1.0),
                                  end: Alignment(-math.cos(_orbitAngle), 1.0),
                                  colors: [
                                    Colors.white.withValues(
                                      alpha: (0.12 * (math.sin(_orbitAngle) + 1.0)).clamp(0.0, 0.20),
                                    ),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.35),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ---------------------------------------------------
                          // HOTSPOT PINS (RICIKAN BUSANA INTERAKTIF)
                          // ---------------------------------------------------
                          if (_showHotspotPins)
                            ...model.hotspots.map((hotspot) {
                              final isSelected = _selectedHotspot?.id == hotspot.id;
                              final sWidth = widget.isEmbeddedMode ? 260.0 : 340.0;
                              final sHeight = widget.isEmbeddedMode ? 320.0 : 430.0;
                              final pinLeft = (hotspot.dx * sWidth - 13.0).clamp(4.0, sWidth - 32.0);
                              final pinTop = (hotspot.dy * sHeight - 13.0).clamp(4.0, sHeight - 44.0);
                              return Positioned(
                                left: pinLeft,
                                top: pinTop,
                                child: _buildHotspotPin(hotspot, isSelected),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // 4. KONTROL ATAS: INFORMASI MODEL & AKSARA JAWA
          // -------------------------------------------------------------------
          Positioned(
            top: widget.isEmbeddedMode ? 6 : 14,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identitas Busana Model
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC18130F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x66DFB76C), width: 0.9),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFB76C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                model.gender == GenderTarget.pria ? 'KAKUNG' : 'PUTRI',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14100D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                model.era,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFFDFB76C),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          model.title,
                          style: JText.serif(
                            widget.isEmbeddedMode ? 12 : 13.5,
                            weight: FontWeight.w700,
                            color: const Color(0xFFFAF6F0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          model.javaneseScript,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFDFB76C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Tombol Tool: Toggle Pin Hotspot & Reset Putar
                Column(
                  children: [
                    _buildRoundToolBtn(
                      icon: _showHotspotPins ? Icons.place_rounded : Icons.place_outlined,
                      tooltip: 'Tampilkan/Sembunyikan Pin Ricikan',
                      isActive: _showHotspotPins,
                      onTap: () => setState(() => _showHotspotPins = !_showHotspotPins),
                    ),
                    const SizedBox(height: 6),
                    _buildRoundToolBtn(
                      icon: Icons.sync_rounded,
                      tooltip: 'Reset Sudut Putar',
                      onTap: () => setState(() => _orbitAngle = 0.0),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // 5. BAR PEMILIH MODEL BUSANA JAWA TENGAH (MODEL SELECTOR BAR)
          // -------------------------------------------------------------------
          Positioned(
            bottom: widget.isEmbeddedMode ? 6 : 14,
            left: 0,
            right: 0,
            child: _buildModelSelectorBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotPin(ModelHotspot hotspot, bool isSelected) {
    return GestureDetector(
      onTap: () => _showHotspotDetailSheet(hotspot),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseScale = 1.0 + (_pulseController.value * 0.22);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: isSelected ? 1.3 : pulseScale,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFAF6F0) : const Color(0xFFDFB76C),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF14100D),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDFB76C).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: isSelected ? const Color(0xFF14100D) : const Color(0xFF1E1712),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xEE1E1712),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFDFB76C), width: 0.6),
                ),
                child: Text(
                  hotspot.name,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFAF6F0),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModelSelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PILIH MODEL PERAGA BUSANA ADAT',
                style: TextStyle(fontSize: 9.5, color: Color(0xFFDFB76C), fontWeight: FontWeight.w800),
              ),
              InkWell(
                onTap: _showFullCulturalModal,
                child: const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 12, color: Color(0xFFDFB76C)),
                    SizedBox(width: 4),
                    Text(
                      'Bedah Filosofi Lengkap',
                      style: TextStyle(fontSize: 9, color: Color(0xFFFAF6F0), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: RealisticFashionModel.curatedModels.map((m) {
                final isCurrent = m.id == widget.currentModel.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (!isCurrent) {
                        widget.onSelectModel(m);
                        setState(() {
                          _selectedHotspot = null;
                          _orbitAngle = 0.0;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFFDFB76C) : const Color(0xFF1E1712),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFFDFB76C) : const Color(0x44DFB76C),
                          width: 1.0,
                        ),
                        boxShadow: isCurrent
                            ? [
                                const BoxShadow(
                                  color: Color(0x44DFB76C),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.gender == GenderTarget.pria ? Icons.male_rounded : Icons.female_rounded,
                            size: 13,
                            color: isCurrent ? const Color(0xFF14100D) : const Color(0xFFDFB76C),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            m.title,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                              color: isCurrent ? const Color(0xFF14100D) : const Color(0xFFFAF6F0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundToolBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDFB76C) : const Color(0xCC1E1712),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDFB76C), width: 0.8),
      ),
      child: IconButton(
        padding: const EdgeInsets.all(7),
        constraints: const BoxConstraints(),
        icon: Icon(
          icon,
          size: 15,
          color: isActive ? const Color(0xFF14100D) : const Color(0xFFFAF6F0),
        ),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildModelPlaceholder(RealisticFashionModel model) {
    return Container(
      color: const Color(0xFF221A14),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_rounded, size: 64, color: Color(0xFFDFB76C)),
          const SizedBox(height: 12),
          Text(
            model.title,
            style: const TextStyle(color: Color(0xFFFAF6F0), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Podium Kayu Jati Ukir Melingkar (Carved Teak Circular Podium)
class _CarvedTeakPodium extends StatelessWidget {
  const _CarvedTeakPodium({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF5A3E26),
            Color(0xFF382313),
            Color(0xFF22140A),
          ],
        ),
        border: Border.all(color: const Color(0xFFDFB76C), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.75,
          height: size * 0.75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x77DFB76C), width: 1.2),
          ),
          child: Center(
            child: Icon(
              Icons.stars_rounded,
              size: size * 0.28,
              color: const Color(0x44DFB76C),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lembar Penjelasan Detail Hotspot Ricikan Budaya
class _HotspotCulturalDetailSheet extends StatelessWidget {
  const _HotspotCulturalDetailSheet({
    required this.hotspot,
    required this.model,
    required this.onClose,
  });

  final ModelHotspot hotspot;
  final RealisticFashionModel model;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1410),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: Color(0xFFDFB76C), width: 1.2)),
        boxShadow: [
          BoxShadow(color: Color(0xDD000000), blurRadius: 25, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Sheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2218),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDFB76C), width: 0.8),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Color(0xFFDFB76C), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotspot.name,
                        style: JText.serif(15, weight: FontWeight.w700, color: const Color(0xFFFAF6F0)),
                      ),
                      Text(
                        hotspot.javaneseScript,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDFB76C)),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFFA89989)),
                onPressed: onClose,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bahan & Konstruksi
          _buildInfoRow(
            icon: Icons.texture_rounded,
            title: 'Bahan & Konstruksi Otentik',
            content: hotspot.material,
          ),

          const SizedBox(height: 10),

          // Makna Filosofis
          _buildInfoRow(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Makna Filosofi Kehidupan',
            content: hotspot.philosophy,
          ),

          const SizedBox(height: 10),

          // Paugeran Adat Keraton
          _buildInfoRow(
            icon: Icons.gavel_rounded,
            title: 'Paugeran & Tata Aturan Adat',
            content: hotspot.courtRule,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF221A14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33DFB76C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFDFB76C)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDFB76C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFAF6F0), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Lembar Filosofi Lengkap Model Busana
class _FullPhilosophyModal extends StatelessWidget {
  const _FullPhilosophyModal({required this.model});
  final RealisticFashionModel model;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF17120E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(top: BorderSide(color: Color(0xFFDFB76C), width: 1.2)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x55DFB76C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                model.title,
                style: JText.serif(18, weight: FontWeight.w800, color: const Color(0xFFFAF6F0)),
              ),
              Text(
                model.subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFFDFB76C)),
              ),
              const SizedBox(height: 12),

              Text(
                model.description,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFFAF6F0), height: 1.45),
              ),
              const SizedBox(height: 16),

              const Text(
                'Filosofi Kebudayaan Luhur',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDFB76C)),
              ),
              const SizedBox(height: 4),
              Text(
                model.culturalPhilosophy,
                style: const TextStyle(fontSize: 12, color: Color(0xFFFAF6F0), height: 1.4),
              ),
              const SizedBox(height: 16),

              const Text(
                'Paugeran Adat & Konteks Sosial',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDFB76C)),
              ),
              const SizedBox(height: 4),
              Text(
                model.paugeranAdat,
                style: const TextStyle(fontSize: 12, color: Color(0xFFFAF6F0), height: 1.4),
              ),
              const SizedBox(height: 20),

              // Rincian Elemen Busana (Mustaka, Rasukan, Bebetan, Curiga)
              const Text(
                'Ricikan Kelengkapan Busana',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDFB76C)),
              ),
              const SizedBox(height: 8),
              _buildRicikanTile('Penutup Kepala (Mustaka)', model.headwearName),
              _buildRicikanTile('Busana Atasan (Rasukan)', model.upperBodyName),
              _buildRicikanTile('Kain Bawahan (Bebetan)', model.lowerBodyName),
              _buildRicikanTile('Aksesoris & Pusaka', model.accessoriesSummary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRicikanTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF201812),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33DFB76C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFDFB76C)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Color(0xFFFAF6F0)),
            ),
          ),
        ],
      ),
    );
  }
}
