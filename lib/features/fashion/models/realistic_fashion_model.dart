import 'package:flutter/material.dart';
import 'javanese_clothing_models.dart';

/// Hotspot anotasi ricikan pada tubuh model peraga busana
class ModelHotspot {
  const ModelHotspot({
    required this.id,
    required this.name,
    required this.javaneseScript,
    required this.category,
    required this.dx,
    required this.dy,
    required this.material,
    required this.philosophy,
    required this.courtRule,
  });

  final String id;
  final String name;
  final String javaneseScript;
  final ClothingCategory category;
  final double dx; // Posisi relatif x (0.0 - 1.0)
  final double dy; // Posisi relatif y (0.0 - 1.0)
  final String material;
  final String philosophy;
  final String courtRule;
}

/// Model Peraga Busana Adat Realistis Jawa Tengah
typedef RealisticFashionModelLibrary = RealisticFashionModel;

class RealisticFashionModel {
  const RealisticFashionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.javaneseScript,
    required this.gender,
    required this.region,
    required this.socialContext,
    required this.era,
    required this.imageAsset,
    required this.headwearName,
    required this.upperBodyName,
    required this.lowerBodyName,
    required this.accessoriesSummary,
    required this.description,
    required this.culturalPhilosophy,
    required this.paugeranAdat,
    required this.hotspots,
    required this.tags,
    this.primaryColor = const Color(0xFF1E1712),
    this.accentColor = const Color(0xFFDFB76C),
  });

  final String id;
  final String title;
  final String subtitle;
  final String javaneseScript;
  final GenderTarget gender;
  final TraditionRegion region;
  final SocialContext socialContext;
  final String era;
  final String imageAsset;
  final String headwearName;
  final String upperBodyName;
  final String lowerBodyName;
  final String accessoriesSummary;
  final String description;
  final String culturalPhilosophy;
  final String paugeranAdat;
  final List<ModelHotspot> hotspots;
  final List<String> tags;
  final Color primaryColor;
  final Color accentColor;

  /// Koleksi Model Peraga Busana Jawa Tengah Hasil Riset Autentik
  static const List<RealisticFashionModel> curatedModels = [
    // -------------------------------------------------------------------------
    // 1. Ksatria Ageng Jawi Jangkep Kasunanan Surakarta (Kakung)
    // -------------------------------------------------------------------------
    RealisticFashionModel(
      id: 'model_jawi_jangkep_solo',
      title: 'Busana Jawi Jangkep Kasunanan',
      subtitle: 'Pakem Ksatria & Bangsawan Keraton Surakarta Hadiningrat',
      javaneseScript: 'ꦧꦸꦱꦤꦗꦮꦶꦗꦁꦏꦼꦥ꧀ꦱꦸꦫꦏꦂꦠ',
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      socialContext: SocialContext.keratonBangsawan,
      era: 'Abad XVIII - Kasunanan Surakarta',
      imageAsset: 'assets/images/model_jawi_jangkep_solo.jpg',
      headwearName: 'Blangkon Trepes Surakarta (Parang Barong)',
      upperBodyName: 'Beskap Landhung Beludru Hitam Sulam Benang Emas',
      lowerBodyName: 'Jarik Batik Tulis Parang Barong Soganan Surakarta',
      accessoriesSummary: 'Keris Ladrang Solo Kayu Timoho, Sabuk Cinde, Epek Timang Prada, Selop Beludru Bordir',
      description:
          'Setelan agung resmi para bangsawan, pangeran, dan abdi dalem saat pisowanan agung di Sasana Sewaka Keraton Kasunanan Surakarta Hadiningrat. Memancarkan aura kepemimpinan, keteguhan hati, dan kesantunan luhur prajurit kebudayaan Jawa.',
      culturalPhilosophy:
          'Jawi Jangkep bermakna kesempurnaan manusia Jawa yang utuh lahir dan batin. Sikap tegap berbalut beskap melambangkan keteguhan prinsip hidup, sabuk cinde melambangkan pengekangan hawa nafsu, dan keris di belakang melambangkan kewaspadaan tanpa pamer kekuasaan.',
      paugeranAdat:
          'Motif Parang Barong merupakan batik larangan keraton yang hanya boleh dikenakan raja dan keturunan langsung pada upacara kenegaraan. Keris diselipkan miring ke kanan dengan roncen melati kuncup.',
      tags: ['Keraton Surakarta', 'Batik Larangan', 'Beskap Beludru', 'Keris Ladrang'],
      hotspots: [
        ModelHotspot(
          id: 'mustaka_blangkon_solo',
          name: 'Blangkon Trepes Kasunanan',
          javaneseScript: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀ꦠꦿꦺꦥꦺꦱ꧀',
          category: ClothingCategory.headwear,
          dx: 0.50,
          dy: 0.22,
          material: 'Kain mori batik tulis sogan parang, trepes datar di belakang tanpa mondholan besar.',
          philosophy: 'Bentuk trepes datar menyimbolkan pemikiran terbuka dan keikhlasan melepas beban duniawi di hadapan Sang Pencipta.',
          courtRule: 'Wajib dikenakan dengan posisi tegak simetris di atas dahi tanpa miring.',
        ),
        ModelHotspot(
          id: 'rasukan_beskap_landhung',
          name: 'Beskap Landhung Beludru Sulam Emas',
          javaneseScript: 'ꦧꦼꦱ꧀ꦏꦥ꧀ꦭꦤ꧀ꦝꦸꦁ',
          category: ClothingCategory.upperBody,
          dx: 0.50,
          dy: 0.38,
          material: 'Kain beludru sutra hitam pekat impor Eropa dengan bordir benang emas kencana.',
          philosophy: 'Warna hitam menyimbolkan keteguhan nafsu lawwamah dan keheningan jiwa ksatria Jawa.',
          courtRule: 'Kancing depan lurus tertutup rapat dari leher shanghai hingga dada.',
        ),
        ModelHotspot(
          id: 'sabuk_cinde_timang',
          name: 'Sabuk Cinde & Epek Timang Kencana',
          javaneseScript: 'ꦱꦧꦸꦏ꧀ꦕꦶꦤ꧀ꦢꦺ',
          category: ClothingCategory.accessories,
          dx: 0.48,
          dy: 0.48,
          material: 'Kain sutra cinde merah vermilion dengan gesper kuningan bertatahkan prada emas.',
          philosophy: 'Mengikat erat hawa nafsu perut dan syahwat agar manusia senantiasa eling lan waspada.',
          courtRule: 'Dipasang tepat melingkar di atas pinggang menahan kain jarik dan keris.',
        ),
        ModelHotspot(
          id: 'curiga_keris_ladrang',
          name: 'Keris Ladrang Gayaman Solo',
          javaneseScript: 'ꦏꦼꦫꦶꦱ꧀ꦭꦢꦿꦁ',
          category: ClothingCategory.accessories,
          dx: 0.62,
          dy: 0.47,
          material: 'Warangka ladrang kayu timoho pelet kendit bertatahkan pendok bunton emas murni.',
          philosophy: 'Curiga manjing warangka melambangkan kebersatuan raga dan sukma serta senjata pengendalian diri.',
          courtRule: 'Diselipkan di pinggang kanan belakang sebagai perlambang kesiapan membela negara.',
        ),
        ModelHotspot(
          id: 'bebet_jarik_parang',
          name: 'Jarik Batik Parang Barong Sogan',
          javaneseScript: 'ꦥꦫꦁꦧꦫꦺꦴꦁ',
          category: ClothingCategory.lowerBody,
          dx: 0.50,
          dy: 0.68,
          material: 'Mori primissima katun sutra malam alam pewarna soga jambal, tegeran, dan tingi.',
          philosophy: 'Ombak samudra parang melambangkan semangat pantang menyerah dan kesinambungan peradaban.',
          courtRule: 'Wiron jarik dilipat rapi ganjil ke arah kanan menurut adat Kasunanan Surakarta.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 2. Putri Ageng Kebaya Kartini Beludru Jepara-Solo (Putri)
    // -------------------------------------------------------------------------
    RealisticFashionModel(
      id: 'model_kebaya_kartini_solo',
      title: 'Kebaya Kartini Beludru Jepara',
      subtitle: 'Keanggunan Putri Bangsawan & Warisan Emansipasi Jawa Tengah',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶꦗꦼꦥꦫ',
      gender: GenderTarget.wanita,
      region: TraditionRegion.jepara,
      socialContext: SocialContext.priyayiFormal,
      era: 'Abad XIX - Pesisir Jepara & Surakarta',
      imageAsset: 'assets/images/model_kebaya_kartini_solo.jpg',
      headwearName: 'Sanggul Tekuk Klasik Ronce Melati & Cunduk Mentul',
      upperBodyName: 'Kebaya Panjang Beludru Hitam Sulam Prada Keraton',
      lowerBodyName: 'Jarik Batik Tulis Truntum Soganan Halus',
      accessoriesSummary: 'Bros Susun Tiga Kencana, Gelang Kana, Ronce Melati Tiba Dhadha, Selop Beludru',
      description:
          'Busana kebesaran putri bangsawan Jawa Tengah yang dipopulerkan oleh pahlawan emansipasi R.A. Kartini di Jepara dan Keraton Kasunanan Surakarta. Menampilkan siluet kebaya panjang beludru belahan V yang menutup pinggul dengan sulaman emas floral pesisiran yang halus.',
      culturalPhilosophy:
          'Potongan kebaya yang ramping dan menutup tubuh melambangkan kepribadian wanita Jawa yang anggun, santun, lembut namun memiliki keteguhan prinsip batin yang kokoh bagai samudra.',
      paugeranAdat:
          'Kain batik Truntum diciptakan oleh Kanjeng Ratu Kencana bermakna cinta yang bersemi kembali (tumaruntum), menjadi pakaian wajib upacara temu pengantin dan hajatan keraton.',
      tags: ['Bumi Kartini', 'Batik Truntum', 'Kebaya Beludru', 'Bros Susun'],
      hotspots: [
        ModelHotspot(
          id: 'mustaka_sanggul_tekuk',
          name: 'Sanggul Tekuk & Cunduk Mentul',
          javaneseScript: 'ꦱꦁꦒꦸꦭ꧀ꦠꦼꦏꦸꦏ꧀',
          category: ClothingCategory.headwear,
          dx: 0.50,
          dy: 0.16,
          material: 'Rambut asli dibentuk ukel tekuk dengan 7 cunduk mentul kencana bertabur intan.',
          philosophy: 'Tujuh cunduk mentul melambangkan pitulungan (pertolongan tulus dari Tuhan Yang Maha Esa).',
          courtRule: 'Diberi hiasan untaian ronce melati kuncup menjuntai lembut ke bahu kanan.',
        ),
        ModelHotspot(
          id: 'rasukan_kebaya_kartini',
          name: 'Kebaya Panjang Beludru Sutra',
          javaneseScript: 'ꦏꦼꦧꦪꦧꦼꦭꦸꦢꦿꦸ',
          category: ClothingCategory.upperBody,
          dx: 0.50,
          dy: 0.38,
          material: 'Beludru sutra belgia hitam pekat dengan sulam border benang emas motif lung-lungan.',
          philosophy: 'Potongan panjang hingga bawah pinggul melambangkan kehormatan dan martabat wanita terhormat.',
          courtRule: 'Disematkan bros susun tiga melambangkan keselarasan tiga alam semesta.',
        ),
        ModelHotspot(
          id: 'piageman_bros_susun',
          name: 'Bros Susun Tiga Emas Keraton',
          javaneseScript: 'ꦧꦿꦺꦴꦱ꧀ꦱꦸꦱꦸꦤ꧀',
          category: ClothingCategory.accessories,
          dx: 0.48,
          dy: 0.35,
          material: 'Emas murni bertatahkan batu permata intan berlian gaya pesisiran Jawa-Eropa.',
          philosophy: 'Tiga susunan mengartikan cipta, rasa, dan karsa dalam budi pekerti wanita adiluhung.',
          courtRule: 'Dipasang simetris vertikal menutup bukaan depan kebaya.',
        ),
        ModelHotspot(
          id: 'bebet_jarik_truntum',
          name: 'Jarik Batik Motif Truntum Sogan',
          javaneseScript: 'ꦧꦠꦶꦏ꧀ꦠꦿꦸꦤ꧀ꦠꦸꦩ꧀',
          category: ClothingCategory.lowerBody,
          dx: 0.50,
          dy: 0.68,
          material: 'Kain katun mori primissima halus dengan canting tulis tangan canthing isen cecek.',
          philosophy: 'Motif bintang kecil malam hari menandakan cinta tulus tanpa syarat yang membimbing arah.',
          courtRule: 'Ujung wiron menghadap ke kiri depan khas pemakaian putri Kasunanan.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 3. Ratu Pengantin Solo Basahan (Putri - Pengantin Keraton)
    // -------------------------------------------------------------------------
    RealisticFashionModel(
      id: 'model_solo_basahan_bride',
      title: 'Busana Pengantin Solo Basahan',
      subtitle: 'Tradisi Sakral Dodot Kampuh Alas-Alasan Keraton Solo',
      javaneseScript: 'ꦧꦸꦱꦤꦧꦱꦲꦤ꧀ꦱꦸꦫꦏꦂꦠ',
      gender: GenderTarget.wanita,
      region: TraditionRegion.surakarta,
      socialContext: SocialContext.pengantinTradisi,
      era: 'Era Dinasti Mataram Islam - Surakarta',
      imageAsset: 'assets/images/model_solo_basahan_bride.jpg',
      headwearName: 'Paes Solo Basahan Pupus Hijau & Sanggul Bokor Mengkurep',
      upperBodyName: 'Kemben Dodot Kampuh Alas-Alasan Hijau Prada Emas',
      lowerBodyName: 'Kain Jarik Cinde Merah Samparan Prada Kencana',
      accessoriesSummary: 'Kalung Tanggalan Susun, Kelat Bahu Naga Emas, Pending Kencana, Ronce Melati Tiba Dhadha',
      description:
          'Tata busana pengantin paling sakral dan adiluhung dalam khasanah kebudayaan Jawa Tengah. Pengantin wanita mengenakan kain dodot kampuh sepanjang 4 meter bermotif satwa hutan alas-alasan dengan riasan paes pupus hijau yang anggun mistis.',
      culturalPhilosophy:
          'Basahan melambangkan kepasrahan hamba di hadapan Sang Maha Kuasa saat melangkah ke jenjang mahligai rumah tangga. Motif alas-alasan melambangkan keanekaragaman flora fauna kehidupan yang harus dijaga kelestariannya.',
      paugeranAdat:
          'Dahulu hanya diperkenankan untuk upacara pernikahan putra-putri raja di Tratag Pagelaran Keraton Kasunanan Surakarta. Garis batas paes berwarna hijau tua daun pupus pisang muda.',
      tags: ['Solo Basahan', 'Dodot Kampuh', 'Paes Pupus Hijau', 'Sakral Keraton'],
      hotspots: [
        ModelHotspot(
          id: 'mustaka_paes_basahan',
          name: 'Paes Solo Basahan Pupus Hijau',
          javaneseScript: 'ꦥꦲꦺꦱ꧀ꦧꦱꦲꦤ꧀',
          category: ClothingCategory.headwear,
          dx: 0.50,
          dy: 0.16,
          material: 'Lulur lulut hijau dari daun pandan wangi dan dlingo bengle dengan 9 cunduk mentul.',
          philosophy: 'Lekukan gajahan melambangkan kemegahan gunung Semeru dan ketajaman intuisi keibuan.',
          courtRule: 'Diberi ronce melati binarung kuncup tiba dhadha panjang menjuntai hingga pinggul.',
        ),
        ModelHotspot(
          id: 'rasukan_dodot_alas_alasan',
          name: 'Dodot Kampuh Alas-Alasan Prada',
          javaneseScript: 'ꦢꦺꦴꦢꦺꦴꦠ꧀ꦏꦩ꧀ꦥꦸꦃ',
          category: ClothingCategory.upperBody,
          dx: 0.50,
          dy: 0.38,
          material: 'Kain panjang sutra tenun prada emas motif binatang rimba alas-alasan.',
          philosophy: 'Melingkupi raga dengan keindahan ciptaan semesta tanda syukur atas anugerah Ilahi.',
          courtRule: 'Dililitkan khusus dengan teknik bebetan ketat dibantu sabuk cinde prada.',
        ),
        ModelHotspot(
          id: 'piageman_kalung_tanggalan',
          name: 'Kalung Tanggalan & Kelat Bahu Naga',
          javaneseScript: 'ꦏꦭꦸꦁꦠꦁꦒꦭꦤ꧀',
          category: ClothingCategory.accessories,
          dx: 0.52,
          dy: 0.32,
          material: 'Emas murni 24 karat berukir motif bulan sabit tanggal muda dan sepasang naga kencana.',
          philosophy: 'Menyinari rumah tangga baru laksana rembulan sabit yang akan tumbuh purnama.',
          courtRule: 'Dikenakan menutupi dada atas yang terbuka anggun.',
        ),
        ModelHotspot(
          id: 'bebet_cinde_samparan',
          name: 'Samparan Cinde Merah Emas',
          javaneseScript: 'ꦱꦩ꧀ꦥꦫꦤ꧀ꦕꦶꦤ꧀ꦢꦺ',
          category: ClothingCategory.lowerBody,
          dx: 0.50,
          dy: 0.72,
          material: 'Kain tenun sutra patola India impor masa lampau dengan sulaman benang emas.',
          philosophy: 'Langkah kaki yang mantap menapaki jalan dharma rumah tangga sakinah.',
          courtRule: 'Ujung kain menyapu lantai anggun di bawah ikatan dodot kampuh.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 4. Pangeran Surjan Pranakan Sembagi (Kakung - Abdi Dalem & Priyayi)
    // -------------------------------------------------------------------------
    RealisticFashionModel(
      id: 'model_surjan_pranakan_solo',
      title: 'Busana Surjan Pranakan Sembagi',
      subtitle: 'Kearifan Budi Pekerti Priyayi & Kesantunan Luhur Jawa',
      javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦥꦿꦤꦏꦤ꧀ꦱꦼꦩ꧀ꦧꦒꦶ',
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      socialContext: SocialContext.priyayiFormal,
      era: 'Abad XIX - Mataram & Surakarta',
      imageAsset: 'assets/images/model_surjan_pranakan_solo.jpg',
      headwearName: 'Blangkon Solo Sogan Halus',
      upperBodyName: 'Surjan Tenun Lurik Prasojo Kancing Tiga Lurus',
      lowerBodyName: 'Jarik Batik Tulis Parang Kusumo Wiron Rapi',
      accessoriesSummary: 'Keris Ladrang Solo Warangka Gayaman, Epek Timang Ukir, Selop Beludru',
      description:
          'Busana tradisional kemeja khas Jawa yang sarat filosofi spiritual relijius diciptakan oleh Sunan Kalijaga. Menggunakan kain tenun lurik vertikal halus yang bersahaja dipadukan kancing berderet di leher shanghai dan dada.',
      culturalPhilosophy:
          'Kata surjan berasal dari suraksa-janma (menjaga manusia) atau siro-jan (pelita terang). Enam kancing di leher melambangkan Rukun Iman, dan dua kancing di dada melambangkan dua kalimat Syahadat.',
      paugeranAdat:
          'Kerap dikenakan pada upacara wilujengan selamatan, grebeg sekaten, pertemuan adat priyayi, dan ziarah makam leluhur Imogiri.',
      tags: ['Sunan Kalijaga', 'Rukun Iman', 'Tenun Lurik', 'Priyayi Santun'],
      hotspots: [
        ModelHotspot(
          id: 'mustaka_blangkon_surjan',
          name: 'Blangkon Solo Sogan Halus',
          javaneseScript: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀ꦱꦺꦴꦭꦺꦴ',
          category: ClothingCategory.headwear,
          dx: 0.50,
          dy: 0.16,
          material: 'Kain mori batik tulis sogan cokelat tanah dengan mondholan ceper tertutup.',
          philosophy: 'Menyimpan rahasia budi pekerti dan mengendalikan amarah dalam ketenangan.',
          courtRule: 'Dikenakan pas mengitari lingkar kepala sejajar pelipis.',
        ),
        ModelHotspot(
          id: 'rasukan_surjan_lurik',
          name: 'Surjan Lurik Prasojo Kerah Shanghai',
          javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦭꦸꦫꦶꦏ꧀',
          category: ClothingCategory.upperBody,
          dx: 0.50,
          dy: 0.36,
          material: 'Kain tenun katun serat alam lurik garis vertikal warna gelap cokelat-biru nila.',
          philosophy: 'Garis vertikal melambangkan hubungan vertikal hamba dengan Tuhan Yang Maha Esa (Habluminallah).',
          courtRule: 'Kancing depan berjumlah ganjil dipasang rapi dari bawah leher.',
        ),
        ModelHotspot(
          id: 'curiga_keris_surjan',
          name: 'Keris Gayaman Solo Warangka Timoho',
          javaneseScript: 'ꦏꦼꦫꦶꦱ꧀ꦒꦪꦩꦤ꧀',
          category: ClothingCategory.accessories,
          dx: 0.58,
          dy: 0.44,
          material: 'Bilah pamor beras wutah, warangka gayaman kayu timoho alami berpelitur tipis.',
          philosophy: 'Gayaman melambangkan ketenteraman dan kedamaian hidup dalam masyarakat.',
          courtRule: 'Diselipkan di balik sabuk pinggang menghadap ke samping kiri-kanan.',
        ),
        ModelHotspot(
          id: 'bebet_jarik_parang_kusumo',
          name: 'Jarik Parang Kusumo Wiron Rapi',
          javaneseScript: 'ꦥꦫꦁꦏꦸꦱꦸꦩꦺꦴ',
          category: ClothingCategory.lowerBody,
          dx: 0.50,
          dy: 0.70,
          material: 'Kain mori primissima batik tulis soga klasik dengan wiron lipatan 7 tumpuk.',
          philosophy: 'Kusumo bermakna bunga harum, melambangkan harapan agar pemakainya mengharumkan nama bangsa.',
          courtRule: 'Wiron diatur simetris dengan jarak lipatan 2.5 cm rapi.',
        ),
      ],
    ),
  ];

  static List<RealisticFashionModel> get models => curatedModels;

  static RealisticFashionModel getModelById(String id) {
    return curatedModels.firstWhere(
      (m) => m.id == id,
      orElse: () => curatedModels.first,
    );
  }
}

