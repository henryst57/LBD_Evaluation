#makes values of -1 (indicating no association can be calucalted)
# values of 999999, this is useful when soring in ascending order
use strict;
use warnings;

my $fileName = 'threshold6_ltc';
my $scoreFile = "scores/$fileName";
my $outFile = "flippedScores/$fileName";
&_flipNegs($scoreFile, $outFile);


##############################################
#     BEGIN CODE
#############################################
sub _flipNegs {
    my $inFile = shift;
    my $outFile = shift;
    
    #open in and out
    my $fileOpened = open IN, $inFile;
    if (!$fileOpened) {
	print "ERROR: unable to open inFile: $inFile\n";
	return;
    }
    open OUT, ">$outFile" or die ("ERROR: unable to open outFile: $outFile\n");

    #read in, and output as its read
    # flip -1 when encountered
    while (my $line = <IN>) {
	my @vals = split(/\<\>/, $line);
	if ($vals[0] == -1) {
	    $vals[0] = 999999999;
	}
	print OUT "$vals[0]<>$vals[1]<>$vals[2]";
    }
    close IN;
    close OUT;
}


