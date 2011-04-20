package t::MusicBrainz::Server::Edit::Artist::Merge;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Merge }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Non-existant merge target' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password) VALUES
    (1, 'editor', 'password'), (4, 'ModBot', 'mod');
EOSQL

    my $edit = create_edit($c);
    $c->model('Artist')->delete(2);

    accept_edit($c, $edit);

    is($edit->status, $STATUS_FAILEDDEP);
    ok(defined $c->model('Artist')->get_by_id(1));
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ artist => [1, 2] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $a1 = $c->model('Artist')->get_by_id(1);
my $a2 = $c->model('Artist')->get_by_id(2);
is($a1->edits_pending, 1);
is($a2->edits_pending, 1);

reject_edit($c, $edit);

$a1 = $c->model('Artist')->get_by_id(1);
$a2 = $c->model('Artist')->get_by_id(2);
is($a1->edits_pending, 0);
is($a2->edits_pending, 0);

$edit = create_edit($c);
accept_edit($c, $edit);

$a1 = $c->model('Artist')->get_by_id(1);
$a2 = $c->model('Artist')->get_by_id(2);
ok(!defined $a1);
ok(defined $a2);

is($a2->edits_pending, 0);

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_MERGE,
        editor_id => 1,
        old_entities => [ { id => 1, name => 'Old Artist' } ],
        new_entity => { id => 2, name => 'New Artist' },
        rename => 0
    );
}

1;
