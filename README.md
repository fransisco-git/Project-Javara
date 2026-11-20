# Project Javara (Javara Mobile App)

Aplikasi eksplorasi budaya dan warisan luhur Jawa Tengah berbasis Flutter dengan pengalaman visual autentik, 3D Virtual Try-On Busana Adat Keraton, Peta Interaktif 35 Wilayah, Kuis Budaya, Paspor Digital, dan Sanggar Aksara Jawa.

---

## 🏛️ Fitur Utama

1. **Onboarding & Autentikasi Budaya**
   - Splash screen sogan keraton dan Welcome Screen eksklusif.
   - Autentikasi Email, Google Auth, Apple ID, serta alur Lupa Password dengan OTP 5 digit.

2. **Beranda & Penjelajahan Budaya**
   - Cerita budaya unggulan (Kuliner, Seni Pertunjukan, Tradisi).
   - Katalog Cinderamata Kriya & Keranjang Belanja Adat.

3. **Jelajah Jawa (35 Wilayah & Karesidenan)**
   - Peta interaktif 35 kabupaten/kota Jawa Tengah (Solo Raya, Kedu, Semarang Raya, Banyumasan, Pantura).
   - Riwayat sejarah, destinasi keraton, dan filosofi wilayah.

4. **Wardrobe & 3D Virtual Try-On Busana Adat**
   - Katalog busana adat pria & wanita (Kebaya Kartini Solo, Beskap Landhung, Solo Basahan, Surjan Lurik).
   - Fitur sewa busana adat dengan opsi durasi sewa harian/mingguan.
   - Studio Busana Virtual 3D Turntable 360° interaktif.

5. **Sinau Budaya & Sanggar Aksara Jawa**
   - Kuis Budaya 10 soal interaktif berumpan balik instan dan kotak wawasan *"Tahukah Kamu?"*.
   - Pembukaan Lencana Kehormatan (*Pujangga Sinau Jawa*) & Sertifikat Digital (PDF).
   - Sanggar Aksara Jawa: Transliterasi instan teks Latin ke Aksara Jawa Hanacaraka beserta filosofi 20 aksara legena.

6. **Profil Ksatria, Paspor Budaya & Swara Nusantara**
   - Profil pengguna dengan sistem level & prasasti XP.
   - Paspor Budaya Digital: Lembar perkamen kuno dengan segel lilin kerajaan (*wax seals*).
   - Swara Nusantara: Pemutar audio gamelan keraton (*Ladrang Wilujeng*) berpenampilan piringan hitam (*vinyl disc*).

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: Flutter 3.x / Dart 3.x
- **Backend / Database**: Supabase Flutter SDK
- **Styling & Theme**: Sogan Keraton Palette (`#F4E9D8`, `#3A261D`, `#C79B3A`), Typography (Lora Serif & Inter)
- **Navigation**: Curved Liquid Glass Bottom Navigation Bar
- **Audio & Media**: Java Music Service & Audio Players

---

## 🚀 Panduan Memulai untuk Tim Pengembang

### 1. Clone Repository
```bash
git clone https://github.com/<USERNAME>/Project-Javara.git
cd Project-Javara
```

### 2. Install Dependensi
Pastikan Flutter SDK sudah terpasang di komputer Anda:
```bash
flutter pub get
```

### 3. Konfigurasi Aset & Supabase
Periksa konfigurasi Supabase pada `lib/core/config/app_config.dart` atau file `.env` jika diperlukan.

### 4. Jalankan Aplikasi
```bash
flutter run
```

---

## 📁 Struktur Direktori

```text
lib/
├── core/               # Tema warna (JColors, JText), transisi, dan validator
├── data/               # Data dummy & katalog budaya lokal
├── features/
│   ├── auth/           # Login, Sign Up, Lupa Password & Verifikasi OTP
│   ├── explore/        # Peta 35 Wilayah, Detail Cerita, dan Kuis Budaya
│   ├── fashion/        # Wardrobe, Busana Adat, dan Studio 3D Try-On
│   ├── heritage/       # Paspor Budaya, Sanggar Aksara Jawa, Swara Nusantara
│   ├── home/           # Beranda Utama, Tab Profil, dan Navigasi
│   ├── shop/           # Belanja cinderamata kriya
│   ├── splash/         # Layar Splash Screen awal
│   └── welcome/        # Layar Selamat Datang
└── services/           # Supabase Service, Auth Service, Audio Service
```

---

*Dikembangkan dengan penuh dedikasi untuk pelestarian warisan adiluhung budaya Nusantara.*
