perl search.pl > sentences.pan-ashaninka
mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < sentences.pan-ashaninka > sentences.tok.pan-ashaninka
mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.en < sentences.tok.pan-ashaninka > sentences.true.pan-ashaninka
morfessor -t sentences.true.pan-ashaninka -S model.segm -T testdata.txt

morfessor -t sentences.pan-ashaninka.training -S sentences.pan-ashaninka.segm -T sentences.pan-ashaninka.test

morfessor-train --encoding=ISO_8859-15 --traindata-list --logfile=log.log -s model.bin -d ones sentences.pan-ashaninka.segm
python testdata.py

# Wordform number 
#  perl AshaninkaMorph/tokenize.pl sentences.tok.pan-ashaninka | sort | uniq -c | sort -rnb | wc -l

#(['pa', 'va'], 13.63206769327279)
#(['vi', 'tsi', 'ki', 'ro', 'ri'], 35.38994413454433)
#(['kipatsi', 'pa', 'ye'], 21.20642081758134)
#(['pi', 'to', 'tsi'], 19.94535904627127)
