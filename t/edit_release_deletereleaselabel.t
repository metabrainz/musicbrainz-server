use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::DeleteReleaseLabel' }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+delete_rl');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::DeleteReleaseLabel');

my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
is(scalar @$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
ok(defined $edit->release);
is($edit->release->id, $edit->release_id);
is($edit->release->edits_pending, 1);

$c->model('Edit')->reject($edit);

my $release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 3);
is($release->labels->[0]->id, 1);
is($release->labels->[1]->id, 2);
is($release->labels->[2]->id, 3);

$edit = create_edit();
$c->model('Edit')->accept($edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ReleaseLabel')->load($release);
is($release->label_count, 2);
is($release->labels->[0]->id, 2);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_DELETERELEASELABEL,
        editor_id => 1,
        release_id => 1,
        release_label_id => 1
    );
}
