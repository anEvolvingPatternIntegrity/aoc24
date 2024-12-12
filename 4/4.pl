#!/usr/bin/env perl
use strict;
use warnings;

my $grid = [];
push @$grid, [split ''] while(<STDIN>);

my $maxcol = $#{$grid->[0]};
my $maxrow = $#$grid;

my %named_dirs;
@named_dirs{qw/NW N NE W _ E SW S SE/ } = map {
    my $x = $_;
    map { [$x, $_] } (-1, 0, 1);
} (-1, 0, 1);

sub offsets {
    my ($magnitudes, $dir_names) = @_;

    return [
        map {  # magnitudes X directions
            my ($dir_row, $dir_col) = @{$_}[0,1];
            [ map { [$_ * $dir_row, $_ * $dir_col] } @$magnitudes ]
        } @named_dirs{@$dir_names}
    ];
}

sub mk_matcher {
    my ($pat, $offsets) = @_;

    return sub {
        my ($row, $col) = @_;
        my @matches;
        return grep { # 4. only keep those that match pattern
            m/^$pat$/;
        } map {       # 3. get string at position of coords
            join('', map { $grid->[$_->[0]]->[$_->[1]] } @$_);
        } grep {      # 2. only keep coord lists of proper length
            scalar( @$_ ) == scalar( @{$offsets->[0]} )
        } map {       # 1. get lists of coords to check
            [
             grep {   # 1.2 filter out-of-bounds
                $_->[0] >= 0       && $_->[1] >= 0       &&
                $_->[0] <= $maxrow && $_->[1] <= $maxcol
              } map { # 1.1 apply offset to given coords
                  [ $row + $_->[0], $col + $_->[1] ]
              } @$_
            ]
        } @$offsets;
    };
}

my $matcher_x = mk_matcher(q/MAS/,
                           offsets([1,2,3],  [qw/NW N NE W E SW S SE/]));
my $matcher_a = mk_matcher(q/MAS|SAM/,
                           offsets([-1,0,1], [qw/NW NE/]));

my ($xmas_count, $mas_xs_count) = (0,0);

foreach my $row ( 0 .. $maxrow ){
    foreach my $col ( 0 .. $maxcol){
        if( $grid->[$row]->[$col] eq 'X' ){
            $xmas_count += scalar( $matcher_x->($row, $col) );
        }elsif( $grid->[$row]->[$col] eq 'A' ){
            $mas_xs_count++ if scalar( $matcher_a->($row, $col) ) >= 2;
        }
    }
}

print "\npart 1: $xmas_count\npart 2: $mas_xs_count\n";

# visual aid
#
#   [-3,-3][__,__][__,__][-3,+0][__,__][__,__][=3,+3]
#   [__,__][-2,-2][__,__][-2,+0][__,__][-2,+2][__,__]
#   [__,__][__,__][-1,-1][-1,+0][-1,+1][__,__][__,__]
#   [+0,-3][+0,-2][+0,-1][+0,+0][+0,+1][+0,+2][+0,+3]
#   [__,__][__,__][+1,-1][+1,+0][+1,+1][__,__][__,__]
#   [__,__][+2,-2][__,__][+2,+0][__,__][+2,+2][__,__]
#   [+3,-3][__,__][__,__][+3,+0][__,__][__,__][+3,+3]

# original hardcoded offsets
#my @xmas_offsets = ([ [ 0,1 ], [ 0,2 ], [ 0,3 ] ],
#                    [ [ 0,-1], [ 0,-2], [ 0,-3] ],
#                    [ [ 1,0 ], [ 2,0 ], [ 3,0 ] ],
#                    [ [-1,0 ], [-2,0 ], [-3,0 ] ],
#                    [ [ 1,1 ], [ 2,2 ], [ 3,3 ] ],
#                    [ [-1,-1], [-2,-2], [-3,-3] ],
#                    [ [-1,1 ], [-2,2 ], [-3,3 ] ],
#                    [ [ 1,-1], [ 2,-2], [ 3,-3] ]);
#
#my @mas_xs_offsets = ([ [-1,-1], [ 0,0 ], [ 1,1 ],],
#                      [ [ 1,-1], [ 0,0 ], [-1,1 ],],);
#
