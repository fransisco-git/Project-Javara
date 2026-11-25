/// Model Warisan Budaya dan Kriya Wastra Busana Adat Jawa Tengah.
class CultureItem {
  const CultureItem({
    required this.id,
    required this.title,
    required this.meta,
    required this.image,
    this.tag = '',
    this.price,
    this.actionLabel = 'Lihat',
    this.description = '',
    this.history = '',
    this.location = 'Jawa Tengah',
    this.regency = '',
    this.highlights = const [],
    this.category = 'Busana Tradisi',
  });

  final String id;
  final String title;
  final String meta; // mis. "Busana Keraton · Surakarta, Jateng"
  final String tag; // mis. "ADILUHUNG KERATON"
  final String? price; // null => pakai actionLabel
  final String actionLabel;
  final String image; // nama file di assets/images/
  final String description;
  final String history;
  final String location;
  final String regency;
  final List<String> highlights;
  final String category;
}

const popularItems = <CultureItem>[
  CultureItem(
    id: 'beskap_jawi_jangkep_solo',
    title: 'Beskap Jawi Jangkep',
    meta: 'Busana Resmi Pria · Surakarta, Jateng',
    price: 'Rp485.000',
    actionLabel: 'Sewa / Beli',
    image: 'model_surjan_pranakan_solo.jpg',
    tag: 'AGUNG KASUNANAN',
    category: 'Busana Tradisi',
    regency: 'Kota Surakarta',
    location: 'Keraton Kasunanan & Baluwarti, Surakarta',
    description: 'Beskap Jawi Jangkep adalah busana adat pria resmi warisan Keraton Kasunanan Surakarta. Terbuat dari bahan beludru atau wol berkualitas dengan potongan leher tegak, kancing asimetris melengkung, serta lekukan bagian belakang yang dirancang khusus untuk menyematkan Keris pusaka ladrang.',
    history: 'Disempurnakan pada masa Sri Susuhunan Pakubuwana IX dan X sebagai pakaian kehormatan para bangsawan dan abdi dalem saat pisowanan agung di Sasana Sewaka.',
    highlights: [
      'Potongan belakang berlekuk presisi untuk menyelipkan Keris Ladrang',
      'Kain jarik motif Parang Barong atau Sidomukti berwiru halus',
      'Dilengkapi sabuk cinde, epek timang kuningan berprada emas',
      'Kelengkapan blangkon gaya Solo dengan mondolan cepak khas Surakarta',
    ],
  ),
  CultureItem(
    id: 'busana_pengantin_solo_basahan',
    title: 'Solo Basahan Pengantin',
    meta: 'Busana Pengantin Adat · Surakarta, Jateng',
    price: 'Rp1.250.000',
    actionLabel: 'Sewa Busana',
    image: 'solo_basahan_couple.jpg',
    tag: 'BUSANA ADAT ADILUHUNG',
    category: 'Busana Tradisi',
    regency: 'Kota Surakarta',
    location: 'Sentra Busana Adat Laweyan, Surakarta',
    description: 'Solo Basahan merupakan tata busana pengantin tradisional Jawa Tengah dengan filosofi penyatuan spiritual tertinggi. Mengenakan dodot/kampuh batik alas-alasan berprada emas, dipadukan dengan cunduk mentul kencana dan paes hitam kehijauan yang melambangkan keanggunan permaisuri.',
    history: 'Awalnya merupakan busana pengantin khusus keluarga raja Keraton Mataram Islam dan Kasunanan Surakarta, sebelum akhirnya diizinkan dikenakan oleh masyarakat umum sebagai busana raja sehari dalam upacara pernikahan.',
    highlights: [
      'Kain dodot/kampuh panjang 4 meter bermotif Alas-Alasan prada emas',
      'Perhiasan kalung ulur, kelat bahu naga, dan gelang canthing kencana',
      'Riasan paes kambil tipis dengan cunduk mentul kembang goyang 9 tangkai',
      'Kain jarik semen rante yang melambangkan ikatan cinta seumur hidup',
    ],
  ),
  CultureItem(
    id: 'batik_tulis_solo',
    title: 'Batik Tulis Parang Barong',
    meta: 'Wastra Keraton · Surakarta, Jateng',
    price: 'Rp375.000',
    actionLabel: 'Pesan Wastra',
    image: 'batik.png',
    tag: 'MOTIF LARANGAN KERATON',
    category: 'Batik Tradisi',
    regency: 'Kota Surakarta',
    location: 'Kampung Batik Laweyan & Kauman, Surakarta',
    description: 'Batik Tulis Surakarta motif Parang Rusak Barong adalah mahakarya wastra Jawa dengan warna soga cokelat alami yang hangat dan berwibawa. Garis miring diagonal melambangkan ombak samudera dan tekad ksatria yang pantang menyerah dalam menegakkan kebajikan.',
    history: 'Diciptakan oleh Sultan Agung Hanyakrakusuma saat bertapa di pesisir Pantai Selatan. Pada era Kasunanan Surakarta, motif Parang Barong berukuran di atas 8 cm ditetapkan sebagai motif larangan (awisan dalem) yang hanya boleh dikenakan raja.',
    highlights: [
      'Pewarnaan soga alam dari ekstrak kayu tingi, jambal, dan tegeran',
      'Proses pengerjaan canting tulis tembaga memakan waktu hingga 3 bulan',
      'Filosofi kepemimpinan luhur berwatak ksatria berbudi bawa laksana',
      'Kain mori primissima halus dengan aroma malam lebah alami',
    ],
  ),
  CultureItem(
    id: 'kebaya_kartini_rembang',
    title: 'Kebaya Kartini',
    meta: 'Busana Tradisional Wanita · Rembang & Jepara',
    price: 'Rp325.000',
    actionLabel: 'Sewa / Beli',
    image: 'kebaya.png',
    tag: 'WARISAN EMAS PEREMPUAN',
    category: 'Busana Tradisi',
    regency: 'Kabupaten Rembang',
    location: 'Sentra Bordir & Kebaya Rembang - Jepara',
    description: 'Kebaya Kartini memiliki potongan panjang yang anggun menutupi panggul dengan lipatan kerah setali berbentuk V. Didesain bersahaja namun memancarkan wibawa keputrian Jawa yang cerdas, anggun, dan berpendidikan.',
    history: 'Diabadikan oleh pahlawan emansipasi wanita RA Kartini di Jepara dan Rembang pada akhir abad ke-19, menjadi simbol kebangkitan martabat wanita Nusantara.',
    highlights: [
      'Bahan katun voil halus dengan bordir kerancang manual bermotif bunga melati',
      'Potongan leher lipit V setali yang memberi kesan jenjang dan berwibawa',
      'Dipadukan dengan jarik batik sogan motif Parang Klithik atau Truntum',
      'Cocok untuk wisuda, resepsi resmi kenegaraan, dan upacara adat',
    ],
  ),
];

const pickedItems = <CultureItem>[
  CultureItem(
    id: 'kebaya_kutubaru_solo',
    title: 'Kebaya Kutubaru Klasik Solo',
    meta: 'Busana Tradisional · Surakarta, Jateng',
    tag: 'MAHAKARYA KERATON',
    price: 'Rp350.000',
    actionLabel: 'Pesan Busana',
    image: 'kebaya.png',
    category: 'Busana Tradisi',
    regency: 'Kota Surakarta',
    location: 'Laweyan & Kauman, Surakarta',
    description: 'Kebaya kutubaru adalah busana tradisional wanita Jawa klasik dengan bukaan depan bersiluet ramping dan bef (penutup dada tengah) yang anggun. Dilengkapi bordir benang emas dan dipadukan dengan jarik batik sogan keraton.',
    history: 'Dikenakan para putri keraton sejak era Mataram Islam dan dipopulerkan di Keraton Kasunanan Surakarta sebagai busana resmi pasowanan agung.',
    highlights: [
      'Bahan sutra brokat halus dengan furing katun adem',
      'Jahitan bordir tangan motif lung-lungan emas',
      'Sesuai pakem busana keraton Kasunanan Surakarta',
      'Pilihan sempurna untuk upacara adat dan pernikahan',
    ],
  ),
  CultureItem(
    id: 'batik_pekalongan',
    title: 'Batik Pesisir Pekalongan',
    meta: 'Busana & Wastra · Pekalongan, Jateng',
    tag: 'KOTA BATIK DUNIA UNESCO',
    price: 'Rp195.000',
    actionLabel: 'Pesan Wastra',
    image: 'batik.png',
    category: 'Batik Tradisi',
    regency: 'Kota Pekalongan',
    location: 'Kampung Batik Pesindon & Kauman, Pekalongan',
    description: 'Batik Pekalongan mencerminkan keterbukaan masyarakat pesisir utara Jawa Tengah. Kaya akan warna-warni cerah yang berani seperti merah koral, pirus, toska, dan jingga dengan motif buketan bunga Eropa, naga Tionghoa, dan burung merak yang atraktif.',
    history: 'Letak Pekalongan sebagai pelabuhan niaga strategis di Jalur Sutra maritim mempertemukan pengaruh budaya Tiongkok, Arab, Belanda, dan Jawa, melahirkan corak batik pesisiran yang sangat dinamis.',
    highlights: [
      'Motif Jlamprang yang khas peninggalan saudagar Gujarat',
      'Warna cerah ceria yang memikat generasi muda',
      'Pusat kerajinan di Pasar Grosir Setono & Museum Batik Pekalongan',
      'Diakui UNESCO sebagai City of Crafts and Folk Art',
    ],
  ),
  CultureItem(
    id: 'surjan_lurik_tradisi',
    title: 'Surjan Lurik Tradisional',
    meta: 'Busana Tradisional · Jawa Tengah',
    tag: 'BUSANA PRIA PRIYAYI',
    price: 'Rp285.000',
    actionLabel: 'Pesan Busana',
    image: 'kebaya.png',
    category: 'Busana Tradisi',
    regency: 'Kota Surakarta',
    location: 'Sentra Tenun Pedan Klaten & Solo',
    description: 'Surjan lurik adalah pakaian adat pria Jawa berlengan panjang dengan motif garis-garis sejajar khas tenun ATBM. Berkerah tegak dengan kancing berjumlah ganjil yang sarat makna keagamaan dan kepasrahan budi pekerti.',
    history: 'Diciptakan oleh Sunan Kalijaga pada abad ke-15 sebagai busana takwa yang mengajarkan kesederhanaan, pengendalian nafsu, dan kepatuhan syariat.',
    highlights: [
      'Kain tenun lurik asli alat tenun bukan mesin (ATBM)',
      'Kancing leher 3 pasang melambangkan rukun iman & Islam',
      'Bahan katun alami yang sejuk dan menyerap keringat',
      'Dapat dipadukan dengan celana modern maupun kain jarik',
    ],
  ),
];
