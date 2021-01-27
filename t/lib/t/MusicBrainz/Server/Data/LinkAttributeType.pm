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
is($link_attr_type->name, 'additional');


$test->c->sql->begin;
$lat_data->update(1, { name => 'additional test' });
$test->c->sql->commit;

$link_attr_type = $lat_data->get_by_id(1);
is($link_attr_type->id, 1);
is($link_attr_type->parent_id, undef);
is($link_attr_type->name, 'additional test');

$test->c->sql->begin;
$link_attr_type = $lat_data->insert({
    parent_id => 229,
    name => 'electric guitar',
});
$test->c->sql->commit;

my $link_attr_type_id = $link_attr_type->id;

$test->c->sql->begin;
$lat_data->update(302, { parent_id => 1 });
$test->c->sql->commit;

my $root_id = $test->c->sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=302');
is($root_id, 1);
$root_id = $test->c->sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=229');
is($root_id, 14);

$test->c->sql->begin;
$link_attr_type = $lat_data->delete($link_attr_type_id);
$test->c->sql->commit;

$link_attr_type = $lat_data->get_by_id($link_attr_type_id);
is($link_attr_type, undef);

};

test 'get_by_gid with non existent GID' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

    ok(!defined $test->c->model('LinkAttributeType')->get_by_gid(
        'ba5341f8-3b1d-4f99-a0c6-26b7f4e42c7f'));
};

test 'Updating a link attribute invalidates cache entries for links' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;

    $c->sql->do(<<'EOSQL');
INSERT INTO link (id, link_type, attribute_count) VALUES (1, 148, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (1, 1);
EOSQL

    # Ensure cache is clear before calling get_by_id
    $c->cache->delete('link:1');

    my $original_link = $c->model('Link')->get_by_id(1);
    is($original_link->attributes->[0]->type->name, 'additional');

    $c->model('LinkAttributeType')->update(1, { name => 'renamed' });

    my $updated_link = $c->model('Link')->get_by_id(1);
    is($updated_link->attributes->[0]->type->name, 'renamed');

    # Cleanup
    $c->cache->delete('link:1');
};

1;
