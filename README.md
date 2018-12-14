Ashaninka Morph
===============

This is a morphological analyzer for Ashaninka written using Xerox finite state technology.

Ashaninka is a polysynthetic and head-marking language spoken in the central adjoining Amazonian regions between Peru and Brazil (Acre State).
It is spoken by approximately 70,000 people (2002), making it the third most widely spoken indigenous language of the Americas.

#### Polysynthetic  

Because it is often possible to find a word that combines several word stems with a very specific 
semantic meaning (noun-incorporation and verbal classifiers).

#### Head-marking 

Ashaninka possesses extensive agreement or cross-refencing. Heads such as verbs and nouns agree with 
the properties of their arguments, for instance, markers on the verb indicate properties of both the subject 
and the object.

Compiling with XFST or FOMA
===============================

```
# XFST 
$ xfst -f asheninka.script 
$ xfst -f ideoredupsyl.prq.foma 
$ echo "ashaninka" | lookup -f lookup.script -flags cnKv29TT
Reading script from "lookup.script"
0%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100%

  *****  LEXICON LOOK-UP  *****

ashaninka	[a-][NPers][1PL.poss+][--][=shani+m.][NRoot][=anteater (ES: oso.hormiguero)][--][-nka+quality][+NMZ]
ashaninka	[a-][NPers][1PL.poss+][--][=shani][VRoot][=to.be.of.the.same.group][--][-nka+quality][+NMZ]nka


LOOKUP STATISTICS (success with different strategies):
strategy 0:	1 times 	(100.00 %)
strategy 1:	0 times 	(0.00 %)
not found:	0 times 	(0.00 %)

corpus size:	1 word
execution time:	0 sec
speed:		1 word/sec

  *****  END OF LEXICON LOOK-UP  *****

# FOMA
$ foma -f asheninka.script 
$ foma -f ideoredupsyl.prq.foma 

```

How to download
===============

* Using `wget`
```
$ wget https://github.com/hinantin/AshaninkaMorph/archive/master.zip 
```

* Cloning the repository
```
$ git clone https://github.com/hinantin/AshaninkaMorph
```

Software prerequisites
======================

In order to run AshaninkaMorph (this finite state transducer), you will need either Foma or XFST, the download links for these are provided below:

* Foma: https://github.com/mhulden/foma (In order to run Foma on a Linux OS you will need to install the following packages first: zlib1g-dev, flex, bison, libreadline-dev).

* XFST: http://www.stanford.edu/~laurik/.book2software/

Software testing
================

Don't know how or want to install it?

Then test it on-line at https://hinant.in/

For more information
====================

Richard Castro Mamani

E-mail: rcastro@hinant.in

Skype: richardtk_1



