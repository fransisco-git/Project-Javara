with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2_3.js", "r", encoding="utf-8") as f:
    code = f.read()
print("Top 200 chars:\n", code[:200])
print("Bottom 200 chars:\n", code[-200:])
