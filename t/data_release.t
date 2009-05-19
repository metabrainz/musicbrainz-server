use strict;
use warnings;
use Test::More tests => 31;
use_ok 'MusicBrainz::Server::Data::Release';
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);

my $release = $release_data->get_by_id(1);
is( $release->id, 1 );
is( $release->gid, "f34c079d-374e-4436-9448-da92dedef3ce" );
is( $release->name, "Arrival" );
is( $release->artist_credit_id, 2 );
is( $release->release_group_id, 1 );
is( $release->status_id, 1 );
is( $release->packaging_id, 1 );
is( $release->country_id, 1 );
is( $release->date->year, 2009 );
is( $release->date->month, 5 );
is( $release->date->day, 8 );
is( $release->barcode, "731453398122" );
is( $release->edits_pending, 0 );

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);
$release_label_data->load($release);
ok( @{$release->labels} >= 2 );
is( $release->labels->[0]->label_id, 1 );
is( $release->labels->[0]->catalog_number, "ABC-123" );
is( $release->labels->[2]->label_id, 1 );
is( $release->labels->[2]->catalog_number, "ABC-123-X" );

my ($releases, $hits) = $release_data->find_by_artist(5, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->gid, "f205627f-b70a-409d-adbe-66289b614e80" );
is( $releases->[0]->date->day, 7 );
is( $releases->[1]->gid, "9b3d9383-3d2a-417f-bfbb-56f7c15f075b" );
is( $releases->[1]->date->day, 8 );

($releases, $hits) = $release_data->find_by_release_group(2, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->gid, "f205627f-b70a-409d-adbe-66289b614e80" );
is( $releases->[0]->date->day, 7 );
is( $releases->[1]->gid, "9b3d9383-3d2a-417f-bfbb-56f7c15f075b" );
is( $releases->[1]->date->day, 8 );
