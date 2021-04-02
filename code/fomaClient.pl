#!/usr/bin/perl

use IO::Socket::INET;
use IO::File;
use utf8; # Source code is UTF-8
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
use Getopt::Long qw(GetOptions);

# --- Options
my $options = "[--port|-P <INT>] [--host|-H <STRING>] [--stdin] [--inputfile|-i <DOCUMENT>] [--outputfile|-o <DOCUMENT>]";

my $port;
my $host;
my $stdin;
my $inputfile;
my $outputfile;

GetOptions (
'port|P=s' => \$port,
'host|H=s' => \$host,
'stdin' => \$stdin,
'inputfile|i=s' => \$inputfile,
'outputfile|o=s' => \$outputfile,
) or die " Usage:  $0 $options\n";
if ((not defined $stdin) and (not defined $file)) {
  print STDERR "* Usage:  $0 $options\n‐‐stdin not activated for getting data from a file --file \n";
  exit;
}

my $text;
my $buffsize = 300000;

if (defined $stdin) {
  while(<>){
    $text = $_;

# auto-flush on socket
$| = 1;

# create a connecting socket
my $socket = new IO::Socket::INET (PeerHost => $host, PeerPort => $port, Proto => 'tcp',);
#print STDERR "Host: $host, Port: $port File: $file\n$text";
binmode($socket, ":utf8");
my $message = "";
die "cannot connect to the server $!\n" unless $socket;
$message = "connected to the server";

# data to send to a server
$text =~ s/^\s+|\s+$//g;
my $size = $socket->send($text);
$message = "$message, sent data of length $size";

# notify server that request has been sent
shutdown($socket, 1);

# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, $buffsize);
$response =~ s/(PHONPROC)//;
$response =~ s/(@@)//;
if (defined $outputfile) {
  # appending response to file 
  open(my $fh, '>>', $outputfile) or die "Could not open file '$outputfile' $!";
  say $fh "$response";
  close $fh;
}
else {
  print STDOUT "$response";
}

$socket->close();

  }
}
else {
  # -- Getting data from file
  if (not defined $inputfile) {
    print STDERR " Usage:  $0 $options\n‐‐stdin not activated for getting data from a file --file \n";
    exit;
  }
  else {
    open (TEXT, $inputfile) or die "Can't open file \"$file\" to write: $!\n";
    while (<TEXT>) { $text .= $_; }
    #open (TMP, ">:encoding(UTF-8)", $file) or die "Can't open temporary file \"$file\" to write: $!\n";
    #while(<>){print TMP $_;}
  }
}

