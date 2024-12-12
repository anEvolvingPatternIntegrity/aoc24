#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my %pages_with_rules;
my %cannot_be_after;
my %cannot_be_before;
my @updates;

while(<STDIN>){
    chomp;
    if(m/(\d+)\|(\d+)/){
        $pages_with_rules{$1} = undef;
        $pages_with_rules{$2} = undef;
        $cannot_be_after{$1}->{$2} = 1;
    }elsif(m/(\d+,?)+/){
        push @updates, [split(',')];
    }
}

sub pages_that_cannot_be_before {
    my $start = shift;
    my %cba = %{ $cannot_be_after{$start} || {} };
    my @new_keys = keys(%cba);
    while(scalar(@new_keys)){
        my %new_hash;
        foreach (@new_keys){
            $new_hash{$cannot_be_after{$_}} = undef
                if($cannot_be_after{$_});
        }
        @new_keys = keys(%new_hash);
    }
    return %cba;
}

$cannot_be_before{$_} = {pages_that_cannot_be_before($_)}
    foreach (keys %pages_with_rules);

my ($correct_checksum, $incorrect_checksum) = 0;
UPDATE:
foreach my $update (@updates){
    my @seen = ( $update->[0] );
    foreach my $page ( @{$update}[1 .. $#$update] ){
        foreach my $bad ( keys %{$cannot_be_before{$page}}){
            foreach my $seen (@seen){
                if($seen == $bad){
                    $update = [ sort {
                        ($cannot_be_before{$b}->{$a} || 0)
                                        <=>
                        ($cannot_be_before{$a}->{$b} || 0)
                                } @$update ];
                    $incorrect_checksum += $update->[ $#$update / 2 ];
                    next UPDATE;
                }
            }
        }
        push @seen, $page;
    }
    $correct_checksum += $update->[ $#$update / 2 ];
}

print "\ncorrect checksum: $correct_checksum";
print "\nincorrect checksum: $incorrect_checksum";
