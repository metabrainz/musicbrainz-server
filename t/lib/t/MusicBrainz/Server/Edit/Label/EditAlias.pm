package t::MusicBrainz::Server::Edit::Label::EditAlias;
use Test::Routine;
use Test::Fatal;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::EditAlias }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT_ALIAS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Label')->get_by_id(1),
        alias     => $c->model('Label')->alias->get_by_id(2),
        name => 'Renamed alias',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Label')->get_by_id(1),
        alias     => $c->model('Label')->alias->get_by_id(2),
        locale    => 'en_TEST'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $alias = $c->model('Label')->alias->get_by_id(2);
    is($alias->name, 'Renamed alias', 'alias was renamed');
    is($alias->locale, 'en_TEST', 'alias locale changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Label')->get_by_id(1),
        alias     => $c->model('Label')->alias->get_by_id(2),
        name => 'Call it FOO!'
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Label')->get_by_id(1),
        alias     => $c->model('Label')->alias->get_by_id(2),
        name      => 'Call it BAZ!'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $alias = $c->model('Label')->alias->get_by_id(2);
    is($alias->name, 'Call it FOO!', 'alias was renamed');
};

1;
