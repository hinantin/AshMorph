DROPBOXPATH=/home/richard/Descargas/RCastroq/dropbox/Dropbox/05_Ashaninca/05_Morfologia/Ashaninka_Morph/xml
TOKENIZERPATH=/home/richard/Documents/git/02_AshaninkaMorph_GoogleCode/hntAshaninka/morphology/AshaninkaMorph/generated_states_transitions

updateservice:
	@foma -f asheninka.script
	@cp asheninka.bin /usr/share/hinantin/
	@/etc/init.d/tcpServerFoma restart
	@xfst -f asheninka.script
	@cp asheninka.bin /usr/share/hinantin/asheninka.xfst.bin

updatespellchecker:
	@sed 's/\.o\. Orthography/#\.o\. Orthography/g' asheninka.script > asheninka.script.bak
	@foma -f asheninka.script.bak
	@cp asheninka.bin /usr/share/hinantin/error_detection.fst
	@rm -f asheninka.script.bak
	@sed 's/\.o\. Orthography/#\.o\. Orthography/g' asheninka.script > asheninka.script.bak
	@perl -pi.bak -e 's/read regex Ashaninka;/#read regex Ashaninka;/g' asheninka.script.bak
	@perl -pi.bak -e 's/save stack asheninka.bin/#save stack asheninka.bin/g' asheninka.script.bak
	@perl -pi.bak -e 's/#read regex Ashaninka .l;/read regex Ashaninka .l;/g' asheninka.script.bak
	@perl -pi.bak -e 's/#write att spellcheck.att/write att spellcheck.att/g' asheninka.script.bak
	@perl -pi.bak -e 's/#clear /clear /g' asheninka.script.bak
	@perl -pi.bak -e 's/#read att spellcheck.att/read att spellcheck.att/g' asheninka.script.bak
	@perl -pi.bak -e 's/#read cmatrix typo.matrix/read cmatrix typo.matrix/g' asheninka.script.bak
	@perl -pi.bak -e 's/#save stack error_correction.fst/save stack error_correction.fst/g' asheninka.script.bak
	@foma -f asheninka.script.bak
	@cp error_correction.fst /usr/share/hinantin/error_correction.fst
	@rm -f asheninka.script.bak asheninka.script.bak.bak error_correction.fst
	@ /etc/init.d/tcpServerErrorDetection restart
	@ /etc/init.d/tcpServerErrorCorrection restart

compile:
	@rm -f n-vroot.prq.group1.foma | perl extractEntries.pl --file nroot.prq.foma --file nroot.es.foma --file aroot.prq.foma --file ideo.prq.foma --file numeral.prq.foma --file nroot.qu.foma --file oroot.prq.foma --outputfilename "n-vroot.prq.group1.foma" --label "N@->V" --title "Verbalized entries" --header "NounToVerbPRQin" --replace2 1 --source2 "\" : {" --target2 "[^VBZ]\" : {"
	@rm -f v-nroot.prq.group1.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "v-nroot.prq.group1.foma" --label "V@->N" --title "Nominalized entries" --header "VerbToNounPRQin" --replace2 1 --source2 "\" : {" --target2 "[^NMZ]\" : {"
	@rm -f noun.cmp.prq.foma | perl extractEntries.pl --file nroot.prq.foma --file ideo.prq.foma --file numeral.prq.foma --outputfilename "noun.cmp.prq.foma" --label "@CMP" --title "Compound nouns" --header "NRootCmpPRQin" --separator 1
	@rm -f verb.composition.prq.foma | perl extractEntries.pl --file nroot.prq.foma --file aroot.prq.foma --outputfilename "verb.composition.prq.foma" --label "@VCMP" --title "NOUN INCORPORATION (Verb-noun composition)" --header "V=S=noun" --separator 1 --replace1 1 --replace3 1 --source3 "NRoot" --target3 "IncNRoot"
	@rm -f verb.composition.len.prq.foma | perl extractEntries.pl --file nroot.prq.foma --outputfilename "verb.composition.len.prq.foma" --label "@VCMP" --title "NOUN INCORPORATION (Verb-noun composition)" --header "V=S=LEN=noun" --separator 1 --replace3 1 --source3 "NRoot" --target3 "IncNRoot"
	@rm -f verb.classifier.prq.foma | perl extractEntries.pl --file noun.suffix.prq.script --outputfilename "verb.classifier.prq.foma" --label "@CL" --title "VERBAL CLASSIFIERS (VERB.CL)" --header "V=S=CL" --replace1 1 --replace2 1 --source2 "\+CL:" --target2 "+VERB.CL:"
	@rm -f vroot.redup.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "vroot.redup.foma" --label "@REDUP" --title "VERBAL REDUPLICATION" --header "VRootREDUPin" --replace2 1 --source2 "!###" --target2 ""
	@rm -f reduplication/vroot.prtlredup.class01.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "reduplication/vroot.prtlredup.class01.foma" --label "@PRTLREDUPCLASS01" --title "VERBAL PARTIAL REDUPLICATION CLASS 1" --header "VRootPrtlRedupClass01in" --replace2 1 --source2 "#@PRTLREDUPCLASS01" --target2 ""
	@rm -f reduplication/vroot.totredup.class01.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "reduplication/vroot.totredup.class01.foma" --label "@TOTREDUPCLASS01" --title "VERBAL TOTAL REDUPLICATION CLASS 1" --header "VRootTotRedupClass01in" --replace2 1 --source2 "#@TOTREDUPCLASS01" --target2 ""
	@rm -f reduplication/vroot.totredup.class02.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "reduplication/vroot.totredup.class02.foma" --label "@TOTREDUPCLASS02" --title "VERBAL TOTAL REDUPLICATION CLASS 2" --header "VRootTotRedupClass02in" --replace2 1 --source2 "#@TOTREDUPCLASS02" --target2 ""
	@rm -f reduplication/vroot.totredup.class03.foma | perl extractEntries.pl --file vroot.prq.foma --outputfilename "reduplication/vroot.totredup.class03.foma" --label "@TOTREDUPCLASS03" --title "VERBAL TOTAL REDUPLICATION CLASS 3" --header "VRootTotRedupClass03in" --replace2 1 --source2 "#@TOTREDUPCLASS03" --target2 ""
	@rm -f ideo.adbl.foma | bash ashaninkamorph.sh -q "test" 
	@rm -f asheninka.bin asheninka.guesser.bin *.tar.bz2
	@xfst -f asheninka.script 
	@xfst -f asheninka.guesser.script 
#	@tar -jcvf ashaninkamorph$$(date +%Y%m%d%H%M%S).tar.bz2 asheninka.bin asheninka.guesser.bin 
#	@cp *.tar.bz2 /media/sf_RCastroq/CloudStorage/DropBox00001/Dropbox/Ashaninka/ashaninkamorph
#	@xfst -f ideoredupsyl.prq.foma 

testing:
	@echo "#########################################"
	@echo "  RANDOM MORPHOLOGICAL ANALYSIS TESTING  "
	@echo "#########################################"
	@printf "iquenquitsatacota\nnonkibero\nnochenko\nnovito\nnoyoka\n\
iraantsi\n\
iraani\n\
iraani" > text.txt
	@cat text.txt | lookup asheninka.bin
	@rm -f text.txt
	@echo "#########################################"
	@echo "LENITION MORPHOLOGICAL ANALYSIS TESTING  "
	@echo "#########################################"
	@printf "pitotsi\nnovito\npivito\nivito\novito\navito\n\
pava\nnovavani\npivavani\nivavani\novavani\navavani\n\
koka\nnoyokani\npiyokani\niyokani\nyokani\nyokani\n\
kaniri\nnoyaniri\npiyaniri\niyaniri\nyaniri\nyaniri\n\
kami\nnoyamini\npiyamini\niyamini\nyamini\nyamini" > text.txt
	@cat text.txt | lookup asheninka.bin
	@rm -f text.txt
	@printf "kitsarentsi\nnoitsari\npiitsari\niitsari\noitsari\naitsari\n\
kitzitsi\nnoitzi\npiitzi\niitzi\noitzi\naitzi\n\
kishitsi\nnoishi\npiishi\niishi\noishi\naishi\n\
kipatsi\nnoipatsite\npiipatsite\niipatsite\noipatsite\naipatsite\n\
kitsoki\nnoitsoki\npiitsoki\niitsoki\noitsoki\naitsoki\n\
borotsi\n\
iishintsi\npankainantsi\ntamakontsi\nshimpityokitsi\ncheratsi\nkirimashintsi\nkentsitsi\notapinomatsi\n\
okitsi\nkempitantsi\nasorinantsi\npaantetsi\n\
batsatsi\natsiri\n\
iitontsi\nnejitsi\nkonakitsi\nakoperotsi\nporitsi\nyeritontsi\nashonki\niitsintsi\nshetakintsi\n\
kentsitsi\nshempatsi\nmotsitsi\nmoitontsi\njempekitsi\nakotsi\ntsapakintsi\naporibatsa\ntaabatontsi\nakontatsi\n\
taapiikintsi\ntetetsi" > text.txt
	@cat text.txt | lookup asheninka.bin
	@cat text.txt | lookup asheninka.bin | grep '+?' | gawk '{print $1}' > failures.all 
	@cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
	@vim failures.sorted
	@rm -f text.txt

backup:
	@echo "*********Copying the transducer to my dropbox folder*********"
	@rm -f /home/richard/Descargas/RCastroq/dropbox/Dropbox/01_Analizador_Morfologico_Ashaninca/asheninka.bin
	@cp asheninka.bin /home/richard/Descargas/RCastroq/dropbox/Dropbox/01_Analizador_Morfologico_Ashaninca/asheninka.bin
	@echo "*********Copying the manually analyzed list of words*********"
	@rm -f /home/richard/Descargas/RCastroq/dropbox/Dropbox/01_Analizador_Morfologico_Ashaninca/test.text.morph.txt
	@cp test.text.morph.txt /home/richard/Descargas/RCastroq/dropbox/Dropbox/01_Analizador_Morfologico_Ashaninca/test.text.morph.txt

#iraantsi\n\ # blood
#iraani\n\ # her.blood
#iraani\n\ # blood

# This file is designed to work in a Linux OS (Ubuntu 12.04)

update:
	@echo "*****UPDATING TRANSDUCER TRANSITIONS STATES*****"
	@echo "*****VERB*****"
	@rm -f verb.suffix.prq.script
	@cp $(DROPBOXPATH)/verb.suffix.prq.script verb.suffix.prq.script
	@echo "*****NOUN*****"
	@rm -f noun.suffix.prq.script
	@cp $(DROPBOXPATH)/noun.suffix.prq.script noun.suffix.prq.script
	@echo "*****UPDATING TRANSDUCER TRANSITIONS*****"
	@echo "*****VERB*****"
	@rm -f verb.transitions.prq.script
	@cp $(DROPBOXPATH)/verb.transitions.prq.script verb.transitions.prq.script
	@echo "*****NOUN*****"
	@rm -f noun.transitions.prq.script
	@cp $(DROPBOXPATH)/noun.transitions.prq.script noun.transitions.prq.script

# --lang and --type IDs are provided by our MYSQL database, see ConfigFile.ini file for connection information
consult:
	@echo "*****UPDATING LEXICONS*****"
	@echo "*****VERB*****"
	@rm -f vroot.prq.foma
	@> vroot.prq.foma
	@python Reports.py --configfile=ConfigFile.ini --file=vroot.prq.foma --header=VRootPRQin --headershort=VRoot --lang=4 --type=5
	@echo "*****NOUN*****"
	@rm -f nroot.prq.foma
	@> nroot.prq.foma
	@python Reports.py --configfile=ConfigFile.ini --file=nroot.prq.foma --header=NRootPRQin --headershort=NRoot --lang=4 --type=6
#	@echo "*****VERB*****"
#	@rm -f vroot.prq.foma
#	@> vroot.prq.foma
#	@python Reports.py --file=vroot.prq.foma --header=VRootPRQin --headershort=VRoot --lang=4 --type=13
#	@echo "*****OTHER*****"
#	@rm -f oroot.prq.foma
#	@> oroot.prq.foma
#	@python Reports.py --file=oroot.prq.foma --header=ORootPRQin --headershort=OtherRoot --lang=4 --type=14
#	@echo "*****ADJECTIVE*****"
#	@rm -f aroot.prq.foma
#	@> aroot.prq.foma
#	@python Reports.py --file=aroot.prq.foma --header=ARootPRQin --headershort=AdjRoot --lang=4 --type=15
#	@echo "*****ADVERB*****"
#	@rm -f advroot.prq.foma
#	@> advroot.prq.foma
#	@python Reports.py --file=advroot.prq.foma --header=AdvRootPRQin --headershort=AdvRoot --lang=4 --type=16
#	@echo "*****PRONOUN*****"
#	@rm -f pronoun.prq.foma
#	@> pronoun.prq.foma
#	@python Reports.py --file=pronoun.prq.foma --header=PronounPRQin --headershort=PronounPRQ --lang=4 --type=17
#	@echo "*****NUMERAL*****"
#	@rm -f numeral.prq.foma
#	@> numeral.prq.foma
#	@python Reports.py --file=numeral.prq.foma --header=NumeralPRQin --headershort=NumeralPRQ --lang=4 --type=18
#	@echo "*****INTERJECTION*****"
#	@rm -f interjection.prq.foma
#	@> interjection.prq.foma
#	@python Reports.py --file=interjection.prq.foma --header=InterjPRQin --headershort=InterjPRQ --lang=4 --type=19
#	@echo "*****IDEOPHONE*****"
#	@rm -f ideo.prq.foma
#	@> ideo.prq.foma
#	@python Reports.py --file=ideo.prq.foma --header=IdeoPRQin --headershort=IdeoPRQ --lang=4 --type=20
#	@echo "*****SPANISH VERB*****"
#	@rm -f vroot.es.foma
#	@> vroot.es.foma
#	@python Reports.py --file=vroot.es.foma --header=VRootESin --headershort=VRootEs --lang=4 --type=21
#	@echo "*****SPANISH NOUN*****"
#	@rm -f nroot.es.foma
#	@> nroot.es.foma
#	@python Reports.py --file=nroot.es.foma --header=NRootESin --headershort=NRootEs --lang=4 --type=22
#	@echo "*****NEGATOR*****"
#	@rm -f neg.prq.foma
#	@> neg.prq.foma
#	@python Reports.py --file=neg.prq.foma --header=NegPRQin --headershort=NegPRQ --lang=4 --type=23
#	@echo "*****INTERROGATIVE PRONOUN*****"
#	@rm -f interrogative.prq.foma
#	@> interrogative.prq.foma
#	@python Reports.py --file=interrogative.prq.foma --header=WhPRQin --headershort=WhPRQ --lang=4 --type=24

word:
	@echo "$(word)" | lookup asheninka.bin

sentence:
	@echo $(sentence) | tr -s [:space:] '\n' | lookup asheninka.bin | grep '+?' | gawk '{print $1}' > failures.all 
	@cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
	@cat failures.sorted

analyze.file:
	@rm -f failures.old.sorted
	@cp -R -u -p failures.sorted failures.old.sorted
	@cat mycorpus.2018-09-17.txt | perl $(TOKENIZERPATH)/tokenize.pl | lookup -f lookup.script -flags cnKv29TT | grep '+?' | gawk '{print $1}' > failures.all 
	@cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
#	@gedit failures.sorted

analyze.treebank:
	@rm -f failures.old.sorted
	@cp -R -u -p failures.sorted failures.old.sorted
	@perl gettreebank.pl > mycorpus.txt 
	@cat mycorpus.txt | perl $(TOKENIZERPATH)/tokenize.pl | lookup -f lookup.script -flags cnKv29TT | grep '+?' | gawk '{print $1}' > failures.all 
	@cat failures.all | sort | uniq -c | sort -rnb > failures.sorted

search.treebank:
	@rm -f failures.old.sorted
	@cp -R -u -p failures.sorted failures.old.sorted
	@perl gettreebank.pl > mycorpus.txt 
	@cat mycorpus.txt | perl $(TOKENIZERPATH)/tokenize.pl | lookup -f lookup.script -flags cnKv29TT | awk '/-taro/' | gawk '{print $1}' > failures.all 
	@cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
#analyze.file:
#	@rm -f mycorpus.txt
#	@> mycorpus.txt
#	@printf $(sentence) > mycorpus.txt
#	@cat mycorpus.txt | perl $(TOKENIZERPATH)tokenize.pl | lookup asheninka.bin | grep '+?' | gawk '{print $1}' > failures.all 
#	@rm -f mycorpus.txt






