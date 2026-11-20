await Promise.all([
  figma.loadFontAsync({ family: "Inter", style: "Regular" }),
  figma.loadFontAsync({ family: "Inter", style: "Medium" }),
  figma.loadFontAsync({ family: "Inter", style: "Bold" }),
  figma.loadFontAsync({ family: "Lora", style: "Regular" }),
  figma.loadFontAsync({ family: "Lora", style: "Bold" })
]);

const javaraPage = figma.root.children.find(p => p.name === 'Javara');
await figma.setCurrentPageAsync(javaraPage);

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

function addJavaraHeaderLogo(frame, centerX = 206, startY = 60) {
  const logoGroup = figma.createFrame();
  frame.appendChild(logoGroup);
  logoGroup.name = "Javara Authentic Logo";
  logoGroup.x = centerX - 100;
  logoGroup.y = startY;
  logoGroup.resize(200, 70);
  logoGroup.fills = [];
  addText(logoGroup, { text: "ꦗ  ꦮ  ꦫ", x: 0, y: 0, width: 200, size: 18, weight: "Bold", family: "Inter", color: "#C79B3A", align: "CENTER" });
  addText(logoGroup, { text: "JAVARA", x: 0, y: 26, width: 200, size: 24, weight: "Bold", family: "Lora", color: "#2B1A12", align: "CENTER", letterSpacing: 4 });
  addRect(logoGroup, { x: 80, y: 60, width: 40, height: 2, fill: "#C79B3A", radius: 1, name: "Gold Line" });
  return logoGroup;
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

// SECTION 1: ONBOARDING & AUTENTIKASI
const sec1 = figma.createSection();
javaraPage.appendChild(sec1);
sec1.name = "ALUR 1 — ONBOARDING & AUTENTIKASI (14 Screens)";
sec1.x = 0;
sec1.y = 0;
sec1.resize(7100, 1100);

let sx = 60;
const yPos = 80;

// 01 — Splash
const s01 = figma.createFrame();
sec1.appendChild(s01);
s01.name = "01 — Splash Screen (Current APK)";
s01.x = sx; s01.y = yPos; s01.resize(412, 917); s01.fills = solidPaint("#2E2019"); s01.cornerRadius = 28; s01.clipsContent = true;
addStatusBar(s01, true);
const m1 = figma.createEllipse(); s01.appendChild(m1); m1.x = 106; m1.y = 260; m1.resize(200, 200); m1.fills = solidPaint("#C79B3A", 0.08); m1.strokes = solidPaint("#C79B3A", 0.35); m1.strokeWeight = 1.5;
addText(s01, { text: "ꦗ  ꦮ  ꦫ", x: 0, y: 335, width: 412, size: 24, weight: "Bold", family: "Inter", color: "#E0C9A6", align: "CENTER" });
addText(s01, { text: "JAVARA", x: 0, y: 375, width: 412, size: 36, weight: "Bold", family: "Lora", color: "#FFFBF4", align: "CENTER", letterSpacing: 6 });
addText(s01, { text: "KHASANAH BUDAYA JAWA TENGAH", x: 0, y: 425, width: 412, size: 10, weight: "Medium", family: "Inter", color: "#C79B3A", align: "CENTER", letterSpacing: 3 });
addRect(s01, { x: 86, y: 730, width: 240, height: 4, fill: "#463428", radius: 2 });
addRect(s01, { x: 86, y: 730, width: 160, height: 4, fill: "#C79B3A", radius: 2 });
addText(s01, { text: "Menyelaraskan Khasanah Budaya Jawa...", x: 20, y: 746, width: 372, size: 12, family: "Lora", color: "#D6C8B8", align: "CENTER" });
addText(s01, { text: "Memayu Hayuning Bawana • Memperindah Keindahan Dunia", x: 20, y: 840, width: 372, size: 11, family: "Lora", color: "#A89482", align: "CENTER" });
sx += 492;

// 02 — Welcome
const s02 = figma.createFrame();
sec1.appendChild(s02);
s02.name = "02 — Welcome Screen (Current APK)";
s02.x = sx; s02.y = yPos; s02.resize(412, 917); s02.fills = solidPaint("#F4E9D8"); s02.cornerRadius = 28; s02.clipsContent = true;
addStatusBar(s02, false);
addText(s02, { text: "Selamat Datang di", x: 28, y: 76, size: 20, family: "Lora", color: "#2B1A12" });
addText(s02, { text: "JAVARA", x: 28, y: 104, size: 42, weight: "Bold", family: "Lora", color: "#2B1A12", letterSpacing: 2 });
addText(s02, { text: "Jelajah budaya Jawa , Temukan rasa, karya , dan pengalaman terbaiknya", x: 28, y: 166, width: 356, size: 15, family: "Lora", color: "#2B1A12", lineSpacing: 22 });
addRect(s02, { x: 28, y: 260, width: 356, height: 470, radius: 18, imageHash: "6cfffa6d4b1a106f14380589f575ae7010a42701", stroke: "#E0C9A6", strokeWidth: 1 });
const btnM2 = figma.createFrame(); s02.appendChild(btnM2); btnM2.name = "Tombol Mulai"; btnM2.x = 28; btnM2.y = 810; btnM2.resize(356, 52); btnM2.fills = solidPaint("#D4A343"); btnM2.cornerRadius = 12; btnM2.layoutMode = "HORIZONTAL"; btnM2.primaryAxisAlignItems = "CENTER"; btnM2.counterAxisAlignItems = "CENTER"; btnM2.layoutSizingHorizontal = "FIXED"; btnM2.layoutSizingVertical = "FIXED";
addText(btnM2, { text: "Mulai", size: 16, weight: "Bold", family: "Lora", color: "#261808" });
sx += 492;

// Helper for Login Screen
function buildLoginBase(s, emailVal = "", passVal = "", emailFocused = false) {
  addStatusBar(s, false);
  addJavaraHeaderLogo(s, 206, 68);
  addText(s, { text: "Log In", x: 28, y: 170, size: 28, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(s, { text: "Selamat datang kembali!", x: 28, y: 210, size: 14, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(s, { text: "Lanjutkan perjalananmu bersama JAVARA", x: 28, y: 232, size: 12, family: "Lora", color: "#6B5845" });

  const fe = figma.createFrame(); s.appendChild(fe); fe.name = "Field: Email"; fe.x = 28; fe.y = 280; fe.resize(356, 52); fe.fills = solidPaint(emailFocused ? "#FFFBF4" : "#E3CDAB"); fe.strokes = solidPaint(emailFocused ? "#3A261D" : "#E3CDAB"); fe.strokeWeight = 1.5; fe.cornerRadius = 12; fe.paddingLeft = 16; fe.layoutMode = "HORIZONTAL"; fe.counterAxisAlignItems = "CENTER"; fe.layoutSizingHorizontal = "FIXED"; fe.layoutSizingVertical = "FIXED";
  addText(fe, { text: emailVal || "Email", size: 14, weight: emailVal ? "Medium" : "Regular", family: "Lora", color: emailVal ? "#2B1A12" : "#5F4E3C" });

  const fp = figma.createFrame(); s.appendChild(fp); fp.name = "Field: Password"; fp.x = 28; fp.y = 348; fp.resize(356, 52); fp.fills = solidPaint("#E3CDAB"); fp.cornerRadius = 12; fp.paddingLeft = 16; fp.paddingRight = 16; fp.layoutMode = "HORIZONTAL"; fp.primaryAxisAlignItems = "SPACE_BETWEEN"; fp.counterAxisAlignItems = "CENTER"; fp.layoutSizingHorizontal = "FIXED"; fp.layoutSizingVertical = "FIXED";
  addText(fp, { text: passVal || "Password", size: passVal ? 18 : 14, weight: passVal ? "Bold" : "Regular", family: passVal ? "Inter" : "Lora", color: passVal ? "#2B1A12" : "#5F4E3C" });

  addText(s, { text: "Lupa Password?", x: 260, y: 414, size: 12, weight: "Bold", family: "Lora", color: "#3A261D" });

  const btnL = figma.createFrame(); s.appendChild(btnL); btnL.name = "Tombol Log In"; btnL.x = 28; btnL.y = 452; btnL.resize(356, 52); btnL.fills = solidPaint("#3A261D"); btnL.cornerRadius = 12; btnL.layoutMode = "HORIZONTAL"; btnL.primaryAxisAlignItems = "CENTER"; btnL.counterAxisAlignItems = "CENTER"; btnL.layoutSizingHorizontal = "FIXED"; btnL.layoutSizingVertical = "FIXED";
  addText(btnL, { text: "Log In", size: 16, weight: "Bold", family: "Lora", color: "#FFFBF4" });

  addRect(s, { x: 28, y: 540, width: 140, height: 1, fill: "#C8B69A" });
  addText(s, { text: "atau", x: 180, y: 531, width: 52, size: 13, family: "Lora", color: "#6B5845", align: "CENTER" });
  addRect(s, { x: 244, y: 540, width: 140, height: 1, fill: "#C8B69A" });

  const bg = figma.createFrame(); s.appendChild(bg); bg.x = 28; bg.y = 574; bg.resize(172, 50); bg.fills = solidPaint("#E3CDAB"); bg.cornerRadius = 12; bg.layoutMode = "HORIZONTAL"; bg.primaryAxisAlignItems = "CENTER"; bg.counterAxisAlignItems = "CENTER"; bg.layoutSizingHorizontal = "FIXED"; bg.layoutSizingVertical = "FIXED";
  addText(bg, { text: "G  Google", size: 14, weight: "Bold", family: "Inter", color: "#2B1A12" });

  const ba = figma.createFrame(); s.appendChild(ba); ba.x = 212; ba.y = 574; ba.resize(172, 50); ba.fills = solidPaint("#E3CDAB"); ba.cornerRadius = 12; ba.layoutMode = "HORIZONTAL"; ba.primaryAxisAlignItems = "CENTER"; ba.counterAxisAlignItems = "CENTER"; ba.layoutSizingHorizontal = "FIXED"; ba.layoutSizingVertical = "FIXED";
  addText(ba, { text: "  Apple", size: 14, weight: "Bold", family: "Inter", color: "#2B1A12" });

  const br = figma.createFrame(); s.appendChild(br); br.x = 28; br.y = 660; br.resize(356, 30); br.fills = []; br.layoutMode = "HORIZONTAL"; br.primaryAxisAlignItems = "CENTER"; br.itemSpacing = 6;
  addText(br, { text: "Belum punya akun?", size: 13, family: "Lora", color: "#6B5845" });
  addText(br, { text: "Sign Up", size: 13, weight: "Bold", family: "Lora", color: "#3A261D" });
}

// 03 — Login Default
const s03 = figma.createFrame(); sec1.appendChild(s03); s03.name = "03 — Login (Default State)"; s03.x = sx; s03.y = yPos; s03.resize(412, 917); s03.fills = solidPaint("#F4E9D8"); s03.cornerRadius = 28; s03.clipsContent = true;
buildLoginBase(s03);
sx += 492;

// 04 — Login Focused
const s04 = figma.createFrame(); sec1.appendChild(s04); s04.name = "04 — Login (Active / Typing State)"; s04.x = sx; s04.y = yPos; s04.resize(412, 917); s04.fills = solidPaint("#F4E9D8"); s04.cornerRadius = 28; s04.clipsContent = true;
buildLoginBase(s04, "raden.arya@javara.id", "", true);
sx += 492;

// 05 — Login Filled
const s05 = figma.createFrame(); sec1.appendChild(s05); s05.name = "05 — Login (Filled State)"; s05.x = sx; s05.y = yPos; s05.resize(412, 917); s05.fills = solidPaint("#F4E9D8"); s05.cornerRadius = 28; s05.clipsContent = true;
buildLoginBase(s05, "raden.arya@javara.id", "••••••••••••", false);
sx += 492;

// 06 — Google Auth Modal
const s06 = figma.createFrame(); sec1.appendChild(s06); s06.name = "06 — Google Auth Modal"; s06.x = sx; s06.y = yPos; s06.resize(412, 917); s06.fills = solidPaint("#F4E9D8"); s06.cornerRadius = 28; s06.clipsContent = true;
buildLoginBase(s06);
addRect(s06, { x: 0, y: 0, width: 412, height: 917, fill: "#000000", opacity: 0.65, name: "Scrim" });
const gModal = figma.createFrame(); s06.appendChild(gModal); gModal.name = "Google Account Sheet"; gModal.x = 24; gModal.y = 300; gModal.resize(364, 300); gModal.fills = solidPaint("#FFFFFF"); gModal.cornerRadius = 16; gModal.paddingLeft = 24; gModal.paddingRight = 24; gModal.paddingTop = 20;
addText(gModal, { text: "G  Masuk dengan Google", x: 24, y: 20, size: 16, weight: "Bold", family: "Inter", color: "#2B1A12" });
addText(gModal, { text: "Pilih akun untuk melanjutkan ke JAVARA", x: 24, y: 46, size: 12, family: "Inter", color: "#6B5845" });
const gAcc = figma.createFrame(); gModal.appendChild(gAcc); gAcc.x = 24; gAcc.y = 80; gAcc.resize(316, 64); gAcc.fills = solidPaint("#F4E9D8"); gAcc.cornerRadius = 10; gAcc.paddingLeft = 14; gAcc.layoutMode = "HORIZONTAL"; gAcc.counterAxisAlignItems = "CENTER"; gAcc.itemSpacing = 12; gAcc.layoutSizingHorizontal = "FIXED"; gAcc.layoutSizingVertical = "FIXED";
addText(gAcc, { text: "👤", size: 24, family: "Inter" });
const gCol = figma.createFrame(); gAcc.appendChild(gCol); gCol.resize(230, 40); gCol.fills = []; gCol.layoutMode = "VERTICAL"; gCol.primaryAxisAlignItems = "CENTER";
addText(gCol, { text: "Raden Mas Arya", size: 13, weight: "Bold", family: "Inter", color: "#2B1A12" });
addText(gCol, { text: "raden.arya@gmail.com", size: 11, family: "Inter", color: "#6B5845" });
const btnCont = figma.createFrame(); gModal.appendChild(btnCont); btnCont.x = 24; btnCont.y = 200; btnCont.resize(316, 48); btnCont.fills = solidPaint("#3A261D"); btnCont.cornerRadius = 10; btnCont.layoutMode = "HORIZONTAL"; btnCont.primaryAxisAlignItems = "CENTER"; btnCont.counterAxisAlignItems = "CENTER"; btnCont.layoutSizingHorizontal = "FIXED"; btnCont.layoutSizingVertical = "FIXED";
addText(btnCont, { text: "Lanjutkan sebagai Arya", size: 14, weight: "Bold", family: "Inter", color: "#FFFBF4" });
sx += 492;

// 07 — Apple ID Modal
const s07 = figma.createFrame(); sec1.appendChild(s07); s07.name = "07 — Apple ID Modal"; s07.x = sx; s07.y = yPos; s07.resize(412, 917); s07.fills = solidPaint("#F4E9D8"); s07.cornerRadius = 28; s07.clipsContent = true;
buildLoginBase(s07);
addRect(s07, { x: 0, y: 0, width: 412, height: 917, fill: "#000000", opacity: 0.65, name: "Scrim" });
const aModal = figma.createFrame(); s07.appendChild(aModal); aModal.name = "Apple ID Sheet"; aModal.x = 24; aModal.y = 320; aModal.resize(364, 270); aModal.fills = solidPaint("#000000"); aModal.cornerRadius = 18; aModal.paddingLeft = 24; aModal.paddingRight = 24; aModal.paddingTop = 22;
addText(aModal, { text: "  Masuk dengan Apple", x: 24, y: 22, size: 18, weight: "Bold", family: "Inter", color: "#FFFFFF" });
addText(aModal, { text: "Apakah Anda ingin membuat akun JAVARA dengan Apple ID Anda?", x: 24, y: 52, width: 316, size: 12.5, family: "Inter", color: "#A8A8A8", lineSpacing: 18 });
addText(aModal, { text: "Face ID  |  Klik Dua Kali untuk Menyetujui", x: 24, y: 130, size: 12, weight: "Bold", family: "Inter", color: "#0A84FF" });
const btnApp = figma.createFrame(); aModal.appendChild(btnApp); btnApp.x = 24; btnApp.y = 180; btnApp.resize(316, 48); btnApp.fills = solidPaint("#FFFFFF"); btnApp.cornerRadius = 10; btnApp.layoutMode = "HORIZONTAL"; btnApp.primaryAxisAlignItems = "CENTER"; btnApp.counterAxisAlignItems = "CENTER"; btnApp.layoutSizingHorizontal = "FIXED"; btnApp.layoutSizingVertical = "FIXED";
addText(btnApp, { text: "Lanjutkan dengan Kode Sandi", size: 14, weight: "Bold", family: "Inter", color: "#000000" });
sx += 492;

// 08 — Lupa Password Email
const s08 = figma.createFrame(); sec1.appendChild(s08); s08.name = "08 — Lupa Password (Input Email)"; s08.x = sx; s08.y = yPos; s08.resize(412, 917); s08.fills = solidPaint("#F4E9D8"); s08.cornerRadius = 28; s08.clipsContent = true;
addStatusBar(s08, false); addBackButton(s08); addJavaraHeaderLogo(s08, 206, 68);
addText(s08, { text: "Lupa Password?", x: 28, y: 170, size: 26, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s08, { text: "Masukkan email yang terdaftar untuk mereset password", x: 28, y: 210, width: 356, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });
const fE08 = figma.createFrame(); s08.appendChild(fE08); fE08.x = 28; fE08.y = 270; fE08.resize(356, 52); fE08.fills = solidPaint("#E3CDAB"); fE08.cornerRadius = 12; fE08.paddingLeft = 16; fE08.layoutMode = "HORIZONTAL"; fE08.counterAxisAlignItems = "CENTER"; fE08.layoutSizingHorizontal = "FIXED"; fE08.layoutSizingVertical = "FIXED";
addText(fE08, { text: "raden.arya@javara.id", size: 14, weight: "Medium", family: "Lora", color: "#2B1A12" });
const btnR08 = figma.createFrame(); s08.appendChild(btnR08); btnR08.x = 28; btnR08.y = 350; btnR08.resize(356, 52); btnR08.fills = solidPaint("#3A261D"); btnR08.cornerRadius = 12; btnR08.layoutMode = "HORIZONTAL"; btnR08.primaryAxisAlignItems = "CENTER"; btnR08.counterAxisAlignItems = "CENTER"; btnR08.layoutSizingHorizontal = "FIXED"; btnR08.layoutSizingVertical = "FIXED";
addText(btnR08, { text: "Reset Password", size: 16, weight: "Bold", family: "Lora", color: "#FFFBF4" });
sx += 492;

// 09 — Lupa Password OTP
const s09 = figma.createFrame(); sec1.appendChild(s09); s09.name = "09 — Lupa Password (OTP 5 Kotak)"; s09.x = sx; s09.y = yPos; s09.resize(412, 917); s09.fills = solidPaint("#F4E9D8"); s09.cornerRadius = 28; s09.clipsContent = true;
addStatusBar(s09, false); addBackButton(s09); addJavaraHeaderLogo(s09, 206, 68);
addText(s09, { text: "Check Email Kamu", x: 28, y: 170, size: 26, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s09, { text: "Kami udah ngirim kode verifikasi ke raden.arya@javara.id. Masukkan 5 digit kode yang ada di email", x: 28, y: 210, width: 356, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });
const otpRow = figma.createFrame(); s09.appendChild(otpRow); otpRow.x = 28; otpRow.y = 280; otpRow.resize(356, 60); otpRow.fills = []; otpRow.layoutMode = "HORIZONTAL"; otpRow.primaryAxisAlignItems = "SPACE_BETWEEN"; otpRow.layoutSizingHorizontal = "FIXED"; otpRow.layoutSizingVertical = "FIXED";
for (const d of ["8", "2", "5", "1", "9"]) {
  const box = figma.createFrame(); otpRow.appendChild(box); box.resize(58, 58); box.fills = solidPaint("#FFFBF4"); box.strokes = solidPaint("#C79B3A"); box.strokeWeight = 1.5; box.cornerRadius = 12; box.layoutMode = "HORIZONTAL"; box.primaryAxisAlignItems = "CENTER"; box.counterAxisAlignItems = "CENTER"; box.layoutSizingHorizontal = "FIXED"; box.layoutSizingVertical = "FIXED";
  addText(box, { text: d, size: 22, weight: "Bold", family: "Inter", color: "#2B1A12" });
}
addText(s09, { text: "Kirim ulang kode dalam 54 detik", x: 28, y: 360, width: 356, size: 12, family: "Lora", color: "#6B5845", align: "CENTER" });
const btnV09 = figma.createFrame(); s09.appendChild(btnV09); btnV09.x = 28; btnV09.y = 400; btnV09.resize(356, 52); btnV09.fills = solidPaint("#3A261D"); btnV09.cornerRadius = 12; btnV09.layoutMode = "HORIZONTAL"; btnV09.primaryAxisAlignItems = "CENTER"; btnV09.counterAxisAlignItems = "CENTER"; btnV09.layoutSizingHorizontal = "FIXED"; btnV09.layoutSizingVertical = "FIXED";
addText(btnV09, { text: "Verify Kode", size: 16, weight: "Bold", family: "Lora", color: "#FFFBF4" });
sx += 492;

// 10 — Lupa Password Baru
const s10 = figma.createFrame(); sec1.appendChild(s10); s10.name = "10 — Lupa Password (Password Baru)"; s10.x = sx; s10.y = yPos; s10.resize(412, 917); s10.fills = solidPaint("#F4E9D8"); s10.cornerRadius = 28; s10.clipsContent = true;
addStatusBar(s10, false); addBackButton(s10); addJavaraHeaderLogo(s10, 206, 68);
addText(s10, { text: "Password Reset", x: 28, y: 170, size: 26, weight: "Bold", family: "Lora", color: "#2B1A12" });
addText(s10, { text: "Kata sandi kamu berhasil diverifikasi. Masukkan kata sandi baru untuk akunmu", x: 28, y: 210, width: 356, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });
const fP10 = figma.createFrame(); s10.appendChild(fP10); fP10.x = 28; fP10.y = 270; fP10.resize(356, 52); fP10.fills = solidPaint("#E3CDAB"); fP10.cornerRadius = 12; fP10.paddingLeft = 16; fP10.layoutMode = "HORIZONTAL"; fP10.counterAxisAlignItems = "CENTER"; fP10.layoutSizingHorizontal = "FIXED"; fP10.layoutSizingVertical = "FIXED";
addText(fP10, { text: "••••••••••••", size: 18, weight: "Bold", family: "Inter", color: "#2B1A12" });
const fC10 = figma.createFrame(); s10.appendChild(fC10); fC10.x = 28; fC10.y = 338; fC10.resize(356, 52); fC10.fills = solidPaint("#E3CDAB"); fC10.cornerRadius = 12; fC10.paddingLeft = 16; fC10.layoutMode = "HORIZONTAL"; fC10.counterAxisAlignItems = "CENTER"; fC10.layoutSizingHorizontal = "FIXED"; fC10.layoutSizingVertical = "FIXED";
addText(fC10, { text: "••••••••••••", size: 18, weight: "Bold", family: "Inter", color: "#2B1A12" });
const btnC10 = figma.createFrame(); s10.appendChild(btnC10); btnC10.x = 28; btnC10.y = 415; btnC10.resize(356, 52); btnC10.fills = solidPaint("#3A261D"); btnC10.cornerRadius = 12; btnC10.layoutMode = "HORIZONTAL"; btnC10.primaryAxisAlignItems = "CENTER"; btnC10.counterAxisAlignItems = "CENTER"; btnC10.layoutSizingHorizontal = "FIXED"; btnC10.layoutSizingVertical = "FIXED";
addText(btnC10, { text: "Konfirmasi", size: 16, weight: "Bold", family: "Lora", color: "#FFFBF4" });
sx += 492;

// 11 — Lupa Password Sukses
const s11 = figma.createFrame(); sec1.appendChild(s11); s11.name = "11 — Lupa Password (Sukses Dialog)"; s11.x = sx; s11.y = yPos; s11.resize(412, 917); s11.fills = solidPaint("#F4E9D8"); s11.cornerRadius = 28; s11.clipsContent = true;
addStatusBar(s11, false); addJavaraHeaderLogo(s11, 206, 68);
addRect(s11, { x: 0, y: 0, width: 412, height: 917, fill: "#000000", opacity: 0.65, name: "Scrim" });
const sDlg = figma.createFrame(); s11.appendChild(sDlg); sDlg.name = "Success Dialog"; sDlg.x = 28; sDlg.y = 320; sDlg.resize(356, 230); sDlg.fills = solidPaint("#2E2019"); sDlg.strokes = solidPaint("#C79B3A", 0.7); sDlg.strokeWeight = 1.2; sDlg.cornerRadius = 18; sDlg.paddingLeft = 24; sDlg.paddingRight = 24; sDlg.paddingTop = 22;
addText(sDlg, { text: "✓  Kata Sandi Berhasil Diubah", x: 24, y: 22, size: 17, weight: "Bold", family: "Lora", color: "#FFDF9E" });
addText(sDlg, { text: "Kata sandi akun JAVARA Anda telah berhasil diperbarui. Silakan masuk kembali dengan kata sandi baru Anda.", x: 24, y: 56, width: 308, size: 13, family: "Lora", color: "#D6C8B8", lineSpacing: 18 });
const btnOk11 = figma.createFrame(); sDlg.appendChild(btnOk11); btnOk11.x = 24; btnOk11.y = 150; btnOk11.resize(308, 48); btnOk11.fills = solidPaint("#C79B3A"); btnOk11.cornerRadius = 10; btnOk11.layoutMode = "HORIZONTAL"; btnOk11.primaryAxisAlignItems = "CENTER"; btnOk11.counterAxisAlignItems = "CENTER"; btnOk11.layoutSizingHorizontal = "FIXED"; btnOk11.layoutSizingVertical = "FIXED";
addText(btnOk11, { text: "Masuk Sekarang →", size: 14, weight: "Bold", family: "Lora", color: "#261808" });
sx += 492;

// Helper for Sign Up
function buildSignUpBase(s, nVal = "", eVal = "", pVal = "") {
  addStatusBar(s, false); addBackButton(s); addJavaraHeaderLogo(s, 206, 68);
  addText(s, { text: "Sign Up", x: 28, y: 170, size: 28, weight: "Bold", family: "Lora", color: "#2B1A12" });
  addText(s, { text: "Buat akun untuk memulai menjelajahi budaya Jawa!", x: 28, y: 210, width: 356, size: 13, family: "Lora", color: "#6B5845", lineSpacing: 18 });

  const fn = figma.createFrame(); s.appendChild(fn); fn.x = 28; fn.y = 265; fn.resize(356, 52); fn.fills = solidPaint("#E3CDAB"); fn.cornerRadius = 12; fn.paddingLeft = 16; fn.layoutMode = "HORIZONTAL"; fn.counterAxisAlignItems = "CENTER"; fn.layoutSizingHorizontal = "FIXED"; fn.layoutSizingVertical = "FIXED";
  addText(fn, { text: nVal || "Nama Lengkap", size: 14, weight: nVal ? "Medium" : "Regular", family: "Lora", color: nVal ? "#2B1A12" : "#5F4E3C" });

  const fe = figma.createFrame(); s.appendChild(fe); fe.x = 28; fe.y = 330; fe.resize(356, 52); fe.fills = solidPaint("#E3CDAB"); fe.cornerRadius = 12; fe.paddingLeft = 16; fe.layoutMode = "HORIZONTAL"; fe.counterAxisAlignItems = "CENTER"; fe.layoutSizingHorizontal = "FIXED"; fe.layoutSizingVertical = "FIXED";
  addText(fe, { text: eVal || "Email", size: 14, weight: eVal ? "Medium" : "Regular", family: "Lora", color: eVal ? "#2B1A12" : "#5F4E3C" });

  const fp = figma.createFrame(); s.appendChild(fp); fp.x = 28; fp.y = 395; fp.resize(356, 52); fp.fills = solidPaint("#E3CDAB"); fp.cornerRadius = 12; fp.paddingLeft = 16; fp.layoutMode = "HORIZONTAL"; fp.counterAxisAlignItems = "CENTER"; fp.layoutSizingHorizontal = "FIXED"; fp.layoutSizingVertical = "FIXED";
  addText(fp, { text: pVal || "Password", size: pVal ? 18 : 14, weight: pVal ? "Bold" : "Regular", family: pVal ? "Inter" : "Lora", color: pVal ? "#2B1A12" : "#5F4E3C" });

  const btnS = figma.createFrame(); s.appendChild(btnS); btnS.x = 28; btnS.y = 470; btnS.resize(356, 52); btnS.fills = solidPaint("#3A261D"); btnS.cornerRadius = 12; btnS.layoutMode = "HORIZONTAL"; btnS.primaryAxisAlignItems = "CENTER"; btnS.counterAxisAlignItems = "CENTER"; btnS.layoutSizingHorizontal = "FIXED"; btnS.layoutSizingVertical = "FIXED";
  addText(btnS, { text: "Sign Up", size: 16, weight: "Bold", family: "Lora", color: "#FFFBF4" });

  addRect(s, { x: 28, y: 550, width: 140, height: 1, fill: "#C8B69A" });
  addText(s, { text: "atau", x: 180, y: 541, width: 52, size: 13, family: "Lora", color: "#6B5845", align: "CENTER" });
  addRect(s, { x: 244, y: 550, width: 140, height: 1, fill: "#C8B69A" });

  const bg = figma.createFrame(); s.appendChild(bg); bg.x = 28; bg.y = 580; bg.resize(172, 50); bg.fills = solidPaint("#E3CDAB"); bg.cornerRadius = 12; bg.layoutMode = "HORIZONTAL"; bg.primaryAxisAlignItems = "CENTER"; bg.counterAxisAlignItems = "CENTER"; bg.layoutSizingHorizontal = "FIXED"; bg.layoutSizingVertical = "FIXED";
  addText(bg, { text: "G  Google", size: 14, weight: "Bold", family: "Inter", color: "#2B1A12" });

  const ba = figma.createFrame(); s.appendChild(ba); ba.x = 212; ba.y = 580; ba.resize(172, 50); ba.fills = solidPaint("#E3CDAB"); ba.cornerRadius = 12; ba.layoutMode = "HORIZONTAL"; ba.primaryAxisAlignItems = "CENTER"; ba.counterAxisAlignItems = "CENTER"; ba.layoutSizingHorizontal = "FIXED"; ba.layoutSizingVertical = "FIXED";
  addText(ba, { text: "  Apple", size: 14, weight: "Bold", family: "Inter", color: "#2B1A12" });

  const br = figma.createFrame(); s.appendChild(br); br.x = 28; br.y = 660; br.resize(356, 30); br.fills = []; br.layoutMode = "HORIZONTAL"; br.primaryAxisAlignItems = "CENTER"; br.itemSpacing = 6;
  addText(br, { text: "Sudah punya akun?", size: 13, family: "Lora", color: "#6B5845" });
  addText(br, { text: "Log In", size: 13, weight: "Bold", family: "Lora", color: "#3A261D" });
}

// 12 — Sign Up Default
const s12 = figma.createFrame(); sec1.appendChild(s12); s12.name = "12 — Sign Up (Default State)"; s12.x = sx; s12.y = yPos; s12.resize(412, 917); s12.fills = solidPaint("#F4E9D8"); s12.cornerRadius = 28; s12.clipsContent = true;
buildSignUpBase(s12);
sx += 492;

// 13 — Sign Up Typing
const s13 = figma.createFrame(); sec1.appendChild(s13); s13.name = "13 — Sign Up (Typing State)"; s13.x = sx; s13.y = yPos; s13.resize(412, 917); s13.fills = solidPaint("#F4E9D8"); s13.cornerRadius = 28; s13.clipsContent = true;
buildSignUpBase(s13, "Raden Mas Arya", "raden.arya@");
sx += 492;

// 14 — Sign Up Filled
const s14 = figma.createFrame(); sec1.appendChild(s14); s14.name = "14 — Sign Up (Filled State)"; s14.x = sx; s14.y = yPos; s14.resize(412, 917); s14.fills = solidPaint("#F4E9D8"); s14.cornerRadius = 28; s14.clipsContent = true;
buildSignUpBase(s14, "Raden Mas Arya", "raden.arya@javara.id", "••••••••••••");

return "Section 1 (Onboarding & Auth - 14 Screens) created successfully!";