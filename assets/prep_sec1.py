with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15539_call_0.js", "r", encoding="utf-8") as f:
    code = f.read()

code = code.replace("sec1.resize(7100, 1100);", "sec1.resizeWithoutConstraints(7100, 1100);")
with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_1.js", "w", encoding="utf-8") as f:
    f.write(code)

print("Saved run_section_1.js successfully.")
