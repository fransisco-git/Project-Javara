import re

for fpath in [r'c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15491_call_0.js', r'c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\step_15539_call_0.js']:
    print("File:", fpath)
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()
    matches = re.findall(r'name\s*=\s*["\']([^"\']+)["\']', content)
    for m in matches:
        if any(keyword in m for keyword in ['—', 'ALUR', 'Screen', 'Alur', 'Default', 'State', 'Modal', 'Utama', 'Detail', 'Kuis', 'Paspor']):
            print("  ", m)
