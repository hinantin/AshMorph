#rm -f PossibleLemmasForTrain PossibleMorphsForTrain PossibleRootsForTrain
/usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/search_xfst.pl > /home/hinantin/ashaninka/AshaninkaMorph/segmentation/sentences.pan-ashaninka.xfst
###cat /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/sentences.pan-ashaninka.xfst | /usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/getPossibleRootsForTrain.pl
# POS 
###cat sentences.pan-ashaninka.xfst | /usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/xfst2wapiti_pos.pl -train > /home/hinantin/ashaninka/Wapiti/dat/pan-ashaninka.train.txt
###cd /home/hinantin/ashaninka/Wapiti && /home/hinantin/ashaninka/Wapiti/wapiti train -p model/pan-ashaninka.pattern.txt -1 5 model/pan-ashaninka.train.txt /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.model
# model 2
cat /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/sentences.pan-ashaninka.xfst | /usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/xfst2wapiti_morphTrain.pl -1 -train > /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.train.txt.model2
cd /home/hinantin/ashaninka/Wapiti && /home/hinantin/ashaninka/Wapiti/wapiti train -p models/pan-ashaninka.pattern.txt.model2 -1 5 /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.train.txt.model2 /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.model2
# model 3
###cat /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/sentences.pan-ashaninka.xfst | /usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/xfst2wapiti_morphTrain.pl -2 -train > /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.train.txt.model3
###cd /home/hinantin/ashaninka/Wapiti && /home/hinantin/ashaninka/Wapiti/wapiti train -p models/pan-ashaninka.pattern.txt.model3 -1 5 /home/hinantin/ashaninka/Wapiti/dat/pan-ashaninka.train.txt.model3 /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.model3
# model 4
###cat /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/sentences.pan-ashaninka.xfst | /usr/bin/perl /home/hinantin/ashaninka/AshaninkaMorph/segmentation/xfst2wapiti_morphTrain.pl -3 -train > /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.train.txt.model4
###(cd /home/hinantin/ashaninka/Wapiti && /home/hinantin/ashaninka/Wapiti/wapiti train -p models/pan-ashaninka.pattern.txt.model4 -1 5 /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.train.txt.model4 /home/hinantin/ashaninka/AshaninkaMorph/segmentation/models/pan-ashaninka.model4)
#cd /home/hinantin/ashaninka/Wapiti/wapiti train -p /home/hinantin/squoia/morphology/disambiguation/crf++_version/crf_config_pos -1 5 train.txt model