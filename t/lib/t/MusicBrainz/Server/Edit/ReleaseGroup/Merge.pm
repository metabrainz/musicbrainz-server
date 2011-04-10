package t::MusicBrainz::Server::Edit::ReleaseGroup::Merge;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Merge }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_merge');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

my ($edits) = $c->model('Edit')->find({ release_group => [1, 2] }, 10, 0);
is($edits->[0]->id, $edit->id);

my $rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
is($rgs->{1}->edits_pending, 1);
is($rgs->{2}->edits_pending, 1);

reject_edit($c, $edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(defined $rgs->{2});

$edit = create_edit($c);
accept_edit($c, $edit);
$rgs = $c->model('ReleaseGroup')->get_by_ids(1, 2);
ok(defined $rgs->{1});
ok(!defined $rgs->{2});

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_MERGE,
        editor_id => 1,
        old_entities => [
            { id => 2, name => 'Old RG 1' }
        ],
        new_entity => { id => 1, name => 'New RG' },
    );
}

1;
