#!/usr/bin/env perl
use strict;
use warnings;

sub add_mult_results {
    my ($input, $result) = (shift, 0);
    $result += $1*$2
        while($input =~ m/mul\((\d+),(\d+)\)/sg);
    return $result;
}

my $input = do { local $/; <STDIN> };

print "result one: ".add_mult_results($input)."\n";

$input =~ s/don't\(\)(.*?)do\(\)//sg;
$input =~ s/don't\(\).*//sg;

print "result two: ".add_mult_results($input)."\n";
