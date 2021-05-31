#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use utf8;
#use Encode;
use IO::Socket::INET;
use File::Temp qw/ tempdir /;
use IO::CaptureOutput qw/capture/;

my $query = new CGI();
print $query -> header(
-type => 'application/json; charset=UTF-8',
);

my $sentence = $query->param('sentence');
my $slang = $query->param('slang');

$sentence =~ s/'/\\'/g;
$sentence =~ s/^\s+|\s+$//g;

my $callback = $query->param('callback');

my $shitovaantsi = undef;

my $template = "vavahaantsiinputXXXXXX"; # trailing Xs are changed
my ($fh, $tmpdatei )= File::Temp::tempfile( $template, DIR => "/tmp/");
chmod 0777, $tmpdatei;
"Could not create temporary file\n" unless (defined $fh);
print $fh "$sentence\n";
$fh->close;

my $templateoutput = "vavahaantsioutputXXXXXX"; # trailing Xs are changed
my ($fhoutput, $tmpdateioutput )= File::Temp::tempfile( $templateoutput, DIR => "/tmp/");
chmod 0777, $tmpdateioutput;
"Could not create temporary file\n" unless (defined $fhoutput);
$fhoutput->close;

my $templateoutputxml = "vavahaantsioutputxmlXXXXXX"; # trailing Xs are changed
my ($fhoutputxml, $tmpdateioutputxml )= File::Temp::tempfile( $templateoutputxml, DIR => "/tmp/");
chmod 0777, $tmpdateioutputxml;
"Could not create temporary file\n" unless (defined $fhoutputxml);
$fhoutputxml->close;

  my ($stdout, $stderr);
  capture sub {
    system("export LANG=en_US.utf8; /bin/bash /usr/lib/cgi-bin/ashaninka/machinetranslation/translate.sh $tmpdatei $tmpdateioutput $tmpdateioutputxml");
  } => \$stdout, \$stderr;

#my $matxin = "/home/hinantin/squoia/MT_systems/matxin-lex";
#my $bidix = "/usr/share/hinantin/ashaninka/machinetranslation/en-cni.bin"; 
#open(XFER,"-|" ,"cat $tmpdateioutputxml | $matxin/squoia-xfer-lex $bidix"  ) || die "lexical transfer failed: $!\n";
#my $dom = XML::LibXML->load_xml( IO => *XFER );
#close(XFER);

#$shitovaantsi = $dom->toString(3);

$shitovaantsi = "$stdout";

$shitovaantsi =~ s/\n/\\n/g;
$shitovaantsi =~ s/"/\\"/g;
print "$callback(\"$shitovaantsi\")";
