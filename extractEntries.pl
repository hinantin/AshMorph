#/usr/bin/perl -w

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
use Getopt::Long qw(GetOptions);

my $filename = 'n-vroot.prq.foma';
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

print $fh  "# -----------------\n";
print $fh  "# Verbalized nouns\n";
print $fh  "# -----------------\n";
print $fh  "define NounToVerbPRQin [\n";
my $count = 0;

# Obtaining the options
my @files;
my $options = "--file file_1 --file file_2 ... ";
GetOptions (
'file=s' => \@files,
) or die " Usage:  $0 $options\n";
#if (@files) {
#  print STDERR " Usage:  $0 $options\n";
#  exit;
#} 
  
my $file;
while (defined($file = shift @files)) {
open INFO, $file or die "Could not open $file: $!";
 while (<INFO>)
 {
 if (m/N@->V/) { 
  if ($count == 0) { 
   my $text = $_;
   $text =~ s/^\|/ /g;
   print $fh $text; 
  }
  else { 
   my $myvar = $_;
   substr($myvar, 0, 1, "|") if " " eq substr($myvar, 0, 1);
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
 
