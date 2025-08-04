import sys
from Nonogram import Nonogram

if len(sys.argv) < 2:
	print("decode.py [hidoku game] [output file]")
n = Nonogram(sys.argv[1])
if sys.argv[2]=="-":
	n.decode(sys.stdin)
else:
	with open(sys.argv[2],"r") as f:
		n.decode(f)