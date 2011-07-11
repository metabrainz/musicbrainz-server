package t::MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::EditReleaseLabel }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );
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
is($rl->label_id, 1);
is($rl->catalog_number, 'ABC-123');

reject_edit($c, $edit);

$rl = $c->model('ReleaseLabel')->get_by_id(1);
is($rl->label_id, 1);
is($rl->catalog_number, 'ABC-123');

$release = $c->model('Release')->get_by_id($rl->release_id);
is($release->edits_pending, 0);

$edit = create_edit($c, $rl);
accept_edit($c, $edit);

$rl = $c->model('ReleaseLabel')->get_by_id(1);
is($rl->label_id, 2);
is($rl->catalog_number, 'FOO');

$release = $c->model('Release')->get_by_id($rl->release_id);
is($release->edits_pending, 0);

};

sub create_edit {
    my ($c, $rl) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDITRELEASELABEL,
        editor_id => 1,
        release_label => $rl,
        label => $c->model('Label')->get_by_id(2),
        catalog_number => 'FOO',
    );
}

1;
