package t::MusicBrainz::Server::Edit::ReleaseGroup::SetCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_SET_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Set cover art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');
    my $rg = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('Artwork')->load_for_release_groups ($rg);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_SET_COVER_ART,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        entity => $rg,
    );

    $edit->accept ();

    $rg = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('Artwork')->load_for_release_groups ($rg);

    isa_ok($rg->cover_art, 'MusicBrainz::Server::Entity::Artwork');
    isa_ok($rg->cover_art->release, 'MusicBrainz::Server::Entity::Release');

    is ($rg->cover_art->is_front, 1, "Associated cover art is a frontiest cover");
    is ($rg->cover_art->id, 12345, "Associated cover art has expected id");
    is ($rg->cover_art->release->id, 1, "Associated cover art has links to expected release id");

    my $exception = exception {
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASEGROUP_SET_COVER_ART,
            editor_id => 1,
            release => $c->model('Release')->get_by_id(1),
            entity => $rg,
            );
    };

    ok($exception);
    isa_ok ($exception, 'MusicBrainz::Server::Edit::Exceptions::NoChanges');
};

test 'Set cover art fails if release no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');
    my $rg = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('Artwork')->load_for_release_groups ($rg);

    my $release = $c->model('Release')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_SET_COVER_ART,
        editor_id => 1,
        release => $release,
        entity => $rg,
    );

    $c->model('Release')->delete ($release->id);

    my $exception = exception { $edit->accept };
    ok($exception, "An exception occured when accepting the edit");
    isa_ok($exception, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency',
        "... and is a failed dependancy");
};

