use strict;
use warnings;
use Test::More tests => 13;
use_ok 'MusicBrainz::Server::Data::ReleaseGroup';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);

my $rg = $rg_data->get_by_id(1);
is ( $rg->id, 1 );
is ( $rg->gid, "234c079d-374e-4436-9448-da92dedef3ce" );
is ( $rg->name, "Arrival" );
is ( $rg->artist_credit_id, 2 );
is ( $rg->type_id, 1 );
is ( $rg->edits_pending, 0 );

$rg = $rg_data->get_by_gid("234c079d-374e-4436-9448-da92dedef3ce");
is ( $rg->id, 1 );
is ( $rg->gid, "234c079d-374e-4436-9448-da92dedef3ce" );
is ( $rg->name, "Arrival" );
is ( $rg->artist_credit_id, 2 );
is ( $rg->type_id, 1 );
is ( $rg->edits_pending, 0 );
