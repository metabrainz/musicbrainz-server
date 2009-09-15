#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 17;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::LinkType';

use Sql;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');

my $sql = Sql->new($c->dbh);

my $link_type = $c->model('LinkType')->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument');
is($link_type->short_link_phrase, 'performer');

$sql->begin;
$c->model('LinkType')->update(1, { name => 'instrument test' });
$sql->commit;

$link_type = $c->model('LinkType')->get_by_id(1);
is($link_type->id, 1);
is($link_type->name, 'instrument test');
is($link_type->short_link_phrase, 'performer');

$sql->begin;
$link_type = $c->model('LinkType')->insert({
    parent_id => 1,
    name => 'instrument test',
    link_phrase => 'link_phrase',
    reverse_link_phrase => 'reverse_link_phrase',
    short_link_phrase => 'short_link_phrase',
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
$link_type = $c->model('LinkType')->update(100, {
    attributes => [
        { type => 2 }
    ],
});
$sql->commit;

$row = $sql->select_single_row_hash('SELECT * FROM link_type_attribute_type WHERE link_type=100');
is($row->{attribute_type}, 2);
is($row->{min}, undef);
is($row->{max}, undef);

$link_type = $c->model('LinkType')->get_by_id(100);
is($link_type->parent_id, 1);

$sql->begin;
$link_type = $c->model('LinkType')->update(100, {
    parent_id => undef,
});
$sql->commit;

$link_type = $c->model('LinkType')->get_by_id(100);
is($link_type->parent_id, undef);

$sql->begin;
$link_type = $c->model('LinkType')->delete(100);
$sql->commit;

$link_type = $c->model('LinkType')->get_by_id(100);
is($link_type, undef);
