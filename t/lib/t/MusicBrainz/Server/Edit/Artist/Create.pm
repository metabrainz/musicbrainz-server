package t::MusicBrainz::Server::Edit::Artist::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Create }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+gender');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE artist CASCADE;
SQL

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_CREATE,
    name => 'Junior Boys',
    gender_id => 1,
    comment => 'Canadian electronica duo',
    editor_id => 1,
    begin_date => { 'year' => 1981, 'month' => 5 },
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');

ok(defined $edit->artist_id, 'edit should store the artist id');

my ($edits, $hits) = $c->model('Edit')->find({ artist => $edit->artist_id }, 10, 0);
is($edits->[0]->id, $edit->id);

my $artist = $c->model('Artist')->get_by_id($edit->artist_id);
ok(defined $artist);
is($artist->name, 'Junior Boys');
is($artist->gender_id, 1);
is($artist->comment, 'Canadian electronica duo');
is($artist->begin_date->format, "1981-05" );

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);

is($edit->display_data->{name}, 'Junior Boys');
is($edit->display_data->{gender}->{name}, 'Male');
is($edit->display_data->{comment}, 'Canadian electronica duo');
is($edit->display_data->{begin_date}->format, "1981-05" );

is($edit->status, $STATUS_APPLIED, 'add artist edits should be autoedits');
is($artist->edits_pending, 0, 'add artist edits should be autoedits');

};

1;
