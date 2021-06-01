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

my $nyaantsi = $query->param('nyaantsi');
my $finitestatetool = $query->param('finitestatetool');

$nyaantsi =~ s/'/\\'/g;
$nyaantsi =~ s/^\s+|\s+$//g;

my $callback = $query->param('callback');

my $shitovaantsi = undef;

if ($finitestatetool eq "foma") {
    
    my $template = "aminaantsifomaXXXXXX"; # trailing Xs are changed
    my ($fh, $tmpdatei )= File::Temp::tempfile( $template, DIR => "/tmp/");
    chmod 0777, $tmpdatei;
    "Could not create temporary file\n" unless (defined $fh);
    print $fh "$nyaantsi\n";
    $fh->close;

    # create a connecting socket
    my $socket = new IO::Socket::INET (PeerHost => 'localhost', PeerPort => '8981', Proto => 'tcp',);
    die "cannot connect to the server $!\n" unless $socket;
    print STDERR "connected to the server\n";
    # binmode($socket,":utf8");
	# $nyaantsi = encode('utf16', $nyaantsi);
    # data to send to a server
    my $size = $socket->send($nyaantsi);
    print STDERR "sent data of length $size\n";
    
    # notify server that request has been sent
    shutdown($socket, 1);
     
    # receive a response of up to 16384 characters from server
    my $response = "";
    $socket->recv($response, 16384);
    #print "$response\n";
    
    $socket->close();
    $shitovaantsi = "$response";
}
else {

my $template = "aminaantsixfstXXXXXX"; # trailing Xs are changed
my ($fh, $tmpdatei )= File::Temp::tempfile( $template, DIR => "/tmp/");
chmod 0777, $tmpdatei;
"Could not create temporary file\n" unless (defined $fh);
print $fh "$nyaantsi\n";
$fh->close;

  my ($stdout, $stderr);
  capture sub {
    system("export LANG=en_US.utf8; /bin/bash /usr/lib/cgi-bin/ashaninka/aminaantsi.sh $tmpdatei");
  } => \$stdout, \$stderr;
$shitovaantsi = "$stdout";

}

$shitovaantsi =~ s/\n/\\n/g;
$shitovaantsi =~ s/"/\\"/g;
print "$callback(\"$shitovaantsi\")";

