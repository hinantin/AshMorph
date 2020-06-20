#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import sys, getopt

from foma import FST

fst = FST.load('orthography.bin')
word = 'ejAti'
word = word.lower()
numberresults = 0
Results = []
Results.append(word) 
for result in fst.apply_up(word):
    if result not in Results or numberresults < 1:
        print result
        numberresults += 1

