#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import modules for CGI handling 
import cgi, cgitb 
import sys
reload(sys)
sys.setdefaultencoding('utf8')
import os
import sentencepiece as spm
import morfessor

import tempfile
import shlex, subprocess

# Create instance of FieldStorage 
arguments = cgi.FieldStorage() 

# Get data from fields
nyaantsi = ''
nyaantsi = arguments["nyaantsi"].value
segmentationtool = arguments["segmentationtool"].value
callback = arguments["callback"].value

if segmentationtool == "sentencepiece":
  # SENTENCE PIECE
  sp = spm.SentencePieceProcessor()
  sp.Load('/usr/share/hinantin/ashaninka/segmentation/spm.model')
  pieces = sp.EncodeAsPieces(nyaantsi)
  shitovaantsi = '@@'.join(pieces).encode('utf-8').replace(u'_',' ')
elif segmentationtool == "morfessor":
  # MORFESSOR
  io = morfessor.MorfessorIO()
  model = io.read_binary_model_file('/usr/share/hinantin/ashaninka/segmentation/model.bin')
  pieces = model.viterbi_segment(nyaantsi)[0]
  shitovaantsi = '@@'.join(pieces).encode('utf-8').replace(u'_',' ')
else:
  # SUBWORD-NMT
  fpname = ''
  fp = tempfile.NamedTemporaryFile(prefix='swnmtin',delete=False,mode='w+t')
  fpname = fp.name
  fp.write(nyaantsi)
  fp.flush()
  
  foutname = ''
  fout = tempfile.NamedTemporaryFile(prefix='swnmtout',delete=False,mode='w+')
  foutname = fout.name

  shitovaantsi = ''
  cmd = ''
  #try:
  cmd = "/bin/bash /usr/lib/cgi-bin/ashaninka/subword_nmt.sh " + fpname + " " + foutname
  #args = shlex.split(cmd)
  # returns output as byte string
  #p = subprocess.Popen(args)
  #except subprocess.CalledProcessError as e:
  #shitovaantsi = e.output
  exit_code = os.system(cmd)
  assert exit_code == 0
  fout.seek(0) # always add 
  lines = fout.readlines()

  shitovaantsi = nyaantsi + '\t' + ''.join(lines)
  fp.close()
  fout.close()

shitovaantsi = shitovaantsi.replace("\n", "\\n")
shitovaantsi = shitovaantsi.replace("\"", '\\"')
print "Content-Type: application/json\n"
print callback + '(\"' + shitovaantsi + '\")'
