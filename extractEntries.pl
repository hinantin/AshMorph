#/usr/bin/perl -w

#use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
use Getopt::Long qw(GetOptions);

my $outputfilename = 'n-vroot.prq.foma';
my $label = 'N@->V';
my $title = 'Verbalized nouns';
my $header = 'NounToVerbPRQin';
my $separatorsymbol = "[--]";
my $separator = 0;
my $replace1 = 0;
my $source1 = " : {";
my $target1 = " : \"\@EP\"{";
my $replace2 = 0;
my $source2 = " : {";
my $target2 = " : \"\@EP\"{";
my $replace3 = 0;
my $source3 = " : {";
my $target3 = " : \"\@EP\"{";
# Obtaining the options
my @files;
my $options = "--file file_1 --file file_2 ... ";
GetOptions (
'file=s' => \@files,
'outputfilename=s' => \$outputfilename, 
'label=s' => \$label, 
'title=s' => \$title, 
'header=s' => \$header, 
"separator=i" => \$separator, 
"replace1=i" => \$replace1, 
"replace2=i" => \$replace2, 
"replace3=i" => \$replace3, 
'source1=s' => \$source1, 
'target1=s' => \$target1, 
'source2=s' => \$source2, 
'target2=s' => \$target2, 
'source3=s' => \$source3, 
'target3=s' => \$target3, 
) or die " Usage:  $0 $options\n";
#if (@files) {
#  print STDERR " Usage:  $0 $options\n";
#  exit;
#} 

print STDERR " $label\n";

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
 if (m/$label/) { 
  if ($count == 0) { 
   my $myvar = $_;
   if ($separator == 1) { $myvar =~ s/\"/\"$separatorsymbol/; }
   if ($replace1 == 1) { $myvar =~ s/$source1/$target1/; }
   if ($replace2 == 1) { 
     # splitting 
     if ($myvar =~ m/N@\->V::\[(.*)\]/) {
       my $targetstring = "::[$1]"; 
       $myvar =~ m/(.*)$source2/g; 
       my $result = "$1$targetstring$target2"; 
       $myvar =~ m/$source2(.*)/s; 
       $myvar = "$result$1"; 
     }
     elsif ($myvar =~ m/V@\->N::\[(.*)\]/) {
       my $targetstring = "::[$1]"; 
       $myvar =~ m/(.*)$source2/g; 
       my $result = "$1$targetstring$target2"; 
       $myvar =~ m/$source2(.*)/s; 
       $myvar = "$result$1"; 
     }
     else {
       $myvar =~ s/$source2/$target2/; 
     }
     
   }
   if ($replace3 == 1) { $myvar =~ s/$source3/$target3/; }
   $myvar =~ s/^\|/ /g;
   print $fh $myvar; 
  }
  else { 
   my $myvar = $_;
   substr($myvar, 0, 1, "|") if " " eq substr($myvar, 0, 1);
   if ($separator == 1) { $myvar =~ s/\"/\"$separatorsymbol/; }
   if ($replace1 == 1) { $myvar =~ s/$source1/$target1/; }
   if ($replace2 == 1) { 
     # splitting 
     if ($myvar =~ m/N@\->V::\[(.*)\]/) {
       my $targetstring = "::[$1]"; 
       $myvar =~ m/(.*)$source2/g; 
       my $result = "$1$targetstring$target2"; 
       $myvar =~ m/$source2(.*)/s; 
       $myvar = "$result$1"; 
     }
     elsif ($myvar =~ m/V@\->N::\[(.*)\]/) {
       my $targetstring = "::[$1]"; 
       $myvar =~ m/(.*)$source2/g; 
       my $result = "$1$targetstring$target2"; 
       $myvar =~ m/$source2(.*)/s; 
       $myvar = "$result$1"; 
     }
     else {
       $myvar =~ s/$source2/$target2/; 
     }
     
   }
   if ($replace3 == 1) { $myvar =~ s/$source3/$target3/; }
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
 
