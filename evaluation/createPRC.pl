#Program to take a scores file and turn it into a PRC or ROC plot
# Example of how to run (with all possible options)
#  perl createPRC.pl scoresFile goldFile graphOutputFile --roc --sortAscending --random
#
#Input
# $gold is a tab seperated list of cui, cui, score, where
#  the score is the future relatedness. A score of <= 0 
#  indicates that it is a false sample. > 0 a true sample
#  format is: score<>cui<>cui\n
#
# $predicted is a tab seperate list of cui, cui, score, where
#  the score indicates the certainty of true. A threshold is 
#  applied in ascending order to the predicted cuis at each rank, 
#  E.G. A pair with a score of 0 will be considered false, before  
#  a pair with a score of 1. 
#  format is: score<>cui<>cui\n
#
#Output
# the $prcOut is output as two data columns. The first
# column indicates recall, the second precision. 
# The precision and recall curve can then be plotted 
# from that data. Columns are tab seperated.
# format is: recall\tprecision
# The first line of the document is the title line,
# which contains the name of the file and the 
# area under the curve (auc)

my $VERSION = 0.1;
use Getopt::Long;

#grab options
eval(GetOptions( "version", "help", "roc", "random", "sortAscending" ));
#check for help and version options
if (defined $opt_help) {
    &showHelp();
    exit;
}
if (defined $opt_version) {
    &showVersion();
    exit;
}
#option to construct ROC vs. PRC curve
my $constructROC = 0;
if (defined $opt_roc) {
    $constructROC = 1;
}
my $random = 0;
if (defined $opt_random) {
    $random = 1;
}
my $sortAscending = 0;
if (defined $opt_sortAscending) {
    $sortAscending = 1;
}


#Grab the predicted, gold, and output parameters
if (scalar @ARGV != 3) {
    print STDERR "ERROR: three arguments are required: predictedFile, goldFile, and outputFile.\n";
    &askHelp();
    exit;
}
my $predicted = shift;
my $gold = shift;
my $outFile = shift;


#create the PRC.ROC curve
&_createPRC($gold, $predicted, $outFile, $constructROC, $random, $sortAscending);


############################################
#       Begin Code
############################################
sub _createPRC {
    #grab the input
    my $gold = shift;
    my $predicted = shift;
    my $prcOut = shift;
    my $calculateROC = shift;
    my $random = shift;
    my $sortAscending = shift;
    
    #read true data in (score<>cui<>cui on each line)
    my %goldScores = ();
    open IN, $gold or die ("ERROR: cannot open gold: $gold\n");
    while (my $line = <IN>) {
	#grab values from the line
	chomp $line;
	my @vals = split (/\<\>/,$line);
	#vals[0] = score, $vals[1] = cui1, $vals[2] = cui2
	if (scalar @vals != 3) {
	    die ("ERROR reading gold file, 3 values expected on each line: $line\n");
	}
	
	#save the truth value of the pair
	$goldScores{"$vals[1],$vals[2]"} = ($vals[0] > 0);
    }
    close IN;
    
    #read in the predicted scores
    my %predictedScores = ();
    open IN, $predicted or die ("ERROR: cannot open predicted: $predicted\n");
    while (my $line = <IN>) {
	#grab values from the line
	chomp $line;
	my @vals = split (/\<\>/,$line);
	#vals[0] = score, $vals[1] = cui1, $vals[2] = cui2
	if (scalar @vals != 3) {
	    die ("ERROR reading predicted file, 3 values expected on each line: $line\n");
	}
	
	#save the truth value of the pair
	$predictedScores{"$vals[1],$vals[2]"} = $vals[0];
	#assign a random score to produce a random ordering
	if ($random) {
	    $predictedScores{"$vals[1],$vals[2]"} = rand(1);
	}
    }
    close IN;
    
    #sort in ascending or descending order
    my @rankedPairs = ();
    if ($sortAscending > 0) {
	@rankedPairs = sort {$predictedScores{$a} <=> $predictedScores{$b}} keys %predictedScores;
    } else {
       @rankedPairs = sort {$predictedScores{$b} <=> $predictedScores{$a}} keys %predictedScores;
    }
    
    #penalize tied terms
    my @untiedRankedPairs = ();
    for (my $i = 0; $i < scalar @rankedPairs; $i++) {
	#check if you are at the last index
	if ($i+1 >= scalar @rankedPairs) {
	    #you are at the last element, add it, then your done
	    push @untiedRankedPairs, $rankedPairs[$i];
	}
	else {
	    #you are not at the last element, check for ties

	    #check if this is tied with the one ranked higher than it
	    if ($predictedScores{$rankedPairs[$i]} == $predictedScores{$rankedPairs[$i+1]}) {
		#this is tied with the one ranked higher than it. 
		# Get all ranks that it is tied with
		my @tiedIndeces = ();
		#add the $ith index (which started the tie to the list of tied indeces)
		push @tiedIndeces, $i;
		my $j;
		for ($j = $i+1; $j < scalar @rankedPairs; $j++) {
		    if ($predictedScores{$rankedPairs[$i]} == $predictedScores{$rankedPairs[$j]}) {
			#this is tied, so add it to the list of tied indeces
			push @tiedIndeces, $j;
		    }
		    else {
			#otherwise, its not tied, so quit this loop
		        last;
		    }
		}

		#now we have a list of tied indeces, order them such that false indeces are
		# ordered first
		my @falseTied = ();
		my @trueTied = ();
		foreach my $index(@tiedIndeces) {
		    if ($goldScores{$rankedPairs[$index]} > 0) {
			#this is true, add it to the list of true tied
			push @trueTied, $index;
		    }
		    else {
			#this is false, add it to the list of false tied
			push @falseTied, $index;
		    }
		}

		#add the false tied to the list of ranked indeces
		foreach my $index(@falseTied) {
		    push @untiedRankedPairs, $rankedPairs[$index];
		}
		#then add the true tied to the list of ranked indeces
		foreach my $index(@trueTied) {
		    push @untiedRankedPairs, $rankedPairs[$index];
		}

		#update $i to the top of untied ranks
		# and subtract 1, since $i will be incremented at the 
		# bottom of the loop thereby setting it to the correct
		# position
		$i += scalar @tiedIndeces - 1; 
	    }
	    else {
		#this pair is not tied with the next ranked, 
		# so add it to the untied ranked list
		push @untiedRankedPairs, $rankedPairs[$i];
	    }
	}
    }
    @rankedPairs = @untiedRankedPairs;

    #count the total number true
    my $totalTrue = 0;
    my $totalFalse = 0; #only needed for ROC
    foreach my $pair (keys %goldScores) {
	if ($goldScores{$pair} > 0) {
	    $totalTrue++;
	}
	else {
	    $totalFalse++;
	}
    }

    #find precision and recall at each rank
    my @precision = ();
    my @recall = ();
    my $numPredictedTrue = 0;
    my $numTruePredictions = 0;
    #also calculate auc as the sum of rectangles under the
    # curve, that is sum of lenght*width at each datapoint
    my $auc = 0;
    for (my $i = 0; $i < scalar @rankedPairs; $i++) {
	#$i is the number predicted true, since we are 
	# thresholding by rank
	$numPredictedTrue = $i+1;

        #count the number of true predictions
	if ($goldScores{$rankedPairs[$i]} > 0) {
	    $numTruePredictions++;
	}

	#calculate precision and recall at this rank
	$precision[$i] = $numTruePredictions/$numPredictedTrue;
	$recall[$i] = $numTruePredictions/$totalTrue;

	#calculate ROC curve if option is enabled
	if ($calculateROC) {
	    #the y-axis is true positive fraction
	    #  which corresponds to the y-axis of precision for prc
	    $precision[$i] = $numTruePredictions/$totalTrue;

	    #the x-axis is false positive fraction
	    #  which corresponds to the x-axis of recall for prc
	    # numFalse predictions is all samples except those predicted true 
	    my $numFalsePredictions = ($i+1)-$numTruePredictions;
	    $recall[$i] = $numFalsePredictions/$totalFalse;
	}
	
	#auroc += length*height
	# length is the x-axis width, the previouss recall to current recall
	# height is the y-axis height = precision
	if ($i > 0) { #no width for first datapoint
	    $auc += ($recall[$i]-$recall[$i-1])*$precision[$i]
	}
    }

    #output the true/false positive rate in tab seperated columns
    open OUT, ">$prcOut" or die ("ERROR: unable to open prcOut: $prcOut\n");
    #output the fileName and AUC on the first line
    print OUT "$prcOut\tAUC:\t$auc\n";
    #output the column labels on the second line
    if ($calculateROC) {
	print OUT "True Positive Rate\tFalse Positive Rate\n";
    }
    else {
	print OUT "Recall\tPrecision\n";
    }
    #output the values at each subsequent line
    for (my $i = 0; $i < scalar @rankedPairs; $i++) {
	print OUT "$recall[$i]\t$precision[$i]\n";
    }
    close OUT;

    print "Done!\n";
}



#### Function to show the version number
sub showVersion {
    print "current version is $VERSION\n";
}

#### Function to output "ask for help" if the user goofed
sub askHelp {
    print STDERR "Type createPRC.pl --help for help\n";
}

#### Shows the help (description and options)
sub showHelp {
    print "Creates a PRC or ROC curve from a scores and truth file.\n";
    print "Example of how to run (with all options):\n";
    print "   perl createPRC.pl scoresFile goldFile graphOutputFile --roc --sortAscending --random";
}
