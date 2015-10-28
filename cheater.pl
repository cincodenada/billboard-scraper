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
	s/<\/?br ?\/?>/ /g;
	s/\{\{.*?\}\}//g;
	s/\[\[([^\]]*?)\|([^\]]*?)\]\]/\2/g;
	s/\[\[(.*?)\]\]/\1/g;
	s/\|\|[^\[\|]+?\|([^\|])/\|\|\1/g;

	# Skip title rows, we don't care
	if(/^\|\+/) { next; }

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
	} elsif($in_table and /^[\|\!](.*(?:[\|\!]{2,2}.*)+)$/) {
		debug "Found single-row row\n";
		@{$currow} = split(/[\|\!]{2,2}/, $1);
	} elsif($in_table and /^[\|\!](?:.*\|)?(.*)$/) {
		# Regular col
		debug "Found individual col\n";
		push(@{$currow}, $1);
	}
}

%persong = {};
%songdata = {};
%headers = {};
for $key (keys %rows) {
	$chart = $key;
	$chart =~ s/^List of //i;
	$chart =~ s/^Number[ \-]one //i;
	if($chart =~ /of (\d+)/) {
		$year = $1;
	}

	@header = @{shift(@{$rows{$key}})};
	$firstheaders{lc(join('|',@header))}++;
	$first_is_date = ($header[0] =~ /date/i);
	$mincols = $first_is_date ? 3 : 2;
	for $row (@{$rows{$key}}) {
		if(scalar(@{$row}) >= $mincols) {
			my ($date, $song, $artist) = @{$row};
			$songdata{$artist.$song} = [$song, $artist];
			unless($persong{$artist.$song}) {
				$persong{$artist.$song} = [];
			}
			push(@{$persong{$artist.$song}}, sprintf("%s, %s %s", $chart, $date, $year));
		}
	}
}

print Dumper %firstheaders;

for $key (keys %persong) {
	my ($song, $artist) = @{$songdata{$key}};
	printf("%s - %s (%s)\n", $song, $artist, join('; ', @{$persong{$key}}));
}
#print Dumper %rows;
