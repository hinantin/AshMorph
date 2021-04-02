#!/bin/bash
#set -x

########################################################
## ADAPT THESE PATH DECLARATIONS TO YOUR INSTALLATION ##
########################################################

# path to the compiled xfst analyzers, either from the git repository, or the package AshaninkaMorph from https://github.com/hinantin/AshaninkaMorph
#export ASHANINKAMORPH_DIR=/home/hinantin/ashaninka/AshaninkaMorph
#export WAPITI=/home/hinantin/ashaninka/Wapiti/wapiti
#export LOOKUP_DIR=/usr/bin
#export TMP_DIR=/tmp
#export SEGMENTER=/home/hinantin/ashaninka/AshaninkaMorph/segmentation
#export MOSES=/home/hinantin/ashaninka/mosesdecoder
export ASHANINKAMORPH_DIR=/home/richard/Downloads/AshMorph
export WAPITI=/home/richard/Downloads/Wapiti/wapiti
export LOOKUP_DIR=/home/richard/Downloads/foma/foma
export TMP_DIR=/tmp
export SEGMENTER=/home/richard/Downloads/AshMorph/code
export MOSES=/home/richard/Downloads/mosesdecoder
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
/usr/bin/perl $MOSES/scripts/tokenizer/tokenizer.perl -l en < $RAW_FILE > $TMP_DIR/$filename_no_ext.tok
/bin/sed 's/.*/& #EOS/' $TMP_DIR/$filename_no_ext.tok > $TMP_DIR/$filename_no_ext.EOS.tok
#cat $TMP_DIR/$filename_no_ext.EOS.tok | /usr/bin/perl $SEGMENTER/tokenize.pl | $LOOKUP_DIR/flookup $ASHANINKAMORPH_DIR/asheninka.bin > $TMP_DIR/$filename_no_ext.test.xfst
cat $TMP_DIR/$filename_no_ext.EOS.tok | /usr/bin/perl $SEGMENTER/tokenize.pl | perl $SEGMENTER/fomaClient.pl -P 8981 -H localhost --stdin > $TMP_DIR/$filename_no_ext.test.xfst 
#tail $TMP_DIR/$filename_no_ext.test.xfst 
# (2) CRF before|after
cp $TMP_DIR/$filename_no_ext.test.xfst $TMP_DIR/$TMPFILENAME.test_clean.xfst
cat $TMP_DIR/$filename_no_ext.test.xfst | /usr/bin/perl $SEGMENTER/xfst2wapiti_pos.pl -test > $TMP_DIR/$TMPFILENAME.pos.test

# -------------
#      POS
# -------------
# INPUT CRF MATRIX -> OUTPUT CRF MATRIX
$WAPITI label -m $MORPH1_MODEL $TMP_DIR/$TMPFILENAME.pos.test > $TMP_DIR/$TMPFILENAME.morph1.result

# INPUT CRF MATRIX + ORIGINAL XFST -> CRF MATRIX 
/usr/bin/perl $SEGMENTER/disambiguateRoots.pl $TMP_DIR/$TMPFILENAME.morph1.result $TMP_DIR/$TMPFILENAME.test_clean.xfst > $TMP_DIR/$TMPFILENAME.morph1.disamb

# INPUT XFST -> OUTPUT CRF MATRIX + DATA-STRUCTURE @words in /tmp/prevdisambMorph1 and /tmp/words1 
/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -1 $TMP_DIR/$TMPFILENAME.morph1.disamb > $TMP_DIR/$TMPFILENAME.morph2.test

# -------------
#      1
# -------------
# INPUT CRF MATRIX -> OUTPUT CRF MATRIX
$WAPITI label -m $MORPH2_MODEL $TMP_DIR/$TMPFILENAME.morph2.test > $TMP_DIR/$TMPFILENAME.morph2.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -2 $TMP_DIR/$TMPFILENAME.morph2.result > $TMP_DIR/$TMPFILENAME.morph3.test

# -------------
#      2
# -------------
$WAPITI label -m $MORPH3_MODEL $TMP_DIR/$TMPFILENAME.morph3.test > $TMP_DIR/$TMPFILENAME.morph3.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -3 $TMP_DIR/$TMPFILENAME.morph3.result > $TMP_DIR/$TMPFILENAME.morph4.test

# -------------
#      3
# -------------
$WAPITI label -m $MORPH4_MODEL $TMP_DIR/$TMPFILENAME.morph4.test > $TMP_DIR/$TMPFILENAME.morph4.result

/usr/bin/perl $SEGMENTER/xfst2wapiti_morphTest.pl -4 $TMP_DIR/$TMPFILENAME.morph4.result > $TMP_DIR/$filename_no_ext.disamb.xfst

# (3) Plain text before|after
# convert xfst to plain text
cat $TMP_DIR/$filename_no_ext.disamb.xfst | /usr/bin/perl $SEGMENTER/xfst2plaintext.pl ##> $TMP_DIR/$filename_no_ext.morfessor
tail $TMP_DIR/$filename_no_ext.disamb.xfst 
# Deleting temporary files 
rm -f $TMP_DIR/$filename_no_ext.tok $TMP_DIR/$filename_no_ext.EOS.tok $TMP_DIR/$filename_no_ext.test.xfst $TMP_DIR/$TMPFILENAME.test_clean.xfst $TMP_DIR/$TMPFILENAME.pos.test $TMP_DIR/$TMPFILENAME.morph1.result $TMP_DIR/$TMPFILENAME.morph2.test $TMP_DIR/$TMPFILENAME.morph2.result $TMP_DIR/$TMPFILENAME.morph3.test $TMP_DIR/$TMPFILENAME.morph3.result $TMP_DIR/$TMPFILENAME.morph4.test $TMP_DIR/$TMPFILENAME.morph4.result $TMP_DIR/$filename_no_ext.disamb.xfst /tmp/words1 /tmp/words2 /tmp/words3 /tmp/prevdisambMorph1 /tmp/totalAmbigForms 
