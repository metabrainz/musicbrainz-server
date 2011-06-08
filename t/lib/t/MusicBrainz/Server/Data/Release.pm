package t::MusicBrainz::Server::Data::Release;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Release;

use MusicBrainz::Server::Constants qw( $QUALITY_UNKNOWN_MAPPED );
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);
memory_cycle_ok($release_data);

my $release = $release_data->get_by_id(1);
is( $release->id, 1, 'get release 1 by id');
is( $release->gid, "f34c079d-374e-4436-9448-da92dedef3ce" );
is( $release->name, "Arrival", 'release is called "Arrival"');
is( $release->artist_credit_id, 1 );
is( $release->release_group_id, 1 );
is( $release->status_id, 1 );
is( $release->packaging_id, 1 );
is( $release->country_id, 1 );
is( $release->script_id, 1 );
is( $release->language_id, 1 );
is( $release->date->year, 2009 );
is( $release->date->month, 5 );
is( $release->date->day, 8 );
is( $release->barcode, "731453398122" );
is( $release->comment, "Comment" );
is( $release->edits_pending, 2 );
is( $release->quality, $QUALITY_UNKNOWN_MAPPED );
memory_cycle_ok($release_data);
memory_cycle_ok($release);

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $test->c);
$release_label_data->load($release);
ok( @{$release->labels} >= 2 );
is( $release->labels->[0]->label_id, 1 );
is( $release->labels->[0]->catalog_number, "ABC-123", 'release has catalog number ABC-123');
is( $release->labels->[1]->label_id, 1 );
is( $release->labels->[1]->catalog_number, "ABC-123-X", 'release also has catalog number ABC-123-X' );
memory_cycle_ok($release_label_data);
memory_cycle_ok($release);

$release = $release_data->get_by_id(2);
is( $release->quality, $QUALITY_UNKNOWN_MAPPED );

my ($releases, $hits) = $release_data->find_by_artist(1, 100);
is( $hits, 6 );
is( scalar(@$releases), 6 );
ok( (grep { $_->id == 1 } @$releases), 'found release by artist');
ok( (grep { $_->id == 2 } @$releases), 'found release by artist');
memory_cycle_ok($release_data);
memory_cycle_ok($releases);

($releases, $hits) = $release_data->find_by_track_artist(3, 100);
is( $hits, 1 );
is( scalar(@$releases), 1 );
ok( (grep { $_->id == 11 } @$releases), 'found release 11' );
ok( (grep { $_->id == 10 } @$releases) == 0, 'did not find release 10' );
memory_cycle_ok($release_data);
memory_cycle_ok($releases);

($releases, $hits) = $release_data->find_by_recording(1, 100);
is( $hits, 1 );
is( scalar(@$releases), 1 );
is( $releases->[0]->id, 3, 'found release by recording' );
memory_cycle_ok($release_data);
memory_cycle_ok($releases);

($releases, $hits) = $release_data->find_by_release_group(1, 100);
is( $hits, 6 );
is( scalar(@$releases), 6 );
ok( (grep { $_->id == 1 } @$releases), 'found release by release group' );
ok( (grep { $_->id == 2 } @$releases), 'found release by release group' );
memory_cycle_ok($release_data);
memory_cycle_ok($releases);

my @releases = $release_data->find_by_medium(1, 100);
is( $releases[0]->id, 3 );
memory_cycle_ok($release_data);
memory_cycle_ok(\@releases);

my $annotation = $release_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

memory_cycle_ok($release_data);
memory_cycle_ok($annotation);

$release = $release_data->get_by_gid('71dc55d8-0fc6-41c1-94e0-85ff2404997d');
is ( $release->id, 1, 'get release by gid' );

memory_cycle_ok($release_data);
memory_cycle_ok($release);

my %names = $release_data->find_or_insert_names('Arrival', 'Release #2', 'Protection');
is(keys %names, 3);
is($names{'Arrival'}, 1);
is($names{'Release #2'}, 2);
ok($names{'Protection'} > 2);

memory_cycle_ok($release_data);
memory_cycle_ok(\%names);

my $sql = $test->c->sql;
my $raw_sql = $test->c->raw_sql;
$sql->begin;
$release = $release_data->insert({
        name => 'Protection',
        artist_credit => 1,
        release_group_id => 1,
        packaging_id => 1,
        status_id => 1,
        date => { year => 2001, month => 2, day => 15 },
        barcode => '0123456789',
        country_id => 1,
        script_id => 1,
        language_id => 1,
        comment => 'A comment',
    });
memory_cycle_ok($release_data);

$release = $release_data->get_by_id($release->id);
ok(defined $release, 'get release by id');
is($release->name, 'Protection', 'release is called "Protection"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2001);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 1);
is($release->script_id, 1);
is($release->language_id, 1);
is($release->comment, 'A comment');

$release_data->update($release->id, {
        name => 'Blue Lines',
        country_id => 1,
        date => { year => 2002 },
    });
memory_cycle_ok($release_data);

$release = $release_data->get_by_id($release->id);
ok(defined $release);
is($release->name, 'Blue Lines', 'release is called "Blue Lines"');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2002);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 1);

$release_data->delete($release->id);
memory_cycle_ok($release_data);

$release = $release_data->get_by_id($release->id);
ok(!defined $release);
$sql->commit;

# Both #1 and #2 are in the DB
$release = $release_data->get_by_id(1);
ok(defined $release);
$release = $release_data->get_by_id(2);
ok(defined $release);

# Merge #7 into #6 with append stategy
$raw_sql->begin;
$sql->begin;
$release_data->merge(
    new_id => 6,
    old_ids => [ 7 ],
    medium_positions => {
        3 => 1,
        2 => 2
    }
);
memory_cycle_ok($release_data);

$release = $release_data->get_by_id(6);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 2);
is($release->mediums->[0]->id, 3);
is($release->mediums->[0]->position, 1);
is($release->mediums->[1]->id, 2);
is($release->mediums->[1]->position, 2);
memory_cycle_ok($release);

# Only #6 is now in the DB
$release = $release_data->get_by_id(6);
ok(defined $release);
$release = $release_data->get_by_id(7);
ok(!defined $release);

$raw_sql->commit;
$sql->commit;

# Merge #9 into #8 with merge stategy
$raw_sql->begin;
$sql->begin;
$release_data->merge(new_id => 8, old_ids => [ 9 ], merge_strategy => 2);
$release = $release_data->get_by_id(8);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 1);
is($release->mediums->[0]->id, 4);
is($release->mediums->[0]->position, 1);
memory_cycle_ok($release);

# Make sure it merged the recordings
is(
    $test->c->model('Recording')->get_by_gid('64cac850-f0cc-11df-98cf-0800200c9a66')->id,
    $test->c->model('Recording')->get_by_gid('691ee030-f0cc-11df-98cf-0800200c9a66')->id
);

# Only #6 is now in the DB
$release = $release_data->get_by_id(8);
ok(defined $release);
$release = $release_data->get_by_id(9);
ok(!defined $release);

$raw_sql->commit;
$sql->commit;

};

test 'Merge and set medium names' => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

my $sql = $test->c->sql;
my $raw_sql = $test->c->raw_sql;

$raw_sql->begin;
$sql->begin;

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);
memory_cycle_ok($release_data);

# Merge #7 into #6 with append stategy
$release_data->merge(
    new_id => 6,
    old_ids => [ 7 ],
    medium_positions => {
        3 => 1,
        2 => 2
    },
    medium_names => {
        3 => 'Foo',
        2 => 'Bar'
    }
);
memory_cycle_ok($release_data);

my $release = $release_data->get_by_id(6);
$test->c->model('Medium')->load_for_releases($release);
is($release->all_mediums, 2);
is($release->mediums->[0]->id, 3);
is($release->mediums->[0]->position, 1);
is($release->mediums->[0]->name, 'Foo');
is($release->mediums->[1]->id, 2);
is($release->mediums->[1]->position, 2);
is($release->mediums->[1]->name, 'Bar');
memory_cycle_ok($release);

# Only #6 is now in the DB
$release = $release_data->get_by_id(6);
ok(defined $release);
$release = $release_data->get_by_id(7);
ok(!defined $release);

$raw_sql->commit;
$sql->commit;

};

1;
