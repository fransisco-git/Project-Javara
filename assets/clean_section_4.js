
await Promise.all([
  figma.loadFontAsync({ family: "Inter", style: "Regular" }),
  figma.loadFontAsync({ family: "Inter", style: "Medium" }),
  figma.loadFontAsync({ family: "Inter", style: "Bold" }),
  figma.loadFontAsync({ family: "Lora", style: "Regular" }),
  figma.loadFontAsync({ family: "Lora", style: "Bold" })
]);
const javaraPage = figma.root.children.find(p => p.name === 'Javara');

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

function addBottomNavBar(frame, activeIndex = 2) {
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

function addBackButton(frame, isLight = false) {
  const btn = figma.createFrame();
  frame.appendChild(btn);
  btn.name = "Tombol Kembali";
  btn.x = 20;
  btn.y = 52;
  btn.resize(36, 36);
  btn.fills = [];
  addText(btn, { text: "←", x: 6, y: 4, size: 22, weight: "Bold", family: "Inter", color: isLight ? "#FFFBF4" : "#2B1A12" });
  return btn;
}

// ==========================================
// SECTION 4: WARDROBE & 3D VIRTUAL TRY-ON
// ==========================================
const sec4 = figma.createSection();
javaraPage.appendChild(sec4);
sec4.name = "ALUR 4 — WARDROBE & 3D VIRTUAL TRY-ON (8 Screens)";
sec4.x = 0;
sec4.y = 2900;
sec4.resizeWithoutConstraints(4200, 1600);

let s4x = 60;
const y4Pos = 80;

// Helper for Clean Wardrobe Header (No AI Slop long text as requested by user)
function addWardrobeHeader(s, activeGender = "Semua", activeCategory = "Semua") {
  addStatusBar(s, false);
  
  // Header title bar
  addText(s, { text: "Busana Adat Jawa", x: 24, y: 64, size: 24, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(s, { text: "👜", x: 360, y: 64, size: 20, family: "Inter", color: "#2B1A12" });

  // Clean Carousel Banner (Without redundant text)
  const banner = figma.createFrame();
  s.appendChild(banner);
  banner.name = "Banner Busana 3D";
  banner.x = 24; banner.y = 104; banner.resize(364, 120);
  banner.fills = solidPaint("#1F150E");
  banner.strokes = solidPaint("#C79B3A", 0.6);
  banner.strokeWeight = 1.2;
  banner.cornerRadius = 16;
  banner.paddingLeft = 18; banner.paddingTop = 14;

  addText(banner, { text: "👘  BUSANA TRADISIONAL 3D", x: 18, y: 14, size: 10, weight: "Bold", family: "Inter", color: "#DFB76C", letterSpacing: 2 });
  addText(banner, { text: "Koleksi Busana Adat Jawa Tengah", x: 18, y: 36, width: 320, size: 18, weight: "Bold", family: "Lora", color: "#FAF6F0", lineSpacing: 24 });

  // Elegant Carousel Dots
  const dotRow = figma.createFrame();
  banner.appendChild(dotRow);
  dotRow.x = 18; dotRow.y = 92; dotRow.resize(100, 10);
  dotRow.fills = []; dotRow.layoutMode = "HORIZONTAL"; dotRow.itemSpacing = 6;
  const dot1 = figma.createFrame(); dotRow.appendChild(dot1); dot1.resize(24, 6); dot1.fills = solidPaint("#DFB76C"); dot1.cornerRadius = 3;
  const dot2 = figma.createFrame(); dotRow.appendChild(dot2); dot2.resize(6, 6); dot2.fills = solidPaint("#463428"); dot2.cornerRadius = 3;
  const dot3 = figma.createFrame(); dotRow.appendChild(dot3); dot3.resize(6, 6); dot3.fills = solidPaint("#463428"); dot3.cornerRadius = 3;
  const dot4 = figma.createFrame(); dotRow.appendChild(dot4); dot4.resize(6, 6); dot4.fills = solidPaint("#463428"); dot4.cornerRadius = 3;

  // Gender Toggle (Semua / Wanita / Pria)
  const gToggle = figma.createFrame();
  s.appendChild(gToggle);
  gToggle.x = 24; gToggle.y = 240; gToggle.resize(364, 40);
  gToggle.fills = solidPaint("#E3CDAB"); gToggle.cornerRadius = 10;
  gToggle.layoutMode = "HORIZONTAL"; gToggle.paddingLeft = 4; gToggle.paddingRight = 4;
  gToggle.primaryAxisAlignItems = "SPACE_BETWEEN"; gToggle.counterAxisAlignItems = "CENTER";
  gToggle.layoutSizingHorizontal = "FIXED"; gToggle.layoutSizingVertical = "FIXED";

  const genders = ["Semua", "Wanita", "Pria"];
  for (const g of genders) {
    const isG = g === activeGender;
    const gb = figma.createFrame(); gToggle.appendChild(gb);
    gb.resize(114, 32);
    gb.fills = isG ? solidPaint("#3A261D") : [];
    if (isG) gb.cornerRadius = 8;
    gb.layoutMode = "HORIZONTAL"; gb.primaryAxisAlignItems = "CENTER"; gb.counterAxisAlignItems = "CENTER";
    gb.layoutSizingHorizontal = "FIXED"; gb.layoutSizingVertical = "FIXED";
    addText(gb, { text: g, size: 12, weight: isG ? "Bold" : "Medium", family: "Lora", color: isG ? "#FFFBF4" : "#2B1A12" });
  }

  // Category Chips
  const cRow = figma.createFrame();
  s.appendChild(cRow);
  cRow.x = 24; cRow.y = 294; cRow.resize(364, 34);
  cRow.fills = []; cRow.layoutMode = "HORIZONTAL"; cRow.itemSpacing = 8;
  const cats = ["Semua", "Keraton", "Rakyat", "Bisa Disewa"];
  for (const c of cats) {
    const isC = c === activeCategory;
    const cb = figma.createFrame(); cRow.appendChild(cb);
    cb.resize(c === "Bisa Disewa" ? 96 : 74, 32);
    cb.fills = isC ? solidPaint("#3A261D") : solidPaint("#FFFBF4");
    cb.strokes = solidPaint(isC ? "#3A261D" : "#E0C9A6"); cb.strokeWeight = 1;
    cb.cornerRadius = 8;
    cb.layoutMode = "HORIZONTAL"; cb.primaryAxisAlignItems = "CENTER"; cb.counterAxisAlignItems = "CENTER";
    cb.layoutSizingHorizontal = "FIXED"; cb.layoutSizingVertical = "FIXED";
    addText(cb, { text: c, size: 11, weight: isC ? "Bold" : "Medium", family: "Lora", color: isC ? "#FFFBF4" : "#2B1A12" });
  }
}

// 24 — Wardrobe Utama
const s24 = figma.createFrame(); sec4.appendChild(s24); s24.name = "24 — Wardrobe Utama (Current APK)"; s24.x = s4x; s24.y = y4Pos; s24.resize(412, 1380); s24.fills = solidPaint("#F4E9D8"); s24.cornerRadius = 28; s24.clipsContent = true;
addWardrobeHeader(s24, "Semua", "Semua");

// Garment 1: Kebaya Kartini
const gc1 = figma.createFrame(); s24.appendChild(gc1); gc1.x = 24; gc1.y = 350; gc1.resize(174, 250); gc1.fills = solidPaint("#FFFBF4"); gc1.strokes = solidPaint("#E0C9A6"); gc1.strokeWeight = 1; gc1.cornerRadius = 14; gc1.clipsContent = true;
addRect(gc1, { x: 0, y: 0, width: 174, height: 140, imageHash: "1fbfe49e615479b943ef56617243e3376418a136" });
addText(gc1, { text: "Kebaya Kartini Solo", x: 12, y: 150, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(gc1, { text: "Wanita • Keraton", x: 12, y: 172, size: 10.5, family: "Lora", color: "#6B5845" });
addText(gc1, { text: "Rp 350.000 / hari", x: 12, y: 196, size: 12, weight: "Bold", family: "Inter", color: "#B08D57" });
const btnTry1 = figma.createFrame(); gc1.appendChild(btnTry1); btnTry1.x = 12; btnTry1.y = 218; btnTry1.resize(150, 26); btnTry1.fills = solidPaint("#3A261D"); btnTry1.cornerRadius = 6; btnTry1.layoutMode = "HORIZONTAL"; btnTry1.primaryAxisAlignItems = "CENTER"; btnTry1.counterAxisAlignItems = "CENTER"; btnTry1.layoutSizingHorizontal = "FIXED"; btnTry1.layoutSizingVertical = "FIXED";
addText(btnTry1, { text: "✨ Virtual Try-On", size: 10, weight: "Bold", family: "Inter", color: "#FFFBF4" });

// Garment 2: Beskap Landhung
const gc2 = figma.createFrame(); s24.appendChild(gc2); gc2.x = 214; gc2.y = 350; gc2.resize(174, 250); gc2.fills = solidPaint("#FFFBF4"); gc2.strokes = solidPaint("#E0C9A6"); gc2.strokeWeight = 1; gc2.cornerRadius = 14; gc2.clipsContent = true;
addRect(gc2, { x: 0, y: 0, width: 174, height: 140, imageHash: "7e93353d53942a440b72c1e52db5d5e35d2cdb60" });
addText(gc2, { text: "Beskap Landhung", x: 12, y: 150, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(gc2, { text: "Pria • Keraton Solo", x: 12, y: 172, size: 10.5, family: "Lora", color: "#6B5845" });
addText(gc2, { text: "Rp 375.000 / hari", x: 12, y: 196, size: 12, weight: "Bold", family: "Inter", color: "#B08D57" });
const btnTry2 = figma.createFrame(); gc2.appendChild(btnTry2); btnTry2.x = 12; btnTry2.y = 218; btnTry2.resize(150, 26); btnTry2.fills = solidPaint("#3A261D"); btnTry2.cornerRadius = 6; btnTry2.layoutMode = "HORIZONTAL"; btnTry2.primaryAxisAlignItems = "CENTER"; btnTry2.counterAxisAlignItems = "CENTER"; btnTry2.layoutSizingHorizontal = "FIXED"; btnTry2.layoutSizingVertical = "FIXED";
addText(btnTry2, { text: "✨ Virtual Try-On", size: 10, weight: "Bold", family: "Inter", color: "#FFFBF4" });

// Garment 3: Surjan Lurik
const gc3 = figma.createFrame(); s24.appendChild(gc3); gc3.x = 24; gc3.y = 615; gc3.resize(174, 250); gc3.fills = solidPaint("#FFFBF4"); gc3.strokes = solidPaint("#E0C9A6"); gc3.strokeWeight = 1; gc3.cornerRadius = 14; gc3.clipsContent = true;
addRect(gc3, { x: 0, y: 0, width: 174, height: 140, imageHash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237" });
addText(gc3, { text: "Surjan Lurik Pranakan", x: 12, y: 150, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(gc3, { text: "Pria • Abdi Dalem", x: 12, y: 172, size: 10.5, family: "Lora", color: "#6B5845" });
addText(gc3, { text: "Rp 250.000 / hari", x: 12, y: 196, size: 12, weight: "Bold", family: "Inter", color: "#B08D57" });

// Garment 4: Solo Basahan
const gc4 = figma.createFrame(); s24.appendChild(gc4); gc4.x = 214; gc4.y = 615; gc4.resize(174, 250); gc4.fills = solidPaint("#FFFBF4"); gc4.strokes = solidPaint("#E0C9A6"); gc4.strokeWeight = 1; gc4.cornerRadius = 14; gc4.clipsContent = true;
addRect(gc4, { x: 0, y: 0, width: 174, height: 140, imageHash: "1fbfe49e615479b943ef56617243e3376418a136" });
addText(gc4, { text: "Solo Basahan Putri", x: 12, y: 150, width: 150, size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(gc4, { text: "Wanita • Pengantin Keraton", x: 12, y: 172, size: 10.5, family: "Lora", color: "#6B5845" });
addText(gc4, { text: "Rp 650.000 / hari", x: 12, y: 196, size: 12, weight: "Bold", family: "Inter", color: "#B08D57" });

addBottomNavBar(s24, 2);
s4x += 492;

// 25 — Wardrobe Filter Wanita
const s25 = figma.createFrame(); sec4.appendChild(s25); s25.name = "25 — Wardrobe Filter Wanita (Current APK)"; s25.x = s4x; s25.y = y4Pos; s25.resize(412, 1380); s25.fills = solidPaint("#F4E9D8"); s25.cornerRadius = 28; s25.clipsContent = true;
addWardrobeHeader(s25, "Wanita", "Keraton");
addText(s25, { text: "Menampilkan 6 Busana Adat Wanita", x: 24, y: 345, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addBottomNavBar(s25, 2);
s4x += 492;

// 26 — Wardrobe Filter Pria
const s26 = figma.createFrame(); sec4.appendChild(s26); s26.name = "26 — Wardrobe Filter Pria (Current APK)"; s26.x = s4x; s26.y = y4Pos; s26.resize(412, 1380); s26.fills = solidPaint("#F4E9D8"); s26.cornerRadius = 28; s26.clipsContent = true;
addWardrobeHeader(s26, "Pria", "Keraton");
addText(s26, { text: "Menampilkan 8 Busana Adat Pria", x: 24, y: 345, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addBottomNavBar(s26, 2);
s4x += 492;

// 27 — Wardrobe Filter Bisa Disewa
const s27 = figma.createFrame(); sec4.appendChild(s27); s27.name = "27 — Wardrobe Filter Bisa Disewa (Current APK)"; s27.x = s4x; s27.y = y4Pos; s27.resize(412, 1380); s27.fills = solidPaint("#F4E9D8"); s27.cornerRadius = 28; s27.clipsContent = true;
addWardrobeHeader(s27, "Semua", "Bisa Disewa");
addText(s27, { text: "Koleksi Busana Siap Sewa (12 Pilihan)", x: 24, y: 345, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addBottomNavBar(s27, 2);
s4x += 492;

// 28 — Detail Busana Kebaya Kartini
const s28 = figma.createFrame(); sec4.appendChild(s28); s28.name = "28 — Detail Busana Kebaya Kartini Solo (Current APK)"; s28.x = s4x; s28.y = y4Pos; s28.resize(412, 1380); s28.fills = solidPaint("#F4E9D8"); s28.cornerRadius = 28; s28.clipsContent = true;
addStatusBar(s28, false); addBackButton(s28);
addText(s28, { text: "Detail Busana Adat", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addRect(s28, { x: 24, y: 100, width: 364, height: 320, radius: 18, imageHash: "1fbfe49e615479b943ef56617243e3376418a136", stroke: "#E0C9A6", strokeWidth: 1 });
addText(s28, { text: "Kebaya Kartini Beludru Solo", x: 24, y: 440, size: 22, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s28, { text: "Pakem Ageng Busana Wanita Bangsawan Surakarta", x: 24, y: 470, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });
addText(s28, { text: "Rp 350.000 / hari  •  Tersedia Ukuran S, M, L, XL", x: 24, y: 494, size: 13, weight: "Bold", family: "Inter", color: "#B08D57" });

addText(s28, { text: "Filosofi & Ricikan Busana", x: 24, y: 535, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s28, { text: "Kebaya Kartini Solo melambangkan keanggunan, keteguhan hati, dan kesantunan wanita Jawa. Dibuat dari kain beludru hitam pekat berhias sulaman benang emas (bordir kawat) di sepanjang kerah kutubaru.", x: 24, y: 560, width: 364, size: 13, family: "Lora", color: "#463428", lineSpacing: 20 });

const btnGuide = figma.createFrame(); s28.appendChild(btnGuide); btnGuide.x = 24; btnGuide.y = 660; btnGuide.resize(364, 46); btnGuide.fills = solidPaint("#FFFBF4"); btnGuide.strokes = solidPaint("#E0C9A6"); btnGuide.strokeWeight = 1; btnGuide.cornerRadius = 10; btnGuide.paddingLeft = 14; btnGuide.paddingRight = 14; btnGuide.layoutMode = "HORIZONTAL"; btnGuide.primaryAxisAlignItems = "SPACE_BETWEEN"; btnGuide.counterAxisAlignItems = "CENTER"; btnGuide.layoutSizingHorizontal = "FIXED"; btnGuide.layoutSizingVertical = "FIXED";
addText(btnGuide, { text: "📏  Lihat Panduan Ukuran Keraton", size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(btnGuide, { text: "→", size: 16, family: "Inter", color: "#2B1A12" });

const btnVirtual = figma.createFrame(); s28.appendChild(btnVirtual); btnVirtual.x = 24; btnVirtual.y = 720; btnVirtual.resize(364, 52); btnVirtual.fills = solidPaint("#C79B3A"); btnVirtual.cornerRadius = 12; btnVirtual.layoutMode = "HORIZONTAL"; btnVirtual.primaryAxisAlignItems = "CENTER"; btnVirtual.counterAxisAlignItems = "CENTER"; btnVirtual.layoutSizingHorizontal = "FIXED"; btnVirtual.layoutSizingVertical = "FIXED";
addText(btnVirtual, { text: "✨ Coba di Virtual 3D Studio", size: 15, weight: "Bold", family: "Lora", color: "#261808" });

const btnRent = figma.createFrame(); s28.appendChild(btnRent); btnRent.x = 24; btnRent.y = 784; btnRent.resize(364, 52); btnRent.fills = solidPaint("#3A261D"); btnRent.cornerRadius = 12; btnRent.layoutMode = "HORIZONTAL"; btnRent.primaryAxisAlignItems = "CENTER"; btnRent.counterAxisAlignItems = "CENTER"; btnRent.layoutSizingHorizontal = "FIXED"; btnRent.layoutSizingVertical = "FIXED";
addText(btnRent, { text: "🛍️ Sewa Busana Sekarang", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });
s4x += 492;

// 29 — Panduan Ukuran Busana
const s29 = figma.createFrame(); sec4.appendChild(s29); s29.name = "29 — Panduan Ukuran Busana Keraton (Current APK)"; s29.x = s4x; s29.y = y4Pos; s29.resize(412, 1380); s29.fills = solidPaint("#F4E9D8"); s29.cornerRadius = 28; s29.clipsContent = true;
addStatusBar(s29, false); addBackButton(s29);
addText(s29, { text: "Panduan Ukuran Busana", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s29, { text: "Standar Ukuran Busana Keraton Solo", x: 24, y: 110, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s29, { text: "Gunakan pita ukur untuk mencocokkan postur tubuh Anda dengan pakem busana keraton.", x: 24, y: 134, width: 364, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });

// Size Table
const sTable = figma.createFrame(); s29.appendChild(sTable); sTable.x = 24; sTable.y = 180; sTable.resize(364, 240); sTable.fills = solidPaint("#FFFBF4"); sTable.strokes = solidPaint("#E0C9A6"); sTable.strokeWeight = 1; sTable.cornerRadius = 14; sTable.clipsContent = true;
addText(sTable, { text: "Ukuran", x: 16, y: 16, size: 12, weight: "Bold", family: "Inter", color: "#6B5845" });
addText(sTable, { text: "Lingkar Dada", x: 90, y: 16, size: 12, weight: "Bold", family: "Inter", color: "#6B5845" });
addText(sTable, { text: "Pinggang", x: 190, y: 16, size: 12, weight: "Bold", family: "Inter", color: "#6B5845" });
addText(sTable, { text: "Panjang", x: 280, y: 16, size: 12, weight: "Bold", family: "Inter", color: "#6B5845" });
addRect(sTable, { x: 0, y: 40, width: 364, height: 1, fill: "#E0C9A6" });

const sizes = [
  { s: "S", d: "84 - 88 cm", p: "68 - 72 cm", l: "128 cm" },
  { s: "M", d: "88 - 94 cm", p: "72 - 78 cm", l: "132 cm" },
  { s: "L", d: "94 - 100 cm", p: "78 - 84 cm", l: "136 cm" },
  { s: "XL", d: "100 - 108 cm", p: "84 - 92 cm", l: "140 cm" }
];
let ty = 54;
for (const sz of sizes) {
  addText(sTable, { text: sz.s, x: 16, y: ty, size: 13, weight: "Bold", family: "Inter", color: "#2B1A12" });
  addText(sTable, { text: sz.d, x: 90, y: ty, size: 12, family: "Inter", color: "#2B1A12" });
  addText(sTable, { text: sz.p, x: 190, y: ty, size: 12, family: "Inter", color: "#2B1A12" });
  addText(sTable, { text: sz.l, x: 280, y: ty, size: 12, family: "Inter", color: "#2B1A12" });
  ty += 44;
}
s4x += 492;

// 30 — Modal Bottom Sheet Sewa Busana
const s30 = figma.createFrame(); sec4.appendChild(s30); s30.name = "30 — Modal Bottom Sheet Sewa Busana (Current APK)"; s30.x = s4x; s30.y = y4Pos; s30.resize(412, 1380); s30.fills = solidPaint("#F4E9D8"); s30.cornerRadius = 28; s30.clipsContent = true;
addStatusBar(s30, false);
// Base screen background behind modal
addRect(s30, { x: 24, y: 100, width: 364, height: 320, radius: 18, imageHash: "1fbfe49e615479b943ef56617243e3376418a136" });
addRect(s30, { x: 0, y: 0, width: 412, height: 1380, fill: "#000000", opacity: 0.65, name: "Scrim" });

const rentSheet = figma.createFrame(); s30.appendChild(rentSheet); rentSheet.name = "Bottom Sheet Sewa"; rentSheet.x = 0; rentSheet.y = 780; rentSheet.resize(412, 600); rentSheet.fills = solidPaint("#FAF6EE"); rentSheet.cornerRadius = 28; rentSheet.paddingLeft = 24; rentSheet.paddingRight = 24; rentSheet.paddingTop = 20;
addRect(rentSheet, { x: 180, y: 12, width: 52, height: 5, fill: "#C8B69A", radius: 3 });
addText(rentSheet, { text: "Sewa Busana Adat", x: 24, y: 32, size: 20, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rentSheet, { text: "Kebaya Kartini Beludru Solo • Ukuran M", x: 24, y: 60, size: 13, family: "Lora", color: "#6B5845" });

addText(rentSheet, { text: "Pilih Durasi Sewa", x: 24, y: 100, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
const dRow = figma.createFrame(); rentSheet.appendChild(dRow); dRow.x = 24; dRow.y = 126; dRow.resize(364, 42); dRow.fills = []; dRow.layoutMode = "HORIZONTAL"; dRow.itemSpacing = 10;
for (const d of ["1 Hari (Rp 350k)", "3 Hari (Rp 900k)", "7 Hari (Rp 1.8M)"]) {
  const isD = d.startsWith("3 Hari");
  const db = figma.createFrame(); dRow.appendChild(db); db.resize(114, 40); db.fills = solidPaint(isD ? "#3A261D" : "#FFFBF4"); db.strokes = solidPaint(isD ? "#3A261D" : "#E0C9A6"); db.strokeWeight = 1; db.cornerRadius = 8; db.layoutMode = "HORIZONTAL"; db.primaryAxisAlignItems = "CENTER"; db.counterAxisAlignItems = "CENTER"; db.layoutSizingHorizontal = "FIXED"; db.layoutSizingVertical = "FIXED";
  addText(db, { text: d, size: 10.5, weight: isD ? "Bold" : "Medium", family: "Inter", color: isD ? "#FFFBF4" : "#2B1A12" });
}

addText(rentSheet, { text: "Total Biaya Sewa:", x: 24, y: 200, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(rentSheet, { text: "Rp 900.000", x: 270, y: 198, size: 18, weight: "Bold", family: "Inter", color: "#B08D57" });

const btnConfirmRent = figma.createFrame(); rentSheet.appendChild(btnConfirmRent); btnConfirmRent.x = 24; btnConfirmRent.y = 250; btnConfirmRent.resize(364, 52); btnConfirmRent.fills = solidPaint("#3A261D"); btnConfirmRent.cornerRadius = 12; btnConfirmRent.layoutMode = "HORIZONTAL"; btnConfirmRent.primaryAxisAlignItems = "CENTER"; btnConfirmRent.counterAxisAlignItems = "CENTER"; btnConfirmRent.layoutSizingHorizontal = "FIXED"; btnConfirmRent.layoutSizingVertical = "FIXED";
addText(btnConfirmRent, { text: "Lanjutkan ke Pembayaran →", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });
s4x += 492;

// 31 — Studio Busana Virtual 3D
const s31 = figma.createFrame(); sec4.appendChild(s31); s31.name = "31 — Studio Busana Virtual 3D Try-On (Current APK)"; s31.x = s4x; s31.y = y4Pos; s31.resize(412, 1380); s31.fills = solidPaint("#1F150E"); s31.cornerRadius = 28; s31.clipsContent = true;
addStatusBar(s31, true); addBackButton(s31, true);
addText(s31, { text: "Studio Busana 3D", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#FFFBF4" });

// 3D Viewport
const vp3d = figma.createFrame(); s31.appendChild(vp3d); vp3d.name = "3D Turntable Viewport"; vp3d.x = 24; vp3d.y = 100; vp3d.resize(364, 460); vp3d.fills = solidPaint("#120B07"); vp3d.strokes = solidPaint("#C79B3A", 0.5); vp3d.strokeWeight = 1.5; vp3d.cornerRadius = 20; vp3d.clipsContent = true;
addRect(vp3d, { x: 30, y: 30, width: 304, height: 400, imageHash: "1fbfe49e615479b943ef56617243e3376418a136" });
addText(vp3d, { text: "🔄 Putar 360° untuk melihat detail ricikan", x: 0, y: 420, width: 364, size: 11, family: "Inter", color: "#DFB76C", align: "CENTER" });

addText(s31, { text: "Lemari Busana Virtual", x: 24, y: 585, size: 16, weight: "Bold", family: "Lora", color: "#FAF6F0" });
const rackRow = figma.createFrame(); s31.appendChild(rackRow); rackRow.x = 24; rackRow.y = 615; rackRow.resize(364, 110); rackRow.fills = []; rackRow.layoutMode = "HORIZONTAL"; rackRow.itemSpacing = 12;
const garments3D = [
  { n: "Kebaya Kartini", hash: "1fbfe49e615479b943ef56617243e3376418a136" },
  { n: "Beskap Landhung", hash: "7e93353d53942a440b72c1e52db5d5e35d2cdb60" },
  { n: "Solo Basahan", hash: "1fbfe49e615479b943ef56617243e3376418a136" }
];
for (let i = 0; i < garments3D.length; i++) {
  const gb = figma.createFrame(); rackRow.appendChild(gb); gb.resize(110, 104); gb.fills = solidPaint("#2A1C14"); gb.strokes = solidPaint(i === 0 ? "#DFB76C" : "#463428"); gb.strokeWeight = i === 0 ? 1.5 : 1; gb.cornerRadius = 12; gb.clipsContent = true;
  addRect(gb, { x: 10, y: 8, width: 90, height: 60, imageHash: garments3D[i].hash });
  addText(gb, { text: garments3D[i].n, x: 0, y: 76, width: 110, size: 10, weight: "Bold", family: "Lora", color: i === 0 ? "#DFB76C" : "#D6C8B8", align: "CENTER" });
}

const btnSnap = figma.createFrame(); s31.appendChild(btnSnap); btnSnap.x = 24; btnSnap.y = 750; btnSnap.resize(364, 52); btnSnap.fills = solidPaint("#DFB76C"); btnSnap.cornerRadius = 12; btnSnap.layoutMode = "HORIZONTAL"; btnSnap.primaryAxisAlignItems = "CENTER"; btnSnap.counterAxisAlignItems = "CENTER"; btnSnap.layoutSizingHorizontal = "FIXED"; btnSnap.layoutSizingVertical = "FIXED";
addText(btnSnap, { text: "📸 Abadikan Foto dengan Busana Ini", size: 14, weight: "Bold", family: "Lora", color: "#261808" });

return "Section 4 created successfully!";