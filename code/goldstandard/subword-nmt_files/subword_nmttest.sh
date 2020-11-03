# Learn a vocabulary using 1,000 merge operations 
python /home/hinantin/ashaninka/subword-nmt/subword_nmt/learn_bpe.py -s 1000 < sentences.pan-ashaninka.training > subword-nmt_files/pan-ashaninka.codes.bpe
# Apply the vocabulary to the training file
python /home/hinantin/ashaninka/subword-nmt/subword_nmt/apply_bpe.py -c subword-nmt_files/pan-ashaninka.codes.bpe < sentences.pan-ashaninka.training > subword-nmt_files/sentences.pan-ashaninka.training.bpe

python /home/hinantin/ashaninka/subword-nmt/subword_nmt/apply_bpe.py -c pan-ashaninka.codes.bpe < ../sentences.pan-ashaninka.test > sentences.pan-ashaninka.test.bpe

python /home/hinantin/ashaninka/subword-nmt/subword_nmt/apply_bpe.py -c /home/hinantin/ashaninka/AshaninkaMorph/segmentation/goldstandard/subword-nmt_files/pan-ashaninka.codes.bpe < ../cni.txt.rand.tok > ../cni.txt.rand.subword-nmt