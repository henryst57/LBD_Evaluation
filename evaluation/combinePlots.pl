#combines the first column of prk or crgs into a single file
# This is just a convenience method that makes plotting easier
# This just makes plotting everything easier
use strict;
use warnings;

my $outFile = 'comparison_pak_threshold6.csv';
my $resultsFolder = "precisionAtK/";
my @files = ();
push @files, $resultsFolder."pak_threshold6_ltc";
push @files, $resultsFolder."pak_threshold6_lta_asc";
push @files, $resultsFolder."pak_threshold6_mwa_asc";
push @files, $resultsFolder."pak_threshold6_sbc";
push @files, $resultsFolder."pak_threshold6_lsa_asc";
push @files, $resultsFolder."pak_threshold6_w2vCos_asc";
push @files, $resultsFolder."pak_threshold6_dirCos_asc";
push @files, $resultsFolder."pak_threshold6_freq";
push @files, $resultsFolder."pak_threshold6_random";
push @files, $resultsFolder."pak_threshold6_ideal";
my @labels = ("average", "LTC", "LTA", "MWA", "SBC", "LSA", "w2vCos", "dirCos", "Freq", "Random", "Ideal");




########## begin code

#open each file and assign a handle
my @fileHandles = ();
foreach my $file (@files) {
    open my $fileHandle, $file or die ("ERROR: unable to open file: $file\n");
    push @fileHandles, $fileHandle;
}


#output the header
open OUT, ">$outFile" or die ("ERROR: unable to open outFile: $outFile\n");
my $numLabels = scalar @labels;
print OUT ",";
foreach my $label (@labels) {
    print OUT "$label,";
}
print OUT "\n";

#read all the averages
my @averages = ();
foreach my $fileHandle (@fileHandles) {
    my $line = <$fileHandle>;
    #grab the average
    $line =~ /average\s(\d+\.?\d*)\t/;	    
#    $line =~ /auc\s+=\s+(\d+\.?\d*)\s+/;
    unshift @averages, $1;
}

#read each score and output as you go
my $printAverage = (scalar @fileHandles)-1;
my $done = 0;
while (1) {
    my $printString = '';
    #check if you should print the average 
    # this happens only when it is the first
    # line of a file
    if ($printAverage >= 0) {
	#print the average then go to the next line
	$printString .= $labels[$numLabels-$printAverage-1].",$averages[$printAverage],";
	$printAverage --;
    }
    else {
	$printString .= ",,";
    }

    #grab each score from the line
    foreach my $fileHandle (@fileHandles) {
	#read the line, quit if its the last line
	my $line = <$fileHandle>;
	if (!$line) {
	    $done = 1;
	    last;
	}

	#grab each average score
	$line =~ /([^\s]+)/;
	$printString .= "$1,";
    }
    print OUT "$printString\n";

    #read lines until there are no more
    if ($done) {
	last;
    }
}



