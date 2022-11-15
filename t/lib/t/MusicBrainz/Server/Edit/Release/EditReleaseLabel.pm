package t::MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;
use Test::Deep qw( cmp_deeply ignore );

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::EditReleaseLabel }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_RELEASE_ADDRELEASELABEL
    $STATUS_APPLIED
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);

    my $edit = create_edit(
        $c,
        $rl,
        label => $c->model('Label')->get_by_id(3),
        catalog_number => 'FOO',
        privileges => $UNTRUSTED_FLAG,
    );
    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditReleaseLabel');

    my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
    is(scalar @$edits, 1);
    is($edits->[0]->id, $edit->id);

    my $release = $c->model('Release')->get_by_id(1);
    is($release->edits_pending, 1);

    $rl = $c->model('ReleaseLabel')->get_by_id(1);
    is($rl->label_id, 2);
    is($rl->catalog_number, 'ABC-123');

    reject_edit($c, $edit);

    $rl = $c->model('ReleaseLabel')->get_by_id(1);
    is($rl->label_id, 2);
    is($rl->catalog_number, 'ABC-123');

    $release = $c->model('Release')->get_by_id($rl->release_id);
    is($release->edits_pending, 0);

    $edit = create_edit(
        $c,
        $rl,
        label => $c->model('Label')->get_by_id(3),
        catalog_number => 'FOO',
    );

    $rl = $c->model('ReleaseLabel')->get_by_id(1);
    is($rl->label_id, 3);
    is($rl->catalog_number, 'FOO');

    $release = $c->model('Release')->get_by_id($rl->release_id);
    is($release->edits_pending, 0);
};

test 'Editing the label can fail as a conflict' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit1 = create_edit($c, $rl, label => $c->model('Label')->get_by_id(3), privileges => $UNTRUSTED_FLAG);
    my $edit2 = create_edit($c, $rl, label => undef, privileges => $UNTRUSTED_FLAG);

    ok !exception { $edit1->accept };
    ok  exception { $edit2->accept };
};

test 'Editing the catalog number can fail as a conflict' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit1 = create_edit($c, $rl, catalog_number => 'Woof!', privileges => $UNTRUSTED_FLAG);
    my $edit2 = create_edit($c, $rl, catalog_number => 'Meow!', privileges => $UNTRUSTED_FLAG);

    ok !exception { $edit1->accept };
    ok  exception { $edit2->accept };
};

test 'Editing to remove the label works correctly' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);

    ok !exception {
        create_edit($c, $rl, label => undef);
    };
};

test 'Editing to remove the catalog number works correctly' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);

    ok !exception {
        create_edit($c, $rl, catalog_number => undef);
    };
};

test 'Parallel edits that dont conflict merge' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $expected_label_id = 3;
    my $expected_cat_no = 'Woof!';

    {
        my $rl = $c->model('ReleaseLabel')->get_by_id(1);
        my $edit1 = create_edit(
            $c,
            $rl,
            catalog_number => $expected_cat_no,
            privileges => $UNTRUSTED_FLAG,
        );
        my $edit2 = create_edit(
            $c,
            $rl,
            label => $c->model('Label')->get_by_id($expected_label_id),
            privileges => $UNTRUSTED_FLAG,
        );

        ok !exception { $edit1->accept };
        ok !exception { $edit2->accept };
    }

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    is($rl->label_id, 3);
    is($rl->catalog_number, 'Woof!');
};

test 'Editing a non-existent release label fails' => sub {
    my $test = shift;
    my $c = $test->c;

    my $model = $c->model('ReleaseLabel');
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $model->get_by_id(1);
    my $edit = create_edit(
        $c,
        $rl,
        label => $c->model('Label')->get_by_id(3),
        privileges => $UNTRUSTED_FLAG,
    );

    $model->delete(1);

    isa_ok exception { $edit->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Prevents initializing an edit with a duplicate label/catalog number pair' => sub {
    my ($test) = @_;

    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $label = $c->model('Label')->get_by_id(2);

    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $label,
        catalog_number => 'ABC-456',
    );

    like exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
            editor_id => 1,
            release_label => $c->model('ReleaseLabel')->get_by_id(1),
            label => $label,
            catalog_number => 'ABC-456',
        );
    }, qr/The label and catalog number in this edit already exist on the release./;
};

test 'Prevents applying an edit with a duplicate label/catalog number pair' => sub {
    my ($test) = @_;

    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $label = $c->model('Label')->get_by_id(2);

    my $edit_edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $c->model('ReleaseLabel')->get_by_id(1),
        label => $label,
        catalog_number => 'ABC-456',
        privileges => $UNTRUSTED_FLAG,
    );

    # Another edit adds the same release label before the first edit is applied.
    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $label,
        catalog_number => 'ABC-456',
    );

    like exception {
        $edit_edit->accept;
    }, qr/The label and catalog number in this edit already exist on the release./;
};

test 'Can apply after labels are merged' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $label = $c->model('Label')->get_by_id(4);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $c->model('ReleaseLabel')->get_by_id(1),
        label => $label,
        catalog_number => 'ABC-456',
        privileges => $UNTRUSTED_FLAG,
    );

    ok($edit->is_open);
    $c->model('Label')->merge(3, 4);
    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED);

    # Check that the new label loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{label}{new}{id}, 3);
};

test 'Can apply after release is merged' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $label = $c->model('Label')->get_by_id(4);
    my $release_label = $c->model('ReleaseLabel')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $release_label,
        label => $label,
        catalog_number => 'ABC-456',
        privileges => $UNTRUSTED_FLAG,
    );

    ok($edit->is_open);
    is($release_label->release_id, 1);

    $c->model('Release')->merge(
        new_id => 2,
        old_ids => [1],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
    );

    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED);

    # Check that the new release loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{release}{id}, 2);
};

test 'Can add a label where one is currently missing' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<~'SQL');
        INSERT INTO release_label (id, release, label, catalog_number)
            VALUES (2, 1, NULL, 'ABC-456');
        SQL

    my $edit = create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        label => $c->model('Label')->get_by_id(4),
    );

    ok(!$edit->is_open);
    is($edit->status, $STATUS_APPLIED);
};

test q(Edits that only change the catalog number show up in the label's edit history (MBS-8533)) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<~'SQL');
        INSERT INTO release_label (id, release, label, catalog_number)
            VALUES (2, 1, 2, 'FOO');
        SQL

    my $edit = create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        catalog_number => 'BAR',
    );

    ok($c->sql->select_single_value('SELECT 1 FROM edit_label WHERE edit = ?', $edit->id));
};

test 'Edits that only change the catalog number still store and display the label' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<~'SQL');
        INSERT INTO release_label (id, release, label, catalog_number)
            VALUES (2, 1, 2, 'FOO');
        SQL

    my $edit = create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        catalog_number => 'BAR',
    );

    cmp_deeply($edit->data, {
        new => {
            catalog_number => 'BAR',
        },
        old => {
            catalog_number => 'FOO',
            label => { gid => 'f2a9a3c0-72e3-11de-8a39-0800200c9a66', id => 2, name => 'Label' },
        },
        release => ignore(),
        release_label_id => 2,
    });

    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{label}{old}{gid}, 'f2a9a3c0-72e3-11de-8a39-0800200c9a66');
};

test 'Edits that only change the label still store and display the catalog number (MBS-8534)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<~'SQL');
        INSERT INTO release_label (id, release, label, catalog_number)
            VALUES (2, 1, 2, 'FOO');
        SQL

    my $edit = create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        label => $c->model('Label')->get_by_id(3)
    );

    cmp_deeply($edit->data, {
        new => {
            label => { gid => '7214c460-97d7-11de-8a39-0800200c9a66', id => 3, name => 'Label' },
        },
        old => {
            catalog_number => 'FOO',
            label => { gid => 'f2a9a3c0-72e3-11de-8a39-0800200c9a66', id => 2, name => 'Label' },
        },
        release => ignore(),
        release_label_id => 2,
    });

    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{catalog_number}{old}, 'FOO');
};

sub create_edit {
    my ($c, $release_label, %args) = @_;

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $release_label,
        %args
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
