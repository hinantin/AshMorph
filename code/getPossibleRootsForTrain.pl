#!/usr/bin/perl

use strict;
use utf8;
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
use Storable;
use Config::IniFiles;
use File::Spec::Functions qw(rel2abs);
use File::Basename;
use Config::IniFiles;

my $path = dirname(rel2abs($0));

# get possible roots from xfst and store hash with this info to disk

my @words;

# my %hashAnalysis = ('pos', $root, 'morph', \@suffixmorphtags, 'allmorphs', $allsuffixes, 'lem', $lem, 'isNP', $isNP, 'string', $analysis);
# my @analyses = ( \%hashAnalysis ) ; # @analyses contains more than 1 %hashAnalysis 
# push(@$analyses, \%hashAnalysis);
# my @word = ($form, \@analyses); # pseudo hash ?
#		push(@word, \@possibleClasses);
#		push(@word, $actualClass);
# push(@words,\@word);

my $newWord=1;
my $index=0;

my $storedWords;


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
			unless(/RootG/){
				my ($form, $analysis) = split(/\t/);
				# determining word class
				my $CONFIG =
				Config::IniFiles->new( -file =>
					$path."/pos.ini"
				);
				my $partofspeechtags = $CONFIG->val( 'PART_OF_SPEECH', 'POS' );
				my ($pos) = $analysis =~ m/($partofspeechtags)/ ;
				#my ($pos) = $analysis =~ m/(ALFS|CARD|NP|NRoot|VRoot|Neg|WhPrn|Part|PrnDem|PrnInterr|PrnPers|SP|\$|AdvES|PrepES|ConjES)/ ;
				#print STDERR "$analysis\n";
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
		if($lem eq ''){
			#$lem = $form;
			$lem = 'ZZZ';
		}
				#print "allmorphs: $allmorphs\n";
				#print "morphs: @morphtags\n\n";
			
				#print "$form: $root morphs: @morphtags\n";
		my %hashAnalysis;
		$hashAnalysis{'pos'} = $root;
		$hashAnalysis{'morph'} = \@suffixmorphtags;
		$hashAnalysis{'string'} = $_;
		$hashAnalysis{'root'} = $root;
		$hashAnalysis{'allmorphs'} = $allsuffixes;
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
}

# store @words as hash to disk

store \@words, 'WordsForTrain';
my %xfstWords =();
foreach my $word (@words){
		my $form = @$word[0];
		my $analyses = @$word[1];
		
		unless(exists $xfstWords{$form}){
			$xfstWords{$form} = $analyses;
		}
		
}

#foreach my $w (keys %xfstWords){
#	print "$w : \n";
#	my $analyses = $xfstWords{$w};
#	foreach my $a (@$analyses){
#		print "a: ".$a->{'string'}."\n";
#	}
#	print "\n";
#}

store \%xfstWords, 'WordsForTrain';

my %wordforms =();

foreach my $word (@words){
		my $form = @$word[0];
		my $analyses = @$word[1];
		my @possibleClasses;
		
		if(exists $wordforms{$form}  ){
			my $possibleClassesRef = $wordforms{$form};
			@possibleClasses = @$possibleClassesRef;
		}
		
		foreach my $analysis (@$analyses){
				my $pos = $analysis->{'pos'};
				unless (grep {$_ =~ /\Q$pos\E/} @possibleClasses ){
					push(@possibleClasses, $pos);
			}
		}
		
		$wordforms{$form} = \@possibleClasses;
		
}

foreach my $word (keys %wordforms){
	#print "$word: ";
	my $possiblePos = $wordforms{$word};
	#print "@$possiblePos\n";
}

store \%wordforms, 'PossibleRootsForTrain';
		
		
my %Morphanalyses =();

foreach my $word (@words){
		my $form = @$word[0];
		my $analyses = @$word[1];
		my @possibleMorphs;
		
		if(exists $Morphanalyses{$form}  ){
			my $possibleMorphsRef = $Morphanalyses{$form};
			@possibleMorphs = @$possibleMorphsRef;
		}
		
		foreach my $analysis (@$analyses){
				my $allmorphs = $analysis->{'allmorphs'};
				unless (grep {$_ =~ /\Q$allmorphs\E/} @possibleMorphs ){
					push(@possibleMorphs, $allmorphs);
			}
		}
		
		$Morphanalyses{$form} = \@possibleMorphs;
		
}

foreach my $word (keys %Morphanalyses){
	#print "$word: ";
	my $possibleMorphs = $Morphanalyses{$word};
	#print "@$possibleMorphs\n";
}

store \%Morphanalyses, 'PossibleMorphsForTrain';

my %Lemmas =();

foreach my $word (@words){
		my $form = @$word[0];
		my $analyses = @$word[1];
		my @possibleLemmas;
		
		if(exists $Lemmas{$form}  ){
			my $possibleLemmasRef = $Lemmas{$form};
			@possibleLemmas = @$possibleLemmasRef;
		}
		
		foreach my $analysis (@$analyses){
				my $lem = $analysis->{'lem'};
				unless (grep {$_ =~ /\Q$lem\E$/} @possibleLemmas ){
					push(@possibleLemmas, $lem);
			}
		}
		
		$Lemmas{$form} = \@possibleLemmas;
		
}

foreach my $word (keys %Lemmas){
	#rint "$word: ";
	my $possibleLemmas = $Lemmas{$word};
	#print "@$possibleLemmas\n";
}

store \%Lemmas, 'PossibleLemmasForTrain';
				
		
		