#!/usr/bin/env nix-shell
#! nix-shell -i perl --packages perl perlPackages.JSON
use strict;
use warnings;
#use Imager;
use Time::HiRes qw/sleep/;
use Storable 'dclone';
use JSON;


my $grid = [];
while(<STDIN>){
    chomp;
    push @$grid, [split ''];
}

my $maxcol = $#{$grid->[0]};
my $maxrow = $#$grid;

my %obstacles;
my $heading = 'N';
my @directions = qw/N E S W/;
my %direction_offsets;
@{direction_offsets}{@directions} = ( [-1,0], [0,1], [1,0], [0,-1] );

my %visited;

my $initial_grid = dclone($grid);
my @updates;

sub print_grid {
    print `clear`;
    print "\n";
    foreach my $row ( 0 .. $maxrow ){
        foreach my $col ( 0 .. $maxcol){
            print $grid->[$row]->[$col];
        }
        print "\n";
    }
    print "\n";
    sleep 0.3;
}

sub add_frame {
    my ($row, $col, $char) = @_;
    push @updates, [$row, $col, $char];
}

sub mark_visited {
    my ($row, $col, $heading) = @_;
    my $idx = $row.','.$col;
        ## IF I turned right now,
        ## what direction would I be going in
        ## get list of all coords in that direction from here
        ## check if any match prospective direction
        ##
        ##
        ##
        ##
        ##
    #
    #if(defined($visited{$idx})){
    #    print "\n->$direction_idx\n";



    #    my $heading = $directions[$direction_idx-1];
    #    my $offsets = $direction_offsets{$heading};
    #    my ($obstacle_row, $obstacle_col) = ($row + $offsets->[0], $col + $offsets->[1]);
    #    $grid->[$obstacle_row]->[$obstacle_col] = 'O';
    #    $obstacles{$obstacle_row.','.$obstacle_col} = 1;
    #}else{
    $visited{$idx} //= {};
    $visited{$idx}->{$heading} = 1;
    $grid->[$row]->[$col] = $heading;
    #}
    #print_grid();
    add_frame($row, $col, $heading);
}

sub in_bounds {
    my ($row, $col) = @_;
    #print "\n < $row, $col >\n";
    return  $row >= 0 && $row <= $maxrow && $col >= 0 && $col <= $maxcol;
}

sub patrol {
    my ($row, $col) = @_;
    #print "\n [ $row, $col ]\n";
    my $turns = 0;
    my $didx = 0;

    my $turning = 0;
    while(in_bounds($row, $col)) {
        my $offsets = $direction_offsets{$heading};
        #print "\nheading: $heading, row-offset: ".$offsets->[0].", col-offset: ".$offsets->[1]."\n";
        my ($consider_row, $consider_col) = ($row + $offsets->[0], $col + $offsets->[1]);
        last if !in_bounds($consider_row, $consider_col);
        if('#' eq $grid->[$consider_row]->[$consider_col]){
            $turns++;
            $didx = $turns%4;
            #print "previous heading: $heading, turning for $turns time, dir idx: $didx\n";
            $heading = $directions[$didx];
            $turning = 1;
        }else{
            # if we turn right now...
            if(!$turning){
                my ($ghost_row, $ghost_col)  = ($row, $col);
                my $ghost_turns = $turns+1;
                my $ghost_didx = $ghost_turns%4;
                my %ghost_tracks;
                my $ghost_heading = $directions[$ghost_didx];
                while(in_bounds($ghost_row, $ghost_col)){
                    #print "[ $ghost_row , $ghost_col ]\n";
                    my $ghost_offsets = $direction_offsets{$ghost_heading};
                    my ($ghost_consider_row, $ghost_consider_col) = ($ghost_row + $ghost_offsets->[0], $ghost_col + $ghost_offsets->[1]);
                    last if !in_bounds($ghost_consider_row, $ghost_consider_col);
                    if('#' eq $grid->[$ghost_consider_row]->[$ghost_consider_col]){
                        #print "*A*> $ghost_turns $ghost_didx $ghost_heading> ";

                        $ghost_turns++;
                        $ghost_didx = $ghost_turns%4;
                        $ghost_heading = $directions[$ghost_didx];
                        #print "< $ghost_turns $ghost_didx $ghost_heading*A*<\n";
                    }
                    #elsif(
                    #    #$ghost_heading eq $grid->[$ghost_consider_row]->[$ghost_consider_col] ||
                    #    $ghost_heading eq ($ghost_tracks{"$ghost_consider_row,$ghost_consider_col"}||'')
                    #    ){
                    #    #print "*B*";
                    #    $obstacles{$row.','.$col} = 1;
                    #    last;
                    #}
                    else{
                        #use Data::Dumper;
                        #print Dumper([$ghost_row, $ghost_col]);
                        #print Dumper($ghost_offsets);
                        #print "*C*";
                        my $ghost_loc = "$ghost_row,$ghost_col";
                        if(($visited{$ghost_loc} && $visited{$ghost_loc}->{$ghost_heading}) ||
                           ($ghost_tracks{$ghost_loc} && $ghost_tracks{$ghost_loc}->{$ghost_heading})){
                            $obstacles{$consider_row.','.$consider_col} = 1;
                            add_frame($consider_row, $consider_col, 'O');
                            last;
                        }
                        ($ghost_row, $ghost_col) = ($ghost_consider_row, $ghost_consider_col);
                        add_frame($ghost_row, $ghost_col, 'G');
                        $ghost_tracks{$ghost_loc} //= {};
                        $ghost_tracks{$ghost_loc}->{$ghost_heading} = 1;
                    }
                }
            }
            ($row, $col) = ($consider_row, $consider_col);
            mark_visited($row, $col, $heading);
            $turning = 0;
        }
        #return;
    }
    return $heading;
}

my $start_key;
foreach my $row ( 0 .. $maxrow ){
    foreach my $col ( 0 .. $maxcol){
        if( '^' eq $grid->[$row]->[$col] ){
            mark_visited($row, $col, 'N');
            patrol($row, $col);
            $start_key=$row.','.$col;
        }
    }
}

#print_grid();
delete $obstacles{$start_key};

use Data::Dumper;
print Dumper(\%visited);
print Dumper(\%obstacles);


print scalar(keys(%visited))."\n";
print scalar(keys(%obstacles))."\n";

open(OUT, '>', 'frames.json' );

print OUT encode_json( { grid => $initial_grid, updates => \@updates});
