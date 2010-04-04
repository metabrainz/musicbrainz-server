#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 45;
use MusicBrainz::Server::Test;

use_ok 'MusicBrainz::Server::Data::Work';
use MusicBrainz::Server::Data::WorkType;
use MusicBrainz::Server::Data::Search;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+work');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $c);

my $work = $work_data->get_by_id(1);
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 1 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

$work = $work_data->get_by_gid("745c079d-374e-4436-9448-da92dedef3ce");
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 1 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

is ( $work->type, undef );
MusicBrainz::Server::Data::WorkType->new(c => $c)->load($work);
is ( $work->type->name, "Composition" );

my ($works, $hits) = $work_data->find_by_artist(1, 100);
is( $hits, 1 );
is( scalar(@$works), 1 );
is( $works->[0]->name, "Dancing Queen" );

my $annotation = $work_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

$work = $work_data->get_by_gid('28e73402-5666-4d74-80ab-c3734dc699ea');
is ( $work->id, 1 );

$work = $work_data->get_by_gid('ffffffff-ffff-ffff-ffff-ffffffffffff');
is ( $work, undef );

my $search = MusicBrainz::Server::Data::Search->new(c => $c);
my $results;
($results, $hits) = $search->search("work", "queen", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Dancing Queen" );

my %names = $work_data->find_or_insert_names('Dancing Queen', 'Traits');
is(keys %names, 2);
is($names{'Dancing Queen'}, 1);
ok($names{'Traits'} > 1);

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);
$sql->begin;
$raw_sql->begin;

$work = $work_data->insert({
        name => 'Traits',
        artist_credit => 1,
        type_id => 1,
        iswc => 'T-000.000.001-0',
        comment => 'Drum & bass track',
    });
isa_ok($work, 'MusicBrainz::Server::Entity::Work');
ok($work->id > 1);

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits');
is($work->artist_credit_id, 1);
is($work->comment, 'Drum & bass track');
is($work->iswc, 'T-000.000.001-0');
is($work->type_id, 1);
ok(defined $work->gid);

$work_data->update($work->id, {
        name => 'Traits (remix)',
        iswc => 'T-100.000.001-0',
    });

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits (remix)');
is($work->iswc, 'T-100.000.001-0');

$work_data->delete($work);
$work = $work_data->get_by_id($work->id);
ok(!defined $work);

$raw_sql->commit;
$sql->commit;


# Both #1 and #2 are in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(defined $work);

# Merge #2 into #1
$sql->begin;
$raw_sql->begin;
$work_data->merge(1, 2);
$sql->commit;
$raw_sql->commit;

# Only #1 is now in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(!defined $work);
