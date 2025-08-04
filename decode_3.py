import sys
from Hidoku import Hidoku

if len(sys.argv) < 2:
	print("decode.py [hidoku game] [output file]")
h = Hidoku(sys.argv[1])
if sys.argv[2]=="-":
	h.decode(sys.stdin)
else:
	with open(sys.argv[2],"r") as f:
		h.decode(f)