#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::Release';
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+release');

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);

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
is( $release->quality, -1 );

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);
$release_label_data->load($release);
ok( @{$release->labels} >= 2 );
is( $release->labels->[0]->label_id, 1 );
is( $release->labels->[0]->catalog_number, "ABC-123", 'release has catalog number ABC-123');
is( $release->labels->[1]->label_id, 1 );
is( $release->labels->[1]->catalog_number, "ABC-123-X", 'release also has catalog number ABC-123-X' );

$release = $release_data->get_by_id(2);
is( $release->quality, -1 );

my ($releases, $hits) = $release_data->find_by_artist(1, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->id, 1, 'found release by artist');
is( $releases->[1]->id, 2, 'found release by artist');

($releases, $hits) = $release_data->find_by_track_artist(1, 100);
is( $hits, 1 );
is( scalar(@$releases), 1 );
is( $releases->[0]->id, 3, 'found release by track artist');

($releases, $hits) = $release_data->find_by_recording(1, 100);
is( $hits, 1 );
is( scalar(@$releases), 1 );
is( $releases->[0]->id, 3, 'found release by recording' );

($releases, $hits) = $release_data->find_by_release_group(1, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->id, 1, 'found release by release group' );
is( $releases->[1]->id, 2, 'found release by release group' );

my @releases = $release_data->find_by_medium(1, 100);
is( $releases[0]->id, 3 );

my $annotation = $release_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

$release = $release_data->get_by_gid('71dc55d8-0fc6-41c1-94e0-85ff2404997d');
is ( $release->id, 1, 'get release by gid' );

my %names = $release_data->find_or_insert_names('Arrival', 'Release #2', 'Protection');
is(keys %names, 3);
is($names{'Arrival'}, 1);
is($names{'Release #2'}, 2);
ok($names{'Protection'} > 2);

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);
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

$release_data->delete($release);
$release = $release_data->get_by_id($release->id);
ok(!defined $release);
$sql->commit;

# Both #1 and #2 are in the DB
$release = $release_data->get_by_id(1);
ok(defined $release);
$release = $release_data->get_by_id(2);
ok(defined $release);

# Merge #2 into #1
$raw_sql->begin;
$sql->begin;
$release_data->merge(1, 2);
$raw_sql->commit;
$sql->commit;

# Only #1 is now in the DB
$release = $release_data->get_by_id(1);
ok(defined $release);
$release = $release_data->get_by_id(2);
ok(!defined $release);

done_testing;
