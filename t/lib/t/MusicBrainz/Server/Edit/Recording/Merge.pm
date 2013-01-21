package t::MusicBrainz::Server::Edit::Recording::Merge;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::Merge; }

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ recording => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $r1 = $c->model('Recording')->get_by_id(1);
my $r2 = $c->model('Recording')->get_by_id(2);
is($r1->edits_pending, 1);
is($r2->edits_pending, 1);

reject_edit($c, $edit);

$r1 = $c->model('Recording')->get_by_id(1);
$r2 = $c->model('Recording')->get_by_id(2);
is($r1->edits_pending, 0);
is($r2->edits_pending, 0);

$c->model('Relationship')->load($r1);
$c->model('Relationship')->load($r2);

is ($r1->all_relationships, 1, "Recording 1 has one relationship");
is ($r2->all_relationships, 1, "Recording 2 has one relationship");

$edit = create_edit($c);
accept_edit($c, $edit);

$r1 = $c->model('Recording')->get_by_id(1);
$r2 = $c->model('Recording')->get_by_id(2);
ok(!defined $r1);
ok(defined $r2);

is($r2->edits_pending, 0);

$c->model('Relationship')->load($r2);
is($r2->all_relationships, 1, "Relationships of recordings merged");

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_MERGE,
        editor_id => 1,
        old_entities => [ { id => 1, name => 'Old Recording' } ],
        new_entity => { id => 2, name => 'New Recording' },
    );
}

1;
