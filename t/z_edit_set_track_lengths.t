use strict;
use warnings;
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::SetTrackLengths' };

use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );

my $c = MusicBrainz::Server::Test->create_test_context;
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_SET_TRACK_LENGTHS,
    editor_id => 1,
    tracklist_id => 1,
    cdtoc_id => 1
);
isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

accept_edit($c, $edit);

my $tracklist = $c->model('Tracklist')->get_by_id(1);
$c->model('Track')->load_for_tracklists($tracklist);
is($tracklist->tracks->[0]->length, 338640);
is($tracklist->tracks->[1]->length, 273133);
is($tracklist->tracks->[2]->length, 327226);
is($tracklist->tracks->[3]->length, 252066);
is($tracklist->tracks->[4]->length, 719666);
is($tracklist->tracks->[5]->length, 276933);
is($tracklist->tracks->[6]->length, 94200);

done_testing;
