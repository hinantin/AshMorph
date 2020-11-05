Ashaninka-Morph (AshMorph for short)
===============

This is a morphological analyzer for pan-Ashaninka that is written using Xerox finite state technology with a multilingual lexicon (Ashaninka, English, Spanish and Portuguese), some entries in Quechua and Italian are provided in a lesser quantity.

Pan-Ashaninka is the general term used to refer to a cluster of Arawak-dialects spoken in Peru and Acre-Brazil, the aforementioned cluster specifically comprises Ashéninka Pichis (Pi), Alto Perené (Pe), Ashéninka Pajonal (Paj), Ucayali-Yurua Ashéninka (U-Y), Ajyininka (or Ashéninka) Apucurayali (Apu), Ashaninka (Asha).

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

katsinkajari / katsinkahari
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

Verbal reduplication indicates urgency `(1)`, repetition `(3)`, or intensity `(2)`.

```
1) ma 'to.do' -> ma~ma 'to.do.quickly' 
```

Our analysis of the collected text corpus, shows that pan-Ashaninka presents both partial reduplication 'bounded copy' `(2)` and total reduplication 'unbounded copy' `(1, 3)` as productive morphological operations.

```
2) kov 'to.want' -> ko~kov 'to.prefer.strongly' 

3) koniha 'to.appear' -> koniha~koniha 'to.appear.again-and-again'
```

There are particular cases where verbal roots with prefixes are reduplicated in both partial and total modes. 

Normalization process
===================

In order to give this project a certain amount of robustness, we used a normalized version of the alphabet 
developed by Elena Mihas to write every lexicon entry and all the affixes. 
In addition to this, normalization rules have been implemented, this means that every letter in an input entry is mapped to
its equivalent in the normalized alphabet before being fully analyzed. 

Compiling with XFST or FOMA
===============================

```bash
# XFST 
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

# FOMA
$ foma -f asheninka.script 

```

How to download the source code 
===============================

* Using `wget`

```bash
$ wget https://github.com/hinantin/AshaninkaMorph/archive/master.zip 
```

* Cloning this repository

```bash
$ git clone https://github.com/hinantin/AshaninkaMorph
```

Software prerequisites
======================

In order to run AshaninkaMorph (this finite state transducer), you will need either Foma or XFST, the download links for these are provided below:

* Foma: https://github.com/mhulden/foma (In order to run Foma on a Linux OS you will need to install the following packages first: zlib1g-dev, flex, bison, libreadline-dev).

* XFST: http://www.stanford.edu/~laurik/.book2software/

Software on-line testing
========================

Don't know how or want to install it?

Then test the morphological analyzer on-line, go to https://hinant.in/

Spell-checking
================

 Test the spell-checker on-line: https://hinant.in/ckeditor/samples/api.html



