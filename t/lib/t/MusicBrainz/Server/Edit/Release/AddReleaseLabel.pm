package t::MusicBrainz::Server::Edit::Release::AddReleaseLabel;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::AddReleaseLabel }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_ADDRELEASELABEL
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::AddReleaseLabel');

my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
is(scalar @$edits, 1);
is($edits->[0]->id, $edit->id);

my $release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1, 'Release has edits pending');

$c->model('ReleaseLabel')->load($release);
is($release->label_count, 2, 'Release now has an extra label');
is($release->labels->[0]->id, 1, 'Release label id is 1');
is($release->labels->[1]->catalog_number, 'AVCD-51002', 'Has new release label');

reject_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 1, 'Release still has one label after rejected edit');
is($release->labels->[0]->id, 1, 'Release label id is 1');

$edit = create_edit($c);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 2, 'Release has two labels after accepting edit');
is($release->labels->[0]->id, 1, 'First release label is unchanged');
is($release->labels->[1]->label_id, 2, 'Second release label has label_id 1');
is($release->labels->[1]->catalog_number, 'AVCD-51002', 'Second release label has catalog number AVCD-51002');

};

test 'Inserting just a catalog number' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    {
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
            editor_id => 1,
            release => $c->model('Release')->get_by_id(1),
            catalog_number => 'AVCD-51002',
            privileges => $UNTRUSTED_FLAG,
        );

        $edit = $c->model('Edit')->get_by_id_and_lock($edit->id);
        $c->model('Edit')->reject($edit, 8);

        my $release = $c->model('Release')->get_by_id(1);
        $c->model('ReleaseLabel')->load($release);
        is($release->label_count, 1, 'Release has one label after rejecting edit');
        is($release->labels->[0]->id, 1, 'First release label is unchanged');
    };

    {
        $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
            editor_id => 1,
            release => $c->model('Release')->get_by_id(1),
            catalog_number => 'AVCD-51002',
        );

        my $release = $c->model('Release')->get_by_id(1);
        $c->model('ReleaseLabel')->load($release);
        is($release->label_count, 2, 'Release has two labels after accepting edit');
        is($release->labels->[0]->id, 1, 'First release label is unchanged');
        is($release->labels->[1]->label_id, undef, 'Second release label has no label id');
        is($release->labels->[1]->catalog_number, 'AVCD-51002', 'Second release label has catalog number AVCD-51002');
    }
};

test 'Prevents initializing an edit with a duplicate label/catalog number pair' => sub {
    my ($test) = @_;

    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    like exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
            editor_id => 1,
            release => $c->model('Release')->get_by_id(1),
            label => $c->model('Label')->get_by_id(2),
            catalog_number => 'ABC-123',
        );
    }, qr/The label and catalog number in this edit already exist on the release./;
};

test 'Displays correctly following label merges' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $c->model('Label')->get_by_id(4),
        catalog_number => 'ABC-456',
    );

    $c->model('Label')->merge(3, 4);

    # Check that the new label loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{label}{id}, 3);
};

test 'Displays correctly following release merges' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $c->model('Label')->get_by_id(4),
        catalog_number => 'ABC-456',
    );

    $c->model('Release')->merge(
        new_id => 2,
        old_ids => [1],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
    );

    # Check that the new release loads correctly.
    $c->model('Edit')->load_all($edit);
    is($edit->display_data->{release}{id}, 2);
};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $c->model('Label')->get_by_id(2),
        catalog_number => 'AVCD-51002',
        privileges => $UNTRUSTED_FLAG,
    );
}

1;
