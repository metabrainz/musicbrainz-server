package t::MusicBrainz::Server::Data::LinkAttributeType;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

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

memory_cycle_ok($lat_data);
memory_cycle_ok($link_attr_type);

$test->c->sql->begin;
$lat_data->update(1, { name => 'Additional test' });
memory_cycle_ok($lat_data);
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
memory_cycle_ok($lat_data);
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
memory_cycle_ok($lat_data);
$test->c->sql->commit;

$link_attr_type = $lat_data->get_by_id(100);
is($link_attr_type, undef);

};

1;
