const javaraPage = figma.root.children.find(p => p.name === 'Javara');
const comp4 = await figma.getNodeByIdAsync('345:818');

function hexToRgb(hex) {
  let c = hex.replace("#", "");
  if (c.length === 3) c = c.split("").map(ch => ch + ch).join("");
  const num = parseInt(c, 16);
  return { r: ((num >> 16) & 255) / 255, g: ((num >> 8) & 255) / 255, b: (num & 255) / 255 };
}

function solidPaint(hex, opacity = 1) {
  return [{ type: "SOLID", color: hexToRgb(hex), opacity: Math.min(1, Math.max(0, opacity)) }];
}

function imagePaint(hash, scaleMode = "FILL") {
  return [{ type: "IMAGE", scaleMode: scaleMode, imageHash: hash }];
}

function addText(parent, { text, x = 0, y = 0, size = 14, weight = "Regular", family = "Lora", color = "#2B1A12", opacity = 1, align = "LEFT", width = null, height = null, lineSpacing = null, letterSpacing = null }) {
  const t = figma.createText();
  parent.appendChild(t);
  let style = weight;
  if (family === "Inter") {
    style = (weight === "Bold" || weight === "SemiBold") ? "Bold" : (weight === "Medium" ? "Medium" : "Regular");
  } else {
    style = (weight === "Bold" || weight === "SemiBold") ? "Bold" : "Regular";
  }
  t.fontName = { family, style };
  t.fontSize = size;
  t.characters = text;
  t.x = x;
  t.y = y;
  t.fills = solidPaint(color, opacity);
  t.textAlignHorizontal = align;
  if (width) {
    t.textAutoResize = "HEIGHT";
    t.resize(width, height || size * 1.4);
  }
  if (lineSpacing) { t.lineHeight = { value: lineSpacing, unit: "PIXELS" }; }
  if (letterSpacing) { t.letterSpacing = { value: letterSpacing, unit: "PIXELS" }; }
  return t;
}

function addRect(parent, { x = 0, y = 0, width = 100, height = 100, fill = "#F4E9D8", opacity = 1, radius = 0, stroke = null, strokeWidth = 1, strokeOpacity = 1, imageHash = null, name = "Rect" }) {
  const r = figma.createRectangle();
  parent.appendChild(r);
  r.name = name;
  r.x = x;
  r.y = y;
  r.resize(width, height);
  if (imageHash) {
    r.fills = imagePaint(imageHash);
  } else if (fill) {
    r.fills = solidPaint(fill, opacity);
  }
  if (radius) r.cornerRadius = radius;
  if (stroke) {
    r.strokes = solidPaint(stroke, strokeOpacity);
    r.strokeWeight = strokeWidth;
  }
  return r;
}

function addStatusBar(frame, isLight = false) {
  const sb = figma.createFrame();
  frame.appendChild(sb);
  sb.name = "Status Bar";
  sb.x = 0;
  sb.y = 0;
  sb.resize(412, 44);
  sb.fills = [];
  const col = isLight ? "#FFFBF4" : "#2B1A12";
  addText(sb, { text: "9:41", x: 28, y: 14, size: 14, weight: "Bold", family: "Inter", color: col });
  addText(sb, { text: "5G  100%", x: 330, y: 14, size: 12, weight: "Medium", family: "Inter", color: col });
  return sb;
}

function addBackButton(frame) {
  const btn = figma.createFrame();
  frame.appendChild(btn);
  btn.name = "Tombol Kembali";
  btn.x = 20;
  btn.y = 52;
  btn.resize(36, 36);
  btn.fills = [];
  addText(btn, { text: "←", x: 6, y: 4, size: 22, weight: "Bold", family: "Inter", color: "#2B1A12" });
  return btn;
}

// ==========================================
// SECTION 2: BERANDA & PENJELAJAHAN BUDAYA
// ==========================================
const sec2 = figma.createSection();
javaraPage.appendChild(sec2);
sec2.name = "ALUR 2 — BERANDA & PENJELAJAHAN BUDAYA (5 Screens)";
sec2.x = 0;
sec2.y = 1200;
sec2.resize(2560, 1550);

let s2x = 60;
const y2Pos = 80;

// 15 — Beranda Utama
const s15 = figma.createFrame(); sec2.appendChild(s15); s15.name = "15 — Beranda Utama (Current APK)"; s15.x = s2x; s15.y = y2Pos; s15.resize(412, 1380); s15.fills = solidPaint("#F4E9D8"); s15.cornerRadius = 28; s15.clipsContent = true;
addStatusBar(s15, false);
addText(s15, { text: "Sugeng Rawuh,", x: 24, y: 64, size: 14, family: "Lora", color: "#6B5845" });
addText(s15, { text: "Raden Mas Arya", x: 24, y: 86, size: 24, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s15, { text: "🔔", x: 360, y: 74, size: 22, family: "Inter", color: "#2B1A12" });
const sb15 = figma.createFrame(); s15.appendChild(sb15); sb15.name = "Search Bar"; sb15.x = 24; sb15.y = 126; sb15.resize(364, 48); sb15.fills = solidPaint("#FFFBF4"); sb15.strokes = solidPaint("#E0C9A6"); sb15.strokeWeight = 1; sb15.cornerRadius = 12; sb15.paddingLeft = 16; sb15.paddingRight = 16; sb15.layoutMode = "HORIZONTAL"; sb15.primaryAxisAlignItems = "SPACE_BETWEEN"; sb15.counterAxisAlignItems = "CENTER"; sb15.layoutSizingHorizontal = "FIXED"; sb15.layoutSizingVertical = "FIXED";
addText(sb15, { text: "🔍  Cari rasa, karya atau cerita jawa...", size: 13, family: "Lora", color: "#6B5845" });
addText(sb15, { text: "⚙", size: 16, family: "Inter", color: "#2B1A12" });

addRect(s15, { x: 24, y: 190, width: 364, height: 180, radius: 16, imageHash: "7e93353d53942a440b72c1e52db5d5e35d2cdb60", stroke: "#E0C9A6", strokeWidth: 1, name: "Hero Lanskap Joglo" });
addText(s15, { text: "Kategori Khasanah", x: 24, y: 390, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

const cats15 = [
  { name: "Candi & Situs", hash: "6cfffa6d4b1a106f14380589f575ae7010a42701", x: 24 },
  { name: "Kuliner Jawa", hash: "c446742019072560f6f77e9bb53fc96c2bcb1aab", x: 120 },
  { name: "Busana Adat", hash: "1fbfe49e615479b943ef56617243e3376418a136", x: 216 },
  { name: "Seni Wayang", hash: "f4c6295c1ace0f26014f0a8c3a6ef894debdd09f", x: 312 }
];
for (const c of cats15) {
  const circ = figma.createEllipse(); s15.appendChild(circ); circ.x = c.x + 8; circ.y = 425; circ.resize(60, 60); circ.fills = imagePaint(c.hash); circ.strokes = solidPaint("#C79B3A"); circ.strokeWeight = 1.5;
  addText(s15, { text: c.name, x: c.x, y: 494, width: 76, size: 11, weight: "Medium", family: "Lora", color: "#2B1A12", align: "CENTER" });
}

addText(s15, { text: "Rekomendasi Budaya", x: 24, y: 540, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s15, { text: "Lihat Semua →", x: 300, y: 542, size: 12, weight: "Bold", family: "Lora", color: "#3A261D" });

// Gudeg Card
const rc1 = figma.createFrame(); s15.appendChild(rc1); rc1.x = 24; rc1.y = 574; rc1.resize(174, 230); rc1.fills = solidPaint("#FFFBF4"); rc1.strokes = solidPaint("#E0C9A6"); rc1.strokeWeight = 1; rc1.cornerRadius = 14; rc1.clipsContent = true;
addRect(rc1, { x: 0, y: 0, width: 174, height: 125, imageHash: "c446742019072560f6f77e9bb53fc96c2bcb1aab" });
addText(rc1, { text: "D.I. Yogyakarta", x: 12, y: 135, size: 10, weight: "Medium", family: "Inter", color: "#B5603A" });
addText(rc1, { text: "Gudeg Yu Djum Wijilan", x: 12, y: 152, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rc1, { text: "★ 4.9 (1.2k ulasan)", x: 12, y: 198, size: 11, family: "Inter", color: "#6B5845" });

// Wayang Card
const rc2 = figma.createFrame(); s15.appendChild(rc2); rc2.x = 214; rc2.y = 574; rc2.resize(174, 230); rc2.fills = solidPaint("#FFFBF4"); rc2.strokes = solidPaint("#E0C9A6"); rc2.strokeWeight = 1; rc2.cornerRadius = 14; rc2.clipsContent = true;
addRect(rc2, { x: 0, y: 0, width: 174, height: 125, imageHash: "f4c6295c1ace0f26014f0a8c3a6ef894debdd09f" });
addText(rc2, { text: "Surakarta", x: 12, y: 135, size: 10, weight: "Medium", family: "Inter", color: "#B5603A" });
addText(rc2, { text: "Wayang Kulit Purwa", x: 12, y: 152, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rc2, { text: "★ 5.0 (890 ulasan)", x: 12, y: 198, size: 11, family: "Inter", color: "#6B5845" });

addText(s15, { text: "Kriya & Suvenir Warisan", x: 24, y: 830, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
// Batik Card
const pc1 = figma.createFrame(); s15.appendChild(pc1); pc1.x = 24; pc1.y = 864; pc1.resize(174, 230); pc1.fills = solidPaint("#FFFBF4"); pc1.strokes = solidPaint("#E0C9A6"); pc1.strokeWeight = 1; pc1.cornerRadius = 14; pc1.clipsContent = true;
addRect(pc1, { x: 0, y: 0, width: 174, height: 125, imageHash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237" });
addText(pc1, { text: "Batik Tulis Parang", x: 12, y: 135, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(pc1, { text: "Rp 450.000", x: 12, y: 175, size: 14, weight: "Bold", family: "Inter", color: "#B08D57" });
addText(pc1, { text: "Solo Hadiningrat", x: 12, y: 198, size: 10, family: "Inter", color: "#6B5845" });

// Keranjang Card
const pc2 = figma.createFrame(); s15.appendChild(pc2); pc2.x = 214; pc2.y = 864; pc2.resize(174, 230); pc2.fills = solidPaint("#FFFBF4"); pc2.strokes = solidPaint("#E0C9A6"); pc2.strokeWeight = 1; pc2.cornerRadius = 14; pc2.clipsContent = true;
addRect(pc2, { x: 0, y: 0, width: 174, height: 125, imageHash: "02a22d8181245f26ef3eb5bdad734190b01e9a7d" });
addText(pc2, { text: "Keranjang Anyaman", x: 12, y: 135, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(pc2, { text: "Rp 125.000", x: 12, y: 175, size: 14, weight: "Bold", family: "Inter", color: "#B08D57" });
addText(pc2, { text: "Kudus Tradisional", x: 12, y: 198, size: 10, family: "Inter", color: "#6B5845" });

if (comp4) { const nav15 = comp4.clone(); s15.appendChild(nav15); nav15.x = -4; nav15.y = 1284; }
s2x += 492;

// 16 — Beranda Pencarian Aktif
const s16 = figma.createFrame(); sec2.appendChild(s16); s16.name = "16 — Beranda Pencarian Aktif (Current APK)"; s16.x = s2x; s16.y = y2Pos; s16.resize(412, 1380); s16.fills = solidPaint("#F4E9D8"); s16.cornerRadius = 28; s16.clipsContent = true;
addStatusBar(s16, false);
addBackButton(s16);
const sb16 = figma.createFrame(); s16.appendChild(sb16); sb16.name = "Search Bar Active"; sb16.x = 64; sb16.y = 50; sb16.resize(324, 44); sb16.fills = solidPaint("#FFFBF4"); sb16.strokes = solidPaint("#3A261D"); sb16.strokeWeight = 1.5; sb16.cornerRadius = 12; sb16.paddingLeft = 14; sb16.paddingRight = 14; sb16.layoutMode = "HORIZONTAL"; sb16.primaryAxisAlignItems = "SPACE_BETWEEN"; sb16.counterAxisAlignItems = "CENTER"; sb16.layoutSizingHorizontal = "FIXED"; sb16.layoutSizingVertical = "FIXED";
addText(sb16, { text: "Candi Borobudur|", size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sb16, { text: "✕", size: 14, family: "Inter", color: "#6B5845" });

// Chips Kata Kunci Cepat
const chipRow = figma.createFrame(); s16.appendChild(chipRow); chipRow.x = 24; chipRow.y = 110; chipRow.resize(364, 34); chipRow.fills = []; chipRow.layoutMode = "HORIZONTAL"; chipRow.itemSpacing = 8;
const sChips = ["Candi (12)", "Batik (28)", "Keraton (8)", "Gamelan (14)"];
for (let i = 0; i < sChips.length; i++) {
  const ch = figma.createFrame(); chipRow.appendChild(ch); ch.resize(i === 0 ? 86 : 80, 32); ch.fills = solidPaint(i === 0 ? "#3A261D" : "#E3CDAB"); ch.cornerRadius = 8; ch.layoutMode = "HORIZONTAL"; ch.primaryAxisAlignItems = "CENTER"; ch.counterAxisAlignItems = "CENTER"; ch.layoutSizingHorizontal = "FIXED"; ch.layoutSizingVertical = "FIXED";
  addText(ch, { text: sChips[i], size: 11, weight: i === 0 ? "Bold" : "Medium", family: "Lora", color: i === 0 ? "#FFFBF4" : "#2B1A12" });
}

addText(s16, { text: "Hasil Pencarian: 3 Ditemukan", x: 24, y: 160, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Search Result 1: Candi Borobudur
const sr1 = figma.createFrame(); s16.appendChild(sr1); sr1.x = 24; sr1.y = 190; sr1.resize(364, 110); sr1.fills = solidPaint("#FFFBF4"); sr1.strokes = solidPaint("#E0C9A6"); sr1.strokeWeight = 1; sr1.cornerRadius = 14; sr1.clipsContent = true;
addRect(sr1, { x: 0, y: 0, width: 110, height: 110, imageHash: "6cfffa6d4b1a106f14380589f575ae7010a42701" });
addText(sr1, { text: "Candi Borobudur", x: 124, y: 14, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sr1, { text: "Kabupaten Magelang • Situs Warisan Dunia UNESCO", x: 124, y: 36, width: 226, size: 11, family: "Lora", color: "#6B5845", lineSpacing: 16 });
addText(sr1, { text: "★ 4.9 (14.2k)  •  Buka 06.00 - 17.00", x: 124, y: 76, size: 10.5, family: "Inter", color: "#B5603A" });

// Search Result 2: Candi Prambanan
const sr2 = figma.createFrame(); s16.appendChild(sr2); sr2.x = 24; sr2.y = 314; sr2.resize(364, 110); sr2.fills = solidPaint("#FFFBF4"); sr2.strokes = solidPaint("#E0C9A6"); sr2.strokeWeight = 1; sr2.cornerRadius = 14; sr2.clipsContent = true;
addRect(sr2, { x: 0, y: 0, width: 110, height: 110, imageHash: "7e93353d53942a440b72c1e52db5d5e35d2cdb60" });
addText(sr2, { text: "Candi Prambanan", x: 124, y: 14, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sr2, { text: "Klaten & Sleman • Kompleks Candi Hindu Terbesar", x: 124, y: 36, width: 226, size: 11, family: "Lora", color: "#6B5845", lineSpacing: 16 });
addText(sr2, { text: "★ 4.8 (9.8k)  •  Pagelaran Ramayana", x: 124, y: 76, size: 10.5, family: "Inter", color: "#B5603A" });

// Search Result 3: Candi Mendut
const sr3 = figma.createFrame(); s16.appendChild(sr3); sr3.x = 24; sr3.y = 438; sr3.resize(364, 110); sr3.fills = solidPaint("#FFFBF4"); sr3.strokes = solidPaint("#E0C9A6"); sr3.strokeWeight = 1; sr3.cornerRadius = 14; sr3.clipsContent = true;
addRect(sr3, { x: 0, y: 0, width: 110, height: 110, imageHash: "6cfffa6d4b1a106f14380589f575ae7010a42701" });
addText(sr3, { text: "Candi Mendut", x: 124, y: 14, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sr3, { text: "Magelang • Arca Buddha Vairocana Agung", x: 124, y: 36, width: 226, size: 11, family: "Lora", color: "#6B5845", lineSpacing: 16 });
addText(sr3, { text: "★ 4.7 (3.1k)  •  3 km dari Borobudur", x: 124, y: 76, size: 10.5, family: "Inter", color: "#B5603A" });

if (comp4) { const nav16 = comp4.clone(); s16.appendChild(nav16); nav16.x = -4; nav16.y = 1284; }
s2x += 492;

// 17 — Detail Budaya: Gudeg Yu Djum
const s17 = figma.createFrame(); sec2.appendChild(s17); s17.name = "17 — Detail Budaya: Gudeg Yu Djum (Current APK)"; s17.x = s2x; s17.y = y2Pos; s17.resize(412, 1380); s17.fills = solidPaint("#F4E9D8"); s17.cornerRadius = 28; s17.clipsContent = true;
addStatusBar(s17, false); addBackButton(s17);
addText(s17, { text: "Detail Kuliner Jawa", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s17, { x: 24, y: 100, width: 364, height: 260, radius: 18, imageHash: "c446742019072560f6f77e9bb53fc96c2bcb1aab", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s17, { text: "Gudeg Yu Djum Wijilan", x: 24, y: 380, size: 22, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s17, { text: "Sentra Gudeg Tradisional Wijilan, D.I. Yogyakarta", x: 24, y: 410, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });
addText(s17, { text: "★ 4.9 (1.2k Ulasan)  •  Legenda Sejak 1950", x: 24, y: 432, size: 12, family: "Lora", color: "#6B5845" });

addText(s17, { text: "Khasanah Rasa & Sejarah", x: 24, y: 470, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s17, { text: "Gudeg Yu Djum merupakan pusaka kuliner Yogyakarta yang dimasak perlahan di atas tungku kayu bakar menggunakan rempah kelapa pilihan, daun jati merah, nangka muda (gori), serta krecek pedas gurih khas keraton.", x: 24, y: 496, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

addText(s17, { text: "Pilihan Menu Utama", x: 24, y: 600, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
const gMenus = [
  { n: "Nasi Gudeg Telur + Suwir Ayam", p: "Rp 35.000" },
  { n: "Paket Besek Lengkap Ayam Kampung Utuh", p: "Rp 180.000" },
  { n: "Gudeg Kaleng Yu Djum (Oleh-Oleh)", p: "Rp 45.000" }
];
let gmy = 630;
for (const gm of gMenus) {
  const gBox = figma.createFrame(); s17.appendChild(gBox); gBox.x = 24; gBox.y = gmy; gBox.resize(364, 48); gBox.fills = solidPaint("#FFFBF4"); gBox.strokes = solidPaint("#E0C9A6"); gBox.strokeWeight = 1; gBox.cornerRadius = 10; gBox.paddingLeft = 14; gBox.paddingRight = 14; gBox.layoutMode = "HORIZONTAL"; gBox.primaryAxisAlignItems = "SPACE_BETWEEN"; gBox.counterAxisAlignItems = "CENTER"; gBox.layoutSizingHorizontal = "FIXED"; gBox.layoutSizingVertical = "FIXED";
  addText(gBox, { text: gm.n, size: 12, weight: "Medium", family: "Lora", color: "#2B1A12" });
  addText(gBox, { text: gm.p, size: 12, weight: "Bold", family: "Inter", color: "#B08D57" });
  gmy += 56;
}

const btnOrderG = figma.createFrame(); s17.appendChild(btnOrderG); btnOrderG.x = 24; btnOrderG.y = 810; btnOrderG.resize(364, 52); btnOrderG.fills = solidPaint("#3A261D"); btnOrderG.cornerRadius = 12; btnOrderG.layoutMode = "HORIZONTAL"; btnOrderG.primaryAxisAlignItems = "CENTER"; btnOrderG.counterAxisAlignItems = "CENTER"; btnOrderG.layoutSizingHorizontal = "FIXED"; btnOrderG.layoutSizingVertical = "FIXED";
addText(btnOrderG, { text: "🛍️ Pesan Menu Budaya Ini", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });
s2x += 492;

// 18 — Detail Seni: Wayang Kulit Purwa
const s18 = figma.createFrame(); sec2.appendChild(s18); s18.name = "18 — Detail Seni: Wayang Purwa (Current APK)"; s18.x = s2x; s18.y = y2Pos; s18.resize(412, 1380); s18.fills = solidPaint("#F4E9D8"); s18.cornerRadius = 28; s18.clipsContent = true;
addStatusBar(s18, false); addBackButton(s18);
addText(s18, { text: "Detail Seni Pertunjukan", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s18, { x: 24, y: 100, width: 364, height: 260, radius: 18, imageHash: "f4c6295c1ace0f26014f0a8c3a6ef894debdd09f", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s18, { text: "Wayang Kulit Purwa Gagrag Surakarta", x: 24, y: 380, size: 21, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s18, { text: "Mahakarya Seni Adiluhung Keraton Kasunanan Solo", x: 24, y: 410, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });
addText(s18, { text: "Lakon: Karna Tanding  •  Kidung Gamelan Slendro", x: 24, y: 432, size: 12, family: "Lora", color: "#6B5845" });

addText(s18, { text: "Filosofi & Nilai Luhur Ksatria", x: 24, y: 470, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s18, { text: "Wayang Kulit Purwa menggambarkan pergulatan batin manusia antara darma (kebenaran) dan adarma (keserakahan). Melalui tata cahaya blencong dan kelir putih, dalang menyampaikan wejangan luhur hidup selaras dengan alam semesta.", x: 24, y: 496, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

addText(s18, { text: "Jadwal Pagelaran Keraton", x: 24, y: 610, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
const wShows = [
  { t: "Malam Jumat Kliwon", loc: "Pendopo Sasana Sewaka Keraton", time: "20.00 - 04.00" },
  { t: "Festival Wayang Nusantara", loc: "Taman Budaya Jawa Tengah (TBJT)", time: "19.30 - 23.30" }
];
let wsy = 640;
for (const ws of wShows) {
  const wCard = figma.createFrame(); s18.appendChild(wCard); wCard.x = 24; wCard.y = wsy; wCard.resize(364, 58); wCard.fills = solidPaint("#FFFBF4"); wCard.strokes = solidPaint("#E0C9A6"); wCard.strokeWeight = 1; wCard.cornerRadius = 10; wCard.paddingLeft = 14; wCard.paddingRight = 14; wCard.layoutMode = "HORIZONTAL"; wCard.primaryAxisAlignItems = "SPACE_BETWEEN"; wCard.counterAxisAlignItems = "CENTER"; wCard.layoutSizingHorizontal = "FIXED"; wCard.layoutSizingVertical = "FIXED";
  const wCol = figma.createFrame(); wCard.appendChild(wCol); wCol.resize(230, 42); wCol.fills = []; wCol.layoutMode = "VERTICAL"; wCol.primaryAxisAlignItems = "CENTER";
  addText(wCol, { text: ws.t, size: 12.5, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(wCol, { text: ws.loc, size: 10, family: "Lora", color: "#6B5845" });
  addText(wCard, { text: ws.time, size: 11, weight: "Bold", family: "Inter", color: "#B5603A" });
  wsy += 68;
}

const btnListen = figma.createFrame(); s18.appendChild(btnListen); btnListen.x = 24; btnListen.y = 800; btnListen.resize(364, 52); btnListen.fills = solidPaint("#C79B3A"); btnListen.cornerRadius = 12; btnListen.layoutMode = "HORIZONTAL"; btnListen.primaryAxisAlignItems = "CENTER"; btnListen.counterAxisAlignItems = "CENTER"; btnListen.layoutSizingHorizontal = "FIXED"; btnListen.layoutSizingVertical = "FIXED";
addText(btnListen, { text: "🎶 Dengarkan Gendhing Suluk Wayang", size: 14, weight: "Bold", family: "Lora", color: "#261808" });
s2x += 492;

// 19 — Keranjang Belanja Kriya
const s19 = figma.createFrame(); sec2.appendChild(s19); s19.name = "19 — Keranjang Belanja Kriya (Current APK)"; s19.x = s2x; s19.y = y2Pos; s19.resize(412, 1380); s19.fills = solidPaint("#F4E9D8"); s19.cornerRadius = 28; s19.clipsContent = true;
addStatusBar(s19, false); addBackButton(s19);
addText(s19, { text: "Keranjang Belanja Kriya", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Item 1
const it1 = figma.createFrame(); s19.appendChild(it1); it1.x = 24; it1.y = 110; it1.resize(364, 100); it1.fills = solidPaint("#FFFBF4"); it1.strokes = solidPaint("#E0C9A6"); it1.strokeWeight = 1; it1.cornerRadius = 14; it1.clipsContent = true;
addRect(it1, { x: 0, y: 0, width: 100, height: 100, imageHash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237" });
addText(it1, { text: "Batik Tulis Parang Barong", x: 114, y: 16, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(it1, { text: "Solo Hadiningrat • 1 pcs", x: 114, y: 38, size: 11, family: "Lora", color: "#6B5845" });
addText(it1, { text: "Rp 450.000", x: 114, y: 64, size: 14, weight: "Bold", family: "Inter", color: "#B08D57" });

// Item 2
const it2 = figma.createFrame(); s19.appendChild(it2); it2.x = 24; it2.y = 224; it2.resize(364, 100); it2.fills = solidPaint("#FFFBF4"); it2.strokes = solidPaint("#E0C9A6"); it2.strokeWeight = 1; it2.cornerRadius = 14; it2.clipsContent = true;
addRect(it2, { x: 0, y: 0, width: 100, height: 100, imageHash: "02a22d8181245f26ef3eb5bdad734190b01e9a7d" });
addText(it2, { text: "Keranjang Anyaman Kudus", x: 114, y: 16, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(it2, { text: "Kudus Tradisional • 1 pcs", x: 114, y: 38, size: 11, family: "Lora", color: "#6B5845" });
addText(it2, { text: "Rp 125.000", x: 114, y: 64, size: 14, weight: "Bold", family: "Inter", color: "#B08D57" });

// Summary Card
const sumCard = figma.createFrame(); s19.appendChild(sumCard); sumCard.x = 24; sumCard.y = 350; sumCard.resize(364, 150); sumCard.fills = solidPaint("#FFFBF4"); sumCard.strokes = solidPaint("#E0C9A6"); sumCard.strokeWeight = 1; sumCard.cornerRadius = 14; sumCard.paddingLeft = 18; sumCard.paddingRight = 18; sumCard.paddingTop = 16;
addText(sumCard, { text: "Ringkasan Pesanan", x: 18, y: 16, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sumCard, { text: "Subtotal Kriya (2 Item)", x: 18, y: 44, size: 12, family: "Lora", color: "#6B5845" });
addText(sumCard, { text: "Rp 575.000", x: 260, y: 44, size: 12, weight: "Bold", family: "Inter", color: "#2B1A12" });
addText(sumCard, { text: "Ongkos Kirim Budaya", x: 18, y: 70, size: 12, family: "Lora", color: "#6B5845" });
addText(sumCard, { text: "Gratis (Promo)", x: 260, y: 70, size: 12, weight: "Bold", family: "Inter", color: "#3F6B3A" });
addRect(sumCard, { x: 18, y: 96, width: 328, height: 1, fill: "#E0C9A6" });
addText(sumCard, { text: "Total Tagihan:", x: 18, y: 110, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(sumCard, { text: "Rp 575.000", x: 240, y: 108, size: 16, weight: "Bold", family: "Inter", color: "#B08D57" });

const btnCheckout = figma.createFrame(); s19.appendChild(btnCheckout); btnCheckout.x = 24; btnCheckout.y = 525; btnCheckout.resize(364, 52); btnCheckout.fills = solidPaint("#3A261D"); btnCheckout.cornerRadius = 12; btnCheckout.layoutMode = "HORIZONTAL"; btnCheckout.primaryAxisAlignItems = "CENTER"; btnCheckout.counterAxisAlignItems = "CENTER"; btnCheckout.layoutSizingHorizontal = "FIXED"; btnCheckout.layoutSizingVertical = "FIXED";
addText(btnCheckout, { text: "Simulasi Checkout Kriya →", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });


// ==========================================
// SECTION 3: JELAJAH JAWA & 35 WILAYAH
// ==========================================
const sec3 = figma.createSection();
javaraPage.appendChild(sec3);
sec3.name = "ALUR 3 — JELAJAH JAWA & 35 WILAYAH (4 Screens)";
sec3.x = 2620;
sec3.y = 1200;
sec3.resize(2060, 1550);

let s3x = 60;
const y3Pos = 80;

// 20 — Jelajah Jawa Utama
const s20 = figma.createFrame(); sec3.appendChild(s20); s20.name = "20 — Jelajah Jawa Utama (Current APK)"; s20.x = s3x; s20.y = y3Pos; s20.resize(412, 1380); s20.fills = solidPaint("#F4E9D8"); s20.cornerRadius = 28; s20.clipsContent = true;
addStatusBar(s20, false);
addText(s20, { text: "Jelajah Jawa", x: 24, y: 64, size: 24, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s20, { text: "👜", x: 360, y: 64, size: 20, family: "Inter", color: "#2B1A12" });

const sndBar = figma.createFrame(); s20.appendChild(sndBar); sndBar.x = 24; sndBar.y = 104; sndBar.resize(364, 46); sndBar.fills = solidPaint("#3A261D"); sndBar.cornerRadius = 12; sndBar.paddingLeft = 14; sndBar.paddingRight = 14; sndBar.layoutMode = "HORIZONTAL"; sndBar.primaryAxisAlignItems = "SPACE_BETWEEN"; sndBar.counterAxisAlignItems = "CENTER"; sndBar.layoutSizingHorizontal = "FIXED"; sndBar.layoutSizingVertical = "FIXED";
addText(sndBar, { text: "🎶  Swara Nusantara • Gamelan Laras Slendro", size: 12, weight: "Medium", family: "Lora", color: "#FFFBF4" });
addText(sndBar, { text: "⏸", size: 14, family: "Inter", color: "#C79B3A" });

addText(s20, { text: "Pilih daerah, temukan warisannya.", x: 24, y: 168, width: 364, size: 22, weight: "Bold", family: "Lora", color: "#2B1A12", lineSpacing: 28 });
addText(s20, { text: "Setiap daerah punya budaya, produk, makanan dan acara sendiri", x: 24, y: 228, width: 364, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });

const pRow3 = figma.createFrame(); s20.appendChild(pRow3); pRow3.x = 24; pRow3.y = 280; pRow3.resize(364, 38); pRow3.fills = []; pRow3.layoutMode = "HORIZONTAL"; pRow3.itemSpacing = 12;
const pJateng = figma.createFrame(); pRow3.appendChild(pJateng); pJateng.resize(200, 38); pJateng.fills = solidPaint("#3A261D"); pJateng.cornerRadius = 10; pJateng.layoutMode = "HORIZONTAL"; pJateng.primaryAxisAlignItems = "CENTER"; pJateng.counterAxisAlignItems = "CENTER"; pJateng.layoutSizingHorizontal = "FIXED"; pJateng.layoutSizingVertical = "FIXED";
addText(pJateng, { text: "Jawa Tengah (35 Daerah)", size: 12, weight: "Bold", family: "Lora", color: "#FFFBF4" });
const pDIY = figma.createFrame(); pRow3.appendChild(pDIY); pDIY.resize(140, 38); pDIY.fills = solidPaint("#E3CDAB"); pDIY.cornerRadius = 10; pDIY.layoutMode = "HORIZONTAL"; pDIY.primaryAxisAlignItems = "CENTER"; pDIY.counterAxisAlignItems = "CENTER"; pDIY.layoutSizingHorizontal = "FIXED"; pDIY.layoutSizingVertical = "FIXED";
addText(pDIY, { text: "D.I. Yogyakarta", size: 12, weight: "Medium", family: "Lora", color: "#2B1A12" });

const mapC = figma.createFrame(); s20.appendChild(mapC); mapC.x = 24; mapC.y = 334; mapC.resize(364, 180); mapC.fills = solidPaint("#E0C9A6"); mapC.cornerRadius = 16; mapC.strokes = solidPaint("#C79B3A"); mapC.strokeWeight = 1.2;
addText(mapC, { text: "🗺️ Peta Budaya 35 Wilayah Jawa Tengah", x: 16, y: 16, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(mapC, { text: "Ketuk pin untuk melihat khasanah daerah", x: 16, y: 36, size: 11, family: "Lora", color: "#6B5845" });
const pins = [{ name: "Semarang", x: 180, y: 70 }, { name: "Surakarta", x: 230, y: 120 }, { name: "Magelang", x: 160, y: 110 }, { name: "Pekalongan", x: 110, y: 65 }, { name: "Banyumas", x: 60, y: 125 }];
for (const p of pins) {
  const pin = figma.createFrame(); mapC.appendChild(pin); pin.resize(70, 24); pin.x = p.x; pin.y = p.y; pin.fills = solidPaint("#3A261D"); pin.cornerRadius = 6; pin.layoutMode = "HORIZONTAL"; pin.primaryAxisAlignItems = "CENTER"; pin.counterAxisAlignItems = "CENTER"; pin.layoutSizingHorizontal = "FIXED"; pin.layoutSizingVertical = "FIXED";
  addText(pin, { text: "📍 " + p.name, size: 10, weight: "Bold", family: "Inter", color: "#FFFBF4" });
}

addText(s20, { text: "Destinasi Khasanah Pilihan", x: 24, y: 535, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Reg 1: Solo
const rg1 = figma.createFrame(); s20.appendChild(rg1); rg1.x = 24; rg1.y = 570; rg1.resize(364, 100); rg1.fills = solidPaint("#FFFBF4"); rg1.strokes = solidPaint("#E0C9A6"); rg1.strokeWeight = 1; rg1.cornerRadius = 14; rg1.clipsContent = true;
addRect(rg1, { x: 0, y: 0, width: 100, height: 100, imageHash: "1fbfe49e615479b943ef56617243e3376418a136" });
addText(rg1, { text: "Kota Surakarta (Solo)", x: 114, y: 16, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rg1, { text: "Pusat Keraton Kasunanan & Pura Mangkunegaran, sentra batik adiluhung.", x: 114, y: 38, width: 236, size: 11, family: "Lora", color: "#6B5845", lineSpacing: 16 });
addText(rg1, { text: "14 Khasanah Terdaftar →", x: 114, y: 74, size: 11, weight: "Bold", family: "Lora", color: "#B5603A" });

// Reg 2: Magelang
const rg2 = figma.createFrame(); s20.appendChild(rg2); rg2.x = 24; rg2.y = 684; rg2.resize(364, 100); rg2.fills = solidPaint("#FFFBF4"); rg2.strokes = solidPaint("#E0C9A6"); rg2.strokeWeight = 1; rg2.cornerRadius = 14; rg2.clipsContent = true;
addRect(rg2, { x: 0, y: 0, width: 100, height: 100, imageHash: "6cfffa6d4b1a106f14380589f575ae7010a42701" });
addText(rg2, { text: "Kabupaten Magelang", x: 114, y: 16, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rg2, { text: "Mahakarya Candi Borobudur, peradaban Mataram Kuno & lembah Progo.", x: 114, y: 38, width: 236, size: 11, family: "Lora", color: "#6B5845", lineSpacing: 16 });
addText(rg2, { text: "21 Khasanah Terdaftar →", x: 114, y: 74, size: 11, weight: "Bold", family: "Lora", color: "#B5603A" });

if (comp4) { const nav20 = comp4.clone(); s20.appendChild(nav20); nav20.x = -4; nav20.y = 1284; }
s3x += 492;

// 21 — Detail Wilayah Surakarta
const s21 = figma.createFrame(); sec3.appendChild(s21); s21.name = "21 — Detail Wilayah: Surakarta (Current APK)"; s21.x = s3x; s21.y = y3Pos; s21.resize(412, 1380); s21.fills = solidPaint("#F4E9D8"); s21.cornerRadius = 28; s21.clipsContent = true;
addStatusBar(s21, false); addBackButton(s21);
addText(s21, { text: "Kota Surakarta (Solo)", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s21, { x: 24, y: 100, width: 364, height: 240, radius: 18, imageHash: "1fbfe49e615479b943ef56617243e3376418a136", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s21, { text: "Keraton Hadiningrat & Mangkunegaran", x: 24, y: 360, size: 20, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s21, { text: "Pusat Pelestarian Kebudayaan Mataram Islam", x: 24, y: 390, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });

addText(s21, { text: "Profil Khasanah Daerah", x: 24, y: 430, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s21, { text: "Kota Surakarta merupakan poros adiluhung seni tari bedhaya, gamelan slendro keraton, tata busana kebaya, serta tradisi batik Laweyan dan Kauman. Sebagai pusat monarki tradisional, Solo menjaga pakem adat berusia ratusan tahun.", x: 24, y: 456, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

addText(s21, { text: "Destinasi Wajib Dikunjungi", x: 24, y: 570, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
const sDests = [
  "1. Keraton Kasunanan Surakarta Hadiningrat",
  "2. Pura Mangkunegaran & Taman Air Prabasasana",
  "3. Pasar Gede Hardjonagoro (Kuliner Dawet Telasih)",
  "4. Kampung Batik Laweyan & Kauman"
];
let sdy = 600;
for (const sd of sDests) {
  addText(s21, { text: "•  " + sd, x: 28, y: sdy, width: 360, size: 12.5, family: "Lora", color: "#2B1A12" });
  sdy += 24;
}

const btnExploreSolo = figma.createFrame(); s21.appendChild(btnExploreSolo); btnExploreSolo.x = 24; btnExploreSolo.y = 730; btnExploreSolo.resize(364, 52); btnExploreSolo.fills = solidPaint("#3A261D"); btnExploreSolo.cornerRadius = 12; btnExploreSolo.layoutMode = "HORIZONTAL"; btnExploreSolo.primaryAxisAlignItems = "CENTER"; btnExploreSolo.counterAxisAlignItems = "CENTER"; btnExploreSolo.layoutSizingHorizontal = "FIXED"; btnExploreSolo.layoutSizingVertical = "FIXED";
addText(btnExploreSolo, { text: "Jelajahi 14 Khasanah Solo →", size: 14, weight: "Bold", family: "Lora", color: "#FFFBF4" });
s3x += 492;

// 22 — Detail Wilayah Magelang
const s22 = figma.createFrame(); sec3.appendChild(s22); s22.name = "22 — Detail Wilayah: Magelang (Current APK)"; s22.x = s3x; s22.y = y3Pos; s22.resize(412, 1380); s22.fills = solidPaint("#F4E9D8"); s22.cornerRadius = 28; s22.clipsContent = true;
addStatusBar(s22, false); addBackButton(s22);
addText(s22, { text: "Kabupaten Magelang", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s22, { x: 24, y: 100, width: 364, height: 240, radius: 18, imageHash: "6cfffa6d4b1a106f14380589f575ae7010a42701", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s22, { text: "Mahakarya Borobudur & Mataram", x: 24, y: 360, size: 20, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s22, { text: "Lembah Pegunungan Menoreh & Candi Kuno", x: 24, y: 390, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });

addText(s22, { text: "Profil Khasanah Daerah", x: 24, y: 430, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s22, { text: "Magelang dikaruniai kemegahan Candi Borobudur peninggalan Dinasti Syailendra abad ke-8. Dikelilingi 5 gunung sakral (Merapi, Merbabu, Sumbing, Andong, Telomoyo), wilayah ini menyimpan kekayaan spiritual dan agraris tinggi.", x: 24, y: 456, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

const btnExploreMag = figma.createFrame(); s22.appendChild(btnExploreMag); btnExploreMag.x = 24; btnExploreMag.y = 600; btnExploreMag.resize(364, 52); btnExploreMag.fills = solidPaint("#3A261D"); btnExploreMag.cornerRadius = 12; btnExploreMag.layoutMode = "HORIZONTAL"; btnExploreMag.primaryAxisAlignItems = "CENTER"; btnExploreMag.counterAxisAlignItems = "CENTER"; btnExploreMag.layoutSizingHorizontal = "FIXED"; btnExploreMag.layoutSizingVertical = "FIXED";
addText(btnExploreMag, { text: "Jelajahi 21 Khasanah Magelang →", size: 14, weight: "Bold", family: "Lora", color: "#FFFBF4" });
s3x += 492;

// 23 — Detail Wilayah Pekalongan
const s23 = figma.createFrame(); sec3.appendChild(s23); s23.name = "23 — Detail Wilayah: Pekalongan (Current APK)"; s23.x = s3x; s23.y = y3Pos; s23.resize(412, 1380); s23.fills = solidPaint("#F4E9D8"); s23.cornerRadius = 28; s23.clipsContent = true;
addStatusBar(s23, false); addBackButton(s23);
addText(s23, { text: "Kota Pekalongan", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s23, { x: 24, y: 100, width: 364, height: 240, radius: 18, imageHash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s23, { text: "Kota Batik Dunia UNESCO", x: 24, y: 360, size: 20, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s23, { text: "Sentra Canting Emas & Wastra Pesisiran", x: 24, y: 390, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });

addText(s23, { text: "Profil Khasanah Daerah", x: 24, y: 430, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s23, { text: "Pekalongan terkenal dengan ragam hias batik pesisiran yang dinamis, kaya warna, dan terbuka terhadap akulturasi budaya Nusantara, Tionghoa, Arab, dan Eropa. Setiap helai kain batik tulis dibuat dengan ketelitian tangan para pengrajin wanita.", x: 24, y: 456, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

const btnExplorePek = figma.createFrame(); s23.appendChild(btnExplorePek); btnExplorePek.x = 24; btnExplorePek.y = 600; btnExplorePek.resize(364, 52); btnExplorePek.fills = solidPaint("#3A261D"); btnExplorePek.cornerRadius = 12; btnExplorePek.layoutMode = "HORIZONTAL"; btnExplorePek.primaryAxisAlignItems = "CENTER"; btnExplorePek.counterAxisAlignItems = "CENTER"; btnExplorePek.layoutSizingHorizontal = "FIXED"; btnExplorePek.layoutSizingVertical = "FIXED";
addText(btnExplorePek, { text: "Jelajahi 18 Khasanah Pekalongan →", size: 14, weight: "Bold", family: "Lora", color: "#FFFBF4" });

return "Sections 2 and 3 created successfully!";