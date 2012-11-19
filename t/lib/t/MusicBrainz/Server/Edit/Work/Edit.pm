package t::MusicBrainz::Server::Edit::Work::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;
use Test::Deep qw( cmp_set );

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::Edit };

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Old edit work edits to add ISWCs still pass (insert)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<'EOSQL');
INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name) VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 1);
INSERT INTO edit (expire_time, id, editor, type, status, data)
    VALUES (now(), 1, 1, 42, 1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":null}}')
EOSQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ 'T-910.986.678-6' ]);
};

test 'Old edit work edits to add ISWCs still pass (update)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<'EOSQL');
INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name) VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 1);
INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
INSERT INTO edit (expire_time, id, editor, type, status, data)
    VALUES (now(), 1, 1, 42, 1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":"T-110.986.678-6"}}')
EOSQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ 'T-910.986.678-6' ]);
};

test 'Old edit work edits to add ISWCs still pass (delete)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<'EOSQL');
INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name) VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 1);
INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
INSERT INTO edit (expire_time, id, editor, type, status, data)
    VALUES (now(), 1, 1, 42, 1, '{"entity":{"name":"Work","id":1},"new":{"iswc":null},"old":{"iswc":"T-110.986.678-6"}}')
EOSQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ ]);
};

test 'Old edit work edits to add ISWCs still pass (conflict)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<'EOSQL');
INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name) VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 1);
INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
INSERT INTO edit (expire_time, id, editor, type, status, data)
    VALUES (now(), 1, 1, 42, 1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":null}}')
EOSQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ 'T-110.986.678-6' ]);
};

test all => sub {

my $test = shift;
my $c = $test->c;

my %args = (
    name => 'Edited name',
    comment => 'Edited comment',
    type_id => 1,
    language_id => 1,
);

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');
MusicBrainz::Server::Test->prepare_test_database($c, '+language');

my $work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

my $edit = create_edit($c, $work, %args);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

my ($edits) = $c->model('Edit')->find({ work => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 1);

reject_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

$work = $c->model('Work')->get_by_id(1);
$edit = create_edit($c, $work, %args);
accept_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
is($work->name, 'Edited name');
is($work->comment, 'Edited comment');
is($work->type_id, 1);
is($work->language_id, 1);
is($work->edits_pending, 0);

};

test 'Adding a work language is an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');
    MusicBrainz::Server::Test->prepare_test_database($c, '+language');

    {
        my $edit = create_edit(
            $c, $c->model('Work')->get_by_id(1),
            language_id => 1
        );

        ok(!$edit->is_open);
    }
};

test 'Changing work language is not an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');
    MusicBrainz::Server::Test->prepare_test_database($c, '+language');
    $c->sql->do('UPDATE work SET language = 1');

    {
        my $edit = create_edit(
            $c, $c->model('Work')->get_by_id(1),
            language_id => undef
        );

        ok($edit->is_open);
        accept_edit($c, $edit);
    }
};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Work')->get_by_id(1),
        name => 'Awesome work is awesome'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Work')->get_by_id(1),
        name      => 'Awesome work'
    );

    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $work = $c->model('Work')->get_by_id(1);
    is ($work->name, 'Awesome work', 'work renamed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

    my $edit_1 = $c->model('Edit')->create(
        edit_type   => $EDIT_WORK_EDIT,
        editor_id   => 1,
        to_edit     => $c->model('Work')->get_by_id(1),
        name        => 'A'
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type   => $EDIT_WORK_EDIT,
        editor_id   => 1,
        to_edit     => $c->model('Work')->get_by_id(1),
        name        => 'B'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $work = $c->model('Work')->get_by_id(1);
    is ($work->name, 'A', 'work renamed');
};

sub create_edit {
    my $c = shift;
    my $work = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        to_edit => $work,
        @_
    );
}

sub is_unchanged {
    my $work = shift;
    is($work->name, 'Traits (remix)');
    is($work->comment, '');
    is($work->type_id, undef);
}

1;
