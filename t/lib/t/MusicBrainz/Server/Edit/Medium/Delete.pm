package t::MusicBrainz::Server::Edit::Medium::Delete;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Medium::Delete }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');

my $edit = _create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Delete');

# Make sure we can load the artist
my $medium = $c->model('Medium')->get_by_id(1);
is($medium->edits_pending, 1);

my $release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);
$medium = $c->model('Medium')->get_by_id(1);
ok(defined $medium);
is($medium->edits_pending, 0);
$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 0);

# Test accepting the edit
$edit = _create_edit($c, );
accept_edit($c, $edit);
$medium = $c->model('Medium')->get_by_id(1);
ok(!defined $medium);
$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 0);

};

test 'Deleting a medium will also delete its tracks' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO track (id, gid, name, medium, recording, artist_credit, position, number)
    VALUES (1, '15d6a884-0274-486c-81fe-94ff57b8cf36', 1, 1, 1, 1, 1, 'A1'),
           (2, '03d0854f-6053-416c-a67f-8c79a796ed39', 1, 1, 1, 1, 2, 'A2');
EOSQL

    my $edit = _create_edit($c);
    accept_edit($c, $edit);

    is ($c->model('Track')->get_by_id(1), undef, 'Track with row id 1 has been deleted');
    is ($c->model('Track')->get_by_id(2), undef, 'Track with row id 1 has been deleted');
};

sub _create_edit {
    my $c = shift;
    my $medium = $c->model('Medium')->get_by_id(1);
    return $c->model('Edit')->create(
        edit_type => $EDIT_MEDIUM_DELETE,
        medium => $medium,
        editor_id => 1
    );
}

1;
