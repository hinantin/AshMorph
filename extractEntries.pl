#/usr/bin/perl -w

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
use Getopt::Long qw(GetOptions);

my $outputfilename = 'n-vroot.prq.foma';
my $flag = 'N@->V';
my $title = 'Verbalized nouns';
my $header = 'NounToVerbPRQin';
my $separatorsymbol = "[--]";
my $separator = 0;
# Obtaining the options
my @files;
my $options = "--file file_1 --file file_2 ... ";
GetOptions (
'file=s' => \@files,
'outputfilename=s' => \$outputfilename, 
'flag=s' => \$flag, 
'title=s' => \$title, 
'header=s' => \$header, 
"separator=i" => \$separator, 
) or die " Usage:  $0 $options\n";
#if (@files) {
#  print STDERR " Usage:  $0 $options\n";
#  exit;
#} 

open(my $fh, '>', $outputfilename) or die "Could not open file '$outputfilename' $!";

print $fh  "# -----------------\n";
print $fh  "# $title \n";
print $fh  "# -----------------\n";
print $fh  "define $header [ \n";
my $count = 0;
  
my $file;
while (defined($file = shift @files)) {
open INFO, $file or die "Could not open $file: $!";
 while (<INFO>)
 {
 if (m/$flag/) { 
  if ($count == 0) { 
   my $text = $_;
   $text =~ s/^\|/ /g;
   if ($separator == 1) { print "$separator\n"; $text =~ s/\"/\"$separatorsymbol/; }
   print $fh $text; 
  }
  else { 
   my $myvar = $_;
   substr($myvar, 0, 1, "|") if " " eq substr($myvar, 0, 1);
   if ($separator == 1) { print "$separator\n"; $myvar =~ s/\"/\"$separatorsymbol/; }
   print $fh $myvar; 
  }
  $count++;
 }
 else {  }
 }
close(INFO);
}
print $fh  "];\n"; 
close $fh;
 
