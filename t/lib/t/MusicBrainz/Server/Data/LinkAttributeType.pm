package t::MusicBrainz::Server::Data::LinkAttributeType;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::LinkType;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

my $lat_data = $test->c->model('LinkAttributeType');
my $link_attr_type = $lat_data->get_by_id(1);
is($link_attr_type->id, 1);
is($link_attr_type->parent_id, undef);
is($link_attr_type->name, 'Additional');


$test->c->sql->begin;
$lat_data->update(1, { name => 'Additional test' });
$test->c->sql->commit;

$link_attr_type = $lat_data->get_by_id(1);
is($link_attr_type->id, 1);
is($link_attr_type->parent_id, undef);
is($link_attr_type->name, 'Additional test');

$test->c->sql->begin;
$link_attr_type = $lat_data->insert({
    parent_id => 2,
    name => 'Piano',
});
$test->c->sql->commit;

is($link_attr_type->id, 100);

$test->c->sql->begin;
$lat_data->update(3, { parent_id => 1 });
$test->c->sql->commit;

my $root_id = $test->c->sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=3');
is($root_id, 1);
$root_id = $test->c->sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=4');
is($root_id, 1);

$test->c->sql->begin;
$link_attr_type = $lat_data->delete(100);
$test->c->sql->commit;

$link_attr_type = $lat_data->get_by_id(100);
is($link_attr_type, undef);

};

test 'get_by_gid with non existant GID' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

    ok(!defined $test->c->model('LinkAttributeType')->get_by_gid(
        'ba5341f8-3b1d-4f99-a0c6-26b7f4e42c7f'));
};

test 'Updating a link attribute invalidates cache entries for links' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;

    $c->sql->do(<<'EOSQL');
INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (1, 1, '36990974-4f29-4ea1-b562-3838fa9b8832', 'additional');
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase,
                       reverse_link_phrase, long_link_phrase, description)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'recording',
            'instrument', 'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer', 'performed desc');
INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 1);
INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES (1, 1, 0, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (1, 1);
EOSQL

    my $original_link = $c->model('Link')->get_by_id(1);
    is($original_link->attributes->[0]->name, 'additional');

    $c->model('LinkAttributeType')->update(1, { name => 'renamed' });

    my $updated_link = $c->model('Link')->get_by_id(1);
    is($updated_link->attributes->[0]->name, 'renamed');
};

1;
