#!/bin/sh

AVOTSI=/usr/share/hinantin/ashaninka/segmentation

ARCHIVOINPUT=$1
ARCHIVOOUTPUT=$2

python /home/hinantin/ashaninka/subword-nmt/subword_nmt/apply_bpe.py -c $AVOTSI/pan-ashaninka.codes.bpe < $ARCHIVOINPUT > $ARCHIVOOUTPUT 
