import sys
sys.path
from apply_bpe import BPE

bpe = BPE('pan-ashaninka.codes.bpe')
out = bpe.process_line("mapipaye")
print(out)