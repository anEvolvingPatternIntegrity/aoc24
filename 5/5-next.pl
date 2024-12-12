#!/usr/bin/env perl
use strict;
use warnings;

my %ordering;
my %cannot_be_after;
my @updates;

while(<STDIN>){
    chomp;
    if(m/(\d+)\|(\d+)/){
        my ($before, $after) = ($1,$2);
        print "\n[[[[[$before, $after]]]]]\n";
        $cannot_be_after{$before}->{$after} = undef;
        $ordering{$before} = $ordering{$before} || 0;
        $ordering{$after}  = ($ordering{$after} || 0 ) + 1;
    }elsif(m/(\d+,?)+/){
        push @updates, [split(',')];
    }
}

foreach ( @updates ){
    foreach my $c (@$_){
        print "..$c..";
    }
}

use Data::Dumper;
print "----".Dumper(\%ordering);
