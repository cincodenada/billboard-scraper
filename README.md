Wikipedia Song Chart Parser (cheater version)
---------------------------------------------

This script takes an XML dump of pages with tables of instances
of songs on charts from Wikipedia, and outputs a TSV summary
of those songs and what charts they appeared on.

It doesn't actually parse any XML, hence the "cheater" part.
It just skips through and mostly parses the raw Wikitext.

It was designed for and tested on Billboard charts, so YMMV
with anything else.

## Note about this repo

The history before Nov 1, 2015 is reconstructed from
git undo history.

I initially faked the history with UTC timestamps, and
then had to adjust them forward 7 hours and mark them
with the right timezone for accuracy.

For posterity's sake, here's the scary-lookin `filter-branch`
command I used to change the timezone of my git commits:

    git filter-branch -f --env-filter 'GIT_COMMITTER_DATE=`echo $GIT_COMMITTER_DATE | perl -ne '\''($time, $tz) = split(" "); print "@"; print substr($time,1)+60*60*7; print "-0700"'\''`; GIT_AUTHOR_DATE=$GIT_COMMITTER_DATE; export GIT_COMMITTER_DATE; export GIT_AUTHOR_DATE'
