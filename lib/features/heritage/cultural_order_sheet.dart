import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/culture_items.dart';
import '../../widgets/photo_box.dart';

/// Modal Pemesanan Busana & Wastra Autentik Pengrajin Jawa Tengah.
class CulturalOrderSheet extends StatefulWidget {
  const CulturalOrderSheet({super.key, required this.item});

  final CultureItem item;

  @override
  State<CulturalOrderSheet> createState() => _CulturalOrderSheetState();
}

class _CulturalOrderSheetState extends State<CulturalOrderSheet> {
  int _quantity = 1;
  String _selectedPackaging = 'Kotak Eksklusif Busana';
  bool _isSuccess = false;

  final List<String> _packagings = [
    'Kotak Eksklusif Busana',
    'Besek Bambu Tradisional',
    'Kemasan Kain Mori Halus',
  ];

  int _parsePrice() {
    final p = widget.item.price ?? 'Rp50.000';
    final cleaned = p.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 50000;
  }

  String _formatRupiah(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp$buffer';
  }

  void _confirmOrder() {
    HapticFeedback.mediumImpact();
    setState(() => _isSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = _parsePrice();
    final totalPrice = unitPrice * _quantity;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF5ED),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _isSuccess
          ? _buildSuccessView()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDECDB8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pemesanan Karya Pengrajin',
                      style: JText.serif(
                        18,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: JColors.ink,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kartu Produk
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEADBCA)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: AssetPhoto(file: widget.item.image),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: JText.serif(
                                15,
                                weight: FontWeight.w700,
                                color: JColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.regency.isNotEmpty
                                  ? widget.item.regency
                                  : widget.item.meta,
                              style: JText.serif(11.5, color: JColors.muted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRupiah(unitPrice),
                              style: JText.serif(
                                14,
                                weight: FontWeight.w800,
                                color: const Color(0xFFB5603A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Jumlah Pesanan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah Pesanan',
                      style: JText.serif(
                        14,
                        weight: FontWeight.w600,
                        color: JColors.ink,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE6D6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              size: 16,
                              color: JColors.ink,
                            ),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: JText.serif(
                              14,
                              weight: FontWeight.w700,
                              color: JColors.ink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: JColors.ink,
                            ),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Opsi Kemasan Tradisional
                Text(
                  'Pilihan Kemasan Tradisional',
                  style: JText.serif(
                    14,
                    weight: FontWeight.w600,
                    color: JColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _packagings.map((pkg) {
                    final isSelected = _selectedPackaging == pkg;
                    return ChoiceChip(
                      label: Text(pkg),
                      selected: isSelected,
                      selectedColor: const Color(0xFF3A261D),
                      backgroundColor: const Color(0xFFFFFDF9),
                      labelStyle: JText.serif(
                        12,
                        weight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFFFDF9E)
                            : JColors.ink,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF3A261D)
                              : const Color(0xFFEADBCA),
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPackaging = pkg),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Catatan Pengrajin
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DFD0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF6A7B5B),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '100% Produk kurasi asli dari pengrajin & mpu kriya Jawa Tengah.',
                          style: JText.serif(
                            12,
                            color: const Color(0xFF4A382A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Total & Tombol Beli
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: JText.serif(11.5, color: JColors.muted),
                        ),
                        Text(
                          _formatRupiah(totalPrice),
                          style: JText.serif(
                            20,
                            weight: FontWeight.w800,
                            color: JColors.ink,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _confirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A261D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: JText.serif(
                          14,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFFDF9E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0x223F6B3A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF3F6B3A),
              size: 54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pesanan Berhasil Disiapkan!',
            style: JText.serif(20, weight: FontWeight.w700, color: JColors.ink),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pesanan ${widget.item.title} ($_quantity item) dengan kemasan "$_selectedPackaging" telah diteruskan ke sentra pengrajin lokal di Jawa Tengah.',
              textAlign: TextAlign.center,
              style: JText.serif(13, color: JColors.muted, height: 1.45),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A261D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Selesai & Kembali',
              style: JText.serif(
                14,
                weight: FontWeight.w700,
                color: const Color(0xFFFFDF9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
