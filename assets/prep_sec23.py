with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15542_call_0.js", "r", encoding="utf-8") as f:
    code = f.read()

# Replace resize on sections
code = code.replace("sec2.resize(2560, 1550);", "sec2.resizeWithoutConstraints(2560, 1550);")
code = code.replace("sec3.resize(2060, 1550);", "sec3.resizeWithoutConstraints(2060, 1550);")

# Remove comp4
code = code.replace("const comp4 = await figma.getNodeByIdAsync('345:818');", "// comp4 removed")

# Add addBottomNavBar definition after addBackButton
nav_func = """
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
"""

code = code.replace("function addBackButton(frame) {", nav_func + "\nfunction addBackButton(frame) {")

# Replace nav occurrences
code = code.replace("if (comp4) { const nav15 = comp4.clone(); s15.appendChild(nav15); nav15.x = -4; nav15.y = 1284; }", "addBottomNavBar(s15, 0);")
code = code.replace("if (comp4) { const nav16 = comp4.clone(); s16.appendChild(nav16); nav16.x = -4; nav16.y = 1284; }", "addBottomNavBar(s16, 0);")
code = code.replace("if (comp4) { const nav20 = comp4.clone(); s20.appendChild(nav20); nav20.x = -4; nav20.y = 1284; }", "addBottomNavBar(s20, 1);")

with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2_3.js", "w", encoding="utf-8") as f:
    f.write(code)

print("Saved run_section_2_3.js successfully. Length:", len(code))
