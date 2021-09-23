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
is( $date->format, '' );

$date = Date->new( year => 0 );
ok( not $date->is_empty );

$date = Date->new( year => 2009 );
ok( not $date->is_empty );
is( $date->year, 2009 );
is( $date->format, '2009' );

$date = Date->new( year => 2009, month => 4 );
is( $date->format, '2009-04' );

$date = Date->new( year => 2009, month => 4, day => 18 );
is( $date->format, '2009-04-18' );

$partial = { 'year' => 1476, 'month' => 12 };
$date = Date->new( $partial );
is ($date->format, '1476-12');

$partial = { 'year' => 1476, 'month' => 12, 'day' => undef };
$date = Date->new( $partial );
is ($date->format, '1476-12');

$date = Date->new( '1476' );
is ($date->format, '1476');

$date = Date->new( '1476-12' );
is ($date->format, '1476-12');

$date = Date->new( '1476-12-1' );
is ($date->format, '1476-12-01');

$date = Date->new( '1476-12-01' );
is ($date->format, '1476-12-01');

$date = Date->new( month => 4, day => 1 );
is ($date->format, '????-04-01');

$date = Date->new( year => 1999, day => 1 );
is ($date->format, '1999-??-01');

$date = Date->new( day => 1 );
is ($date->format, '????-??-01');

$date = Date->new( year => 0 );
is ($date->format, '0000');

$date = Date->new( month => 1 );
is ($date->format, '????-01');

$date = Date->new( year => -1, month => 1, day => 1 );
is ($date->format, '-001-01-01');

my ($a, $b);

$a = Date->new();
$b = Date->new();
ok(!($a < $b), 'empty dates sort the same');
ok(!($b > $a), 'empty dates sort the same');

$a = Date->new( year => 1995 );
$b = Date->new( year => 1995 );
ok(!($a < $b), 'given only year, same year sorts the same');
ok(!($b > $a), 'given only year, same year sorts the same');

$a = Date->new( year => -1995 );
$b = Date->new( year => -1995 );
ok(!($a < $b), 'given only negative year, same year sorts the same');
ok(!($b > $a), 'given only negative year, same year sorts the same');

$a = Date->new( year => 2000 );
$b = Date->new( year => 2001 );
ok($a < $b, 'given only year, earlier sorts first');
ok($b > $a, 'given only year, later sorts second');

$a = Date->new( year => 2000, month => 1 );
$b = Date->new( year => 2000, month => 5 );
ok($a < $b, 'given year and month, earlier sorts first');
ok($b > $a, 'given year and month, later sorts second');

$a = Date->new( year => 2000, month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 20 );
ok($a < $b, 'given full date, earlier sorts first');
ok($b > $a, 'given full date, later sorts second');

$a = Date->new( year => 2000, month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 1 );
ok(!($a < $b), 'given full date, same date sorts the same');
ok(!($b < $a), 'given full date, same date sorts the same');

$a = Date->new( month => 1, day => 1 );
$b = Date->new( year => 2000, month => 1, day => 1 );
ok($a < $b, 'missing year date sorts before full date');
ok($b > $a, 'full date sorts after missing year date');

$a = Date->new( month => 1, day => 1 );
$b = Date->new( month => 1, day => 1 );
ok(!($a < $b), 'missing year date, otherwise equal, sorts the same');
ok(!($b < $a), 'missing year date, otherwise equal, sorts the same');

$a = Date->new( year => 0 );
$b = Date->new( year => 2000 );
ok($a < $b, 'year 0 sorts before 2000');
ok($b > $a, 'year 2000 sorts after 0');

$a = Date->new( year => 0 );
$b = Date->new( year => -1 );
ok($a > $b);
ok($b < $a);

$a = Date->new( year => -1, month => 1 );
$b = Date->new( year => -1, month => 2 );

ok($b > $a);
ok($a < $b);

$a = Date->new( year => 1994, month => 2, day => 29 );
$b = Date->new( year => 1994 );

ok($a < $b, 'invalid dates sort before valid ones');
ok($b > $a, 'valid dates sort after invalid ones');

ok(Date->new('')->is_empty);

};

1;
