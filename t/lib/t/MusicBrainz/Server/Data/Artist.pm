package t::MusicBrainz::Server::Data::Artist;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Artist;

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Search;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_artist');

my $sql = $test->c->sql;
my $raw_sql = $test->c->raw_sql;
$sql->begin;
$raw_sql->begin;

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);
does_ok($artist_data, 'MusicBrainz::Server::Data::Role::Editable');
memory_cycle_ok($artist_data, 'new artist data does not have memory cycles');

# ----
# Test fetching artists:

# An artist with all attributes populated
my $artist = $artist_data->get_by_id(1);
is ( $artist->id, 1 );
is ( $artist->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $artist->name, "Test Artist" );
is ( $artist->sort_name, "Artist, Test" );
is ( $artist->begin_date->year, 2008 );
is ( $artist->begin_date->month, 1 );
is ( $artist->begin_date->day, 2 );
is ( $artist->end_date->year, 2009 );
is ( $artist->end_date->month, 3 );
is ( $artist->end_date->day, 4 );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, 'Yet Another Test Artist' );
is ( $artist->ipi_code, '00014107338' );
memory_cycle_ok($artist_data, 'artist data does not leak after get_by_id');
memory_cycle_ok($artist, 'artist entity has no cycles after get_by_id');

# Test loading metadata
$artist_data->load_meta($artist);
is ( $artist->rating, 70 );
is ( $artist->rating_count, 4 );
isnt ( $artist->last_updated, undef );
memory_cycle_ok($artist_data, 'artist data does not leak after load_meta');
memory_cycle_ok($artist, 'artist entity has no cycles after load_meta');

# An artist with the minimal set of required attributes
$artist = $artist_data->get_by_id(2);
is ( $artist->id, 2 );
is ( $artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $artist->name, "Minimal Artist" );
is ( $artist->sort_name, "Minimal Artist" );
is ( $artist->begin_date->year, undef );
is ( $artist->begin_date->month, undef );
is ( $artist->begin_date->day, undef );
is ( $artist->end_date->year, undef );
is ( $artist->end_date->month, undef );
is ( $artist->end_date->day, undef );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, undef );
is ( $artist->ipi_code, undef );
memory_cycle_ok($artist_data, 'artist data does not leak after get_by_id');
memory_cycle_ok($artist, 'artist entity has no cycles after get_by_id');

# ---
# Test annotations

# Fetching annotations
my $annotation = $artist_data->annotation->get_latest(1);
like ( $annotation->text, qr/Test annotation 1/ );

memory_cycle_ok($artist_data, 'artist data does not leak after get_latest annotation');
memory_cycle_ok($annotation, 'annotation entity has no cycles after get_latest annotation');

# Merging annotations
$artist_data->annotation->merge(2, 1);
$annotation = $artist_data->annotation->get_latest(1);
ok(!defined $annotation);

$annotation = $artist_data->annotation->get_latest(2);
like ( $annotation->text, qr/Test annotation 1/ );

memory_cycle_ok($annotation, 'annotation entity has no cycles after get_latest annotation');
memory_cycle_ok($artist_data, 'artist data does not leak after merging annotations');

TODO: {
    local $TODO = 'Merging annotations should concatenate or combine them';
    like($annotation->text, qr/Test annotation 1.*Test annotation 7/s);
}

# Deleting annotations
$artist_data->annotation->delete(2);
$annotation = $artist_data->annotation->get_latest(2);
ok(!defined $annotation);

memory_cycle_ok($artist_data, 'artist data does not leak after deleting annotations');

$sql->commit;
$raw_sql->commit;

# ---
# Searching for artists
my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my ($results, $hits) = $search->search("artist", "test", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Test Artist" );
is( $results->[0]->entity->sort_name, "Artist, Test" );

memory_cycle_ok($results, 'search results do not leak after searching for artists');

$sql->begin;
$raw_sql->begin;

# ---
# Find/insert artist names
my %names = $artist_data->find_or_insert_names('Test Artist', 'Minimal Artist',
                                               'Massive Attack');
is(keys %names, 3);
is($names{'Test Artist'}, 1);
is($names{'Minimal Artist'}, 3);
ok($names{'Massive Attack'} > 3);

memory_cycle_ok($artist_data, 'artist data does not leak after find_or_insert_names');

# ---
# Creating new artists
$artist = $artist_data->insert({
        name => 'New Artist',
        sort_name => 'Artist, New',
        comment => 'Artist comment',
        country_id => 1,
        type_id => 1,
        gender_id => 1,
        begin_date => { year => 2000, month => 1, day => 2 },
        end_date => { year => 1999, month => 3, day => 4 },
        ipi_code => '00014107339',
    });
isa_ok($artist, 'MusicBrainz::Server::Entity::Artist');
ok($artist->id > 2);
memory_cycle_ok($artist_data, 'artist data does not leak after insert');
memory_cycle_ok($artist, 'artist entity from insert does not leak');

$artist = $artist_data->get_by_id($artist->id);
is($artist->name, 'New Artist');
is($artist->sort_name, 'Artist, New');
is($artist->begin_date->year, 2000);
is($artist->begin_date->month, 1);
is($artist->begin_date->day, 2);
is($artist->end_date->year, 1999);
is($artist->end_date->month, 3);
is($artist->end_date->day, 4);
is($artist->type_id, 1);
is($artist->gender_id, 1);
is($artist->country_id, 1);
is($artist->comment, 'Artist comment');
is($artist->ipi_code, '00014107339');
ok(defined $artist->gid);

# ---
# Updating artists
$artist_data->update($artist->id, {
        name => 'Updated Artist',
        sort_name => 'Artist, Updated',
        begin_date => { year => 1995, month => 4, day => 22 },
        end_date => { year => 1990, month => 6, day => 17 },
        type_id => 2,
        gender_id => 2,
        country_id => 2,
        comment => 'Updated comment',
        ipi_code => '00014107341',
    });

memory_cycle_ok($artist_data, 'artist data does not leak ater update');

$artist = $artist_data->get_by_id($artist->id);
is($artist->name, 'Updated Artist');
is($artist->sort_name, 'Artist, Updated');
is($artist->begin_date->year, 1995);
is($artist->begin_date->month, 4);
is($artist->begin_date->day, 22);
is($artist->end_date->year, 1990);
is($artist->end_date->month, 6);
is($artist->end_date->day, 17);
is($artist->type_id, 2);
is($artist->gender_id, 2);
is($artist->country_id, 2);
is($artist->comment, 'Updated comment');
is($artist->ipi_code, '00014107341');

$artist_data->update($artist->id, {
        type_id => undef,
    });
$artist = $artist_data->get_by_id($artist->id);
is($artist->type_id, undef);

$artist_data->delete($artist->id);
memory_cycle_ok($artist_data, 'artist data does not leak after delete');
$artist = $artist_data->get_by_id($artist->id);
ok(!defined $artist);

# ---
# Gid redirections
$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
is ( $artist->id, 1 );
memory_cycle_ok($artist_data, 'artist data does not leak after get_by_gid');
memory_cycle_ok($artist, 'artist entity does not leak after get_by_gid');

$artist_data->remove_gid_redirects(1);
$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
ok(!defined $artist);
memory_cycle_ok($artist_data, 'artist data does not leak after remove_gid_redirects');

$artist_data->add_gid_redirects(
    '20bb5c20-5dbf-11de-8a39-0800200c9a66' => 1,
    '2adff2b0-5dbf-11de-8a39-0800200c9a66' => 2,
);

memory_cycle_ok($artist_data, 'artist data does not leak after add_gid_redirects');

$artist = $artist_data->get_by_gid('20bb5c20-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 1);

$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 2);

$artist_data->update_gid_redirects(1, 2);

memory_cycle_ok($artist_data, 'artist data does not leak after update_gid_redirects');

$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 1);

$artist_data->merge(1, [ 2 ]);
memory_cycle_ok($artist_data, 'artist data does not leak after merge');
$artist = $artist_data->get_by_id(2);
ok(!defined $artist);

$artist = $artist_data->get_by_id(1);
ok(defined $artist);
is($artist->name, 'Test Artist');

# ---
# Checking when an artist is in use or not

ok($artist_data->can_delete(1));
memory_cycle_ok($artist_data, 'artist data does not leak after can_delete');

my $ac = $test->c->model('ArtistCredit')->find_or_insert({ artist => 1, name => 'Calibre' });
ok($artist_data->can_delete(1));

my $rec = $test->c->model('Recording')->insert({
    name => "Love's Too Tight Too Mention",
    artist_credit => $ac,
    comment => 'Drum & bass track',
});

ok(!$artist_data->can_delete(1));

$sql->commit;
$raw_sql->commit;

};

1;
