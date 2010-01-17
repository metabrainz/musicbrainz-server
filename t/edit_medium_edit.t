#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::Edit' }

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $medium = $c->model('Medium')->get_by_id(1);
is_unchanged($medium);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Edit');

$edit = $c->model('Edit')->get_by_id($edit->id);
$medium = $c->model('Medium')->get_by_id(1);
is_unchanged($medium);
is($medium->edits_pending, 1);

reject_edit($c, $edit);
$medium = $medium = $c->model('Medium')->get_by_id(1);
is($medium->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);

$medium = $medium = $c->model('Medium')->get_by_id(1);
is($medium->tracklist_id, 2);
is($medium->format_id, 1);
is($medium->release_id, 1);
is($medium->position, 2);
is($medium->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_MEDIUM_EDIT,
        to_edit => $medium,
        format_id => 1,
        name => 'Edited name',
        tracklist_id => 2,
        position => 2,
    );
}

sub is_unchanged {
    my $medium = shift;
    is($medium->tracklist_id, 1);
    is($medium->format_id, undef);
    is($medium->release_id, 1);
    is($medium->position, 1);
}
