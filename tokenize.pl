#/usr/bin/perl -w

use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

while (<>)
{
@words = split(/([\s+|,|\.|\:|;|\[|\]|\(|\)|\?|\“|\”|\"|\"|\¡|\–|\¿|\!|\/|\%|\'|…|—])/);
foreach (@words) {
    if (m/^\s*$/) { next;}
    elsif (m/^\.*$/) { next; } 
    elsif (m/^\,*$/) { next; }
    elsif (m/^\:*$/) { next; }
    elsif (m/^\;*$/) { next; }
    elsif (m/^\-*$/) { next; }
    elsif (m/^\(*$/) { next; }
    elsif (m/^\)*$/) { next; }
    elsif (m/^\/*$/) { next; }
    elsif (m/^\“*$/) { next; }
    elsif (m/^\”*$/) { next; }
    elsif (m/^\]*$/) { next; }
    elsif (m/^\[*$/) { next; }
    elsif (m/^\¡*$/) { next; }
    elsif (m/^\!*$/) { next; }
    elsif (m/^\→*$/) { next; }
    elsif (m/^\=*$/) { next; }
    elsif (m/^\…*$/) { next; }
    elsif (m/^\—*$/) { next; }
    elsif (m/\d{1,2}?/) { next; }
    else {
=pod
I am deting the hyphen - .
=cut
        my $string = $_;
        $string = lc($string);
        $string =~ s/’/\'/ig;
        $string =~ s/`/\'/ig;
        $string =~ s/\-//g;
        print "$string\n";
    }
}
}

