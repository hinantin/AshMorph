#!/bin/sh

export LC_ALL="en_US.UTF-8" 

FREELINGINSTALLPATH=/home/hinantin/FreeLing_install
MATXININSTALLPATH=/home/hinantin/squoia/MT_systems/matxin-lex
TEMPPATH=/usr/share/hinantin/ashaninka/machinetranslation
export FREELINGSHARE=$FREELINGINSTALLPATH/share/freeling
export LD_LIBRARY_PATH=$FREELINGINSTALLPATH/lib
CONFIG=$FREELINGINSTALLPATH/share/freeling/config

INPUT=$1
OUTPUT=$2
XML=$3

$FREELINGINSTALLPATH/bin/analyzer_client localhost:50005 <$INPUT >$OUTPUT

perl $TEMPPATH/conll2xml.pm $OUTPUT | tee $XML 
cat $XML | $MATXININSTALLPATH/squoia_xfer_lex $TEMPPATH/en-cni.bin 

