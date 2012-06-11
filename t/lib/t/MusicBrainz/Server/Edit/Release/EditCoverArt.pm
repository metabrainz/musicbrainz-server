package t::MusicBrainz::Server::Edit::Release::EditCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Edit };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_COVER_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Editing cover art fails if the cover art no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT_COVER_ART,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        old_types => [ ],
        new_types => [ 1 ],
        artwork_id => 12345
    );

    $c->sql->do('DELETE FROM cover_art_archive.cover_art WHERE id = 12345');

    my $exception = exception { $edit->accept };
    ok($exception);
    isa_ok($exception, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency');
    warn $exception;
};

1;
