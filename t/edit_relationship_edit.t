#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Relationship::Edit' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 0);
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 1);
is($rel->link->begin_date->year, undef);
is($rel->link->end_date->year, undef);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 1);

# Test rejecting the edit
$c->model('Edit')->reject($edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel);
is($rel->edits_pending, 0);

# Test accepting the edit
$edit = _create_edit();
$c->model('Edit')->accept($edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel);
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 2);
is($rel->link->begin_date->year, 1994);
is($rel->link->end_date->year, 1995);

done_testing;

sub _create_edit {
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => $rel,
        link_type_id => 2,
        begin_date => { year => 1994 },
        end_date => { year => 1995 },
        attributes => [],
    );
}
