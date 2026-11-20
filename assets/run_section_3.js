
await Promise.all([
  figma.loadFontAsync({ family: "Inter", style: "Regular" }),
  figma.loadFontAsync({ family: "Inter", style: "Medium" }),
  figma.loadFontAsync({ family: "Inter", style: "Bold" }),
  figma.loadFontAsync({ family: "Lora", style: "Regular" }),
  figma.loadFontAsync({ family: "Lora", style: "Bold" })
]);
const javaraPage = figma.root.children.find(p => p.name === 'Javara');
// comp4 removed

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


function addBottomNavBar(frame, activeIndex = 0) {
  const bar = figma.createFrame();
  frame.appendChild(bar);
  bar.name = "Curved Liquid Glass Bottom Nav";
  bar.x = 16;
  bar.y = frame.height - 90;
  bar.resize(380, 70);
  bar.fills = solidPaint("#1F150E", 0.94);
  bar.strokes = solidPaint("#C79B3A", 0.5);
  bar.strokeWeight = 1.2;
  bar.cornerRadius = 35;
  bar.layoutMode = "HORIZONTAL";
  bar.primaryAxisAlignItems = "SPACE_AROUND";
  bar.counterAxisAlignItems = "CENTER";
  bar.layoutSizingHorizontal = "FIXED";
  bar.layoutSizingVertical = "FIXED";

  const tabs = [
    { label: "Beranda", icon: "🏛️" },
    { label: "Jelajah", icon: "🗺️" },
    { label: "Wardrobe", icon: "👘" },
    { label: "Sinau", icon: "📜" },
    { label: "Profil", icon: "👤" }
  ];

  tabs.forEach((tab, idx) => {
    const isAct = idx === activeIndex;
    const tabItem = figma.createFrame();
    bar.appendChild(tabItem);
    tabItem.resize(isAct ? 72 : 54, 56);
    tabItem.fills = isAct ? solidPaint("#C79B3A", 0.18) : [];
    if (isAct) { tabItem.cornerRadius = 18; }
    tabItem.layoutMode = "VERTICAL";
    tabItem.primaryAxisAlignItems = "CENTER";
    tabItem.counterAxisAlignItems = "CENTER";
    tabItem.itemSpacing = 2;
    tabItem.layoutSizingHorizontal = "FIXED";
    tabItem.layoutSizingVertical = "FIXED";

    addText(tabItem, { text: tab.icon, size: 18, family: "Inter" });
    addText(tabItem, { text: tab.label, size: 10, weight: isAct ? "Bold" : "Medium", family: "Inter", color: isAct ? "#C79B3A" : "#A89482" });
  });

  return bar;
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
// SECTION 3: JELAJAH JAWA & 35 WILAYAH
// ==========================================
const sec3 = figma.createSection();
javaraPage.appendChild(sec3);
sec3.name = "ALUR 3 — JELAJAH JAWA & 35 WILAYAH (4 Screens)";
sec3.x = 2620;
sec3.y = 1200;
sec3.resizeWithoutConstraints(2060, 1550);

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

addBottomNavBar(s20, 1);
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