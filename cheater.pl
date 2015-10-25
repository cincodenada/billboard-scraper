use Data::Dumper;
use HTML::Entities;
my $curheader;
my $currow;
my $currows;
my %rows;
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
		$rows{$curtitle} = $currows;
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

for $chart (keys %rows) {
	print "$chart\n";
	$first_row = shift(@{$rows{$chart}});
	print join("\t",@{$first_row}) . "\n";
	for $row (@{$rows{$chart}}) {
		@currow = map {s/([\[\]])//g; $_} @{$row};
		@currow = map {decode_entities($_)} @currow;
		print join("\t",@currow) . "\n";
	}
}
print Dumper %rows;
