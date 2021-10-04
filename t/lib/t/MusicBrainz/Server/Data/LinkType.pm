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

my $link_type = $lt_data->get_by_id(148);
is($link_type->id, 148);
is($link_type->name, 'instrument');
is($link_type->long_link_phrase, 'performed {additional} {guest} {solo} {instrument:%|instruments} on');


$sql->begin;
$lt_data->update(148, { name => 'instrument test' });
$sql->commit;

$link_type = $lt_data->get_by_id(148);
is($link_type->id, 148);
is($link_type->name, 'instrument test');
is($link_type->long_link_phrase, 'performed {additional} {guest} {solo} {instrument:%|instruments} on');

$sql->begin;
$link_type = $lt_data->insert({
    parent_id => 156,
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

my $id = $link_type->id;
my $row = $sql->select_single_row_hash('SELECT * FROM link_type_attribute_type WHERE link_type = ?', $id);
is($row->{attribute_type}, 1);
is($row->{min}, 0);
is($row->{max}, 1);

$sql->begin;
$link_type = $lt_data->update($id, {
    attributes => [{ type => 14 }],
});
$sql->commit;

$row = $sql->select_single_row_hash('SELECT * FROM link_type_attribute_type WHERE link_type = ?', $id);
is($row->{attribute_type}, 14);
is($row->{min}, undef);
is($row->{max}, undef);

$link_type = $lt_data->get_by_id($id);
is($link_type->parent_id, 156);

$sql->begin;
$link_type = $lt_data->update($id, {
    parent_id => undef,
});
$sql->commit;

$link_type = $lt_data->get_by_id($id);
is($link_type->parent_id, undef);

$sql->begin;
$link_type = $lt_data->delete($id);
$sql->commit;

$link_type = $lt_data->get_by_id($id);
is($link_type, undef);

};

test 'Can load relationship documentation' => sub {
    my $test = shift;
    my $c = $test->c;

    my $expected_documentation = 'Documentation goes here';
    $test->c->sql->do(<<~'SQL', $expected_documentation);
        INSERT INTO documentation.link_type_documentation (id, documentation) VALUES (102, ?);
        SQL

    my $link_types = $c->model('LinkType')->get_by_ids(102, 103);
    my @all_link_types = values %$link_types;
    $c->model('LinkType')->load_documentation(@all_link_types);

    is($link_types->{102}->documentation, $expected_documentation, 'loaded documentation sucessfully');
    is($link_types->{103}->documentation, '', 'default documentation string is empty');

    my $new_documentation = 'newer documentation';
    my $subject = $link_types->{102};
    $c->model('LinkType')->update($subject->id, { documentation => $new_documentation });
    $c->model('LinkType')->load_documentation(@all_link_types);

    is($subject->documentation, $new_documentation, 'can update documentation');
};

test 'Deprecated relationships are loaded as is_deprecated' => sub {
    my $test = shift;
    my $c = $test->c;

    my $link_types = $c->model('LinkType')->get_by_ids(102, 236);
    ok(!$link_types->{102}->is_deprecated, 'LT 102 is not deprecated');
    ok($link_types->{236}->is_deprecated, 'LT 236 is deprecated');
};

1;
