with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2_3.js", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Find split point at Section 3
split_idx = -1
for i, line in enumerate(lines):
    if "SECTION 3: JELAJAH JAWA" in line:
        split_idx = i
        break

print("Split index:", split_idx)

# Header helpers are lines 0 to split_idx where Section 2 starts
sec2_start_idx = -1
for i, line in enumerate(lines[:split_idx]):
    if "SECTION 2: BERANDA" in line:
        sec2_start_idx = i
        break

header = lines[:sec2_start_idx]
sec2_body = lines[sec2_start_idx:split_idx]
sec3_body = lines[split_idx:]

with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_2.js", "w", encoding="utf-8") as f:
    f.writelines(header)
    f.writelines(sec2_body)
    f.write('\nreturn "Section 2 created successfully!";\n')

with open(r"c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\run_section_3.js", "w", encoding="utf-8") as f:
    f.writelines(header)
    f.writelines(sec3_body)
    # sec3_body already has the return statement

print("Saved run_section_2.js and run_section_3.js successfully.")
