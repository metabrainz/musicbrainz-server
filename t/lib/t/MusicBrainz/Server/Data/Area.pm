package t::MusicBrainz::Server::Data::Area;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Test;

with 't::Edit';
with 't::Context';

my $AREA_GID = 'f03dd94f-a936-42eb-bb97-819102487899';
my $INSERT_AREA = <<"EOSQL";
INSERT INTO area (id, gid, name, sort_name)
  VALUES (1, '$AREA_GID', 'Area', 'Area');
EOSQL

for my $test_data (
    [ 'iso_3166_1', 'CO' ],
    [ 'iso_3166_2', 'US-MD' ],
    [ 'iso_3166_3', 'DDDE' ],
) {
    my ($iso, $code) = @$test_data;
    my $method = "get_by_$iso";

    test $method => sub {
        my $test = shift;
        my $c = $test->c;

        $c->sql->do(<<"EOSQL");
$INSERT_AREA
INSERT INTO $iso (area, code) VALUES (1, '$code');
EOSQL

        my $areas = $c->model("Area")->$method($code, 'NA');
        ok(exists $areas->{$code}, "Found an area for $code");
        ok(exists $areas->{NA}, "There is an entry for NA");
        is($areas->{NA}, undef, "No area for NA");
        is($areas->{$code}->gid, $AREA_GID, "Found $code area");
    };
}

test 'Test load_parent_country' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO area_type (id, name) VALUES (1, 'Country'), (2, 'Subdivision');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
    (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'descendant', 'descendant', 2),
    (2, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'parent', 'parent', 1),
    (3, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'incorrect parent', 'incorrect parent', 1);

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
    (356, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'area', 'area', 'part of', 'link', 'rev-link', 'long-link');
INSERT INTO link (id, link_type) VALUES (1, 356);
INSERT INTO l_area_area (link, entity0, entity1) VALUES (1, 2, 1), (1, 3, 2);
EOSQL

    my $area = $test->c->model('Area')->get_by_id(1);
    is($area->name, 'descendant', 'correct descendant country is loaded');

    $test->c->model('Area')->load_parent_country($area);
    is($area->parent_country->name, 'parent', 'correct parent country is loaded');
};

1;
