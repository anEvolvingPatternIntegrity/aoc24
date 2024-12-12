#!/usr/bin/env perl

my $safe = 0;
my $saved_by_dampener = 0;

 LINE:
while (<STDIN>){
    chomp($_);
    my @vals = split(/\s/, $_);
    #print $vals[0]." .. ".$vals[$#vals] . "\n";
    my $lastdiff;
    my $jumps = 0;
    print "\n[".join('|',@vals)."]\n";
    for ( $i = 1; $i <= $#vals; $i++) {
        print "$i: ";
        my $diff = $vals[$i] - $vals[$i-1];
        print "<$diff>";
        my $absdiff = abs($diff);
        my $unsafe = $absdiff > 3
            || $absdiff == 0
            || ($lastdiff && !( $lastdiff < 0 && $diff < 0 ) && !( $lastdiff > 0 && $diff > 0 ));
        if($unsafe){
            $jumps++;
            print " *unsafe $jumps* ";
            next LINE if $jumps > 1;
            print " --continuing--> ";
            splice(@vals, $i, 1);
            $i--;
            print '{'.join('|',@vals)."}";
        }else{
            $lastdiff = $diff;
        }
        print "\n";
    }
    print "safe!\n";
    if($jumps){
        $saved_by_dampener++ if $jumps;
        print "[DS] $_\n";
    }
    $safe++;
}

print "Safe without dampening: ".($safe - $saved_by_dampener)."\n";
print "Safe with dampening: $safe\n";
