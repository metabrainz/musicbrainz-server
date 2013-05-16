package t::MusicBrainz::Server::Entity::PartialDate;
use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::PartialDate' => 'Date';

test all => sub {

my $date;
my $partial;

$date = Date->new();
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
$date = Date->new( $partial );
is ($date->format, "1476-12");

$partial = { 'year' => 1476, 'month' => 12, 'day' => undef };
$date = Date->new( $partial );
is ($date->format, "1476-12");

$date = Date->new( "1476" );
is ($date->format, "1476");

$date = Date->new( "1476-12" );
is ($date->format, "1476-12");

$date = Date->new( "1476-12-1" );
is ($date->format, "1476-12-01");

$date = Date->new( "1476-12-01" );
is ($date->format, "1476-12-01");

$date = Date->new( month => 04, day => 01 );
is ($date->format, "????-04-01");

$date = Date->new( year => 1999, day => 01 );
is ($date->format, "1999-??-01");

$date = Date->new( day => 01 );
is ($date->format, "????-??-01");

my ($a, $b);

$a = Date->new( year => 2000 );
$b = Date->new( year => 2001 );
ok($a < $b);
ok($b > $a);

$a = Date->new( year => 2000, month => 1 );
$b = Date->new( year => 2000, month => 5 );
ok($a < $b);
ok($b > $a);

$a = Date->new( year => 2000, month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 20 );
ok($a < $b);
ok($b > $a);

$a = Date->new( year => 2000, month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 1 );
ok(!($a < $b));
ok(!($b < $a));

$a = Date->new( month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 1 );
ok($a < $b);
ok($b > $a);

$a = Date->new( month => 1, day => 1 );
$b = Date->new( month => 1, day => 1 );
ok(!($a < $b));
ok(!($b < $a));

ok(Date->new('')->is_empty);

};

1;
