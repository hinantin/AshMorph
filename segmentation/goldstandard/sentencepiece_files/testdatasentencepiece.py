import sys
reload(sys)
sys.setdefaultencoding('utf8')
import sentencepiece as spm
sp = spm.SentencePieceProcessor()
sp.Load('spm.model')

f=open("../sentences.pan-ashaninka.test", "r")
Lines = f.readlines() 

for line in Lines: 
  txt = line.decode('utf-8').strip()
  pieces = sp.EncodeAsPieces(txt)
  print('@@'.join(pieces).encode('utf-8').replace(u'_',' '))
  #words = txt.split(" ")
  #for word in words:
  #  sp.NBestEncodeAsPieces(word, 1)
  #  print(sp.SampleEncodeAsPieces(word, -1, 0.1))
  #print("\n")