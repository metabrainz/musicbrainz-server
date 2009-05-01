use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Data::Utils';

my $date = MusicBrainz::Server::Data::Utils::partial_date_from_row(
    { a_year => 2008, a_month => 1, a_day => 2 }, 'a_');

is ( $date->year, 2008 );
is ( $date->month, 1 );
is ( $date->day, 2 );
