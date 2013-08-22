package t::MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting removes the linked cover art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    ok !exception {
        my $edit = create_edit($c);
        accept_edit($c, $edit);
    }
};

test 'Rejecting does not make any changes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    ok !exception {
        my $edit = create_edit($c);
        reject_edit($c, $edit);
    };
};

sub create_edit {
    my $c = shift;
    my $release = $c->model('Release')->get_by_id(1) or die 'Could not load release, is the test data correct?';

    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADD_COVER_ART,
        editor_id => 1,

        release => $c->model('Release')->get_by_id(1),
        cover_art_id => '1234',
        cover_art_types => [ ],
        cover_art_position => 1,
        cover_art_comment => '',
        cover_art_mime_type => 'image/jpeg'
    )->accept;

    my ($artwork) = @{ $c->model ('CoverArtArchive')->find_available_artwork($release->gid) };

    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_REMOVE_COVER_ART,
        editor_id => 1,

        release => $release,
        to_delete => $artwork,

        cover_art_type => 'cover',
        cover_art_page => 2
    );
}

1;
