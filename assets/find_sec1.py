with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15539_call_0.js", "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "sec1" in line:
            print(f"{i}: {line.strip()}")
