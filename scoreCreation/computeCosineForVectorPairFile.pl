#computes the cosine distance between a set of cuis in a file from a sparse vector file
# Output:
# a cosine pairs file the form: cosine<>CUI1<>CUI2\n
# Input:
# cui pairs file: of the form: CUI<>CUI\n
# vectors file containing the vectors for every cui in the 
# vocabulary of the form:
#    rowCui<>cui,value<>cui,value<>...<>cui,value<>
# Input can be a matrix file instead, which contains values of the
# form:
#    $cui1\t$cui2\t$value\n
# Input can be word2vec format instead, which contains:
#    first line of file is number of vectors space vector length
#    subsequent lines are of the form:
#    term value value value ... value\n
# Both input and output are sparse format, so only cuis for which
# a non-zero value has a value are stored.
#
# The vector file format must be specified as:
#    'matrix', 'word2vec', 'vector'
#
# This is used to compare cosine distances as an indirect evaluation
# measure using the indirectEval graphs  
use strict;
use warnings;

my $cuiFile = 'cuiPairs/pairs_threshold6';
my $vectorFile = 'data/1975_2009_window8_threshold1';
my $outputFile = 'results_t1/threshold6_dirCos';
my $vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold6_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold5';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold5_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold5_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold4';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold4_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold4_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold3';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold3_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold3_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold2';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold2_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold2_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold1';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold1_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold1_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);

$cuiFile = 'cuiPairs/pairs_threshold0';
$vectorFile = 'data/1975_2009_window8';
$outputFile = 'results_t1/threshold0_dirCos';
$vectorFileFormat = 'matrix';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);
$vectorFile = 'data/vectors_word2vec_1975_2009_abstractCuis_window8_size200_min-count0_cbow';
$outputFile = 'results_t1/threshold0_w2vCos';
$vectorFileFormat = 'word2vec';
&computeCosineForFile($vectorFile, $cuiFile, $outputFile, $vectorFileFormat);




#######################################################
#                     Begin Code
#######################################################

#computes the cosine distances for a set of cui pairs
sub computeCosineForFile {
    my $vectorFile = shift;
    my $cuiFile = shift;
    my $outputFile = shift;
    my $vectorfileFormat = shift;

    #read input
    my $cuisArrayRef = &readCuiPairFile($cuiFile);
    my $vectorsHashRef;
    if ($vectorFileFormat eq 'matrix') {
        $vectorsHashRef = &readMatrixFile($vectorFile);
    }
    elsif ($vectorFileFormat eq 'word2vec') {
        $vectorsHashRef = &readWord2VecFile($vectorFile);
    }
    elsif ($vectorFileFormat eq 'vector') {
        $vectorsHashRef = &readVectorFile($vectorFile);
    }
    else {
        die ("ERROR: vectorFileFormat must be specified as vector, matrix, or word2vec: $vectorFileFormat\n");
    }

    #compute cosine for each cui set and output
    open OUT, ">$outputFile" or die ("ERROR: error opening outputFile: $outputFile\n");
    foreach my $cuiSet (@{$cuisArrayRef}) {
	#get the cui pair
	my @cuis = split(/<>/,$cuiSet);
	if (scalar @cuis != 2) {
	    die ("Formatting error parsing CUIs: $cuiSet\n");
	}

	#get each vector
	my $vector1 = ${$vectorsHashRef}{$cuis[0]};
	(defined $vector1) or print("WARNING: no vector for cui: $cuis[0]**\n");
	my $vector2 = ${$vectorsHashRef}{$cuis[1]};
	(defined $vector2) or print("WARNING: no vector for cui: $cuis[1]**\n");

	my $cosine = 0;
	if (defined $vector1 && defined $vector2) {
	    #compute cosine
	    $cosine = &computeCosine($vector1, $vector2);
	}
        #output the results
	print OUT "$cosine<>$cuiSet\n";
    }
    close OUT;

    print "Done!\n";
}


#reads the vector file of the form: VECTOR_CUI<>CUI,VALUE<>CUI,VALUE<>...\n
# returns a ref to a hash of hashes, of the form: %vectors{$cui}=\%vector
#     where %vector is of the form: $vector{$cui} = $value
sub readVectorFile {
    my $vectorFile = shift;
    
    #read each vector
    open IN, $vectorFile or die ("ERROR: unable to open vectorFile: $vectorFile\n");
    my %vectors = ();
    while (my $line = <IN>) {
	#seperate the line into value pairs
	chomp $line;
	my @vals = split('<>',$line);

	#the first value of the line the cui that the vector is for
	# create that vector and add to the vectorsHash
	my $vectorCui = shift @vals;
	my %vector = ();
	$vectors{$vectorCui} = \%vector;

	#populate the vector with the cui,value pairs
	foreach my $valPair (@vals) {
	    (my $cui, my $val) = split(',',$valPair);
	    $vector{$cui} = $val;
	}
    }
    
    #return the vectors hash
    return \%vectors;
}


#reads the vector file of the form: 
#    first line of file is number of vectors space vector length
#    subsequent lines are of the form:
#    term value value value ... value\n 
# returns a ref to a hash of hashes, of the form: %vectors{$cui}=\%vector 
#     where %vector is of the form: $vector{$cui} = $value
sub readWord2VecFile {
    my $vectorFile = shift;

    #read each vector
    open IN, $vectorFile or die ("ERROR: unable to open vectorFile: $vectorFile\n");

    #skip the header line 
    my $headLine = <IN>;

    #read each vector line 
    my %vectors = ();
    while (my $line = <IN>) {
        #seperate the line into value pairs
	chomp $line;
        my @vals = split(' ',$line);

        #the first value of the line the cui that the vector is for
        # create that vector and add to the vectorsHash
	my $vectorCui = shift @vals;
        my %vector = ();
        $vectors{$vectorCui} = \%vector;

        #populate the vector values
	my $index = 0;
        foreach my $val (@vals) {
	    $vector{$index} = $val;
	    $index++;
        }
	#print "\n";
    }

    #return the vectors hash
    return \%vectors;
}



#reads the matrix file of the form: cui1\tcui2\tvalue...\n
# returns a ref to a hash of hashes, of the form: %vectors{$cui}=\%vector
#     where %vector is of the form: $vector{$cui} = $value
sub readMatrixFile {
    my $vectorFile = shift;

    #read each vector
    open IN, $vectorFile or die ("ERROR: unable to open vectorFile: $vectorFile\n");
    my %vectors = ();
    while (my $line = <IN>) {
        #seperate the line into value pairs
	chomp $line;
        my @vals = split(/\t/,$line);
        #cui1 = vals[0]
        #cui2 = vals[1]
        #val  = vals[2]
	
        #create the vector if needed
	if (!defined $vectors{$vals[0]}) {
            my %emptyHash = ();
            $vectors{$vals[0]} = \%emptyHash;
        }
        #add this value
	${$vectors{$vals[0]}}{$vals[1]} = $vals[2];
    }
    #return the vectors hash
    return \%vectors;
}



#reads the cui pair file of the form: cui<>cui\n
# and returns a ref to an array of each chomped line
sub readCuiPairFile {
    my $cuiFile = shift;

    #read each line
    my @cuiPairs = ();
    open IN, $cuiFile or die ("ERROR: unable to open cuiFile: $cuiFile");
    while (my $line = <IN>) {
	chomp $line;
	push @cuiPairs, $line;
    }

    return \@cuiPairs;
}


#computes the cosine distance between two vectors
# vectors are of the form: %vector{$cui}=$value;
sub computeCosine {
    my $vector1Ref = shift;
    my $vector2Ref = shift;

    #compute the numerator, which is the sum of x_i * y_i values
    my $numerator = 0;
    foreach my $key (keys %{$vector1Ref}) {
	if (exists ${$vector2Ref}{$key}) {
	    $numerator += (${$vector1Ref}{$key} * ${$vector2Ref}{$key});
	}
    }

    #find the denominator, which is the product of x and y lengths
    #find sum of x squared
    my $vector1Sum = 0;
    foreach my $key (keys %{$vector1Ref}) {
	$vector1Sum += (${$vector1Ref}{$key} * ${$vector1Ref}{$key});
    }

    #find sum of y squared
    my $vector2Sum = 0;
    foreach my $key (keys %{$vector2Ref}) {
	$vector2Sum += (${$vector2Ref}{$key} * ${$vector2Ref}{$key});
    }

    #find the denominator
    my $denominator = sqrt($vector1Sum)*sqrt($vector2Sum);
    
    #calcualte the score (with error checking)
    my $score = -1;  
    if ($denominator != 0) { 
#should I check if numerator == 0 as well?  What does it mean if they don't have any cuis in common?  this would calucalte their cosine distance to be 0 then?  ... it would be, which is correct, but weird
	$score = $numerator/$denominator;
    }
    
    #return the cosine distance
    return $score;
}
