with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15542_call_0.js", "r", encoding="utf-8") as f:
    lines = f.readlines()
print("Total lines in 15542:", len(lines))
for i, line in enumerate(lines):
    if "createSection" in line:
        print(f"Line {i}: {line.strip()}")
