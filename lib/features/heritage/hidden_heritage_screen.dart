import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Model Pusaka Tersembunyi (Hidden Heritage).
class HiddenHeritageGem {
  const HiddenHeritageGem({
    required this.title,
    required this.regency,
    required this.category,
    required this.rarity,
    required this.description,
    required this.secretFact,
    required this.icon,
  });

  final String title;
  final String regency;
  final String category;
  final String rarity;
  final String description;
  final String secretFact;
  final IconData icon;
}

/// Halaman Pusaka Tersembunyi (Hidden Heritage).
/// Menyingkap situs purbakala, tradisi rahasia, dan keajaiban budaya Jawa Tengah yang jarang terungkap.
class HiddenHeritageScreen extends StatelessWidget {
  const HiddenHeritageScreen({super.key});

  static const List<HiddenHeritageGem> _gems = [
    HiddenHeritageGem(
      title: 'Candi Cetho & Sukuh Lawu',
      regency: 'Kabupaten Karanganyar',
      category: 'Purbakala Megalitik',
      rarity: 'Sangat Langka',
      description: 'Berdiri megah di ketinggian 1.496 mdpl di atas awan lereng barat Gunung Lawu. Memiliki tata ruang punden berundak menyerupai piramida suku Maya di Mesoamerika.',
      secretFact: 'Didirikan pada akhir keruntuhan Majapahit (abad ke-15) sebagai tempat ruwatan agung untuk mengembalikan kesucian jiwa dan menolak bala bencana zaman.',
      icon: Icons.landscape_rounded,
    ),
    HiddenHeritageGem(
      title: 'Api Abadi Mrapen',
      regency: 'Kabupaten Grobogan',
      category: 'Fenomena Alam & Sakral',
      rarity: 'Pusaka Geologis',
      description: 'Keluarnya gas alam yang membakar api abadi tanpa pernah padam meski diguyur hujan lebat. Menjadi sumber api suci perayaan Waisak Borobudur dan obor PON.',
      secretFact: 'Legenda Babad menceritakan Sunan Kalijaga menancapkan tongkat ke bumi saat mencari mata air untuk prajurit Demak, namun yang memancar adalah api abadi.',
      icon: Icons.local_fire_department_rounded,
    ),
    HiddenHeritageGem(
      title: 'Desa Purba Candirejo',
      regency: 'Kabupaten Magelang',
      category: 'Desa Adat & Budaya',
      rarity: 'Kearifan Lokal',
      description: 'Desa tradisional di lembah Bukit Menoreh yang masih mempertahankan pola hidup komunal gotong royong, arsitektur rumah limasan kayu, dan alat angkut andong dokar.',
      secretFact: 'Menyimpan situs Watu Kendil dan upacara adat Saparan Nyadran yang tidak pernah terputus selama lebih dari 400 tahun.',
      icon: Icons.cottage_rounded,
    ),
    HiddenHeritageGem(
      title: 'Batik Kuno Bakaran Juwana',
      regency: 'Kabupaten Pati',
      category: 'Wastra Pesisir Klasik',
      rarity: 'Langganan Kolektor',
      description: 'Gaya batik tulis unik berlatar retak-retak (remukan malam) dengan warna sogan kehitaman dan motif khas seperti Panca Tirta, Gandrung, dan Magel Padas.',
      secretFact: 'Dipelopori oleh Nyi Danowati (Mpu Nyi Banoel), dayang pembuat busana Keraton Majapahit yang melarikan diri ke Juwana saat perang saudara Paregreg.',
      icon: Icons.brush_rounded,
    ),
    HiddenHeritageGem(
      title: 'Benteng Pendem Fort Willem I',
      regency: 'Ambarawa, Kab. Semarang',
      category: 'Benteng Kolonial',
      rarity: 'Cagar Budaya Unik',
      description: 'Benteng pertahanan parit yang tersembunyi di bawah permukaan tanah diapit persawahan dan latar Gunung Merbabu. Memiliki lorong bawah tanah bata merah berarsitektur lengkung kubah.',
      secretFact: 'Dibangun tahun 1834 oleh Belanda sebagai markas logistik perang Diponegoro, kini menjadi objek riset arsitektur militer tertua di pedalaman Jawa.',
      icon: Icons.shield_rounded,
    ),
    HiddenHeritageGem(
      title: 'Seni Mistis Tari Sintren',
      regency: 'Pekalongan & Batang',
      category: 'Seni Pertunjukan Langka',
      rarity: 'Warisan Spiritual',
      description: 'Tari tradisional gadis berkaca mata hitam yang diikat tali tambang dan dimasukkan ke dalam kurung ayam bertutup kain mori, lalu keluar dalam keadaan berpakaian penari bidadari.',
      secretFact: 'Membawa pesan moral bahwa manusia harus keluar dari sangkar kegelapan hawa nafsu menuju pencerahan spiritual yang suci.',
      icon: Icons.theater_comedy_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF130914),
        appBar: AppBar(
          backgroundColor: const Color(0xFF130914),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFFDF9E),
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Pusaka Tersembunyi',
            style: JText.serif(
              18,
              weight: FontWeight.w700,
              color: const Color(0xFFFFDF9E),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF291223), Color(0xFF180A15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDFB76C),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.vpn_key_rounded,
                          color: Color(0xFFFFD700),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EKSPLORASI KHASANAH RAHASIA',
                          style: JText.serif(
                            11,
                            weight: FontWeight.w700,
                            color: const Color(0xFFFFDF9E),
                          ).copyWith(letterSpacing: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Menyingkap Pusaka yang Jarang Terjamah',
                      style: JText.serif(
                        18,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Di balik jalur wisata populer, Jawa Tengah menyimpan peradaban mistis, candi di atas awan, dan tradisi rahasia yang terawat utuh oleh masyarakat adat.',
                      style: JText.serif(
                        12.5,
                        color: const Color(0xFFC7B7A6),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Daftar Pusaka Tersembunyi
              for (final gem in _gems) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C0D1B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0x44DFB76C),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0x33DFB76C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              gem.icon,
                              color: const Color(0xFFFFDF9E),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      gem.category,
                                      style: JText.serif(
                                        10.5,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFB5603A),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33DFB76C),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        gem.rarity,
                                        style: JText.serif(
                                          9,
                                          weight: FontWeight.w700,
                                          color: const Color(0xFFFFD700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gem.title,
                                  style: JText.serif(
                                    16,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  gem.regency,
                                  style: JText.serif(
                                    11.5,
                                    color: const Color(0xFFB5A493),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        gem.description,
                        style: JText.serif(
                          13,
                          height: 1.5,
                          color: const Color(0xFFD6C8B8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Catatan Rahasia
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF281326),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x33DFB76C)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gem.secretFact,
                                style: JText.serif(
                                  11.5,
                                  color: const Color(0xFFFFDF9E),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
