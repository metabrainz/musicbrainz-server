package t::MusicBrainz::Server::Edit::Work::Edit;
use strict;
use warnings;

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
    $c->sql->do(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 'Work');
        INSERT INTO edit (expire_time, id, editor, type, status)
            VALUES (now(), 1, 1, 42, 1);
        INSERT INTO edit_data (edit, data)
            VALUES (1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":null}}');
        SQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ 'T-910.986.678-6' ]);
};

test 'Old edit work edits to add ISWCs still pass (update)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 'Work');
        INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
        INSERT INTO edit (expire_time, id, editor, type, status)
            VALUES (now(), 1, 1, 42, 1);
        INSERT INTO edit_data (edit, data)
            VALUES (1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":"T-110.986.678-6"}}');
        SQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ 'T-910.986.678-6' ]);
};

test 'Old edit work edits to add ISWCs still pass (delete)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 'Work');
        INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
        INSERT INTO edit (expire_time, id, editor, type, status)
            VALUES (now(), 1, 1, 42, 1);
        INSERT INTO edit_data (edit, data)
            VALUES (1, '{"entity":{"name":"Work","id":1},"new":{"iswc":null},"old":{"iswc":"T-110.986.678-6"}}');
        SQL

    $c->model('Edit')->accept($c->model('Edit')->get_by_id(1));

    my @iswcs = $c->model('ISWC')->find_by_works(1);
    cmp_set([ map { $_->iswc } @iswcs ], [ ]);
};

test 'Old edit work edits to add ISWCs still pass (conflict)' => sub {
    my $test = shift;
    my $c = $test->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, '51546e7c-b11d-410e-a0ff-6c88aa91f5ac', 'Work');
        INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-110.986.678-6');
        INSERT INTO edit (expire_time, id, editor, type, status)
            VALUES (now(), 1, 1, 42, 1);
        INSERT INTO edit_data (edit, data)
            VALUES (1, '{"entity":{"name":"Work","id":1},"new":{"iswc":"T-910.986.678-6"},"old":{"iswc":null}}');
        SQL

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
    languages => [145],
);

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

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
$c->model('Language')->load_for_works($work);
is($work->name, 'Edited name');
is($work->comment, 'Edited comment');
is($work->type_id, 1);
is($work->languages->[0]->language_id, 145);
is($work->edits_pending, 0);

};

test 'Adding a work language is an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('Language')->load_for_works($work);

    my $edit = create_edit($c, $work, languages => [145]);

    ok(!$edit->is_open);
};

test 'Changing work language is not an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');
    $c->sql->do('INSERT INTO work_language (work, language) VALUES (1, 145)');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('Language')->load_for_works($work);

    my $edit = create_edit($c, $work, languages => []);

    ok($edit->is_open);
    accept_edit($c, $edit);
};

test 'Adding first work attributes is an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);

    my $edit = create_edit(
        $c,
        $work,
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 13,
                attribute_text => undef,
            },
            {
                attribute_type_id => 6,
                attribute_text => 'Attr value',
                attribute_value_id => undef
            }
        ]
    );

    ok(!$edit->is_open);
};

test 'Adding first work attribute of a kind is an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');
    $c->sql->do('INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value) VALUES (1, 1, 1, 13)');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);

    create_edit(
        $c, $c->model('Work')->get_by_id(1),
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 13,
                attribute_text => undef,
            }
        ]
    );

    my $edit = create_edit(
        $c,
        $work,
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 13,
                attribute_text => undef,
            },
            {
                attribute_type_id => 6,
                attribute_text => 'Attr value',
                attribute_value_id => undef
            }
        ]
    );

    ok(!$edit->is_open);
};

test 'Adding work attribute of existing kind is not an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');
    $c->sql->do('INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value) VALUES (1, 1, 1, 13)');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);

    my $edit = create_edit(
        $c,
        $work,
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 13,
                attribute_text => undef,
            },
            {
                attribute_type_id => 1,
                attribute_value_id => 33,
                attribute_text => undef,
            }
        ]
    );

    ok($edit->is_open);
    accept_edit($c, $edit);
};

test 'Changing work attribute is not an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');
    $c->sql->do('INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value) VALUES (1, 1, 1, 13)');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);

    my $edit = create_edit(
        $c,
        $work,
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 33,
                attribute_text => undef,
            }
        ]
    );

    ok($edit->is_open);
    accept_edit($c, $edit);
};

test 'Deleting work attribute is not an auto-edit for non-auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');
    $c->sql->do('INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value) VALUES (1, 1, 1, 13)');

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);

    my $edit = create_edit(
        $c,
        $work,
        attributes => []
    );

    ok($edit->is_open);
    accept_edit($c, $edit);
};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work_attributes');

    my $edit_1 = create_edit(
        $c,
        $c->model('Work')->get_by_id(1),
        name => 'Awesome work is awesome',
        attributes => [
            {
                attribute_type_id => 1,
                attribute_value_id => 13,
                attribute_text => undef,
            },
            {
                attribute_type_id => 6,
                attribute_text => 'Attr value',
                attribute_value_id => undef
            }
        ],
    );

    is exception { $edit_1->accept }, undef, 'accepted edit 1';

    my $edit_2 = create_edit(
        $c,
        $c->model('Work')->get_by_id(1),
        name => 'Awesome work',
        attributes => [
            {
                attribute_type_id => 6,
                attribute_text => 'Attr value',
                attribute_value_id => undef
            }
        ],
    );

    is exception { $edit_2->accept }, undef, 'accepted edit 2';

    my $work = $c->model('Work')->get_by_id(1);
    $c->model('WorkAttribute')->load_for_works($work);
    is($work->name, 'Awesome work', 'work renamed');
    is($work->all_attributes, 2, 'Work has two attributes');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

    my $edit_1 = create_edit(
        $c,
        $c->model('Work')->get_by_id(1),
        name => 'A',
    );

    my $edit_2 = create_edit(
        $c,
        $c->model('Work')->get_by_id(1),
        name => 'B',
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $work = $c->model('Work')->get_by_id(1);
    is($work->name, 'A', 'work renamed');
};

sub create_edit {
    my ($c, $work, %args) = @_;
    $args{attributes} //= [];
    $args{languages} //= [];
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        to_edit => $work,
        %args,
    );
}

sub is_unchanged {
    my $work = shift;
    is($work->name, 'Traits (remix)');
    is($work->comment, '');
    is($work->type_id, undef);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
