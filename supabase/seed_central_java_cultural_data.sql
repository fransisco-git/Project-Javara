-- =============================================================================
-- JAVARA: CULTURAL HERITAGE DATABASE SEED SCRIPT
-- Central Javanese Traditional Clothing & Literature Records
-- File: supabase/seed_central_java_cultural_data.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SEED CULTURAL REGIONS
-- -----------------------------------------------------------------------------
INSERT INTO public.cultural_regions (id, name, sub_regions, javanese_script, description, latitude, longitude) VALUES
('surakarta', 'Surakarta Hadiningrat', 'Solo, Sukoharjo, Karanganyar, Klaten, Boyolali, Wonogiri, Sragen', 'ꦱꦸꦫꦏꦂꦠ', 'Pusat kebudayaan adiluhung Mataram Islam Kasunanan dan Pura Mangkunegaran dengan pakem busana keraton yang penuh kehalusan rasa dan wibawa.', -7.5666, 110.8284),
('yogyakarta', 'Yogyakarta Hadiningrat', 'Kraton Ngayogyakarta Hadiningrat & Pura Pakualaman', 'ꦔꦪꦺꦴꦒꦾꦏꦂꦠ', 'Pusat tradisi Kasultanan Mataram dengan ciri khas mondolan blangkon bulat penuh, kebaya tangkeban, dan pakem tata krama Mataram gagrak Ngayogyakarta.', -7.7956, 110.3695),
('banyumas', 'Banyumasan', 'Banyumas, Purwokerto, Cilacap, Purbalingga, Banjarnegara', 'ꦧꦚꦸꦩꦱ꧀', 'Wilayah budaya egaliter Lembah Serayu dengan kekhasan beskap Banyumasan tanpa kupingan, motif batik jahe serang, dan jiwa ksatria bawor.', -7.5147, 109.2944),
('pekalongan', 'Pesisir Pekalongan', 'Kota Pekalongan & Kabupaten Pekalongan', 'ꦥꦼꦏꦭꦺꦴꦔꦤ꧀', 'Kota Kreatif Dunia UNESCO untuk Batik dengan ciri warna-warni pesisiran cerah, motif buketan akulturasi Eropa, dan kebaya encim akulturasi Pecinan.', -6.8886, 109.6753),
('kudus', 'Kudus & Muria', 'Kudus Kulon, Kudus Wetan, Lereng Gunung Muria', 'ꦏꦸꦢꦸꦱ꧀', 'Kawasan pesisiran timur bernuansa santri saudagar dengan tradisi caping kalo anyaman bambu mikro, kebaya bordir janggan bordir icik, dan motif batik kapal kandas.', -6.8048, 110.8405),
('jepara', 'Jepara Pesisiran', 'Bumi Kartini, Kalinyamat, Karimunjawa', 'ꦗꦼꦥꦫ', 'Daerah pesisir maritim bersejarah tempat R.A. Kartini memperjuangkan emansipasi dengan kebaya panjang beludru belahan V berenda benang emas halus.', -6.5944, 110.6719),
('semarang', 'Semarang Pesisiran', 'Pesisir Semarang, Kota Lama, Pecinan Semarang', 'ꦱꦼꦩꦫꦁ', 'Ibukota Jawa Tengah dengan warisan kebaya encim pesisiran yang mencerminkan harmoni akulturasi budaya Jawa, Tionghoa, dan kolonial.', -6.9667, 110.4167)
ON CONFLICT (id) DO UPDATE SET
name = EXCLUDED.name, sub_regions = EXCLUDED.sub_regions, description = EXCLUDED.description;

-- -----------------------------------------------------------------------------
-- 2. SEED CULTURAL SOURCES
-- -----------------------------------------------------------------------------
INSERT INTO public.cultural_sources (id, title, author, period, institution, description, citation) VALUES
('serat_tatacara', 'Serat Tatacara Karaton Surakarta Hadiningrat', 'K.P.A. Kusumadilaga / Raden Mas Suwita', '1893 Masehi', 'Sasana Pustaka Keraton Surakarta Hadiningrat', 'Manuskrip pedoman tata laksana busana adat keraton, ricikan ageng, wiron jarik, dan paugeran upacara kenegaraan.', 'Kusumadilaga, K.P.A. (1893). Serat Tatacara. Surakarta: Sasana Pustaka.'),
('serat_centhini', 'Serat Centhini (Suluk Tambangraras)', 'K.G.P.A.A. Amangkunagara III / Raden Ngabehi Yasadipura II', '1814 Masehi', 'Pustaka Radya Pustaka Surakarta', 'Ensiklopedia kebudayaan terlengkap Jawa mengenai busana, tata rias manten, keris, wastra batik, dan filosofi kehidupan.', 'Amangkunagara III. (1814). Serat Centhini. Surakarta: Sasana Pustaka.'),
('babad_tanah_jawi', 'Babad Tanah Jawi', 'Carik Braja / Pujangga Kadipaten', 'Abad XVII-XVIII Masehi', 'Perpustakaan Nasional Republik Indonesia', 'Kronik sejarah peradaban wangsa Mataram dan perkembangan tata krama busana para adipati dan punggawa kraton.', 'Olthof, W.L. (1941). Babad Tanah Jawi. Gravenhage: M. Nijhoff.'),
('pawiyatan_paugeran', 'Paugeran Busana Adat Kasunanan Surakarta', 'Lembaga Dewan Adat & Pawiyatan Kabudayan', '2018 Edisi Revisi', 'Pawiyatan Kabudayan Karaton Surakarta', 'Pedoman baku pakem tata busana putra dan putri keraton masa kini yang disahkan oleh para sesepuh adat.', 'Dewan Adat Keraton. (2018). Paugeran Busana Adat Jawa. Surakarta.')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3. SEED CLOTHING CATEGORIES
-- -----------------------------------------------------------------------------
INSERT INTO public.clothing_categories (id, name, javanese_name, description, layer_order) VALUES
('headwear', 'Penutup Kepala', 'Iketan / Blangkon', 'Penutup dan tata rias kepala yang melambangkan pengikatan pikiran kotor dan ketundukan ego.', 1),
('upperBody', 'Busana Atasan', 'Rasukan / Ageman', 'Pakaian penutup badan atas seperti beskap, surjan, sikepan, dan kebaya.', 2),
('lowerBody', 'Busana Bawahan', 'Bebet / Jarik Samping', 'Kain wastra batik panjang yang dililitkan mengelilingi pinggul hingga pergelangan kaki.', 3),
('accessories', 'Ricikan & Aksesoris', 'Curiga & Perhiasan', 'Pusaka keris kelengkapan lambang pertahanan batin, sabuk lonthong kamus, epek, timang, dan bros susun.', 4)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4. SEED CLOTHING ITEMS
-- -----------------------------------------------------------------------------
INSERT INTO public.clothing_items (
    id, name, javanese_script, category_id, gender, region_id, period,
    social_context, material, philosophical_meaning, cutting_and_construction,
    texture_motif, compatibility_keys, color_palette, historical_notes,
    references, asset_image_path
) VALUES
(
    'blangkon_solo_cekok',
    'Blangkon Cekokan Kasunanan Trenggos',
    'ꦧꦭꦁꦏꦺꦴꦤ꧀ꦱꦺꦴꦭꦺꦴ',
    'headwear',
    'pria',
    'surakarta',
    'Abad XVIII s.d. Sekarang',
    'Keraton & Bangsawan / Priyayi',
    'Kain batik katun mori cap/tulis, karton tebal berlapis mori press kaku.',
    'Bentuk cekokan pipih di belakang mencerminkan keterbukaan budi pekerti masyarakat Solo yang halus dan tidak menyimpan prasangka tersembunyi.',
    'Konstruksi berbentuk topi oval pipih tanpa mondolan menonjol, wiru lipatan depan 17 lipit melambangkan rakaat shalat.',
    'Motif Batik Modang Sogan Cokelat Kemuning',
    ARRAY['solo_royal', 'solo_priyayi', 'solo_formal'],
    ARRAY['#3A2414', '#D4B06A', '#F2E8DC'],
    'Ditetapkan sebagai penutup kepala resmi pejabat Keraton Surakarta sejak masa Sinuhun Pakubuwana IX.',
    'Serat Tatacara Karaton Surakarta Hadiningrat Hal. 42',
    'assets/images/blangkon_solo.png'
),
(
    'blangkon_jogja_mondolan',
    'Blangkon Gagrak Ngayogyakarta Mondolan',
    'ꦧꦭꦁꦏꦺꦴꦤ꧀ꦔꦪꦺꦴꦒꦾ',
    'headwear',
    'pria',
    'yogyakarta',
    'Abad XVIII s.d. Sekarang',
    'Keraton & Priyayi Formal',
    'Kain batik katun sutra malam alam, bulatan mondolan berisi rambut cemara/sabut kelapa halus.',
    'Mondolan bulat menonjol di belakang melambangkan kemampuan seorang ksatria menyimpan rahasia pribadi dan aib sesama dengan rapat.',
    'Lipatan wiru simetris kanan kiri berjumlah ganjil, mondolan bulat sempurna padat di tengkuk.',
    'Motif Batik Nitik Sogan Putih Kraton',
    ARRAY['jogja_royal', 'jogja_priyayi', 'jogja_formal'],
    ARRAY['#2E1F16', '#FAF5EC', '#A67C52'],
    'Mulai berkembang semenjak Perjanjian Giyanti 1755 ketika Pangeran Mangkubumi menata adat Ngayogyakarta.',
    'Babad Giyanti & Tata Rakitan Kasultanan Yogyakarta',
    'assets/images/blangkon_jogja.png'
),
(
    'beskap_langenharjan_solo',
    'Beskap Langenharjan Beludru Hitam',
    'ꦧꦼꦱ꧀ꦏꦥ꧀ꦭꦔꦼꦤ꧀ꦲꦂꦗꦤ꧀',
    'upperBody',
    'pria',
    'surakarta',
    'Tahun 1890 Masehi (Sri Susuhunan PB IX)',
    'Upacara Resmi & Resepsi Manten Ageng',
    'Kain beludru sutra belgia hitam legam pekat, kancing kuningan timbul lambang garuda/roset.',
    'Bagian depan yang terbuka memperlihatkan rompi putih dan dasi kupu melambangkan keterbukaan menerima kemajuan zaman tanpa meninggalkan akar tradisi.',
    'Potongan krah tegak shanghai dengan bukaan dada melengkung U, bagian pinggul belakang dipotong melengkung (kroakan) agar keris dapat diselipkan leluasa.',
    'Polos hitam pekat beludru halus dengan list pinggir benang sulam emas.',
    ARRAY['solo_royal', 'solo_langenharjan'],
    ARRAY['#14100D', '#DFB76C', '#FFFFFF'],
    'Diciptakan di Pesanggrahan Langenharja di tepi Bengawan Solo sebagai perpaduan busana adat dan jas malam Eropa.',
    'Serat Tatacara PB IX, Sasana Pustaka Surakarta',
    'assets/images/beskap_langenharjan.png'
),
(
    'surjan_lurik_klasik',
    'Surjan Lurik Prasojo Kerah Shanghai',
    'ꦱꦸꦂꦗꦤ꧀ꦭꦸꦫꦶꦏ꧀',
    'upperBody',
    'pria',
    'surakarta',
    'Zaman Kasultanan Demak & Pajang',
    'Busana Keseharian Rakyat & Abdi Dalem',
    'Kain tenun katun serat alam lurik garis vertikal warna gelap cokelat-biru nila.',
    'Garis vertikal melambangkan hubungan lurus vertikal hamba dengan Tuhan Semesta Alam (Habluminallah).',
    'Kancing depan ganjil dipasang miring dengan 6 kancing di dada melambangkan rukun iman.',
    'Tenun Lurik Garis Hujan Gerimis Cokelat-Nila',
    ARRAY['rakyat_lurik', 'abdi_dalem', 'universal_jawa'],
    ARRAY['#281E19', '#3D4A54', '#8C7462'],
    'Dipopulerkan oleh Sunan Kalijaga sebagai pakaian dakwah yang merakyat dan bersahaja.',
    'Serat Centhini Pupuh 12, Hal. 108',
    'assets/images/surjan_lurik.png'
),
(
    'kebaya_kartini_beludru',
    'Kebaya Panjang Beludru Hitam Kartinian',
    'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶ',
    'upperBody',
    'wanita',
    'jepara',
    'Abad XIX Masehi',
    'Priyayi Formal & Bangsawan Putri',
    'Kain beludru prada sutra dengan sulaman manik bordir benang emas di sekeliling belahan leher.',
    'Potongan kebaya panjang yang menutup hingga paha mencerminkan kehormatan, keibuan, dan keteguhan iman putri Jawa.',
    'Siluet pas badan (fitted) dengan belahan dada leher V yang disambung bef kecil dan dikunci bros susun.',
    'Beludru polos dengan lis sulaman emas bermotif daun pakis dan sulur bunga.',
    ARRAY['kartini_royal', 'solo_putri', 'jepara_formal'],
    ARRAY['#18120F', '#E4C590', '#9E2A2B'],
    'Menjadi busana identitas R.A. Kartini dalam berbagai perjamuan resmi di Jepara.',
    'Surat-Surat R.A. Kartini (Habis Gelap Terbitlah Terang)',
    'assets/images/model_kebaya_kartini_solo.jpg'
),
(
    'jarik_parang_barong',
    'Jarik Parang Barong Babon Sogan',
    'ꦥꦫꦁꦧꦫꦺꦴꦁ',
    'lowerBody',
    'pria',
    'surakarta',
    'Masa Sultan Agung Hanyakrakusuma',
    'Motif Larangan Keraton (Raja & Pangeran Adipati)',
    'Mori primissima katun sutra malam tawon alami dengan pewarnaan soga jambal, tegeran, dan tingi.',
    'Parang Barong berukuran di atas 10 cm menggambarkan ombak samudra dahsyat yang melambangkan kekuasaan, keperkasaan, dan pengendalian hawa nafsu seorang pemimpin.',
    'Wiron lipatan 7 tumpuk diatur simetris dengan jarak 2.5 cm berbaris miring dari kanan atas ke kiri bawah.',
    'Motif lereng parang berdiagonal 45 derajat berpadu ornamen mlinjon.',
    ARRAY['solo_royal', 'raja_pangeran'],
    ARRAY['#24150D', '#8C5627', '#EBD8B8'],
    'Motif parang paling agung yang hanya boleh dikenakan raja pada saat pisowanan agung di Sasana Sewaka.',
    'Pranatan Dalem Bab Jenising Pola Batik Karaton Surakarta 1927',
    'assets/images/jarik_parang_barong.png'
),
(
    'keris_gayaman_solo',
    'Keris Ladrang Gayaman Solo Warangka Timoho',
    'ꦏꦼꦫꦶꦱ꧀ꦒꦪꦩꦤ꧀',
    'accessories',
    'pria',
    'surakarta',
    'Abad XVII s.d. Sekarang',
    'Perlengkapan Pokok Ksatria & Busana Resmi',
    'Bilah besi wasi aji pamor beras wutah, warangka kayu timoho pelet kendit, pendok bunton tatah kuningan sepuh mas.',
    'Curiga manjing warangka melambangkan manunggaling kawula gusti (persatuan raga dan sukma) serta pengekangan diri dari amarah angkara murka.',
    'Diselipkan di pinggang belakang di antara ikatan epek dan timang membentuk sudut 45 derajat ke arah kanan.',
    'Pamor beras wutah perak menyala di atas bilah hitam meteorit keleng.',
    ARRAY['solo_royal', 'solo_priyayi', 'solo_formal'],
    ARRAY['#734A26', '#E4C590', '#2C2B2A'],
    'Menjadi kelengkapan mutlak bagi pria dalam adat Jawa, pria tanpa keris dianggap belum sempurna busananya.',
    'Serat Paniti Kadang Karaton Surakarta Hadiningrat',
    'assets/images/keris_solo.png'
)
ON CONFLICT (id) DO UPDATE SET
name = EXCLUDED.name, material = EXCLUDED.material, philosophical_meaning = EXCLUDED.philosophical_meaning;

-- -----------------------------------------------------------------------------
-- 5. SEED OUTFIT PRESETS
-- -----------------------------------------------------------------------------
INSERT INTO public.outfit_presets (
    id, title, javanese_script, collection_category, gender, region_id, era,
    headwear_id, upperBody_id, lowerBody_id, accessory_ids, summary,
    cultural_philosophy, etiquette_rules, historical_sources, dominant_colors
) VALUES
(
    'outfit_jawi_jangkep_solo',
    'Busana Jawi Jangkep Kasunanan',
    'ꦧꦸꦱꦤꦗꦮꦶꦗꦁꦏꦼꦥ꧀ꦱꦸꦫꦏꦂꦠ',
    'Keraton & Bangsawan',
    'pria',
    'surakarta',
    'Abad XVIII Masehi - Era Pakubuwono III s.d. Sekarang',
    'blangkon_solo_cekok',
    'beskap_langenharjan_solo',
    'jarik_parang_barong',
    ARRAY['keris_gayaman_solo'],
    'Setelan ksatria paling lengkap dan agung bagi pria bangsawan Surakarta yang memadukan wibawa beskap beludru, blangkon cekok trenggos, jarik parang, dan curiga ladrang.',
    'Melambangkan kesiapan seorang pria Jawa mengemban tanggung jawab keluarga, masyarakat, dan negara dengan jiwa ksatria yang teguh dan santun.',
    'Hanya boleh dikenakan dengan selop tertutup; keris wajib diselipkan di pinggang kanan belakang; pantang mengangkat kaki saat duduk di hadapan tetua.',
    'Serat Tatacara Karaton Surakarta & Pawiyatan Kabudayan Karaton',
    ARRAY['#14100D', '#DFB76C', '#8C5627']
),
(
    'outfit_kebaya_kartini_solo',
    'Kebaya Kartini Beludru Jepara-Solo',
    'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶꦗꦼꦥꦫ',
    'Priyayi Formal',
    'wanita',
    'jepara',
    'Abad XIX Masehi - Era R.A. Kartini',
    NULL,
    'kebaya_kartini_beludru',
    'jarik_parang_barong',
    ARRAY['keris_gayaman_solo'],
    'Setelan kebesaran wanita priyayi bangsawan Jawa Tengah yang memadukan keanggunan kebaya panjang beludru belahan V dengan wiron jarik halus sogan dan sanggul tekuk melati.',
    'Melambangkan kecerdasan, ketenangan batin, kelembutan tutur kata, dan kemandirian wanita Jawa yang mampu memancarkan pesona dari dalam jiwa.',
    'Kancing bros susun tiga melambangkan tri murti; selendang disampirkan anggun di pundak kiri; langkah kaki teratur tidak tergesa-gesa.',
    'Catatan Museum Kartini Jepara & Serat Pawiyatan Putri Surakarta',
    ARRAY['#18120F', '#E4C590', '#24150D']
)
ON CONFLICT (id) DO UPDATE SET
title = EXCLUDED.title, summary = EXCLUDED.summary, cultural_philosophy = EXCLUDED.cultural_philosophy;

-- -----------------------------------------------------------------------------
-- 6. SEED AVATARS (Realistic Models)
-- -----------------------------------------------------------------------------
INSERT INTO public.avatars (id, title, subtitle, gender, region_id, image_asset, tags, is_active) VALUES
('model_jawi_jangkep_solo', 'Busana Jawi Jangkep Kasunanan', 'Pakem Ksatria & Bangsawan Keraton Surakarta Hadiningrat', 'pria', 'surakarta', 'assets/images/model_jawi_jangkep_solo.jpg', ARRAY['Solo', 'Kasunanan', 'Ksatria', 'Beskap', 'Keris'], true),
('model_kebaya_kartini_solo', 'Kebaya Kartini Beludru Jepara', 'Keanggunan Putri Bangsawan & Warisan Emansipasi Jawa Tengah', 'wanita', 'jepara', 'assets/images/model_kebaya_kartini_solo.jpg', ARRAY['Jepara', 'Kartini', 'Kebaya Beludru', 'Batik Sogan', 'Putri'], true),
('model_surjan_lurik_prasojo', 'Surjan Lurik Prasojo Mataraman', 'Busana Keseharian Rakyat Bersahaja & Abdi Dalem Kasunanan', 'pria', 'surakarta', 'assets/images/model_surjan_lurik.jpg', ARRAY['Lurik', 'Surjan', 'Prasojo', 'Rakyat', 'Tenun'], true)
ON CONFLICT (id) DO UPDATE SET
title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, image_asset = EXCLUDED.image_asset;

