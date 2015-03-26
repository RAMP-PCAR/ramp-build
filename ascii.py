#!/usr/bin/env python
import re

ascii = open("ascii.txt", "r").read()
am = open("ascii_mangled.txt", "w")

#ascii = re.sub(r"\"", "\\\"", ascii)

stringified = str(ascii)

stringified = re.sub(r"\"", "\\\"", stringified)
stringified = re.sub(r"\\", "\\\\", stringified)
stringified = re.sub(r"\\n", "\\\\n", stringified)

am.write(stringified)
am.close()

print stringified