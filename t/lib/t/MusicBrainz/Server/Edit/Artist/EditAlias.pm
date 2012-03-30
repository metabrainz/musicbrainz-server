package t::MusicBrainz::Server::Edit::Artist::EditAlias;
use Test::Routine;
use Test::Fatal;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::EditAlias }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT_ALIAS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Should fail if the alias has subsequently been deleted' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(2),
        name      =>  'Renamed alias',
    );

    $c->model('Artist')->alias->delete(2);

    isa_ok exception { $edit->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(2),
        name => 'Renamed alias',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(2),
        locale    => 'en_TEST'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $alias = $c->model('Artist')->alias->get_by_id(2);
    is ($alias->name, 'Renamed alias', 'alias was renamed');
    is ($alias->locale, 'en_TEST', 'alias locale changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(2),
        name => 'Call it FOO!'
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(2),
        name      => 'Call it BAZ!'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $alias = $c->model('Artist')->alias->get_by_id(2);
    is ($alias->name, 'Call it FOO!', 'alias was renamed');
};

1;
