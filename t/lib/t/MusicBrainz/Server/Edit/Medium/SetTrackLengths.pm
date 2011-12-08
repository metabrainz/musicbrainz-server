package t::MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_SET_TRACK_LENGTHS,
    editor_id => 1,
    tracklist_id => 1,
    cdtoc_id => 1
);
isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

accept_edit($c, $edit);

my $tracklist = $c->model('Tracklist')->get_by_id(100);
$c->model('Track')->load_for_tracklists($tracklist);
is($tracklist->tracks->[0]->length, 338640);
is($tracklist->tracks->[1]->length, 273133);
is($tracklist->tracks->[2]->length, 327226);
is($tracklist->tracks->[3]->length, 252066);
is($tracklist->tracks->[4]->length, 719666);
is($tracklist->tracks->[5]->length, 276933);
is($tracklist->tracks->[6]->length, 94200);

};

1;
