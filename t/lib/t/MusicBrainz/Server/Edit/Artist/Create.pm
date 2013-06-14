package t::MusicBrainz::Server::Edit::Artist::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Create }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+gender');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE artist CASCADE;
    INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834');
    INSERT INTO editor (id, name, password, ha1) VALUES (4, 'modbot', '{CLEARTEXT}pass', 'a359885742ca76a15d93724f1a205cc7');
SQL

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_CREATE,
    name => 'Junior Boys',
    gender_id => 1,
    comment => 'Canadian electronica duo',
    editor_id => 1,
    begin_date => { 'year' => 1981, 'month' => 5 },
    ended => 1,
    ipi_codes => [ ],
    isni_codes => [ ],
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');

ok(defined $edit->artist_id, 'edit should store the artist id');

my ($edits, $hits) = $c->model('Edit')->find({ artist => $edit->artist_id }, 10, 0);
is($edits->[0]->id, $edit->id, "Edit IDs match between edit and ->find");

my $artist = $c->model('Artist')->get_by_id($edit->artist_id);
ok(defined $artist, "Artist was actually created.");
is($artist->name, 'Junior Boys', "Name is correct in created artist.");
is($artist->gender_id, 1, "Gender ID is correct in created artist.");
is($artist->comment, 'Canadian electronica duo', "Comment is correct in created artist.");
is($artist->begin_date->format, "1981-05", "Begin date is correct in created artist.");
is($artist->ended, 1, "Has 'ended' set on created artist.");

my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id($artist->id);
is(scalar @$ipi_codes, 0, "Artist has no ipi codes");

my $isni_codes = $c->model('Artist')->isni->find_by_entity_id($artist->id);
is(scalar @$isni_codes, 0, "Artist has no isni codes");

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);

is($edit->display_data->{name}, 'Junior Boys', "Name is correct in display data.");
is($edit->display_data->{gender}->{name}, 'Male', "Gender is correct in display data.");
is($edit->display_data->{comment}, 'Canadian electronica duo', "Comment is correct in display data.");
is($edit->display_data->{begin_date}->format, "1981-05", "Begin date is correct in display data." );
is($edit->display_data->{ended}, 1, "Has 'ended' set in display data." );

is($edit->status, $STATUS_APPLIED, 'add artist edits should be autoedits');
is($artist->edits_pending, 0, 'add artist edits should be autoedits');

};

1;
