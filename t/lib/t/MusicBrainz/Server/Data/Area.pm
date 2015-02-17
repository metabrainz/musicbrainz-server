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
INSERT INTO area (id, gid, name)
  VALUES (1, '$AREA_GID', 'Area');
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

test 'Test load_containment' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO area_type (id, name) VALUES (1, 'Country'), (2, 'Subdivision'), (3, 'City'), (4, 'District');
INSERT INTO area (id, gid, name, type) VALUES
    (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'descendant', 4),
    (2, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbaaaa', 'parent city', 3),
    (3, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbcccc', 'parent subdivision', 2),
    (4, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'parent country', 1),
    (5, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'incorrect parent country', 1);

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
    (356, 'de7cc874-8b1b-3a05-8272-f3834c968fb7', 'area', 'area', 'part of', 'link', 'rev-link', 'long-link');
INSERT INTO link (id, link_type) VALUES (1, 356);
INSERT INTO l_area_area (link, entity0, entity1) VALUES (1, 2, 1), (1, 3, 2), (1, 4, 3), (1, 5, 4);
EOSQL

    my $area = $test->c->model('Area')->get_by_id(1);
    is($area->name, 'descendant', 'correct descendant country is loaded');

    $test->c->model('Area')->load_containment($area);
    is($area->parent_city->name, 'parent city', 'correct parent city is loaded');
    is($area->parent_subdivision->name, 'parent subdivision', 'correct parent subdivision is loaded');
    is($area->parent_country->name, 'parent country', 'correct parent country is loaded');

    $area = $test->c->model('Area')->get_by_id(2);
    is($area->name, 'parent city', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is($area->parent_city, undef, 'no parent city is loaded');
    is($area->parent_subdivision->name, 'parent subdivision', 'correct parent subdivision is loaded');
    is($area->parent_country->name, 'parent country', 'correct parent country is loaded');

    $area = $test->c->model('Area')->get_by_id(3);
    is($area->name, 'parent subdivision', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is($area->parent_city, undef, 'no parent city is loaded');
    is($area->parent_subdivision, undef, 'no parent subdivision is loaded');
    is($area->parent_country->name, 'parent country', 'correct parent country is loaded');

    $area = $test->c->model('Area')->get_by_id(4);
    is($area->name, 'parent country', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is($area->parent_city, undef, 'no parent city is loaded');
    is($area->parent_subdivision, undef, 'no parent subdivision is loaded');
    is($area->parent_country->name, 'incorrect parent country', 'correct parent meta-country is loaded');

};

1;
