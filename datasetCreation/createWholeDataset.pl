# Creates the hybrid time sliced dataset, which consists
# of four ouput files:
#    1) known - list of all 'known' cui pairs
#    2) gold - list of all gold standard cui pairs. These are
#              the cui pairs that exist in the post-cutoff set
#              but not in the pre-cutoff set
#    3) truth - list of all  cui pairs and their truth value.
#               This isn't all possible combinations of pairs,
#               but rather all possible within the semantic 
#               type requirements (e.g. type1-type2 or 
#               type2-type1 pairs), and that are not in the
#               known set. 
#    4) pairs - this is the same list as truth, but without
#               a truth label.
#    5) vocab - a list of terms in the vocabulary.
# The truth set is used to evaluate the term filtering and 
# term ranking sets of LBD. Is simulates what would happen
# if all CUI pairs were generated and then filtered based on 
# removing known and applying semantic type filters. The 
# known dataset is needed if you are evaluateing the term
# generation step, since removing known and applying
# semantic type filters must be done manually. Gold is then
# used to evaluate the term generation step. The terms in 
# the vocabulary are likely also needed for evaluating the
# term generation step, since only terms in the pre-defined
# vocabulary are considered.
#
# This code outputs a known, gold, truth, and vocab file 
# for each possible threshold until no terms remain.         
#
# Input Formats:
# SemMed File format is a subject CUI followed by a list
#  of object CUIs for which a relationship exists, e.g.:
#    SUBJECT_CUI\tPRED_TYPE\tOBJECT_CUI\t_OBJECT_CUI\t...\n
#
# CuiCooccurrence format is:
#    CUI\tCUI\tCoocCount\n
#
# Input files are:
# postCutoff_SemmedFile - contains future knowledge minus known
#                         knowledge from SemMedDB, generated from
#                         getSemMedDBData.pl
# preCutoff_SemmedFile - known predications from SemMedDB, generated
#                        from getSemMedDBData.pl                         
# preCutoff_MedlineCoocFile - file of pre-cutoff co-occurrences from
#                             MEDLINE, generated from UMLS::Association
#                     
# Output Format:
# Truth file format:
#   A cui pair and true/false value on each line. A  value of 0 
#   indicates they are a false sample (that pair does not occur  
#   in the future dataset or the pair exists in the past dataest),
#   and a value of 1 that they are a true sample (they occur in 
#   the future dataset but not the past dataset). Specific format:
#      [0,1]<>$subject<>$object\n
#
# Gold and Known file format:
#   cui1<>cui2\n;

use strict;
use warnings;

my $postCutoff_SemmedFile = 'data/true_typeLimited';
my $preCutoff_SemmedFile = 'data/known_typeLimited';
my $preCutoff_MedlineCoocFile = 'data/1800_2009_window8';
my $goldOutFile = 'results/gold';
my $knownOutFile = 'results/known';
my $truthValueOutFile = 'results/truth';
my $pairsOutFile = 'results/pairs';
my $vocabOutFile = 'results/vocab';
&makeTrueFalse($postCutoff_SemmedFile, $preCutoff_SemmedFile, $preCutoff_MedlineCoocFile, $goldOutFile, $knownOutFile, $truthValueOutFile, $pairsOutFile, $vocabOutFile);


############################################
##### BEGIN CODE
############################################


#Reads in the semmed file, which contains only true samples
# and outputs a classification file containing all true and 
# all false samples based on the vocab in the file
sub makeTrueFalse {
    my $postCutoff_SemmedFile = shift;
    my $preCutoff_SemmedFile = shift;
    my $preCutoff_MedlineCoocfile = shift;
    my $goldOutFile = shift;
    my $knownOutFile = shift;
    my $truthValuesOutFile = shift;
    my $pairsOutFile = shift;
    my $vocabOutFile = shift;

    print "Reading PostCutoff SemMed\n";
    #read in the true  pairs and record the vocabulary
    # semmed file is the format:
    #    SUBJECT_CUI\tPRED_TYPE\tOBJECT_CUI\t_OBJECT_CUI\t...\n
    open IN, $postCutoff_SemmedFile 
	or die ("ERROR:unable to open postCutoff_SemmedFile: $postCutoff_SemmedFile\n");
    my %futurePairs = ();
    my %futureVocab = ();
    while (my $line = <IN>) {
	chomp $line;

	#grab values from the line
	my @vals = split ("\t", $line);
	my $subject = shift @vals;
	my $relType = shift @vals;

	#add the subject to vocab
	$futureVocab{$subject}=1;

	#add each pair to the dataset (order doesn't matter)
	foreach my $object (@vals) {
	    $futurePairs{"$subject,$object"} = 1;
	    $futurePairs{"$object,$subject"} = 1;
	    $futureVocab{$object}=1;
	}
    }
    close IN;

    print "Reading Co-occurrence File\n";
    #read in the known cui pairs from a pre-cutoff MEDLINE 
    #  co-occurrence file
    my %knownPairs = ();
    my %medlineVocab = ();
    open IN, $preCutoff_MedlineCoocFile 
	or die("ERROR: unable to open preCutoff_MedlineCoocFile: $preCutoff_MedlineCoocFile\n");
    while (my $line = <IN>) {
	my @vals = split (/\t/,$line);
	#vals[0]=cui1, vals[1]=cui2, vals[2]=score
	#only add if its in the vocabulary to save on memory
	# add make order not matter
	if (defined $futureVocab{"$vals[0]"} 
	     && defined $futureVocab{"$vals[1]"}) {
	    $knownPairs{"$vals[0],$vals[1]"}=1;
	    $knownPairs{"$vals[1],$vals[0]"}=1;
	}
	
	#update the vocabularies
	$medlineVocab{$vals[0]}=1;
	$medlineVocab{$vals[1]}=1;
    }
    my %knownVocab = %medlineVocab;
    close IN;

    print "Reading PreCutoff SemMed\n";
    #...and read in the known cui pairs from SemMedDB to 
    #  ensure we grab all known CUI pairs
    open IN, $preCutoff_SemmedFile 
	or die("ERROR: unable to open preCutoff_SemmedFile: $preCutoff_SemmedFile\n");
    while (my $line = <IN>) {
	chomp $line;
	#line is subject\trelType\tlistOfObjects
	my @vals = split("\t",$line);
	my $subject = shift @vals;
	my $relType = shift @vals;
	$knownVocab{$subject}=1;
	#add each pair to the list of known pairs
	# and make order not matter
	foreach my $object (@vals) {
	    $knownPairs{"$subject,$object"}=1;
	    $knownPairs{"$object,$subject"}=1;
	    $knownVocab{$object}=1;
	}
    }

    print "Merging Vocabulary\n";
    #construct the vocabulary we will use. The vocab is a combination 
    # of term pairs that appear in both the past and future vocabularies
    #We also check to make sure the terms occur in both MEDLINE and 
    # SemMedDB
    print "knownVocab Size = ".(scalar keys %knownVocab)."\n";
    print "medlineVocab Size = ".(scalar keys %medlineVocab)."\n";
    print "futureVocab Size = ".(scalar keys %futureVocab)."\n";
    my %vocabulary = ();
    foreach my $term (keys %futureVocab) {
	if (defined $knownVocab{$term} && defined $medlineVocab{$term}) {
	    $vocabulary{$term}=1;
	}
    }
    print "Vocab Size = ".(scalar keys %vocabulary)."\n";
        
    #We now have a set of vocabulary terms for our dataset
    # a set of known term pairs, and a set of future term pairs
    #We will now threshold the dataset at multiple intervals
    # create a dataset with all possible term pairs in the 
    # vocab, and use these future and known pairs as truth values

    print "Applying Thresholds\n";
    #apply multiple thresholds, and output datasets at each threshold
    # we repeat this until there are no terms remaining in the vocabulary
    # thresholds are based on number of unique and number of unique objects
    # that each term has.
    my $threshold = 0;
    my $currentVocabRef = \%vocabulary;
    print "Vocab Size TOP = ".(scalar keys %{$currentVocabRef})."\n";
    while ((scalar keys %{$currentVocabRef}) > 0) {
	print "   Applying Threshold of $threshold\n";
	#apply a threshold to generate a reduced vocabulary
	$currentVocabRef = &_thresholdDataset($currentVocabRef, \%futurePairs, \%knownPairs, $threshold);
	print "Vocab Size $threshold = ".(scalar keys %{$currentVocabRef})."\n";
    
	
	#ouput the datasets at this threshold
	print "   Outputting DataSet\n";
	&_outputDataSet($currentVocabRef, \%knownPairs, \%futurePairs, $goldOutFile."_threshold$threshold", $knownOutFile."_threshold$threshold", $pairsOutFile."_threshold$threshold", $truthValuesOutFile."_threshold$threshold", $vocabOutFile."_threshold$threshold");
	
	#increment the threshold and repeat
	$threshold++
    }

    print "Done!\n";
}


#creates gold, known, and false sets from the current vocabulary
# using the orignal read in known and future values
sub _createSets {
    my $vocabRef = shift;
    my $knownRef = shift;
    my $futureRef = shift;

    #create a set of gold standard term pairs (future - known) 
    # and set of known term pairs, and a set of false term pairs
    # and make order not matter (I know, making order not matter
    # is repetitive, but we need to me sure that it doesn't)
    my %goldPairs = ();
    my %knownPairs = ();
    foreach my $subject (keys %{$vocabRef}) {
	foreach my $object (keys %{$vocabRef}) {
	    if (defined ${$knownRef}{"$subject,$object"}
		|| defined ${$knownRef}{"$object,$subject"}) {
		$knownPairs{"$subject,$object"}=1;
		$knownPairs{"$object,$subject"}=1;
	    }
	    elsif (defined ${$futureRef}{"$subject,$object"} ||
		   defined ${$futureRef}{"$object,$subject"}) {
		$goldPairs{"$subject,$object"}=1;
		$goldPairs{"$object,$subject"}=1;
	    }
	    #else its a false pair
	}
    }

    return \%goldPairs, \%knownPairs;
}



#outputs the dataset based on all possible pairs of the
# current vocabulary and the originally read in 
# future and known pairs
sub _outputDataSet {
    #grab data
    my $vocabularyRef = shift;
    my $knownPairsRef = shift;
    my $futurePairsRef = shift;
    #grab filenames
    my $goldOutFile = shift;
    my $knownOutFile = shift;
    my $pairsOutFile = shift;
    my $truthValuesOutFile = shift;
    my $vocabOutFile = shift;

    #get the gold, known, and false in vocabulary
    # Note, false isn't used for anything except checking errors
    my ($goldPairsRef, $inVocabKnownPairsRef) = 
	&_createSets($vocabularyRef, $knownPairsRef, $futurePairsRef);
    
    #check the sets for errors
    &_checkForErrors($goldPairsRef, $inVocabKnownPairsRef,
		     $knownPairsRef, $futurePairsRef);

    #output vocabulary
    open OUT, ">$vocabOutFile" or die ("ERROR: unable to open vocabOutFile: $vocabOutFile\n");
    foreach my $term (keys %{$vocabularyRef}) {
	print OUT "$term\n";
    }
    close OUT;

    #output gold samples only
    open OUT, ">$goldOutFile" 
	or die ("ERROR: unable to open goldOutFile: $goldOutFile\n");
    foreach my $pair (keys %{$goldPairsRef}) {
	my ($subject, $object) = split(/,/,$pair);
	print OUT "$subject<>$object\n";
    }
    close OUT;
    
    #output known samples only
    open OUT, ">$knownOutFile" 
	or die ("ERROR: unable to open knownOutFile: $knownOutFile\n"); 
    foreach my $pair (keys %{$inVocabKnownPairsRef}) {
	my ($subject, $object) = split(/,/,$pair);
	print OUT "$subject<>$object\n";
    }
    close OUT;
    
    #output all pairs with true/false values (except known pairs)
    # and output a file of just pairs, no truth values
    open OUT_TRUTH, ">$truthValuesOutFile" 
	or die ("ERROR: unable to open truthValuesOutFile: $truthValuesOutFile\n");    
    open OUT_PAIRS, ">$pairsOutFile"
	or die ("ERROR: unable to open pairsOutFile: $pairsOutFile\n");
    foreach my $subject (sort keys %{$vocabularyRef}) {
	foreach my $object (sort keys %{$vocabularyRef}) {
	    if (!defined ${$knownPairsRef}{"$subject,$object"} 
		&& !defined ${$knownPairsRef}{"$object,$subject"}) {
		my $truthVal = 0;
		if (defined ${$goldPairsRef}{"$subject,$object"}
		    || defined ${$goldPairsRef}{"$object,$subject"}) {
		    $truthVal = 1;
		}
		print OUT_TRUTH "$truthVal<>$subject<>$object\n";
		print OUT_PAIRS "$subject<>$object\n";
	    }
	}
    }
    close OUT_TRUTH;
    close OUT_PAIRS;
}


#Check for errors
sub _checkForErrors {
    my $goldPairsRef = shift;
    my $knownPairsRef = shift;
    my $originalKnownPairsRef = shift;
    my $originalFuturePairsRef = shift;

    #Check the dataset, again this is overkill, but we have to be correct
    foreach my $pair (keys %{$knownPairsRef}) {
	my ($subject, $object) = split(/,/,$pair);
	if (defined ${$goldPairsRef}{"$subject,$object"} 
	    || defined ${$goldPairsRef}{"$object,$subject"}) {
	    print "ERROR: $pair in known and gold\n";
	}
	if (!(defined ${$originalKnownPairsRef}{"$subject,$object"}
	      || defined ${$originalKnownPairsRef}{"object,$subject"})) {
	    print "ERROR: $pair in current known, but not original known\n";
	}
	if (!defined ${$knownPairsRef}{"$object,$subject"}){
	    print "ERROR: order matters for $pair in false\n";
	}
    }
    foreach my $pair (keys %{$goldPairsRef}) {
	my ($subject, $object) = split(/,/,$pair);
        if (defined ${$knownPairsRef}{"$subject,$object"} 
	    || defined ${$knownPairsRef}{"$object,$subject"}) {
	    print "ERROR: $pair in gold and known\n";
	}
	if (!(defined ${$originalFuturePairsRef}{"$subject,$object"}
	      || defined ${$originalFuturePairsRef}{"object,$subject"})) {
	    print "ERROR: $pair in current gold, but not original future\n";
	}
	if (!defined ${$goldPairsRef}{"$object,$subject"}){
	    print "ERROR: order matters for $pair in gold\n";
	}
    }
}




#############################################################
######## THRESHOLDING
#############################################################
sub _thresholdDataset {
    #grab inputs
    my $vocabRef = shift;
    my $futurePairsRef = shift;
    my $knownPairsRef = shift;
    my $threshold = shift;

    #maybe use different thresholds in future work
    my $minNumObjectsThreshold = $threshold;
    my $minNumSubjectsThreshold = $threshold;


    #generate a set of gold predicates
    my ($goldPairsRef, $inVocabKnownPairsRef) 
	= &_createSets($vocabRef, $knownPairsRef, $futurePairsRef);

    #remove non-subjects and apply threshld
    # This may need to be done iteratively because applying the
    # threshold may necessitate removing objects, then re-applying
    # the threshold and so on
    my $done = 0;
    while (!$done) {
	$goldPairsRef = &_applyThreshold($goldPairsRef, $minNumSubjectsThreshold, $minNumObjectsThreshold);
	my ($objectsPerSubject, $subjectsPerObject) = &_getCuisPerCui($goldPairsRef);
	print "         Num goldPairs = ".(scalar keys %{$goldPairsRef})."\n";

        #Check if done (threshold does not need to be re-applied)
	$done = 1;
	foreach my $subject (keys %{$objectsPerSubject}) {
	    my $numObjects = ${$objectsPerSubject}{$subject};
	    if ($numObjects <= $minNumObjectsThreshold) {
		$done = 0;
		last;
	    }
	}
	if ($done) {
	    foreach my $object (keys %{$subjectsPerObject}) {
		my $numSubjects = ${$subjectsPerObject}{$object};
		if ($numSubjects <= $minNumSubjectsThreshold) {
		    $done = 0;
		    last;
		}
	    }
	}
    }

    #Threshold Complete, get and return the thresholded vocabulary
    my %vocabulary = ();
    foreach my $pair (keys %{$goldPairsRef}) {
	my ($subject,$object) = split(/,/,$pair);
	$vocabulary{$subject}=1;
	$vocabulary{$object}=1;
    }
    return \%vocabulary;
}

#Applies a minimum subjects per object and minimum objects
# per subject threshold to the predicates hash
sub _applyThreshold {
    my $goldPairsRef = shift;
    my $minNumSubjectsThreshold = shift;
    my $minNumObjectsThreshold = shift;

    #get lists of cuis per subject/object
    my ($objectsPerSubject, $subjectsPerObject) = &_getCuisPerCui($goldPairsRef);

    #threshold the matrix
    foreach my $pair (keys %{$goldPairsRef}) {
	#grab the values
	my @vals = split(/,/,$pair);
	my $subject = $vals[0];
	my $object = $vals[1];

	#record the subject and object
	if (${$objectsPerSubject}{$subject} <= $minNumObjectsThreshold
	    || ${$subjectsPerObject}{$object} <= $minNumSubjectsThreshold) {
	    delete ${$goldPairsRef}{$pair};
	}
    }
    
    return $goldPairsRef;
}

#gets two hashes, which list the cuis that are objects
# for each subject (objectsPerSubject), and another that
# lists the subjects per object. Both are of the form:
# ${$cuisPer{$cui}}{$cui} = 1
sub _getCuisPerCui {
    my $goldPairsRef = shift;

    #find the object lists and subject lists for each 
    # subject and object in the matrix
    my %objectsPerSubject = ();
    my %subjectsPerObject = ();
    foreach my $pair (keys %{$goldPairsRef}) {
	#grab the values
	my @vals = split(/,/,$pair);
	my $subject = $vals[0];
	my $object = $vals[1];

	#record the subject and object
	$objectsPerSubject{$subject} ++;
	$subjectsPerObject{$object} ++;
    }

    return (\%objectsPerSubject, \%subjectsPerObject);
}
