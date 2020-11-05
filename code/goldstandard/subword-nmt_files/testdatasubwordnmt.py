import sys
sys.path
from apply_bpe import BPE

bpe = BPE('pan-ashaninka.codes.bpe')

f=open("../cni.txt.rand.tok", "r")
Lines = f.readlines() 

for line in Lines: 
  out = bpe.process_line(line)
  print(out)