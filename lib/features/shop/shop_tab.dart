import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/culture_items.dart';
import '../../data/shop_data.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/interactive_feedback.dart';
import '../heritage/cultural_order_sheet.dart';

/// Tab Belanja Warisan Jawa - Implementasi asli dari Figma Page 2 ('belanja.png').
/// Menampilkan kategori belanja budaya (Kuliner, Busana, Kerajinan, Event/Tiket)
/// dan daftar produk "Baru dipesan" dengan detail harga & asal daerah.
class ShopTab extends StatefulWidget {
  const ShopTab({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  final _searchController = TextEditingController();
  String _query = '';
  ShopCategory? _activeCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopProduct> get _filteredProducts {
    var list = shopProducts.toList();
    if (_activeCategory != null) {
      list = list.where((p) => p.category == _activeCategory).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(_query) ||
                p.origin.toLowerCase().contains(_query) ||
                p.category.label.toLowerCase().contains(_query),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: JavaraPullRefresh(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await Future.delayed(const Duration(milliseconds: 700));
              if (mounted) setState(() {});
            },
            child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          widget.onOpenTab(0);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: JColors.ink,
                    ),
                    Text(
                      'Belanja',
                      style: JText.serif(
                        17.5,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    IconButton(
                      onPressed: _showCartSheet,
                      icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                      color: JColors.ink,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E9D8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2D0B6)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  style: JText.serif(14, color: JColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Cari kuliner, busana, kerajinan, atau tiket',
                    hintStyle: JText.serif(13, color: JColors.hint),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: JColors.muted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Editorial Headline
              Text(
                'Belanja warisan Jawa',
                style: JText.serif(
                  28,
                  weight: FontWeight.w700,
                  color: JColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kuliner, busana, kerajinan, dan tiket pengalaman dalam satu tempat.',
                style: JText.serif(
                  14,
                  color: const Color(0xFF6E5B49),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Kategori Grid (2x2) sesuai Figma
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
                children: ShopCategory.values.map((cat) {
                  final isActive = _activeCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activeCategory = isActive ? null : cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive
                              ? JColors.gold
                              : const Color(0xFFE5D5BF),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isActive
                                ? const Color(0x1AC79B3A)
                                : const Color(0x0A3A261D),
                            blurRadius: isActive ? 12 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AssetPhoto(file: cat.image, radius: 0),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                            // Label & Subtitle
                            Positioned(
                              left: 14,
                              bottom: 14,
                              right: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.label,
                                    style: JText.serif(
                                      10,
                                      weight: FontWeight.w700,
                                      color: JColors.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat.title,
                                    style: JText.serif(
                                      16,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    cat.subtitle,
                                    style: JText.serif(
                                      11,
                                      color: const Color(0xFFDEC9AD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: JColors.gold,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: JColors.night,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Seksi "Baru dipesan" - Daftar Produk
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeCategory != null
                        ? _activeCategory!.title
                        : 'Baru dipesan',
                    style: JText.serif(
                      20,
                      weight: FontWeight.w700,
                      color: JColors.ink,
                    ),
                  ),
                  if (_activeCategory != null)
                    TextButton(
                      onPressed: () => setState(() => _activeCategory = null),
                      child: Text(
                        'Lihat semua',
                        style: JText.serif(
                          12.5,
                          weight: FontWeight.w600,
                          color: JColors.terracotta,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (products.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEADBCA)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 36,
                        color: JColors.muted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada produk ditemukan.',
                        style: JText.serif(14, color: JColors.muted),
                      ),
                    ],
                  ),
                )
              else
                ...products.map((product) => _buildProductCard(product)),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildProductCard(ShopProduct product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final cultureItem = CultureItem(
            id: product.id,
            title: product.title,
            tag: product.category.label,
            meta: product.origin,
            image: product.image,
            price: product.price,
            description:
                'Karya autentik dari maestro dan pengrajin lokal di ${product.origin}. Dikerjakan dengan ketelitian tangan tinggi dan material orisinal khas Jawa Tengah.',
            history: 'Warisan kerajinan Jawa Tengah yang telah diakui keagungan mutunya sejak berabad-abad, mencerminkan kearifan lokal Nusantara.',
            location: product.origin,
            regency: product.origin,
            highlights: const [
              '100% Orisinal & Autentik',
              'Dukungan Langsung untuk Seniman Lokal',
              'Garansi Kualitas Warisan Nusantara',
              'Kemasan Ramah Lingkungan',
            ],
          );
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CulturalOrderSheet(item: cultureItem),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEFE2CE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C3A261D),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Foto produk
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: AssetPhoto(
                        file: product.image,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: JColors.terracotta,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BARU',
                          style: JText.serif(
                            8,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.label,
                      style: JText.serif(
                        9.5,
                        weight: FontWeight.w700,
                        color: JColors.terracotta,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.title,
                      style: JText.serif(
                        15,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    Text(
                      product.origin,
                      style: JText.serif(11.5, color: JColors.muted),
                    ),
                  ],
                ),
              ),
              // Harga
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.price,
                    style: JText.serif(
                      14,
                      weight: FontWeight.w700,
                      color: JColors.button,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: JColors.gold,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: JText.serif(
                          10.5,
                          weight: FontWeight.w600,
                          color: JColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF9F5EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFCCB2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JColors.gold.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 36,
                  color: JColors.terracotta,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keranjang Khasanah Jawa',
                style: JText.serif(
                  18,
                  weight: FontWeight.w700,
                  color: JColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Belum ada pesanan kriya atau kuliner aktif. Pilih karya orisinal para maestro lokal Jawa Tengah untuk memesan langsung.',
                textAlign: TextAlign.center,
                style: JText.serif(12.5, color: JColors.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JColors.button,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Jelajahi Karya Pengrajin',
                    style: JText.serif(
                      14,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
