#reads in a gold file and outputs stats on it
# Gold file is a tab seperated list of cui pairs
# and their score (future relatedness), specifically:
# [0,1]<>CUI<>CUI\n
#
#Cooccurrence file is of the form:
# CUI\tCUI\tnumCooccurrences
#
use strict;
use warnings;

=comment
#user input
my $goldFile = 'newOut/all_gold';
my $cooccurrenceFile = 'newOut/1975_2015_window8';
&getStats($goldFile, $cooccurrenceFile);
=cut

print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 6   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
my $goldFile = 'results/truth_threshold6';
my $cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 5   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold5';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 4   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold4';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 3   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold3';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 2   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold2';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold1';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);
print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
print "XXXXXXXXXXXXXXXXXXXXXXXXXXX    THRESHOLD 0   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
$goldFile = 'results/truth_threshold0';
$cooccurrenceFile = 'data/1800_2009_window8';
&getStats($goldFile, $cooccurrenceFile);








############################################
#    Begin Code
#############################################
sub getStats {
    my $goldFile = shift;
    my $cooccurrenceFile = shift;
    my $problemCuiOut = shift;

    #########################################
    #read the in file and collect info 
    open IN, $goldFile or die ("ERROR: unable to open goldFile: $goldFile\n");
    my %numTrueForSubject = ();
    my %numFalseForSubject = ();
    my %numTrueForObject = ();
    my %numFalseForObject = ();
    my %goldScores = ();
    my %subjects = ();
    my %objects = ();
    while (my $line = <IN>) {
	#grab values
        #line in $cui<>$cui<>$score
	chomp $line;
	my ($score, $cui1, $cui2) = split (/\<\>/,$line);
	
	#increment true/false counts for cui, if score > 0 its
	# a cui pair is a future discovery (true)
	if ($score > 0) {
	    $numTrueForSubject{$cui1}++;
	    $numTrueForObject{$cui2}++;
	}
	else {
	    $numFalseForSubject{$cui1}++;
	    $numFalseForObject{$cui2}++;
	}

	#gather other info
	$goldScores{"$cui1,$cui2"} = $score;
	$subjects{$cui1} = 1;
	$objects{$cui2} = 1;
    }











    ###################################
    #answer questions
    ###### num true for subject questions
    my $numTrue = 0;
    my $maxTrue = 0;
    my $minTrue = 999999;
    my $minTrueSubject = '';
    my $maxTrueSubject = '';
    foreach my $subject (keys %numTrueForSubject) {
	$numTrue += $numTrueForSubject{$subject};
	if ($numTrueForSubject{$subject} > $maxTrue) {
	    $maxTrue = $numTrueForSubject{$subject};
	    $maxTrueSubject = $subject;
	}
	if ($numTrueForSubject{$subject} < $minTrue) {
	    $minTrue = $numTrueForSubject{$subject};
	    $minTrueSubject = $subject;
	    
	}
    }
    my $averageTruePerSubject = -1;
    if (scalar keys %numTrueForSubject > 0) {
	$averageTruePerSubject = $numTrue/(scalar keys %numTrueForSubject);
    }
   

    ###### num false for subject questions
    my $numFalse = 0;
    foreach my $subject (keys %numFalseForSubject) {
	$numFalse += $numFalseForSubject{$subject}
    }
    my $averageFalsePerSubject = -1;
    if (scalar keys %numFalseForSubject > 0) {
	$averageFalsePerSubject = $numFalse/(scalar keys %numFalseForSubject);
    }

    #calculate average ratio
    my $averageRatio = 0;
    foreach my $subject (keys %numTrueForSubject) {
	$averageRatio += ($numTrueForSubject{$subject} / $numFalseForSubject{$subject});
    }
    if (scalar keys %numTrueForSubject > 0) {
	$averageRatio /= (scalar keys %numTrueForSubject);
    }

    print "number of subjects = ".(scalar keys %subjects)."\n";
    print "number of unique objects = ".(scalar keys %objects)."\n";
    print "\n";
    print "total number true pairs = $numTrue\n";
    print "total number of false pairs = $numFalse\n";
    print "total ratio true/false = ".($numTrue/$numFalse)."\n";
    print "\n";


   ##### find min and max scores for subjects
    my $lowestScore = 999999;
    my $highestScore = 0;
    my $highestSubject = '';
    my $lowestSubject = '';
    my $highestObject = '';
    my $lowestObject = '';
    foreach my $pair (keys %goldScores) {
	my ($subject, $object) = split (/,/,$pair);
	if ($goldScores{$pair} > $highestScore) {
	    $highestScore = $goldScores{$pair};
	    $highestSubject = $subject;
	    $highestObject = $object;
	}
	if ($goldScores{$pair} < $lowestScore && $goldScores{$pair} > 0) {
	    $lowestScore = $goldScores{$pair};
	    $lowestSubject = $subject;
	    $lowestObject = $object;
	}
    }

    print "The highest score is between $highestSubject and $highestObject at $highestScore\n";
    print "The lowest score is between $lowestSubject and $lowestObject at $lowestScore\n";
    print "\n\n";


    print "average true per subject = $averageTruePerSubject\n";
    print "average false per subject = $averageFalsePerSubject\n";
    print "average ratio per subject = $averageRatio";
    print "\n";

    print "$maxTrueSubject is the subject with the most true objects, at $maxTrue\n";
    print "$minTrueSubject is the subject with the least true objects, at $minTrue\n";
    print "\n\n";











    ###### num true for object questions
    $numTrue = 0;
    $maxTrue = 0;
    $minTrue = 999999;
    my $minTrueObject = '';
    my $maxTrueObject = '';
    foreach my $object (keys %numTrueForObject) {
	$numTrue += $numTrueForObject{$object};
	if ($numTrueForObject{$object} > $maxTrue) {
	    $maxTrue = $numTrueForObject{$object};
	    $maxTrueObject = $object;
	}
	if ($numTrueForObject{$object} < $minTrue) {
	    $minTrue = $numTrueForObject{$object};
	    $minTrueObject = $object;
	    
	}
    }
    my $averageTruePerObject = -1;
    if ((scalar keys %numTrueForObject) > 0) {
	$averageTruePerObject = $numTrue/(scalar keys %numTrueForObject);
    }

    ###### num false for object questions
    $numFalse = 0;
    foreach my $object (keys %numFalseForObject) {
	$numFalse += $numFalseForObject{$object}
    }
    my $averageFalsePerObject = $numFalse/(scalar keys %numFalseForObject);

    #calculate average ratio
    $averageRatio = 0;
    foreach my $object (keys %numTrueForObject) {
	$averageRatio += ($numTrueForObject{$object} / $numFalseForObject{$object});
    }
    if ((scalar keys %numTrueForObject) > 0) {
	$averageRatio /= (scalar keys %numTrueForObject);
    }


    print "average true per object = $averageTruePerObject\n";
    print "average false per object = $averageFalsePerObject\n";
    print "average ratio per object = $averageRatio";
    print "\n";

    print "$maxTrueObject is the object with the most true subjects, at $maxTrue\n";
    print "$minTrueObject is the object with the least true subjects, at $minTrue\n";
    print "\n\n";



































    ###### do subjects and objects overlap with different scores?
    my $numSubjectObjectOverlaps = 0;
    foreach my $subject (keys %subjects) {
	#check if the subject is also an object
	if (defined $objects{$subject}) {
	    $numSubjectObjectOverlaps++;
	}
    }
    
    #check if scores and true falses mismatch
    my $numScoreMismatches = 0;
    my $numTrueFalseMismatches = 0;
    foreach my $subject (keys %subjects) {
	for my $object (keys %objects) {
	    if (defined $goldScores{"$subject,$object"} 
		&& defined $goldScores{"$object,$subject"}) {
		#there is an overlap of scores, check it out
		if ($goldScores{"$subject,$object"} ne $goldScores{"$object,$subject"}) {
		    #there is a score mismatch, increment that and check if its a true false mismatch
		    $numScoreMismatches++;
		    print "$subject, $object -- ".$goldScores{"$subject,$object"}.", ".$goldScores{"$object,$subject"}."\n";
		    if (($goldScores{"$subject,$object"} == 0 && $goldScores{"$object,$subject"} != 0)
			|| ($goldScores{"$subject,$object"} != 0 && $goldScores{"$object,$subject"} == 0)) {
			#one is true and the other is false (this is bad, increment)
			$numTrueFalseMismatches++;
		    }
		}
	    }
	}
    }

    print "There are $numSubjectObjectOverlaps subjects that are also objects\n";
    print "Scores of subj-obj and obj-subj are different $numScoreMismatches times\n"; 
    print "The truth value of subj-obj and obj-subj is true $numTrueFalseMismatches times\n";
    print "\n\n";
    







    ###########################################
    # Get Cooccurrence info
    open IN, $cooccurrenceFile or die ("ERROR: unable to open cooccurrence file\n");
#    my $trueOccurrences = 0;
#    my $falseOccurrences = 0;
    my %occurrences = ();
    while (my $line = <IN>) {
	my ($subject, $object, $count) = split(/\t/,$line);

	#count occurrences regardless of posistion
	if (defined $subjects{$subject} || defined $objects{$subject}) {
	    $occurrences{$subject} += $count;

	    #increment true and false occurrence rates
	    #its a true pair if score > 0
#	    if ($goldScores{"$subject,$object"} > 0) {
#		$trueOccurrences++;
#	    }
	    #else, it is a false pair
#	    else {
#
#	    }
	}
	if (defined $objects{$subject} || defined $objects{$object}) {
	    #make sure they are not double counted
	    if ($subject ne $object) {
		$occurrences{$object} += $count;
	    }
	}
    }
    close IN;

    #calculate stats from the cooccurrence info and find cuis that are not in MEDLINE
    my $numSubjectOccurrences = 0;
    foreach my $subject (keys %subjects) {
	if (!defined $occurrences{$subject}) {
	    $occurrences{$subject} = 0;
	    print "$subject - NOT IN MEDLINE\n";
	}
       	$numSubjectOccurrences += $occurrences{$subject};
    }
    my $meanOccurrencesPerSubject = $numSubjectOccurrences / (scalar keys %subjects);

    my $numObjectOccurrences = 0;
    foreach my $object (keys %objects) {
	if (!defined $occurrences{$object}) {
	    $occurrences{$object} = 0;
	    print "$object - NOT IN MEDLINE\n";
	}
       	$numObjectOccurrences += $occurrences{$object};
    }
    my $meanOccurrencesPerObject = $numObjectOccurrences / (scalar keys %objects);



    ###################################################
    # Print the stats
    print "Total subject occurrence count = $numSubjectOccurrences\n";
    print "Total object occurrence count = $numObjectOccurrences\n";
    print "Average occurrences per subject = $meanOccurrencesPerSubject\n";
    print "Average occurrences per object = $meanOccurrencesPerObject\n";

    
}
