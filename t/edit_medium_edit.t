use strict;
use warnings;
use Test::More tests => 19;

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Test;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::Edit' }

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $medium = $c->model('Medium')->get_by_id(1);
is($medium->tracklist_id, 1);
is($medium->format_id, undef);
is($medium->release_id, 1);
is($medium->position, 1);
is($medium->edits_pending, 0);

my $edit = $c->model('Edit')->create(
    editor_id => 1,
    edit_type => $EDIT_MEDIUM_EDIT,
    medium => $medium,
    format_id => 1,
    name => 'Edited name',
    tracklist_id => 2,
    position => 2,
);

isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Edit');
is($edit->entity_model, 'Medium');
is($edit->entity_id, $medium->id);

$medium = $c->model('Medium')->get_by_id(1);
is($medium->tracklist_id, 1);
is($medium->format_id, undef);
is($medium->release_id, 1);
is($medium->position, 1);
is($medium->edits_pending, 1);

$c->model('Edit')->accept($edit);

$medium = $c->model('Medium')->get_by_id(1);
is($medium->tracklist_id, 2);
is($medium->format_id, 1);
is($medium->release_id, 1);
is($medium->position, 2);
is($medium->edits_pending, 0);
