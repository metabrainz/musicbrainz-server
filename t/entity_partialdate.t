use strict;
use warnings;
use Test::More tests => 7;
use MusicBrainz::Server::Entity::PartialDate;

my $date;

$date = MusicBrainz::Server::Entity::PartialDate->new();
ok( $date->is_empty );
is( $date->format, "" );

$date->year(2009);
ok( not $date->is_empty );
is( $date->year, 2009 );

is( $date->format, "2009" );
$date->month(4);
is( $date->format, "2009-04" );
$date->day(18);
is( $date->format, "2009-04-18" );
