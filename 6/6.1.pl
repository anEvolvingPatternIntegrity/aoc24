#!/usr/bin/env nix-shell
#! nix-shell -i perl --packages perl perlPackages.JSON
use strict;
use warnings;

package Guard;
use Storable 'dclone';
use Data::Dumper;
use Time::HiRes qw/sleep/;
use JSON;

our @directions        = qw/N E S W/;
our @direction_offsets = ( [-1,0], [0,1], [1,0], [0,-1] );

sub new {
    my $class = shift;
    my %args  = @_;

    my $self;
    $self->{grid}                = $args{grid};
    $self->{initial_grid}        = dclone($self->{grid});
    $self->{debug}               = $args{debug};
    $self->{maxcol}              = $#{$self->{grid}->[0]};
    $self->{maxrow}              = $#{$self->{grid}};
    $self->{check_for_obstacles} = $args{check_for_obstacles};
    $self->{visited}             = {};
    $self->{visited_prev}        = $args{visited_prev} || {};
    $self->{path}                = [];
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

sub print_grid {
    my $self = shift;
    #print `clear`;
    print "\n";
    foreach my $row ( 0 .. $self->{maxrow} ){
        foreach my $col ( 0 .. $self->{maxcol}){
            print $self->{grid}->[$row]->[$col];
        }
        print "\n";
    }
    print "\n";
    #print Dumper($self->{visited});
    sleep 0.3;
}

sub add_frame {
    my ($self, $row, $col, $char) = @_;
    return if !$self->{check_for_obstacles};
    push @{$self->{updates}}, [$row, $col, $char];
}

sub mark_visited {
    my ($self, $row, $col) = @_;
    push @{$self->{path}}, [$row, $col];
    $self->{visited}->{position_key($row,$col)} //= {};
    $self->{visited}->{position_key($row,$col)}->{$self->heading()} = 1;
    $self->{grid}->[$row]->[$col] = $self->heading();
    $self->add_frame($row, $col, $self->heading());
    #$self->print_grid() if $self->{debug};
}

sub starts_retracing_at {
    my ($self, $row, $col) = @_;
    my $visited_at = $self->{visited}->{position_key($row,$col)};
    my $visited_at_prev = $self->{visited_prev}->{position_key($row,$col)};
    return ($visited_at_prev && $visited_at_prev->{$self->heading()});#|| ($visited_at && $visited_at->{$self->heading()});
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

    my $turning = 0;
    while($self->in_bounds($row, $col)){
        my ($next_row, $next_col) = $self->get_next_position($row, $col);
        print "\nconsider: $next_row, $next_col\n" if $self->{debug};
        last if !$self->in_bounds($next_row, $next_col);
        if('#' eq $self->cell_at($next_row, $next_col)){
            $self->turn();
            $turning = 1;
        }else{
            if($self->{check_for_obstacles} && !$turning){
                my $check_grid = dclone($self->{grid});
                $check_grid->[$next_row]->[$next_col] = '#';
                #my $debug = $row == 6;
                my $debug = 0;
                my $heading = $self->heading();
                #print "\nHEADING [$heading]\n";
                my $check_guard = Guard->new(grid => $check_grid, visited_prev => $self->{visited}, debug => $debug);
                my $check_results = $check_guard->patrol($self->{turns}, $row, $col);
                #print Dumper($check_results);

                if($check_results->{loops}){
                    $self->{obstacles}->{position_key($next_row,$next_col)} = 1;
                    $self->add_frame($next_row, $next_col, 'O');
                }
            }else{
                if($self->starts_retracing_at($next_row,$next_col)){
                    $self->{loops} = 1;
                    last;
                }
            }
            ($row, $col) = ($next_row, $next_col);
            $self->mark_visited($row, $col);
            $turning = 0;
        }
    }

    if($self->{check_for_obstacles}){
        open(OUT, '>', 'frames.1.json');
        print OUT encode_json( { grid => $self->{initial_grid}, updates => $self->{updates} } );
        close(OUT);
    }

    return {
        visited   => [ keys %{$self->{visited}} ],
        path      => $self->{path},
        loops     => $self->{loops},
        obstacles => $self->{obstacles},
        start     => position_key($self->{start_row}, $self->{start_col})
    };
}

1;

my $input_grid = [];
while(<STDIN>){
    chomp;
    push @$input_grid, [split ''];
}
my %obstacles;

my $guard = Guard->new(grid => $input_grid, check_for_obstacles => 1);
my $results = $guard->patrol(0);

use Data::Dumper;
print Dumper($results);
print 'Visited '.scalar(@{$results->{visited}})." positions\n";
delete $results->{obstacles}->{$results->{start}};
print 'Obstacles:  '.scalar(keys %{$results->{obstacles}})." positions\n";

open(OUT, '>', 'obstacles.dump');
print OUT Dumper($results->{obstacles});
close(OUT);
