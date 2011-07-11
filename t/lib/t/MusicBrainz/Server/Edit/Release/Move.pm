package t::MusicBrainz::Server::Edit::Release::Move;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Move };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

# Starting point for releases
my $release_group = $c->model('ReleaseGroup')->get_by_id(2);

my $release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Test editing all possible fields
my $edit = create_edit($c, $release, $release_group);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Move');

my ($edits) = $c->model('Edit')->find({ release => $release->id }, 10, 0);
is($edits->[0]->id, $edit->id);

$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);
is_unchanged($release);

reject_edit($c, $edit);
$release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Accept the edit
$edit = create_edit($c, $release, $release_group);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
is($release->release_group_id, 2);
is($release->edits_pending, 0);

};

test 'Cannot move into a non-existant release group' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

    my $release_group = $c->model('ReleaseGroup')->get_by_id(2);
    my $release = $c->model('Release')->get_by_id(1);

    my $edit = create_edit($c, $release, $release_group);

    $c->model('ReleaseGroup')->delete($release_group->id);

    isa_ok exception { $edit->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub is_unchanged {
    my ($release) = @_;
    is($release->release_group_id, 1);
}

sub create_edit {
    my $c = shift;
    my $release = shift;
    my $release_group = shift;
    $c->model('ReleaseGroup')->load($release);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MOVE,
        editor_id => 1,
        release => $release,
        new_release_group => $release_group
    );
}

1;
