#!/bin/sh

AVOTSI=/usr/share/hinantin
TOKENIZERPATH=/home/hinantin/ashaninka/AshaninkaMorph

ARCHIVO=$1

cat $ARCHIVO | perl $TOKENIZERPATH/tokenize.pl | $AVOTSI/lookup $AVOTSI/asheninka.xfst.bin 

 
