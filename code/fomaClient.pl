#!/usr/bin/perl
use IO::Socket qw(AF_INET AF_UNIX SOCK_DGRAM SHUT_WR);
use IO::File;
use utf8; # Source code is UTF-8
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
use Getopt::Long qw(GetOptions);
use IO::CaptureOutput qw/capture/;

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
my $socket = IO::Socket->new (
    Domain => AF_INET,
    Type => SOCK_DGRAM,
    PeerHost => $host, 
    PeerPort => $port, 
    proto => 'tcp',
) || die "Can't open socket: $IO::Socket::errstr";
#print STDERR "Host: $host, Port: $port File: $file\n$text";
#binmode($socket, ":utf8");
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

# the guesser should only be used when no analysis was found, #eos should be an exception as it is a keyword  
if ("$response" =~ /\+\?/ && $response !~ /#eos/i) {
  print STDERR "$response\n";

  my ($stdout, $stderr);
  capture sub {
    system("export LANG=en_US.utf8; echo \"$text\" | /home/ubuntu/foma/foma/flookup /home/ubuntu/AshMorph/asheninka.guesser.bin");
  } => \$stdout, \$stderr;

$response = $stdout;
}

if (defined $outputfile) {
  # appending response to file 
  open(my $fh, '>>', $outputfile) or die "Could not open file '$outputfile' $!";
  say $fh "$response\n";
  close $fh;
}
else {
  print STDOUT "$response\n";
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

