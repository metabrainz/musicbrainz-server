use strict;
use warnings;
use Test::More;
use MusicBrainz::Server::Entity::PartialDate;

my $date;
my $partial;

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

$partial = { 'year' => 1476, 'month' => 12 };
$date = MusicBrainz::Server::Entity::PartialDate->new( $partial );
is ($date->format, "1476-12");

$partial = { 'year' => 1476, 'month' => 12, 'day' => undef };
$date = MusicBrainz::Server::Entity::PartialDate->new( $partial );
is ($date->format, "1476-12");

done_testing;

1;
