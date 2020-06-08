#!/bin/bash
set -x

########################################################
## ADAPT THESE PATH DECLARATIONS TO YOUR INSTALLATION ##
########################################################

# path to the compiled xfst analyzers, either from the git repository, or the package AshaninkaMorph from https://github.com/hinantin/AshaninkaMorph
export ASHANINKAMORPH_DIR=/home/ubuntu/hinantin/AshaninkaMorph

#export WAPITI=/home/richard/Downloads/01_Instaladores/wapiti/wapiti-1.5.0/wapiti
export WAPITI=/home/ubuntu/hinantin/Wapiti/wapiti
export LOOKUP_DIR=/home/ubuntu/hinantin/bin
export TMP_DIR=/tmp
export SEGMENTER=/home/ubuntu/hinantin/AshaninkaMorph/segmentation

## Models to disambiguate words
MORPH1_MODEL=$SEGMENTER/models/pan-ashaninka.model
MORPH2_MODEL=$SEGMENTER/models/pan-ashaninka.model2
MORPH3_MODEL=$SEGMENTER/models/pan-ashaninka.model3
MORPH4_MODEL=$SEGMENTER/models/pan-ashaninka.model4

RAW_FILE=$1

filename_w_ext=$(basename "$RAW_FILE")
filename_no_ext="${filename_w_ext%.*}"
TMPFILENAME=TMPNM$filename_no_ext

#echo "filename is $filename_no_ext"

# (1) XFST 
/usr/bin/perl /home/hinantin/ashaninka/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < $RAW_FILE > $TMP_DIR/$RAW_FILE.tok
cat $TMP_DIR/$RAW_FILE.tok | /usr/bin/perl $SEGMENTER/tokenize.pl | $LOOKUP_DIR/lookup $ASHANINKAMORPH_DIR/asheninka.bin -flags cKv29TT > $TMP_DIR/$filename_no_ext.test.xfst

# (2) CRF before|after
###cat $TMP_DIR/$filename_no_ext.test.xfst | perl $SEGMENTER/cleanGuessedRoots.pl -$EVID -$PISPAS > $TMP_DIR/$TMPFILENAME.test_clean.xfst
#cat $TMP_DIR/$TMPFILENAME.test_clean.xfst | perl $SEGMENTER/xfst2wapiti_pos.pl -test > $TMP_DIR/$TMPFILENAME.pos.test
cp $TMP_DIR/$filename_no_ext.test.xfst $TMP_DIR/$TMPFILENAME.test_clean.xfst
cat $TMP_DIR/$filename_no_ext.test.xfst | /usr/bin/perl $SEGMENTER/xfst2wapiti_pos.pl -test > $TMP_DIR/$TMPFILENAME.pos.test

$WAPITI label -m $MORPH1_MODEL $TMP_DIR/$TMPFILENAME.pos.test > $TMP_DIR/$TMPFILENAME.morph1.result

/usr/bin/perl $SEGMENTER/disambiguateRoots.pl $TMP_DIR/$TMPFILENAME.morph1.result $TMP_DIR/$TMPFILENAME.test_clean.xfst > $TMP_DIR/$TMPFILENAME.morph1.disamb

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -1 $TMP_DIR/$TMPFILENAME.morph1.disamb > $TMP_DIR/$TMPFILENAME.morph2.test

$WAPITI label -m $MORPH2_MODEL $TMP_DIR/$TMPFILENAME.morph2.test > $TMP_DIR/$TMPFILENAME.morph2.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -2 $TMP_DIR/$TMPFILENAME.morph2.result > $TMP_DIR/$TMPFILENAME.morph3.test

$WAPITI label -m $MORPH3_MODEL $TMP_DIR/$TMPFILENAME.morph3.test > $TMP_DIR/$TMPFILENAME.morph3.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -3 $TMP_DIR/$TMPFILENAME.morph3.result > $TMP_DIR/$TMPFILENAME.morph4.test

$WAPITI label -m $MORPH4_MODEL $TMP_DIR/$TMPFILENAME.morph4.test > $TMP_DIR/$TMPFILENAME.morph4.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -4 $TMP_DIR/$TMPFILENAME.morph4.result > $TMP_DIR/$filename_no_ext.disamb.xfst

# (3) Morfessor before|after
# convert xfst to morfessor
cat $TMP_DIR/$filename_no_ext.disamb.xfst | /usr/bin/perl $SEGMENTER/xfst2morfessor.pl ##> $TMP_DIR/$filename_no_ext.morfessor

