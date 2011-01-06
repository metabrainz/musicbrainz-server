package t::MusicBrainz::Server::Data::LinkAttributeType;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::LinkType';

use Sql;
use MusicBrainz::Server::Test;

test all => sub {

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');

my $sql = Sql->new($c->dbh);

my $link_attr_type = $c->model('LinkAttributeType')->get_by_id(1);
is($link_attr_type->id, 1);
is($link_attr_type->parent_id, undef);
is($link_attr_type->name, 'Additional');

$sql->begin;
$c->model('LinkAttributeType')->update(1, { name => 'Additional test' });
$sql->commit;

$link_attr_type = $c->model('LinkAttributeType')->get_by_id(1);
is($link_attr_type->id, 1);
is($link_attr_type->parent_id, undef);
is($link_attr_type->name, 'Additional test');

$sql->begin;
$link_attr_type = $c->model('LinkAttributeType')->insert({
    parent_id => 2,
    name => 'Piano',
});
$sql->commit;

is($link_attr_type->id, 100);

$sql->begin;
$c->model('LinkAttributeType')->update(3, { parent_id => 1 });
$sql->commit;

my $root_id = $sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=3');
is($root_id, 1);
$root_id = $sql->select_single_value('SELECT root FROM link_attribute_type WHERE id=4');
is($root_id, 1);

$sql->begin;
$link_attr_type = $c->model('LinkAttributeType')->delete(100);
$sql->commit;

$link_attr_type = $c->model('LinkAttributeType')->get_by_id(100);
is($link_attr_type, undef);

};

1;
