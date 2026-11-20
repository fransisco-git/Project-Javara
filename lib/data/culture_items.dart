/// Model Warisan Budaya dan Kriya Kuliner Khas Jawa Tengah.
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
    this.category = 'Budaya',
  });

  final String id;
  final String title;
  final String meta; // mis. "Situs Sejarah · Magelang, Jateng"
  final String tag; // mis. "WARISAN DUNIA UNESCO"
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
    id: 'candi_borobudur',
    title: 'Candi Borobudur',
    meta: 'Situs Bersejarah · Magelang, Jateng',
    price: 'Tiket Wisata',
    actionLabel: 'Jelajah',
    image: 'candi_3d_hero.jpg',
    tag: 'WARISAN DUNIA UNESCO',
    category: 'Candi & Purbakala',
    regency: 'Kabupaten Magelang',
    location: 'Jl. Badrawati, Kw. Candi Borobudur, Borobudur, Magelang',
    description: 'Candi Borobudur adalah monumen candi Buddha Mahayana terbesar di dunia yang didirikan pada abad ke-8 Masehi oleh Dinasti Syailendra. Bangunan megah ini tersusun dari 2 juta balok batu andesit alami tanpa perekat semen, memuat 2.672 panel relief naratif serta 504 arca Buddha yang mengabadikan kosmologi Kamadhatu, Rupadhatu, dan Arupadhatu.',
    history: 'Didirikan sekitar tahun 780-840 M pada masa pemerintahan Raja Samaratungga dari Wangsa Syailendra. Sempat tertimbun abu vulkanik Gunung Merapi dan vegetasi liar selama ratusan tahun sebelum ditemukan kembali oleh Sir Thomas Stamford Raffles pada tahun 1814.',
    highlights: [
      '2.672 panel relief pahatan batu andesit terlengkap di dunia',
      '72 stupa berterawang mengelilingi stupa induk puncak',
      'Filosofi tingkatan spiritual Kamadhatu, Rupadhatu, dan Arupadhatu',
      'Orientasi poros kosmik simetris sejajar Candi Mendut dan Pawon',
    ],
  ),
  CultureItem(
    id: 'batik_tulis_solo',
    title: 'Batik Tulis Solo',
    meta: 'Busana Tradisi · Surakarta, Jateng',
    price: 'Rp350.000',
    actionLabel: 'Pesan Karya',
    image: 'batik.png',
    tag: 'ADILUHUNG KERATON',
    category: 'Batik Tradisi',
    regency: 'Kota Surakarta',
    location: 'Kampung Batik Laweyan & Kauman, Surakarta',
    description: 'Batik Tulis Surakarta memiliki ciri khas warna soga cokelat alami yang hangat dan berwibawa, berpadu dengan dasar putih kekuningan. Dibuat manual menggunakan canting tembaga dan malam panas oleh para mpu pembatik, setiap helai kain mengandung filosofi luhur seperti motif Parang Rusak Barong, Sidomukti, dan Truntum.',
    history: 'Tradisi membatik di Solo berkembang pesat seiring berdirinya Keraton Kasunanan Surakarta pada abad ke-18. Kampung Laweyan menjadi salah satu sentra industri batik tertua di Nusantara yang mencatatkan sejarah pergerakan ekonomi rakyat.',
    highlights: [
      'Pewarnaan soga alam dari kulit kayu pohon tingi, jambal, dan tegeran',
      'Motif larangan keraton seperti Parang Barong khusus raja dan pangeran',
      'Proses pengerjaan halus memakan waktu 1 hingga 3 bulan per helai',
      'Teknik mbabar tradisi dengan ketelitian kontur garis isen-isen',
    ],
  ),
  CultureItem(
    id: 'wayang_kulit_solo',
    title: 'Wayang Kulit Surakarta',
    meta: 'Seni Pertunjukan · Solo, Jateng',
    price: 'Jadwal Pagelaran',
    actionLabel: 'Lihat Lakon',
    image: 'wayang.png',
    tag: 'MAHAKARYA LISAN UNESCO',
    category: 'Seni Pertunjukan',
    regency: 'Kota Surakarta',
    location: 'Taman Budaya Jawa Tengah (TBJT) & Sriwedari, Solo',
    description: 'Wayang Kulit purwa gaya Surakarta terkenal dengan proporsi tatahan yang luwes, pewarnaan prada emas yang anggun, dan iringan gamelan berlaras laras slendro-pelog. Dalang membawakan wiracarita Mahabarata dan Ramayana yang sarat ajaran filsafat hidup, etika kepemimpinan, dan spiritualitas Jawa.',
    history: 'Wayang kulit telah berurat akar sejak zaman Kerajaan Kahuripan dan Kediri, kemudian disempurnakan oleh Walisongo pada masa Kesultanan Demak agar selaras dengan dakwah kebajikan, hingga mencapai puncak kehalusan visual pada era Keraton Surakarta.',
    highlights: [
      'Kulit kerbau pilihan yang ditatah dengan presisi jarum besi mpu kriya',
      'Pewarnaan serbuk emas prada asli untuk tokoh ksatria dan dewa',
      'Iringan sindhen dan nayaga gamelan sepanjang malam (semalam suntuk)',
      'Falsafah moral adiluhung mengenai kemenangan dharma atas adharma',
    ],
  ),
  CultureItem(
    id: 'ukiran_kayu_jepara',
    title: 'Ukiran Kayu Jepara',
    meta: 'Kriya & Mebel · Jepara, Jateng',
    price: 'Rp1.200.000',
    actionLabel: 'Lihat Karya',
    image: 'keranjang.png',
    tag: 'KRIYA PUSAKA DUNIA',
    category: 'Kriya Kayu',
    regency: 'Kabupaten Jepara',
    location: 'Desa Tahunan, Mulyoharjo, & Sukodono, Jepara',
    description: 'Seni ukir Jepara menonjolkan motif sulur tanaman yang melengkung dinamis, jumbai daun menjalar bebas, dan buah-buah kecil di ujung ranting. Menggunakan kayu jati TPK perhutani yang telah diawetkan, seni kriya ini menghiasi gebyok rumah joglo, mimbar, meja, hingga karya seni kontemporer bertaraf ekspor dunia.',
    history: 'Keahlian ukir Jepara diyakini berakar dari era Ratu Kalinyamat pada abad ke-16. Putri bangsawan RA Kartini kemudian turut mempromosikan kerajinan ukir Jepara ke kancah internasional pada akhir abad ke-19.',
    highlights: [
      'Kayu jati solid berumur tua dengan serat alami yang kuat',
      'Kedalaman pahatan 3 dimensi dengan relief berundak halus',
      'Sentra ukir relief Senenan dan patung Mulyoharjo',
      'Finishing natural melamin dan wax tradisional tanpa merusak urat kayu',
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
