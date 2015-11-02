#!/usr/bin/perl
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
	if(/\{\{Dts\|format\=\w+\|(\d+)\|(\d+)\|(\d+)\}\}/) {
		($year, $month, $day) = ($1, $2, $3);
		s/\{\{Dts.*?\}\}/$month-$day-$year/;
	}
	if(/\{\{sortname\|(?<fname>.*)\|(?<lname>.*)(?:\|(?<dname>.*))?\}\}/) {
		$name = (exists $+{dname}) ? $+{dname} : "$+{fname} $+{lname}";
		s/\{\{sortname.*?\}\}/$name/;
	}
	s/[↓↑]//g;
	s/<ref.*?>.*?<\/ref>//g;
	s/<small>\s+(.*?)(?:<\/small>)?/\1/g;
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
		}
		$currow = [];
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
%linkmap = {};
for $key (keys %rows) {
	$chart = $key;
	$chart =~ s/^List of //i;
	$chart =~ s/^Number[ \-]one //i;
	$chart = ucfirst($chart);
	$linkmap{$chart} = $key;
	if($chart =~ /of (\d+)/) {
		$year = $1;
	}

	@header = @{shift(@{$rows{$key}})};

	# Determine columns
	%colpos = ();
	$colnum = 0;
	$mincols = 0;
	for $col (@header) {
		if($col =~ /date|reached/i and !exists($colpos{date})) {
			$colpos{date} = $colnum;
			if($colnum > $mincols) { $mincols = $colnum; }
		} elsif($col =~ /song|title|single/i and !exists($colpos{song})) {
			$colpos{song} = $colnum;
			if($colnum > $mincols) { $mincols = $colnum; }
		} elsif($col =~ /artist/i and !exists($colpos{artist})) {
			$colpos{artist} = $colnum;
			if($colnum > $mincols) { $mincols = $colnum; }
		}
		$colnum++;
	}

	my %revcols = reverse %colpos;
	debug join (', ', map { "$_: $revcols{$_}" } sort keys %revcols) . ' - ';
	debug join (', ', @header) . "\n";

	if(exists($colpos{artist}) and exists($colpos{song})) {
		for $row (@{$rows{$key}}) {
			@currow = @{$row};
			# Update year from decade-type charts
			if(scalar(@currow) == 1) {
				if($currow[0] =~ /\d{4,4}/) { $year = $1; }
			} elsif(scalar(@currow) > $mincols) {
				$song = $currow[$colpos{song}];
				$artist = $currow[$colpos{artist}];
				$date = exists($colpos{date}) ? $currow[$colpos{date}] : 'N/A';
				unless($date =~ /\d{4,4}/) { $date .= ", $year"; }

				$songdata{$artist.$song} = [$song, $artist];
				unless($persong{$artist.$song}) {
					$persong{$artist.$song} = [];
				}
				push(@{$persong{$artist.$song}}, sprintf("%s, %s", $chart, $date));
			}
		}
	}
}

for $key (keys %persong) {
	my ($song, $artist) = @{$songdata{$key}};
	printf("%s\t%s\t%s\n", $artist, $song, join('; ', @{$persong{$key}}));
}

open(my $fh, '>', 'linkmap.tsv');
for $text(keys %linkmap) {
	printf $fh "%s\t%s\n", $text, $linkmap{$text};
}
close($fh);
#print Dumper %rows;
