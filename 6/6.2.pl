#!/usr/bin/env perl
package Guard;

our @directions        = qw/N E S W/;
our @direction_offsets = ( [-1,0], [0,1], [1,0], [0,-1] );

sub new {
    my $class = shift;
    my %args  = @_;

    my $self;
    $self->{grid}                = $args{grid};
    $self->{debug}               = $args{debug};
    $self->{maxcol}              = $#{$self->{grid}->[0]};
    $self->{maxrow}              = $#{$self->{grid}};
    $self->{visited}             = {};
    $self->{updates}             = [];
    $self->{turns}               = 0;
    return bless( $self, $class );
}

sub position_key {
    my ($row, $col) = @_;
    return "[$row,$col]";
}

sub in_bounds {
    my ($self, $row, $col) = @_;
    return  $row >= 0 && $row <= $self->{maxrow} &&
            $col >= 0 && $col <= $self->{maxcol};
}

sub mark_visited {
    my ($self, $row, $col) = @_;
    $self->{visited}->{position_key($row,$col)} //= {};
    $self->{visited}->{position_key($row,$col)}->{$self->heading()} = 1;
    $self->{grid}->[$row]->[$col] = $self->heading();
    #$self->print_grid() if $self->{debug};
}

sub starts_retracing_at {
    my ($self, $row, $col) = @_;
    my $visited_at = $self->{visited}->{position_key($row,$col)};
    return ($visited_at && $visited_at->{$self->heading()});
}

sub find_starting_position {
    my $self = shift;
    foreach my $row ( 0 .. $self->{maxrow} ){
        foreach my $col ( 0 .. $self->{maxcol}){
            if( '^' eq $self->{grid}->[$row]->[$col] ){
                return ($row, $col);
            }
        }
    }
}

sub heading {
    my $self = shift;
    return $directions[$self->{turns}%4];
}

sub turn {
    my $self = shift;
    print 'Before> turns: '.$self->{turns}.' heading: '.$self->heading().'> ' if $self->{debug};
    $self->{turns}++;
    print 'After> turns: '.$self->{turns}.' heading: '.$self->heading().'> ' if $self->{debug};
}

sub get_next_position {
    my ($self, $row, $col) = @_;
    my $offsets = $direction_offsets[$self->{turns}%4];
    return ($row + $offsets->[0], $col + $offsets->[1]);
}

sub cell_at {
    my ($self, $row, $col) = @_;
    return $self->{grid}->[$row]->[$col];
}

sub patrol {
    my ($self, $turns, $row, $col) = @_;
    $self->{turns} = $turns;
    if(!defined($row)){
        ($row, $col) = $self->find_starting_position();
    }
    ($self->{start_row}, $self->{start_col}) = ($row, $col);

    #print "\nstart: $row, $col\n" if $self->{debug};

    $self->mark_visited($row, $col);

    while($self->in_bounds($row, $col)){
        my ($next_row, $next_col) = $self->get_next_position($row, $col);
        print "\nconsider: $next_row, $next_col\n" if $self->{debug};
        last if !$self->in_bounds($next_row, $next_col);
        if('#' eq $self->cell_at($next_row, $next_col)){
            $self->turn();
        }else{
            if($self->starts_retracing_at($next_row,$next_col)){
                $self->{loops} = 1;
                last;
            }

            ($row, $col) = ($next_row, $next_col);
            $self->mark_visited($row, $col);
        }
    }

    return {
        visited   => $self->{visited},
        loops     => $self->{loops},
        start     => position_key($self->{start_row}, $self->{start_col})
    };
}

1;

use strict;
use warnings;
use Storable 'dclone';

my $input_grid = [];
while(<STDIN>){
    chomp;
    push @$input_grid, [split ''];
}
my $initial_grid = dclone($input_grid);
my @obstacles;

my $guard = Guard->new(grid => $input_grid);
my $results = $guard->patrol(0);

use Data::Dumper;
#print Dumper($results);
print 'Visited '.scalar(keys %{$results->{visited}})." positions\n";
my $potential_obstacles = $results->{visited};
delete $potential_obstacles->{$results->{start}};
foreach ( keys %{ $potential_obstacles } ){
    if(m/(\d+),(\d+)/){
        my ($row, $col) = ($1,$2);
        my $grid = dclone($initial_grid);
        $grid->[$row]->[$col] = '#';
        my $guard = Guard->new(grid => $grid);
        my $results = $guard->patrol(0);
        if($results->{loops}){
            push @obstacles, [$row, $col];
        }
    }
}
print 'Obstacles:  '.scalar(@obstacles)." positions\n";
