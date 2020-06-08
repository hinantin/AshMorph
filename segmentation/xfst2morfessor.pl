#!/usr/bin/perl


use utf8;                  # Source code is UTF-8
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
use strict;
use Storable;
use File::Spec::Functions qw(rel2abs);
use File::Basename;
my $path = dirname(rel2abs($0));

my @words;
my $newWord=1; # flag indicating a new word 
my $index=0;
#my $hasPAS =0;
my $hasMdirect =0;
my $segmentedword = "";
# STDIN processes single tokens 
while(<STDIN>){
	if (/\?\?\?/)
	{
		# move on to the next loop element
		next;
	}
	if (/^$/) # no token detected 
	{
		$newWord=1;
	}
	else
	{
		my ($form, $analysis) = split(/\t/);
		# determining word class
		my ($root) = $analysis =~ m/(ALFS|CARD|NP|NRoot|VRoot|PostPol|Part|PrnDem|PrnInterr|PrnPers|SP|\$|AdvES|PrepES|ConjES)/ ;
		#print STDERR "$analysis\n";
		$root =~ s/\?/\\?/ig;
		# loan word 
		my $isNP = 0;
		if($root eq 'NP'){
			$root = 'NRoot';
			$isNP =1;
			#print $form."\n";
		}
		
#		if($analysis =~ /\@PAS/){
#			$hasPAS =1;
#			#print STDERR "has pas\n";
#		}
		# specifically for Quechua  
		if($analysis =~ /\@mMI/){
			$hasMdirect =1;
		}
		
		# loan word 
		if($root =~ /AdvES|PrepES|ConjES/){
			$root = 'SP';
			$isNP =1;
			#print $form."\n";
		}
		
		elsif($root eq ''){
			if($form eq '#EOS'){
				$root = '#EOS';
			}
			else{
				$root = "ZZZ";
			}
		}
		
		# getting data from analysis 
		my @segments = split(/\[--\]/);
		#print join(", ", @segments);
		my $allprefixes='';
		my $isprefix = 1;
		my $allsuffixes='';
		my $lem ='';
		my @allsegments = ();
		foreach my $segment (@segments){
			if ($segment =~ m/$root/) {
				# extract lemma 
				my ($lemwithtags) = ($segment =~ m/\[=(.+?)\]\[$root/ );
				if ($lemwithtags =~ m/\+/) { ($lem) = ($lemwithtags =~ m/(.+?)\+/); }
				else { $lem = $lemwithtags }
				#print "$lem\n";
				push @allsegments, lc($lem);
				$isprefix = 0;
			}
			elsif ($isprefix) {
				# extract prefix
				my ($morph) = ($segment =~ m/.*\[(.+?)[-|=]\]/);
				#print "$morph***\n";
				push @allsegments, lc($morph);
			}
			else {
				# extract suffix
				my $morph = "";
				if ($segment =~ m/\+.*@/) { ($morph) = ($segment =~ m/\[[-|=](.+?)\+/); }
				else { ($morph) = ($segment =~ m/\[[-|=](.+?)\]/); }
				#print "***$morph\n";
				push @allsegments, lc($morph);
			}
		}
		$segmentedword = join '@@', @allsegments;
		if ($newWord) {
			print "$segmentedword ";
			$newWord = 0;
		}
	}
}