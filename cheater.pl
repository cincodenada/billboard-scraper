use Data::Dumper;
my $curheader;
my $currow;
my $currows;
my %tables;
my $curtitle;

sub debug {
	if(0) {
		print @_;
	}
}

while(<>) {
	if(/title>(.*)<\/title/) {
		$curtitle = $1;
		debug "Found title: $curtitle\n";
	} elsif(/^\|\-/) {
		# End of a row
		if(scalar(@{$currow}) > 0) {
			debug "Finishing row!\n";
			push(@{$currows}, $currow);
			$currow = [];
		}
	} elsif(/^\|\}/) {
		# End of a table
		debug "Finishing table!\n";
		$tables{$curtitle} = {
			header => $curheader,
			rows => $currows
		};
		$currows = [];
		$curheader = [];
	} elsif(/^\|(.*(?:\|\|.*)+)$/) {
		debug "Found single-row row\n";
		#@{$currow} = split('||', $1);
	} elsif(/^[\|\!](?:.*\|)?(.*)$/) {
		# Regular col
		debug "Found individual col\n";
		push(@{$currow}, $1);
	}
}

print Dumper %tables;
