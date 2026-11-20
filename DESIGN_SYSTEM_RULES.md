# JAVARA Design System & Architectural Rules

> Official design system rules and Figma MCP integration architecture for **JAVARA: Cultural Fashion Platform for Central Javanese Heritage**.

---

## 1. Token Definitions

### Color Tokens (`lib/core/theme.dart` -> `JColors`)
* **Obsidian Core (Dark Shell & Studio)**:
  - `obsidianBase`: `#07040B` (Latar malam mistis candi Borobudur & studio)
  - `obsidianElevated`: `#120A16` (Surface kartu melayang di atas obsidian)
  - `obsidianGlass`: `Color(0xCC1A120D)` (Permukaan kaca tembus pandang)
* **Royal Gold Palette (Prada Kencana & Aksen Adiluhung)**:
  - `antiqueGold`: `#B08D57` / `#DFB76C` (Aksen utama, garis pembatas, outline)
  - `goldLight`: `#FFDF9E` / `#FFE8B3` (Teks judul berkilau & halo glow)
  - `goldDeep`: `#C89948` (Gradasi tombol CTA ksatria)
* **Heritage Earth & Parchment**:
  - `warmIvory`: `#F5F0E8` (Latar terang editorial naskah kuno)
  - `deepJavaBrown`: `#30251F` (Kayu jati ukir & beludru kasunanan)
  - `softSand`: `#E8DED0` (Pembatas & kartu sekunder)
  - `parchmentBase`: `#F4E9D8` (Lembar paspor perkamen kuno)
  - `ink`: `#2B1A12` (Tinta cina naskah lontar)
  - `terracotta`: `#B5603A` / `#A8664F` (Bata merah candi & gerabah Kasongan)
* **Functional States**:
  - `success`: `#3F6B3A` / `#58D68D` (State jawaban kuis benar & match try-on)
  - `error`: `#B3261E` / `#FF7A66` (Batik larangan & kesalahan input)

### Typography Tokens (`lib/core/theme.dart` -> `JText`)
1. **Editorial Serif (`GoogleFonts.cormorantGaramond`)**:
   - Judul layar utama, nama busana kebesaran, falsafah luhur.
2. **Interface Sans (`GoogleFonts.inter`)**:
   - Label navigasi, tombol CTA, indikator tab, chip kategori, timer.
3. **Cultural Narrative Serif (`GoogleFonts.lora`)**:
   - Deskripsi sejarah, cerita busana, soal kuis, makna filosofis 5 pakem.
4. **Javanese Traditional Script (`Aksara Jawa`)**:
   - `ꦗ ꦮ ꦫ` (Javara), `ꦱꦸꦫꦏꦂꦠ` (Surakarta), `ꦩꦒꦼꦭꦁ` (Magelang).

---

## 2. Component Library (`lib/widgets/javara_widgets.dart` & feature modules)

* **`JavaraLogo`**: Lambang bulat resmi "JAVARA · Warisane Jowo" dengan fallback semantik SVG/Canvas.
* **`JavaraBottomNav`**: Navigasi bawah 5 tab (*Beranda, Jelajah, Studio [Elevated Gold Capsule], Sinau, Paspor*).
* **`JavaraGoldButton`**: Tombol aksi ksatria dengan gradasi emas, elevasi halus, dan haptic feedback.
* **`JavaraGlassCard`**: Kartu permukaan kaca obsidian dengan border emas 0.8px dan blur volumetrik.
* **`WipeSlider`**: Bilah pembanding Sebelum/Sesudah (Interactive Wipe Slider) dengan handle geser Prada Gold.
* **`SilhouetteGuide`**: Garis putus-putus siluet postur tubuh untuk panduan kamera On-Cam.
* **`PassportStampCard`**: Lencana stempel cagar budaya Jawa Tengah dengan status terkumpul / terkunci.

---

## 3. Frameworks & Libraries
* **UI Framework**: Flutter 3.13.5+ (Material 3 enabled, dark/light theme).
* **Typography**: `google_fonts: ^6.2.1` (Cormorant Garamond, Inter, Lora).
* **Hardware & Sensor**:
  - `camera: ^0.12.2` (On-Cam pose detection & live try-on preview)
  - `image_picker: ^1.2.4` (Foto dari galeri)
  - `flutter_map: ^8.3.2` & `latlong2: ^0.10.1` (Peta interaktif Jawa Tengah)
  - `audioplayers: ^6.8.1` (Gamelan suci, genta Borobudur & musik tradisi)
  - `webview_flutter: ^4.10.0` (Turntable 3D WebGL Three.js)

---

## 4. Asset Management
* Lokasi aset utama: `assets/images/`
* Format: PNG dengan transparansi untuk logo & tangan mudra; WebP/JPEG 85% untuk render sinematik 3D candi & model busana.
* Penamaan aset:
  - `candi_3d_cinema.jpg`: Latar Candi Borobudur sinematik
  - `buddha_hand_left.png` & `buddha_hand_right.png`: Sepasang tangan Buddha Mudra
  - `model_solo_basahan_bride.jpg`: Busana Dodot Kemben Prada Pengantin
  - `model_jawi_jangkep_solo.jpg`: Busana Pria Beskap Sikepan Kasunanan
  - `model_kebaya_kartini_solo.jpg`: Busana Kebaya Kartini Sutra
  - `model_surjan_pranakan_solo.jpg`: Busana Surjan Lurik Pranakan Kasunanan

---

## 5. Icon System
* Menggabungkan `Icons` Material Symbols Rounded (mis. `Icons.camera_alt_rounded`, `Icons.checkroom_rounded`, `Icons.view_in_ar_rounded`).
* Simbol budaya kustom via Unicode & CustomPaint (Mandala, Surya Akasa, Bintang Prabha 8 Penjuru).

---

## 6. Styling Approach
* Strict **Anti-Slop** Policy:
  - Dilarang menggunakan layout e-commerce generik (tidak ada "Add to Cart", "Flash Sale", atau diskon).
  - Skema warna wajib berpijak pada nilai filosofis kraton Mataram & candi andesit.
  - Setiap layout diuji pada berbagai resolusi (300px s/d 540px) untuk memastikan **nol overflow**.

---

## 7. Project Structure
```text
lib/
├── core/
│   ├── theme.dart           # Master Design Tokens (JColors, JText, Theme)
│   ├── transitions.dart     # Transisi halaman sinematik (fadeSlideRoute)
│   └── validators.dart      # Validasi form autentikasi
├── features/
│   ├── splash/              # SplashScreen sinematik & mandala
│   ├── welcome/             # WelcomeScreen & carousel pengenalan
│   ├── auth/                # Login, Register, Lupa Password
│   ├── home/                # Beranda, Parallax Borobudur 3D, Tangan Mudra
│   ├── explore/             # Peta Budaya Interaktif Jateng & Daerah
│   ├── fashion/             # JAVARA Studio On-Cam, Try-On, 5 Pakem Busana
│   └── heritage/            # Paspor Budaya & Sinau Kuis
└── widgets/
    ├── javara_widgets.dart  # Komponen UI utama (Logo, Button, Nav, Card)
    └── heritage_background.dart # Latar gradasi dinamis
```
