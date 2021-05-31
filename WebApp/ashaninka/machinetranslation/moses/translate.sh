#!/bin/bash

export LC_ALL="en_US.UTF-8" 
PATH=/home/hinantin/ashaninka
PATHCORPUS=/tmp
MOSESPATH=/home/hinantin/ashaninka
MODELPATH=/home/hinantin/ashaninka/AshaninkaMT/moses
INPUT=$1
OUTPUT=$2
TRANSLATION=$3
/usr/bin/perl $PATH/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < $INPUT > $OUTPUT
$MOSESPATH/mosesdecoder/bin/moses -f $MODELPATH/working/binarised-model/moses.ini -i $OUTPUT 
#> $TRANSLATION

