use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT_TRACKLIST );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);
$c->model('ArtistCredit')->load($tracklist->all_tracks);

my $edit = $c->model('Edit')->create(
    editor_id => 1,
    edit_type => $EDIT_MEDIUM_EDIT_TRACKLIST,
    separate_tracklists => 0,
    medium_id => 1,
    tracklist_id => 1,
    old_tracklist => $tracklist,
    new_tracklist => [
        {
            name => 'Test track',
            artist_credit => [
                { artist => 1, name => 'aCiD2' }
            ],
            length => 12346,
            recording_id => 3
        }
    ]
);

accept_edit($c, $edit);

$tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);
$c->model('ArtistCredit')->load($tracklist->all_tracks);

is($tracklist->track_count, 1);
is($tracklist->tracks->[0]->name, 'Test track');
is($tracklist->tracks->[0]->artist_credit->name, 'aCiD2');
is($tracklist->tracks->[0]->length, 12346);
is($tracklist->tracks->[0]->position, 1);
is($tracklist->tracks->[0]->recording_id, 3);

done_testing;
