use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Track::Edit' }

use MusicBrainz::Server::Constants qw( $EDIT_TRACK_EDIT );
use MusicBrainz::Server::Data::Track;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
ALTER SEQUENCE artist_credit_id_seq RESTART 2;
ALTER SEQUENCE artist_name_id_seq RESTART 2;
SQL

my $track = $c->model('Track')->get_by_id(1);
my $edit = $c->model('Edit')->create(
    editor_id => 1,
    edit_type => $EDIT_TRACK_EDIT,
    track => $track,
    name => 'Edited name',
    tracklist_id => 2,
    artist_credit => [ { artist => 1, name => 'Foo' } ],
    recording_id => 3
);

isa_ok($edit, 'MusicBrainz::Server::Edit::Track::Edit');
is($edit->entity_id, $track->id);
is($edit->entity_model, 'Track');

$track = $c->model('Track')->get_by_id(1);
is($track->edits_pending, 1);

$c->model('Edit')->accept($edit);

$track = $c->model('Track')->get_by_id(1);
$c->model('ArtistCredit')->load($track);
is($track->name, 'Edited name');
is($track->tracklist_id, 2);
is($track->artist_credit->name, 'Foo');
is($track->recording_id, 3);
is($track->edits_pending, 0);

done_testing;
