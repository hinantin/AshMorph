#!/usr/bin/perl

use strict;
use open ':utf8';
use utf8;
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
use Storable;
use File::Spec::Functions qw(rel2abs);
use File::Basename;
use Config::IniFiles;

my $path = dirname(rel2abs($0));

# --------------------------------
# Task specific prediction 
# --------------------------------
# check if paramenter was given, either:
# -train (disambiguated input, add class in last row)
# -test (input to be disambiguated, leave last row empty)

my $num_args = $#ARGV + 2;
if ($num_args !=3) {
  print STDERR "\nUsage:  perl xfst2wapiti_morphTrain.pl -1/-2/-3 -train/-gold\n";	
  print STDERR "-1: NS/VS, -2: nominal+verbal morph disamb, 3: independent suffixes disamb\n";	
  print STDERR "-train: use 'PossibleRoots/Lemmas/MorphsForTrain, -gold use 'PossibleRoots/Lemmas/MorphsForGold (with xfst analyzed words from gold standard) \n";
  exit;
}

my $mode = $ARGV[0];
unless($mode eq '-1' or $mode eq '-2' or $mode eq '-3' or !$mode){
	print STDERR "\nUsage:  perl xfst2wapiti_morphTrain.pl -1/-2/-3 -train/-gold\n";	
 	print STDERR "-1: NS/VS, -2: nominal+verbal morph disamb, 3: independent suffixes disamb\n";
 	print STDERR "-train: use 'PossibleRoots/Lemmas/MorphsForTrain, -gold use 'PossibleRoots/Lemmas/MorphsForGold (with xfst analyzed words from gold standard) \n";
  	exit;
}

my $trainOrGold =  $ARGV[1];
unless($trainOrGold eq '-train' or $trainOrGold eq '-gold' or !$trainOrGold){
	print STDERR "\nUsage:  perl xfst2wapiti_morphTrain.pl -1/-2/-3 -train/-gold\n";	
 	print STDERR "-1: NS/VS, -2: nominal+verbal morph disamb, 3: independent suffixes disamb\n";
 	print STDERR "-train: use 'PossibleRoots/Lemmas/MorphsForTrain, -gold use 'PossibleRoots/Lemmas/MorphsForGold (with xfst analyzed words from gold standard) \n";
  	exit;
}



my @words; # general variable where each word and its corresponding analysis are stored

# my %hashAnalysis = ('pos', $root, 'morph', \@suffixmorphtags, 'allmorphs', $allsuffixes, 'allprefixes', $allprefixes, 'lem', $lem, 'isNP', $isNP, 'string', $analysis);
# my @analyses = ( \%hashAnalysis ) ; # @analyses contains more than 1 %hashAnalysis 
# push(@$analyses, \%hashAnalysis);
# my @word = ($form, \@analyses); # pseudo hash ?
#		push(@word, \@possibleClasses);
#		push(@word, $actualClass);
# push(@words,\@word);

my $newWord=1;
my $index=0;

my $storedWords;
my $xfstWordsRefLem;
my $xfstWordsRefMorph;
my $xfstWordsRefPos;	
my $xfstWordsRef;


if($trainOrGold eq '-train'){
	$xfstWordsRefLem = retrieve('PossibleLemmasForTrain');
	$xfstWordsRefMorph = retrieve('PossibleMorphsForTrain');
	$xfstWordsRefPos = retrieve('PossibleRootsForTrain');	
	$xfstWordsRef = retrieve('WordsForTrain');
}
elsif($trainOrGold eq '-gold'){
	$xfstWordsRefLem = retrieve('PossibleLemmasForGold');
	$xfstWordsRefMorph = retrieve('PossibleMorphsForGold');
	$xfstWordsRefPos = retrieve('PossibleRootsForGold');	
	$xfstWordsRef = retrieve('WordsForGold');
}

my %xfstwordsLem = %$xfstWordsRefLem;
my %xfstwordsMorph = %$xfstWordsRefMorph;
my %xfstwordsPos = %$xfstWordsRefPos;
my %xfstWords = %$xfstWordsRef;


while(<STDIN>){
	if (/\?\?\?/)
	{
		# move on to the next loop element
		next;
	}
		if (/^$/)
		{
			$newWord=1;
		}
		else
		{	
			my ($form, $analysis) = split(/\t/);
			#print $form."\n";

		# determining word class
			my $CONFIG =
			Config::IniFiles->new( -file =>
				$path."/pos.ini"
			);
			my $partofspeechtags = $CONFIG->val( 'PART_OF_SPEECH', 'POS' );
			my ($pos) = $analysis =~ m/($partofspeechtags)/ ;
			#my ($pos) = $analysis =~ m/(ALFS|CARD|NP|NRoot|VRoot|PostPol|Part|PrnDem|PrnInterr|PrnPers|SP|\$|AdvES|PrepES|ConjES)/ ;
			
			my ($root) = $analysis =~ m/^([^\[]+?)\[/ ;
			#print "$root\n";
			#$root =~ s/\?/\\?/ig;
			if($pos eq ''){
				if($form eq '#EOS'){
					$pos = '#EOS';
				}
				else{
					$pos = "ZZZ";
				}
			}
			
		# getting data from analysis 
		my @segments = split(/\[--\]/);
		#print join(", ", @segments);
		my $allprefixes='';
		my $isprefix = 1;
		my $allsuffixes='';
		my $lem ='';
		my @prefixmorphtags = ();
		my @suffixmorphtags = ();
		foreach my $segment (@segments){
			if ($segment =~ m/\Q$root\E/) {
				# extract lemma 
				my ($lemwithtags) = ($segment =~ m/\[=(.+?)\]\[\Q$root\E/ );
				if ($lemwithtags =~ m/\+/) { ($lem) = ($lemwithtags =~ m/(.+?)\+/); }
				else { $lem = $lemwithtags }
				#print "$lem\n";
				$isprefix = 0;
			}
			elsif ($isprefix) {
				# extract prefix
				my ($morph) = ($segment =~ m/.*\[(.+?\+)\]/);
				#print "$morph***\n";
				push @prefixmorphtags, $morph;
				$allprefixes = $allprefixes.$morph;
			}
			else {
				# extract suffix
				my ($morph) = ($segment =~ m/\[(\+.+?)\]/);
				#print "***$morph\n";
				push @suffixmorphtags, $morph;
				$allsuffixes = $allsuffixes.$morph;
			}
		}

			$lem = lc($lem);
			if($lem eq ''){
				#$lem = $form;
				$lem = 'ZZZ';
			}
			#print "allmorphs: $allmorphs\n";
			#print "morphs: @morphtags\n\n";
		
			#print "$form: $root morphs: @morphtags\n";
			push(@prefixmorphtags, @suffixmorphtags);
			my %hashAnalysis;
			$hashAnalysis{'pos'} = $pos;
			$hashAnalysis{'morph'} = \@prefixmorphtags;
			$hashAnalysis{'string'} = $_;
			$hashAnalysis{'root'} = $root;
	    	$hashAnalysis{'allmorphs'} = $allprefixes.$allsuffixes;
	    	$hashAnalysis{'lem'} = $lem;
			
			if($newWord)
			{
				my @analyses = ( \%hashAnalysis ) ;
				my @word = ($form, \@analyses);
				push(@words,\@word);
				$index++;
			}
			else
			{
				my $thisword = @words[-1];
				my $analyses = @$thisword[1];
				push(@$analyses, \%hashAnalysis);
			}
			$newWord=0;	
	 }
		
}
if($mode eq '-1')
{
	# ----------------------------
	# get NS/ VS ambiguities
	# ----------------------------
	# We will assign possible-classes according to the XFST analyses.
	# correct-class will be the output when the model is used 
	# print STDERR "Do they have prefixes?\n";
	foreach my $word (@words)
	{
		my $analyses = @$word[1];
		my @possibleClasses = ();
		my $actualClass;
		my $allmorphs = @$analyses[0]->{'allmorphs'};
		my $pos = @$analyses[0]->{'pos'};
		my $string = @$analyses[0]->{'string'};
		my $form = @$word[0];
		my $xfstAnalyses =  $xfstWords{$form};
		# print STDERR "pos: $pos\n";
		if(exists($xfstWords{$form}))
		{
			# VERBAL morphology
			# Do they have prefixes?
			# print STDERR "$string\n";
			my $nominalpossession = "\Q1SG.poss+\E|\Q2poss+\E|\Q3m.poss+\E|\Q3n.m.poss+\E|\Q1PL.poss+\E";
			my $verbalprefixes = "\Q1SG.S/A+\E|\Q1SG.S+\E|\Q1SG.A+\E|\Q2S/A+\E|\Q2S+\E|\Q2A+\E|\Q3m.S/A+\E|\Q3m.S+\E|\Q3m.A+\E|\Q3n.m.S/A+\E|\Q3n.m.S+\E|\Q3n.m.A+\E|\Q1PL.S/A+\E|\Q1PL.S+\E|\Q1PL.A+\E|\QIRR+\E|\QM.CAUS+\E|\QAGT.CAUS+\E";
			if($string =~ m/($nominalpossession)/) # determining if there is ambiguity 
			{
				# print STDERR "Do they have prefixes?\n";
				# possible-classes
				push(@possibleClasses, "Prefix");
				push(@possibleClasses, "NoPrefix");
				$actualClass = "Prefix";
			}
			elsif($string =~ m/($verbalprefixes)/)
			{
				# possible-classes
				push(@possibleClasses, "Prefix");
				push(@possibleClasses, "NoPrefix");
				$actualClass = "Prefix";
			}
			elsif ($pos =~ m/(VRoot|NRoot)/)
			{
				push(@possibleClasses, "Prefix");
				push(@possibleClasses, "NoPrefix");
				$actualClass = "NoPrefix";
			}
			### -sqaykichik
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+Perf","+1.Sg.Subj_2.Pl.Obj.Fut"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "Perf");
			##	push(@possibleClasses, "Fut");
			##	if(&containedInOtherMorphs($xfstAnalyses,"+Perf","+IPst+1.Sg.Subj_2.Pl.Obj")){
			##		push(@possibleClasses, "IPst");
			##	}
			##	# actual-class
			##	if($allmorphs =~ /Perf/){$actualClass = "Perf";}
			##	elsif($allmorphs =~  /Fut/){$actualClass = "Fut";}
			##	elsif($allmorphs =~ /IPst/ ){$actualClass = "IPst";}
			##}
			### -sqa
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+Perf","+IPst") || &containedInOtherMorphs($xfstAnalyses,"+Perf","+3.Sg.Subj.IPst") )
			##{
			##	# possible-classes
			##	push(@possibleClasses, "IPst");
			##	push(@possibleClasses, "Perf");
			##	# actual-class
			##	if($allmorphs =~ /IPst/  ){$actualClass = "IPst";}
			##	if($allmorphs =~ /Perf/  ){$actualClass = "Perf";}
			##	#print "@$word[0]\n";
			##}
			# -aantsi
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+ADJ.PARTIC","+NMZ.INF"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "ADJ.PARTIC");
			##	push(@possibleClasses, "NMZ.INF");
			##	# actual-class
			##	if($allmorphs =~  /\QADJ.PARTIC\E/){$actualClass = "ADJ.PARTIC";}
			##	elsif($allmorphs =~ /\QNMZ.INF\E/ ){$actualClass = "NMZ.INF";}
			##	#print STDERR "actual class: $actualClass\n allmorph: $allmorphs\n";
			##	#print STDERR "@$word[0]\n\n";
			##}
			### -yman
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+1.Sg.Subj.Pot","+Inf+Dat_Ill"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "Pot");
			##	push(@possibleClasses, "Inf");
			##	# actual-class
			##	if($allmorphs =~ /Inf/  ){$actualClass = "Inf";}
			##	elsif($allmorphs =~ /Pot/  ){$actualClass = "Pot";}
			##	#print "@$word[0]\n";
			##}
			### -ykuna
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+Inf+Pl","+Aff+Obl"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "Inf");
			##	push(@possibleClasses, "Aff_Obl");
			##	# actual-class
			##	if($allmorphs =~ /\Q+Inf+Pl\E/ ){$actualClass = "Inf";}
			##	elsif($allmorphs =~ /Aff\+Obl/  ){$actualClass = "Aff_Obl";}
			##	#print "@$word[0]\n";
			##}
			### -kuna
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+Pl","+Rflx_Int+Obl"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "Pl");
			##	push(@possibleClasses, "Rflx_Obl");
			##	# actual-class
			##	if($allmorphs =~ /\Q+Pl\E/  ){$actualClass = "Pl";}
			##	elsif($allmorphs =~ /\Q+Rflx_Int+Obl\E/ ){$actualClass = "Rflx_Obl";}
			##	#print "@$word[0]\n";
			##}
			### -cha
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+Fact","+Dim"))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "Fact");
			##	push(@possibleClasses, "Dim");
			##	# should not be a verb, but you never know..
			##	if(&containedInOtherMorphs($xfstAnalyses,"+Dim","+Vdim+Rflx_Int+Obl") or &containedInOtherMorphs($xfstAnalyses,"+Fact","+Vdim") ){
			##		push(@possibleClasses, "Vdim");
			##	}
			##	# actual-class
			##	if($allmorphs =~  /\Q+Fact\E/){$actualClass = "Fact";}
			##	elsif($allmorphs =~ /\Q+Dim\E/){$actualClass = "Dim";}
			##	elsif($allmorphs =~ /\Q+Vdim\E/){$actualClass = "Vdim";}
			##	#print "@$word[0]\n";
			##}
			### -waq 2.Sg.Pot vs. -wa -q (Ag) NOTE: could not evaluate performance on this ambiguity, occurs in none of the four test texts
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+1.Obj+Ag","+2.Sg.Subj.Pot" ) or &containedInOtherMorphs($xfstAnalyses,"+1.Obj+Ag+3.Subj_1.Pl.Incl.Obj","+1.Pl.Incl.Subj.Pot" ))
			##{
			##	# possible-classes
			##	push(@possibleClasses, "12Pot");
			##	push(@possibleClasses, "Ag");
			##	# actual-class
			##	if($allmorphs =~  /\+2\.Sg\.Subj\.Pot/){$actualClass = "12Pot";}
			##	elsif($allmorphs =~ /\+1\.Obj.*\+Ag/ ){$actualClass = "Ag";}
			##}
		}
		# else: other ambiguities, leave
		else
		{
				# possible-classes
				push(@possibleClasses, "ZZZ");
				# TODO test what's better...
				# actual-class
				$actualClass = "none";
				#$actualClass = @$analyses[0]->{'pos'};
		}
	
		push(@$word, \@possibleClasses);
		push(@$word, $actualClass);
	}
}

if($mode eq '-2')
{
	# get nominal/verbal ambiguities
	foreach my $word (@words)
	{
		my $analyses = @$word[1];
		my @possibleClasses = ();
		my $actualClass;
		my $allmorphs = @$analyses[0]->{'allmorphs'};
		my $string = @$analyses[0]->{'string'};
		my $form = @$word[0];
		my $xfstAnalyses =  $xfstWords{$form};
		#print "$form ".$xfstWords{'lluqsimpuni'}[0]->{'string'}."\n";
		#print "$form $allmorphs:  ".($allmorphs =~ /\Q+3.Sg.Subj+Def\E/ || $allmorphs =~ /\Q+Cis_Trs+Rgr_Iprs+1.Sg.Subj\E/)."\n";
		
		# -npuni: -n -puni or -m -pu -ni (cannot use morph analysis, because n-pu is normalized to -mpu in training)
		# note: ONLY 2 instances in training material!! :(
		##if($allmorphs =~ /\Q+3.Sg.Subj+Def\E/ || $allmorphs =~ /\Q+Cis_Trs+Rgr_Iprs+1.Sg.Subj\E/ ){
		##		push(@possibleClasses, "1Sg");
		##		push(@possibleClasses, "3Sg");
		##		if($allmorphs =~  /\Q+1.Sg.Subj\E/){$actualClass = "1Sg";}
		##		elsif($allmorphs =~ /\Q+3.Sg.Subj\E/ ){$actualClass = "3Sg";}
		##}	
		if(exists($xfstWords{$form}))
		{
			# VERBAL morphology
			# -aantsi
			if(($string =~ /\Q+ADJ.PARTIC\E/) || ($string =~ /\Q+NMZ.INF\E/))
			{
				push(@possibleClasses, "ADJ.PARTIC");
				push(@possibleClasses, "NMZ.INF");
				if($allmorphs =~  /\Q+ADJ.PARTIC\E/){$actualClass = "ADJ.PARTIC";}
				elsif($allmorphs =~ /\+QNMZ.INF\E/ ){$actualClass = "NMZ.INF";}
			}
			### -nqa
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+3.Sg.Subj+Top","+3.Sg.Subj.Fut"))
			##{
			##	push(@possibleClasses, "Top");
			##	push(@possibleClasses, "Fut");
			##	if($allmorphs =~  /Top/){$actualClass = "Top";}
			##	elsif($allmorphs =~ /Fut/ ){$actualClass = "Fut";}
			##}
			### -sqaykiku
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+IPst+1.Pl.Excl.Subj_2.Sg.Obj","+1.Pl.Excl.Subj_2.Sg.Obj.Fut"))
			##{
			##	push(@possibleClasses, "IPst");
			##	push(@possibleClasses, "Fut");
			##	if($allmorphs =~ /Fut/ ){$actualClass = "Fut";}
			##	elsif($allmorphs =~ /IPst/  ){$actualClass = "IPst";}
			##} 
			### -wanku 
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+1.Obj+3.Pl.Subj","+3.Subj_1.Pl.Excl.Obj" ) or &containedInOtherMorphs($xfstAnalyses,"+1.Obj+NPst+3.Pl.Subj","+3.Subj_1.Pl.Excl.Obj" ) or &containedInOtherMorphs($analyses,"+1.Obj+IPst+3.Pl.Subj","+3.Subj_1.Pl.Excl.Obj" ) &containedInOtherMorphs($analyses,"+1.Obj+Prog+3.Pl.Subj","+3.Subj_1.Pl.Excl.Obj" ) )
			##{ 
			##	push(@possibleClasses, "1Sg");
			##	push(@possibleClasses, "1Pl");
			##	if($allmorphs =~  /Excl/){$actualClass = "1Pl";}
			##	elsif($allmorphs =~ /\+1\.Obj.*\+3\.Pl\.Subj/ ){$actualClass = "1Sg";}
			##	
			##}
			### -wanqaku 3.Subj_1.Pl.Excl.Obj 
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+1.Obj+3.Pl.Subj.Fut","+3.Subj_1.Pl.Excl.Obj.Fut" ) or &containedInOtherMorphs($xfstAnalyses,"+1.Obj+Prog+3.Pl.Subj.Fut","+3.Subj_1.Pl.Excl.Obj.Fut" )  )
			##{
			##	push(@possibleClasses, "1Sg");
			##	push(@possibleClasses, "1Pl");
			##	if($allmorphs =~  /Excl/){$actualClass = "1Pl";}
			##	elsif($allmorphs =~ /\+1\.Obj.*\+3\.Pl\.Subj\.Fut/ ){$actualClass = "1Sg";}
			##}
			# else: other ambiguities, leave
			else
			{
				push(@possibleClasses, "ZZZ");
				# TODO test what's better...
				$actualClass = "none";
				#$actualClass = @$analyses[0]->{'pos'};
			}
		}
		push(@$word, \@possibleClasses);
		push(@$word, $actualClass);
	}
}

if($mode eq '-3')
{	
	# @word: 0: $form (string), 1: $analyses (arrayref) , 2: $possibleClasses (arrayref), 3: $actualClass (string), 4: $sentenceHasEvid (boolean) 5: $precedingGenitive (boolean)
	# check remaining ambiguities
	# disambiguate indepenent suffixes 
	for(my $i=0;$i<scalar(@words);$i++)
	{
		my $word = @words[$i];
		my $analyses = @$word[1];
		my @possibleClasses = ();
		my $actualClass;
		my $allmorphs = @$analyses[0]->{'allmorphs'};
		my $string = @$analyses[0]->{'string'};
		my $form = @$word[0];
		my $xfstAnalyses =  $xfstWords{$form};
		#print "$form morphs: $allmorphs\n  string: $string\n";
		
	#	if(exists($xfstWords{$form}) && scalar(@$xfstAnalyses)>1)
		if(exists($xfstWords{$form}) )
		{
			# REALIS OR IRREALIS
			# TODO: missing in training material: rqakun -> rqa -ku -n/ -rqaku -m
			# yku-n
			if(&containedInOtherMorphs($xfstAnalyses,"+REAL"))
			{
				#print STDERR "$xfstAnalyses";
				push(@possibleClasses, "REAL");
				push(@possibleClasses, "IRR");
				$actualClass = "REAL";
				# check if sentence already contains an evidential suffix
				##@$word[4] = &sentenceHasEvid(\@words, $i);
				#print "@$word[0], has evid: ".&sentenceHasEvid(\@words, $i)."\n";
				
				#print "@$word[0]: evid @$word[4], gen: @$word[5] \n";
			}
			elsif(&containedInOtherMorphs($xfstAnalyses,"+IRR"))
			{
				#print STDERR "$xfstAnalyses";
				push(@possibleClasses, "REAL");
				push(@possibleClasses, "IRR");
				$actualClass = "IRR";
				# check if sentence already contains an evidential suffix
				##@$word[4] = &sentenceHasEvid(\@words, $i);
				#print "@$word[0], has evid: ".&sentenceHasEvid(\@words, $i)."\n";
				
				#print "@$word[0]: evid @$word[4], gen: @$word[5] \n";
			}

			# -n
			##elsif(&containedInOtherMorphs($xfstAnalyses,"+DirE","+3.Sg.Poss") )
			##{ 
			##	push(@possibleClasses, "DirE");
			##	push(@possibleClasses, "Poss");
			##	if($allmorphs =~ /DirE/){$actualClass = "DirE";}
			##	elsif($allmorphs =~ /Poss/ ){$actualClass = "Poss";}
			##	# check if sentence already contains an evidential suffix
			##	@$word[4] = &sentenceHasEvid(\@words, $i);
			##	#print "@$word[0], has evid: ".&sentenceHasEvid(\@words, $i)."\n";
			##	# check if preceding word has a genitive suffix
			##	unless($i==0){
			##		my $preword = @words[$i-1];
			##		my $preanalyses =  @$preword[1];
			##		if(@$preanalyses[0]->{'allmorphs'} =~ /\+Gen/){
			##			@$word[5] = 1;
			##		}
			##		else{
			##			@$word[5] = 0;
			##		}
			##	}
			##	#print "@$word[0]: evid @$word[4], gen: @$word[5] \n";
			##	#print "$form class $actualClass\n";
			##}
			### -pis
			### get also the ones with -pas for training, otherwise we have only Loc_IndE in training (additive ocurrs only as -pas in trainig texts!)
			##elsif($allmorphs =~ /\Q+Loc+IndE\E/ || ($allmorphs =~ /\Q+Add\E/ && $string !~ /Add.*(IndE|DirE|Asmp)/) )
			##{
			##	push(@possibleClasses, "Loc_IndE");
			##	push(@possibleClasses, "Add");
			##	if($allmorphs =~ /\Q+Loc+IndE\E/){$actualClass = "Loc_IndE";}
			##	elsif($allmorphs =~ /Add/ ){$actualClass = "Add";}
			##	@$word[4] =  &sentenceHasEvid(\@words, $i);
			##}
	
			# -s with Spanish roots: Plural or IndE (e.g. derechus)
			##elsif(!&notContainedInMorphs($xfstAnalyses, "+IndE"))
			##{
			##	foreach my $analisis(@$xfstAnalyses)
			##	{
			##		my $string = $analisis->{'string'};
			##		if($string =~ /s\[NRootES/ or $string =~ /\QNRootES][--]s[Num\E/  )
			##		{
			##			push(@possibleClasses, "Pl");
			##			push(@possibleClasses, "IndE");
			##			@$word[4] = &sentenceHasEvid(\@words, $i);
			##			if($allmorphs =~ /\Q+IndE\E/){$actualClass = "IndE";}
			##			else{$actualClass = "Pl";}
			##		}
			##	}
				
			##}
			# else: lexical ambiguities, leave
			else
			{
				#print "$form, $actualClass\n";
				push(@possibleClasses, "ZZZ");
				# TODO test what's better...
				$actualClass = "none";
				#$actualClass = @$analyses[0]->{'pos'};
			}

		}
		@$word[2] = \@possibleClasses;
		@$word[3] = $actualClass;
	}
}

my $lastlineEmpty=0;

#my $xfstWordsRefLem = retrieve('PossibleLemmasForTrain');
#my %xfstwordsLem = %$xfstWordsRefLem;
#my $xfstWordsRefMorph = retrieve('PossibleMorphsForTrain');
#my %xfstwordsMorph = %$xfstWordsRefMorph;

# print all instances and assign the ones that will not be disambiguated with the current model a dummy label (or their pos?) TODO: test

# -----------
# offsets (rows)
# -----------
for (my $i=0;$i<scalar(@words);$i++){  # iterating through CRFs offsets 
	my $word = @words[$i];
	my $analyses = @$word[1];
	my $form = @$word[0];
	my $possibleClasses = @$word[2];
	my $correctClass = @$word[3];
	
	
	if($form eq '#EOS' ){
		unless($lastlineEmpty == 1){
		print "\n";
		$lastlineEmpty =1;
		next;
		}
	}
	else
	{
		#--------------
		# feature 0: lowercased word
		#--------------
		#print "$form\t";
		print lc($form)."\t";
		
		#--------------
		# feature 1: n, case (lc/uc)
		#--------------
		$lastlineEmpty =0;
		# uppercase/lowercase?
		#punctuation (punctuation has never more than one analysis, so we can just take @$analyses[0])
		if(@$analyses[0]->{'pos'} eq '$'){
			print "n\t";
		}
		elsif(substr($form,0,1) eq uc(substr($form,0,1))){
			print "uc\t";
		}
		# lowercase
		else{
			print "lc\t";
		}
		
		#--------------
		# feature 2: root-pos
		#--------------
		my $pos = @$analyses[0]->{'pos'};
		#if($pos =~ /ConjES|AdvES|PrepES/){$pos = 'SP';}
		if($pos eq 'NP'){$pos = 'NRoot';}
		print $pos."\t";

		#--------------
		# feature 3: root-pos
		#--------------
		# print lemma(s)
		my $printedlems='#';
		my $nbrOfLems =0;
		foreach my $analysis (@$analyses){
			my $lem = $analysis->{'lem'};
			# unless = if not 
			# what's between \Q and \E is treated as normal characters, not regexp characters
			# search a string for a match 
			unless($printedlems =~ /\Q#$lem#\E/ or $nbrOfLems >= 2){
				print "$lem\t";
				$printedlems = $printedlems.'#'.$lem."#";
				$nbrOfLems++;
			}
		}
		
		#--------------
		# feature 4: root-pos
		#--------------
		# get possible lemmas from stored hash (need xfst analysis to get those!)
		if($mode eq '-train'){
			my $possibleLemmasRef = $xfstwordsLem{$form};
			foreach my $lem (@$possibleLemmasRef){
				unless($printedlems =~ /\Q#$lem#\E/ or $nbrOfLems >= 2 ){
					print "$lem\t";
					$printedlems = $printedlems.'#'.$lem."#";
					$nbrOfLems++;
				}
			}
		}
		
		while($nbrOfLems<2){
			print "ZZZ\t";
			$nbrOfLems++;
		}
		
		#--------------
		# feature 5: morph-tags 
		#--------------
		#possible morph tags: take ALL morph tags into account 
		my $printedmorphs='';
		my $nbrOfMorph =0;
		foreach my $analysis (@$analyses){
			my $morphsref = $analysis->{'morph'};
			#print $morphsref;
			foreach my $morph (@$morphsref){
			unless($printedmorphs =~ /\Q$morph\E/){
				# in portmanteau forms -sunki -> only +3.Subj_2.Sg.Obj, -> insert +2/1.Obj in order to have the same morphtags as with regular sequences (-su .. -nki)
				if($morph =~ /.+_2\.(Sg|Pl)\.Obj/ && $printedmorphs !~ /\+2\.\Obj/){
					print "+2.Obj\t";
					$printedmorphs = $printedmorphs."+2.Obj";
					$nbrOfMorph++;
				}
				if($morph =~ /.+_1\.(Sg|Pl(\.Incl|\.Excl))\.Obj/ && $printedmorphs !~ /\+1\.\Obj/){
					print "+1.Obj\t";
					$printedmorphs = $printedmorphs."+1.Obj";
					$nbrOfMorph++;
				}
				print "$morph\t";
				$printedmorphs = $printedmorphs.$morph;
				$nbrOfMorph++;
				}
			}
		}
		#--------------
		# feature 6-14: morph-tags
		#--------------
		# add other possible morphs for ambiguous forms (need xfst analysis for this!)
		# TODO: only for -1/-3? with -3, there shouldn't be other ambiguities...(?)
		# get possible morphs from stored hash (need xfst analysis to get those!)
		if($mode eq '-1' or $mode eq '-2'){
			my $possibleMorphsRef = $xfstwordsMorph{$form};
			foreach my $possAllmorph (@$possibleMorphsRef){
				my @morphs = split('#', $possAllmorph);
				foreach my $morph (@morphs){
					unless($printedmorphs =~ /\Q$morph\E/){
						print "$morph\t";
						$printedmorphs = $printedmorphs.$morph;
						$nbrOfMorph++;
					}
				}
			}
		}
		# mode -3: add missing morphs:
		# +3.Sg.Poss for DirE and vice versa
		# +Loc+IndE for Add and vice versa
		elsif($mode eq '-3'){
			if($correctClass eq 'DirE'){
				print "+3.Sg.Poss\t"; # plus 1 feature
				$nbrOfMorph++;
			}
			elsif($correctClass eq 'Poss'){
				print "+DirE\t"; # plus 1 feature
				$nbrOfMorph++;
			}
			elsif($correctClass eq 'DirEs'){
				print "+Aff\t+3.Sg.Subj\t"; # plus 2 features
				$nbrOfMorph+=2;
			}
			elsif($correctClass eq 'Subj'){
				print "+1.Pl.Excl.Subj\t+DirE\t"; # plus 2 features
				$nbrOfMorph+=2;
			}
			elsif($correctClass eq 'Loc_IndE'){
				print "+Add\t"; # plus 1 feature
				$nbrOfMorph++;
			}
			elsif($correctClass eq 'Add'){
				print "+Loc\t+IndE\t"; # plus 2 features
				$nbrOfMorph +=2;
			}
			elsif($correctClass eq 'Pl'){
				print "+IndE\t"; # plus 1 feature
				$nbrOfMorph++;
			}
		}
		
		while($nbrOfMorph<10){
			print "ZZZ\t"; # adding missing features ZZZ 
			$nbrOfMorph++;
		}
		#--------------
		# feature 15-16: lemma (only on mode 3)
		#--------------
		# for morph3: add info about evidential and genitive suffixes 
		if($mode eq '-3'){
			# feature 15 
			if(@$word[4] eq ''){
				print "ZZZ\t";
			}
			else{
				print "@$word[4]\t";
			}
			# feature 16 
			if(@$word[5] eq ''){
				print "ZZZ\t";
			}
			else{
				print "@$word[5]\t";
			}
			
		}
		
		#--------------
		# feature 15-18: 4 possible classes
		# feature 19: 1 correct-class or none  
		#--------------
		if(scalar(@$possibleClasses)>1 && $correctClass ne ''  && $correctClass ne 'none')
		{
			my $nbrOfClasses =0;
			# possible classes
			foreach my $class (@$possibleClasses){
				print "$class\t";
				$nbrOfClasses++;
			}
			
			while($nbrOfClasses<4){
				print "ZZZ\t";
				$nbrOfClasses++;
			}
			print "$correctClass";
		}
		else{
			#print "@$analyses[0]->{'pos'}";
			print "ZZZ\tZZZ\tZZZ\tZZZ\tnone";
		}
		print "\n";
	}
}
	
	
	###########################################
	
	
  


sub sentenceHasEvid{
	my $wordsref = $_[0];
	my @words = @$wordsref;
	my $i = $_[1];
	
	my $word = @words[$i];
	
	my $analyses = @$word[1];
	my $form = @$word[0];
	my $allmorphs = @$analyses[0]->{'allmorphs'};
	
	my $j = $i-1;
	my $prestring = $form;
	#print "word: $prestring\n";
	while($prestring !~ /\[\$/){
		my $preword = @words[$j];
		my $preanalyses = @$preword[1];
		$prestring = @$preanalyses[0]->{'string'};
		my $preallmorphs = @$preanalyses[0]->{'allmorphs'};
		if($preallmorphs =~ /DirE|IndE|Asmp/ && $prestring!~ /hinaspan/ ){
			#print "found $prestring, $preallmorphs\n";
			return 1;
		}
		$j--;
	}
	my $j = $i+1;
	my $poststring = $form;
	#print "word: $poststring\n";
	while($poststring !~ /\[\$/){
		my $postword = @words[$j];
		my $postanalyses = @$postword[1];
		$poststring = @$postanalyses[0]->{'string'};
		my $postallmorphs = @$postanalyses[0]->{'allmorphs'};
		if($postallmorphs =~ /DirE|IndE|Asmp/ && $poststring !~ /hinaspan/  ){
			#print "found $poststring, $postallmorphs\n";
			return 1;
		}
		$j++;
	}
	#print "\n";
	return 0;
}

sub containedInOtherMorphs{
	my ($analyses, @strings) = (@_);
	if (scalar(@strings)>1) {
		my $string1 = @strings[0];
		my $string2 = @strings[1];
		for(my $j=0;$j<scalar(@$analyses);$j++) 
		{
			my $analysis = @$analyses[$j];
			my $allmorphs = $analysis->{'allmorphs'};
			$allmorphs =~ s/#//g;
			#print STDERR @$analyses[$j]->{'lem'}." morphs: $allmorphs  string1: $string1  string2: $string2\n";
			if($allmorphs =~ /\Q$string1\E/)
			{	
				#print STDERR @$analyses[$j]->{'lem'}." morphs: $allmorphs  string1: $string1  string2: $string2\n";
				# check if later analysis has +Term
				for(my $k=$j+1;$j<$k;$k--) 
				{
					my $analysis2 = @$analyses[$k];
					my $postmorphs = $analysis2->{'allmorphs'};
					$postmorphs =~ s/#//g;
					#print "  next: $postmorphs\n";
					if($postmorphs =~ /\Q$string2\E/ )
					{		
						#print "2 found $allmorphs\n";
						#print "2compared with $postmorphs\n";
						return 1;
					}
				}
				# check if previuous analysis has +Term
				for(my $k=0;$k<$j;$k++) 
				{
					my $analysis3 = @$analyses[$k];
					my $premorphs = $analysis3->{'allmorphs'};
					$premorphs =~ s/#//g;
					#print "   prev: $premorphs\n";
					if($premorphs =~ /\Q$string2\E/)
					{
						#print "      3 found $allmorphs\n";
						#print "      3 compared with $premorphs\n";
						return 1;
					}
				}
			}
		}
	}
	else {
		my $string1 = @strings[0];
		for(my $j=0;$j<scalar(@$analyses);$j++) 
		{
			my $analysis = @$analyses[$j];
			my $allmorphs = $analysis->{'allmorphs'};
			$allmorphs =~ s/#//g;
			#print STDERR @$analyses[$j]->{'lem'}." morphs: $allmorphs  string1: $string1  string2: $string2\n";
			if($allmorphs =~ /\Q$string1\E/)
			{	
				return 1;
			}
		}
	}
	return 0;
}

sub notContainedInMorphs{
	my $analyses = $_[0];
	my $string = $_[1];
	
	foreach my $analysis (@$analyses)
	{
		my $allmorphs = $analysis->{'allmorphs'};
		$allmorphs =~ s/#//g;
		if($allmorphs =~ /\Q$string\E/){
			return 0;
		}
	}
	return 1;
}