use strict;
use warnings;
use Test::More tests => 18;
use_ok 'MusicBrainz::Server::Data::Release';
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);

my $release = $release_data->get_by_id(1);
is ( $release->id, 1 );
is ( $release->gid, "f34c079d-374e-4436-9448-da92dedef3ce" );
is ( $release->name, "Arrival" );
is ( $release->artist_credit_id, 2 );
is ( $release->release_group_id, 1 );
is ( $release->status_id, 1 );
is ( $release->packaging_id, 1 );
is ( $release->date->year, 2009 );
is ( $release->date->month, 5 );
is ( $release->date->day, 8 );
is ( $release->barcode, "731453398122" );
is ( $release->edits_pending, 0 );

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);
$release_label_data->load($release);
is ( @{$release->labels}, 2 );
is ( $release->labels->[0]->label_id, 1 );
is ( $release->labels->[0]->catalog_number, "ABC-123" );
is ( $release->labels->[1]->label_id, 1 );
is ( $release->labels->[1]->catalog_number, "ABC-123-X" );
