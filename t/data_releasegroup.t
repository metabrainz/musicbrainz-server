use strict;
use warnings;
use Test::More tests => 26;
use_ok 'MusicBrainz::Server::Data::ReleaseGroup';
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);

my $rg = $rg_data->get_by_id(1);
is( $rg->id, 1 );
is( $rg->gid, "234c079d-374e-4436-9448-da92dedef3ce" );
is( $rg->name, "Arrival" );
is( $rg->artist_credit_id, 2 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 0 );

$rg = $rg_data->get_by_gid("234c079d-374e-4436-9448-da92dedef3ce");
is( $rg->id, 1 );
is( $rg->gid, "234c079d-374e-4436-9448-da92dedef3ce" );
is( $rg->name, "Arrival" );
is( $rg->artist_credit_id, 2 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 0 );

my ($rgs, $hits) = $rg_data->find_by_artist(7, 100);
is( $hits, 1 );
is( scalar(@$rgs), 1 );
is( $rgs->[0]->name, "Aerial" );

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);
my $release = $release_data->get_by_id(2);
isnt( $release, undef );
is( $release->release_group, undef );
$rg_data->load($release);
isnt( $release->release_group, undef );
is( $release->release_group->name, "Aerial" );

my $annotation = $rg_data->annotation->get_latest(1);
is ( $annotation->text, "Test annotation 5." );

$rg = $rg_data->get_by_gid('77637e8c-be66-46ea-87b3-73addc722fc9');
is ( $rg->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $c);
my $results;
($results, $hits) = $search->search("release_group", "arrival", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Arrival" );
