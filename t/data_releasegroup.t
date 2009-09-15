#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 42;
use_ok 'MusicBrainz::Server::Data::ReleaseGroup';
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+releasegroup');

my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);

my $rg = $rg_data->get_by_id(1);
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 2 );

$rg = $rg_data->get_by_gid('7b5d22d0-72d7-11de-8a39-0800200c9a66');
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 2 );

my ($rgs, $hits) = $rg_data->find_by_artist(1, 100);
is( $hits, 2 );
is( scalar(@$rgs), 2 );
is( $rgs->[0]->id, 1 );
is( $rgs->[1]->id, 2 );

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);
my $release = $release_data->get_by_id(1);
isnt( $release, undef );
is( $release->release_group, undef );
$rg_data->load($release);
isnt( $release->release_group, undef );
is( $release->release_group->id, 1 );

my $annotation = $rg_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

$rg = $rg_data->get_by_gid('77637e8c-be66-46ea-87b3-73addc722fc9');
is ( $rg->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $c);
my $results;
($results, $hits) = $search->search("release_group", "release group", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->id, 1 );

my $sql = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);
$sql->begin;
$raw_sql->begin;

$rg = $rg_data->insert({
        name => 'My Demons',
        artist_credit => 1,
        type_id => 1,
        comment => 'Dubstep album',
    });
ok(defined $rg);
isa_ok($rg, 'MusicBrainz::Server::Entity::ReleaseGroup');
ok($rg->id > 1);
ok($rg->gid);

$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Demons');
is($rg->type_id, 1);
is($rg->comment, 'Dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->update($rg->id, { name => 'My Angels', comment => 'Fake dubstep album' });
$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Angels');
is($rg->type_id, 1);
is($rg->comment, 'Fake dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->delete($rg->id);
$rg = $rg_data->get_by_id($rg->id);
ok(!defined $rg);

$rg_data->merge(1, 2);
$rg = $rg_data->get_by_id(2);
ok(!defined $rg);

$rg = $rg_data->get_by_id(1);
ok(defined $rg);

$raw_sql->commit;
$sql->commit;
