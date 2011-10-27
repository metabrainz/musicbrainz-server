package t::MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting removes the linked cover art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    LWP::UserAgent::Mockable->reset('playback', $Bin.'/lwp-sessions/cover-art-archive-delete-accept.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_REMOVE_COVER_ART,
        editor_id => 1,

        release => $c->model('Release')->get_by_id(1),
        cover_art_type => 'cover',
        cover_art_page => 2
    );

    accept_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

test 'Rejecting does not make any changes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    LWP::UserAgent::Mockable->reset('playback', $Bin.'/lwp-sessions/cover-art-archive-delete-reject.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_REMOVE_COVER_ART,
        editor_id => 1,

        release => $c->model('Release')->get_by_id(1),
        cover_art_type => 'cover',
        cover_art_page => 2
    );

    reject_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

sub basic_validation {
    my ($actual, $expected) = @_;
    is($actual->uri, $expected->uri, 'called ' . $expected->uri);
    is($actual->method, $expected->method, 'method is ' . $expected->method);
}

1;
