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


# ---
# Creating new places
$place = $place_data->insert({
        name => 'New Place',
        comment => 'Place comment',
        address => 'An Address',
        area_id => 221,
        type_id => 1,
        begin_date => { year => 2000, month => 1, day => 2 },
        end_date => { year => 1999, month => 3, day => 4 },
        coordinates => { latitude => 0.1, longitude => 0.2 },
    });
isa_ok($place, 'MusicBrainz::Server::Entity::Place');
ok($place->id > 2);

$place = $place_data->get_by_id($place->id);
is($place->name, 'New Place');
is($place->address, 'An Address');
is($place->begin_date->year, 2000);
is($place->begin_date->month, 1);
is($place->begin_date->day, 2);
is($place->end_date->year, 1999);
is($place->end_date->month, 3);
is($place->end_date->day, 4);
is($place->type_id, 1);
is($place->area_id, 221);
is($place->comment, 'Place comment');
is($place->coordinates->latitude, 0.1);
is($place->coordinates->longitude, 0.2);
ok(defined $place->gid);

# ---
# Updating places
$place_data->update($place->id, {
        name => 'Updated Place',
        begin_date => { year => 1995, month => 4, day => 22 },
        end_date => { year => 1990, month => 6, day => 17 },
        type_id => undef,
        address => 'A Different Address',
        area_id => 222,
        comment => 'Updated comment',
    });


$place = $place_data->get_by_id($place->id);
is($place->name, 'Updated Place');
is($place->address, 'A Different Address');
is($place->begin_date->year, 1995);
is($place->begin_date->month, 4);
is($place->begin_date->day, 22);
is($place->end_date->year, 1990);
is($place->end_date->month, 6);
is($place->end_date->day, 17);
is($place->type_id, undef);
is($place->area_id, 222);
is($place->comment, 'Updated comment');

$place_data->update($place->id, {
        type_id => 2
    });
$place = $place_data->get_by_id($place->id);
is($place->type_id, 2);

$place_data->delete($place->id);
$place = $place_data->get_by_id($place->id);
ok(!defined $place);

$sql->commit;

};


1;
