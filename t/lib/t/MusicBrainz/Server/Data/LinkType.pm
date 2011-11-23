package t::MusicBrainz::Server::Data::LinkType;
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

my $lt_data = $test->c->model('LinkType');

my $sql = $test->c->sql;

my $link_type = $lt_data->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument');
is($link_type->short_link_phrase, 'performer');

memory_cycle_ok($lt_data);
memory_cycle_ok($link_type);

$sql->begin;
$lt_data->update(1, { name => 'instrument test' });
memory_cycle_ok($lt_data);
$sql->commit;

$link_type = $lt_data->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument test');
is($link_type->short_link_phrase, 'performer');

$sql->begin;
$link_type = $lt_data->insert({
    parent_id => 1,
    name => 'instrument test',
    link_phrase => 'link_phrase',
    entity0_type => 'artist',
    entity1_type => 'recording',
    reverse_link_phrase => 'reverse_link_phrase',
    short_link_phrase => 'short_link_phrase',
    attributes => [
        { type => 1, min => 0, max => 1 }
    ],
});
memory_cycle_ok($lt_data);
$sql->commit;

is($link_type->id, 100);

my $row = $sql->select_single_row_hash('SELECT * FROM link_type_attribute_type WHERE link_type=100');
is($row->{attribute_type}, 1);
is($row->{min}, 0);
is($row->{max}, 1);

$sql->begin;
$link_type = $lt_data->update(100, {
    attributes => [
        { type => 2 }
    ],
});
$sql->commit;

$row = $sql->select_single_row_hash('SELECT * FROM link_type_attribute_type WHERE link_type=100');
is($row->{attribute_type}, 2);
is($row->{min}, undef);
is($row->{max}, undef);

$link_type = $lt_data->get_by_id(100);
is($link_type->parent_id, 1);

$sql->begin;
$link_type = $lt_data->update(100, {
    parent_id => undef,
});
$sql->commit;

$link_type = $lt_data->get_by_id(100);
is($link_type->parent_id, undef);

$sql->begin;
$link_type = $lt_data->delete(100);
memory_cycle_ok($lt_data);
$sql->commit;

$link_type = $lt_data->get_by_id(100);
is($link_type, undef);

};

1;
