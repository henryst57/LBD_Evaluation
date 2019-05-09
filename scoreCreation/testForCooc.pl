# Tests if the frequency score is greater than 1 for anything in 
# the score file. This determines if the terms co-occur together
# in the pre-cutoff file
use strict;
use warnings;

#my $inFile = 'published_freq';
#my $inFile = 'highlyCited_freq';
my $inFile = 'results/threshold7_freq';

my $count = 0;
open IN, $inFile or die ("");
while (my $line = <IN>) {
    my @vals = split(/\<\>/,$line);
    my $val = $vals[0];
    if ($val > 0) {
	print "GREATER THAN 0: $vals[0], $vals[1], $vals[2]";
	$count++;
    }
    
}
