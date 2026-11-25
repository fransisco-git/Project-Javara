import 'package:flutter/material.dart';
import '../models/javanese_clothing_models.dart';

/// Database Induk Busana Adat Jawa Tengah (JAVARA Cultural Archive)
class JavaneseClothingData {
  // ===========================================================================
  // 1. PENUTUP KEPALA (HEADWEAR / IKETAN & BLANGKON)
  // ===========================================================================
  static const List<ClothingItem> headwearItems = [
    ClothingItem(
      id: 'blangkon_surakarta_parang',
      name: 'Blangkon Surakarta Trepes',
      javaneseScript: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀ꦱꦸꦫꦏꦂꦠ',
      category: ClothingCategory.headwear,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Paku Buwono III - X)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain mori batik halus, karton khusus, malam lilin lebah, dan benang sutra.',
      philosophicalMeaning:
          'Bentuk belakang yang pipih rata (trepes tanpa mondholan) melambangkan keterbukaan pikiran, keikhlasan batin, serta kepasrahan hamba kepada Sang Pencipta tanpa menyimpan niat tersembunyi.',
      cuttingAndConstruction:
          'Lipatan wiru bertingkat presisi di bagian samping dengan 17 lipatan melambangkan jumlah rakaat shalat. Bagian belakang diikat rata (trepes) khas Kasunanan Surakarta.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'priyayi_solo', 'beskap_solo'],
      colorPalette: [Color(0xFF2C2219), Color(0xFFC79B3A), Color(0xFF6E4F32)],
      textureMotif: 'Batik Parang Klithik & Modang Kencana',
      historicalNotes:
          'Berkembang sejak masa Paku Buwono III setelah Perjanjian Giyanti 1755. Berbeda dengan gaya Yogya yang mempertahankan mondholan rambut, gaya Surakarta memotong rambut pendek sehingga blangkon dibuat trepes.',
      references: 'Serat Pranatan Busana Karaton Kasunanan Surakarta Hadiningrat, Raden Tumenggung Reksokusumo.',
      primaryColor: Color(0xFF38271A),
      accentColor: Color(0xFFE4C590),
    ),
    ClothingItem(
      id: 'blangkon_yogyakarta_sidomukti',
      name: 'Blangkon Yogyakarta Mondholan',
      javaneseScript: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀ꦔꦪꦺꦴꦒꦾꦏꦂꦠ',
      category: ClothingCategory.headwear,
      gender: GenderTarget.pria,
      region: TraditionRegion.yogyakarta,
      period: 'Abad 18 s.d. Kini (Hamengkubuwono I)',
      socialContext: SocialContext.priyayiFormal,
      material: 'Kain batik cap halus motif Sidomukti, kapas pengisi tonjolan, lem kanji tradisi.',
      philosophicalMeaning:
          'Mondholan bulat di bagian belakang menyimpan filosofi masyarakat Jawa yang pandai menyimpan rahasia pribadi serta aib sesama, mengedepankan kesantunan lahir batin.',
      cuttingAndConstruction:
          'Dilengkapi mondholan membulat menonjol di belakang tengkuk sebagai wadah rambut panjang yang digulung rapi.',
      compatibilityKeys: ['yogyakarta_formal', 'surjan_jogja', 'priyayi_jogja'],
      colorPalette: [Color(0xFF1E1610), Color(0xFFD4AF37), Color(0xFF5A3E26)],
      textureMotif: 'Batik Sidomukti & Nitik',
      historicalNotes:
          'Warisan busana Mataram Islam. Mondholan semula berfungsi sebagai wadah rambut pria Jawa zaman dahulu yang belum dipangkas pendek.',
      references: 'Tata Busana Adat Mataram Yogyakarta, K.R.T. Hardjonagoro.',
      primaryColor: Color(0xFF241912),
      accentColor: Color(0xFFDFB76C),
    ),
    ClothingItem(
      id: 'blangkon_banyumasan_wirasaba',
      name: 'Blangkon Banyumasan Wirasaba',
      javaneseScript: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀ꦧꦚꦸꦩꦱꦤ꧀',
      category: ClothingCategory.headwear,
      gender: GenderTarget.pria,
      region: TraditionRegion.banyumas,
      period: 'Abad 16 (Kadipaten Wirasaba / Joko Kaiman)',
      socialContext: SocialContext.keseharianRakyat,
      material: 'Kain tenun lurik katun kasar dan batik sogan Banyumasan motif Babon Angrem.',
      philosophicalMeaning:
          'Karakter tegas, lugas, egaliter (cablaka/blakasuta), tanpa kepura-puraan birokrasi istana yang rumit.',
      cuttingAndConstruction:
          'Kombinasi iket segitiga yang diperkuat dengan simpul samping fleksibel, lebih lebar dan menaungi kening.',
      compatibilityKeys: ['banyumas_tradisi', 'gandrung_banyumas', 'lurik_rakyat'],
      colorPalette: [Color(0xFF231F1C), Color(0xFF8B4513), Color(0xFFD2B48C)],
      textureMotif: 'Batik Sogan Gelap & Babon Angrem',
      historicalNotes:
          'Khas wilayah Banyumas dan Bagelen yang memiliki watak ksatria desa berjiwa mandiri serta menjunjung persaudaraan.',
      references: 'Babad Banyumas & Tradisi Pakaian Adat Lembaga Adat Banyumasan.',
      primaryColor: Color(0xFF2A231C),
      accentColor: Color(0xFFC79B3A),
    ),
    ClothingItem(
      id: 'kuluk_kanigaran_solo',
      name: 'Kuluk Kanigaran Karaton Solo',
      javaneseScript: 'ꦏꦸꦭꦸꦏ꧀ꦏꦤꦶꦒꦫꦤ꧀',
      category: ClothingCategory.headwear,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 19 (Paku Buwono VII - IX)',
      socialContext: SocialContext.pengantinTradisi,
      material: 'Kain beludru sutra hitam kaku (hardened velvet), benang prada emas 24k, dan hiasan permata intan.',
      philosophicalMeaning:
          'Bentuk silinder menjulang ke langit menyimbolkan keteguhan iman, martabat raja atau pengantin laksana raja sehari.',
      cuttingAndConstruction:
          'Silinder bermahkota tinggi tanpa tepi, dihiasi motif sulur prada emas melingkar dan jengger emas di bagian depan.',
      compatibilityKeys: ['kanigaran_solo', 'beskap_kanigaran', 'pengantin_agung'],
      colorPalette: [Color(0xFF0D0C0B), Color(0xFFFFD700), Color(0xFFC5A059)],
      textureMotif: 'Sulam Prada Kencana & Tumpal Emas',
      historicalNotes:
          'Kuluk ini diadaptasi dari mahkota raja Kasunanan untuk busana pernikahan adat Kanigaran, mengangkat kedua mempelai setara derajat kaum ningrat istana.',
      references: 'Upacara Pernikahan Adat Keraton Kasunanan Surakarta Hadiningrat, Sasana Pustaka Karaton Solo.',
      primaryColor: Color(0xFF151412),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'sanggul_tekuk_ronce_melati',
      name: 'Sanggul Tekuk & Ronce Melati Tiba Dada',
      javaneseScript: 'ꦱꦁꦒꦸꦭ꧀ꦠꦼꦏꦸꦏ꧀ꦩꦼꦭꦠꦶ',
      category: ClothingCategory.headwear,
      gender: GenderTarget.wanita,
      region: TraditionRegion.surakarta,
      period: 'Abad 17 (Era Sultan Agung s.d. Paku Buwono)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Rambut asli dipadu cemara, kembang melati segar ronce, cunduk mentul kencana sepuh emas.',
      philosophicalMeaning:
          'Aroma harum melati menggambarkan kemurnian budi pekerti wanita, sementara 7 cunduk mentul melambangkan pertolongan (pitulungan) dari Tuhan Yang Maha Esa.',
      cuttingAndConstruction:
          'Rambut ditekuk rapi membentuk oval simetris di tengkuk, dihiasi 5 atau 7 cunduk mentul emas, dan ronce melati bawang sebungkul menjuntai ke dada kanan.',
      compatibilityKeys: ['kebaya_solo', 'basahan_putri', 'kanigaran_putri', 'priyayi_putri'],
      colorPalette: [Color(0xFF100F0E), Color(0xFFFFFFFF), Color(0xFFFFDF7D)],
      textureMotif: 'Ronce Kuncup Melati & Ceplok Kenanga',
      historicalNotes:
          'Tatanan rambut resmi wanita keraton dan pengantin putri Kasunanan Surakarta yang melambangkan keanggunan seorang ibu pertiwi.',
      references: 'Busana Pengantin Tradisional Gaya Surakarta, Ny. Tien Santoso.',
      primaryColor: Color(0xFF1A1714),
      accentColor: Color(0xFFFFDF7D),
    ),
  ];

  // ===========================================================================
  // 2. BUSANA ATASAN (UPPER BODY / RASUKAN)
  // ===========================================================================
  static const List<ClothingItem> upperBodyItems = [
    ClothingItem(
      id: 'beskap_landhung_solo',
      name: 'Beskap Landhung Kasunanan Hitam',
      javaneseScript: 'ꦧꦼꦱ꧀ꦏꦥ꧀ꦭꦤ꧀ꦝꦸꦁ',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 19 (Paku Buwono X)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain wol/dril sutra hitam premium, kancing logam emas berukir lambang Sri Radya Laksana.',
      philosophicalMeaning:
          'Potongan kerah tegak kancing tertutup melambangkan keteguhan memegang janji luhur, kewibawaan lahiriah, dan kesantunan bertutur kata.',
      cuttingAndConstruction:
          'Kerah shanghai tegak tanpa lipatan luar, bukaan asimetris menyamping ke kanan dengan barisan kancing emas, serta potongan bawah belakang melengkung khusus untuk keris.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'beskap_solo', 'priyayi_solo'],
      colorPalette: [Color(0xFF141210), Color(0xFFC79B3A), Color(0xFF332921)],
      textureMotif: 'Tenun Wol Halus & Lis Benang Emas',
      historicalNotes:
          'Pakaian resmi pria keraton dalam upacara pasowanan agung. Krowok (potongan berlubang) di bagian belakang bawah dirancang presisi agar warangka keris dapat diselipkan tanpa mendesak jas.',
      references: 'Pranatan Lampahing Pasowanan Karaton Kasunanan Surakarta.',
      primaryColor: Color(0xFF1C1814),
      accentColor: Color(0xFFE4C590),
    ),
    ClothingItem(
      id: 'beskap_sikepan_beludru_emas',
      name: 'Beskap Sikepan Beludru Sulam Emas',
      javaneseScript: 'ꦧꦼꦱ꧀ꦏꦥ꧀ꦱꦶꦏꦼꦥꦤ꧀',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Paku Buwono IV)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Beludru sutra hitam tebal, benang kawat prada emas 24k, kemeja putih berenda katun Belanda.',
      philosophicalMeaning:
          'Keagungan dan kearifan kepemimpinan yang bersinar laksana emas tanpa menyilaukan rakyat kecil.',
      cuttingAndConstruction:
          'Bukaan depan terbuka (sikepan) yang memperlihatkan rompi/kutang putih berenda kancing emas di bagian dalam, dihiasi sulaman sulur emas di kerah dan manset lengan.',
      compatibilityKeys: ['kanigaran_solo', 'jawi_jangkep', 'pengantin_agung'],
      colorPalette: [Color(0xFF0F0E0C), Color(0xFFFFD700), Color(0xFFB8860B)],
      textureMotif: 'Sulam Timbul Sulur Gelung & Ronce Kencana',
      historicalNotes:
          'Dipakai oleh sentana dalem (pangeran keraton) dan mempelai pria dalam pernikahan agung gaya Kanigaran Surakarta.',
      references: 'Ensiklopedi Busana Adat Karaton Jawa, Balai Pustaka.',
      primaryColor: Color(0xFF141210),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'surjan_ontrokusumo_sutra',
      name: 'Surjan Ontrokusumo Sutra Kembang',
      javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦲꦺꦴꦤ꧀ꦠꦿꦺꦴꦏꦸꦱꦸꦩꦺꦴ',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 17 (Mataram Islam Sultan Agung)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain sutra jacquard tenun kembang bunga, benang perak dan benang emas prada.',
      philosophicalMeaning:
          'Berasal dari kata "su-ro-jo" (menjadi pelita). Kancing di bagian dada berjumlah 6 melambangkan Rukun Iman, 2 kancing leher melambangkan Kalimah Syahadat, dan 3 kancing dada bawah melambangkan nafsu yang harus dikendalikan.',
      cuttingAndConstruction:
          'Kerah tegak tinggi, kancing tertutup di leher dan dada, motif bunga-bunga halus mekar di atas dasar sutra krem keemasan.',
      compatibilityKeys: ['surjan_ontro', 'priyayi_solo', 'yogyakarta_formal'],
      colorPalette: [Color(0xFF4A3525), Color(0xFFE4C590), Color(0xFF8C6D46)],
      textureMotif: 'Jacquard Kembang Kusuma & Sulur Sari',
      historicalNotes:
          'Secara tradisi di Keraton, Surjan Ontrokusumo bermotif bunga hanya diperkenankan bagi bangsawan berpangkat tinggi atau upacara kehormatan khusus.',
      references: 'Falsafah Busana Adat Keraton Mataram, K.P.A. Winarno Kusumo.',
      primaryColor: Color(0xFF38271B),
      accentColor: Color(0xFFE4C590),
    ),
    ClothingItem(
      id: 'surjan_lurik_klaten',
      name: 'Surjan Lurik Tenun Prasaja Klaten',
      javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦭꦸꦫꦶꦏ꧀',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Tradisi Abadi Masyarakat Desa',
      socialContext: SocialContext.keseharianRakyat,
      material: 'Benang katun tenun ATBM (Alat Tenun Bukan Mesin) Pedan Klaten, pewarna soga alam.',
      philosophicalMeaning:
          'Kata "lurik" berakar dari kata lorek (garis lurus). Garis lurus adalah simbol kejujuran, keteguhan hati, dan kesederhanaan lahiriah yang sejalan dengan tuntunan ilahi.',
      cuttingAndConstruction:
          'Lengan panjang longgar, potongan lurus sederhana dengan motif garis vertikal hitam, cokelat tua, dan abu-abu arang.',
      compatibilityKeys: ['lurik_rakyat', 'banyumas_tradisi', 'keseharian_solo'],
      colorPalette: [Color(0xFF2B2621), Color(0xFF6B5848), Color(0xFFA6937C)],
      textureMotif: 'Lurik Tuluh Watu & Klenting Kuning',
      historicalNotes:
          'Kain tenun lurik menjadi identitas busana rakyat jelata, petani, hingga abdi dalem kawedanan di seantero wilayah Jawa Tengah.',
      references: 'Tenun Tradisional Pedan Klaten: Warisan Budaya Takbenda Kemendikbud.',
      primaryColor: Color(0xFF302821),
      accentColor: Color(0xFFA6937C),
    ),
    ClothingItem(
      id: 'kebaya_kartini_beludru_jepara',
      name: 'Kebaya Kartini Sutra Bordir Jepara',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶ',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.wanita,
      region: TraditionRegion.jepara,
      period: 'Akhir Abad 19 (Masa RA Kartini)',
      socialContext: SocialContext.priyayiFormal,
      material: 'Kain sutra halus warna terakota matang, bordiran benang katun kencana buatan tangan pengrajin Jepara.',
      philosophicalMeaning:
          'Potongan kerah V panjang yang menutup dada dengan anggun melambangkan emansipasi pikiran luhur wanita Jawa tanpa meninggalkan etika kesantunan budi pekerti.',
      cuttingAndConstruction:
          'Panjang kebaya menutup pinggul hingga paha atas, tanpa lipatan bef kutubaru di tengah, garis leher V memanjang ke bawah berhias bordir motif sulur ukiran Jepara.',
      compatibilityKeys: ['kebaya_kartini', 'priyayi_putri', 'kebaya_solo'],
      colorPalette: [Color(0xFF4A1A17), Color(0xFFE4C590), Color(0xFF7A2E2A)],
      textureMotif: 'Bordir Sulur Daun & Bunga Teratai Jepara',
      historicalNotes:
          'Dipopulerkan oleh Raden Ajeng Kartini di Jepara pada akhir abad ke-19, menjadi lambang kebangkitan intelektual dan keanggunan perempuan Nusantara.',
      references: 'Habis Gelap Terbitlah Terang, R.A. Kartini & Arsip Busana Museum Kartini Jepara.',
      primaryColor: Color(0xFF421614),
      accentColor: Color(0xFFE4C590),
    ),
    ClothingItem(
      id: 'kebaya_kutubaru_beludru_solo',
      name: 'Kebaya Kutubaru Beludru Solo',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦸꦠꦸꦧꦫꦸ',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.wanita,
      region: TraditionRegion.surakarta,
      period: 'Abad 19 (Era Kasunanan Surakarta)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain beludru sutra hitam legam, benang bordir emas, peniti emas permata susun tiga.',
      philosophicalMeaning:
          'Bef kain di bagian tengah dada melambangkan tameng perlindungan kehormatan dan kehangatan kasih sayang seorang wanita dalam keluarga.',
      cuttingAndConstruction:
          'Menggunakan bef (tambahan kain persegi di dada) menghubungkan sisi kiri dan kanan, kancing tertutup di sisi dalam, dipercantik dengan bros susun tiga (bros renteng).',
      compatibilityKeys: ['kebaya_solo', 'priyayi_putri', 'kanigaran_putri'],
      colorPalette: [Color(0xFF141210), Color(0xFFFFD700), Color(0xFF40342A)],
      textureMotif: 'Beludru Hitam Halus Bertepi Emas',
      historicalNotes:
          'Busana klasik putri bangsawan keraton Surakarta untuk upacara pernikahan atau resepsi resmi adat istana.',
      references: 'Busana Pengantin Keraton Jawa, Yayasan Pustaka Nusatama.',
      primaryColor: Color(0xFF181512),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'dodot_kampuh_basahan',
      name: 'Dodot Kampuh Basahan Emas',
      javaneseScript: 'ꦢꦺꦴꦝꦺꦴꦠ꧀ꦧꦱꦲꦤ꧀',
      category: ClothingCategory.upperBody,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 17 s.d. Kini (Paku Buwono)',
      socialContext: SocialContext.pengantinTradisi,
      material: 'Kain mori sutra halus panjang 4 meter, prada emas murni 24k serbuk timbul, malam soga alam.',
      philosophicalMeaning:
          'Busana basahan tanpa penutup baju atasan melambangkan kepasrahan total sepasang manusia yang suci lahir batin di hadapan Sang Hyang Widhi saat mengikat janji suci.',
      cuttingAndConstruction:
          'Kain berukuran dua kali lipat kain jarik biasa (kampuh), dililitkan di dada (kemben) untuk putri dan di pinggang hingga dada untuk kakung, menyisakan buntal roncean melati menjuntai.',
      compatibilityKeys: ['basahan_solo', 'basahan_putri', 'pengantin_agung'],
      colorPalette: [Color(0xFF241C14), Color(0xFFFFDF7D), Color(0xFF6B4C2A)],
      textureMotif: 'Batik Alas-Alasan & Prada Emas Mengkilap',
      historicalNotes:
          'Tata rias dan busana Solo Basahan adalah pusaka agung tertinggi Keraton Surakarta warisan Sultan Agung Hanyokrokusumo.',
      references: 'Serat Waduaji: Busana Upacara Karaton Kasunanan Surakarta.',
      primaryColor: Color(0xFF261D15),
      accentColor: Color(0xFFFFD700),
    ),
  ];

  // ===========================================================================
  // 3. BUSANA BAWAHAN (LOWER BODY / BEBET & KAIN JARIK)
  // ===========================================================================
  static const List<ClothingItem> lowerBodyItems = [
    ClothingItem(
      id: 'jarik_batik_parang_barong_solo',
      name: 'Kain Jarik Batik Parang Barong Solo',
      javaneseScript: 'ꦥꦫꦁꦧꦫꦺꦴꦁ',
      category: ClothingCategory.lowerBody,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 17 (Era Sultan Agung Mataram)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain primissima mori candi mekar, lilin malam klowong, pewarna soga jembangan alami Solo.',
      philosophicalMeaning:
          'Garis lereng diagonal 45 derajat berkesinambungan laksana ombak karang laut selatan yang tak pernah putus. Melambangkan perjuangan tanpa lelah memerangi hawa nafsu dan keteguhan pemimpin.',
      cuttingAndConstruction:
          'Ukuran parang besar (di atas 8 cm). Dililitkan sebagai bebet dengan wiru (lipatan) khas Solo di bagian depan: wiru menghadap ke arah kiri dengan tumpukan rapi ujung memanjang.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'beskap_solo', 'priyayi_solo', 'kanigaran_solo'],
      colorPalette: [Color(0xFF2C1E12), Color(0xFFE4C590), Color(0xFF7A5432)],
      textureMotif: 'Parang Barong Besar & Mlinjon',
      historicalNotes:
          'Dahulu merupakan Batik Awisan Dalem (motif larangan) di Keraton Surakarta yang hanya boleh dikenakan oleh Sunan/Raja dan putra mahkota.',
      references: 'Batik Pengaruh Keraton Surakarta, K.R.T. Hardjonagoro (Go Tik Swan).',
      primaryColor: Color(0xFF332216),
      accentColor: Color(0xFFE4C590),
      assetImagePath: 'assets/images/batik/batik_parang_barong.jpg',
    ),
    ClothingItem(
      id: 'jarik_batik_sidomukti_solo',
      name: 'Kain Jarik Batik Sidomukti Pengantin',
      javaneseScript: 'ꦱꦶꦢꦺꦴꦩꦸꦏ꧀ꦠꦶ',
      category: ClothingCategory.lowerBody,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Paku Buwono IV)',
      socialContext: SocialContext.pengantinTradisi,
      material: 'Katun primissima halus, soga kayu tingi dan jambal, proses mbabar tradisi 40 hari.',
      philosophicalMeaning:
          '"Sido" artinya menjadi/tercapai, dan "Mukti" artinya mulia dan bahagia lahir batin. Mengandung doa agar pemakainya memperoleh kemakmuran, derajat luhur, dan kelanggengan hidup berumah tangga.',
      cuttingAndConstruction:
          'Dihiasi ornamen garuda bersayap tunggal (lar), mahkota pohon hayat, dan kupu-kupu. Diwiru halus dengan 7 lipatan bersilang.',
      compatibilityKeys: ['kanigaran_solo', 'kebaya_solo', 'beskap_solo', 'priyayi_putri', 'pengantin_agung'],
      colorPalette: [Color(0xFF3D2A1A), Color(0xFFDFC08E), Color(0xFF8B5D33)],
      textureMotif: 'Sidomukti Gurda & Bunga Teratai',
      historicalNotes:
          'Kain jarik wajib bagi mempelai pengantin adat Jawa gaya Solo pada saat prosesi panggih dan akad nikah.',
      references: 'Makna Simbolik Motif Batik Klasik Jawa, Nian S. Djoemena.',
      primaryColor: Color(0xFF3B2718),
      accentColor: Color(0xFFDFC08E),
      assetImagePath: 'assets/images/batik/batik_sidomukti.jpg',
    ),
    ClothingItem(
      id: 'jarik_batik_truntum_solo',
      name: 'Kain Jarik Batik Truntum',
      javaneseScript: 'ꦠꦿꦸꦤ꧀ꦠꦸꦩ꧀',
      category: ClothingCategory.lowerBody,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Diciptakan Kanjeng Ratu Beruk / PB III)',
      socialContext: SocialContext.pengantinTradisi,
      material: 'Mori katun halus, malam remukan alam, pewarnaan cokelat soga khas Laweyan Solo.',
      philosophicalMeaning:
          '"Truntum" berasal dari kata "tumaruntum" yang berarti bersemi kembali. Bunga-bunga kecil bertabur di latar gelap melambangkan cinta kasih tulus tanpa pamrih yang selalu tumbuh menuntun anak cucu.',
      cuttingAndConstruction:
          'Pola geometris titik-titik kuncup melati bintang mekar merata di seluruh bidang kain. Dikenakan oleh orang tua pengantin pada upacara panggih.',
      compatibilityKeys: ['kebaya_solo', 'surakarta_formal', 'priyayi_solo', 'pengantin_agung'],
      colorPalette: [Color(0xFF26190F), Color(0xFFE8D3B0), Color(0xFF5E4029)],
      textureMotif: 'Bintang Tabur Kuncup Melati Tumaruntum',
      historicalNotes:
          'Diciptakan oleh permaisuri Paku Buwono III yang menatap langit berbintang malam sunyi hingga cinta sang raja bersemi kembali.',
      references: 'Kisah Penciptaan Batik Truntum, Balai Pelestarian Nilai Budaya D.I. Yogyakarta & Jateng.',
      primaryColor: Color(0xFF2E1F14),
      accentColor: Color(0xFFE8D3B0),
      assetImagePath: 'assets/images/batik/batik_truntum.jpg',
    ),
    ClothingItem(
      id: 'jarik_batik_kawung_picis',
      name: 'Kain Jarik Batik Kawung Picis',
      javaneseScript: 'ꦏꦮꦸꦁꦥꦶꦕꦶꦱ꧀',
      category: ClothingCategory.lowerBody,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 13 s.d. Mataram Islam',
      socialContext: SocialContext.priyayiFormal,
      material: 'Katun tenun halus tradisional, pewarna soga alam kulit pohon jambal dan tegeran.',
      philosophicalMeaning:
          'Bentuk bundar empat elips melambangkan buah kolang-kaling (kelapa aren) yang suci bersih di dalam. Mengajarkan manusia untuk bermanfaat dari akar hingga pucuk bagi kemaslahatan sesama.',
      cuttingAndConstruction:
          'Ukuran kawung kecil (sebesar mata uang picis zaman Belanda). Menghasilkan susunan teratur yang menampakkan kedisiplinan dan ketenangan batin.',
      compatibilityKeys: ['surjan_ontro', 'priyayi_solo', 'priyayi_jogja', 'lurik_rakyat', 'surakarta_formal'],
      colorPalette: [Color(0xFF2A1C12), Color(0xFFD6B57E), Color(0xFF63462E)],
      textureMotif: 'Kawung Picis Geometris Empat Arah Mata Angin',
      historicalNotes:
          'Salah satu motif batik tertua di Pulau Jawa yang terpahat pada arca candi Kidal dan Singhasari abad ke-13.',
      references: 'Ragam Hias Batik Jawa Kuno, P.K. Ojong.',
      primaryColor: Color(0xFF302015),
      accentColor: Color(0xFFD6B57E),
      assetImagePath: 'assets/images/batik/batik_kawung_picis.jpg',
    ),
    ClothingItem(
      id: 'jarik_batik_buketan_pekalongan',
      name: 'Sarung Batik Buketan Pesisir Pekalongan',
      javaneseScript: 'ꦧꦸꦏꦺꦠꦤ꧀ꦥꦼꦏꦭꦺꦴꦔꦤ꧀',
      category: ClothingCategory.lowerBody,
      gender: GenderTarget.wanita,
      region: TraditionRegion.pekalongan,
      period: 'Awal Abad 20 (Akulturasi Indo-Eropa & Tionghoa)',
      socialContext: SocialContext.keseharianRakyat,
      material: 'Kain katun santung halus, pewarna remasol cerah merah delima, hijau giok, dan jingga.',
      philosophicalMeaning:
          'Rangkaian karangan bunga (bouqet) dan burung merak mencerminkan sukacita, optimisme maritim, dan keterbukaan budaya pesisir utara terhadap peradaban dunia.',
      cuttingAndConstruction:
          'Bentuk sarung pesisiran dengan kepala sarung bermotif tumpal segitiga dan badan sarung penuh ilustrasi flora fauna berwarna kontras.',
      compatibilityKeys: ['kebaya_kartini', 'pesisir_pekalongan', 'keseharian_solo'],
      colorPalette: [Color(0xFF8B1E1E), Color(0xFF2E6B4F), Color(0xFFE8B244)],
      textureMotif: 'Rangkaian Bunga Krisan & Burung Hong Pesisir',
      historicalNotes:
          'Dikembangkan oleh pengrajin batik Pekalongan seperti E. van Zuylen dan perajin peranakan Kauman Pekalongan yang sangat digemari saudagar maritim.',
      references: 'Batik Belanda 1840-1940: Dutch Influence in Batik from Java, Harmen Veldhuisen.',
      primaryColor: Color(0xFF5A1C1C),
      accentColor: Color(0xFFE8B244),
      assetImagePath: 'assets/images/batik/batik_buketan_pekalongan.jpg',
    ),
  ];

  // ===========================================================================
  // 4. RICIKAN & AKSESORIS (ACCESSORIES / RICIKAN KERIS & TIMANG)
  // ===========================================================================
  static const List<ClothingItem> accessoryItems = [
    ClothingItem(
      id: 'keris_ladrang_solo_kayu_timoho',
      name: 'Keris Warangka Ladrang Kasunanan Solo',
      javaneseScript: 'ꦏꦼꦫꦶꦱ꧀ꦭꦢꦿꦁꦱꦺꦴꦭꦺꦴ',
      category: ClothingCategory.accessories,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Pakubuwono Era)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Bilah besi meteorit pamor Beras Wutah, warangka kayu timoho pelet alami, pendok bunton perak sepuh emas.',
      philosophicalMeaning:
          'Keris bukan senjata pembunuh melainkan pusaka pengendali amarah (sipat kandel), penyimpan doa keselamatan, dan penanda derajat kehormatan ksatria Jawa.',
      cuttingAndConstruction:
          'Gaya Ladrang Solo memiliki lengkungan perahu warangka yang ramping melengkung elegan ke atas, diselipkan di pinggang belakang miring ke arah kanan.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'beskap_solo', 'kanigaran_solo', 'priyayi_solo'],
      colorPalette: [Color(0xFF4A3018), Color(0xFFFFD700), Color(0xFF1F1D1B)],
      textureMotif: 'Urat Kayu Timoho Pelet Kucing & Pamor Beras Wutah',
      historicalNotes:
          'Warangka Ladrang dikenakan khusus untuk menghadiri upacara resmi atau pasowanan keraton. Pada hari biasa digunakan warangka Gayaman yang lebih bulat praktis.',
      references: 'Ensiklopedi Keris Indonesia, Bambang Harsrinuksmo.',
      primaryColor: Color(0xFF382312),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'sabuk_cinde_epek_timang_emas',
      name: 'Sabuk Cinde & Epek Timang Sepuh Emas',
      javaneseScript: 'ꦱꦧꦸꦏ꧀ꦕꦶꦤ꧀ꦢꦺꦠꦶꦩꦁ',
      category: ClothingCategory.accessories,
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      period: 'Abad 18 (Paku Buwono III)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Kain sutra cinde merah jingga bermotif patola Gujarat, ikat pinggang kulit epek beludru, gesper timang kuningan sepuh emas bertatah intan.',
      philosophicalMeaning:
          'Mengikat pinggang berarti mengendalikan hawa nafsu perut dan keserakahan, menegakkan punggung agar selalu bersikap teguh dan adil.',
      cuttingAndConstruction:
          'Sabuk cinde dililitkan mengelilingi pinggang sebagai bantalan, kemudian dikunci erat dengan epek hitam berkepala gesper timang emas berukir lung-lungan.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'beskap_solo', 'kanigaran_solo'],
      colorPalette: [Color(0xFF8B2518), Color(0xFFFFD700), Color(0xFF1A1A1A)],
      textureMotif: 'Cinde Patola Bunga Merah & Ukiran Emas Timang',
      historicalNotes:
          'Kelengkapan mutlak dalam busana adat Jawi Jangkep Kasunanan Surakarta. Timang emas menandakan kedudukan resmi di hadapan raja.',
      references: 'Tuntunan Busana Adat Karaton Surakarta, Sasana Budaya Karaton.',
      primaryColor: Color(0xFF6B1B12),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'bros_rodha_kalung_ulur_putri',
      name: 'Kalung Ulur Tiga Tingkat & Bros Rodha',
      javaneseScript: 'ꦏꦭꦸꦁꦲꦸꦭꦸꦂꦧꦿꦺꦴꦱ꧀',
      category: ClothingCategory.accessories,
      gender: GenderTarget.wanita,
      region: TraditionRegion.surakarta,
      period: 'Abad 19 (Paku Buwono IX - X)',
      socialContext: SocialContext.keratonBangsawan,
      material: 'Emas murni 22k, batu permata zamrud dan berlian banjar, enamel prada keraton.',
      philosophicalMeaning:
          'Tiga tingkatan kalung melambangkan trilogi alam semesta (alam atas, alam perantara, dan alam bawah) serta keseimbangan cipta, rasa, dan karsa seorang wanita ningrat.',
      cuttingAndConstruction:
          'Dua bros peniti disematkan pada lipatan kebaya kutubaru, dihubungkan rantai emas gantung tiga susun yang jatuh menjuntai di atas bef beludru.',
      compatibilityKeys: ['kebaya_solo', 'kebaya_kartini', 'priyayi_putri', 'kanigaran_putri'],
      colorPalette: [Color(0xFFFFD700), Color(0xFF0F5A47), Color(0xFFF7F2EA)],
      textureMotif: 'Bros Rodha Surya Kencana & Mutiara',
      historicalNotes:
          'Perhiasan dada wajib para ratu, gusti putri, dan pengantin wanita gaya Surakarta Hadiningrat.',
      references: 'Perhiasan Tradisional Pengantin Jawa, Dr. Suwati Kartiwa.',
      primaryColor: Color(0xFF382F18),
      accentColor: Color(0xFFFFD700),
    ),
    ClothingItem(
      id: 'selop_beludru_sulam_emas',
      name: 'Selop Beludru Berpayet Benang Emas',
      javaneseScript: 'ꦱꦺꦭꦺꦴꦥ꧀ꦧꦼꦭꦸꦢꦿꦸ',
      category: ClothingCategory.accessories,
      gender: GenderTarget.unisex,
      region: TraditionRegion.surakarta,
      period: 'Abad 19 (Paku Buwono X)',
      socialContext: SocialContext.priyayiFormal,
      material: 'Kulit sapi halus lapisan dalam, beludru sutra hitam bagian luar, sulaman monte payet emas.',
      philosophicalMeaning:
          'Menjaga setiap langkah kaki agar senantiasa berjalan di jalan yang lurus dan terpuji, tidak menodai tanah pertiwi dengan kecongkakan.',
      cuttingAndConstruction:
          'Ujung depan sedikit melengkung tertutup dan bagian tumit terbuka (mule slipper), dihiasi bordiran benang emas motif bunga melati.',
      compatibilityKeys: ['surakarta_formal', 'jawi_jangkep', 'kebaya_solo', 'kanigaran_solo', 'priyayi_solo'],
      colorPalette: [Color(0xFF12100E), Color(0xFFFFD700), Color(0xFF40352A)],
      textureMotif: 'Bordir Payet Sulur Bunga Melati Emas',
      historicalNotes:
          'Selop diperkenalkan di lingkungan keraton pada akhir abad ke-19 untuk menggantikan kebiasaan nyeker (tanpa alas kaki) di lingkungan luar keraton.',
      references: 'Tata Busana Kasunanan Surakarta Hadiningrat, Sasana Pustaka.',
      primaryColor: Color(0xFF1C1916),
      accentColor: Color(0xFFFFD700),
    ),
  ];

  // ===========================================================================
  // 5. SETELAN BUSANA LENGKAP KURASI ("JELAJAHI BUSANA")
  // ===========================================================================
  static const List<TraditionalOutfit> curatedOutfits = [
    TraditionalOutfit(
      id: 'outfit_jawi_jangkep_langenharjan',
      title: 'Busana Jawi Jangkep Langenharjan',
      javaneseScript: 'ꦧꦸꦱꦤꦗꦮꦶꦗꦁꦏꦼꦥ꧀',
      collectionCategory: 'Koleksi Keraton Kasunanan',
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      era: 'Abad 19 (Paku Buwono IX - X)',
      headwearId: 'blangkon_surakarta_parang',
      upperBodyId: 'beskap_landhung_solo',
      lowerBodyId: 'jarik_batik_parang_barong_solo',
      accessoryIds: [
        'keris_ladrang_solo_kayu_timoho',
        'sabuk_cinde_epek_timang_emas',
        'selop_beludru_sulam_emas',
      ],
      summary:
          'Setelan busana resmi pria keraton Surakarta Hadiningrat paling paripurna yang mencerminkan martabat adiluhung, wibawa kepemimpinan ksatria, dan kepatuhan pada aturan tatakrama istana.',
      culturalPhilosophy:
          'Jawi Jangkep bermakna busana Jawa yang lengkap lahir batin. Penutup kepala blangkon trepes menundukkan ego akal, beskap kancing leher mengendalikan ucapan, kain jarik melangkah teratur, dan keris di belakang mengendalikan hawa nafsu amarah.',
      etiquetteRules:
          'Dilarang mengenakan keris di depan dada saat menghadap Sunan/Raja. Selop dilepas ketika memasuki Sasana Sewaka Karaton Surakarta.',
      historicalSources:
          'Serat Angger-Angger Pranatan Busana Karaton Kasunanan Surakarta Hadiningrat & Sasana Pustaka Solo.',
      dominantColors: [Color(0xFF141210), Color(0xFFC79B3A), Color(0xFF2C1E12)],
    ),
    TraditionalOutfit(
      id: 'outfit_solo_kanigaran_beludru',
      title: 'Busana Pengantin Solo Kanigaran',
      javaneseScript: 'ꦧꦸꦱꦤꦏꦤꦶꦒꦫꦤ꧀',
      collectionCategory: 'Koleksi Pengantin Adiluhung',
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      era: 'Abad 19 (Paku Buwono VII)',
      headwearId: 'kuluk_kanigaran_solo',
      upperBodyId: 'beskap_sikepan_beludru_emas',
      lowerBodyId: 'jarik_batik_sidomukti_solo',
      accessoryIds: [
        'keris_ladrang_solo_kayu_timoho',
        'sabuk_cinde_epek_timang_emas',
        'selop_beludru_sulam_emas',
      ],
      summary:
          'Busana kebesaran pengantin pria adat Solo Kanigaran yang memadukan kehangatan beludru hitam bersulam benang kawat emas prada dengan kuluk mahkota ningrat.',
      culturalPhilosophy:
          'Mengangkat kedua mempelai menjadi raja dan ratu sehari (raja sadina). Motif Sidomukti menautkan doa kemuliaan hidup berumahtangga yang diberkahi rezeki melimpah.',
      etiquetteRules:
          'Dikenakan pada upacara resepsi panggih agung setelah prosesi akad nikah selesai.',
      historicalSources:
          'Buku Upacara Perkawinan Adat Surakarta Hadiningrat, K.R.T. Sasraningrat.',
      dominantColors: [Color(0xFF0F0E0C), Color(0xFFFFD700), Color(0xFF3D2A1A)],
    ),
    TraditionalOutfit(
      id: 'outfit_kebaya_kartini_jepara_ningrat',
      title: 'Busana Kebaya Kartini Ningrat Jepara',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶꦗꦼꦥꦫ',
      collectionCategory: 'Koleksi Priyayi & Intelektual',
      gender: GenderTarget.wanita,
      region: TraditionRegion.jepara,
      era: 'Akhir Abad 19 (1890-an)',
      headwearId: 'sanggul_tekuk_ronce_melati',
      upperBodyId: 'kebaya_kartini_beludru_jepara',
      lowerBodyId: 'jarik_batik_kawung_picis',
      accessoryIds: [
        'bros_rodha_kalung_ulur_putri',
        'selop_beludru_sulam_emas',
      ],
      summary:
          'Setelan anggun putri bangsawan pesisir utara Jepara yang dipelopori R.A. Kartini, memadukan kehalusan sutra terakota berhias bordir ukir Jepara dengan kesucian kain batik Kawung.',
      culturalPhilosophy:
          'Bentuk kerah V panjang yang menutup dada dengan santun melambangkan kejernihan pikiran emansipasi wanita, sementara motif Kawung Picis menegaskan kemurnian budi pekerti yang berbakti pada nusa bangsa.',
      etiquetteRules:
          'Langkah kaki harus tenang (mingset lumampah) dengan iringan aroma melati kuncup di dada kanan.',
      historicalSources:
          'Koleksi Foto & Surat R.A. Kartini, Museum Kartini Kabupaten Jepara.',
      dominantColors: [Color(0xFF421614), Color(0xFFE4C590), Color(0xFF302015)],
    ),
    TraditionalOutfit(
      id: 'outfit_priyayi_surjan_ontrokusumo',
      title: 'Busana Priyayi Surjan Ontrokusumo',
      javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦲꦺꦴꦤ꧀ꦠꦿꦺꦴꦏꦸꦱꦸꦩꦺꦴ',
      collectionCategory: 'Koleksi Priyayi & Formal',
      gender: GenderTarget.pria,
      region: TraditionRegion.surakarta,
      era: 'Abad 18 s.d. Kini',
      headwearId: 'blangkon_surakarta_parang',
      upperBodyId: 'surjan_ontrokusumo_sutra',
      lowerBodyId: 'jarik_batik_kawung_picis',
      accessoryIds: [
        'keris_ladrang_solo_kayu_timoho',
        'selop_beludru_sulam_emas',
      ],
      summary:
          'Busana kehormatan kaum priyayi berwibawa dengan kain surjan sutra jacquard kembang keemasan yang menentramkan pandangan.',
      culturalPhilosophy:
          'Enam kancing dada menyimbolkan Rukun Iman dan keteguhan bertauhid, berpadu dengan motif Kawung yang menepis fitnah duniawi.',
      etiquetteRules:
          'Dikenakan untuk acara adat pasowanan ageng, wisuda keraton, dan upacara keluarga ningrat.',
      historicalSources:
          'Serat Tatacara Djawa, Ki Padmasusastra, Balai Pustaka 1907.',
      dominantColors: [Color(0xFF38271B), Color(0xFFE4C590), Color(0xFF2A1C12)],
    ),
    TraditionalOutfit(
      id: 'outfit_keseharian_lurik_klaten',
      title: 'Busana Keseharian Tenun Lurik Prasaja',
      javaneseScript: 'ꦭꦸꦫꦶꦏ꧀ꦥꦿꦱꦗ',
      collectionCategory: 'Koleksi Keseharian Rakyat',
      gender: GenderTarget.pria,
      region: TraditionRegion.banyumas,
      era: 'Tradisi Abadi Nusantara',
      headwearId: 'blangkon_banyumasan_wirasaba',
      upperBodyId: 'surjan_lurik_klaten',
      lowerBodyId: 'jarik_batik_kawung_picis',
      accessoryIds: [],
      summary:
          'Busana bersahaja masyarakat desa dan petani di kawasan Banyumas, Klaten, dan Solo yang mengedepankan kepraktisan tenun katun adem penangkal terik matahari sawah.',
      culturalPhilosophy:
          'Garis lurus tenun lurik melambangkan filosofi blakasuta (kejujuran apa adanya), gotong royong tanpa pamrih, dan ketahanan pangan masyarakat agraris.',
      etiquetteRules:
          'Busana harian yang lentur dipakai untuk bekerja di ladang, berdagang di pasar tradisional, maupun menghadiri rembug desa.',
      historicalSources:
          'Kajian Etnografi Pedesaan Jawa Tengah, Lembaga Kebudayaan Jawa.',
      dominantColors: [Color(0xFF2B2621), Color(0xFFA6937C), Color(0xFF302015)],
    ),
  ];

  // ===========================================================================
  // 6. RAGAM MOTIF BATIK TRADISIONAL (PHILOSOPHY DATABASE)
  // ===========================================================================
  static const List<BatikMotif> batikMotifs = [
    BatikMotif(
      id: 'motif_parang_barong',
      name: 'Parang Barong',
      javaneseScript: 'ꦥꦫꦁꦧꦫꦺꦴꦁ',
      category: 'Parang / Lereng',
      meaning:
          'Berasal dari kata "pereng" (tebing karang) dan "barong" (besar/singa). Melambangkan keteguhan watak pemimpin laksana tebing kokoh yang diterpa ombak samudra, pantang menyerah menegakkan keadilan.',
      historicalUsage:
          'Motif Larangan Keraton (Batik Awisan Dalem) tingkat tertinggi. Dahulu hanya boleh dipakai oleh Sunan/Sultan dan putra mahkota pada upacara agung.',
      primaryTone: Color(0xFF4A3222),
      isLarangan: true,
    ),
    BatikMotif(
      id: 'motif_kawung',
      name: 'Kawung Picis',
      javaneseScript: 'ꦏꦮꦸꦁ',
      category: 'Geometris Bundar',
      meaning:
          'Empat lingkaran elips yang bersatu di satu poros melambangkan empat penjuru mata angin dan pancer spiritual (Sedulur Papat Limo Pancer). Menyimbolkan hati yang tulus bersih dan pengendalian hawa nafsu.',
      historicalUsage:
          'Boleh dikenakan oleh kalangan ningrat, priyayi, maupun abdi dalem yang berhati bersih.',
      primaryTone: Color(0xFF3D2717),
      isLarangan: false,
    ),
    BatikMotif(
      id: 'motif_sidomukti',
      name: 'Sidomukti',
      javaneseScript: 'ꦱꦶꦢꦺꦴꦩꦸꦏ꧀ꦠꦶ',
      category: 'Semen / Gurda',
      meaning:
          'Harapan agar senantiasa menjadi mukti (mulia, bahagia, berkecukupan rezeki) dalam naungan Sang Pencipta.',
      historicalUsage:
          'Wajib dikenakan kedua mempelai pengantin gaya Solo pada saat prosesi ijab kabul dan panggih.',
      primaryTone: Color(0xFF5A3E26),
      isLarangan: false,
    ),
    BatikMotif(
      id: 'motif_truntum',
      name: 'Truntum Sri Katon',
      javaneseScript: 'ꦠꦿꦸꦤ꧀ꦠꦸꦩ꧀',
      category: 'Ceplok Bintang',
      meaning:
          'Cinta kasih yang bersemi kembali (tumaruntum). Memberi teladan kasih sayang tulus yang tak pernah padam bagi generasi penerus.',
      historicalUsage:
          'Dikenakan oleh orang tua pengantin pada upacara pernikahan untuk memberi doa restu dan menuntun langkah sang anak.',
      primaryTone: Color(0xFF2E1F14),
      isLarangan: false,
    ),
    BatikMotif(
      id: 'motif_sidoasih',
      name: 'Sidoasih',
      javaneseScript: 'ꦱꦶꦢꦺꦴꦲꦱꦶꦃ',
      category: 'Semen Semarak',
      meaning:
          'Doa agar kedua insan saling mengasihi, mencintai, dan memelihara keharmonisan rumah tangga hingga usia senja.',
      historicalUsage:
          'Dikenakan saat malam siraman dan midodareni menjelang hari pernikahan adat Jawa.',
      primaryTone: Color(0xFF452B19),
      isLarangan: false,
    ),
  ];

  // ===========================================================================
  // 7. TANTANGAN EDUKASI & KUIS BUSANA ("SINAU BUSANA")
  // ===========================================================================
  static const List<FashionQuizItem> fashionQuizzes = [
    FashionQuizItem(
      id: 'quiz_1',
      question:
          'Mengapa kancing pada busana Surjan di bagian leher berjumlah dua dan di bagian dada berjumlah enam?',
      javaneseScript: 'ꦱꦸꦂꦗꦤ꧀ꦫꦸꦏꦸꦤ꧀ꦲꦶꦩꦤ꧀',
      options: [
        'Hanya ornamen simetri penjahit keraton',
        '2 kancing melambangkan Kalimah Syahadat, dan 6 kancing melambangkan Rukun Iman',
        'Menandakan usia pembuat surjan di masa Mataram',
        'Melambangkan delapan penjuru mata angin',
      ],
      correctOptionIndex: 1,
      historicalExplanation:
          'Diciptakan pada masa Kesultanan Mataram Islam oleh Sunan Kalijaga/Sultan Agung, struktur kancing surjan sarat nilai dakwah tauhid: 2 kancing di leher adalah Dua Kalimah Syahadat, dan 6 kancing di dada mewakili 6 Rukun Iman.',
      category: 'Filosofi Surjan',
    ),
    FashionQuizItem(
      id: 'quiz_2',
      question:
          'Apa perbedaan utama antara Blangkon gaya Surakarta (Solo) dan gaya Yogyakarta di bagian belakangnya?',
      javaneseScript: 'ꦥꦿꦧꦺꦢꦤ꧀ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀',
      options: [
        'Gaya Solo memakai kuncir kuda, gaya Yogya tanpa kain',
        'Gaya Solo bagian belakangnya trepes (datar), sedangkan gaya Yogya memiliki mondholan membulat',
        'Gaya Solo selalu berwarna putih, sedangkan Yogya selalu hitam',
        'Gaya Solo tidak menggunakan kain batik',
      ],
      correctOptionIndex: 1,
      historicalExplanation:
          'Gaya Surakarta berbentuk trepes (pipih rata di belakang) karena prajurit dan pria keraton Solo memotong rambut pendek sejak era Paku Buwono III, melambangkan keterbukaan. Sedangkan gaya Yogyakarta mempertahankan mondholan bulat wadah rambut panjang ksatria Mataram.',
      category: 'Blangkon & Iketan',
    ),
    FashionQuizItem(
      id: 'quiz_3',
      question:
          'Manakah di antara motif batik berikut yang pada masa Keraton Surakarta merupakan "Batik Awisan Dalem" (motif larangan) yang hanya boleh dikenakan raja dan pangeran utama?',
      javaneseScript: 'ꦩꦺꦴꦠꦶꦥ꦳꧀ꦭꦫꦔꦤ꧀ꦥꦫꦁ',
      options: [
        'Batik Buketan Pekalongan',
        'Batik Kawung Picis',
        'Batik Parang Barong',
        'Batik Truntum Sri Katon',
      ],
      correctOptionIndex: 2,
      historicalExplanation:
          'Batik Parang Barong dengan ukuran parang besar di atas 8 cm adalah motif larangan tertinggi (Awisan Dalem) di Keraton Kasunanan Surakarta dan Yogyakarta, melambangkan kekuatan spiritual dan hak kepemimpinan seorang raja.',
      category: 'Batik Larangan',
    ),
    FashionQuizItem(
      id: 'quiz_4',
      question:
          'Pada busana resmi Jawi Jangkep pria di Keraton Surakarta, mengapa warangka keris diselipkan di bagian belakang pinggang, bukan di depan?',
      javaneseScript: 'ꦥꦥꦤꦶꦁꦏꦼꦫꦶꦱ꧀ꦱꦺꦴꦭꦺꦴ',
      options: [
        'Agar tidak terlihat oleh musuh saat berperang',
        'Sebagai simbol bahwa senjata adalah benteng pengendali hawa nafsu dan kesantunan menghadap sesama',
        'Karena jas beskap tidak memiliki saku depan',
        'Hanya kebiasaan praktis saat naik kuda',
      ],
      correctOptionIndex: 1,
      historicalExplanation:
          'Keris di belakang melambangkan bahwa kekuatan senjata fisik bukanlah untuk ditonjolkan atau mengancam sesama, melainkan sebagai sipat kandel (penjaga marwah) dan pengendali hawa nafsu yang ditaruh di balik punggung.',
      category: 'Ricikan Keris Adat',
    ),
    FashionQuizItem(
      id: 'quiz_5',
      question:
          'Siapakah tokoh perempuan emansipasi asal Jepara yang mempopulerkan kebaya panjang bergaris leher V tanpa kutubaru?',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶꦗꦼꦥꦫ',
      options: [
        'Nyi Ageng Serang',
        'Ratu Kalinyamat',
        'Raden Ajeng Kartini',
        'Dewi Sartika',
      ],
      correctOptionIndex: 2,
      historicalExplanation:
          'Raden Ajeng Kartini mempopulerkan kebaya sutra panjang berbordir halus khas Jepara pada akhir abad ke-19. Potongannya yang anggun menutup pinggul dan berleher V kini abadi dikenal sebagai Kebaya Kartini.',
      category: 'Kebaya Pesisir',
    ),
  ];

  // Helper Pencarian
  static ClothingItem? getItemById(String id) {
    try {
      return [...headwearItems, ...upperBodyItems, ...lowerBodyItems, ...accessoryItems]
          .firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<ClothingItem> get clothingItems => [
        ...headwearItems,
        ...upperBodyItems,
        ...lowerBodyItems,
        ...accessoryItems,
      ];

  static List<ClothingItem> getItemsByCategory(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.headwear:
        return headwearItems;
      case ClothingCategory.upperBody:
        return upperBodyItems;
      case ClothingCategory.lowerBody:
        return lowerBodyItems;
      case ClothingCategory.accessories:
        return accessoryItems;
    }
  }
}

