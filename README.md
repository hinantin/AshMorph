Ashaninka-Morph (AshMorph for short)
===============

This is a morphological analyzer for pan-Ashaninka that is written using Finite State technology with a multilingual lexicon (Ashaninka, English, Spanish and Portuguese), some entries in Quechua and Italian are provided in a lesser quantity.

Pan-Ashaninka is the general term used to refer to a 'cluster of Arawak-dialects', this cluster is also known as 'the Ashé-Ashá dialect continuum' and is spoken in Peru and Acre-Brazil, the aforementioned cluster specifically comprises Ashéninka Pichis (Pi), Alto Perené (Pe), Ashéninka Pajonal (Paj), Ucayali-Yurua Ashéninka (U-Y), Ajyininka (or Ashéninka) Apucurayali (Apu), Ashaninka (Asha).

Pan-Ashaninka is a polysynthetic and head-marking language spoken in the central adjoining Amazonian regions between Peru and Brazil (Acre State).
It is spoken by approximately 70,000 people (2002).

#### Polysynthetic  

Because it is often possible to find a word that combines several word stems with a very specific 
semantic meaning (noun-incorporation and verbal classifiers).

```
Noun incorporation: tsapya 'river.bank'

apaani asheninka isaikatsapyaatziro inkaare
=apaani *** =asheninka *** i- =saik -a =tsapya -atz -i =ro *** =inkaare 
=one *** =man *** 3m.A- =to.live -EP =river.bank -PROG -IRR =3n.m.O *** =lake 
EN: 'a man who lived near a lake'; Lit.: 'one man who lived in the lake bank'
ES: 'un hombre que vivía cerca de una cocha' 
```


```
Verbal classifier: ha 'liquid'

katsinkajari /NMZ> katsinkahari
=katsinka -ha -ri 
=to.be.cold -cl:liquid -rel 
EN: 'cold.water; lit.: liquid.that.is.cold'
ES: 'agua.fría; lit.: líquido.que.está.frio' 
```

#### Head-marking 

Ashaninka possesses extensive agreement or cross-refencing. Heads such as verbs and nouns agree with 
the properties of their arguments, for instance, gender markers on the verb indicate properties, such as masculine (+m.) or not-masculine (+n.m.), of both the subject 
and the object.

#### Verbal reduplication

Verbal reduplication indicates urgency `(1)`, repetition/countinued-action `(3)`, intensity `(2)`, or plurality of paticipants `(4)`.

```
1) ma 'to.do' -> ma~ma 'to.do.quickly' 
```

Our analysis of the collected text corpus, shows that pan-Ashaninka presents both partial reduplication 'bounded copy' `(2)` and total reduplication 'unbounded copy' `(1, 3)` as productive morphological operations.

```
2) kov 'to.want' -> ko~kov 'to.prefer.strongly' 

3) koniha 'to.appear' -> koniha~koniha 'to.appear.again-and-again'
```

There are particular cases where verbal roots with prefixes are reduplicated in both partial and total modes. 

Normalization process 'NMZ'
=====================

In order to give this project a certain amount of robustness, we used a normalized version of the alphabet 
developed by Elena Mihas to write every lexicon entry and all the affixes. 
In addition to this, normalization rules have been implemented, this means that every letter in an input entry is mapped to
its equivalent in the normalized alphabet before being fully analyzed. 

Generative capacity of Ashaninka Grammar
=========================

First, we define the "generative capacity of Ashaninka grammar" as a model which indicates what kind of patterns it can or cannot model.
So far we have played loose with the rules which determine the patterns that our current model should and should not generate, because of the initial state of our text corpus and the wide variety of writing systems these texts were written with.

Compiling with XFST
===============================

```bash
$ xfst -f asheninka.script 
$ echo "ashaninka" | lookup asheninka.bin -flags cnKv29TT
0%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100%

  *****  LEXICON LOOK-UP  *****

ashaninka	[a-][NPers][1PL.poss+][--][=shani][VRoot][=to.be.of.the.same.group][--][-nka][NS][+NMZ.QLTY]nka
ashaninka	[a-][NPers][1PL.poss+][--][=shani+m.][NRoot][=anteater (ES: oso.hormiguero; sci.nm.: myrmecophaga.tridactyla)][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka	[=ashaninka][NRoot][=indigenous.person.that.lives.in.the.in.the.central.adjoining.Amazonian.regions.between.Peru-and-Brazil]

LOOKUP STATISTICS (success with different strategies):
strategy 0:	1 times 	(100.00 %)
not found:	0 times 	(0.00 %)

corpus size:	1 word
execution time:	0 sec
speed:		1 word/sec

  *****  END OF LEXICON LOOK-UP  *****
```

Compiling with FOMA
===============================

```bash
$ foma -f asheninka.script 

$ echo "ashaninka" | flookup asheninka.bin
ashaninka       [=ashaninka][NRoot][=indigenous.person.that.lives.in.the.in.the.central.adjoining.Amazonian.regions.between.Peru-and-Brazil]
ashaninka       [a-][NPers][1PL.poss+][--][=sha+gndr@n.m.+sem@plant][NRoot][=palm.tree.sp. (it.has.black.fruits.&.its.leaves.are.used.to.make.baskets/mats; ES: ungurahui, unguravi, ungurabe, ungurague; PT: patoá)][--][-ni+sem@place.][+CL:watercourse][=watercourse, running.water.feature][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka       [a-][NPers][1PL.poss+][--][=sha+gndr@n.m.+sem@plant][NRoot][=palm.tree.sp. (it.has.black.fruits.&.its.leaves.are.used.to.make.baskets/mats; ES: ungurahui, unguravi, ungurabe, ungurague; PT: patoá)][--][-ni][DEGR][+AUG][=AUG (EN: too; ES: demasiado); INTNS][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka       [a-][NPers][1PL.poss+][--][=sha+poss@ni.+sem@wild.anim.][NRoot][=anteater (ES: piampía; PT: tamanduá)][--][-ni+sem@place.][+CL:watercourse][=watercourse, running.water.feature][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka       [a-][NPers][1PL.poss+][--][=sha+poss@ni.+sem@wild.anim.][NRoot][=anteater (ES: piampía; PT: tamanduá)][--][-ni][DEGR][+AUG][=AUG (EN: too; ES: demasiado); INTNS][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka       [a-][NPers][1PL.poss+][--][=shani+gndr@m.+sem@wild.anim.][NRoot][=anteater (ES: oso.hormiguero; sci.nm.: myrmecophaga.tridactyla; PT: tamanduá)][--][-nka][NS][+NMZ.QLTY][=abstract.qlty.noun]
ashaninka       [a-][NPers][1PL.poss+][--][=shani][VRoot][=to.be.of.the.same.group][--][-nka][NS][+NMZ.QLTY]nka
```

How to download the source code 
===============================

* Using `wget`

```bash
$ wget https://github.com/hinantin/AshMorph/archive/master.zip 
```

* Cloning this repository

```bash
$ git clone https://github.com/hinantin/AshMorph
```

Software prerequisites
======================

In order to run AshMorph finite state transducer, you will need either Foma or XFST, the download links for these are provided below:

* Foma: https://github.com/mhulden/foma (In order to run Foma on a Linux OS you will need to install the following packages first: zlib1g-dev, flex, bison, libreadline-dev, termcap).

```bash
$ sudo apt-get update
$ sudo apt install make
$ sudo apt install build-essential
$ sudo apt-get install zlib1g-dev flex bison libreadline-dev
$ cd ..
$ git clone https://github.com/mhulden/foma
$ cd foma/foma
$ sudo apt install cmake
$ sudo apt-get install libboost-all-dev
$ sudo apt install build-essential cmake libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev
$ cmake . 
$ cmake --build . 
$ cd ../.. 
$ cd AshMorph/
$ ../foma/foma/foma -f asheninka.script
$ echo "mapi" | ../foma/foma/flookup asheninka.bin

```
Note: 
=====
* Foma compilations have some issues.
* XFST: http://www.stanford.edu/~laurik/.book2software/
* Further improvements need to be made, concerning new vocabulary.

Contact info:
Richard A. Castro-Mamani rcastro AT hinantin.com

