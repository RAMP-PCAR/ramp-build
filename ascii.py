#!/usr/bin/env python
import re

ascii = open("ascii.txt", "r").read()
am = open("ascii_mangled.txt", "w")

stringified = str(ascii)

stringified = stringified.encode('unicode_escape')
stringified = re.sub(r"\"", "\\\"", stringified) # escape double quotes since the string will be wrapped in double quotes
stringified = stringified.encode('unicode_escape')
stringified = re.sub(r"\"", "\\\"", stringified)

stringified = '"' + stringified + '"'

am.write(stringified)
am.close()

print stringified