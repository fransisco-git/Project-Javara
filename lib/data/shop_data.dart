import 'package:flutter/material.dart';

/// Kategori koleksi busana adat Jawa Tengah.
enum ShopCategory {
  busana(
    'BUSANA',
    Icons.checkroom_rounded,
    'Busana Adat',
    'Koleksi pakaian tradisional',
    'kebaya.png',
  ),
  kerajinan(
    'KERAJINAN',
    Icons.palette_rounded,
    'Batik & Wastra',
    'Kain batik & tenun tradisional',
    'batik.png',
  ),
  aksesoris(
    'AKSESORIS',
    Icons.auto_awesome_rounded,
    'Aksesoris Adat',
    'Pelengkap busana tradisional',
    'keranjang.png',
  );

  const ShopCategory(
    this.label,
    this.icon,
    this.title,
    this.subtitle,
    this.image,
  );
  final String label;
  final IconData icon;
  final String title;
  final String subtitle;
  final String image;
}

/// Produk koleksi busana adat Jawa Tengah.
class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.category,
    required this.title,
    required this.origin,
    required this.price,
    required this.image,
    this.isNew = false,
    this.discount,
    this.rating = 4.8,
    this.reviewCount = 24,
    this.description = '',
  });

  final String id;
  final ShopCategory category;
  final String title;
  final String origin;
  final String price;
  final String image;
  final bool isNew;
  final String? discount;
  final double rating;
  final int reviewCount;
  final String description;
}

/// Katalog produk busana adat Jawa Tengah.
const shopProducts = <ShopProduct>[
  ShopProduct(
    id: 'kebaya_tradisional',
    category: ShopCategory.busana,
    title: 'Kebaya Kutubaru',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp350.000',
    image: 'kebaya.png',
    isNew: true,
    rating: 4.9,
    reviewCount: 38,
    description: 'Kebaya kutubaru brokat halus dengan motif sulam benang emas. Potongan klasik keraton Kasunanan.',
  ),
  ShopProduct(
    id: 'beskap_langenharjan',
    category: ShopCategory.busana,
    title: 'Beskap Langenharjan',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp475.000',
    image: 'kebaya.png',
    isNew: true,
    rating: 4.8,
    reviewCount: 22,
    description: 'Jas tradisional pria Jawa berkerah tegak dengan kancing asimetris kiri dan lengkungan belakang untuk keris.',
  ),
  ShopProduct(
    id: 'surjan_lurik',
    category: ShopCategory.busana,
    title: 'Surjan Lurik',
    origin: 'Yogyakarta',
    price: 'Rp285.000',
    image: 'kebaya.png',
    rating: 4.7,
    reviewCount: 45,
    description: 'Baju surjan bermotif lurik Yogyakarta dengan teknik tenun tradisional. Busana keseharian priyayi Jawa.',
  ),
  ShopProduct(
    id: 'batik_parang_shop',
    category: ShopCategory.kerajinan,
    title: 'Batik Parang Barong',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp275.000',
    image: 'batik.png',
    rating: 4.7,
    reviewCount: 56,
    description: 'Kain batik tulis motif parang barong dengan pewarnaan alami soga Jawa. Kain mori prima halus 2,5 meter.',
  ),
  ShopProduct(
    id: 'batik_truntum',
    category: ShopCategory.kerajinan,
    title: 'Batik Truntum',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp320.000',
    image: 'batik.png',
    rating: 4.9,
    reviewCount: 33,
    description: 'Kain batik tulis motif truntum klasik keraton. Motif bintang-bintang melambangkan cinta yang tumbuh kembali.',
  ),
  ShopProduct(
    id: 'jarik_sida_mukti',
    category: ShopCategory.kerajinan,
    title: 'Jarik Sida Mukti',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp295.000',
    image: 'batik.png',
    rating: 4.8,
    reviewCount: 41,
    description: 'Kain jarik batik tulis motif sida mukti, melambangkan harapan kemakmuran dan kebahagiaan hidup.',
  ),
  ShopProduct(
    id: 'blangkon_solo',
    category: ShopCategory.aksesoris,
    title: 'Blangkon Gaya Solo',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp85.000',
    image: 'keranjang.png',
    rating: 4.6,
    reviewCount: 67,
    description: 'Penutup kepala pria Jawa gaya Solo dengan mondolan (buntalan) di bagian belakang. Bahan batik halus.',
  ),
  ShopProduct(
    id: 'stagen_tenun',
    category: ShopCategory.aksesoris,
    title: 'Stagen Tenun',
    origin: 'Klaten, Jawa Tengah',
    price: 'Rp65.000',
    image: 'keranjang.png',
    rating: 4.5,
    reviewCount: 29,
    description: 'Ikat pinggang kain tenun tradisional untuk mengencangkan jarik. Panjang 3 meter dengan teknik tenun ATBM.',
  ),
  ShopProduct(
    id: 'selop_beludru',
    category: ShopCategory.aksesoris,
    title: 'Selop Beludru Keraton',
    origin: 'Surakarta, Jawa Tengah',
    price: 'Rp125.000',
    image: 'keranjang.png',
    rating: 4.7,
    reviewCount: 19,
    description: 'Alas kaki tradisional dari bahan beludru dengan sulaman benang emas motif lung-lungan keraton.',
  ),
];

/// Item favorit pengguna — hanya busana adat.
class FavoriteItem {
  FavoriteItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isFavorited = true,
  });

  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String image;
  bool isFavorited;
}

List<FavoriteItem> initialFavorites() => [
  FavoriteItem(
    id: 'fav_kebaya',
    category: 'BUSANA',
    title: 'Kebaya Kutubaru',
    subtitle: 'Rp350.000',
    image: 'kebaya.png',
  ),
  FavoriteItem(
    id: 'fav_batik',
    category: 'BATIK',
    title: 'Batik Parang Barong',
    subtitle: 'Rp275.000',
    image: 'batik.png',
  ),
  FavoriteItem(
    id: 'fav_blangkon',
    category: 'AKSESORIS',
    title: 'Blangkon Gaya Solo',
    subtitle: 'Rp85.000',
    image: 'keranjang.png',
  ),
  FavoriteItem(
    id: 'fav_beskap',
    category: 'BUSANA',
    title: 'Beskap Langenharjan',
    subtitle: 'Rp475.000',
    image: 'kebaya.png',
  ),
  FavoriteItem(
    id: 'fav_surjan',
    category: 'BUSANA',
    title: 'Surjan Lurik',
    subtitle: 'Rp285.000',
    image: 'kebaya.png',
  ),
];
