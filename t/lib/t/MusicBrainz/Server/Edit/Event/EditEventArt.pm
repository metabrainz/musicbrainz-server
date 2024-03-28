package t::MusicBrainz::Server::Edit::Event::EditEventArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Event::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_EVENT_EDIT_EVENT_ART );

test 'Editing event art fails if the event art no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+eaa');

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { account_admin => 1 });

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_EDIT_EVENT_ART,
        editor_id => 1,
        event => $c->model('Event')->get_by_id(59357),
        old_types => [],
        new_types => [1],
        artwork_id => 12345,
    );

    $c->sql->do('DELETE FROM event_art_archive.event_art WHERE id = 12345');

    my $exception = exception { $edit->accept };
    ok($exception);
    isa_ok($exception, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency');
};

test 'Editing event art edits can be accepted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+eaa');

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { account_admin => 1 });

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_EDIT_EVENT_ART,
        editor_id => 1,
        event => $c->model('Event')->get_by_id(59357),
        old_comment => '',
        new_comment => 'Bar',
        artwork_id => 12345,
    );

    my $exception = exception { $edit->accept };
    ok(!$exception);
};

1;
