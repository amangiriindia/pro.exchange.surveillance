from PIL import Image
from collections import Counter

img = Image.open('assets/images/bazaar_logo.png')
img = img.convert('RGB')
img.thumbnail((150, 150))
pixels = list(img.getdata())
counter = Counter(pixels)
print(counter.most_common(10))
