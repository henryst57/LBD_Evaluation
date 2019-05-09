#Program to take a scores file and turn it into a precision
# at k graph
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
# the $outFile is where the first column is the average precision
# at K over all terms, and every other column is the precision
# at K for a single term. The first column can be used directly
# to create an average precision at K graph.
my $VERSION = 0.1;
use Getopt::Long;

#grab options
eval(GetOptions( "version", "help", "random", "sortAscending"));

#check for help or version options
if (defined $opt_help) {
    &showHelp();
    exit;
}
if (defined $opt_version) {
    &showVersion();
    exit;
}

#check that the inpout is the correct size
if (scalar @ARGV != 3) {
    print STDERR "ERROR: three arguments are required: predictedFile, goldFile, and outputFile\n";
    &askHelp();
    exit;
}

#grab random param, which tells if random order should be used
my $random = 0;
if (defined $opt_random) {
    $random = 1;
}
my $sortAscending = 0;
if (defined $opt_sortAscending) {
    $sortAscending = 1;
}
#grab the parameters and execute
my $predictedScoresFile = shift;
my $goldScoresFile = shift;
my $outFile = shift;
&calculatePrecisionAtK($predictedScoresFile, $goldScoresFile, $outFile, $random, $sortAscending);



###################################################
# Begin Code
###################################################


# Calculates precision at k
sub calculatePrecisionAtK {
    #grab the input
    my $predictedScoresFile = shift;
    my $goldScoresFile = shift;
    my $outFile = shift;
    my $random = shift;
    my $sortAscending = shift;
    
    #read in the predicted and gold scores from file
    my $predictedScoresRef = &readScoresFile($predictedScoresFile);
    my $goldScoresRef = &readScoresFile($goldScoresFile);

    #randomize scores if needed
    if ($random) {
	&randomizeScores($predictedScoresRef);
    }

########### CALCULATE Precision at K for each Subject CUI
    #calculate precision at K for each subject CUI
    my %precisionsAtK = ();
    #iterate over each vector to calculate an average
    foreach my $subject (sort keys %{$predictedScoresRef}) {
	#ensure the dataset is correct
	(defined ${$goldScoresRef}{$subject}) or die ("ERROR: gold contains CUIs that are not predicted\n");

	#grab the vector of scores
	my %goldVector = %{${$goldScoresRef}{$subject}};
	my %predictedVector = %{${$predictedScoresRef}{$subject}};


############# SORT WITH PENALIZATION
        #sort the predicted objects in descending order, but penalize tied
	# terms such that terms with higher gold relatedness are placed last
        my @untiedRankedObjects = ();
	#sort in ascending or descending order
	my @rankedObjects = ();
	if ($sortAscending > 0) {
	    @rankedObjects = sort {$predictedVector{$a} <=> $predictedVector{$b}} keys %predictedVector;
	} else {
	    @rankedObjects = sort {$predictedVector{$b} <=> $predictedVector{$a}} keys %predictedVector;
	}
	for (my $i = 0; $i < scalar keys %predictedVector; $i++) {
	    #check if you are at the last index
	    if ($i+1 >= scalar @rankedObjects) {
		#you are at the last element, add it, then you are done
		push @untiedRankedObjects, $rankedObjects[$i];
	    }
	    else {
		#you are not at the last element, check for ties
		
		#check if this is tied with the one ranked higher than it
		if ($predictedVector{$rankedObjects[$i]} == $predictedVector{$rankedObjects[$i+1]}) {
		    #this is tied with the one ranked higher than it
		    # Get all the ranks that it is tied with
		    my @tiedIndeces = ();
		    push @tiedIndeces, $i;
		    my $j;
		    for ($j = $i+1; $j < scalar @rankedObjects; $j++) {
			if ($predictedVector{$rankedObjects[$i]} == $predictedVector{$rankedObjects[$j]}) {
			    push @tiedIndeces, $j;
			}
			else {
			    #index $j is not tied, so quit this loop, 
			    # already collected all tied indeces
			    last;
			}
		    }

		    #now you have a list of tied indeces, order them such that
		    # indeces with lower gold scores are ranked first.
		    # Do this by contructing and sorting a hash of gold scores
		    my %goldScores = ();
		    foreach my $index (@tiedIndeces) {
			#add the gold score (if defined, else add 0)
			my $goldScore = 0;
			if (defined $goldVector{$rankedObjects[$index]}) {
			    $goldScores = $goldVector{$rankedObjects[$index]};
			}
			$goldScores{$rankedObjects[$index]} = $goldScore;
		    }
		    
		    #add the tied terms to the untied ranked objects
		    # with the ones with the lowest gold scores
		    # placed first
		    foreach my $object (sort {$goldScores{$a} <=> $goldScores{$b}} keys %goldScores) {
			push @untiedRankedObjects, $object;
		    }
		    
		    #update $i to the top of untied ranks
		    # and subtract 1, since $i will be incremented at the
		    # bottom of the loop thereby setting it to the correct
		    # position
		    $i += scalar @tiedIndeces - 1;
		}
		else {
		    #this is not tied with the next ranked, 
		    # so add it to the untied ranked list
		    push @untiedRankedObjects, $rankedObjects[$i];
		}
	    }
	}

###
###### NOW, Actually Calculate Precision at K
        #find the precision  at each rank for this vector
	my $rank = 0;
	my $numTruePredictions = 0;
	my @precisions = ();
        foreach my $object (@untiedRankedObjects) {
	    #only add if the gold score is defined, otherwise it has a score of 0
	    if (defined $goldVector{$object}) {
		#grab the value from the gold vector
		# if value > 0, then it has a future association
		# and is therefore a true prediction
		my $value = $goldVector{$object};

		#update the number of true predictions at this rank
		if ($value  > 0) {
		    $numTruePredictions++;
		}
		#else this is a false prediction, don't increment
	    }	  
	    #else don't update numTruePredictions ... do nothing

	    #increment rank for every predicted discovery
	    $rank++;

	    #save the precision at this rank, which is the
	    # number of true predictions / num predicted true (rank)
	    $precisions[$rank-1] = $numTruePredictions/$rank;
	    #$precisions[$rank-1] = $numTruePredictions;
	}
	
	#save the sum indexed by the vector cui
        $precisionsAtK{$subject} = \@precisions;
    }


########### FIND THE AVERAGE PRECISION AT K FOR EACH RANK
    #find the largest k
    my $maxK = 0;
    foreach my $subject (keys %precisionsAtK) {
	if ((scalar @{$precisionsAtK{$subject}}) > $maxK) {
	    $maxK = scalar @{$precisionsAtK{$subject}};
	}
    }

    #find the average percent found at each rank 
    my @average = ();
    for (my $k = 0; $k < $maxK; $k++) {
	$average[$k] = 0;
	my $n = 0;
	foreach my $subject (keys %precisionsAtK) {
	    if ((scalar @{$precisionsAtK{$subject}}) > $k) {
		$average[$k] += ${$precisionsAtK{$subject}}[$k];
		$n++;
	    }
	} 
	$average[$k] /= $n;
    }
    

    #calculate the area under the curve, which equals the
    # Mean Average Precision (MAP)
    my $auc = 0;
    for (my $i = 1; $i < scalar @average; $i++) {
        #auc += length*height                                                 
	# length is the x-axis width, (always 1, since its rank)         
	# height is the y-axis height = average[$i]
	# Thereofre, auc = sum(1*average[i]) = sum ($average)
	$auc += ($average[$i])
    }
    $auc /= (scalar @average);


############ OUTPUT THE RESULTS #######################
    #output the results
    open OUT, ">$outFile" or die ("ERROR: cannot open outFile: $outFile\n");

    #print out title row
    print OUT "average\t$auc\t";
    foreach my $cui (sort keys %precisionsAtK) {
	print OUT "$cui\t"
    }
    print OUT "\n";

    #output the average precision at k and each individual precisions
    my $i = 0;
    my $somethingDefined = 1;
    while ($somethingDefined > 0) {
        #assume nothing defined
	$somethingDefined = 0;
 
	#print average as first column
	if (defined $average[$i]) {
	    print OUT "$average[$i]";
	    $somethingDefined = 1;
	}
	#skip a column (thats where auc is printed in the header)
	print OUT "\t\t";

	#print individual precisions
	foreach my $cui (sort keys %precisionsAtK) {
	    if (defined ${$precisionsAtK{$cui}}[$i]) {
		print OUT "${$precisionsAtK{$cui}}[$i]";
		$somethingDefined = 1;
	    }
	    print OUT "\t";
	}
	print OUT "\n";
	$i++;
    }
    close OUT;
}


# Reads in a scores file containing cui pairs and a score
# Specific format: score<>cui<>cui\n
# and returns it as a vector hash of the format:
# hash{cui1} = hash{cui2} = score
sub readScoresFile {
    my $scoresFile = shift;

    #read the scores file
    # reads in as hash{cui1} = hash{cui2} = score
    open IN, $scoresFile or die("ERROR: unable to open scoresFile: $scoresFile\n");
    my %scores = ();
    while (my $line = <IN>) {
	#grab line values
	chomp $line;
	my @vals = split (/\<\>/, $line);
	if (scalar @vals != 3) {
	    die ("Formatting error on line, it should contain 3 values: $line\n");
	}
	my $score = $vals[0];
	my $cui1 = $vals[1];
	my $cui2 = $vals[2];

	#save the values as a vector hash
	if (!defined $scores{$cui1}) {
	    my %newHash = ();
	    $scores{$cui1} = \%newHash;
	}
	${$scores{$cui1}}{$cui2} = $score;
    }
    close IN;
    
    return \%scores;
}


#Assigns random scores to all values in the scores vector
sub randomizeScores {
    my $scoresRef = shift;
    foreach $subject (keys %{$scoresRef}) {	    
	foreach $object (keys %{${$scoresRef}{$subject}}) {
	    ${${$scoresRef}{$subject}}{$object} = rand(1);
	}
    }	    
}



#### Function to show the version number
sub showVersion {
    print "current version is $VERSION\n";
}

#### Function to output "ask for help" if the user goofed
sub askHelp {
    print STDERR "Type createPrecisionAtK.pl --help for help\n";
}

#### Shows the help (description and options)
sub showHelp {
    print "Creates a precision at K graph from a scores and truth file.\n";
    print "Example of how to run (with all options):\n"
    print "   perl createPrecisionAtK.pl scoresFile goldFile graphOutputFile --sortAscending --random";
}
