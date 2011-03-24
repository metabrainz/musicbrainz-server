#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Relationship::Edit' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 0, "no edit pending on the relationship");
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 1, "link type id = 1");
is($rel->link->begin_date->year, undef, "no begin date");
is($rel->link->end_date->year, undef, "no end date");

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($hits, 1, "Found 1 edit for artist 1");
is($edits->[0]->id, $edit->id, "... which has the same id as the edit just created");

($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
is($hits, 1, "Found 1 edit for artist 2");
is($edits->[0]->id, $edit->id, "... which has the same id as the edit just created");

$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 1, "The relationship has 1 edit pending.");

# Test rejecting the edit
reject_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel);
is($rel->edits_pending, 0, "After rejecting the edit, no edit pending on the relationship");

# Test accepting the edit
$edit = _create_edit();
accept_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel, "After accepting the edit, the relationship has...");
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 2, "... type id 2");
is($rel->link->begin_date->year, 1994, "... begin year 1994");
is($rel->link->end_date->year, 1995, "... end year 1995");

# test change direction
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel, "Before accepting the edit...");
is($rel->entity0_id, 1, "... entity0 is artist 1");
is($rel->entity1_id, 2, "... entity1 is artist 2");

$edit = _create_edit_change_direction ();
accept_edit($c, $edit);

$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel, "After accepting the edit...");
is($rel->entity0_id, 2, "... entity0 is now artist 2");
is($rel->entity1_id, 1, "... entity1 is now artist 1");

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

sub _create_edit_change_direction {
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        change_direction => 1,
        relationship => $rel,
        link_type_id => 2,
        begin_date => undef,
        end_date => undef,
        attributes => [],
    );
}
