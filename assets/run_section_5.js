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

function addRect(parent, { x = 0, y = 0, width = 100, height = 100, fill = "#F4E9D8", opacity = 1, radius = 0, stroke = null, strokeWidth = 1, strokeOpacity = 1, name = "Rect" }) {
  const r = figma.createRectangle();
  parent.appendChild(r);
  r.name = name;
  r.x = x;
  r.y = y;
  r.resize(width, height);
  if (fill) {
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

function addBottomNavBar(frame, activeIndex = 3) {
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
// SECTION 5: SINAU BUDAYA & KUIS INTERAKTIF
// ==========================================
let sec5 = javaraPage.children.find(c => c.name && c.name.startsWith("ALUR 5"));
if (!sec5) {
  sec5 = figma.createSection();
  javaraPage.appendChild(sec5);
  sec5.name = "ALUR 5 — SINAU BUDAYA & KUIS INTERAKTIF (4 Screens)";
  sec5.x = 0;
  sec5.y = 4700;
  sec5.resizeWithoutConstraints(2100, 1550);
}

let s5x = 60;
const y5Pos = 80;

// 32 — Kuis Budaya: Pertanyaan Aktif
const s32 = figma.createFrame(); sec5.appendChild(s32); s32.name = "32 — Kuis Budaya: Pertanyaan Aktif (Current APK)"; s32.x = s5x; s32.y = y5Pos; s32.resize(412, 1380); s32.fills = solidPaint("#F4E9D8"); s32.cornerRadius = 28; s32.clipsContent = true;
addStatusBar(s32, false); addBackButton(s32);

// Header Bar
addText(s32, { text: "Kuis Budaya", x: 0, y: 56, width: 412, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12", align: "CENTER" });
const badgeStep1 = figma.createFrame(); s32.appendChild(badgeStep1); badgeStep1.x = 330; badgeStep1.y = 54; badgeStep1.resize(58, 28); badgeStep1.fills = solidPaint("#E9DAC7"); badgeStep1.cornerRadius = 12; badgeStep1.layoutMode = "HORIZONTAL"; badgeStep1.primaryAxisAlignItems = "CENTER"; badgeStep1.counterAxisAlignItems = "CENTER"; badgeStep1.layoutSizingHorizontal = "FIXED"; badgeStep1.layoutSizingVertical = "FIXED";
addText(badgeStep1, { text: "1/10", size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });

// Linear Progress
const progTrack1 = figma.createFrame(); s32.appendChild(progTrack1); progTrack1.x = 24; progTrack1.y = 96; progTrack1.resize(364, 6); progTrack1.fills = solidPaint("#E4D3BD"); progTrack1.cornerRadius = 3;
const progFill1 = figma.createFrame(); progTrack1.appendChild(progFill1); progFill1.x = 0; progFill1.y = 0; progFill1.resize(36, 6); progFill1.fills = solidPaint("#3A261D"); progFill1.cornerRadius = 3;

// Question content
addText(s32, { text: "SENI PERTUNJUKAN & SASTRA", x: 24, y: 122, size: 11, weight: "Bold", family: "Lora", color: "#B5603A", letterSpacing: 1.5 });
addText(s32, { text: "Wayang Purwa biasanya mengangkat kisah wiracarita apa?", x: 24, y: 148, width: 364, size: 21, weight: "Bold", family: "Lora", color: "#2B1A12", lineSpacing: 30 });

// Options (A, B, C, D)
const opts32 = [
  "Mahabharata & Ramayana",
  "Panji Semirang & Angling Dharma",
  "Babad Tanah Jawi & Mataram",
  "Damarwulan & Menak Jinggo"
];
let oy1 = 250;
for (let i = 0; i < opts32.length; i++) {
  const isSelected = i === 0;
  const ob = figma.createFrame(); s32.appendChild(ob);
  ob.x = 24; ob.y = oy1; ob.resize(364, 56);
  ob.fills = solidPaint(isSelected ? "#FFFDF9" : "#FFFDF9");
  ob.strokes = solidPaint(isSelected ? "#C79B3A" : "#E5D5BF");
  ob.strokeWeight = isSelected ? 1.8 : 1.2;
  ob.cornerRadius = 16;
  ob.paddingLeft = 18; ob.paddingRight = 18;
  ob.layoutMode = "HORIZONTAL"; ob.primaryAxisAlignItems = "SPACE_BETWEEN"; ob.counterAxisAlignItems = "CENTER";
  ob.layoutSizingHorizontal = "FIXED"; ob.layoutSizingVertical = "FIXED";

  addText(ob, { text: opts32[i], size: 14.5, weight: isSelected ? "Bold" : "Medium", family: "Lora", color: "#2B1A12" });
  if (isSelected) {
    const radio = figma.createFrame(); ob.appendChild(radio); radio.resize(20, 20); radio.cornerRadius = 10; radio.fills = solidPaint("#C79B3A");
  }
  oy1 += 68;
}

const btnAnswer = figma.createFrame(); s32.appendChild(btnAnswer); btnAnswer.x = 24; btnAnswer.y = 540; btnAnswer.resize(364, 52); btnAnswer.fills = solidPaint("#3A261D"); btnAnswer.cornerRadius = 14; btnAnswer.layoutMode = "HORIZONTAL"; btnAnswer.primaryAxisAlignItems = "CENTER"; btnAnswer.counterAxisAlignItems = "CENTER"; btnAnswer.layoutSizingHorizontal = "FIXED"; btnAnswer.layoutSizingVertical = "FIXED";
addText(btnAnswer, { text: "Kunci Jawaban Ini", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });

addBottomNavBar(s32, 3);
s5x += 492;

// 33 — Kuis Budaya: Umpan Balik Jawaban Benar
const s33 = figma.createFrame(); sec5.appendChild(s33); s33.name = "33 — Kuis Budaya: Umpan Balik Jawaban Benar (Current APK)"; s33.x = s5x; s33.y = y5Pos; s33.resize(412, 1380); s33.fills = solidPaint("#F4E9D8"); s33.cornerRadius = 28; s33.clipsContent = true;
addStatusBar(s33, false); addBackButton(s33);

addText(s33, { text: "Kuis Budaya", x: 0, y: 56, width: 412, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12", align: "CENTER" });
const badgeStep2 = figma.createFrame(); s33.appendChild(badgeStep2); badgeStep2.x = 330; badgeStep2.y = 54; badgeStep2.resize(58, 28); badgeStep2.fills = solidPaint("#E9DAC7"); badgeStep2.cornerRadius = 12; badgeStep2.layoutMode = "HORIZONTAL"; badgeStep2.primaryAxisAlignItems = "CENTER"; badgeStep2.counterAxisAlignItems = "CENTER"; badgeStep2.layoutSizingHorizontal = "FIXED"; badgeStep2.layoutSizingVertical = "FIXED";
addText(badgeStep2, { text: "1/10", size: 13, weight: "Bold", family: "Lora", color: "#2B1A12" });

const progTrack2 = figma.createFrame(); s33.appendChild(progTrack2); progTrack2.x = 24; progTrack2.y = 96; progTrack2.resize(364, 6); progTrack2.fills = solidPaint("#E4D3BD"); progTrack2.cornerRadius = 3;
const progFill2 = figma.createFrame(); progTrack2.appendChild(progFill2); progFill2.x = 0; progFill2.y = 0; progFill2.resize(36, 6); progFill2.fills = solidPaint("#3F6B3A"); progFill2.cornerRadius = 3;

addText(s33, { text: "SENI PERTUNJUKAN & SASTRA", x: 24, y: 122, size: 11, weight: "Bold", family: "Lora", color: "#B5603A", letterSpacing: 1.5 });
addText(s33, { text: "Wayang Purwa biasanya mengangkat kisah wiracarita apa?", x: 24, y: 148, width: 364, size: 21, weight: "Bold", family: "Lora", color: "#2B1A12", lineSpacing: 30 });

// Options with Answer Feedback
let oy2 = 250;
for (let i = 0; i < opts32.length; i++) {
  const isCorrect = i === 0;
  const ob = figma.createFrame(); s33.appendChild(ob);
  ob.x = 24; ob.y = oy2; ob.resize(364, 56);
  ob.fills = solidPaint(isCorrect ? "#E8F5E9" : "#FFFDF9");
  ob.strokes = solidPaint(isCorrect ? "#3F6B3A" : "#E5D5BF");
  ob.strokeWeight = isCorrect ? 2 : 1;
  ob.cornerRadius = 16;
  ob.paddingLeft = 18; ob.paddingRight = 18;
  ob.layoutMode = "HORIZONTAL"; ob.primaryAxisAlignItems = "SPACE_BETWEEN"; ob.counterAxisAlignItems = "CENTER";
  ob.layoutSizingHorizontal = "FIXED"; ob.layoutSizingVertical = "FIXED";

  addText(ob, { text: opts32[i], size: 14.5, weight: isCorrect ? "Bold" : "Medium", family: "Lora", color: isCorrect ? "#1E4620" : "#6B5845" });
  if (isCorrect) {
    const badgeCorrect = figma.createFrame(); ob.appendChild(badgeCorrect); badgeCorrect.resize(68, 26); badgeCorrect.fills = solidPaint("#2E7D32"); badgeCorrect.cornerRadius = 6; badgeCorrect.layoutMode = "HORIZONTAL"; badgeCorrect.primaryAxisAlignItems = "CENTER"; badgeCorrect.counterAxisAlignItems = "CENTER"; badgeCorrect.layoutSizingHorizontal = "FIXED"; badgeCorrect.layoutSizingVertical = "FIXED";
    addText(badgeCorrect, { text: "✓ Benar", size: 11, weight: "Bold", family: "Lora", color: "#FFFFFF" });
  }
  oy2 += 68;
}

// Kotak "Tahukah Kamu?"
const infoBox = figma.createFrame(); s33.appendChild(infoBox); infoBox.x = 24; infoBox.y = 530; infoBox.resize(364, 115); infoBox.fills = solidPaint("#EFE3D2"); infoBox.strokes = solidPaint("#DFCDAF"); infoBox.strokeWeight = 1.2; infoBox.cornerRadius = 16; infoBox.paddingLeft = 16; infoBox.paddingTop = 14;
addText(infoBox, { text: "💡  TAHUKAH KAMU?", x: 16, y: 14, size: 11, weight: "Bold", family: "Inter", color: "#B5603A", letterSpacing: 1.5 });
addText(infoBox, { text: "Wayang Purwa bersumber dari dua epos agung India kuno yaitu Mahabharata dan Ramayana yang disadur mendalam dengan kearifan lokal Jawa oleh para empu dan pujangga keraton sejak era Mataram Kuno.", x: 16, y: 36, width: 332, size: 12.5, family: "Lora", color: "#463428", lineSpacing: 18 });

const btnNextQ = figma.createFrame(); s33.appendChild(btnNextQ); btnNextQ.x = 24; btnNextQ.y = 665; btnNextQ.resize(364, 52); btnNextQ.fills = solidPaint("#3A261D"); btnNextQ.cornerRadius = 14; btnNextQ.layoutMode = "HORIZONTAL"; btnNextQ.primaryAxisAlignItems = "CENTER"; btnNextQ.counterAxisAlignItems = "CENTER"; btnNextQ.layoutSizingHorizontal = "FIXED"; btnNextQ.layoutSizingVertical = "FIXED";
addText(btnNextQ, { text: "Lanjut ke Soal Berikutnya →", size: 15, weight: "Bold", family: "Lora", color: "#FFFBF4" });

addBottomNavBar(s33, 3);
s5x += 492;

// 34 — Kuis Budaya: Hasil Akhir & Sertifikat
const s34 = figma.createFrame(); sec5.appendChild(s34); s34.name = "34 — Kuis Budaya: Hasil Akhir & Sertifikat (Current APK)"; s34.x = s5x; s34.y = y5Pos; s34.resize(412, 1380); s34.fills = solidPaint("#F4E9D8"); s34.cornerRadius = 28; s34.clipsContent = true;
addStatusBar(s34, false); addBackButton(s34);
addText(s34, { text: "Hasil Kuis Budaya", x: 0, y: 56, width: 412, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12", align: "CENTER" });

// Score Circle
const scoreCirc = figma.createFrame(); s34.appendChild(scoreCirc); scoreCirc.x = 141; scoreCirc.y = 110; scoreCirc.resize(130, 130); scoreCirc.cornerRadius = 65; scoreCirc.fills = solidPaint("#FFFDF9"); scoreCirc.strokes = solidPaint("#C79B3A"); scoreCirc.strokeWeight = 3.5; scoreCirc.layoutMode = "HORIZONTAL"; scoreCirc.primaryAxisAlignItems = "CENTER"; scoreCirc.counterAxisAlignItems = "CENTER"; scoreCirc.layoutSizingHorizontal = "FIXED"; scoreCirc.layoutSizingVertical = "FIXED";
addText(scoreCirc, { text: "10/10", size: 34, weight: "Bold", family: "Inter", color: "#3A261D" });

addText(s34, { text: "Ksatria Budaya Paripurna!", x: 0, y: 260, width: 412, size: 22, weight: "Bold", family: "Lora", color: "#2B1A12", align: "CENTER" });
addText(s34, { text: "Kamu menjawab 10 dari 10 soal dengan sempurna.", x: 24, y: 295, width: 364, size: 13.5, family: "Lora", color: "#6B5845", align: "CENTER" });

// Lencana Unlocked
const badgeCard = figma.createFrame(); s34.appendChild(badgeCard); badgeCard.x = 24; badgeCard.y = 340; badgeCard.resize(364, 160); badgeCard.fills = solidPaint("#FFFDF9"); badgeCard.strokes = solidPaint("#E6D6BF"); badgeCard.strokeWeight = 1.2; badgeCard.cornerRadius = 20; badgeCard.layoutMode = "VERTICAL"; badgeCard.primaryAxisAlignItems = "CENTER"; badgeCard.counterAxisAlignItems = "CENTER"; badgeCard.paddingTop = 18; badgeCard.paddingBottom = 18; badgeCard.itemSpacing = 8; badgeCard.layoutSizingHorizontal = "FIXED"; badgeCard.layoutSizingVertical = "FIXED";
addText(badgeCard, { text: "LENCANA KEHORMATAN TERBUKA", size: 11, weight: "Bold", family: "Lora", color: "#B5603A", letterSpacing: 2 });
addText(badgeCard, { text: "🏆", size: 38, family: "Inter" });
addText(badgeCard, { text: "Pujangga Sinau Jawa", size: 17, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(badgeCard, { text: "Menguasai 10 pertanyaan budaya Jawa Tengah", size: 12, family: "Lora", color: "#6B5845" });

// Buttons
const btnCert = figma.createFrame(); s34.appendChild(btnCert); btnCert.x = 24; btnCert.y = 525; btnCert.resize(364, 52); btnCert.fills = solidPaint("#C79B3A"); btnCert.cornerRadius = 14; btnCert.layoutMode = "HORIZONTAL"; btnCert.primaryAxisAlignItems = "CENTER"; btnCert.counterAxisAlignItems = "CENTER"; btnCert.layoutSizingHorizontal = "FIXED"; btnCert.layoutSizingVertical = "FIXED";
addText(btnCert, { text: "📜 Unduh Sertifikat Ksatria (PDF)", size: 14.5, weight: "Bold", family: "Lora", color: "#261808" });

const btnShare = figma.createFrame(); s34.appendChild(btnShare); btnShare.x = 24; btnShare.y = 590; btnShare.resize(364, 52); btnShare.fills = solidPaint("#FFFBF4"); btnShare.strokes = solidPaint("#E0C9A6"); btnShare.strokeWeight = 1; btnShare.cornerRadius = 14; btnShare.layoutMode = "HORIZONTAL"; btnShare.primaryAxisAlignItems = "CENTER"; btnShare.counterAxisAlignItems = "CENTER"; btnShare.layoutSizingHorizontal = "FIXED"; btnShare.layoutSizingVertical = "FIXED";
addText(btnShare, { text: "✨ Bagikan Pencapaian Budaya", size: 14.5, weight: "Bold", family: "Lora", color: "#2B1A12" });

addBottomNavBar(s34, 3);
s5x += 492;

// 35 — Sanggar Aksara Jawa
const s35 = figma.createFrame(); sec5.appendChild(s35); s35.name = "35 — Sanggar Aksara Jawa (Current APK)"; s35.x = s5x; s35.y = y5Pos; s35.resize(412, 1380); s35.fills = solidPaint("#F4E9D8"); s35.cornerRadius = 28; s35.clipsContent = true;
addStatusBar(s35, false); addBackButton(s35);
addText(s35, { text: "Sanggar Aksara Jawa", x: 64, y: 56, size: 18, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s35, { text: "Transliterasi & Filosofi Hanacaraka", x: 24, y: 104, size: 13, weight: "Medium", family: "Inter", color: "#B5603A" });

// Live Transliteration Box
const transBox = figma.createFrame(); s35.appendChild(transBox); transBox.x = 24; transBox.y = 132; transBox.resize(364, 160); transBox.fills = solidPaint("#1F150E"); transBox.strokes = solidPaint("#C79B3A", 0.6); transBox.strokeWeight = 1.2; transBox.cornerRadius = 16; transBox.paddingLeft = 18; transBox.paddingRight = 18; transBox.paddingTop = 14;
addText(transBox, { text: "LATIN KE AKSARA JAWA", x: 18, y: 14, size: 10, weight: "Bold", family: "Inter", color: "#DFB76C", letterSpacing: 2 });
addText(transBox, { text: "Javara Jawa Tengah", x: 18, y: 38, size: 15, weight: "Medium", family: "Lora", color: "#FFFBF4" });
addRect(transBox, { x: 18, y: 68, width: 328, height: 1, fill: "#463428" });
addText(transBox, { text: "ꦗꦮ꦳ꦫ ꦗꦮ ꦠꦼꦔꦃ", x: 18, y: 84, size: 24, weight: "Bold", family: "Lora", color: "#DFB76C" });
addText(transBox, { text: "📋 Salin Aksara", x: 250, y: 122, size: 11, weight: "Bold", family: "Inter", color: "#DFB76C" });

// Hanacaraka Grid
addText(s35, { text: "20 Aksara Hanacaraka (Legena)", x: 24, y: 312, size: 15, weight: "Bold", family: "Lora", color: "#2B1A12" });
const glyphs = [
  { l: "Ha", j: "ꦲ" }, { l: "Na", j: "ꦤ" }, { l: "Ca", j: "ꦕ" }, { l: "Ra", j: "ꦫ" }, { l: "Ka", j: "ꦏ" },
  { l: "Da", j: "ꦢ" }, { l: "Ta", j: "ꦠ" }, { l: "Sa", j: "ꦱ" }, { l: "Wa", j: "ꦮ" }, { l: "La", j: "ꦭ" }
];
let gx = 24, gy = 340;
for (let i = 0; i < glyphs.length; i++) {
  const isHa = i === 0;
  const gb = figma.createFrame(); s35.appendChild(gb); gb.x = gx; gb.y = gy; gb.resize(66, 72);
  gb.fills = solidPaint(isHa ? "#3A261D" : "#FFFDF9");
  gb.strokes = solidPaint(isHa ? "#C79B3A" : "#E5D5BF");
  gb.strokeWeight = isHa ? 1.5 : 1;
  gb.cornerRadius = 12;
  gb.layoutMode = "VERTICAL"; gb.primaryAxisAlignItems = "CENTER"; gb.counterAxisAlignItems = "CENTER";
  gb.layoutSizingHorizontal = "FIXED"; gb.layoutSizingVertical = "FIXED";

  addText(gb, { text: glyphs[i].j, size: 20, weight: "Bold", family: "Lora", color: isHa ? "#DFB76C" : "#2B1A12" });
  addText(gb, { text: glyphs[i].l, size: 11, weight: "Bold", family: "Lora", color: isHa ? "#FFFBF4" : "#6B5845" });

  gx += 74;
  if ((i + 1) % 5 === 0) { gx = 24; gy += 80; }
}

// Glyph detail card
const philCard = figma.createFrame(); s35.appendChild(philCard); philCard.x = 24; philCard.y = 520; philCard.resize(364, 110); philCard.fills = solidPaint("#EFE3D2"); philCard.strokes = solidPaint("#DFCDAF"); philCard.strokeWeight = 1.2; philCard.cornerRadius = 16; philCard.paddingLeft = 16; philCard.paddingTop = 14;
addText(philCard, { text: "FILOSOFI AKSARA HA (ꦲ) — URIP / NAFAS", x: 16, y: 14, size: 11, weight: "Bold", family: "Inter", color: "#B5603A", letterSpacing: 1.5 });
addText(philCard, { text: "Hana caraka: Wujud utusan Sang Maha Pencipta, napas kehidupan manusia yang suci serta ketulusan niat berbuat kebajikan di dunia.", x: 16, y: 36, width: 332, size: 12.5, family: "Lora", color: "#463428", lineSpacing: 18 });

addBottomNavBar(s35, 3);

return "Section 5 created successfully (Screens 32 - 35)!";
