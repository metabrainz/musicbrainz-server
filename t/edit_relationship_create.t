#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Relationship::Create' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
is($rel->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
ok(!defined $rel);

# Test accepting the edit
$edit = _create_edit();
accept_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
ok(defined $rel);
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 2);
is($rel->link->begin_date->year, 1994);
is($rel->link->end_date->year, 1995);

subtest 'creating cover art relationships should update the releases coverart' => sub {
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'release',
        type1 => 'url',
        entity0 => 1,
        entity1 => $c->model('URL')->find_or_insert('http://web.archive.org/web/20100820183338/wiki.jpopstop.com/images/8/8d/alan_-_Kaze_ni_Mukau_Hana_CDDVD_mu-mo.jpg')->id,
        link_type_id => 84
    );
    accept_edit($c, $edit);

    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Release')->load_meta($release);
    ok($release->cover_art_url);
};

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        entity0 => 1,
        entity1 => 2,
        link_type_id => 2,
        begin_date => { year => 1994 },
        end_date => { year => 1995 },
        attributes => [ ],
    );
}
