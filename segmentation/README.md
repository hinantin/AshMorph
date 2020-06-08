### INSTALLATION

```
$ wget https://web.stanford.edu/~laurik/.book2software/fsmbook-software/linux64/bin.tar.gz
$ tar -zxvf bin.tar.gz

$ git clone https://github.com/hinantin/AshaninkaMorph
$ cd AshaninkaMorph/
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
% /home/ubuntu/hinantin/AshaninkaMorph/
% For example 
export ASHANINKAMORPH_DIR=/home/ubuntu/hinantin/AshaninkaMorph
export WAPITI=/home/ubuntu/hinantin/Wapiti/wapiti
export WAPITI_DIR=/home/ubuntu/hinantin/Wapiti
export TMP_DIR=/tmp
export SEGMENTER=/home/ubuntu/hinantin/AshaninkaMorph/segmentation

% TESTING 
$ bash segment.sh input-file 
```