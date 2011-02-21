package t::MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::DeleteReleaseLabel }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+delete_rl');

my $edit = create_edit($c);
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

$edit = create_edit($c);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 2);
is($release->labels->[0]->id, 2);

};

sub create_edit {
    my $c = shift;
    my $release_label = $c->model('ReleaseLabel')->get_by_id(1);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_DELETERELEASELABEL,
        editor_id => 1,
        release_label => $release_label
    );
}

1;
