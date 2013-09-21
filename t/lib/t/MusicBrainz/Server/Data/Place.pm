package t::MusicBrainz::Server::Data::Place;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;
use Test::Deep qw( cmp_set );

use MusicBrainz::Server::Data::Place;

use DateTime;
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Search;
use MusicBrainz::Server::Test;
use Sql;

with 't::Edit';
with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_place');

my $sql = $test->c->sql;
$sql->begin;

my $place_data = MusicBrainz::Server::Data::Place->new(c => $test->c);
does_ok($place_data, 'MusicBrainz::Server::Data::Role::Editable');

# A place with the minimal set of required attributes
my $place = $place_data->get_by_id(1);
is ( $place->id, 1 );
is ( $place->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $place->name, "Test Place" );
is ( $place->address, "An Address" );
is ( $place->coordinates->latitude, 0.11 );
is ( $place->coordinates->longitude, 0.1 );
is ( $place->begin_date->year, 2008 );
is ( $place->begin_date->month, 1 );
is ( $place->begin_date->day, 2 );
is ( $place->end_date->year, 2009 );
is ( $place->end_date->month, 3 );
is ( $place->end_date->day, 4 );
is ( $place->edits_pending, 0 );
is ( $place->comment, 'Yet Another Test Place' );

$place = $place_data->get_by_id(2);
is ( $place->id, 2 );
is ( $place->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $place->name, "Minimal Place" );
is ( $place->address, "" );
is ( $place->coordinates->latitude, undef );
is ( $place->coordinates->longitude, undef );
is ( $place->begin_date->year, undef );
is ( $place->begin_date->month, undef );
is ( $place->begin_date->day, undef );
is ( $place->end_date->year, undef );
is ( $place->end_date->month, undef );
is ( $place->end_date->day, undef );
is ( $place->edits_pending, 0 );
is ( $place->comment, '' );

# Fetching annotations
my $annotation = $place_data->annotation->get_latest(1);
like ( $annotation->text, qr/Test annotation 1/ );


# Merging annotations
$place_data->annotation->merge(2, 1);
$annotation = $place_data->annotation->get_latest(1);
ok(!defined $annotation);

$annotation = $place_data->annotation->get_latest(2);
like ( $annotation->text, qr/Test annotation 2/ );

like($annotation->text, qr/Test annotation 1/, 'has annotation 1');
like($annotation->text, qr/Test annotation 2/, 'has annotation 2');

# Deleting annotations
$place_data->annotation->delete(2);
$annotation = $place_data->annotation->get_latest(2);
ok(!defined $annotation);


$sql->commit;

};

1;
