package t::MusicBrainz::Server::Data::Area;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Area;

use MusicBrainz::Server::Test;

with 't::Edit';
with 't::Context';

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
