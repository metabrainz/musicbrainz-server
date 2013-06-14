package t::MusicBrainz::Server::Data::LinkType;
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

my $lt_data = $test->c->model('LinkType');

my $sql = $test->c->sql;

my $link_type = $lt_data->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument');
is($link_type->long_link_phrase, 'performer');


$sql->begin;
$lt_data->update(1, { name => 'instrument test' });
$sql->commit;

$link_type = $lt_data->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument test');
is($link_type->long_link_phrase, 'performer');

$sql->begin;
$link_type = $lt_data->insert({
    parent_id => 1,
    name => 'instrument test',
    link_phrase => 'link_phrase',
    entity0_type => 'artist',
    entity1_type => 'recording',
    reverse_link_phrase => 'reverse_link_phrase',
    long_link_phrase => 'long_link_phrase',
    attributes => [
        { type => 1, min => 0, max => 1 }
    ],
});
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
$sql->commit;

$link_type = $lt_data->get_by_id(100);
is($link_type, undef);

};

test 'Can load relationship documentation' => sub {
    my $test = shift;
    my $c = $test->c;

    my $expected_documentation = 'Documentation goes here';
    $test->c->sql->do(<<EOSQL, $expected_documentation);
INSERT INTO link_type (id, name, entity_type0, entity_type1, gid, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
    (1, 'performer', 'artist', 'artist', '0e747859-2491-4b16-8173-87d211a8f56b', 'performer', 'performer', 'performer'),
    (2, 'composer', 'artist', 'artist', '6f68ed33-e70c-46e8-82de-3a16d2dcba26', 'composer', 'composer', 'composer');
INSERT INTO documentation.link_type_documentation (id, documentation) VALUES (1, ?);
EOSQL

    my $link_types = $c->model('LinkType')->get_by_ids(1, 2);
    my @all_link_types = values %$link_types;
    $c->model('LinkType')->load_documentation(@all_link_types);

    is($link_types->{1}->documentation, $expected_documentation, 'loaded documentation sucessfully');
    is($link_types->{2}->documentation, '', 'default documentation string is empty');

    my $new_documentation = 'newer documentation';
    my $subject = $link_types->{1};
    $c->model('LinkType')->update($subject->id, { documentation => $new_documentation });
    $c->model('LinkType')->load_documentation(@all_link_types);

    is($subject->documentation, $new_documentation, 'can update documentation');
};

1;

