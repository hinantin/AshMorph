#!/bin/bash

TOKENIZERPATH=/home/hinantin/ashaninka/AshaninkaMorph

source bash-ini-parser
startmessage="
         ******************************************************
         *           Ashaninka Morph v0.5-b.4                 *
         *                    created by                      *
         *          Richard Alexander Castro-Mamani           *
         *   Copyright (c) 2018 by Hinantin Software.         *
         *                All Rights Reserved.                *
         ******************************************************
"
usage="$(basename "$0") [-h] [-a -q -c -b -g] -- program to manage the morphological analyzer with the different repositories (* run with bash, sh doesn't work')

where:
    -a  analyze an entry
    -g  guess entry morphological analysis 
    -q  querying hinantin database
    -c  compile morphological analyzer
    -b  making a backup
    -t  test morphological analyzer
    "

DROPBOXPATH=/home/richard/Descargas/RCastroq/dropbox/Dropbox/05_Ashaninca/05_Morfologia/Ashaninka_Morph/xml
DIR_ANALYZER=/home/richard/Descargas/repo_hinantin/hinantin/ashaninka/morphology/AshaninkaMorph
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE_NAME=ashaninkamorph_$TIMESTAMP.tar.bz2

TEST=$1

while getopts ':h:a:q:c:b:n:s:g:' o; do
  case "${o}" in
    h) echo "$usage"
       exit
       ;;
    a) echo "$startmessage"
#       echo "${OPTARG}" | lookup -f lookup.script -flags cnKv29TT
       echo "${OPTARG}" | perl tokenize.pl | lookup -flags TT asheninka.bin
       ;;
    s) echo "$startmessage"
       curl "http://35.167.3.206:8983/solr/gettingstarted/select?q=${OPTARG}&wt=json&hl=true&hl.snippets=5&hl.usePhraseHighlighter=true&hl.method=unified" | grep -Rn "${OPTARG}"
       ;;
    q)
       echo "$startmessage"
       echo "*****UPDATING LEXICONS*****"
       echo "*****IDEOPHONE*****"
       rm -f ideo.adbl.foma
       > ideo.adbl.foma
       python adbl.py --configfile=ConfigFile.ini --file=ideo.adbl.foma --header=IdeoADBLin --headershort=Ideo --lang=4 --type=5
#       echo "*****VERB*****"
#       rm -f vroot.prq.foma
#       > vroot.prq.foma
#       python Reports.py --configfile=ConfigFile.ini --file=vroot.prq.foma --header=VRootPRQin --headershort=VRoot --lang=4 --type=5
#       echo "*****NOUN*****"
#       rm -f nroot.prq.foma
#       > nroot.prq.foma
#       python Reports.py --configfile=ConfigFile.ini --file=nroot.prq.foma --header=NRootPRQin --headershort=NRoot --lang=4 --type=6
#       echo "*****VERB*****"
#       rm -f vroot.prq.foma
#       > vroot.prq.foma
#       python Reports.py --file=vroot.prq.foma --header=VRootPRQin --headershort=VRoot --lang=4 --type=13
#       echo "*****OTHER*****"
#       rm -f oroot.prq.foma
#       > oroot.prq.foma
#       python Reports.py --file=oroot.prq.foma --header=ORootPRQin --headershort=OtherRoot --lang=4 --type=14
#       echo "*****ADJECTIVE*****"
#       rm -f aroot.prq.foma
#       > aroot.prq.foma
#       python Reports.py --file=aroot.prq.foma --header=ARootPRQin --headershort=AdjRoot --lang=4 --type=15
#       echo "*****ADVERB*****"
#       rm -f advroot.prq.foma
#       > advroot.prq.foma
#       python Reports.py --file=advroot.prq.foma --header=AdvRootPRQin --headershort=AdvRoot --lang=4 --type=16
#       echo "*****PRONOUN*****"
#       rm -f pronoun.prq.foma
#       > pronoun.prq.foma
#       python Reports.py --file=pronoun.prq.foma --header=PronounPRQin --headershort=PronounPRQ --lang=4 --type=17
#       echo "*****NUMERAL*****"
#       rm -f numeral.prq.foma
#       > numeral.prq.foma
#       python Reports.py --file=numeral.prq.foma --header=NumeralPRQin --headershort=NumeralPRQ --lang=4 --type=18
#       echo "*****INTERJECTION*****"
#       rm -f interjection.prq.foma
#       > interjection.prq.foma
#       python Reports.py --file=interjection.prq.foma --header=InterjPRQin --headershort=InterjPRQ --lang=4 --type=19
#       echo "*****IDEOPHONE*****"
#       rm -f ideo.prq.foma
#       > ideo.prq.foma
#       python Reports.py --file=ideo.prq.foma --header=IdeoPRQin --headershort=IdeoPRQ --lang=4 --type=20
#       echo "*****SPANISH VERB*****"
#       rm -f vroot.es.foma
#       > vroot.es.foma
#       python Reports.py --file=vroot.es.foma --header=VRootESin --headershort=VRootEs --lang=4 --type=21
#       echo "*****SPANISH NOUN*****"
#       rm -f nroot.es.foma
#       > nroot.es.foma
#       python Reports.py --file=nroot.es.foma --header=NRootESin --headershort=NRootEs --lang=4 --type=22
#       echo "*****NEGATOR*****"
#       rm -f neg.prq.foma
#       > neg.prq.foma
#       python Reports.py --file=neg.prq.foma --header=NegPRQin --headershort=NegPRQ --lang=4 --type=23
#       echo "*****INTERROGATIVE PRONOUN*****"
#       rm -f interrogative.prq.foma
#       > interrogative.prq.foma
#       python Reports.py --file=interrogative.prq.foma --header=WhPRQin --headershort=WhPRQ --lang=4 --type=24

       ;;
    c)
       echo "$startmessage"
       rm -f compile.log
       rm -f asheninka.bin
       foma -f asheninka.script 2>&1 | tee -a compile.log
       ;;
    b)
       echo "$startmessage"
       echo "**************************************************"
       echo "Making a backup"
       echo "**************************************************"
       tar jcvf $BACKUP_FILE_NAME nroot.prq.foma vroot.prq.foma oroot.prq.foma aroot.prq.foma advroot.prq.foma pronoun.prq.foma numeral.prq.foma ideo.prq.foma vroot.es.foma nroot.es.foma neg.prq.foma neg.prq.foma interjection.prq.foma asheninka.script asheninka.bin
       mv $BACKUP_FILE_NAME $DROPBOXPATH/$BACKUP_FILE_NAME

       ;;
    g)
       echo "$startmessage"
       echo "**************************************************"
       echo "*   Guessing the morphological structure         *"
       echo "**************************************************"
       echo "${OPTARG}" | perl tokenize.pl | lookup -flags TT asheninka.guesser.bin

       ;;
     t)
       echo "$startmessage"
       echo "**************************************************"
       echo "Start testing 1"
       echo "**************************************************"

       echo "#########################################"
       echo "  RANDOM MORPHOLOGICAL ANALYSIS TESTING  "
       echo "#########################################"
       printf "iquenquitsatacota\nnonkibero\nnochenko\nnovito\nnoyoka\n\
iraantsi\n\
iraani\n\
iraani" > text.txt
       cat text.txt | flookup asheninka.bin
       rm -f text.txt
       echo "#########################################"
       echo "LENITION MORPHOLOGICAL ANALYSIS TESTING  "
       echo "#########################################"
       printf "pitotsi\nnovito\npivito\nivito\novito\navito\n\
pava\nnovavani\npivavani\nivavani\novavani\navavani\n\
koka\nnoyokani\npiyokani\niyokani\nyokani\nyokani\n\
kaniri\nnoyaniri\npiyaniri\niyaniri\nyaniri\nyaniri\n\
kami\nnoyamini\npiyamini\niyamini\nyamini\nyamini" > text.txt
       cat text.txt | flookup asheninka.bin
       rm -f text.txt
       printf "kitsarentsi\nnoitsari\npiitsari\niitsari\noitsari\naitsari\n\
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
       cat text.txt | flookup asheninka.bin
       cat text.txt | flookup asheninka.bin | grep '+?' | gawk '{print $1}' > failures.all 
       cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
       vim failures.sorted
       rm -f text.txt

       echo "**************************************************"
       echo "Start testing 2"
       echo "**************************************************"
       cat mycorpus.txt | perl $(TOKENIZERPATH)/tokenize.pl | flookup asheninka.bin | grep '+?' | gawk '{print $1}' > failures.all 
       cat failures.all | sort | uniq -c | sort -rnb > failures.sorted
       gedit failures.sorted

       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

