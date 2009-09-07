use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::EditReleaseLabel' }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rl = $c->model('ReleaseLabel')->get_by_id(1);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditReleaseLabel');

my ($edits) = $c->model('Edit')->find({ release => 1 }, 10, 0);
is(scalar @$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
ok(defined $edit->release);
is($edit->release->id, $edit->release_id);
is($edit->release_id, $rl->release_id);
is($edit->release->edits_pending, 1);

$rl = $c->model('ReleaseLabel')->get_by_id(1);
is($rl->label_id, 1);
is($rl->catalog_number, 'ABC-123');

$c->model('Edit')->reject($edit);

$rl = $c->model('ReleaseLabel')->get_by_id(1);
is($rl->label_id, 1);
is($rl->catalog_number, 'ABC-123');

my $release = $c->model('Release')->get_by_id($rl->release_id);
is($release->edits_pending, 0);

$edit = create_edit();
$c->model('Edit')->accept($edit);

$rl = $c->model('ReleaseLabel')->get_by_id(1);
is($rl->label_id, 2);
is($rl->catalog_number, 'FOO');

$release = $c->model('Release')->get_by_id($rl->release_id);
is($release->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $rl,
        label_id => 2,
        catalog_number => 'FOO',
    );
}
