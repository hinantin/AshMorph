#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import sys, getopt
from foma import FST

def main(argv):
   inputfile = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'normalize.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'normalize.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   print 'Input file is :', inputfile
   print 'Output file is :', outputfile
   fst = FST.load('orthography.fst')
   word = 'ejAti'
   # reading input file 
   finput = open(inputfile)
   try:
      finput.seek(0) # always add 
      lines = finput.readlines()
   finally:
      finput.close()
   # processing words 
   word = word.lower()
   numberresults = 0
   Results = []
   Results.append(word) 
   for result in fst.apply_up(word):
       if result not in Results or numberresults < 1:
           print result
           numberresults += 1

if __name__ == "__main__":
   main(sys.argv[1:])
