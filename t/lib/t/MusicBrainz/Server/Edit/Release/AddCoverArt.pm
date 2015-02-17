package t::MusicBrainz::Server::Edit::Release::AddCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting replaces current art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO cover_art_archive.art_type (id, name) VALUES (1, 'Front');
EOSQL

    my $edit = create_edit($c);

    accept_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

test 'Rejecting cleans up pending artwork' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO cover_art_archive.art_type (id, name) VALUES (1, 'Front');
EOSQL

    my $edit = create_edit($c);

    reject_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

sub create_edit {
    my $c = shift;
    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADD_COVER_ART,
        editor_id => 1,

        release => $c->model('Release')->get_by_id(1),
        cover_art_id => '1234',
        cover_art_types => [ 1 ],
        cover_art_position => 1,
        cover_art_comment => '',
        cover_art_mime_type => 'image/jpeg'
    );
}

1;
