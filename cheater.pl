use Data::Dumper;
my $curheader;
my $currow;
my $currows;
my %tables;
my $curtitle;
while(<>) {
	if(/title>(.*)<\/title/) {
		$curtitle = $1;
		#print "Found title: $curtitle\n";
	} elsif(/^\|\-/) {
		# End of a row
		if(scalar(@{$currow}) > 0) {
			#print "Finishing row!\n";
			push(@{$currows}, $currow);
			$currow = [];
		}
	} elsif(/^\!.*\|(.*)$/) {
		# Header col
		#print "Found header col\n";
		push(@{$curheader}, $1);
	} elsif(/^\|.*\|(.*)$/) {
		# Regular col
		#print "Found regular col\n";
		push(@{$currow}, $1);
	} elsif(/^\|\}/) {
		# End of a table
		#print "Finishing table!\n";
		$tables{$curtitle} = {
			header => $curheader,
			rows => $currows
		};
		$currows = [];
		$curheader = [];
	}
}

print Dumper %tables;
