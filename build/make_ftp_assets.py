#!/usr/bin/env python3
"""
Builds the FTP payload:  flag.abc  (a ZIP with the wrong extension)
  - flag2.txt      : Flag 2, encoded as binary
  - hammerhead.jpg : Flag 3, embedded in the image

Usage: make_ftp_assets.py <output_dir> [path_to_hammerhead_image]

"""
import sys, os, zipfile, shutil

out_dir = sys.argv[1] if len(sys.argv) > 1 else "."
os.makedirs(out_dir, exist_ok=True)

# Flag 3 
# Resolve the image: 2nd CLI arg wins, else look beside this script.
here = os.path.dirname(os.path.abspath(__file__))
img_src = sys.argv[2] if len(sys.argv) > 2 else os.path.join(here, "hammerhead.jpg")

if not os.path.isfile(img_src):
    sys.exit(
        "ERROR: hammerhead image not found at '%s'.\n"
        "Put your flag-embedded image at build/hammerhead.jpg "
        "(or pass its path as the 2nd argument)." % img_src
    )

img_name = os.path.basename(img_src)

# Flag 2 : binary-encoded text
FLAG2_BINARY = (
    "01001100 01000011 01000011 01010100 01000110 01111011 01000111 01110010 "
    "00110011 00110011 01101110 01001100 00110100 01001110 01100100 00110100 "
    "00110000 00110000 01111101 00100000 01000111 01110010 01100101 01100101 "
    "01101110 01101100 01100001 01101110 01100100 00100000 01110011 01101000 "
    "01100001 01110010 01101011 01110011 00100000 01100011 01100001 01101110 "
    "00100000 01101100 01101001 01110110 01100101 00100000 01100001 01110010 "
    "01101111 01110101 01101110 01100100 00100000 00110100 00110000 00110000 "
    "00100000 01111001 01100101 01100001 01110010 01110011"
)
work = os.path.join(out_dir, "_work")
os.makedirs(work, exist_ok=True)
flag2_path = os.path.join(work, "flag2.txt")
with open(flag2_path, "w") as f:
    f.write(FLAG2_BINARY + "\n")

# zip it up and disguise the extension
abc_path = os.path.join(out_dir, "flag.abc")
if os.path.exists(abc_path):
    os.remove(abc_path)
with zipfile.ZipFile(abc_path, "w", zipfile.ZIP_DEFLATED) as z:
    z.write(flag2_path, "flag2.txt")
    z.write(img_src, img_name)

# cleanup
os.remove(flag2_path)
os.rmdir(work)

print("Wrote", abc_path, "(", os.path.getsize(abc_path), "bytes ) using image:", img_name)