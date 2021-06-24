#!/usr/bin/perl

use RPC::XML;
use RPC::XML::Client;
use Config::IniFiles;
binmode(STDOUT, ":utf8");

my $configfile = 'ConfigFile.ini';
my $CONFIG = Config::IniFiles->new( -file => $configfile );
my $user = $CONFIG->val( 'XMLDATABASEHINANTIN', 'USER' );
my $password = $CONFIG->val( 'XMLDATABASEHINANTIN', 'PASSWORD' );
my $host = $CONFIG->val( 'XMLDATABASEHINANTIN', 'HOST' );
my $port = $CONFIG->val( 'XMLDATABASEHINANTIN', 'PORT' );
my $database = $CONFIG->val( 'XMLDATABASEHINANTIN', 'DATABASE' );

$query = <<END;
xquery version "3.0";
for \$doc in doc("/db/HNTE-Learning/Lessons/$doc") return <xml>{\$doc}</xml>
END
$URL = "http://$user:$password\@$host:$port$database/ParallelCorpus/query/gettreebank.xq";
# connecting to $URL...
$client = RPC::XML::Client->new($URL);
# Output options
my @options = ({
    'indent' => 'yes', 
    'encoding' => 'UTF-8',
    'highlight-matches' => 'none'});
$req = RPC::XML::request->new();
$response = $client->send_request('system.listMethods');

if ($callback ne "" and defined($callback)) {
  my $result = $response->value;
  print "$result";
}
else {
  print $response->value;
}
