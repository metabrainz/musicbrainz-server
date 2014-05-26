package t::MusicBrainz::Server::Edit::Release::AddReleaseLabel;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::AddReleaseLabel }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADDRELEASELABEL );
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
is($release->label_count, 2, "Release now has an extra label");
is($release->labels->[0]->id, 1, "Release label id is 1");
is($release->labels->[1]->catalog_number, 'AVCD-51002', "Has new release label");

reject_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 1, "Release still has one label after rejected edit");
is($release->labels->[0]->id, 1, "Release label id is 1");

$edit = create_edit($c);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 2, "Release has two labels after accepting edit");
is($release->labels->[0]->id, 1, "First release label is unchanged");
is($release->labels->[1]->label_id, 1, "Second release label has label_id 1");
is($release->labels->[1]->catalog_number, 'AVCD-51002', "Second release label has catalog number AVCD-51002");

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
        );

        $edit = $c->model('Edit')->get_by_id_and_lock($edit->id);
        $c->model('Edit')->reject($edit, 8);

        my $release = $c->model('Release')->get_by_id(1);
        $c->model('ReleaseLabel')->load($release);
        is($release->label_count, 1, "Release has one label after rejecting edit");
        is($release->labels->[0]->id, 1, "First release label is unchanged");
    };

    {
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
            editor_id => 1,
            release => $c->model('Release')->get_by_id(1),
            catalog_number => 'AVCD-51002',
        );

        accept_edit($c, $edit);

        my $release = $c->model('Release')->get_by_id(1);
        $c->model('ReleaseLabel')->load($release);
        is($release->label_count, 2, "Release has two labels after accepting edit");
        is($release->labels->[0]->id, 1, "First release label is unchanged");
        is($release->labels->[1]->label_id, undef, "Second release label has no label id");
        is($release->labels->[1]->catalog_number, 'AVCD-51002', "Second release label has catalog number AVCD-51002");
    }
};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADDRELEASELABEL,
        editor_id => 1,
        release => $c->model('Release')->get_by_id(1),
        label => $c->model('Label')->get_by_id(1),
        catalog_number => 'AVCD-51002',
    );
}

1;
