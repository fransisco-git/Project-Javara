import json, base64

with open(r'c:\Users\Lenovo\Documents\Mobile JAVARA\Javara\assets\images_b64.json', 'r') as f:
    data = json.load(f)

candi = data['candi_bg'].replace('\n', '').replace('\r', '').strip()
print('Length of candi string:', len(candi))
# test if valid base64
decoded = base64.b64decode(candi)
print('Decoded bytes length:', len(decoded))
