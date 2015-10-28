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
	s/<small>(.*?)<\/small>/(\1)/g;
	s/<ref.*?\/>//g;
	s/<!--.*?-->//g;
	s/<\/?br ?\/?>//g;
	s/\{\{.*?\}\}//g;
	s/\[\[([^\]]*?)\|([^\]]*?)\]\]/\2/g;
	s/\[\[(.*?)\]\]/\1/g;
	s/\|\|[^\[\|]+?\|([^\|])/\|\|\1/g;

	if(/^{\|/) {
		$in_table = 1;
	}

	if(/title>(.*)<\/title/) {
		$curtitle = $1;
		debug "Found title: $curtitle\n";
	} elsif(/^\|\-/) {
		# End of a row
		$filteredrow = [];
		foreach $val (@{$currow}) {
			$val =~ s/^\s+|\s+$//g;
			$val =~ s/^"(.*)"$/\1/g;
			$val =~ s/^'+(.*)'+$/\1/g;
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
		$in_table = 0;
		$rows{$curtitle} = $currows;
		$currow = [];
		$currows = [];
		$curheader = [];
	} elsif($in_table and /^\|(.*(?:\|\|.*)+)$/) {
		debug "Found single-row row\n";
		@{$currow} = split(/\|\|/, $1);
	} elsif($in_table and /^[\|\!](?:.*\|)?(.*)$/) {
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
