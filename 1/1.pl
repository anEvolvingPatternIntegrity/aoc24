#!/usr/bin/env perl
use strict;
use warnings;

my (@a, @b, %bindex);
my ($diffscore, $simscore) = (0,0);

while (<STDIN>){
    if($_ =~ m/(\d+)\s+(\d+)/){
        push @a, $1;
        push @b, $2;
        $bindex{$2} //= 0;
        $bindex{$2}++;
    }
}

@a = sort @a;
@b = sort @b;

for ( 0 .. $#a){
    $diffscore += abs($a[$_] - $b[$_]);
    $simscore  += $a[$_] * $bindex{$a[$_]} if $bindex{$a[$_]};
}

print "difference score: $diffscore\nsimilarity score: $simscore";
