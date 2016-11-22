#/usr/bin/perl -w

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

my $filename = 'n-vroot.prq.foma';
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

print $fh  "# -----------------\n";
print $fh  "# Verbalized nouns\n";
print $fh  "# -----------------\n";
print $fh  "define NounToVerbPRQin [\n";
my $count = 0;
while (<>)
{
 if (m/N@->V/) { 
  if ($count == 0) { 
   my $text = $_;
   $text =~ s/^\|/ /g;
   print $fh $text; 
  }
  else { print $fh $_; }
  $count++;
 }
 else {  }
}
print $fh  "];\n"; 
close $fh;
 
