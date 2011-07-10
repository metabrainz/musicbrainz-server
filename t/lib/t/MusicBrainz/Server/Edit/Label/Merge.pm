package t::MusicBrainz::Server::Edit::Label::Merge;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Merge; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ label => [2, 3] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $l1 = $c->model('Label')->get_by_id(2);
my $l2 = $c->model('Label')->get_by_id(3);
is($l1->edits_pending, 1);
is($l2->edits_pending, 1);

reject_edit($c, $edit);

$l1 = $c->model('Label')->get_by_id(2);
$l2 = $c->model('Label')->get_by_id(3);
is($l1->edits_pending, 0);
is($l2->edits_pending, 0);

$edit = create_edit($c);
accept_edit($c, $edit);

$l1 = $c->model('Label')->get_by_id(2);
$l2 = $c->model('Label')->get_by_id(3);
ok(!defined $l1);
ok(defined $l2);

is($l2->edits_pending, 0);

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_MERGE,
        editor_id => 1,
        old_entities => [ { id => 2, name => 'Old Artist' } ],
        new_entity => { id => 3, name => 'Old Label' },
    );
}

1;
