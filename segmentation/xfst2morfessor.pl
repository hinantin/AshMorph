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
		my ($root) = $analysis =~ m/(ALFS|CARD|NP|NRoot|VRoot|PostPol|\$|Part|PrnDem|PrnInterr|PrnPers|SP|AdvES|PrepES|ConjES)/ ;
		#print STDERR "$analysis\n";
		#$root =~ s/\?/\\?/ig;
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
			if($form eq '#eos'){
				print "\n";
				next;
			}
		}
		
		# getting data from analysis 
		my @segments = split(/\[--\]/, $analysis);
		#print join(", ", @segments);
		my $allprefixes='';
		my $isprefix = 1;
		my $allsuffixes='';
		my $lem ='';
		my @allsegments = ();
		foreach my $segment (@segments){
            my @letters = split(//, $segment);
            my $morph = "";
            foreach my $letter (@letters) {
                last if ($letter =~ /\]|\+/);
                if ($letter =~ /\[/) { }
                else { $morph = $morph.$letter}
            }
            $morph = $morph =~ s/=|-//r;
			if ($morph =~ m/\//) { ($morph) = $morph =~ m/\/(.+)/; }
            push @allsegments, lc($morph);
		}
		$segmentedword = join '@@', @allsegments;
		if ($newWord) {
			if (scalar(@segments) gt 1) { print "$segmentedword "; }
			else { print "$form "; }
			$newWord = 0;
			#print $form."\n";
		}
	}
}