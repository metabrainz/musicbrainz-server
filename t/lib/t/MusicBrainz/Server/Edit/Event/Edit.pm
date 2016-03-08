package t::MusicBrainz::Server::Edit::Event::Edit;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_EVENT_EDIT $UNTRUSTED_FLAG );

test 'MBS-8837' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
        INSERT INTO event (id, name, gid, time)
        VALUES (1, 'test', '5140d04f-a0f9-4846-8b23-b53a36b5c5ff', '19:30:00');
EOSQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_EDIT,
        editor_id => 1,
        to_edit => $c->model('Event')->get_by_id(1),
        time => '19:00',
        privileges => $UNTRUSTED_FLAG,
    );

    $c->sql->do('UPDATE event SET time = ? WHERE id = 1', '19:00:00');
    ok !exception { $edit->accept };
    my $time = $c->sql->select_single_value('SELECT time FROM event WHERE id = 1');
    is($time, '19:00:00');
};

1;
