package t::MusicBrainz::Server::Edit::Release::EditArtist;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants '$EDIT_RELEASE_ARTIST';
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database(
    $c,
    "INSERT INTO artist (id, gid, name, sort_name)
          VALUES (2, '145c079d-374e-4436-9448-da92dedef3cf', 1, 1)");

my $original_release = $c->model('Release')->get_by_id(1);

my $edit = create_edit($c, $original_release);

my $release = $c->model('Release')->get_by_id(1);
is($release->edits_pending => 1);
is($release->artist_credit_id, 1);

reject_edit($c, $edit);

$release = load_release($c);
is($release->edits_pending => 0);
is($release->artist_credit_id, 1);

$edit = create_edit($c, $original_release);
accept_edit($c, $edit);

$release = load_release($c);
is($release->edits_pending => 0);
ok($release->artist_credit_id != 1);
is($release->artist_credit->names->[0]->artist_id => 2);
is($_->artist_credit_id => 1)
    for map { $_->tracklist->all_tracks } $release->all_mediums;

$edit = create_edit($c, $original_release, 1);
accept_edit($c, $edit);

$release = load_release($c);
for (map { $_->tracklist->all_tracks } $release->all_mediums) {
    ok($_->artist_credit_id != 1);
    is($_->artist_credit->names->[0]->artist_id => 2);
}

};

sub create_edit {
    my $c = shift;
    my $original_release = shift;
    my $update = shift || 0;
    $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_RELEASE_ARTIST,
        release => $original_release,
        update_tracklists => $update,
        artist_credit => {
            names => [
                { artist => { id => 2 }, name => 'My new AC' }
            ] }
    );
}

sub load_release {
    my $c = shift;
    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Medium')->load_for_releases($release);
    $c->model('Track')->load_for_tracklists(map { $_->tracklist } $release->all_mediums);
    $c->model('ArtistCredit')->load(
        $release, map { $_->tracklist->all_tracks } $release->all_mediums);
    return $release;
}

1;
