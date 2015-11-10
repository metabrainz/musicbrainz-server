package t::MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::DeleteReleaseLabel }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_DELETERELEASELABEL
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+delete_rl');

    my $edit = create_edit($c, 1);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::DeleteReleaseLabel');

    my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
    is(scalar @$edits, 1);
    is($edits->[0]->id, $edit->id);

    my $release = $c->model('Release')->get_by_id(1);
    is($release->edits_pending, 1);

    reject_edit($c, $edit);

    $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    is($release->label_count, 3);
    is($release->labels->[0]->id, 1);
    is($release->labels->[1]->id, 2);
    is($release->labels->[2]->id, 3);

    $edit = create_edit($c, 1);
    accept_edit($c, $edit);

    $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    is($release->label_count, 2);
    is($release->labels->[0]->id, 2);
};

test 'Displays correctly following label merges' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $release_label = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_DELETERELEASELABEL,
        editor_id => 1,
        release_label => $release_label,
    );

    # Assert we're testing what we think we're testing, in case the data changes...
    is($release_label->label_id, 2);
    $c->model('Label')->merge(3, 2);

    # Check that the new label loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{label}->id, 3);
};

test 'Displays correctly following release merges' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $release_label = $c->model('ReleaseLabel')->get_by_id(1);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_DELETERELEASELABEL,
        editor_id => 1,
        release_label => $c->model('ReleaseLabel')->get_by_id(1),
    );

    is($release_label->release_id, 1);
    $c->model('Release')->merge(
        new_id => 2,
        old_ids => [1],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
    );

    # Check that the new release loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{release}->id, 2);
};

test 'Loads correctly when there\'s just a catalog number' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do(<<'EOSQL');
INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (2, 1, NULL, 'ABC-456');
EOSQL

    my $edit = create_edit($c, 2);
    $c->model('Edit')->load_all($edit);
    ok(!exists $edit->display_data->{label});
};

sub create_edit {
    my ($c, $id) = @_;

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_DELETERELEASELABEL,
        editor_id => 1,
        release_label => $c->model('ReleaseLabel')->get_by_id($id),
        privileges => $UNTRUSTED_FLAG,
    );
}

1;
