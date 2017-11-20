#/usr/bin/perl -w

#use strict;
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
my $replace = 0;
my $source = " : {";
my $target = " : \"\@EP\"{";
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
"replace=i" => \$replace, 
'source=s' => \$source, 
'target=s' => \$target, 
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
   if ($separator == 1) { $text =~ s/\"/\"$separatorsymbol/; }
   if ($replace == 1) { $text =~ s/$source/$target/; }
   print $fh $text; 
  }
  else { 
   my $myvar = $_;
   substr($myvar, 0, 1, "|") if " " eq substr($myvar, 0, 1);
   if ($separator == 1) { $myvar =~ s/\"/\"$separatorsymbol/; }
   if ($replace == 1) { $myvar =~ s/$source/$target/; }
   if ($replace == 2) { 
     # splitting 
if($myvar =~ m/N@\->V::\[(.*)\]/) {
  my $targetstring = "::[$1]"; 
  $myvar =~ m/(.*)$source/g; 
  my $result = "$1$targetstring$target"; 
  $myvar =~ m/$source(.*)/s; 
  $myvar = "$result$1"; 
}
else {
  $myvar =~ s/$source/$target/; 
}
   }
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
 
