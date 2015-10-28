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
	$_ = decode_entities($_);
	s/<ref.*?>.*?<\/ref>//g;
	s/<ref.*?\/>//g;
	s/<!--.*?-->//g;
	s/<\/?br ?\/?>//g;
	s/\{\{.*?\}\}//g;
	s/\[\[(.*?)\|(.*?)\]\]/\2/g;
	s/\[\[(.*?)\]\]/\1/g;

	if(/title>(.*)<\/title/) {
		$curtitle = $1;
		debug "Found title: $curtitle\n";
	} elsif(/^\|\-/) {
		# End of a row
		$filteredrow = [];
		foreach $val (@{$currow}) {
			$val =~ s/^\s+|\s+$//g;
			if($val ne '') {
				push(@{$filteredrow}, $val);
			}
		}
		if(scalar(@{$filteredrow}) > 0) {
			debug "Finishing row!\n";
			push(@{$currows}, $filteredrow);
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
		@{$currow} = split('||', $1);
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
		if(scalar(@{$row}) > 2) {
			print join("\t",@{$row}) . "\n";
		}
	}
}
#print Dumper %rows;
