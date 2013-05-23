package t::MusicBrainz::Server::Edit::Artist::Merge;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Merge }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Non-existant merge target' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit = create_edit($c);
    $c->model('Artist')->delete(4);

    accept_edit($c, $edit);

    is($edit->status, $STATUS_FAILEDDEP);
    ok(defined $c->model('Artist')->get_by_id(3));
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ artist => [3, 4] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $a1 = $c->model('Artist')->get_by_id(3);
my $a2 = $c->model('Artist')->get_by_id(4);
is($a1->edits_pending, 1);
is($a2->edits_pending, 1);

reject_edit($c, $edit);

$a1 = $c->model('Artist')->get_by_id(3);
$a2 = $c->model('Artist')->get_by_id(4);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit($c);
accept_edit($c, $edit);

$a1 = $c->model('Artist')->get_by_id(3);
$a2 = $c->model('Artist')->get_by_id(4);
ok(!defined $a1);
ok(defined $a2);

is($a2->edits_pending, 0);

my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id($a2->id);
is(scalar @$ipi_codes, 3, "Merged Artist has all ipi codes after accepting edit");

my $isni_codes = $c->model('Artist')->isni->find_by_entity_id($a2->id);
is(scalar @$isni_codes, 4, "Merged Artist has all isni codes after accepting edit");

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_MERGE,
        editor_id => 1,
        old_entities => [ { id => 3, name => 'Old Artist' } ],
        new_entity => { id => 4, name => 'New Artist' },
        rename => 0
    );
}

1;
