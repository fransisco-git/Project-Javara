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


// 18 — Paspor Budaya Digital (Current APK)
const s18 = figma.createFrame();
javaraPage.appendChild(s18);
s18.name = "18 — Paspor Budaya Digital (Current APK)";
s18.x = 100;
s18.y = 2550;
s18.resize(412, 1100);
s18.fills = solidPaint("#F4E9D8");
s18.cornerRadius = 28;
s18.clipsContent = true;

addStatusBar(s18, false);
addBackButton(s18);
addText(s18, { text: "Paspor Budaya Jawa", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Vintage Passport Cover Card
const passCover = figma.createFrame();
s18.appendChild(passCover);
passCover.name = "Buku Paspor Perkamen Kuno";
passCover.x = 24; passCover.y = 100; passCover.resize(364, 210);
passCover.fills = solidPaint("#241711"); // Leather dark
passCover.strokes = solidPaint("#C79B3A", 0.7); passCover.strokeWeight = 1.5;
passCover.cornerRadius = 16;
passCover.paddingLeft = 20; passCover.paddingTop = 16;

addText(passCover, { text: "PASPOR KHASANAH ADILUHUNG", x: 20, y: 16, size: 11, weight: "Bold", family: "Inter", color: "#C79B3A", letterSpacing: 2 });
addText(passCover, { text: "Raden Mas Arya", x: 20, y: 42, size: 22, weight: "Bold", family: "Lora", color: "#FFFBF4" });
addText(passCover, { text: "No. Registrasi: JVR-JTG-2026-088", x: 20, y: 72, size: 11, weight: "Regular", family: "Inter", color: "#D6C8B8" });

// Wax Seal Graphic
const seal = figma.createEllipse();
passCover.appendChild(seal);
seal.x = 260; seal.y = 20; seal.resize(76, 76);
seal.fills = solidPaint("#8F1D1D"); // Red wax seal
seal.strokes = solidPaint("#C79B3A", 0.6); seal.strokeWeight = 1.2;
addText(passCover, { text: "ꦗꦮꦫ", x: 276, y: 44, size: 14, weight: "Bold", family: "Inter", color: "#FFE8B3" });

addText(passCover, { text: "18 dari 35 Wilayah Terjelajahi • 850 Poin Ksatria", x: 20, y: 160, size: 12, weight: "Medium", family: "Lora", color: "#FFE8B3" });

// Wax Seals / Stamps Grid
addText(s18, { text: "Cap Stempel Eks-Karesidenan", x: 24, y: 330, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

const stamps = [
  { name: "Kasunanan Surakarta", reg: "Solo Raya", color: "#C79B3A", status: "TERKUMPUL" },
  { name: "Candi Borobudur", reg: "Kedu Raya", color: "#B5603A", status: "TERKUMPUL" },
  { name: "Gagrag Banyumasan", reg: "Banyumas", color: "#394B5B", status: "TERKUMPUL" },
  { name: "Kota Atlas Semarang", reg: "Semarang Raya", color: "#A89482", status: "TERKUNCI" }
];

let sy = 364;
for (const st of stamps) {
  const row = figma.createFrame();
  s18.appendChild(row);
  row.name = "Stamp: " + st.name;
  row.x = 24; row.y = sy; row.resize(364, 68);
  row.fills = solidPaint("#FFFBF4"); row.strokes = solidPaint("#E0C9A6"); row.strokeWeight = 1;
  row.cornerRadius = 12; row.paddingLeft = 16; row.paddingRight = 16;
  row.layoutMode = "HORIZONTAL"; row.primaryAxisAlignItems = "SPACE_BETWEEN"; row.counterAxisAlignItems = "CENTER";
  row.layoutSizingHorizontal = "FIXED"; row.layoutSizingVertical = "FIXED";

  const sCol = figma.createFrame();
  row.appendChild(sCol);
  sCol.resize(220, 48); sCol.fills = []; sCol.layoutMode = "VERTICAL"; sCol.primaryAxisAlignItems = "CENTER";
  addText(sCol, { text: st.name, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(sCol, { text: st.reg, size: 11, weight: "Regular", family: "Lora", color: "#6B5845" });

  const badge = figma.createFrame();
  row.appendChild(badge);
  badge.resize(90, 28); badge.fills = solidPaint(st.status === "TERKUMPUL" ? "#E3CDAB" : "#E8DED0");
  badge.cornerRadius = 6; badge.layoutMode = "HORIZONTAL"; badge.primaryAxisAlignItems = "CENTER"; badge.counterAxisAlignItems = "CENTER";
  addText(badge, { text: st.status, size: 10, weight: "Bold", family: "Inter", color: st.color });

  sy += 80;
}

// Download Button
const btnPdf = figma.createFrame();
s18.appendChild(btnPdf);
btnPdf.name = "Tombol Unduh Paspor";
btnPdf.x = 24; btnPdf.y = 710; btnPdf.resize(364, 52); btnPdf.fills = solidPaint("#3A261D"); btnPdf.cornerRadius = 12;
btnPdf.layoutMode = "HORIZONTAL"; btnPdf.primaryAxisAlignItems = "CENTER"; btnPdf.counterAxisAlignItems = "CENTER";
btnPdf.layoutSizingHorizontal = "FIXED"; btnPdf.layoutSizingVertical = "FIXED";
addText(btnPdf, { text: "📜  Unduh Paspor Budaya (Sertifikat PDF)", size: 14, weight: "Bold", family: "Lora", color: "#FFFBF4" });


// 19 — Swara Nusantara / Pemutar Musik Jawa (Current APK)
const s19 = figma.createFrame();
javaraPage.appendChild(s19);
s19.name = "19 — Swara Nusantara (Current APK)";
s19.x = 592;
s19.y = 2550;
s19.resize(412, 1100);
s19.fills = solidPaint("#2E2019"); // Royal dark velvet
s19.cornerRadius = 28;
s19.clipsContent = true;

addStatusBar(s19, true);
const btnBack19 = figma.createFrame();
s19.appendChild(btnBack19);
btnBack19.name = "Tombol Kembali"; btnBack19.x = 20; btnBack19.y = 52; btnBack19.resize(36, 36); btnBack19.fills = [];
addText(btnBack19, { text: "←", x: 6, y: 4, size: 22, weight: "Bold", family: "Inter", color: "#FFFBF4" });
addText(s19, { text: "Swara Nusantara", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#FFFBF4" });

// Vinyl Record Graphic
const vinyl = figma.createEllipse();
s19.appendChild(vinyl);
vinyl.name = "Piringan Hitam Vinyl";
vinyl.x = 96; vinyl.y = 120; vinyl.resize(220, 220);
vinyl.fills = solidPaint("#14100D");
vinyl.strokes = solidPaint("#C79B3A", 0.5); vinyl.strokeWeight = 2;

const vGroove1 = figma.createEllipse();
s19.appendChild(vGroove1);
vGroove1.x = 126; vGroove1.y = 150; vGroove1.resize(160, 160);
vGroove1.fills = []; vGroove1.strokes = solidPaint("#30251F"); vGroove1.strokeWeight = 1;

const vCenter = figma.createEllipse();
s19.appendChild(vCenter);
vCenter.x = 171; vCenter.y = 195; vCenter.resize(70, 70);
vCenter.fills = solidPaint("#C79B3A");
addText(s19, { text: "ꦗꦮꦫ", x: 184, y: 218, size: 14, weight: "Bold", family: "Inter", color: "#2E2019" });

// Song Title & Artist
addText(s19, { text: "Ladrang Pangkur Slendro Sanga", x: 24, y: 375, width: 364, size: 20, weight: "Bold", family: "Lora", color: "#FFDF9E", align: "CENTER" });
addText(s19, { text: "Karawitan Keraton Kasunanan Surakarta", x: 24, y: 405, width: 364, size: 13, weight: "Regular", family: "Lora", color: "#D6C8B8", align: "CENTER" });

// Progress Bar & Duration
addRect(s19, { x: 36, y: 460, width: 340, height: 4, fill: "#463428", radius: 2, name: "Audio Track" });
addRect(s19, { x: 36, y: 460, width: 150, height: 4, fill: "#C79B3A", radius: 2, name: "Audio Progress" });
addText(s19, { text: "02:18", x: 36, y: 472, size: 11, weight: "Regular", family: "Inter", color: "#A89482" });
addText(s19, { text: "05:40", x: 340, y: 472, size: 11, weight: "Regular", family: "Inter", color: "#A89482" });

// Media Controls Row
const ctrlRow = figma.createFrame();
s19.appendChild(ctrlRow);
ctrlRow.name = "Media Controls Row";
ctrlRow.x = 36; ctrlRow.y = 510; ctrlRow.resize(340, 70); ctrlRow.fills = [];
ctrlRow.layoutMode = "HORIZONTAL"; ctrlRow.primaryAxisAlignItems = "SPACE_EVENLY"; ctrlRow.counterAxisAlignItems = "CENTER";
ctrlRow.layoutSizingHorizontal = "FIXED"; ctrlRow.layoutSizingVertical = "FIXED";

addText(ctrlRow, { text: "🔀", size: 18, weight: "Regular", family: "Inter", color: "#D6C8B8" });
addText(ctrlRow, { text: "⏮", size: 22, weight: "Regular", family: "Inter", color: "#FFFBF4" });

const playBtn = figma.createEllipse();
ctrlRow.appendChild(playBtn);
playBtn.resize(56, 56); playBtn.fills = solidPaint("#C79B3A");
addText(s19, { text: "⏸", x: 194, y: 532, size: 22, weight: "Bold", family: "Inter", color: "#2E2019" });

addText(ctrlRow, { text: "⏭", size: 22, weight: "Regular", family: "Inter", color: "#FFFBF4" });
addText(ctrlRow, { text: "🔁", size: 18, weight: "Regular", family: "Inter", color: "#D6C8B8" });

// Karaoke Lyrics Preview Box
const lBox = figma.createFrame();
s19.appendChild(lBox);
lBox.name = "Karaoke Lyrics Box";
lBox.x = 24; lBox.y = 610; lBox.resize(364, 150);
lBox.fills = solidPaint("#1E1528", 0.7); lBox.strokes = solidPaint("#C79B3A", 0.3); lBox.strokeWeight = 1;
lBox.cornerRadius = 14; lBox.paddingLeft = 20; lBox.paddingRight = 20; lBox.paddingTop = 16;
addText(lBox, { text: "Lirik Gendhing Berjalan", x: 20, y: 16, size: 12, weight: "Bold", family: "Lora", color: "#C79B3A" });
addText(lBox, { text: "Mingkar-mingkuring angkara, akarana karenan mardi siwi...", x: 20, y: 44, width: 324, size: 14, weight: "Bold", family: "Lora", color: "#FFFBF4", lineSpacing: 22 });
addText(lBox, { text: "Sinawung resmining kidung, sinuba sinukarta...", x: 20, y: 94, width: 324, size: 13, weight: "Regular", family: "Lora", color: "#A89482", lineSpacing: 20 });


// 20 — Sanggar Aksara Jawa (Current APK)
const s20 = figma.createFrame();
javaraPage.appendChild(s20);
s20.name = "20 — Sanggar Aksara Jawa (Current APK)";
s20.x = 1084;
s20.y = 2550;
s20.resize(412, 1100);
s20.fills = solidPaint("#F4E9D8");
s20.cornerRadius = 28;
s20.clipsContent = true;

addStatusBar(s20, false);
addBackButton(s20);
addText(s20, { text: "Sanggar Aksara Jawa", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Transliterator Card
const transCard = figma.createFrame();
s20.appendChild(transCard);
transCard.name = "Transliterator Box";
transCard.x = 24; transCard.y = 100; transCard.resize(364, 180);
transCard.fills = solidPaint("#FFFBF4"); transCard.strokes = solidPaint("#E0C9A6"); transCard.strokeWeight = 1.2;
transCard.cornerRadius = 16; transCard.paddingLeft = 18; transCard.paddingTop = 14;

addText(transCard, { text: "Teks Latin:", x: 18, y: 14, size: 11, weight: "Bold", family: "Inter", color: "#6B5845" });
addText(transCard, { text: "Javara Jawa Tengah", x: 18, y: 32, size: 15, weight: "Medium", family: "Lora", color: "#2B1A12" });
addRect(transCard, { x: 18, y: 64, width: 328, height: 1, fill: "#E0C9A6", name: "Divider" });

addText(transCard, { text: "Transliterasi Aksara Jawa:", x: 18, y: 78, size: 11, weight: "Bold", family: "Inter", color: "#B5603A" });
addText(transCard, { text: "ꦗꦮ꦳ꦫ ꦗꦮ ꦠꦼꦔꦃ", x: 18, y: 102, size: 24, weight: "Bold", family: "Inter", color: "#C79B3A", letterSpacing: 4 });
addText(transCard, { text: "📋 Salin Aksara", x: 260, y: 145, size: 11, weight: "Bold", family: "Lora", color: "#3A261D" });

// 20 Aksara Jawa Hanacaraka Grid
addText(s20, { text: "20 Aksara Hanacaraka & Filosofi", x: 24, y: 300, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

const glyphs = [
  { j: "ꦲ", l: "Ha" }, { j: "ꦤ", l: "Na" }, { j: "ꦕ", l: "Ca" }, { j: "ꦫ", l: "Ra" }, { j: "ꦏ", l: "Ka" },
  { j: "ꦢ", l: "Da" }, { j: "ꦠ", l: "Ta" }, { j: "ꦱ", l: "Sa" }, { j: "ꦮ", l: "Wa" }, { j: "ꦭ", l: "La" },
  { j: "ꦥ", l: "Pa" }, { j: "ꦝ", l: "Dha" }, { j: "ꦗ", l: "Ja" }, { j: "ꦪ", l: "Ya" }, { j: "ꦚ", l: "Nya" },
  { j: "ꦩ", l: "Ma" }, { j: "ꦒ", l: "Ga" }, { j: "ꦧ", l: "Ba" }, { j: "ꦛ", l: "Tha" }, { j: "ꦔ", l: "Nga" }
];

let gx = 24, gy = 334;
for (let i = 0; i < glyphs.length; i++) {
  const gl = glyphs[i];
  const gBox = figma.createFrame();
  s20.appendChild(gBox);
  gBox.name = "Glyph: " + gl.l;
  gBox.x = gx; gBox.y = gy; gBox.resize(65, 65);
  gBox.fills = solidPaint("#FFFBF4"); gBox.strokes = solidPaint("#E0C9A6"); gBox.strokeWeight = 1;
  gBox.cornerRadius = 10;
  gBox.layoutMode = "VERTICAL"; gBox.primaryAxisAlignItems = "CENTER"; gBox.counterAxisAlignItems = "CENTER";
  gBox.layoutSizingHorizontal = "FIXED"; gBox.layoutSizingVertical = "FIXED";
  addText(gBox, { text: gl.j, size: 20, weight: "Bold", family: "Inter", color: "#2B1A12" });
  addText(gBox, { text: gl.l, size: 10, weight: "Medium", family: "Lora", color: "#B5603A" });

  if ((i + 1) % 5 === 0) {
    gx = 24; gy += 75;
  } else {
    gx += 75;
  }
}

// Ajisaka Quote
addText(s20, { text: "Hana caraka, data sawala, pada jayanya, maga bathanga.", x: 24, y: 660, width: 364, size: 13, weight: "Bold", family: "Lora", color: "#3A261D", align: "CENTER" });


// 21 — Galeri Motif Batik Jawa (Current APK)
const s21 = figma.createFrame();
javaraPage.appendChild(s21);
s21.name = "21 — Galeri Motif Batik (Current APK)";
s21.x = 1576;
s21.y = 2550;
s21.resize(412, 1100);
s21.fills = solidPaint("#F4E9D8");
s21.cornerRadius = 28;
s21.clipsContent = true;

addStatusBar(s21, false);
addBackButton(s21);
addText(s21, { text: "Galeri Motif Batik", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });

// High-Res Batik Photo
addRect(s21, { x: 24, y: 100, width: 364, height: 260, radius: 16, imageHash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237", stroke: "#E0C9A6", strokeWidth: 1, name: "Foto Motif Batik" });

// Title & Script
addText(s21, { text: "Batik Parang Barong Solo", x: 24, y: 380, size: 22, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s21, { text: "ꦥꦫꦁꦧꦫꦺꦴꦁ  •  Kasunanan Surakarta", x: 24, y: 410, size: 14, weight: "Bold", family: "Inter", color: "#C79B3A" });

const bTagRow = figma.createFrame();
s21.appendChild(bTagRow);
bTagRow.x = 24; bTagRow.y = 440; bTagRow.resize(364, 30); bTagRow.fills = [];
bTagRow.layoutMode = "HORIZONTAL"; bTagRow.itemSpacing = 8;
const bTags = ["Batik Awisan Dalem", "Motif Larangan", "Pewarna Alami Soga"];
for (const bt of bTags) {
  const f = figma.createFrame();
  bTagRow.appendChild(f);
  f.resize(110, 28); f.fills = solidPaint("#3A261D"); f.cornerRadius = 6;
  f.layoutMode = "HORIZONTAL"; f.primaryAxisAlignItems = "CENTER"; f.counterAxisAlignItems = "CENTER";
  f.layoutSizingHorizontal = "FIXED"; f.layoutSizingVertical = "FIXED";
  addText(f, { text: bt, size: 9.5, weight: "Bold", family: "Lora", color: "#FFFBF4" });
}

addText(s21, { text: "Filosofi Ksatria Karang Samudra", x: 24, y: 490, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s21, { text: "Pola lereng diagonal menyerupai ombak karang laut selatan yang tak pernah putus menabrak tebing, melambangkan watak ksatria yang pantang menyerah dalam menegakkan kebajikan semesta.", x: 24, y: 516, width: 364, size: 13, weight: "Regular", family: "Lora", color: "#463428", lineSpacing: 20 });

addText(s21, { text: "Asal-Usul Sejarah", x: 24, y: 620, size: 16, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s21, { text: "Diciptakan Sultan Agung Hanyakrakusuma di Mataram Islam abad ke-17 saat bermeditasi di pesisir Pantai Parangkusumo.", x: 24, y: 646, width: 364, size: 13, weight: "Regular", family: "Lora", color: "#463428", lineSpacing: 20 });


// 22 — Studio Busana Virtual 3D & Try-On (Current APK)
const s22 = figma.createFrame();
javaraPage.appendChild(s22);
s22.name = "22 — Studio Virtual 3D (Current APK)";
s22.x = 2068;
s22.y = 2550;
s22.resize(412, 1100);
s22.fills = solidPaint("#14100D"); // Dark studio viewport
s22.cornerRadius = 28;
s22.clipsContent = true;

addStatusBar(s22, true);
const btnBack22 = figma.createFrame();
s22.appendChild(btnBack22);
btnBack22.x = 20; btnBack22.y = 52; btnBack22.resize(36, 36); btnBack22.fills = [];
addText(btnBack22, { text: "←", x: 6, y: 4, size: 22, weight: "Bold", family: "Inter", color: "#FFFBF4" });
addText(s22, { text: "Studio Busana 3D Decart AI", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#FFFBF4" });

// Viewport Frame Guide
addRect(s22, { x: 24, y: 100, width: 364, height: 480, radius: 20, fill: "#241711", stroke: "#C79B3A", strokeWidth: 1.5, name: "Viewport 3D" });

// Model Avatar / Garment Model
addRect(s22, { x: 50, y: 120, width: 312, height: 440, imageHash: "1fbfe49e615479b943ef56617243e3376418a136", radius: 14, name: "Peraga Busana 3D" });

// 3D Controls Overlay
const rot360 = figma.createFrame();
s22.appendChild(rot360);
rot360.x = 40; rot360.y = 520; rot360.resize(110, 36); rot360.fills = solidPaint("#000000", 0.7); rot360.cornerRadius = 8;
rot360.layoutMode = "HORIZONTAL"; rot360.primaryAxisAlignItems = "CENTER"; rot360.counterAxisAlignItems = "CENTER";
rot360.layoutSizingHorizontal = "FIXED"; rot360.layoutSizingVertical = "FIXED";
addText(rot360, { text: "🔄 Putar 360°", size: 11, weight: "Bold", family: "Inter", color: "#FFDF9E" });

// Wardrobe Drawer at bottom
const drawer = figma.createFrame();
s22.appendChild(drawer);
drawer.name = "Wardrobe Drawer";
drawer.x = 0; drawer.y = 610; drawer.resize(412, 490);
drawer.fills = solidPaint("#2E2019"); drawer.cornerRadius = 24; drawer.paddingLeft = 24; drawer.paddingTop = 18;

addRect(drawer, { x: 186, y: 10, width: 40, height: 4, fill: "#6B5845", radius: 2, name: "Handle" });
addText(drawer, { text: "Pilih Busana untuk Dicoba", x: 24, y: 28, size: 16, weight: "Bold", family: "Lora", color: "#FFDF9E" });

// Garment Chips Row
const wChips = [
  { name: "Kebaya Kartini", hash: "1fbfe49e615479b943ef56617243e3376418a136", active: true },
  { name: "Batik Parang", hash: "a542f0b115f4d328d99513ae1e5c0ffe4b501237", active: false },
  { name: "Solo Basahan", hash: "7e93353d53942a440b72c1e52db5d5e35d2cdb60", active: false }
];

let cx = 24;
for (const ch of wChips) {
  const cCard = figma.createFrame();
  drawer.appendChild(cCard);
  cCard.x = cx; cCard.y = 66; cCard.resize(110, 140);
  cCard.fills = solidPaint("#1E1528"); cCard.strokes = solidPaint(ch.active ? "#C79B3A" : "#463428"); cCard.strokeWeight = ch.active ? 2 : 1;
  cCard.cornerRadius = 12; cCard.clipsContent = true;
  addRect(cCard, { x: 0, y: 0, width: 110, height: 95, imageHash: ch.hash, name: "Foto Garment" });
  addText(cCard, { text: ch.name, x: 8, y: 105, width: 94, size: 10, weight: "Bold", family: "Lora", color: "#FFFBF4" });
  cx += 122;
}

// Action Button in Drawer
const btnSaveTry = figma.createFrame();
drawer.appendChild(btnSaveTry);
btnSaveTry.x = 24; btnSaveTry.y = 230; btnSaveTry.resize(364, 52); btnSaveTry.fills = solidPaint("#C79B3A"); btnSaveTry.cornerRadius = 12;
btnSaveTry.layoutMode = "HORIZONTAL"; btnSaveTry.primaryAxisAlignItems = "CENTER"; btnSaveTry.counterAxisAlignItems = "CENTER";
btnSaveTry.layoutSizingHorizontal = "FIXED"; btnSaveTry.layoutSizingVertical = "FIXED";
addText(btnSaveTry, { text: "📸 Simpan & Bagikan Hasil Try-On", size: 14, weight: "Bold", family: "Lora", color: "#261808" });


// 23 — Bottom Sheet Sewa Busana (Current APK)
const s23 = figma.createFrame();
javaraPage.appendChild(s23);
s23.name = "23 — Bottom Sheet Sewa Busana (Current APK)";
s23.x = 2560;
s23.y = 2550;
s23.resize(412, 1100);
s23.fills = solidPaint("#F4E9D8");
s23.cornerRadius = 28;
s23.clipsContent = true;

// Dimmed Scrim
addStatusBar(s23, false);
const scrim23 = figma.createRectangle();
s23.appendChild(scrim23);
scrim23.x = 0; scrim23.y = 0; scrim23.resize(412, 1100);
scrim23.fills = solidPaint("#000000", 0.65);

// Bottom Sheet Frame
const bs = figma.createFrame();
s23.appendChild(bs);
bs.name = "Cultural Order Sheet";
bs.x = 0; bs.y = 420; bs.resize(412, 680);
bs.fills = solidPaint("#FFFBF4"); bs.cornerRadius = 24; bs.paddingLeft = 24; bs.paddingRight = 24; bs.paddingTop = 16;

addRect(bs, { x: 186, y: 10, width: 40, height: 4, fill: "#E0C9A6", radius: 2, name: "Handle" });
addText(bs, { text: "Sewa Busana Adat Keraton", x: 24, y: 30, size: 20, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(bs, { text: "Kebaya Kartini Solo Sutra Bordir Emas", x: 24, y: 58, size: 14, weight: "Medium", family: "Lora", color: "#B5603A" });

// Rent Duration Box
const durBox = figma.createFrame();
bs.appendChild(durBox);
durBox.x = 24; durBox.y = 96; durBox.resize(364, 60); durBox.fills = solidPaint("#F4E9D8"); durBox.cornerRadius = 12;
durBox.paddingLeft = 16; durBox.paddingRight = 16;
durBox.layoutMode = "HORIZONTAL"; durBox.primaryAxisAlignItems = "SPACE_BETWEEN"; durBox.counterAxisAlignItems = "CENTER";
durBox.layoutSizingHorizontal = "FIXED"; durBox.layoutSizingVertical = "FIXED";
addText(durBox, { text: "Durasi Sewa: 3 Hari (20 - 22 Nov)", size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(durBox, { text: "Ubah", size: 12, weight: "Bold", family: "Lora", color: "#3A261D" });

// Size Selector
addText(bs, { text: "Pilih Ukuran:", x: 24, y: 175, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
const szRow = figma.createFrame();
bs.appendChild(szRow);
szRow.x = 24; szRow.y = 205; szRow.resize(364, 40); szRow.fills = [];
szRow.layoutMode = "HORIZONTAL"; szRow.itemSpacing = 10;
const sizes = [
  { s: "S", act: false },
  { s: "M", act: true },
  { s: "L", act: false },
  { s: "XL", act: false },
  { s: "Kustom", act: false }
];
for (const sz of sizes) {
  const b = figma.createFrame();
  szRow.appendChild(b);
  b.resize(sz.s === "Kustom" ? 80 : 54, 40);
  b.fills = solidPaint(sz.act ? "#3A261D" : "#E3CDAB");
  b.cornerRadius = 8;
  b.layoutMode = "HORIZONTAL"; b.primaryAxisAlignItems = "CENTER"; b.counterAxisAlignItems = "CENTER";
  b.layoutSizingHorizontal = "FIXED"; b.layoutSizingVertical = "FIXED";
  addText(b, { text: sz.s, size: 13, weight: sz.act ? "Bold" : "Medium", family: "Lora", color: sz.act ? "#FFFBF4" : "#2B1A12" });
}

// Cost Summary Box
const costBox = figma.createFrame();
bs.appendChild(costBox);
costBox.x = 24; costBox.y = 275; costBox.resize(364, 90); costBox.fills = solidPaint("#F4E9D8"); costBox.cornerRadius = 12;
costBox.paddingLeft = 18; costBox.paddingRight = 18; costBox.paddingTop = 14;
addText(costBox, { text: "Total Biaya Sewa:", x: 18, y: 14, size: 12, weight: "Regular", family: "Lora", color: "#6B5845" });
addText(costBox, { text: "Rp 350.000", x: 18, y: 34, size: 24, weight: "Bold", family: "Inter", color: "#B08D57" });
addText(costBox, { text: "Termasuk kain jarik & selop", x: 18, y: 64, size: 11, weight: "Regular", family: "Lora", color: "#6B5845" });

// Checkout Button
const btnPay = figma.createFrame();
bs.appendChild(btnPay);
btnPay.x = 24; btnPay.y = 390; btnPay.resize(364, 52); btnPay.fills = solidPaint("#3A261D"); btnPay.cornerRadius = 12;
btnPay.layoutMode = "HORIZONTAL"; btnPay.primaryAxisAlignItems = "CENTER"; btnPay.counterAxisAlignItems = "CENTER";
btnPay.layoutSizingHorizontal = "FIXED"; btnPay.layoutSizingVertical = "FIXED";
addText(btnPay, { text: "Lanjutkan ke Pembayaran →", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });

return "Screens 18 through 23 created successfully!";