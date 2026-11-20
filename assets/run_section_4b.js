
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

const javaraPage = figma.root.children.find(p => p.name === "Javara");
const sec4 = javaraPage.children.find(c => c.name && c.name.startsWith("ALUR 4"));
let s4x = 60 + 492 * 4;
const y4Pos = 80;
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