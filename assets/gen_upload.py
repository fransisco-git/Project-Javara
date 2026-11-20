import json

with open(r'c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\images_b64.json', 'r') as f:
    data = json.load(f)

candi = data['candi_bg']
script = f"""
const b64 = "{candi}";
const img = figma.createImage(figma.base64Decode(b64));
return {{ hash: img.hash }};
"""

with open(r'c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\upload_single.js', 'w', encoding='utf-8') as sf:
    sf.write(script)
print("Saved upload_single.js successfully.")
