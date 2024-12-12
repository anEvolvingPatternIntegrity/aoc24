#!/usr/bin/env perl
use strict;
use warnings;

my $safe = 0;
my $safe_via_dampener = 0;

sub safe_thru {
    my $lastdiff;
    for ( 1 .. $#_ ){
        my $diff = $_[$_] - $_[$_-1];
        my $absdiff = abs($diff);
        my $unsafe = $absdiff > 3
            || $absdiff == 0
            || ($lastdiff
                && !( $lastdiff < 0 && $diff < 0 )
                && !( $lastdiff > 0 && $diff > 0 ));
        if($unsafe){
            return $_-1;
        }
        $lastdiff = $diff;
    }
    return $#_;
}

 LINE: while (<STDIN>){
        chomp($_);
        my @vals = split(/\s/, $_);
        my $idx = safe_thru(@vals);
        if($idx == $#vals){
            $safe++;
            next LINE;
        }

        foreach ( $idx - 1, $idx, $idx + 1 ){
            next if !defined($vals[$_]);
            my @alt = @vals;
            splice(@alt, $_, 1);
            my $idx = safe_thru(@alt);
            if($idx == $#alt){
                $safe_via_dampener++;
                next LINE;
            }
        }
}

print "Safe without dampening: $safe\n";
print "Safe with dampening: ".($safe + $safe_via_dampener)."\n";
