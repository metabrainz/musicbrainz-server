package t::MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::EditReleaseLabel }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_RELEASE_ADDRELEASELABEL
    $STATUS_APPLIED
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);

    my $edit = create_edit($c, $rl);
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

    $edit = create_edit($c, $rl);
    accept_edit($c, $edit);

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
    my $edit1 = _create_edit($c, $rl, label => $c->model('Label')->get_by_id(3));
    my $edit2 = _create_edit($c, $rl, label => undef);

    ok !exception { $edit1->accept };
    ok  exception { $edit2->accept };
};

test 'Editing the catalog number can fail as a conflict' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit1 = _create_edit($c, $rl, catalog_number => 'Woof!');
    my $edit2 = _create_edit($c, $rl, catalog_number => 'Meow!');

    ok !exception { $edit1->accept };
    ok  exception { $edit2->accept };
};

test 'Editing to remove the label works correctly' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit1 = _create_edit($c, $rl, label => undef);

    ok !exception { $edit1->accept };
};

test 'Editing to remove the catalog number works correctly' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit1 = _create_edit($c, $rl, catalog_number => undef);

    ok !exception { $edit1->accept };
};

test 'Parallel edits that dont conflict merge' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $expected_label_id = 3;
    my $expected_cat_no = 'Woof!';

    {
        my $rl = $c->model('ReleaseLabel')->get_by_id(1);
        my $edit1 = _create_edit($c, $rl, catalog_number => $expected_cat_no);
        my $edit2 = _create_edit(
            $c, $rl,
            label => $c->model('Label')->get_by_id($expected_label_id)
        );

        ok !exception { $edit1->accept };
        ok !exception { $edit2->accept };
    }

    my $rl = $c->model('ReleaseLabel')->get_by_id(1);
    is($rl->label_id, 3);
    is($rl->catalog_number, 'Woof!');
};

test 'Editing a non-existant release label fails' => sub {
    my $test = shift;
    my $c = $test->c;

    my $model = $c->model('ReleaseLabel');
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $rl = $model->get_by_id(1);
    my $edit = _create_edit($c, $rl, label => $c->model('Label')->get_by_id(3));

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
    );

    # Another edit adds the same release label before the first edit is applied.
    my $add_edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $label,
        catalog_number => 'ABC-456',
    );

    $add_edit->accept;

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
    is($edit->display_data->{label}{new}->id, 3);
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
    is($edit->display_data->{release}->id, 2);
};

test 'Can add a label where one is currently missing' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<'EOSQL');
INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (2, 1, NULL, 'ABC-456');
EOSQL

    my $edit = _create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        label => $c->model('Label')->get_by_id(4),
    );

    ok($edit->is_open);
    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED);
};

test "Edits that only change the catalog number show up in the label's edit history (MBS-8533)" => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<'EOSQL');
INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (2, 1, 2, 'FOO');
EOSQL

    my $edit = _create_edit(
        $c,
        $c->model('ReleaseLabel')->get_by_id(2),
        catalog_number => 'BAR',
    );

    ok($c->sql->select_single_value('SELECT 1 FROM edit_label WHERE edit = ?', $edit->id));
};

sub create_edit {
    my ($c, $rl) = @_;
    return _create_edit(
        $c, $rl,
        label => $c->model('Label')->get_by_id(3),
        catalog_number => 'FOO',
    );
}

sub _create_edit {
    my ($c, $rl, %args) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $rl,
        %args
    );
}

1;
