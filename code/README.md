### INSTALLATION

```
$ sudo cpan install Config::IniFiles

$ wget https://web.stanford.edu/~laurik/.book2software/fsmbook-software/linux64/bin.tar.gz
$ tar -zxvf bin.tar.gz

$ git clone https://github.com/hinantin/AshMorph
$ cd AshMorph/
$ ../bin/xfst -f asheninka.script
$ cd ..

$ git clone https://github.com/Jekub/Wapiti
$ cd Wapiti/
$ make
$ cd .. 

$ git clone https://github.com/moses-smt/mosesdecoder

$ cd AshaninkaMorph/segmentation/
$ vi segment.sh
% CHANGE THE PATHS ACCORDINGLY 
% I extracted all installers in this path /home/ubuntu/hinantin/
% Then my paths are the following: 
% export ASHANINKAMORPH_DIR=/home/ubuntu/hinantin/AshaninkaMorph
% export WAPITI=/home/ubuntu/hinantin/Wapiti/wapiti
% export LOOKUP_DIR=/home/ubuntu/hinantin/bin
% export TMP_DIR=/tmp
% export SEGMENTER=/home/ubuntu/hinantin/AshaninkaMorph/segmentation
% export MOSES=/home/ubuntu/hinantin/mosesdecoder

% TESTING 
$ bash segment.sh input-file 
```

#### GOLD STANDARD

| FILE                                              | AVERAGE SCORE |
|---------------------------------------------------|---------------|
| sentences.pan-ashaninka.test.bpe.subword-nmt      | 16.3 %        |
| sentences.pan-ashaninka.test.morfessor            | 38.82 %       |
| sentences.pan-ashaninka.test.result.sentencepiece | 37.32 %       |
| sentences.pan-ashaninka.test.ashaninkamorph       | 74.49 %       |

