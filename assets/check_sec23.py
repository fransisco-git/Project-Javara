with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15542_call_0.js", "r", encoding="utf-8") as f:
    lines = f.readlines()
for i in [90, 91, 92, 93, 94, 95, 96, 97, 98, 298, 299, 300, 301, 302, 303, 304, 305]:
    if i < len(lines):
        print(f"{i}: {lines[i].strip()}")
