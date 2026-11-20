with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2_3.js", "r", encoding="utf-8") as f:
    code = f.read()

if "figma.loadFontAsync" not in code:
    font_code = """
await Promise.all([
  figma.loadFontAsync({ family: "Inter", style: "Regular" }),
  figma.loadFontAsync({ family: "Inter", style: "Medium" }),
  figma.loadFontAsync({ family: "Inter", style: "Bold" }),
  figma.loadFontAsync({ family: "Lora", style: "Regular" }),
  figma.loadFontAsync({ family: "Lora", style: "Bold" })
]);
"""
    code = font_code + code
    with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2_3.js", "w", encoding="utf-8") as f:
        f.write(code)
    print("Added font preloading to run_section_2_3.js")
else:
    print("Fonts already present")
